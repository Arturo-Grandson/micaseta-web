// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'penalty.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Penalty {
  int get id;
  String get festiveType;
  int get year;
  double get amount;
  String get reason;
  String get date;
  int get userId;
  int get boothId;

  /// Create a copy of Penalty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PenaltyCopyWith<Penalty> get copyWith =>
      _$PenaltyCopyWithImpl<Penalty>(this as Penalty, _$identity);

  /// Serializes this Penalty to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Penalty &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.festiveType, festiveType) ||
                other.festiveType == festiveType) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.boothId, boothId) || other.boothId == boothId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, festiveType, year, amount,
      reason, date, userId, boothId);

  @override
  String toString() {
    return 'Penalty(id: $id, festiveType: $festiveType, year: $year, amount: $amount, reason: $reason, date: $date, userId: $userId, boothId: $boothId)';
  }
}

/// @nodoc
abstract mixin class $PenaltyCopyWith<$Res> {
  factory $PenaltyCopyWith(Penalty value, $Res Function(Penalty) _then) =
      _$PenaltyCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String festiveType,
      int year,
      double amount,
      String reason,
      String date,
      int userId,
      int boothId});
}

/// @nodoc
class _$PenaltyCopyWithImpl<$Res> implements $PenaltyCopyWith<$Res> {
  _$PenaltyCopyWithImpl(this._self, this._then);

  final Penalty _self;
  final $Res Function(Penalty) _then;

  /// Create a copy of Penalty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? festiveType = null,
    Object? year = null,
    Object? amount = null,
    Object? reason = null,
    Object? date = null,
    Object? userId = null,
    Object? boothId = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      festiveType: null == festiveType
          ? _self.festiveType
          : festiveType // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      boothId: null == boothId
          ? _self.boothId
          : boothId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Penalty implements Penalty {
  const _Penalty(
      {required this.id,
      required this.festiveType,
      required this.year,
      required this.amount,
      required this.reason,
      required this.date,
      required this.userId,
      required this.boothId});
  factory _Penalty.fromJson(Map<String, dynamic> json) =>
      _$PenaltyFromJson(json);

  @override
  final int id;
  @override
  final String festiveType;
  @override
  final int year;
  @override
  final double amount;
  @override
  final String reason;
  @override
  final String date;
  @override
  final int userId;
  @override
  final int boothId;

  /// Create a copy of Penalty
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PenaltyCopyWith<_Penalty> get copyWith =>
      __$PenaltyCopyWithImpl<_Penalty>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PenaltyToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Penalty &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.festiveType, festiveType) ||
                other.festiveType == festiveType) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.boothId, boothId) || other.boothId == boothId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, festiveType, year, amount,
      reason, date, userId, boothId);

  @override
  String toString() {
    return 'Penalty(id: $id, festiveType: $festiveType, year: $year, amount: $amount, reason: $reason, date: $date, userId: $userId, boothId: $boothId)';
  }
}

/// @nodoc
abstract mixin class _$PenaltyCopyWith<$Res> implements $PenaltyCopyWith<$Res> {
  factory _$PenaltyCopyWith(_Penalty value, $Res Function(_Penalty) _then) =
      __$PenaltyCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String festiveType,
      int year,
      double amount,
      String reason,
      String date,
      int userId,
      int boothId});
}

/// @nodoc
class __$PenaltyCopyWithImpl<$Res> implements _$PenaltyCopyWith<$Res> {
  __$PenaltyCopyWithImpl(this._self, this._then);

  final _Penalty _self;
  final $Res Function(_Penalty) _then;

  /// Create a copy of Penalty
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? festiveType = null,
    Object? year = null,
    Object? amount = null,
    Object? reason = null,
    Object? date = null,
    Object? userId = null,
    Object? boothId = null,
  }) {
    return _then(_Penalty(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      festiveType: null == festiveType
          ? _self.festiveType
          : festiveType // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      boothId: null == boothId
          ? _self.boothId
          : boothId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
