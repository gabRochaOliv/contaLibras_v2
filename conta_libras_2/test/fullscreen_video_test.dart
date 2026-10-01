import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:conta_libras_2/data/mock/mock_dictionary_repository.dart';
import 'package:conta_libras_2/ui/screens/dictionary/term_detail_screen.dart';

/// Player falso que imita o comportamento do navegador: quando o <video> é
/// tirado do DOM (troca de rota), a mídia é pausada sem ninguém pedir.
class _FakeVideoPlatform extends VideoPlayerPlatform {
  final _events = StreamController<VideoEvent>.broadcast();
  bool playing = false;
  bool looping = false;

  /// Pausa vinda "de fora" do app (navegador ou usuário na aba).
  void simulateBrowserPause() {
    playing = false;
    _events.add(VideoEvent(
      eventType: VideoEventType.isPlayingStateUpdate,
      isPlaying: false,
    ));
  }

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    // Atraso: o controller só começa a ouvir depois que create() retorna.
    Future.delayed(
        const Duration(milliseconds: 10),
        () => _events.add(VideoEvent(
              eventType: VideoEventType.initialized,
              duration: const Duration(seconds: 5),
              size: const Size(480, 848),
            )));
    return 1;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) => _events.stream;

  @override
  Future<void> play(int textureId) async => playing = true;

  @override
  Future<void> pause(int textureId) async => playing = false;

  @override
  Future<void> setLooping(int textureId, bool looping) async =>
      this.looping = looping;

  @override
  Future<void> setVolume(int textureId, double volume) async {}

  @override
  Future<void> seekTo(int textureId, Duration position) async {}

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {}

  @override
  Future<Duration> getPosition(int textureId) async => Duration.zero;

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Future<void> dispose(int textureId) async {}

  @override
  Widget buildView(int textureId) => const ColoredBox(color: Colors.grey);
}

Future<_FakeVideoPlatform> _openFullScreen(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final fake = _FakeVideoPlatform();
  VideoPlayerPlatform.instance = fake;

  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final term =
      MockDictionaryRepository.terms.firstWhere((t) => t.videoUrl.isNotEmpty);
  await tester.pumpWidget(MaterialApp(home: TermDetailScreen(term: term)));
  // O player atualiza a posição num timer contínuo enquanto toca, então
  // pumpAndSettle nunca terminaria; avança o relógio em passos fixos.
  await _advance(tester, 1000);

  // Vídeo pausado na aba (como se o usuário tivesse tocado nele) antes de
  // abrir a tela cheia — era o caso em que a tela cheia abria parada.
  fake.simulateBrowserPause();
  await _advance(tester, 300);
  expect(fake.playing, isFalse, reason: 'pré-condição: vídeo pausado na aba');

  await tester.tap(find.byTooltip('Tela cheia'));
  await _advance(tester, 250);
  // No meio da transição o navegador pausa a mídia.
  fake.simulateBrowserPause();
  await _advance(tester, 1500);
  return fake;
}

/// Toca no vídeo da tela cheia, que fica centralizado na tela.
Future<void> _tapVideo(WidgetTester tester) async {
  await tester.tapAt(tester.view.physicalSize.center(Offset.zero));
}

Future<void> _advance(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('tela cheia abre tocando em loop, mesmo após pausa do navegador',
      (tester) async {
    final fake = await _openFullScreen(tester);

    expect(fake.playing, isTrue);
    expect(fake.looping, isTrue);
  });

  testWidgets('pausa feita pelo usuário na tela cheia é respeitada',
      (tester) async {
    final fake = await _openFullScreen(tester);
    expect(fake.playing, isTrue);

    await _tapVideo(tester);
    await _advance(tester, 1000);

    expect(fake.playing, isFalse);
  });
}
