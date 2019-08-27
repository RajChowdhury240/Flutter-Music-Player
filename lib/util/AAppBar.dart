import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AAppBar extends StatelessWidget implements PreferredSizeWidget {
  AAppBar({this.title, this.isBack = false});
  final String title;
  final bool isBack;
  @override
  Size get preferredSize => Size.fromHeight(110.0);

  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          Colors.blueGrey.shade500,
          Colors.blueGrey.shade400,
          Colors.blueGrey.shade300,
          Colors.blueGrey.shade200,
          Colors.blueGrey.shade100,
          Colors.blueGrey.shade50,
          Colors.grey.shade100,
          Colors.grey.shade50,
          Color(0xFFFAFAFA)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.clamp,
      )),
      height: preferredSize.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).padding.top,
          ),
          Padding(
            padding: EdgeInsets.only(top: 25.0, left: isBack ? 0.0 : 20.0),
            child: Row(
              children: <Widget>[
                Container(
                    child: isBack
                        ? IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              size: 35.0,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            })
                        : Container()),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 42.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
