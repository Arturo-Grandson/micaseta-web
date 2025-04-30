// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penalty.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Penalty _$PenaltyFromJson(Map<String, dynamic> json) => _Penalty(
      id: (json['id'] as num).toInt(),
      festiveType: json['festiveType'] as String,
      year: (json['year'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      date: json['date'] as String,
      userId: (json['userId'] as num).toInt(),
      boothId: (json['boothId'] as num).toInt(),
    );

Map<String, dynamic> _$PenaltyToJson(_Penalty instance) => <String, dynamic>{
      'id': instance.id,
      'festiveType': instance.festiveType,
      'year': instance.year,
      'amount': instance.amount,
      'reason': instance.reason,
      'date': instance.date,
      'userId': instance.userId,
      'boothId': instance.boothId,
    };
