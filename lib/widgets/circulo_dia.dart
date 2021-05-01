import 'package:flutter/material.dart';

Widget circuloDia(day, context, selected) {
  return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
          color: (selected != 0)
              ? Theme.of(context).accentColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100.0)),
      child: Padding(
        padding: EdgeInsets.all(6.0),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: Colors.black,
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ));
}
