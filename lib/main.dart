import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_days/components/button_centered_column.dart';
import 'package:video_days/services/vimeo_service.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Days',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VideoDays(title: 'Flutter Demo Home Page'),
    );
  }
}

const LINKS = [
  'https://player.vimeo.com/video/125523559',
  'https://player.vimeo.com/video/148470865',
  'https://player.vimeo.com/video/187883952',
  'https://player.vimeo.com/video/240412853',
  'https://player.vimeo.com/video/215167466'
];

class VideoDays extends StatefulWidget {
  const VideoDays({super.key, required this.title});
  final String title;

  @override
  State<VideoDays> createState() => _VideoDaysState();
}

class _VideoDaysState extends State<VideoDays> {
  VideoPlayerController? _controller;
  final VimeoService _vimeoService = VimeoService();
  int _currentVideoIndex = 0;

  StreamController<bool> isPlayerReady = StreamController.broadcast();

  void _onFocusChange() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  bool get isEnded =>
      (_controller?.value.isInitialized ?? false) &&
      _controller!.value.duration.inSeconds > 0 &&
      !_controller!.value.isPlaying &&
      _controller!.value.position.inSeconds == _controller!.value.duration.inSeconds;

  @override
  void initState() {
    super.initState();
    nextVideo();
  }

  Future<void> nextVideo() async {
    isPlayerReady.add(false);
    if (_controller != null) {
      _controller!.removeListener(_onVideoProgress);
      await _controller!.pause();
      await _controller!.dispose();
      _controller = null;
    }
    final videoUrl = LINKS[_currentVideoIndex++ % LINKS.length];
    final manifestUrl = await _vimeoService.loadVideoManifest('$videoUrl/config');
    print('> nextVideo -> manifestUrl: $manifestUrl');
    if (manifestUrl != null) {
      _initVideoController(manifestUrl).then((_) {
        isPlayerReady.add(true);
      });
    } else {
      nextVideo();
    }
  }

  Future<void> _initVideoController(String resourceLink) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(resourceLink),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ))
      ..addListener(_onVideoProgress)
      ..setLooping(false)
      ..initialize().then((_) => setState(() {
            _onFocusChange();
          }))
      ..play();
  }

  void _onVideoProgress() {
    if (isEnded ||
        _controller?.value.position.inSeconds == 10 ||
        _controller?.value.hasError == true) nextVideo();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Focus(
        autofocus: true,
        focusNode: FocusNode(),
        child: StreamBuilder<bool>(
          initialData: false,
          stream: isPlayerReady.stream,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!(snapshot.data ?? false)) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            return Stack(
              alignment: AlignmentDirectional.center,
              children: [
                AspectRatio(
                  key: ValueKey(_controller!.dataSource),
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
                ButtonCenteredColumn(text: 'Next', onPressed: () => nextVideo())
              ],
            );
          },
        ),
      ),
    );
  }
}
