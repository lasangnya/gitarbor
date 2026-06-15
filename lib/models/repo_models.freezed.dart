// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repo_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RepoTree {

 RepoMeta get repo; List<ContributorBranch> get contributors;
/// Create a copy of RepoTree
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepoTreeCopyWith<RepoTree> get copyWith => _$RepoTreeCopyWithImpl<RepoTree>(this as RepoTree, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepoTree&&(identical(other.repo, repo) || other.repo == repo)&&const DeepCollectionEquality().equals(other.contributors, contributors));
}


@override
int get hashCode => Object.hash(runtimeType,repo,const DeepCollectionEquality().hash(contributors));

@override
String toString() {
  return 'RepoTree(repo: $repo, contributors: $contributors)';
}


}

/// @nodoc
abstract mixin class $RepoTreeCopyWith<$Res>  {
  factory $RepoTreeCopyWith(RepoTree value, $Res Function(RepoTree) _then) = _$RepoTreeCopyWithImpl;
@useResult
$Res call({
 RepoMeta repo, List<ContributorBranch> contributors
});


$RepoMetaCopyWith<$Res> get repo;

}
/// @nodoc
class _$RepoTreeCopyWithImpl<$Res>
    implements $RepoTreeCopyWith<$Res> {
  _$RepoTreeCopyWithImpl(this._self, this._then);

  final RepoTree _self;
  final $Res Function(RepoTree) _then;

/// Create a copy of RepoTree
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? repo = null,Object? contributors = null,}) {
  return _then(_self.copyWith(
repo: null == repo ? _self.repo : repo // ignore: cast_nullable_to_non_nullable
as RepoMeta,contributors: null == contributors ? _self.contributors : contributors // ignore: cast_nullable_to_non_nullable
as List<ContributorBranch>,
  ));
}
/// Create a copy of RepoTree
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepoMetaCopyWith<$Res> get repo {
  
  return $RepoMetaCopyWith<$Res>(_self.repo, (value) {
    return _then(_self.copyWith(repo: value));
  });
}
}


/// Adds pattern-matching-related methods to [RepoTree].
extension RepoTreePatterns on RepoTree {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepoTree value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepoTree() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepoTree value)  $default,){
final _that = this;
switch (_that) {
case _RepoTree():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepoTree value)?  $default,){
final _that = this;
switch (_that) {
case _RepoTree() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RepoMeta repo,  List<ContributorBranch> contributors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepoTree() when $default != null:
return $default(_that.repo,_that.contributors);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RepoMeta repo,  List<ContributorBranch> contributors)  $default,) {final _that = this;
switch (_that) {
case _RepoTree():
return $default(_that.repo,_that.contributors);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RepoMeta repo,  List<ContributorBranch> contributors)?  $default,) {final _that = this;
switch (_that) {
case _RepoTree() when $default != null:
return $default(_that.repo,_that.contributors);case _:
  return null;

}
}

}

/// @nodoc


class _RepoTree implements RepoTree {
  const _RepoTree({required this.repo, required final  List<ContributorBranch> contributors}): _contributors = contributors;
  

@override final  RepoMeta repo;
 final  List<ContributorBranch> _contributors;
@override List<ContributorBranch> get contributors {
  if (_contributors is EqualUnmodifiableListView) return _contributors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contributors);
}


/// Create a copy of RepoTree
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepoTreeCopyWith<_RepoTree> get copyWith => __$RepoTreeCopyWithImpl<_RepoTree>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepoTree&&(identical(other.repo, repo) || other.repo == repo)&&const DeepCollectionEquality().equals(other._contributors, _contributors));
}


@override
int get hashCode => Object.hash(runtimeType,repo,const DeepCollectionEquality().hash(_contributors));

@override
String toString() {
  return 'RepoTree(repo: $repo, contributors: $contributors)';
}


}

