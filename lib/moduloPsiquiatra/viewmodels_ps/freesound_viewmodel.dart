import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../model_ps/freesound_model.dart';
import '../services_ps/freesound_service.dart';

class FreesoundViewModel extends ChangeNotifier {
  final FreesoundService _service = FreesoundService();
  final AudioPlayer audioPlayer = AudioPlayer();

  List<FreesoundSound> sounds = [];
  bool isLoading = false;
  int currentPage = 1;
  String currentQuery = '';
  String? currentlyPlayingUrl;

  Future<void> search(String query) async {
    currentQuery = query;
    currentPage = 1;
    sounds = [];
    await fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.searchSounds(
        query: currentQuery,
        page: currentPage,
      );
      sounds.addAll(response.results);
      currentPage++;
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlay(String url) async {
    if (currentlyPlayingUrl == url && audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      currentlyPlayingUrl = url;
      await audioPlayer.setUrl(url);
      audioPlayer.play();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
