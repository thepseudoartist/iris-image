// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'path.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PathAdapter extends TypeAdapter<Path> {
  @override
  final typeId = 0;

  @override
  Path read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Path()
      ..imagePath = fields[0] as String
      ..id = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, Path obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.id);
  }
}
