import 'package:hive/hive.dart';
import '../risk_state.dart';

/// Hive TypeAdapter for RiskState model
///
/// Enables efficient local caching of risk monitoring state
class RiskStateAdapter extends TypeAdapter<RiskState> {
  @override
  final int typeId = 4;

  @override
  RiskState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Safely parse exposureBySymbol from dynamic map
    Map<String, double> exposureBySymbol = {};
    if (fields[4] != null) {
      final rawMap = fields[4];
      if (rawMap is Map) {
        exposureBySymbol = Map<String, double>.from(
          rawMap.map((key, value) => MapEntry(
                key.toString(),
                value is double ? value : (value as num).toDouble(),
              )),
        );
      }
    }

    return RiskState(
      currentDrawdownDaily: fields[0] as double,
      currentDrawdownWeekly: fields[1] as double,
      currentDrawdownMonthly: fields[2] as double,
      totalExposure: fields[3] as double,
      exposureBySymbol: exposureBySymbol,
      consecutiveLosses: fields[5] as int,
      riskMode: fields[6] as String,
      killSwitchActive: fields[7] as bool,
      lastUpdate: fields[8] as DateTime,
      maxDailyDrawdown: fields[9] as double,
      maxWeeklyDrawdown: fields[10] as double,
      maxMonthlyDrawdown: fields[11] as double,
      maxConsecutiveLosses: fields[12] as int,
      maxTotalExposure: fields[13] as double,
    );
  }

  @override
  void write(BinaryWriter writer, RiskState obj) {
    writer
      ..writeByte(14) // number of fields
      ..writeByte(0)
      ..write(obj.currentDrawdownDaily)
      ..writeByte(1)
      ..write(obj.currentDrawdownWeekly)
      ..writeByte(2)
      ..write(obj.currentDrawdownMonthly)
      ..writeByte(3)
      ..write(obj.totalExposure)
      ..writeByte(4)
      ..write(obj.exposureBySymbol)
      ..writeByte(5)
      ..write(obj.consecutiveLosses)
      ..writeByte(6)
      ..write(obj.riskMode)
      ..writeByte(7)
      ..write(obj.killSwitchActive)
      ..writeByte(8)
      ..write(obj.lastUpdate)
      ..writeByte(9)
      ..write(obj.maxDailyDrawdown)
      ..writeByte(10)
      ..write(obj.maxWeeklyDrawdown)
      ..writeByte(11)
      ..write(obj.maxMonthlyDrawdown)
      ..writeByte(12)
      ..write(obj.maxConsecutiveLosses)
      ..writeByte(13)
      ..write(obj.maxTotalExposure);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
