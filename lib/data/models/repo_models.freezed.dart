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
mixin _$Author {

 String get login; String? get avatarUrl; int get commits;
/// Create a copy of Author
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorCopyWith<Author> get copyWith => _$AuthorCopyWithImpl<Author>(this as Author, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Author&&(identical(other.login, login) || other.login == login)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.commits, commits) || other.commits == commits));
}


@override
int get hashCode => Object.hash(runtimeType,login,avatarUrl,commits);

@override
String toString() {
  return 'Author(login: $login, avatarUrl: $avatarUrl, commits: $commits)';
}


}

/// @nodoc
abstract mixin class $AuthorCopyWith<$Res>  {
  factory $AuthorCopyWith(Author value, $Res Function(Author) _then) = _$AuthorCopyWithImpl;
@useResult
$Res call({
 String login, String? avatarUrl, int commits
});




}
/// @nodoc
class _$AuthorCopyWithImpl<$Res>
    implements $AuthorCopyWith<$Res> {
  _$AuthorCopyWithImpl(this._self, this._then);

  final Author _self;
  final $Res Function(Author) _then;

/// Create a copy of Author
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? login = null,Object? avatarUrl = freezed,Object? commits = null,}) {
  return _then(_self.copyWith(
login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,commits: null == commits ? _self.commits : commits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Author].
extension AuthorPatterns on Author {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Author value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Author() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Author value)  $default,){
final _that = this;
switch (_that) {
case _Author():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Author value)?  $default,){
final _that = this;
switch (_that) {
case _Author() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String login,  String? avatarUrl,  int commits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Author() when $default != null:
return $default(_that.login,_that.avatarUrl,_that.commits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String login,  String? avatarUrl,  int commits)  $default,) {final _that = this;
switch (_that) {
case _Author():
return $default(_that.login,_that.avatarUrl,_that.commits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String login,  String? avatarUrl,  int commits)?  $default,) {final _that = this;
switch (_that) {
case _Author() when $default != null:
return $default(_that.login,_that.avatarUrl,_that.commits);case _:
  return null;

}
}

}

/// @nodoc


class _Author implements Author {
  const _Author({required this.login, this.avatarUrl, this.commits = 0});
  

@override final  String login;
@override final  String? avatarUrl;
@override@JsonKey() final  int commits;

/// Create a copy of Author
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthorCopyWith<_Author> get copyWith => __$AuthorCopyWithImpl<_Author>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Author&&(identical(other.login, login) || other.login == login)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.commits, commits) || other.commits == commits));
}


@override
int get hashCode => Object.hash(runtimeType,login,avatarUrl,commits);

@override
String toString() {
  return 'Author(login: $login, avatarUrl: $avatarUrl, commits: $commits)';
}


}

