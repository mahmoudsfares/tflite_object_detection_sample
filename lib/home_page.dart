import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tflite_object_detection_sample/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return controller.isCameraInitialized.value
              ? Stack(
                  children: [
                    // TODO 11: show the camera preview and -if detected- the box surrounding the detected object
                    // numbers in the positioned widgets are declared by trial and error and are not that accurate
                    CameraPreview(controller.cameraController),
                    Positioned(
                      top: controller.y * 700,
                      right: controller.x * 500,
                      child: Container(
                        width: controller.w * 100 * context.width / 100,
                        height: controller.h * 100 * context.height / 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 4.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              color: Colors.green,
                              child: Text(controller.label),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )
              : const Center(child: Text('Loading preview...'));
        },
      ),
    );
  }
}
