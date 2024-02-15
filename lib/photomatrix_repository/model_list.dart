import 'package:json_annotation/json_annotation.dart';

part 'model_list.g.dart';

@JsonSerializable()
class Photoname {
  final String name;

  Photoname({required this.name});

  factory Photoname.fromJson(Map<String, dynamic> json) =>
      _$AnimalsFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalsToJson(this);
}
