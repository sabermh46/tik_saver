// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloaded_video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadedVideoAdapter extends TypeAdapter<DownloadedVideo> {
  @override
  final int typeId = 0;

  @override
  DownloadedVideo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadedVideo(
      awemeId: fields[0] as String,
      title: fields[1] as String,
      coverUrl: fields[2] as String,
      filePath: fields[3] as String,
      downloadDate: fields[4] as DateTime,
      authorUniqueId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadedVideo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.awemeId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.coverUrl)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.downloadDate)
      ..writeByte(5)
      ..write(obj.authorUniqueId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadedVideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