/// @nodoc
abstract mixin class _$RepoTreeCopyWith<$Res> implements $RepoTreeCopyWith<$Res> {
  factory _$RepoTreeCopyWith(_RepoTree value, $Res Function(_RepoTree) _then) = __$RepoTreeCopyWithImpl;
@override @useResult
$Res call({
 RepoMeta repo, List<ContributorBranch> contributors
});


@override $RepoMetaCopyWith<$Res> get repo;

}
/// @nodoc
class __$RepoTreeCopyWithImpl<$Res>
    implements _$RepoTreeCopyWith<$Res> {
  __$RepoTreeCopyWithImpl(this._self, this._then);

  final _RepoTree _self;
  final $Res Function(_RepoTree) _then;

/// Create a copy of RepoTree
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? repo = null,Object? contributors = null,}) {
  return _then(_RepoTree(
repo: null == repo ? _self.repo : repo // ignore: cast_nullable_to_non_nullable
as RepoMeta,contributors: null == contributors ? _self._contributors : contributors // ignore: cast_nullable_to_non_nullable
as List<ContributorBranch>,
  ));
}

/// Create a copy of RepoTree
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepoMetaCopyWith<$Res> get repo {
  
  return $RepoMetaCopyWith<$Res>(_self.repo, (value) {
    return _then(_self.copyWith(repo: value));
  });
}
}


/// @nodoc
mixin _$RepoMeta {

 String get name; String get fullName; String? get description; DateTime get createdAt; int get starCount; String? get primaryLanguage; String get defaultBranch;
/// Create a copy of RepoMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepoMetaCopyWith<RepoMeta> get copyWith => _$RepoMetaCopyWithImpl<RepoMeta>(this as RepoMeta, _$identity);

  /// Serializes this RepoMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepoMeta&&(identical(other.name, name) || other.name == name)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.primaryLanguage, primaryLanguage) || other.primaryLanguage == primaryLanguage)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,fullName,description,createdAt,starCount,primaryLanguage,defaultBranch);

@override
String toString() {
  return 'RepoMeta(name: $name, fullName: $fullName, description: $description, createdAt: $createdAt, starCount: $starCount, primaryLanguage: $primaryLanguage, defaultBranch: $defaultBranch)';
}


}

