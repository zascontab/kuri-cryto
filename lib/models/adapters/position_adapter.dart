import 'package:hive/hive.dart';
import '../position.dart';

/// Hive TypeAdapter for Position model
///
/// Enables efficient local caching of trading positions
class PositionAdapter extends TypeAdapter<Position> {
  @override
  final int typeId = 0;

  @override
  Position read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Position(
      id: fields[0] as String,
      symbol: fields[1] as String,
      side: fields[2] as String,
      entryPrice: fields[3] as double,
      currentPrice: fields[4] as double,
      size: fields[5] as double,
      leverage: fields[6] as double,
      stopLoss: fields[7] as double?,
      takeProfit: fields[8] as double?,
      unrealizedPnl: fields[9] as double,
      realizedPnl: fields[10] as double,
      openTime: fields[11] as DateTime,
      closeTime: fields[12] as DateTime?,
      strategy: fields[13] as String,
      status: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Position obj) {
    writer
      ..writeByte(15) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.side)
      ..writeByte(3)
      ..write(obj.entryPrice)
      ..writeByte(4)
      ..write(obj.currentPrice)
      ..writeByte(5)
      ..write(obj.size)
      ..writeByte(6)
      ..write(obj.leverage)
      ..writeByte(7)
      ..write(obj.stopLoss)
      ..writeByte(8)
      ..write(obj.takeProfit)
      ..writeByte(9)
      ..write(obj.unrealizedPnl)
      ..writeByte(10)
      ..write(obj.realizedPnl)
      ..writeByte(11)
      ..write(obj.openTime)
      ..writeByte(12)
      ..write(obj.closeTime)
      ..writeByte(13)
      ..write(obj.strategy)
      ..writeByte(14)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
