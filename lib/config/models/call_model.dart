import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacting_app/config/entities/call_entity.dart';

class CallModel {
  final String? id;
  final String callerId;
  final String callerName;
  final String calleeId;
  final String calleeName;
  final String? channelName;
  final CallType callType;
  final CallStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? duration; 
  CallModel({
    this.id,
    required this.callerId,
    required this.callerName,
    required this.calleeId,
    required this.calleeName,
    this.channelName,
    required this.callType,
    this.status = CallStatus.calling,
    this.startedAt,
    this.endedAt,
    this.duration,
  });
  CallModel copyWith({
    String? id,
    String? callerId,
    String? callerName,
    String? calleeId,
    String? calleeName,
    String? channelName,
    CallType? callType,
    CallStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    int? duration,
  }) {
    return CallModel(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      calleeId: calleeId ?? this.calleeId,
      calleeName: calleeName ?? this.calleeName,
      channelName: channelName ?? this.channelName,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
    );
  }

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'],
      callerId: json['callerId'] ?? '',
      callerName: json['callerName'] ?? '',
      calleeId: json['calleeId'] ?? '',
      calleeName: json['calleeName'] ?? '',
      channelName: json['channelName'],
      callType: CallType.values.firstWhere(
        (e) => e.name == json['callType'],
        orElse: () => CallType.audio,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CallStatus.calling,
      ),
      startedAt: json['startedAt'] != null
          ? (json['startedAt'] as Timestamp).toDate()
          : null,
      endedAt: json['endedAt'] != null
          ? (json['endedAt'] as Timestamp).toDate()
          : null,
      duration: json['duration'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callerId': callerId,
      'callerName': callerName,
      'calleeId': calleeId,
      'calleeName': calleeName,
      'channelName': channelName,
      'callType': callType.name,
      'status': status.name,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'duration': duration,
    };
  }
  CallEntity toEntity() {
    return CallEntity(
      id: id,
      callerId: callerId,
      callerName: callerName,
      calleeId: calleeId,
      calleeName: calleeName,
      channelName: channelName,
      callType: callType,
      status: status,
      startedAt: startedAt,
      endedAt: endedAt,
      duration: duration,
    );
  }
}