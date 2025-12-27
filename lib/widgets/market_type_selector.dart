import 'package:flutter/material.dart';
import '../models/market_type.dart';

/// A modern segmented button widget for selecting market types.
///
/// This widget displays market types as a segmented button group, following
/// Material 3 design guidelines. It's ideal for mobile interfaces where
/// users need to switch between market types frequently.
///
/// The widget shows each market type with its emoji icon and display name.
/// The selected type is highlighted with the primary container color.
///
/// Example usage:
/// ```dart
/// MarketTypeSelector(
///   selectedType: MarketType.futures,
///   onChanged: (type) {
///     print('Selected: ${type.displayName}');
///   },
///   showAllTypes: true, // Shows all 4 market types
/// );
/// ```
///
/// See also:
/// - [MarketTypeChips] for a more compact chip-based selector
/// - [MarketTypeDropdown] for a space-efficient dropdown selector
class MarketTypeSelector extends StatelessWidget {
  /// The currently selected market type.
  final MarketType selectedType;

  /// Callback invoked when the user selects a different market type.
  final ValueChanged<MarketType> onChanged;

  /// Whether to show all market types or only the main three (Spot, Futures, Margin).
  ///
  /// When `false`, Options trading is hidden. Defaults to `true`.
  final bool showAllTypes;

  /// Creates a [MarketTypeSelector] widget.
  ///
  /// The [selectedType] and [onChanged] parameters are required.
  const MarketTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.showAllTypes = true,
  });

  @override
  Widget build(BuildContext context) {
    final types = showAllTypes
        ? MarketType.values
        : [MarketType.spot, MarketType.futures, MarketType.margin];

    return SegmentedButton<MarketType>(
      segments: types
          .map((type) => ButtonSegment<MarketType>(
                value: type,
                label: Text(type.displayName),
                icon: Text(type.icon),
              ))
          .toList(),
      selected: {selectedType},
      onSelectionChanged: (Set<MarketType> newSelection) {
        onChanged(newSelection.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primaryContainer;
            }
            return Theme.of(context).colorScheme.surface;
          },
        ),
      ),
    );
  }
}

/// A compact chip-based widget for selecting market types.
///
/// This widget displays market types as filter chips in a horizontal wrap layout.
/// It's ideal for tablet interfaces or when you need a more compact representation
/// than [MarketTypeSelector].
///
/// Each chip shows the market type's emoji icon and display name. The selected
/// chip is highlighted with the primary container color.
///
/// Example usage:
/// ```dart
/// MarketTypeChips(
///   selectedType: MarketType.spot,
///   onChanged: (type) {
///     setState(() {
///       _selectedType = type;
///     });
///   },
///   showAllTypes: false, // Only shows Spot, Futures, Margin
/// );
/// ```
///
/// See also:
/// - [MarketTypeSelector] for a segmented button style selector
/// - [MarketTypeDropdown] for a dropdown style selector
class MarketTypeChips extends StatelessWidget {
  /// The currently selected market type.
  final MarketType selectedType;

  /// Callback invoked when the user selects a different market type.
  final ValueChanged<MarketType> onChanged;

  /// Whether to show all market types or only the main three (Spot, Futures, Margin).
  ///
  /// When `false`, Options trading is hidden. Defaults to `true`.
  final bool showAllTypes;

  /// Creates a [MarketTypeChips] widget.
  ///
  /// The [selectedType] and [onChanged] parameters are required.
  const MarketTypeChips({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.showAllTypes = true,
  });

  @override
  Widget build(BuildContext context) {
    final types = showAllTypes
        ? MarketType.values
        : [MarketType.spot, MarketType.futures, MarketType.margin];

    return Wrap(
      spacing: 8,
      children: types.map((type) {
        final isSelected = type == selectedType;
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(type.icon),
              const SizedBox(width: 4),
              Text(type.displayName),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onChanged(type);
            }
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
        );
      }).toList(),
    );
  }
}

/// A dropdown widget for selecting market types.
///
/// This widget displays market types in a standard dropdown menu. It's ideal
/// for forms or interfaces with limited space where a compact selector is needed.
///
/// Each dropdown item shows the market type's emoji icon and display name.
///
/// Example usage:
/// ```dart
/// MarketTypeDropdown(
///   selectedType: MarketType.margin,
///   onChanged: (type) {
///     if (type != null) {
///       print('Selected: ${type.displayName}');
///     }
///   },
///   showAllTypes: true,
/// );
/// ```
///
/// See also:
/// - [MarketTypeSelector] for a segmented button style selector
/// - [MarketTypeChips] for a chip-based selector
class MarketTypeDropdown extends StatelessWidget {
  /// The currently selected market type.
  final MarketType selectedType;

  /// Callback invoked when the user selects a different market type.
  ///
  /// The callback receives `null` if the dropdown is dismissed without selection.
  final ValueChanged<MarketType?> onChanged;

  /// Whether to show all market types or only the main three (Spot, Futures, Margin).
  ///
  /// When `false`, Options trading is hidden. Defaults to `true`.
  final bool showAllTypes;

  /// Creates a [MarketTypeDropdown] widget.
  ///
  /// The [selectedType] and [onChanged] parameters are required.
  const MarketTypeDropdown({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.showAllTypes = true,
  });

  @override
  Widget build(BuildContext context) {
    final types = showAllTypes
        ? MarketType.values
        : [MarketType.spot, MarketType.futures, MarketType.margin];

    return DropdownButton<MarketType>(
      value: selectedType,
      onChanged: onChanged,
      items: types.map((type) {
        return DropdownMenuItem<MarketType>(
          value: type,
          child: Row(
            children: [
              Text(type.icon),
              const SizedBox(width: 8),
              Text(type.displayName),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// An informational card widget displaying detailed market type information.
///
/// This widget shows comprehensive information about a market type including:
/// - Icon and display name
/// - Description
/// - Leverage range (if applicable)
/// - Funding rate availability (for futures)
///
/// It's ideal for educational screens, demo interfaces, or anywhere users
/// need to learn about market type characteristics.
///
/// Example usage:
/// ```dart
/// MarketTypeInfoCard(
///   marketType: MarketType.futures,
/// );
/// // Displays:
/// // 📈 Futures
/// // Contracts with leverage (1-100x)
/// // Leverage: 1x - 100x
/// // Funding Rate: Available
/// ```
///
/// See also:
/// - [MarketTypeSelector] for selecting market types
/// - [MarketType] for the underlying enum
class MarketTypeInfoCard extends StatelessWidget {
  /// The market type to display information about.
  final MarketType marketType;

  /// Creates a [MarketTypeInfoCard] widget.
  ///
  /// The [marketType] parameter is required.
  const MarketTypeInfoCard({
    super.key,
    required this.marketType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  marketType.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  marketType.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              marketType.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              context,
              'Leverage',
              marketType.allowsLeverage
                  ? '${marketType.minLeverage}x - ${marketType.maxLeverage}x'
                  : 'Not available',
            ),
            if (marketType.hasFundingRate)
              _buildFeatureRow(
                context,
                'Funding Rate',
                'Available',
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a row displaying a feature label and its value.
  ///
  /// Used internally to display market type features like leverage range
  /// and funding rate availability.
  Widget _buildFeatureRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
