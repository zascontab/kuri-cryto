import 'package:hive/hive.dart';
import '../system_status.dart';

/// Hive TypeAdapter for SystemStatus model
///
/// Enables efficient local caching of system health and status
class SystemStatusAdapter extends TypeAdapter<SystemStatus> {
  @override
  final int typeId = 6;

  @override
  SystemStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Safely parse errors list
    List<String> errors = [];
    if (fields[5] != null) {
      final rawList = fields[5];
      if (rawList is List) {
        errors = rawList.map((e) => e.toString()).toList();
      }
    }

    return SystemStatus(
      running: fields[0] as bool,
      uptime: fields[1] as String,
      pairsCount: fields[2] as int,
      activeStrategies: fields[3] as int,
      healthStatus: fields[4] as String,
      errors: errors,
      timestamp: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SystemStatus obj) {
    writer
      ..writeByte(7) // number of fields
      ..writeByte(0)
      ..write(obj.running)
      ..writeByte(1)
      ..write(obj.uptime)
      ..writeByte(2)
      ..write(obj.pairsCount)
      ..writeByte(3)
      ..write(obj.activeStrategies)
      ..writeByte(4)
      ..write(obj.healthStatus)
      ..writeByte(5)
      ..write(obj.errors)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
