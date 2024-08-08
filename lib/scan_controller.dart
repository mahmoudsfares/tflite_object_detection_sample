import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  RxBool isCameraInitialized = false.obs;
  int cameraCount = 0;

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFlite();
  }

  void initCamera() async {
    if(await Permission.camera.request().isGranted){
      cameras = await availableCameras();
      cameraController = CameraController(cameras.first, ResolutionPreset.max);
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if(cameraCount % 10 == 0){
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

  initTFlite() async {
    await Tflite.loadModel(model: 'assets/model.tflite', labels: 'assets/labels.txt', isAsset: true, numThreads: 1, useGpuDelegate: false);
  }

  Future<void> objectDetector(CameraImage image) async {
    List<dynamic>? detector =  await Tflite.runModelOnFrame(bytesList: image.planes.map((e) {
      return e.bytes;
    }).toList(),
    asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      rotation: 90,
      threshold: 0.4,
    );
    if(detector != null){
      log('Result is $detector');
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}