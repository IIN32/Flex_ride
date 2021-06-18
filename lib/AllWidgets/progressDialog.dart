import 'package:flutter/material.dart';


class ProgressDialog extends StatelessWidget
{
  String message;
  ProgressDialog({this.message});

  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      backgroundColor: Colors.cyan,
      child: Container(
        margin: EdgeInsets.all(13.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0)
        ),
        child: Padding(
          padding: EdgeInsets.all(13.0),
          child: Row(
            children: [
              SizedBox(width: 4.0,),
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),),
              SizedBox(width: 26.0,),
              Text(
                message,
                style: TextStyle(color: Colors.black12, fontSize: 10.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}