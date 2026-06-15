// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RepoMeta _$RepoMetaFromJson(Map<String, dynamic> json) => _RepoMeta(
  name: json['name'] as String,
  fullName: json['fullName'] as String,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  starCount: (json['starCount'] as num).toInt(),
  primaryLanguage: json['primaryLanguage'] as String?,
  defaultBranch: json['defaultBranch'] as String,
);

Map<String, dynamic> _$RepoMetaToJson(_RepoMeta instance) => <String, dynamic>{
  'name': instance.name,
  'fullName': instance.fullName,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
  'starCount': instance.starCount,
  'primaryLanguage': instance.primaryLanguage,
  'defaultBranch': instance.defaultBranch,
};
