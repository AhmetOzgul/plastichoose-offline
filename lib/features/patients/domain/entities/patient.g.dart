// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatientImpl _$$PatientImplFromJson(
  Map<String, dynamic> json,
) => _$PatientImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  decisionStatus:
      $enumDecodeNullable(_$DecisionStatusEnumMap, json['decisionStatus']) ??
      DecisionStatus.none,
  decisionAt: json['decisionAt'] == null
      ? null
      : DateTime.parse(json['decisionAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$PatientImplToJson(_$PatientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'images': instance.images,
      'decisionStatus': _$DecisionStatusEnumMap[instance.decisionStatus]!,
      'decisionAt': instance.decisionAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DecisionStatusEnumMap = {
  DecisionStatus.none: 'none',
  DecisionStatus.accepted: 'accepted',
  DecisionStatus.rejected: 'rejected',
};
