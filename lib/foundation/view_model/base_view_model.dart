import 'dart:async';
import 'package:flutter/foundation.dart';

// Platform-agnostic ViewModel base class
abstract class BaseViewModel<T> extends ChangeNotifier {
  BaseViewModel() {
    _initialize();
  }

  T? _state;
  Object? _error;
  bool _isLoading = true;

  T? get state => _state;
  Object? get error => _error;
  bool get isLoading => _isLoading;

  // To be implemented by subclasses
  FutureOr<T> init();

  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await init();
      _state = result;
      _error = null;
    } on Exception catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods
  void setState(T newState) {
    _state = newState;
    notifyListeners();
  }

  void setError(Object error) {
    _error = error;
    notifyListeners();
  }

  // ignore: avoid_positional_boolean_parameters
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
