import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

//拿到图片的字节数组
  Future<ui.Image> loadImageByFile(String path) async {
    var list = await File(path).readAsBytes();
    return loadImageByUint8List(list);
  }

  //通过[Uint8List]获取图片
  Future<ui.Image> loadImageByUint8List(Uint8List list) async {
    ui.Codec codec = await ui.instantiateImageCodec(list);
    ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  //图片加文字
  imageAddWaterMark(String imagePath,String textStr) async {
    int width, height;

    //拿到Canvas
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    Canvas canvas = new Canvas(recorder);

    //拿到Image对象
    ui.Image image = await loadImageByFile(imagePath);
    width = image.width;
    height = image.height;
    // 计算四边形的对角线长度
    double dimension =
        math.sqrt(math.pow(image.width, 2) + math.pow(image.height, 2));
    canvas.drawImage(image, Offset(0, 0), Paint());
    canvas.saveLayer(Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Paint()..blendMode = BlendMode.multiply);
    var text = textStr;
    // 完整覆盖下的正方形面积
    double rectSize = math.pow(dimension, 2);
    // 根据面积与字符大小计算文本重复次数
    int textRepeating =
        ((rectSize / math.pow(30, 2) * 2) / (text.length + 8))
            .round(); // text.length + padding 是因为要添加个空格字符

    math.Point pivotPoint = math.Point(dimension / 2, dimension / 2);
    canvas.translate(pivotPoint.x, pivotPoint.y);
    canvas.rotate(-25 * math.pi / 180);
    canvas.translate(
        -pivotPoint.distanceTo(math.Point(0, image.height)),
        -pivotPoint.distanceTo(math.Point(0, 0))); // 计算文本区域起始坐标分别到图片左侧顶部与底部的距离，作为文本区域移动的距离。
    var textPainter = TextPainter(
      text: TextSpan(
          text: (text.padRight(text.length + 8)) * textRepeating,
          style: TextStyle(
            fontSize: 30,
            color: Color.fromRGBO(0, 0, 0, .3),
            height: 2
          )),
      maxLines: null,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.start,
    );
    textPainter.layout(maxWidth: dimension);
    textPainter.paint(canvas, Offset.zero);

    canvas.restore();

    ui.Picture picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());

    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    final Directory _directory = await getTemporaryDirectory();
    final Directory _imageDirectory =
    await new Directory('${_directory.path}/image/').create(recursive: true);
    String _targetPath = _imageDirectory.path;

    File file = File(
        '${_targetPath}watermark${DateTime.now().millisecondsSinceEpoch}.png');
    print(file.path);
    file.writeAsBytesSync(pngBytes.buffer.asInt8List());

    return file;
  }