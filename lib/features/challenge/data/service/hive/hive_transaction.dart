import 'package:hive_flutter/hive_flutter.dart';

typedef BoxName = String;
typedef BoxKey = dynamic;

/// Handles atomic operations on Hive boxes with rollback capability
class HiveTransaction<T> {
  /// Maps box names to their instances
  final Map<BoxName, Box<T>> _boxes = {};

  /// Tracks pending write operations by box name and key
  final Map<BoxName, Map<BoxKey, T>> _pendingWrites = {};

  /// Tracks pending delete operations in format "boxName:key"
  final Set<String> _pendingDeletes = {};

  /// Stores original values for rollback by box name and key
  final Map<BoxName, Map<BoxKey, T>> _originalValues = {};

  Future<void> put(Box<T> box, dynamic key, T value) async {
    final boxName = box.name;
    _boxes[boxName] = box;

    // Store original value for rollback
    _originalValues[boxName] ??= {};
    if (!_originalValues[boxName]!.containsKey(key)) {
      final value = box.get(key);
      if (value != null) {
        // Only store non-null values
        _originalValues[boxName]![key] = value;
      }
    }

    _pendingWrites[boxName] ??= {};
    _pendingWrites[boxName]![key] = value;
  }

  Future<void> delete(Box<T> box, dynamic key) async {
    final boxName = box.name;
    _boxes[boxName] = box;

    // Store original value for rollback
    _originalValues[boxName] ??= {};
    if (!_originalValues[boxName]!.containsKey(key)) {
      final value = box.get(key);
      if (value != null) {
        // Only store non-null values
        _originalValues[boxName]![key] = value;
      }
    }

    _pendingDeletes.add('$boxName:$key');
  }

  Future<void> commit() async {
    try {
      await _executeOperations();
      _clear();
    } catch (e) {
      await rollback();
      _clear();
      throw CommitError(e);
    }
  }

  Future<void> rollback() async {
    try {
      await Future.wait(
        _originalValues.entries.map((entry) {
          final box = _boxes[entry.key]!;
          return Future.wait(
            entry.value.entries.map((valueEntry) {
              final key = valueEntry.key;
              final value = valueEntry.value;
              return value == null ? box.delete(key) : box.put(key, value);
            }),
          );
        }),
      );
    } catch (e) {
      throw RollbackError(e);
    }
  }

  Future<void> _executeOperations() async {
    await Future.wait(
      _pendingDeletes.map((deleteKey) {
        final parts = deleteKey.split(':');
        final box = _boxes[parts[0]]!;
        return box.delete(parts[1]);
      }),
    );

    await Future.wait(
      _pendingWrites.entries.map((entry) {
        final box = _boxes[entry.key]!;
        return box.putAll(entry.value);
      }),
    );
  }

  void _clear() {
    _boxes.clear();
    _pendingWrites.clear();
    _pendingDeletes.clear();
    _originalValues.clear();
  }
}

sealed class TransactionError implements Exception {
  const TransactionError();
}

class CommitError extends TransactionError {
  const CommitError(this.error);
  final Object error;
}

class RollbackError extends TransactionError {
  const RollbackError(this.error);
  final Object error;
}
