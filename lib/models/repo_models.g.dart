// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RepoMeta _$RepoMetaFromJson(Map<String, dynamic> json) => _RepoMeta(
  name: json['name'] as String,
  fullName: json['full_name'] as String,
  description: json['description'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  starCount: (json['stargazers_count'] as num?)?.toInt() ?? 0,
  primaryLanguage: json['primaryLanguage'] as String?,
  defaultBranch: json['default_branch'] as String? ?? 'main',
);

Map<String, dynamic> _$RepoMetaToJson(_RepoMeta instance) => <String, dynamic>{
  'name': instance.name,
  'full_name': instance.fullName,
  'description': instance.description,
  'created_at': instance.createdAt?.toIso8601String(),
  'stargazers_count': instance.starCount,
  'primaryLanguage': instance.primaryLanguage,
  'default_branch': instance.defaultBranch,
};
