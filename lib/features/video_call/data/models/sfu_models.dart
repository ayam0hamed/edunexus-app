import 'package:equatable/equatable.dart';

class SfuJoinResponse extends Equatable {
  final String token;
  final String sfuBaseUrl;
  final Map<String, dynamic> rtpCapabilities;
  final TransportOptions sendTransport;
  final TransportOptions recvTransport;
  final List<ProducerInfo> existingProducers;

  const SfuJoinResponse({
    required this.token,
    required this.sfuBaseUrl,
    required this.rtpCapabilities,
    required this.sendTransport,
    required this.recvTransport,
    required this.existingProducers,
  });

  factory SfuJoinResponse.fromJson(Map<String, dynamic> json) {
    final sTransport = json['sendTransport'] ?? json['sendTransportOptions'];
    final rTransport = json['recvTransport'] ?? json['recvTransportOptions'];
    final producers = json['existingProducers'] as List?;
    
    return SfuJoinResponse(
      token: json['token']?.toString() ?? '',
      sfuBaseUrl: json['sfuBaseUrl']?.toString() ?? '',
      rtpCapabilities: (json['rtpCapabilities'] ?? json['routerRtpCapabilities'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      sendTransport: sTransport != null 
          ? TransportOptions.fromJson(sTransport as Map<String, dynamic>)
          : const TransportOptions(id: '', iceParameters: {}, iceCandidates: [], dtlsParameters: {}),
      recvTransport: rTransport != null
          ? TransportOptions.fromJson(rTransport as Map<String, dynamic>)
          : const TransportOptions(id: '', iceParameters: {}, iceCandidates: [], dtlsParameters: {}),
      existingProducers: producers != null
          ? producers
              .whereType<Map<String, dynamic>>()
              .map(ProducerInfo.fromJson)
              .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [
        token,
        sfuBaseUrl,
        rtpCapabilities,
        sendTransport,
        recvTransport,
        existingProducers,
      ];
}

class TransportOptions extends Equatable {
  final String id;
  final Map<String, dynamic> iceParameters;
  final List<dynamic> iceCandidates;
  final Map<String, dynamic> dtlsParameters;
  final List<dynamic>? iceServers;

  const TransportOptions({
    required this.id,
    required this.iceParameters,
    required this.iceCandidates,
    required this.dtlsParameters,
    this.iceServers,
  });

  factory TransportOptions.fromJson(Map<String, dynamic> json) {
    return TransportOptions(
      id: json['id']?.toString() ?? '',
      iceParameters: (json['iceParameters'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      iceCandidates: (json['iceCandidates'] ?? <dynamic>[]) as List<dynamic>,
      dtlsParameters: (json['dtlsParameters'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      iceServers: json['iceServers'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'iceParameters': iceParameters,
        'iceCandidates': iceCandidates,
        'dtlsParameters': dtlsParameters,
        if (iceServers != null) 'iceServers': iceServers,
      };

  @override
  List<Object?> get props => [id, iceParameters, iceCandidates, dtlsParameters, iceServers];
}

class ProducerInfo extends Equatable {
  final String producerId;
  final String participantId;
  final String kind; // 'audio' or 'video'
  final Map<String, dynamic> appData;

  const ProducerInfo({
    required this.producerId,
    required this.participantId,
    required this.kind,
    required this.appData,
  });

  factory ProducerInfo.fromJson(Map<String, dynamic> json) {
    return ProducerInfo(
      producerId: json['producerId']?.toString() ?? json['id']?.toString() ?? '',
      participantId: json['participantId']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'video',
      appData: (json['appData'] ?? <String, dynamic>{}) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
        'producerId': producerId,
        'participantId': participantId,
        'kind': kind,
        'appData': appData,
      };

  @override
  List<Object?> get props => [producerId, participantId, kind, appData];
}
