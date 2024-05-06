import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:open_file/open_file.dart';
import "songs.dart";

class CameraScreenWidget extends StatefulWidget {
  const CameraScreenWidget({super.key, required this.camera});

  final CameraDescription camera;

  @override
  _CameraScreenWidgetState createState() => _CameraScreenWidgetState();
}

class _CameraScreenWidgetState extends State<CameraScreenWidget> {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  late CameraController _controller;

  late Future<void> _initializeControllerFuture;

  String? _text;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(widget.camera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: <Widget>[
          FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          Text('$_text'),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            final recognizedText = await _textRecognizer
                .processImage(InputImage.fromFilePath(image.path));

            debugPrint('recognized text: ${recognizedText.text}');

            setState(() {
              _text = recognizedText.text;
            });

            bool found = false;
            for (var current_song in pubsongs) {
              if (recognizedText.text.similarityTo(current_song.title) > 0.5) {
                found = true;
                OpenFile.open(current_song.pdf_link);
              }
            }
            if (found == false) _text = 'Could not find matching';

            if (!mounted) return;
          } catch (e) {
            debugPrint('Error during capture: ${e.toString()}');
          }
        },

        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
