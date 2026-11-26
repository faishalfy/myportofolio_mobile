import 'package:json_annotation/json_annotation.dart';

part 'education.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Education {
  const Education({
    required this.institution,
    required this.educationLevel,
    required this.startYear,
    this.id,
    this.studyProgram = '',
    this.endYear,
    this.logoUrl = '',
    this.starCount = 0,
    this.isStarred = false,
  });

  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String institution;
  final String educationLevel;
  final String studyProgram;
  final int startYear;
  final int? endYear;
  final String logoUrl;

  @JsonKey(includeToJson: false)
  final int starCount;

  @JsonKey(includeToJson: false)
  final bool isStarred;

  Map<String, dynamic> toJson() => _$EducationToJson(this);
}
