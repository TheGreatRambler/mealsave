import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/material.dart';

Future openNumberDialog(BuildContext context, int minValue, int maxValue, double initialValue, Widget title) async {
  return showDialog<double>(
    context: context,
    builder: (BuildContext context) {
      double currentValue = initialValue;
      return StatefulBuilder(builder: (context, setState) {
        return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, currentValue);
              return false;
            },
            child: SimpleDialog(
              title: title,
              children: <Widget>[
                DecimalNumberPicker(
                  minValue: minValue,
                  maxValue: maxValue,
                  decimalPlaces: 2,
                  value: currentValue,
                  onChanged: (value) => setState(() {
                    currentValue = value;
                  }),
                ),
                Row(children: [
                  SimpleDialogOption(
                    onPressed: () {
                      setState(() {
                        currentValue = initialValue;
                      });
                    },
                    child: const Text("Reset"),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      setState(() {
                        currentValue = 0;
                      });
                    },
                    child: const Text("Zero"),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, currentValue);
                    },
                    child: const Text("Close"),
                  ),
                ]),
              ],
            ));
      });
    },
  );
}

Future openIntDialog(BuildContext context, int minValue, int maxValue, int initialValue, Widget title) async {
  return showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      int currentValue = initialValue;
      return StatefulBuilder(builder: (context, setState) {
        return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, currentValue);
              return false;
            },
            child: SimpleDialog(
              title: title,
              children: <Widget>[
                NumberPicker(
                  minValue: minValue,
                  maxValue: maxValue,
                  value: currentValue,
                  onChanged: (value) => setState(() {
                    currentValue = value;
                  }),
                ),
                Row(children: [
                  SimpleDialogOption(
                    onPressed: () {
                      setState(() {
                        currentValue = initialValue;
                      });
                    },
                    child: const Text("Reset"),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      setState(() {
                        currentValue = 0;
                      });
                    },
                    child: const Text("Zero"),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, currentValue);
                    },
                    child: const Text("Close"),
                  ),
                ]),
              ],
            ));
      });
    },
  );
}
