enum CallType { audio, video }

enum CallStatus {
  calling,    
  ringing,    
  connected,  
  ended,      
  rejected,   
  missed,     
  busy,       
  failed,     
}

class CallEntity {
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

  CallEntity({
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

  CallEntity copyWith({
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
    return CallEntity(
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
}