/// @nodoc
abstract mixin class $RepoMetaCopyWith<$Res>  {
  factory $RepoMetaCopyWith(RepoMeta value, $Res Function(RepoMeta) _then) = _$RepoMetaCopyWithImpl;
@useResult
$Res call({
 String name, String fullName, String? description, DateTime createdAt, int starCount, String? primaryLanguage, String defaultBranch
});




}
/// @nodoc
class _$RepoMetaCopyWithImpl<$Res>
    implements $RepoMetaCopyWith<$Res> {
  _$RepoMetaCopyWithImpl(this._self, this._then);

  final RepoMeta _self;
  final $Res Function(RepoMeta) _then;

/// Create a copy of RepoMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? fullName = null,Object? description = freezed,Object? createdAt = null,Object? starCount = null,Object? primaryLanguage = freezed,Object? defaultBranch = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,primaryLanguage: freezed == primaryLanguage ? _self.primaryLanguage : primaryLanguage // ignore: cast_nullable_to_non_nullable
as String?,defaultBranch: null == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RepoMeta].
extension RepoMetaPatterns on RepoMeta {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepoMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepoMeta() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepoMeta value)  $default,){
final _that = this;
switch (_that) {
case _RepoMeta():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepoMeta value)?  $default,){
final _that = this;
switch (_that) {
case _RepoMeta() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String fullName,  String? description,  DateTime createdAt,  int starCount,  String? primaryLanguage,  String defaultBranch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepoMeta() when $default != null:
return $default(_that.name,_that.fullName,_that.description,_that.createdAt,_that.starCount,_that.primaryLanguage,_that.defaultBranch);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String fullName,  String? description,  DateTime createdAt,  int starCount,  String? primaryLanguage,  String defaultBranch)  $default,) {final _that = this;
switch (_that) {
case _RepoMeta():
return $default(_that.name,_that.fullName,_that.description,_that.createdAt,_that.starCount,_that.primaryLanguage,_that.defaultBranch);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String fullName,  String? description,  DateTime createdAt,  int starCount,  String? primaryLanguage,  String defaultBranch)?  $default,) {final _that = this;
switch (_that) {
case _RepoMeta() when $default != null:
return $default(_that.name,_that.fullName,_that.description,_that.createdAt,_that.starCount,_that.primaryLanguage,_that.defaultBranch);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepoMeta implements RepoMeta {
  const _RepoMeta({required this.name, required this.fullName, this.description, required this.createdAt, required this.starCount, this.primaryLanguage, required this.defaultBranch});
  factory _RepoMeta.fromJson(Map<String, dynamic> json) => _$RepoMetaFromJson(json);

@override final  String name;
@override final  String fullName;
@override final  String? description;
@override final  DateTime createdAt;
@override final  int starCount;
@override final  String? primaryLanguage;
@override final  String defaultBranch;

/// Create a copy of RepoMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepoMetaCopyWith<_RepoMeta> get copyWith => __$RepoMetaCopyWithImpl<_RepoMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepoMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepoMeta&&(identical(other.name, name) || other.name == name)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.primaryLanguage, primaryLanguage) || other.primaryLanguage == primaryLanguage)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,fullName,description,createdAt,starCount,primaryLanguage,defaultBranch);

@override
String toString() {
  return 'RepoMeta(name: $name, fullName: $fullName, description: $description, createdAt: $createdAt, starCount: $starCount, primaryLanguage: $primaryLanguage, defaultBranch: $defaultBranch)';
}


}

/// @nodoc
abstract mixin class _$RepoMetaCopyWith<$Res> implements $RepoMetaCopyWith<$Res> {
  factory _$RepoMetaCopyWith(_RepoMeta value, $Res Function(_RepoMeta) _then) = __$RepoMetaCopyWithImpl;
@override @useResult
$Res call({
 String name, String fullName, String? description, DateTime createdAt, int starCount, String? primaryLanguage, String defaultBranch
});




}
/// @nodoc
class __$RepoMetaCopyWithImpl<$Res>
    implements _$RepoMetaCopyWith<$Res> {
  __$RepoMetaCopyWithImpl(this._self, this._then);

  final _RepoMeta _self;
  final $Res Function(_RepoMeta) _then;

/// Create a copy of RepoMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? fullName = null,Object? description = freezed,Object? createdAt = null,Object? starCount = null,Object? primaryLanguage = freezed,Object? defaultBranch = null,}) {
  return _then(_RepoMeta(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,primaryLanguage: freezed == primaryLanguage ? _self.primaryLanguage : primaryLanguage // ignore: cast_nullable_to_non_nullable
as String?,defaultBranch: null == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ContributorBranch {

 String get login; String get avatarUrl; List<GitBranch> get branches; int get totalCommits;
/// Create a copy of ContributorBranch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributorBranchCopyWith<ContributorBranch> get copyWith => _$ContributorBranchCopyWithImpl<ContributorBranch>(this as ContributorBranch, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributorBranch&&(identical(other.login, login) || other.login == login)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&const DeepCollectionEquality().equals(other.branches, branches)&&(identical(other.totalCommits, totalCommits) || other.totalCommits == totalCommits));
}


@override
int get hashCode => Object.hash(runtimeType,login,avatarUrl,const DeepCollectionEquality().hash(branches),totalCommits);

@override
String toString() {
  return 'ContributorBranch(login: $login, avatarUrl: $avatarUrl, branches: $branches, totalCommits: $totalCommits)';
}


}

/// @nodoc
abstract mixin class $ContributorBranchCopyWith<$Res>  {
  factory $ContributorBranchCopyWith(ContributorBranch value, $Res Function(ContributorBranch) _then) = _$ContributorBranchCopyWithImpl;
@useResult
$Res call({
 String login, String avatarUrl, List<GitBranch> branches, int totalCommits
});




}
/// @nodoc
class _$ContributorBranchCopyWithImpl<$Res>
    implements $ContributorBranchCopyWith<$Res> {
  _$ContributorBranchCopyWithImpl(this._self, this._then);

  final ContributorBranch _self;
  final $Res Function(ContributorBranch) _then;

/// Create a copy of ContributorBranch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? login = null,Object? avatarUrl = null,Object? branches = null,Object? totalCommits = null,}) {
  return _then(_self.copyWith(
login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,branches: null == branches ? _self.branches : branches // ignore: cast_nullable_to_non_nullable
as List<GitBranch>,totalCommits: null == totalCommits ? _self.totalCommits : totalCommits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ContributorBranch].
extension ContributorBranchPatterns on ContributorBranch {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributorBranch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributorBranch() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributorBranch value)  $default,){
final _that = this;
switch (_that) {
case _ContributorBranch():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributorBranch value)?  $default,){
final _that = this;
switch (_that) {
case _ContributorBranch() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String login,  String avatarUrl,  List<GitBranch> branches,  int totalCommits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributorBranch() when $default != null:
return $default(_that.login,_that.avatarUrl,_that.branches,_that.totalCommits);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String login,  String avatarUrl,  List<GitBranch> branches,  int totalCommits)  $default,) {final _that = this;
switch (_that) {
case _ContributorBranch():
return $default(_that.login,_that.avatarUrl,_that.branches,_that.totalCommits);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String login,  String avatarUrl,  List<GitBranch> branches,  int totalCommits)?  $default,) {final _that = this;
switch (_that) {
case _ContributorBranch() when $default != null:
return $default(_that.login,_that.avatarUrl,_that.branches,_that.totalCommits);case _:
  return null;

}
}

}

/// @nodoc


class _ContributorBranch implements ContributorBranch {
  const _ContributorBranch({required this.login, required this.avatarUrl, required final  List<GitBranch> branches, required this.totalCommits}): _branches = branches;
  

@override final  String login;
@override final  String avatarUrl;
 final  List<GitBranch> _branches;
@override List<GitBranch> get branches {
  if (_branches is EqualUnmodifiableListView) return _branches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branches);
}

@override final  int totalCommits;

/// Create a copy of ContributorBranch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributorBranchCopyWith<_ContributorBranch> get copyWith => __$ContributorBranchCopyWithImpl<_ContributorBranch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributorBranch&&(identical(other.login, login) || other.login == login)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&const DeepCollectionEquality().equals(other._branches, _branches)&&(identical(other.totalCommits, totalCommits) || other.totalCommits == totalCommits));
}


@override
int get hashCode => Object.hash(runtimeType,login,avatarUrl,const DeepCollectionEquality().hash(_branches),totalCommits);

@override
String toString() {
  return 'ContributorBranch(login: $login, avatarUrl: $avatarUrl, branches: $branches, totalCommits: $totalCommits)';
}


}

/// @nodoc
abstract mixin class _$ContributorBranchCopyWith<$Res> implements $ContributorBranchCopyWith<$Res> {
  factory _$ContributorBranchCopyWith(_ContributorBranch value, $Res Function(_ContributorBranch) _then) = __$ContributorBranchCopyWithImpl;
@override @useResult
$Res call({
 String login, String avatarUrl, List<GitBranch> branches, int totalCommits
});




}
/// @nodoc
class __$ContributorBranchCopyWithImpl<$Res>
    implements _$ContributorBranchCopyWith<$Res> {
  __$ContributorBranchCopyWithImpl(this._self, this._then);

  final _ContributorBranch _self;
  final $Res Function(_ContributorBranch) _then;

/// Create a copy of ContributorBranch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? login = null,Object? avatarUrl = null,Object? branches = null,Object? totalCommits = null,}) {
  return _then(_ContributorBranch(
login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,branches: null == branches ? _self._branches : branches // ignore: cast_nullable_to_non_nullable
as List<GitBranch>,totalCommits: null == totalCommits ? _self.totalCommits : totalCommits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$GitBranch {

 String get name; BranchStatus get status; int get commitCount; DateTime get lastCommitDate;
/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitBranchCopyWith<GitBranch> get copyWith => _$GitBranchCopyWithImpl<GitBranch>(this as GitBranch, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitBranch&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.commitCount, commitCount) || other.commitCount == commitCount)&&(identical(other.lastCommitDate, lastCommitDate) || other.lastCommitDate == lastCommitDate));
}


@override
int get hashCode => Object.hash(runtimeType,name,status,commitCount,lastCommitDate);

@override
String toString() {
  return 'GitBranch(name: $name, status: $status, commitCount: $commitCount, lastCommitDate: $lastCommitDate)';
}


}

/// @nodoc
abstract mixin class $GitBranchCopyWith<$Res>  {
  factory $GitBranchCopyWith(GitBranch value, $Res Function(GitBranch) _then) = _$GitBranchCopyWithImpl;
@useResult
$Res call({
 String name, BranchStatus status, int commitCount, DateTime lastCommitDate
});




}
/// @nodoc
class _$GitBranchCopyWithImpl<$Res>
    implements $GitBranchCopyWith<$Res> {
  _$GitBranchCopyWithImpl(this._self, this._then);

  final GitBranch _self;
  final $Res Function(GitBranch) _then;

/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? status = null,Object? commitCount = null,Object? lastCommitDate = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BranchStatus,commitCount: null == commitCount ? _self.commitCount : commitCount // ignore: cast_nullable_to_non_nullable
as int,lastCommitDate: null == lastCommitDate ? _self.lastCommitDate : lastCommitDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GitBranch].
extension GitBranchPatterns on GitBranch {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitBranch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitBranch value)  $default,){
final _that = this;
switch (_that) {
case _GitBranch():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitBranch value)?  $default,){
final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  BranchStatus status,  int commitCount,  DateTime lastCommitDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
return $default(_that.name,_that.status,_that.commitCount,_that.lastCommitDate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  BranchStatus status,  int commitCount,  DateTime lastCommitDate)  $default,) {final _that = this;
switch (_that) {
case _GitBranch():
return $default(_that.name,_that.status,_that.commitCount,_that.lastCommitDate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  BranchStatus status,  int commitCount,  DateTime lastCommitDate)?  $default,) {final _that = this;
switch (_that) {
case _GitBranch() when $default != null:
return $default(_that.name,_that.status,_that.commitCount,_that.lastCommitDate);case _:
  return null;

}
}

}

/// @nodoc


class _GitBranch implements GitBranch {
  const _GitBranch({required this.name, required this.status, required this.commitCount, required this.lastCommitDate});
  

@override final  String name;
@override final  BranchStatus status;
@override final  int commitCount;
@override final  DateTime lastCommitDate;

/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitBranchCopyWith<_GitBranch> get copyWith => __$GitBranchCopyWithImpl<_GitBranch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitBranch&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.commitCount, commitCount) || other.commitCount == commitCount)&&(identical(other.lastCommitDate, lastCommitDate) || other.lastCommitDate == lastCommitDate));
}


