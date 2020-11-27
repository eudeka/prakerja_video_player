import 'package:flutter/material.dart';

import '../config/constant.dart';
import '../network/api_client.dart';

class WidgetReport extends StatefulWidget {
  @override
  _WidgetReportState createState() => _WidgetReportState();
}

class _WidgetReportState extends State<WidgetReport> {
  bool _loading = false;
  String _message = '';

  void _sendReport() async {
    setState(() => _loading = true);
    await ApiClient.sendReport(_message);
    setState(() => _loading = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bug Report (version ${Constant.version})'),
      content: TextField(
        decoration: InputDecoration(
          labelText: 'message',
          helperText: 'minimum length 20',
          border: OutlineInputBorder(),
        ),
        maxLines: null,
        onChanged: (String text) => setState(() => _message = text),
      ),
      actions: <Widget>[
        OutlineButton.icon(
          onPressed: _message.length > 20 && !_loading ? _sendReport : null,
          icon: Icon(_loading ? Icons.clear : Icons.send),
          label: Text(_loading ? 'SENDING...' : 'SEND'),
        )
      ],
    );
  }
}
