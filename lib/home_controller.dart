import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController extends GetxController {
  late CameraController cameraController;
  final RxBool isCameraInitialized = false.obs;

  late List<CameraDescription> _cameras;
  int _cameraImagesCount = 0;

  double x = 0.0;
  double y = 0.0;
  double w = 0.0;
  double h = 0.0;
  String label = '';

  @override
  void onInit() {
    super.onInit();
    _initCamera();
    _initTFLite();
  }

  void _initCamera() async {
    // TODO 5: initialize camera by getting available cameras and initiating the controller with the first one (the back one)
    if (await Permission.camera.request().isGranted) {
      _cameras = await availableCameras();
      cameraController = CameraController(_cameras.first, ResolutionPreset.max);
      // TODO 6: after initialization, call detectObject every 10 frames.. this is to avoid detection on every frame which will slow down the app.
      // the bigger the number, the slower the detection
      // you can increase or decrease the number according to needed detection speed and performance requirements
      await cameraController.initialize().then((_) {
        cameraController.startImageStream((image) {
          _cameraImagesCount++;
          if (_cameraImagesCount % 10 == 0) {
            _cameraImagesCount = 0;
            _detectObject(image);
            // this is to show the detected object box
            update();
          }
        });
      });
      // TODO 7: give isCameraInitialized a value of true to reflect on the view and show the camera view after updating
      isCameraInitialized(true);
      // this is to show the camera view after it's been initialized
      update();
    } else {
      print("Permission denied");
    }
  }

  // TODO 8: initiate tflite with model and labels files in assets
  _initTFLite() async {
    await Tflite.loadModel(model: 'assets/model.tflite', labels: 'assets/labels.txt', isAsset: true, numThreads: 1, useGpuDelegate: false);
  }

  Future<void> _detectObject(CameraImage image) async {
    // TODO 9: record the recognitions detected on a frame by converting the frame into planes, which makes the model able to identify the objects
    List<dynamic>? recognitions = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      numResultsPerClass: 1,
      threshold: 0.45,
    );
    // TODO 10: extract the label and the coordinates of the detected object if the model recognized something, or else reset them
    if (recognitions!.isNotEmpty) {
      dynamic detectedObject = recognitions.first;
      label = detectedObject['detectedClass'].toString();
      h = detectedObject['rect']['h'];
      w = detectedObject['rect']['w'];
      x = detectedObject['rect']['x'];
      y = detectedObject['rect']['y'];
    } else {
      _resetResults();
    }
  }

  void _resetResults() {
    label = '';
    h = 0.0;
    w = 0.0;
    x = 0.0;
    y = 0.0;
    update();
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
