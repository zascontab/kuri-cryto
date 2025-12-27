import 'package:flutter/material.dart';
import '../utils/debouncer.dart';

/// Search field widget with debouncing for symbol search
///
/// Features:
/// - Debounced search to prevent excessive API calls
/// - Autocomplete suggestions
/// - Loading indicator
/// - Clear button
class SymbolSearchField extends StatefulWidget {
  final String? initialValue;
  final List<String> suggestions;
  final void Function(String query) onSearch;
  final void Function(String symbol)? onSymbolSelected;
  final Duration debounceDelay;
  final String hintText;
  final bool isLoading;

  const SymbolSearchField({
    super.key,
    this.initialValue,
    this.suggestions = const [],
    required this.onSearch,
    this.onSymbolSelected,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.hintText = 'Buscar símbolo (ej: BTC-USDT)',
    this.isLoading = false,
  });

  @override
  State<SymbolSearchField> createState() => _SymbolSearchFieldState();
}

class _SymbolSearchFieldState extends State<SymbolSearchField> {
  late TextEditingController _controller;
  late Debouncer _debouncer;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _debouncer = Debouncer(delay: widget.debounceDelay);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    setState(() {
      _showSuggestions = value.isNotEmpty && widget.suggestions.isNotEmpty;
    });

    if (value.isNotEmpty) {
      _debouncer.call(() {
        widget.onSearch(value);
      });
    }
  }

  void _onSuggestionSelected(String symbol) {
    _controller.text = symbol;
    setState(() {
      _showSuggestions = false;
    });
    widget.onSymbolSelected?.call(symbol);
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _showSuggestions = false;
    });
    widget.onSearch('');
  }

  List<String> get _filteredSuggestions {
    if (_controller.text.isEmpty) return [];

    return widget.suggestions
        .where((symbol) =>
            symbol.toLowerCase().contains(_controller.text.toLowerCase()))
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: _onTextChanged,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              widget.onSymbolSelected?.call(value);
            }
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                if (_controller.text.isNotEmpty && !widget.isLoading)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _filteredSuggestions.map((symbol) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.trending_up, size: 20),
                  title: Text(
                    symbol,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => _onSuggestionSelected(symbol),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

/// Debounced refresh widget for auto-refresh functionality
class DebouncedRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Duration refreshInterval;
  final bool autoRefresh;

  const DebouncedRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshInterval = const Duration(seconds: 30),
    this.autoRefresh = true,
  });

  @override
  State<DebouncedRefreshWidget> createState() => _DebouncedRefreshWidgetState();
}

class _DebouncedRefreshWidgetState extends State<DebouncedRefreshWidget> {
  late Throttler _refreshThrottler;

  @override
  void initState() {
    super.initState();
    _refreshThrottler = Throttler(duration: widget.refreshInterval);
  }

  Future<void> _handleRefresh() async {
    _refreshThrottler.call(() async {
      await widget.onRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: widget.child,
    );
  }
}