/// @nodoc
abstract mixin class _$AuthorCopyWith<$Res> implements $AuthorCopyWith<$Res> {
  factory _$AuthorCopyWith(_Author value, $Res Function(_Author) _then) = __$AuthorCopyWithImpl;
@override @useResult
$Res call({
 String login, String? avatarUrl, int commits
});




}
/// @nodoc
class __$AuthorCopyWithImpl<$Res>
    implements _$AuthorCopyWith<$Res> {
  __$AuthorCopyWithImpl(this._self, this._then);

  final _Author _self;
  final $Res Function(_Author) _then;

/// Create a copy of Author
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? login = null,Object? avatarUrl = freezed,Object? commits = null,}) {
  return _then(_Author(
login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,commits: null == commits ? _self.commits : commits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Commit {

 String get sha;/// First line of the commit message.
 String get message;/// GitHub login, or the git author name when the commit is not linked
/// to an account.
 String get author; DateTime get date;
/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommitCopyWith<Commit> get copyWith => _$CommitCopyWithImpl<Commit>(this as Commit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Commit&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.message, message) || other.message == message)&&(identical(other.author, author) || other.author == author)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,sha,message,author,date);

@override
String toString() {
  return 'Commit(sha: $sha, message: $message, author: $author, date: $date)';
}


}

/// @nodoc
abstract mixin class $CommitCopyWith<$Res>  {
  factory $CommitCopyWith(Commit value, $Res Function(Commit) _then) = _$CommitCopyWithImpl;
@useResult
$Res call({
 String sha, String message, String author, DateTime date
});




}
/// @nodoc
class _$CommitCopyWithImpl<$Res>
    implements $CommitCopyWith<$Res> {
  _$CommitCopyWithImpl(this._self, this._then);

  final Commit _self;
  final $Res Function(Commit) _then;

/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sha = null,Object? message = null,Object? author = null,Object? date = null,}) {
  return _then(_self.copyWith(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Commit].
extension CommitPatterns on Commit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Commit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Commit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Commit value)  $default,){
final _that = this;
switch (_that) {
case _Commit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Commit value)?  $default,){
final _that = this;
switch (_that) {
case _Commit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sha,  String message,  String author,  DateTime date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Commit() when $default != null:
return $default(_that.sha,_that.message,_that.author,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sha,  String message,  String author,  DateTime date)  $default,) {final _that = this;
switch (_that) {
case _Commit():
return $default(_that.sha,_that.message,_that.author,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sha,  String message,  String author,  DateTime date)?  $default,) {final _that = this;
switch (_that) {
case _Commit() when $default != null:
return $default(_that.sha,_that.message,_that.author,_that.date);case _:
  return null;

}
}

}

/// @nodoc


class _Commit implements Commit {
  const _Commit({required this.sha, required this.message, required this.author, required this.date});
  

@override final  String sha;
/// First line of the commit message.
@override final  String message;
/// GitHub login, or the git author name when the commit is not linked
/// to an account.
@override final  String author;
@override final  DateTime date;

/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommitCopyWith<_Commit> get copyWith => __$CommitCopyWithImpl<_Commit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Commit&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.message, message) || other.message == message)&&(identical(other.author, author) || other.author == author)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,sha,message,author,date);

@override
String toString() {
  return 'Commit(sha: $sha, message: $message, author: $author, date: $date)';
}


}

