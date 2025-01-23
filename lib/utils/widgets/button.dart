import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button._({
    required this.onPressed,
    required this.child,
    required this.builder,
    this.isLoading = false,
    super.key,
  });

  // Primary filled button
  factory Button.primary({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    ButtonStyle? style,
    Key? key,
  }) {
    return Button._(
      onPressed: onPressed,
      isLoading: isLoading,
      key: key,
      builder: (context, child) => FilledButton(
        style: style,
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
      child: child,
    );
  }
  factory Button.primaryWithIcon({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    Widget? icon,
    ButtonStyle? style,
    Key? key,
  }) {
    return Button._(
      onPressed: onPressed,
      isLoading: isLoading,
      key: key,
      builder: (context, child) => FilledButton.icon(
        style: style,
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? null : icon,
        label: child,
      ),
      child: child,
    );
  }

  // Secondary tonal button
  factory Button.secondary({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    ButtonStyle? style,
    Key? key,
  }) {
    return Button._(
      onPressed: onPressed,
      isLoading: isLoading,
      key: key,
      builder: (context, child) => FilledButton.tonal(
        style: style,
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
      child: child,
    );
  }

  factory Button.secondaryIcon({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    Widget? icon,
    ButtonStyle? style,
    Key? key,
  }) {
    return Button._(
      onPressed: onPressed,
      isLoading: isLoading,
      key: key,
      builder: (context, child) => FilledButton.tonalIcon(
        style: style,
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? null : icon,
        label: child,
      ),
      child: child,
    );
  }

  // Tertiary outlined button
  factory Button.tertiary({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    ButtonStyle? style,
    Key? key,
  }) {
    return Button._(
      onPressed: onPressed,
      isLoading: isLoading,
      key: key,
      builder: (context, child) => OutlinedButton(
        style: style,
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
      child: child,
    );
  }

  factory Button.tertiaryIcon({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    Widget? icon,
    ButtonStyle? style,
    Key? key,
  }) {
    return Button._(
      onPressed: onPressed,
      isLoading: isLoading,
      key: key,
      builder: (context, child) => OutlinedButton.icon(
        style: style,
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? null : icon,
        label: child,
      ),
      child: child,
    );
  }

  // Text button
  factory Button.text({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    ButtonStyle? style,
    Key? key,
  }) {
    return Button._(
      onPressed: onPressed,
      isLoading: isLoading,
      key: key,
      builder: (context, child) => TextButton(
        style: style,
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
      child: child,
    );
  }

  factory Button.textIcon({
    required VoidCallback? onPressed,
    required Widget child,
    bool isLoading = false,
    Widget? icon,
    ButtonStyle? style,
    Key? key,
  }) {
    return Button._(
      onPressed: onPressed,
      isLoading: isLoading,
      key: key,
      builder: (context, child) => TextButton.icon(
        style: style,
        onPressed: isLoading ? null : onPressed,
        icon: icon,
        label: child,
      ),
      child: child,
    );
  }

  factory Button.icon({
    required VoidCallback? onPressed,
    required Widget icon,
    bool isLoading = false,
    ButtonStyle? style,
    Key? key,
  }) {
    return Button._(
      onPressed: onPressed,
      isLoading: isLoading,
      key: key,
      builder: (context, child) => IconButton(
        onPressed: isLoading ? null : onPressed,
        icon: child,
        style: style,
      ),
      child: icon,
    );
  }
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget child;
  final Widget Function(BuildContext, Widget) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            )
          : child,
    );
  }
}
