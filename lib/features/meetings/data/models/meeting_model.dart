import 'package:equatable/equatable.dart';

class MeetingModel extends Equatable {
  final String id;
  final String name;
  final String? createdAt;
  final bool isActive;
  final List<dynamic>? participants;
  
  // Local UI-specific helper properties (passed from UI input when creating)
  final String? courseTitle;
  final String? duration;
  final String? date;
  final String? time;
  final String? maxAttendees;

  const MeetingModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.isActive = true,
    this.participants,
    this.courseTitle,
    this.duration,
    this.date,
    this.time,
    this.maxAttendees,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['meetingName']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      participants: json['participants'] as List<dynamic>?,
      courseTitle: json['courseTitle']?.toString(),
      duration: json['duration']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      maxAttendees: json['maxAttendees']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'isActive': isActive,
      'participants': participants,
      'courseTitle': courseTitle,
      'duration': duration,
      'date': date,
      'time': time,
      'maxAttendees': maxAttendees,
    };
  }

  MeetingModel copyWith({
    String? id,
    String? name,
    String? createdAt,
    bool? isActive,
    List<dynamic>? participants,
    String? courseTitle,
    String? duration,
    String? date,
    String? time,
    String? maxAttendees,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      participants: participants ?? this.participants,
      courseTitle: courseTitle ?? this.courseTitle,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      time: time ?? this.time,
      maxAttendees: maxAttendees ?? this.maxAttendees,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        createdAt,
        isActive,
        participants,
        courseTitle,
        duration,
        date,
        time,
        maxAttendees,
      ];
}
