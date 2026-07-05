import 'package:equatable/equatable.dart';

class MeetingModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String courseName;
  final String date;
  final String time;
  final String duration;
  final String slotsInfo;
  final String type;
  final String? joinUrl;

  const MeetingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseName,
    required this.date,
    required this.time,
    required this.duration,
    required this.slotsInfo,
    required this.type,
    this.joinUrl,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['meetingName']?.toString() ?? '',
      description: json['description']?.toString() ?? json['meetingDescription']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? json['course']?.toString() ?? '',
      date: json['date']?.toString() ?? json['meetingDate']?.toString() ?? '',
      time: json['time']?.toString() ?? json['meetingTime']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '90 minutes',
      slotsInfo: json['slotsInfo']?.toString() ?? '0/50',
      type: json['type']?.toString() ?? json['meetingType']?.toString() ?? 'Lecture',
      joinUrl: json['joinUrl']?.toString() ?? json['link']?.toString() ?? json['meetingLink']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, title, description, courseName, date, time, duration, slotsInfo, type, joinUrl];
}
