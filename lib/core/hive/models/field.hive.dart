import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../parsers/field.parser.dart';

part 'field.hive.g.dart';

@HiveType(typeId: 2)
class HiveLisoField extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String identifier; // identifier
  @HiveField(1)
  final String type; // type of field to parse
  @HiveField(2)
  final bool reserved; // if the user can remove the field or not
  @HiveField(3)
  final bool required;
  @HiveField(4)
  HiveLisoFieldData data; // map that holds the value and/or parameters

  HiveLisoField({
    this.identifier = '',
    required this.type,
    this.reserved = true,
    this.required = false,
    required this.data,
  });

  factory HiveLisoField.fromJson(Map<String, dynamic> json) => HiveLisoField(
        identifier: json["identifier"],
        type: json["type"],
        reserved: json["reserved"],
        required: json["required"],
        data: HiveLisoFieldData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "identifier": identifier,
      "type": type,
      "reserved": reserved,
      "required": required,
      "data": data.toJson(),
    };
  }

  Widget get widget => FieldParser.parse(this);

  @override
  List<Object?> get props => [identifier, type, reserved, required, data];
}

@HiveType(typeId: 3)
class HiveLisoFieldData extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String? label;
  @HiveField(1)
  final String? hint;
  @HiveField(2)
  String? value;
  @HiveField(3)
  final List<HiveLisoFieldChoices>? choices;
  @HiveField(4)
  Map<String, dynamic>? extra;

  HiveLisoFieldData({
    this.label = '',
    this.hint = '',
    this.value = '',
    this.choices = const [],
    this.extra = const {},
  });

  factory HiveLisoFieldData.fromJson(Map<String, dynamic> json) =>
      HiveLisoFieldData(
        label: json["label"],
        hint: json["hint"],
        value: json["value"],
        choices: json["choices"] == null
            ? null
            : List<HiveLisoFieldChoices>.from(
                json["choices"].map((x) => HiveLisoFieldChoices.fromJson(x))),
        extra: json["extra"],
      );

  Map<String, dynamic> toJson() {
    return {
      "label": label,
      "hint": hint,
      "value": value,
      "choices": choices == null
          ? null
          : List<dynamic>.from(choices!.map((x) => x.toJson())),
      "extra": extra,
    };
  }

  @override
  List<Object?> get props => [value];
}

@HiveType(typeId: 4)
class HiveLisoFieldChoices extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String value;

  HiveLisoFieldChoices({
    this.name = '',
    this.value = '',
  });

  factory HiveLisoFieldChoices.fromJson(Map<String, dynamic> json) =>
      HiveLisoFieldChoices(
        name: json["name"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "value": value,
    };
  }
}

enum LisoFieldType {
  section,
  mnemonicSeed, // {seed, privateKey, address, dlt, origin}
  textField,
  textArea,
  richText,
  address, // {street1, street2, city, state, zip, country}
  date,
  time, // {timezone}
  datetime, // {timezone}
  phone, // {country code, postfix}
  email,
  url,
  password,
  pin,
  choices,
  coordinates, // {latitude, longitude}
  divider,
  spacer,
  tags,
  number,
  passport,
}
