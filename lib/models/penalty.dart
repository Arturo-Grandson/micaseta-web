import 'package:freezed_annotation/freezed_annotation.dart';

part 'penalty.freezed.dart';
part 'penalty.g.dart';

@freezed
abstract class Penalty with _$Penalty {
  const factory Penalty({
    required int id,
    required String festiveType,
    required int year,
    required double amount,
    required String reason,
    required String date,
    required int userId,
    required int boothId,
  }) = _Penalty;

  factory Penalty.fromJson(Map<String, dynamic> json) =>
      _$PenaltyFromJson(json);
}
