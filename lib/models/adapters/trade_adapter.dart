import 'package:hive/hive.dart';
import '../trade.dart';

/// Hive TypeAdapter for Trade model
///
/// Enables efficient local caching of trade execution history
class TradeAdapter extends TypeAdapter<Trade> {
  @override
  final int typeId = 1;

  @override
  Trade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Trade(
      id: fields[0] as String,
      orderId: fields[1] as String,
      symbol: fields[2] as String,
      side: fields[3] as String,
      type: fields[4] as String,
      price: fields[5] as double,
      size: fields[6] as double,
      status: fields[7] as String,
      latencyMs: fields[8] as double,
      timestamp: fields[9] as DateTime,
      fee: fields[10] as double?,
      feeCurrency: fields[11] as String?,
      slippagePct: fields[12] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Trade obj) {
    writer
      ..writeByte(13) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderId)
      ..writeByte(2)
      ..write(obj.symbol)
      ..writeByte(3)
      ..write(obj.side)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.size)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.latencyMs)
      ..writeByte(9)
      ..write(obj.timestamp)
      ..writeByte(10)
      ..write(obj.fee)
      ..writeByte(11)
      ..write(obj.feeCurrency)
      ..writeByte(12)
      ..write(obj.slippagePct);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
