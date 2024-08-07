import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {

  late CameraController cameraController;
  late List<CameraDescription> cameras;

  RxBool isCameraInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  void initCamera() async {
    if(await Permission.camera.request().isGranted){
      cameras = await availableCameras();
      cameraController = CameraController(cameras.first, ResolutionPreset.max);
      await cameraController.initialize();
      isCameraInitialized(true);
      update();
    } else {
      print("Permission denied");
    }
  }
}