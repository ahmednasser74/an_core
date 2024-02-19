import 'package:flutter/material.dart';
import 'index.dart';

class LogText extends StatefulWidget {
  const LogText({
    required this.logMode,
    Key? key,
    this.logStyle = 0,
  }) : super(key: key);

  final LogMode logMode;
  static const int _logAll = 0;
  static const int _logOnlyFile = 1;
  static const int _logOnlyTime = 2;
  final int logStyle;

  @override
  State<LogText> createState() => _LogTextState();
}

class _LogTextState extends State<LogText> {
  bool showFirstLine = true;

  @override
  Widget build(BuildContext context) {
    Color color = ConsoleUtil.getLevelColor(widget.logMode.level);
    TextStyle _logStyle = TextStyle(
      color: color,
      fontSize: 15,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.w400,
    );
    String log = _getLog(widget.logMode);
    if (showFirstLine) {
      List<String> list = log.split('\n');

      log = log.split('\n').first + ' ${list.length > 1 ? '...' : ''}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border.all(
        color: color,
        width: 1,
      )),
      child: SelectableText(
        '${widget.logMode.time}\n\n' + log,
        style: _logStyle,
        onTap: _handleTextClick,
      ),
    );
  }

  void _handleTextClick() {
    setState(() {
      showFirstLine = !showFirstLine;
    });
  }

  String _getLog(LogMode logMode) {
    String log = logMode.originalMessage ?? "";
    switch (widget.logStyle % 3) {
      case LogText._logAll:
        log = logMode.originalMessage ?? "";
        break;
      case LogText._logOnlyFile:
        log = log.replaceAll(logMode.fileName ?? "", "");
        break;
      case LogText._logOnlyTime:
        log = log.replaceAll(logMode.time ?? "", "");
        break;
    }

    // print(log);
    return log;
  }
}
