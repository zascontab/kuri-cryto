import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/analysis.dart';
import 'services_provider.dart';

part 'analysis_provider.g.dart';

/// Provider for multi-timeframe analysis
///
/// Fetches and manages multi-timeframe analysis for a symbol
@riverpod
class MultiTimeframeAnalysisNotifier extends _$MultiTimeframeAnalysisNotifier {
  @override
  FutureOr<MultiTimeframeAnalysis?> build() async {
    // No initial state - wait for user to select symbol
    return null;
  }

  /// Analyze a symbol across multiple timeframes
  Future<void> analyze(
    String symbol, {
    List<String>? timeframes,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(analysisServiceProvider);
      return await service.analyzeMultiTimeframe(
        symbol,
        timeframes: timeframes,
      );
    });
  }

  /// Refresh current analysis
  Future<void> refresh() async {
    final currentAnalysis = state.value;
    if (currentAnalysis != null) {
      await analyze(currentAnalysis.symbol);
    }
  }

  /// Clear analysis
  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for available symbols
///
/// Fetches list of symbols available for analysis
@riverpod
Future<List<String>> availableSymbols(AvailableSymbolsRef ref) async {
  final service = ref.watch(analysisServiceProvider);
  return await service.getAvailableSymbols();
}

/// Provider for supported timeframes
///
/// Fetches list of timeframes supported by the analysis service
@riverpod
Future<List<String>> supportedTimeframes(SupportedTimeframesRef ref) async {
  final service = ref.watch(analysisServiceProvider);
  return await service.getSupportedTimeframes();
}

/// Provider for selected symbol state
///
/// Manages the currently selected symbol for analysis
@riverpod
class SelectedSymbol extends _$SelectedSymbol {
  @override
  String build() {
    return 'BTCUSDT'; // Default symbol
  }

  void setSymbol(String symbol) {
    state = symbol;
  }
}

/// Provider for selected timeframes
///
/// Manages which timeframes are selected for analysis
@riverpod
class SelectedTimeframes extends _$SelectedTimeframes {
  @override
  List<String> build() {
    return ['1m', '3m', '5m', '15m']; // Default timeframes
  }

  void setTimeframes(List<String> timeframes) {
    state = timeframes;
  }

  void toggleTimeframe(String timeframe) {
    if (state.contains(timeframe)) {
      state = state.where((t) => t != timeframe).toList();
    } else {
      state = [...state, timeframe];
    }
  }
}

/// Provider for timeframe-specific analysis
///
/// Fetches analysis for a specific symbol and timeframe
@riverpod
Future<TimeframeAnalysis> timeframeAnalysis(
  TimeframeAnalysisRef ref,
  String symbol,
  String timeframe,
) async {
  final service = ref.watch(analysisServiceProvider);
  return await service.analyzeTimeframe(symbol, timeframe);
}

/// Provider to check if a signal is bullish
@riverpod
bool isBullishSignal(IsBullishSignalRef ref, SignalType signal) {
  return signal == SignalType.buy;
}

/// Provider to check if a signal is bearish
@riverpod
bool isBearishSignal(IsBearishSignalRef ref, SignalType signal) {
  return signal == SignalType.sell;
}

/// Provider to get signal color based on type
@riverpod
int signalColor(SignalColorRef ref, SignalType signal) {
  switch (signal) {
    case SignalType.buy:
      return 0xFF10B981; // Green
    case SignalType.sell:
      return 0xFFEF4444; // Red
    case SignalType.neutral:
      return 0xFF6B7280; // Gray
  }
}

/// Provider to get confidence level description
@riverpod
String confidenceLevel(ConfidenceLevelRef ref, double confidence) {
  if (confidence >= 80) {
    return 'Very High';
  } else if (confidence >= 60) {
    return 'High';
  } else if (confidence >= 40) {
    return 'Medium';
  } else if (confidence >= 20) {
    return 'Low';
  } else {
    return 'Very Low';
  }
}
