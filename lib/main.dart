import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:watermarkertoimage/watermarker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'WaterMarkerToImage'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;

  selectImage() async {
    showCupertinoModalPopup(
      context: context, 
      builder: (BuildContext context){
        return CupertinoActionSheet(
          // title: Text('选择照片'),
          message: Text('通过以下选项获取照片'),
          cancelButton: CupertinoActionSheetAction(
            onPressed: (){
              Navigator.pop(context);
            }, 
            child: Text('取消')
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () async{
                Navigator.of(context).pop();
                _goToCamera('gallery');
              }, 
              child: Text('相册')
            ),
            CupertinoActionSheetAction(
              onPressed: () async{
                Navigator.of(context).pop();
                _goToCamera('camera');
              }, 
              child: Text('相机')
            )
          ],
        );
      }
    );
  }

  _goToCamera(line) async {
    if(line == 'camera'){
      if(await applyPermissionCamera()){
        File tempImage = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 50);
        if(tempImage != null){
          var temp = await imageAddWaterMark(tempImage.path,'水印文字');
          setState(() {
            _image = temp;
          });
        }
      }
    }else{
      if(await applyPermissionGallery()){
        File tempImage  = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);
        if(tempImage != null){
          var temp = await imageAddWaterMark(tempImage.path,'水印文字');
          setState(() {
            _image = temp;
          });
        }
      }
    }
  }

  //动态申请权限
  applyPermissionGallery() async {
    //只有当用户同时点选了拒绝开启权限和不再提醒后才会true
    Map<Permission, PermissionStatus> permissions = await [Permission.mediaLibrary].request();
    bool isSHow = await Permission.mediaLibrary.shouldShowRequestRationale;
    // 申请结果  权限检测
    PermissionStatus permission = await Permission.mediaLibrary.status;
    if (permission != PermissionStatus.granted) {
      //权限没允许
      //如果弹框不在出现了，那就跳转到设置页。
      //如果弹框还能出现，那就不用管了，申请权限就行了
      if (!isSHow) {
        Fluttertoast.showToast(
          msg: "请允媒体库权限，并重试！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
        );
        return false;
        // await PermissionHandler().openAppSettings();
      } else {
        await [Permission.mediaLibrary].request();
        //此时要在检测一遍，如果允许了就下载。
        //没允许就就提示。
        PermissionStatus pp = await Permission.mediaLibrary.status;
        if (pp == PermissionStatus.granted) {
          //去下载吧
          return true;
        } else {
          // 参数1：提示消息// 参数2：提示消息多久后自动隐藏// 参数3：位置
          Fluttertoast.showToast(
            msg: "请允媒体库权限，并重试！",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
          );
          return false;
        }
      }
    } else {
      //权限允许了，那就下载吧、
      return true;
    }
  }

  //动态申请权限
  applyPermissionCamera() async {
    //只有当用户同时点选了拒绝开启权限和不再提醒后才会true
    Map<Permission, PermissionStatus> permissions = await [Permission.camera].request();
    bool isSHow = await Permission.camera.shouldShowRequestRationale;
    // 申请结果  权限检测
    PermissionStatus permission = await Permission.camera.status;
    if (permission != PermissionStatus.granted) {
      //权限没允许
      //如果弹框不在出现了，那就跳转到设置页。
      //如果弹框还能出现，那就不用管了，申请权限就行了
      if (!isSHow) {
        Fluttertoast.showToast(
          msg: "请允相机权限，并重试！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
        );
        return false;
        // await PermissionHandler().openAppSettings();
      } else {
        await [Permission.camera].request();
        //此时要在检测一遍，如果允许了就下载。
        //没允许就就提示。
        PermissionStatus pp = await Permission.camera.status;
        if (pp == PermissionStatus.granted) {
          //去下载吧
          return true;
        } else {
          // 参数1：提示消息// 参数2：提示消息多久后自动隐藏// 参数3：位置
          Fluttertoast.showToast(
            msg: "请允相机权限，并重试！",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
          );
          return false;
        }
      }
    } else {
      //权限允许了，那就下载吧、
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: _image != null ? Image.file(
          _image,
        ) : Text(
          '请选择图片',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectImage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
