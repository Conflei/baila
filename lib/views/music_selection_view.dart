import 'package:baila/views/local_video_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'camera_dance_view.dart';

class MusicSelectionView extends StatefulWidget {
  const MusicSelectionView({super.key});

  @override
  State<MusicSelectionView> createState() => _MusicSelectionViewState();
}

class _MusicSelectionViewState extends State<MusicSelectionView> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: w,
        height: h,
        color: Colors.black87,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CameraDanceView(song: "DnB")),
                );
              },
              child: Container(
                width: 320.w,
                height: 100.h,
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade800,
                    borderRadius: BorderRadius.circular(20.w)),
                child: Center(
                    child: Text(
                  "DnB",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
