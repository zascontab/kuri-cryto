import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_type.dart';
import '../providers/market_type_provider.dart';
import '../widgets/market_type_selector.dart';

/// Demo screen showing market type selector and features
class MarketTypeDemoScreen extends ConsumerWidget {
  const MarketTypeDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedMarketTypeProvider);
    final leverage = ref.watch(leverageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Types Tutorial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showFullTutorial(context),
            tooltip: 'Show Full Tutorial',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Welcome to Market Types',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Learn about different trading instruments and how to use them effectively. Each market type has unique characteristics and risk profiles.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showFullTutorial(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Interactive Tutorial'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Select Market Type',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the trading instrument that matches your strategy and risk tolerance.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),

          // Segmented Button Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Segmented Button',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  MarketTypeSelector(
                    selectedType: selectedType,
                    onChanged: (type) {
                      ref
                          .read(selectedMarketTypeProvider.notifier)
                          .setMarketType(type);
                      // Reset leverage when changing market type
                      if (!type.allowsLeverage) {
                        ref.read(leverageProvider.notifier).reset();
                      }
                    },
                    showAllTypes: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Chips Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Chips',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  MarketTypeChips(
                    selectedType: selectedType,
                    onChanged: (type) {
                      ref
                          .read(selectedMarketTypeProvider.notifier)
                          .setMarketType(type);
                      if (!type.allowsLeverage) {
                        ref.read(leverageProvider.notifier).reset();
                      }
                    },
                    showAllTypes: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Market Type Info
          MarketTypeInfoCard(marketType: selectedType),
          const SizedBox(height: 16),

          // Leverage Slider (only if allowed)
          if (selectedType.allowsLeverage)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Leverage',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${leverage.toInt()}x',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: leverage,
                      min: selectedType.minLeverage.toDouble(),
                      max: selectedType.maxLeverage.toDouble(),
                      divisions:
                          selectedType.maxLeverage - selectedType.minLeverage,
                      label: '${leverage.toInt()}x',
                      onChanged: (value) {
                        ref.read(leverageProvider.notifier).setLeverage(value);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${selectedType.minLeverage}x',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${selectedType.maxLeverage}x',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Example Order Summary
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                      context, 'Market Type', selectedType.displayName),
                  _buildSummaryRow(context, 'Symbol', 'BTC-USDT'),
                  if (selectedType.allowsLeverage)
                    _buildSummaryRow(
                        context, 'Leverage', '${leverage.toInt()}x'),
                  _buildSummaryRow(
                    context,
                    'Funding Rate',
                    selectedType.hasFundingRate ? 'Available' : 'N/A',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Risk Indicator
          _buildRiskIndicator(context, selectedType, leverage),
          const SizedBox(height: 16),

          // Key Features Section
          _buildKeyFeatures(context, selectedType),
          const SizedBox(height: 16),

          // Use Cases Section
          _buildUseCases(context, selectedType),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showOrderDialog(context, selectedType, leverage);
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Place Demo Order'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showComparison(context),
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Compare All'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(
      BuildContext context, MarketType marketType, double leverage) {
    final riskLevel = _calculateRiskLevel(marketType, leverage);
    final riskColor = _getRiskColor(context, riskLevel);
    final riskText = _getRiskText(riskLevel);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: riskColor),
                const SizedBox(width: 8),
                Text(
                  'Risk Assessment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: riskLevel / 100,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              color: riskColor,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  riskText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: riskColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${riskLevel.toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getRiskDescription(marketType, leverage),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyFeatures(BuildContext context, MarketType marketType) {
    final features = _getKeyFeatures(marketType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Features',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        feature['icon'] as IconData,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature['text'] as String,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildUseCases(BuildContext context, MarketType marketType) {
    final useCases = _getUseCases(marketType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Best Used For',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...useCases.map((useCase) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          useCase,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  double _calculateRiskLevel(MarketType marketType, double leverage) {
    switch (marketType) {
      case MarketType.spot:
        return 20.0; // Low risk
      case MarketType.futures:
        return 30.0 + (leverage / 100 * 50); // 30-80% based on leverage
      case MarketType.margin:
        return 40.0 + (leverage / 10 * 30); // 40-70% based on leverage
      case MarketType.options:
        return 50.0; // Medium risk
    }
  }

  Color _getRiskColor(BuildContext context, double riskLevel) {
    if (riskLevel < 30) return Colors.green;
    if (riskLevel < 60) return Colors.orange;
    return Colors.red;
  }

  String _getRiskText(double riskLevel) {
    if (riskLevel < 30) return 'Low Risk';
    if (riskLevel < 60) return 'Medium Risk';
    return 'High Risk';
  }

  String _getRiskDescription(MarketType marketType, double leverage) {
    switch (marketType) {
      case MarketType.spot:
        return 'Spot trading has the lowest risk as you own the actual asset without leverage.';
      case MarketType.futures:
        if (leverage > 50) {
          return 'High leverage futures trading carries significant risk. Consider using lower leverage.';
        } else if (leverage > 20) {
          return 'Moderate leverage increases both potential gains and losses. Trade carefully.';
        }
        return 'Futures trading with low leverage offers balanced risk-reward ratio.';
      case MarketType.margin:
        if (leverage > 5) {
          return 'Higher margin leverage amplifies both profits and losses. Monitor positions closely.';
        }
        return 'Margin trading with moderate leverage. Remember to pay attention to interest costs.';
      case MarketType.options:
        return 'Options trading requires understanding of Greeks and time decay. Suitable for hedging.';
    }
  }

  List<Map<String, dynamic>> _getKeyFeatures(MarketType marketType) {
    switch (marketType) {
      case MarketType.spot:
        return [
          {'icon': Icons.check_circle, 'text': 'Own the actual cryptocurrency'},
          {'icon': Icons.security, 'text': 'No liquidation risk'},
          {'icon': Icons.trending_up, 'text': 'Suitable for long-term holding'},
          {'icon': Icons.account_balance_wallet, 'text': 'Simple buy and sell'},
        ];
      case MarketType.futures:
        return [
          {
            'icon': Icons.rocket_launch,
            'text': 'Up to 100x leverage available'
          },
          {'icon': Icons.swap_horiz, 'text': 'Can profit from both directions'},
          {'icon': Icons.schedule, 'text': 'Funding rate every 8 hours'},
          {'icon': Icons.speed, 'text': 'High liquidity and fast execution'},
        ];
      case MarketType.margin:
        return [
          {'icon': Icons.account_balance, 'text': 'Borrow funds to trade'},
          {'icon': Icons.trending_up, 'text': 'Up to 10x leverage'},
          {
            'icon': Icons.percent,
            'text': 'Interest charged on borrowed amount'
          },
          {'icon': Icons.timer, 'text': 'Flexible repayment terms'},
        ];
      case MarketType.options:
        return [
          {'icon': Icons.shield, 'text': 'Right but not obligation to trade'},
          {'icon': Icons.calendar_today, 'text': 'Expiration date based'},
          {'icon': Icons.calculate, 'text': 'Greeks for risk management'},
          {'icon': Icons.trending_flat, 'text': 'Limited loss potential'},
        ];
    }
  }

  List<String> _getUseCases(MarketType marketType) {
    switch (marketType) {
      case MarketType.spot:
        return [
          'Long-term investment and HODLing',
          'Dollar-cost averaging strategies',
          'Building a diversified portfolio',
          'Beginners learning to trade',
        ];
      case MarketType.futures:
        return [
          'Short-term speculation on price movements',
          'Hedging existing spot positions',
          'Taking advantage of high volatility',
          'Professional day trading strategies',
        ];
      case MarketType.margin:
        return [
          'Amplifying spot trading positions',
          'Short-term trading opportunities',
          'Leveraged swing trading',
          'Intermediate traders seeking more exposure',
        ];
      case MarketType.options:
        return [
          'Hedging portfolio against downside risk',
          'Generating income through covered calls',
          'Speculating with limited risk',
          'Advanced trading strategies',
        ];
    }
  }

  void _showFullTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              AppBar(
                title: const Text('Market Types Tutorial'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildTutorialSection(
                      context,
                      '💰 Spot Trading',
                      'Direct Ownership',
                      'Spot trading is the simplest form of cryptocurrency trading. You buy and sell actual cryptocurrencies at current market prices.',
                      [
                        'No leverage - what you see is what you get',
                        'Own the actual cryptocurrency',
                        'No liquidation risk',
                        'Perfect for beginners and long-term investors',
                        'Can transfer to external wallets',
                      ],
                    ),
                    const Divider(height: 32),
                    _buildTutorialSection(
                      context,
                      '📈 Futures Trading',
                      'High Leverage Contracts',
                      'Futures allow you to trade contracts with leverage up to 100x. You can profit from both rising and falling prices.',
                      [
                        'Leverage amplifies both gains and losses',
                        'Funding rate paid/received every 8 hours',
                        'Can go long (buy) or short (sell)',
                        'Risk of liquidation if price moves against you',
                        'Requires active monitoring',
                      ],
                    ),
                    const Divider(height: 32),
                    _buildTutorialSection(
                      context,
                      '⚡ Margin Trading',
                      'Leveraged Spot Trading',
                      'Margin trading lets you borrow funds to increase your trading position up to 10x leverage.',
                      [
                        'Borrow funds from the exchange',
                        'Interest charged on borrowed amount',
                        'Up to 10x leverage',
                        'Must maintain minimum margin ratio',
                        'Risk of margin call if equity drops',
                      ],
                    ),
                    const Divider(height: 32),
                    _buildTutorialSection(
                      context,
                      '🎯 Options Trading',
                      'Rights Without Obligations',
                      'Options give you the right (but not obligation) to buy or sell at a specific price before expiration.',
                      [
                        'Call options for bullish outlook',
                        'Put options for bearish outlook',
                        'Limited loss (premium paid)',
                        'Time decay affects option value',
                        'Greeks help manage risk',
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Got it!'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialSection(
    BuildContext context,
    String title,
    String subtitle,
    String description,
    List<String> points,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ...points.map((point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _showComparison(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            children: [
              AppBar(
                title: const Text('Market Types Comparison'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Table(
                    border: TableBorder.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(1.5),
                      4: FlexColumnWidth(1.5),
                    },
                    children: [
                      _buildTableRow(
                        context,
                        ['Feature', 'Spot', 'Futures', 'Margin', 'Options'],
                        isHeader: true,
                      ),
                      _buildTableRow(
                        context,
                        ['Max Leverage', '1x', '100x', '10x', '1x'],
                      ),
                      _buildTableRow(
                        context,
                        ['Funding Rate', '❌', '✅', '❌', '❌'],
                      ),
                      _buildTableRow(
                        context,
                        ['Risk Level', 'Low', 'High', 'Medium', 'Medium'],
                      ),
                      _buildTableRow(
                        context,
                        [
                          'Complexity',
                          'Simple',
                          'Advanced',
                          'Intermediate',
                          'Advanced'
                        ],
                      ),
                      _buildTableRow(
                        context,
                        ['Liquidation Risk', '❌', '✅', '✅', '❌'],
                      ),
                      _buildTableRow(
                        context,
                        ['Own Asset', '✅', '❌', '✅', '❌'],
                      ),
                      _buildTableRow(
                        context,
                        ['Short Selling', '❌', '✅', '✅', '✅'],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(BuildContext context, List<String> cells,
      {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            )
          : null,
      children: cells
          .map((cell) => Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  cell,
                  style: isHeader
                      ? Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                      : Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
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

  void _showOrderDialog(
      BuildContext context, MarketType marketType, double leverage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${marketType.icon} ${marketType.displayName} Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Symbol: BTC-USDT'),
            Text('Market Type: ${marketType.value}'),
            if (marketType.allowsLeverage)
              Text('Leverage: ${leverage.toInt()}x'),
            const SizedBox(height: 16),
            Text(
              'This is a demo. In production, this would submit an order to the backend with market_type parameter.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order placed: ${marketType.displayName}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
