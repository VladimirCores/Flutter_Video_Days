import 'dart:async';

import 'package:dio/dio.dart';
import 'package:video_days/constants/types/video_stream_type.dart';

const POSSIBLE_CDN = <String?>['akfire_interconnect_quic', 'fastly_skyfire'];

class VimeoService {
  final dio = Dio();

  VimeoService() {}

  String? _getVideoLinkFromProgressive(Map<String, dynamic> files) {
    final progressive = files[VideoStreamType.PROGRESSIVE] as List<dynamic>;
    print('> VimeoService -> _getVideoLinkFromProgressiveList: ${progressive.isNotEmpty}');
    if (progressive.isNotEmpty) {
      var stream = progressive.first as Map<String, dynamic>;
      for (var item in progressive) {
        if (item['width'] >= stream['width'] && item['width'] <= 1920) {
          stream = item;
        }
      }
      return stream['url'];
    }
    return null;
  }

  Future<String?> loadVideoManifest(String configLink) async {
    print('> VimeoService -> loadVideoManifest: configLink = ${configLink}');
    String? url;
    try {
      final response = await dio.get(configLink).catchError((e) {
        print(e);
      });
      final config = response.data as Map<String, dynamic>;
      final request = config['request'] as Map<String, dynamic>;
      bool hasFiles = request.containsKey('files');
      if (hasFiles) {
        final files = request['files'] as Map<String, dynamic>;
        url = _extractStreamByType(files, VideoStreamType.HLS);
      }
    } catch (e) {}
    return url;
  }

  String? _extractStreamByType(Map<String, dynamic> files, String streamType) {
    String? url;
    bool hasStream = files.containsKey(streamType);
    if (hasStream) {
      final list = files[streamType]['cdns'] as Map<String, dynamic>;
      String? cdn = POSSIBLE_CDN.firstWhere((id) => list[id] != null, orElse: () => null);
      url = cdn != null ? list[cdn]['avc_url'] ?? list[cdn]['url'] : null;
    }
    return url;
  }
}
