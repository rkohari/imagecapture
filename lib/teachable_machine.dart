import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:teachablemachine/main.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf;
import 'package:tflite/tflite.dart';

class TeachableMachine extends StatefulWidget {
  const TeachableMachine({Key? key}) : super(key: key);

  @override
  _TeachableMachineState createState() => _TeachableMachineState();
}

class _TeachableMachineState extends State<TeachableMachine> {
  late CameraController controller;
  late CameraImage cameraImage;
  late String  ? output  ="";


  bool isDetecting = false;

  @override
  Widget build(BuildContext context) {
    if ( !controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(),
        body: const Text(
          'Loading',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: 500,
            height: 500,
            child: CameraPreview(controller),
          ),
       Text("output  $output  1ß"),
          FlatButton(onPressed: (){
            controller!.startImageStream((imageStream) {
              cameraImage = imageStream;
              runModel();
            });
          }, child:Text("Start stream")),
        ],
      ),
    );
  }

  @override
  void initState() {
    loadModule();
    loadCamera();

  }

  loadCamera() async {
    controller = CameraController(listOfCameras![0], ResolutionPreset.ultraHigh);
    controller.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {

      });

    });
  }

  runModel() async {
    if (cameraImage != null) {

      var preditions = await Tflite.runModelOnFrame(
          bytesList: cameraImage.planes.map((e) => e.bytes).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
        rotation: 90,
        threshold: 0.1,
        numResults: 2,
        asynch: true,

      );
      preditions!.forEach((element) {
        setState(() {
          print("hellow world");
          print(element.toString());
          output =element["lables"];
        });



      });
    }
  }

  loadModule()
  async{

   await  Tflite.loadModel(model: "assets/ml/model_unquant.tflite",labels:"assets/ml/labels.txt" );
  }


}
