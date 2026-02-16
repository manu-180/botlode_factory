import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';

import '../../../../core/services/video_preloader_service.dart';

final Set<String> _registeredViews = {};

void registerVideoElementWeb(String viewId, String videoPath, void Function() onError) {
  if (_registeredViews.contains(viewId)) return;
  _registeredViews.add(viewId);

  VideoPreloaderService().registerErrorCallback(viewId, onError);

  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int id) {
      final videoElement = VideoPreloaderService().getVideo(videoPath);

      videoElement.onCanPlay.listen((_) {
        videoElement.play();
      });

      videoElement.onLoadedData.listen((_) {
        videoElement.play();
      });

      videoElement.onError.listen((error) {
        debugPrint('Error playing video $videoPath: $error');
        VideoPreloaderService().notifyVideoError(viewId);
      });

      if (videoElement.readyState >= 3) {
        videoElement.play();
      }

      return videoElement;
    },
  );
}
