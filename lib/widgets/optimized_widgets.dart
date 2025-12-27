import 'package:flutter/material.dart';

/// Optimized card widget that prevents unnecessary rebuilds
class OptimizedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;

  const OptimizedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      color: color,
      elevation: elevation,
      shape: shape,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
}

/// Optimized list tile that uses const constructor when possible
class OptimizedListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;

  const OptimizedListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      dense: dense,
    );
  }
}

/// Optimized text widget with const constructor
class OptimizedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const OptimizedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Optimized icon with const constructor
class OptimizedIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const OptimizedIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}

/// Memoized widget that caches its build result
class MemoizedWidget extends StatefulWidget {
  final Widget Function() builder;
  final List<Object?> dependencies;

  const MemoizedWidget({
    super.key,
    required this.builder,
    required this.dependencies,
  });

  @override
  State<MemoizedWidget> createState() => _MemoizedWidgetState();
}

class _MemoizedWidgetState extends State<MemoizedWidget> {
  Widget? _cachedWidget;
  List<Object?>? _lastDependencies;

  @override
  Widget build(BuildContext context) {
    // Check if dependencies have changed
    if (_cachedWidget == null ||
        !_listEquals(_lastDependencies, widget.dependencies)) {
      _cachedWidget = widget.builder();
      _lastDependencies = List.from(widget.dependencies);
    }

    return _cachedWidget!;
  }

  bool _listEquals(List<Object?>? a, List<Object?>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }
}

/// Optimized container with const constructor when possible
class OptimizedContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const OptimizedContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      alignment: alignment,
      child: child,
    );
  }
}

/// Optimized row with const constructor
class OptimizedRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const OptimizedRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// Optimized column with const constructor
class OptimizedColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const OptimizedColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// Widget that prevents rebuilds when data hasn't changed
class StableWidget<T> extends StatefulWidget {
  final T data;
  final Widget Function(T data) builder;

  const StableWidget({
    super.key,
    required this.data,
    required this.builder,
  });

  @override
  State<StableWidget<T>> createState() => _StableWidgetState<T>();
}

class _StableWidgetState<T> extends State<StableWidget<T>> {
  Widget? _cachedWidget;
  T? _lastData;

  @override
  Widget build(BuildContext context) {
    if (_cachedWidget == null || _lastData != widget.data) {
      _cachedWidget = widget.builder(widget.data);
      _lastData = widget.data;
    }

    return _cachedWidget!;
  }
}

/// Optimized sized box with const constructor
class OptimizedSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const OptimizedSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  const OptimizedSizedBox.shrink({super.key})
      : width = 0.0,
        height = 0.0,
        child = null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}

/// Optimized padding with const constructor
class OptimizedPadding extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const OptimizedPadding({
    super.key,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}