/// @nodoc
abstract mixin class _$CommitCopyWith<$Res> implements $CommitCopyWith<$Res> {
  factory _$CommitCopyWith(_Commit value, $Res Function(_Commit) _then) = __$CommitCopyWithImpl;
@override @useResult
$Res call({
 String sha, String message, String author, DateTime date
});




}
/// @nodoc
class __$CommitCopyWithImpl<$Res>
    implements _$CommitCopyWith<$Res> {
  __$CommitCopyWithImpl(this._self, this._then);

  final _Commit _self;
  final $Res Function(_Commit) _then;

/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sha = null,Object? message = null,Object? author = null,Object? date = null,}) {
  return _then(_Commit(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$Branch {

 String get name; BranchStatus get status;/// The branch no longer exists on GitHub and was recovered from a PR.
 bool get deleted;/// Commits on this branch that are not on its parent, newest first.
/// May be fewer than [commitCount] when GitHub truncates the list.
 List<Commit> get commits; int get commitCount;/// The branch it forked from; null means the default branch (the trunk).
 String? get parent;/// Merge base with the parent, used to place the fork on the trunk.
 String? get forkSha; DateTime? get forkDate;/// Newest commit, or the PR close date for a pruned branch.
 DateTime? get lastActivity;/// Login of the author with the most commits on the branch.
 String? get author; int? get prNumber;
/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchCopyWith<Branch> get copyWith => _$BranchCopyWithImpl<Branch>(this as Branch, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Branch&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&const DeepCollectionEquality().equals(other.commits, commits)&&(identical(other.commitCount, commitCount) || other.commitCount == commitCount)&&(identical(other.parent, parent) || other.parent == parent)&&(identical(other.forkSha, forkSha) || other.forkSha == forkSha)&&(identical(other.forkDate, forkDate) || other.forkDate == forkDate)&&(identical(other.lastActivity, lastActivity) || other.lastActivity == lastActivity)&&(identical(other.author, author) || other.author == author)&&(identical(other.prNumber, prNumber) || other.prNumber == prNumber));
}


@override
int get hashCode => Object.hash(runtimeType,name,status,deleted,const DeepCollectionEquality().hash(commits),commitCount,parent,forkSha,forkDate,lastActivity,author,prNumber);

@override
String toString() {
  return 'Branch(name: $name, status: $status, deleted: $deleted, commits: $commits, commitCount: $commitCount, parent: $parent, forkSha: $forkSha, forkDate: $forkDate, lastActivity: $lastActivity, author: $author, prNumber: $prNumber)';
}


}

/// @nodoc
abstract mixin class $BranchCopyWith<$Res>  {
  factory $BranchCopyWith(Branch value, $Res Function(Branch) _then) = _$BranchCopyWithImpl;
@useResult
$Res call({
 String name, BranchStatus status, bool deleted, List<Commit> commits, int commitCount, String? parent, String? forkSha, DateTime? forkDate, DateTime? lastActivity, String? author, int? prNumber
});




}
/// @nodoc
class _$BranchCopyWithImpl<$Res>
    implements $BranchCopyWith<$Res> {
  _$BranchCopyWithImpl(this._self, this._then);

  final Branch _self;
  final $Res Function(Branch) _then;

/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? status = null,Object? deleted = null,Object? commits = null,Object? commitCount = null,Object? parent = freezed,Object? forkSha = freezed,Object? forkDate = freezed,Object? lastActivity = freezed,Object? author = freezed,Object? prNumber = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BranchStatus,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,commits: null == commits ? _self.commits : commits // ignore: cast_nullable_to_non_nullable
as List<Commit>,commitCount: null == commitCount ? _self.commitCount : commitCount // ignore: cast_nullable_to_non_nullable
as int,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as String?,forkSha: freezed == forkSha ? _self.forkSha : forkSha // ignore: cast_nullable_to_non_nullable
as String?,forkDate: freezed == forkDate ? _self.forkDate : forkDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivity: freezed == lastActivity ? _self.lastActivity : lastActivity // ignore: cast_nullable_to_non_nullable
as DateTime?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,prNumber: freezed == prNumber ? _self.prNumber : prNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Branch].
extension BranchPatterns on Branch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Branch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Branch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Branch value)  $default,){
final _that = this;
switch (_that) {
case _Branch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Branch value)?  $default,){
final _that = this;
switch (_that) {
case _Branch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  BranchStatus status,  bool deleted,  List<Commit> commits,  int commitCount,  String? parent,  String? forkSha,  DateTime? forkDate,  DateTime? lastActivity,  String? author,  int? prNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Branch() when $default != null:
return $default(_that.name,_that.status,_that.deleted,_that.commits,_that.commitCount,_that.parent,_that.forkSha,_that.forkDate,_that.lastActivity,_that.author,_that.prNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  BranchStatus status,  bool deleted,  List<Commit> commits,  int commitCount,  String? parent,  String? forkSha,  DateTime? forkDate,  DateTime? lastActivity,  String? author,  int? prNumber)  $default,) {final _that = this;
switch (_that) {
case _Branch():
return $default(_that.name,_that.status,_that.deleted,_that.commits,_that.commitCount,_that.parent,_that.forkSha,_that.forkDate,_that.lastActivity,_that.author,_that.prNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  BranchStatus status,  bool deleted,  List<Commit> commits,  int commitCount,  String? parent,  String? forkSha,  DateTime? forkDate,  DateTime? lastActivity,  String? author,  int? prNumber)?  $default,) {final _that = this;
switch (_that) {
case _Branch() when $default != null:
return $default(_that.name,_that.status,_that.deleted,_that.commits,_that.commitCount,_that.parent,_that.forkSha,_that.forkDate,_that.lastActivity,_that.author,_that.prNumber);case _:
  return null;

}
}

}

/// @nodoc


class _Branch extends Branch {
  const _Branch({required this.name, required this.status, this.deleted = false, final  List<Commit> commits = const <Commit>[], this.commitCount = 0, this.parent, this.forkSha, this.forkDate, this.lastActivity, this.author, this.prNumber}): _commits = commits,super._();
  

@override final  String name;
@override final  BranchStatus status;
/// The branch no longer exists on GitHub and was recovered from a PR.
@override@JsonKey() final  bool deleted;
/// Commits on this branch that are not on its parent, newest first.
/// May be fewer than [commitCount] when GitHub truncates the list.
 final  List<Commit> _commits;
/// Commits on this branch that are not on its parent, newest first.
/// May be fewer than [commitCount] when GitHub truncates the list.
@override@JsonKey() List<Commit> get commits {
  if (_commits is EqualUnmodifiableListView) return _commits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_commits);
}

@override@JsonKey() final  int commitCount;
/// The branch it forked from; null means the default branch (the trunk).
@override final  String? parent;
/// Merge base with the parent, used to place the fork on the trunk.
@override final  String? forkSha;
@override final  DateTime? forkDate;
/// Newest commit, or the PR close date for a pruned branch.
@override final  DateTime? lastActivity;
/// Login of the author with the most commits on the branch.
@override final  String? author;
@override final  int? prNumber;

/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchCopyWith<_Branch> get copyWith => __$BranchCopyWithImpl<_Branch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Branch&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&const DeepCollectionEquality().equals(other._commits, _commits)&&(identical(other.commitCount, commitCount) || other.commitCount == commitCount)&&(identical(other.parent, parent) || other.parent == parent)&&(identical(other.forkSha, forkSha) || other.forkSha == forkSha)&&(identical(other.forkDate, forkDate) || other.forkDate == forkDate)&&(identical(other.lastActivity, lastActivity) || other.lastActivity == lastActivity)&&(identical(other.author, author) || other.author == author)&&(identical(other.prNumber, prNumber) || other.prNumber == prNumber));
}