@override
int get hashCode => Object.hash(runtimeType,name,status,commitCount,lastCommitDate);

@override
String toString() {
  return 'GitBranch(name: $name, status: $status, commitCount: $commitCount, lastCommitDate: $lastCommitDate)';
}


}

/// @nodoc
abstract mixin class _$GitBranchCopyWith<$Res> implements $GitBranchCopyWith<$Res> {
  factory _$GitBranchCopyWith(_GitBranch value, $Res Function(_GitBranch) _then) = __$GitBranchCopyWithImpl;
@override @useResult
$Res call({
 String name, BranchStatus status, int commitCount, DateTime lastCommitDate
});




}
/// @nodoc
class __$GitBranchCopyWithImpl<$Res>
    implements _$GitBranchCopyWith<$Res> {
  __$GitBranchCopyWithImpl(this._self, this._then);

  final _GitBranch _self;
  final $Res Function(_GitBranch) _then;

/// Create a copy of GitBranch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? status = null,Object? commitCount = null,Object? lastCommitDate = null,}) {
  return _then(_GitBranch(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BranchStatus,commitCount: null == commitCount ? _self.commitCount : commitCount // ignore: cast_nullable_to_non_nullable
as int,lastCommitDate: null == lastCommitDate ? _self.lastCommitDate : lastCommitDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
