import 'package:hive/hive.dart';
import '../metrics.dart';

/// Hive TypeAdapter for Metrics model
///
/// Enables efficient local caching of trading performance metrics
class MetricsAdapter extends TypeAdapter<Metrics> {
  @override
  final int typeId = 5;

  @override
  Metrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Metrics(
      totalTrades: fields[0] as int,
      winningTrades: fields[1] as int,
      losingTrades: fields[2] as int,
      winRate: fields[3] as double,
      totalPnl: fields[4] as double,
      dailyPnl: fields[5] as double,
      weeklyPnl: fields[6] as double,
      monthlyPnl: fields[7] as double,
      avgWin: fields[8] as double,
      avgLoss: fields[9] as double,
      profitFactor: fields[10] as double,
      sharpeRatio: fields[11] as double,
      maxDrawdown: fields[12] as double,
      activePositions: fields[13] as int,
      avgLatencyMs: fields[14] as double,
      avgSlippagePct: fields[15] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Metrics obj) {
    writer
      ..writeByte(16) // number of fields
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
      ..write(obj.dailyPnl)
      ..writeByte(6)
      ..write(obj.weeklyPnl)
      ..writeByte(7)
      ..write(obj.monthlyPnl)
      ..writeByte(8)
      ..write(obj.avgWin)
      ..writeByte(9)
      ..write(obj.avgLoss)
      ..writeByte(10)
      ..write(obj.profitFactor)
      ..writeByte(11)
      ..write(obj.sharpeRatio)
      ..writeByte(12)
      ..write(obj.maxDrawdown)
      ..writeByte(13)
      ..write(obj.activePositions)
      ..writeByte(14)
      ..write(obj.avgLatencyMs)
      ..writeByte(15)
      ..write(obj.avgSlippagePct);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
