import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

/// Entry point of the application.
void main() => runApp(MyApp());

/// Root widget of the application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

/// Home screen of the application.
///
/// This screen allows users to select an image and navigate to the ResultPage
/// to view the predictions made by the TensorFlow Lite model.
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// State for HomeScreen.
class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  List? _recognitions;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  /// Loads the TensorFlow Lite model.
  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: 'assets/efnmodel.tflite',
      // labels: 'assets/labels.txt', // Include if you have a labels file
    );
  }

  /// Opens image gallery to select an image.
  Future<void> _getImage() async {
    final image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  /// Predicts the content of the selected image using the TensorFlow Lite model.
  Future<void> _predictImage() async {
    if (_image == null) return;

    var recognitions = await Tflite.runModelOnImage(
      path: _image!.path,
      // Additional parameters can be provided here
    );

    setState(() {
      _recognitions = recognitions;
    });

    print(recognitions);
  }

  /// Navigates to the ResultPage to display predictions.
  void _navigateToResultPage() {
    if (_recognitions != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultPage(recognitions: _recognitions),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null ? Image.file(_image!) : Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _predictImage();
                _navigateToResultPage();
              },
              child: Text('Accept'),
            ),
            _recognitions != null
                ? Text('Predictions: $_recognitions')
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}

/// Result page to display the predictions.
///
/// This page shows the results of the image analysis performed by the TensorFlow Lite model.
class ResultPage extends StatelessWidget {
  final List? recognitions;

  /// Constructor for ResultPage.
  ///
  /// [recognitions] is a list of predictions made by the TensorFlow Lite model.
  ResultPage({this.recognitions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prediction Results'),
      ),
      body: Center(
        child: recognitions != null && recognitions!.isNotEmpty
            ? Text('Predictions: $recognitions')
            : Text('No predictions available.'),
      ),
    );
  }
}
