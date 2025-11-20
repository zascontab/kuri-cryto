import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/comprehensive_analysis.dart';
import '../services/comprehensive_analysis_service.dart';
import 'services_provider.dart';

part 'comprehensive_analysis_provider.g.dart';

/// Provider for Comprehensive Analysis Service
@riverpod
ComprehensiveAnalysisService comprehensiveAnalysisService(
    ComprehensiveAnalysisServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return ComprehensiveAnalysisService(dio);
}

/// Provider for comprehensive market analysis
///
/// This is a family provider that takes a symbol parameter
/// to fetch analysis for different trading pairs
@riverpod
class ComprehensiveAnalysisNotifier extends _$ComprehensiveAnalysisNotifier {
  @override
  FutureOr<ComprehensiveAnalysis> build(String symbol) async {
    return _fetchAnalysis(symbol);
  }

  Future<ComprehensiveAnalysis> _fetchAnalysis(String symbol) async {
    final service = ref.read(comprehensiveAnalysisServiceProvider);
    return await service.getAnalysis(symbol: symbol);
  }

  /// Refresh analysis for the current symbol
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAnalysis(symbol));
  }

  /// Fetch analysis for a different symbol
  Future<void> fetchForSymbol(String newSymbol) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAnalysis(newSymbol));
  }
}

/// Provider for current selected symbol (defaults to DOGE-USDT)
@riverpod
class SelectedSymbol extends _$SelectedSymbol {
  @override
  String build() {
    return 'DOGE-USDT';
  }

  void setSymbol(String symbol) {
    state = symbol;
  }
}

/// Provider for available trading pairs
@riverpod
class AvailableSymbols extends _$AvailableSymbols {
  @override
  List<String> build() {
    return [
      'DOGE-USDT',
      'BTC-USDT',
      'ETH-USDT',
      'SOL-USDT',
      'XRP-USDT',
      'ADA-USDT',
      'MATIC-USDT',
      'DOT-USDT',
      'AVAX-USDT',
      'LINK-USDT',
    ];
  }

  void addSymbol(String symbol) {
    if (!state.contains(symbol)) {
      state = [...state, symbol];
    }
  }

  void removeSymbol(String symbol) {
    state = state.where((s) => s != symbol).toList();
  }
}