@override
int get hashCode => Object.hash(runtimeType,name,status,deleted,const DeepCollectionEquality().hash(_commits),commitCount,parent,forkSha,forkDate,lastActivity,author,prNumber);

@override
String toString() {
  return 'Branch(name: $name, status: $status, deleted: $deleted, commits: $commits, commitCount: $commitCount, parent: $parent, forkSha: $forkSha, forkDate: $forkDate, lastActivity: $lastActivity, author: $author, prNumber: $prNumber)';
}


}

/// @nodoc
abstract mixin class _$BranchCopyWith<$Res> implements $BranchCopyWith<$Res> {
  factory _$BranchCopyWith(_Branch value, $Res Function(_Branch) _then) = __$BranchCopyWithImpl;
@override @useResult
$Res call({
 String name, BranchStatus status, bool deleted, List<Commit> commits, int commitCount, String? parent, String? forkSha, DateTime? forkDate, DateTime? lastActivity, String? author, int? prNumber
});




}
/// @nodoc
class __$BranchCopyWithImpl<$Res>
    implements _$BranchCopyWith<$Res> {
  __$BranchCopyWithImpl(this._self, this._then);

  final _Branch _self;
  final $Res Function(_Branch) _then;

/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? status = null,Object? deleted = null,Object? commits = null,Object? commitCount = null,Object? parent = freezed,Object? forkSha = freezed,Object? forkDate = freezed,Object? lastActivity = freezed,Object? author = freezed,Object? prNumber = freezed,}) {
  return _then(_Branch(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BranchStatus,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,commits: null == commits ? _self._commits : commits // ignore: cast_nullable_to_non_nullable
as List<Commit>,commitCount: null == commitCount ? _self.commitCount : commitCount // ignore: cast_nullable_to_non_nullable
as int,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as String?,forkSha: freezed == forkSha ? _self.forkSha : forkSha // ignore: cast_nullable_to_non_nullable
as String?,forkDate: freezed == forkDate ? _self.forkDate : forkDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivity: freezed == lastActivity ? _self.lastActivity : lastActivity // ignore: cast_nullable_to_non_nullable
as DateTime?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,prNumber: freezed == prNumber ? _self.prNumber : prNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$RepoSnapshot {

 String get owner; String get name; String? get description; int get stars; String get defaultBranch;/// Newest commits of the default branch, newest first.
 List<Commit> get trunkCommits;/// Drawn branches, most recently active first.
 List<Branch> get branches;/// Authors sorted by commit count, highest first.
 List<Author> get authors;/// Branches left out by the branch cap.
 int get omittedBranches; DateTime get fetchedAt;
/// Create a copy of RepoSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepoSnapshotCopyWith<RepoSnapshot> get copyWith => _$RepoSnapshotCopyWithImpl<RepoSnapshot>(this as RepoSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepoSnapshot&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&const DeepCollectionEquality().equals(other.trunkCommits, trunkCommits)&&const DeepCollectionEquality().equals(other.branches, branches)&&const DeepCollectionEquality().equals(other.authors, authors)&&(identical(other.omittedBranches, omittedBranches) || other.omittedBranches == omittedBranches)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}


@override
int get hashCode => Object.hash(runtimeType,owner,name,description,stars,defaultBranch,const DeepCollectionEquality().hash(trunkCommits),const DeepCollectionEquality().hash(branches),const DeepCollectionEquality().hash(authors),omittedBranches,fetchedAt);

@override
String toString() {
  return 'RepoSnapshot(owner: $owner, name: $name, description: $description, stars: $stars, defaultBranch: $defaultBranch, trunkCommits: $trunkCommits, branches: $branches, authors: $authors, omittedBranches: $omittedBranches, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class $RepoSnapshotCopyWith<$Res>  {
  factory $RepoSnapshotCopyWith(RepoSnapshot value, $Res Function(RepoSnapshot) _then) = _$RepoSnapshotCopyWithImpl;
@useResult
$Res call({
 String owner, String name, String? description, int stars, String defaultBranch, List<Commit> trunkCommits, List<Branch> branches, List<Author> authors, int omittedBranches, DateTime fetchedAt
});




}
/// @nodoc
class _$RepoSnapshotCopyWithImpl<$Res>
    implements $RepoSnapshotCopyWith<$Res> {
  _$RepoSnapshotCopyWithImpl(this._self, this._then);

  final RepoSnapshot _self;
  final $Res Function(RepoSnapshot) _then;

/// Create a copy of RepoSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? owner = null,Object? name = null,Object? description = freezed,Object? stars = null,Object? defaultBranch = null,Object? trunkCommits = null,Object? branches = null,Object? authors = null,Object? omittedBranches = null,Object? fetchedAt = null,}) {
  return _then(_self.copyWith(
owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,defaultBranch: null == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String,trunkCommits: null == trunkCommits ? _self.trunkCommits : trunkCommits // ignore: cast_nullable_to_non_nullable
as List<Commit>,branches: null == branches ? _self.branches : branches // ignore: cast_nullable_to_non_nullable
as List<Branch>,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<Author>,omittedBranches: null == omittedBranches ? _self.omittedBranches : omittedBranches // ignore: cast_nullable_to_non_nullable
as int,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RepoSnapshot].
extension RepoSnapshotPatterns on RepoSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepoSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepoSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepoSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _RepoSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepoSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _RepoSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String owner,  String name,  String? description,  int stars,  String defaultBranch,  List<Commit> trunkCommits,  List<Branch> branches,  List<Author> authors,  int omittedBranches,  DateTime fetchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepoSnapshot() when $default != null:
return $default(_that.owner,_that.name,_that.description,_that.stars,_that.defaultBranch,_that.trunkCommits,_that.branches,_that.authors,_that.omittedBranches,_that.fetchedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String owner,  String name,  String? description,  int stars,  String defaultBranch,  List<Commit> trunkCommits,  List<Branch> branches,  List<Author> authors,  int omittedBranches,  DateTime fetchedAt)  $default,) {final _that = this;
switch (_that) {
case _RepoSnapshot():
return $default(_that.owner,_that.name,_that.description,_that.stars,_that.defaultBranch,_that.trunkCommits,_that.branches,_that.authors,_that.omittedBranches,_that.fetchedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String owner,  String name,  String? description,  int stars,  String defaultBranch,  List<Commit> trunkCommits,  List<Branch> branches,  List<Author> authors,  int omittedBranches,  DateTime fetchedAt)?  $default,) {final _that = this;
switch (_that) {
case _RepoSnapshot() when $default != null:
return $default(_that.owner,_that.name,_that.description,_that.stars,_that.defaultBranch,_that.trunkCommits,_that.branches,_that.authors,_that.omittedBranches,_that.fetchedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RepoSnapshot extends RepoSnapshot {
  const _RepoSnapshot({required this.owner, required this.name, this.description, this.stars = 0, required this.defaultBranch, final  List<Commit> trunkCommits = const <Commit>[], final  List<Branch> branches = const <Branch>[], final  List<Author> authors = const <Author>[], this.omittedBranches = 0, required this.fetchedAt}): _trunkCommits = trunkCommits,_branches = branches,_authors = authors,super._();
  

@override final  String owner;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  int stars;
@override final  String defaultBranch;
/// Newest commits of the default branch, newest first.
 final  List<Commit> _trunkCommits;
/// Newest commits of the default branch, newest first.
@override@JsonKey() List<Commit> get trunkCommits {
  if (_trunkCommits is EqualUnmodifiableListView) return _trunkCommits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trunkCommits);
}

/// Drawn branches, most recently active first.
 final  List<Branch> _branches;
/// Drawn branches, most recently active first.
@override@JsonKey() List<Branch> get branches {
  if (_branches is EqualUnmodifiableListView) return _branches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branches);
}

/// Authors sorted by commit count, highest first.
 final  List<Author> _authors;
/// Authors sorted by commit count, highest first.
@override@JsonKey() List<Author> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
}

/// Branches left out by the branch cap.
@override@JsonKey() final  int omittedBranches;
@override final  DateTime fetchedAt;

/// Create a copy of RepoSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepoSnapshotCopyWith<_RepoSnapshot> get copyWith => __$RepoSnapshotCopyWithImpl<_RepoSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepoSnapshot&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&const DeepCollectionEquality().equals(other._trunkCommits, _trunkCommits)&&const DeepCollectionEquality().equals(other._branches, _branches)&&const DeepCollectionEquality().equals(other._authors, _authors)&&(identical(other.omittedBranches, omittedBranches) || other.omittedBranches == omittedBranches)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}


@override
int get hashCode => Object.hash(runtimeType,owner,name,description,stars,defaultBranch,const DeepCollectionEquality().hash(_trunkCommits),const DeepCollectionEquality().hash(_branches),const DeepCollectionEquality().hash(_authors),omittedBranches,fetchedAt);

@override
String toString() {
  return 'RepoSnapshot(owner: $owner, name: $name, description: $description, stars: $stars, defaultBranch: $defaultBranch, trunkCommits: $trunkCommits, branches: $branches, authors: $authors, omittedBranches: $omittedBranches, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class _$RepoSnapshotCopyWith<$Res> implements $RepoSnapshotCopyWith<$Res> {
  factory _$RepoSnapshotCopyWith(_RepoSnapshot value, $Res Function(_RepoSnapshot) _then) = __$RepoSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String owner, String name, String? description, int stars, String defaultBranch, List<Commit> trunkCommits, List<Branch> branches, List<Author> authors, int omittedBranches, DateTime fetchedAt
});




}
/// @nodoc
class __$RepoSnapshotCopyWithImpl<$Res>
    implements _$RepoSnapshotCopyWith<$Res> {
  __$RepoSnapshotCopyWithImpl(this._self, this._then);

  final _RepoSnapshot _self;
  final $Res Function(_RepoSnapshot) _then;

/// Create a copy of RepoSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? owner = null,Object? name = null,Object? description = freezed,Object? stars = null,Object? defaultBranch = null,Object? trunkCommits = null,Object? branches = null,Object? authors = null,Object? omittedBranches = null,Object? fetchedAt = null,}) {
  return _then(_RepoSnapshot(
owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,defaultBranch: null == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String,trunkCommits: null == trunkCommits ? _self._trunkCommits : trunkCommits // ignore: cast_nullable_to_non_nullable
as List<Commit>,branches: null == branches ? _self._branches : branches // ignore: cast_nullable_to_non_nullable
as List<Branch>,authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<Author>,omittedBranches: null == omittedBranches ? _self.omittedBranches : omittedBranches // ignore: cast_nullable_to_non_nullable
as int,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
