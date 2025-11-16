import 'package:hive/hive.dart';
import '../strategy.dart';

/// Hive TypeAdapter for StrategyPerformance model
///
/// Enables efficient local caching of strategy performance metrics
class StrategyPerformanceAdapter extends TypeAdapter<StrategyPerformance> {
  @override
  final int typeId = 3;

  @override
  StrategyPerformance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return StrategyPerformance(
      totalTrades: fields[0] as int,
      winningTrades: fields[1] as int,
      losingTrades: fields[2] as int,
      winRate: fields[3] as double,
      totalPnl: fields[4] as double,
      avgWin: fields[5] as double,
      avgLoss: fields[6] as double,
      sharpeRatio: fields[7] as double,
      maxDrawdown: fields[8] as double,
      profitFactor: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, StrategyPerformance obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.totalTrades)
      ..writeByte(1)
      ..write(obj.winningTrades)
      ..writeByte(2)
      ..write(obj.losingTrades)
      ..writeByte(3)
      ..write(obj.winRate)
      ..writeByte(4)
      ..write(obj.totalPnl)
      ..writeByte(5)
      ..write(obj.avgWin)
      ..writeByte(6)
      ..write(obj.avgLoss)
      ..writeByte(7)
      ..write(obj.sharpeRatio)
      ..writeByte(8)
      ..write(obj.maxDrawdown)
      ..writeByte(9)
      ..write(obj.profitFactor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrategyPerformanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Hive TypeAdapter for Strategy model
///
/// Enables efficient local caching of trading strategies
class StrategyAdapter extends TypeAdapter<Strategy> {
  @override
  final int typeId = 2;

  @override
  Strategy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Safely parse config from dynamic map
    Map<String, dynamic>? config;
    if (fields[4] != null) {
      final rawConfig = fields[4];
      if (rawConfig is Map) {
        config = Map<String, dynamic>.from(rawConfig);
      }
    }

    return Strategy(
      name: fields[0] as String,
      active: fields[1] as bool,
      weight: fields[2] as double,
      performance: fields[3] as StrategyPerformance,
      config: config,
    );
  }

  @override
  void write(BinaryWriter writer, Strategy obj) {
    writer
      ..writeByte(5) // number of fields
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.active)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.performance)
      ..writeByte(4)
      ..write(obj.config);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrategyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
