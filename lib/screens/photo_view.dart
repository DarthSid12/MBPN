import 'package:caller_app/variables/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view.dart';

import '../providers/callProvider.dart';

class PhotoViewPage extends StatefulWidget {
  final String number;
  final String image;
  const PhotoViewPage({Key? key, required this.number, required this.image})
      : super(key: key);

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightGrey,
        title: Text("Photo by ${CallProvider.formatNumber(widget.number)}",
            style: TextStyle(
              fontSize: 22,
              color: AppColors.white,
            )),
      ),
      body: PhotoView(
        imageProvider: NetworkImage(widget.image),
        loadingBuilder: (context, chunkEvent) {
          return Expanded(
            child: Center(
              child: SpinKitChasingDots(
                color: AppColors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
