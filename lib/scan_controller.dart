import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;

  RxBool isCameraInitialized = false.obs;
  int cameraCount = 0;

  double x = 0.0;
  double y = 0.0;
  double w = 0.0;
  double h = 0.0;

  String label = '';

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFLite();
  }

  void initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras.first, ResolutionPreset.max);
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            objectDetector(image);
          }
          update();
        });
      });
      isCameraInitialized(true);
      update();
    } else {
      print("Permission denied");
    }
  }

  initTFLite() async {
    await Tflite.loadModel(model: 'assets/model.tflite', labels: 'assets/labels.txt', isAsset: true, numThreads: 1, useGpuDelegate: false);
  }

  Future<void> objectDetector(CameraImage image) async {
    var recognitions = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      model: "SSDMobileNet",
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90,
      numResultsPerClass: 1,
      threshold: 0.4,
      asynch: true,
    );
    if (recognitions!.isNotEmpty) {
      dynamic detectedObject = recognitions.first;
      if (detectedObject['confidenceInClass'] * 100 > 45) {
        label = detectedObject['detectedClass'].toString();
        h = detectedObject['rect']['h'];
        w = detectedObject['rect']['w'];
        x = detectedObject['rect']['x'];
        y = detectedObject['rect']['y'];
        update();
      }
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
