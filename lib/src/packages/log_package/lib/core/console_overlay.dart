import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'index.dart';

class ConsoleOverlay {
  static OverlayEntry? _entry;
  static bool isShow = false;

  static void show(BuildContext context) {
    if (!isShow) {
      _entry = OverlayEntry(builder: (_) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.only(top: 40),
            child: ConsoleOverlayWidget(),
          ),
        );
      });
      Overlay.of(context)?.insert(_entry!);
      isShow = true;
    }
  }

  static remove() {
    isShow = false;
    _entry?.remove();
  }
}

class ConsoleOverlayWidget extends StatefulWidget {
  ConsoleOverlayWidget({Key? key}) : super(key: key);

  @override
  _ConsoleOverlayWidgetState createState() => _ConsoleOverlayWidgetState();
}

class _ConsoleOverlayWidgetState extends State<ConsoleOverlayWidget> {
  ValueNotifier<FilterMenu> _menuValue = ValueNotifier(FilterMenu(10, true));

  static const double _logHeigh = 210;
  final SizedBox _divider = const SizedBox(
    height: 1,
    width: 80,
    child: Divider(
      color: Colors.black26,
    ),
  );

  late ScrollController _controller;

  late TextEditingController _textController;
  static const int _levelDefault = -1;

  String _filterStr = "";

  int _logLevel = _levelDefault;

  int _logStyle = 0;

  bool _isLarge = false;

  String _levelName = "all";

  double _marginTop = 0;
  double _marginStart = 0;

  final double _mangerSize = 100;

  final GlobalKey _globalKey = GlobalKey();
  final GlobalKey _globalForDrag = GlobalKey();
  bool isSmallBall = true;
  double _ballSize = 60;
  double _currendDy = 0;
  double _currendDx = 0;

  @override
  void initState() {
    _controller = ScrollController();
    _textController = TextEditingController();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      RenderBox renderObject = _globalKey.currentContext?.findRenderObject() as RenderBox;
      _currendDy = renderObject.localToGlobal(Offset.zero).dy;
      _currendDx = renderObject.localToGlobal(Offset.zero).dx;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: _buildDraggable());
  }

  Widget _buildDraggable() {
    return LayoutBuilder(builder: (context, constraints) {
      if (_marginTop <= 0) {
        _marginTop = 0;
      }
      if (_marginStart <= 0) {
        _marginStart = 0;
      }
      return Stack(
        children: [
          Positioned(
            top: _marginTop,
            left: _marginStart,
            child: Container(
              key: _globalKey,
              child: Draggable(
                // axis: Axis.vertical,
                child: _buildDragView(constraints),
                // _isLarge 的状态下，不准拖动
                feedback: _isLarge ? Container() : _buildDragView(constraints),
                childWhenDragging: _isLarge ? _buildDragView(constraints) : Container(),
                onDragEnd: (DraggableDetails details) {
                  _calculatePosition(details, constraints);
                },
              ),
            ),
          )
        ],
      );
    });
  }

  /// 计算位置
  void _calculatePosition(DraggableDetails details, BoxConstraints constraints) {
    if (!_isLarge) {
      if (mounted) {
        setState(() {
          _closeKeyBoard();
          double offY = 0;
          double offX = 0;
          if ((details.offset.dy - _currendDy) < 0) {
            offY = 0;
          } else {
            offY = details.offset.dy - _currendDy;
          }
          if ((details.offset.dx - _currendDx) < 0) {
            offX = 0;
          } else {
            double screenHalfWidth = constraints.maxWidth / 2;
            if (details.offset.dx > screenHalfWidth) {
              offX = constraints.maxWidth - _ballSize;
            } else {
              offX = 0;
            }
          }
          print(details.offset.dx);
          print('max width ${constraints.maxWidth}');
          _marginTop = offY;
          _marginStart = offX;
        });
      }
    }
  }

  Widget _buildDragView(BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.all(isSmallBall ? 0 : 8),
      width: isSmallBall ? null : constraints.maxWidth,
      key: _globalForDrag,
      height: isSmallBall
          ? null
          : _isLarge
              ? constraints.maxHeight + _mangerSize
              : _logHeigh + _mangerSize,
      child: Material(
        color: Colors.transparent,
        // backgroundColor: Colors.transparent,
        // resizeToAvoidBottomInset: false,
        child: isSmallBall
            ? _buildSmallCircul()
            : Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        height: _isLarge ? constraints.maxHeight - 70 : _logHeigh,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        width: constraints.maxWidth,
                        child: ValueListenableBuilder<LogModeValue>(
                          valueListenable: Logger.notifier,
                          builder: (_, model, child) {
                            return _buildLogWidget(model);
                          },
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        // height: _mangerSize,
                        width: constraints.maxWidth,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _clearLog,
                              icon: const Icon(Icons.clear),
                            ),
                            IconButton(
                              onPressed: _changeStyle,
                              icon: const Icon(Icons.style),
                            ),
                            IconButton(
                              onPressed: () {
                                _menuValue.value.isVisible = false;
                                _menuValue.notifyListeners();
                              },
                              icon: const Icon(Icons.print),
                            ),
                            Text(
                              _levelName,
                              style: TextStyle(color: ConsoleUtil.getLevelColor(_logLevel)),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: _buildTextFiled(),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isSmallBall = true;
                                });
                              },
                              icon: Icon(Icons.adb),
                            ),
                            IconButton(
                              onPressed: _changeSize,
                              icon: Icon(_isLarge ? Icons.crop : Icons.aspect_ratio_outlined),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _logMenuWidget(),
                ],
              ),
      ),
    );
  }

  Widget _buildSmallCircul() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          // width: _ballSize,
          // height: _ballSize,
          child: Container(
            child: IconButton(
              iconSize: 25,
              color: Colors.transparent,
              onPressed: () {
                _closeKeyBoard();
                setState(() {
                  isSmallBall = false;
                  _marginStart = 0;
                });
              },
              icon: Icon(
                Icons.adb,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.6),
            borderRadius: BorderRadius.circular(60),
          ),
        ),
      ],
    );
  }

  Widget _buildLogWidget(LogModeValue model) {
    List<LogMode> modeList = model.logModeList;
    List<LogMode> fiterList = [];
    for (int i = modeList.length - 1; i >= 0; i--) {
      LogMode logMode = modeList[i];
      if ((_logLevel == logMode.level || _logLevel == _levelDefault) && logMode.logMessage != null && logMode.logMessage!.contains(_filterStr)) {
        fiterList.add(logMode);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 2500,
        child: ListView.builder(
          controller: _controller,
          reverse: true,
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            LogMode logMode = fiterList[index];

            return _buildTextWidget(logMode);
            // return Text(log, style: _logStyle);
          },
          itemCount: fiterList.length,
        ),
      ),
    );
  }

  Widget _buildTextWidget(LogMode logMode) {
    return LogText(
      logMode: logMode,
      logStyle: _logStyle,
    );
  }

  void _clearLog() {
    _closeKeyBoard();
    Logger.notifier.value = LogModeValue();
  }

  /// 设置log样式，是否显示时间，是否显示文件名
  void _changeStyle() {
    if (mounted) {
      setState(() {
        _logStyle++;
      });
    }
  }

  final List<String> _logLevelFilter = ["all", "verbose", "debug", "info", "warn", "error"];

  Widget _logMenuWidget() {
    return ValueListenableBuilder<FilterMenu>(
        valueListenable: _menuValue,
        builder: (_, model, child) {
          return Positioned(
              left: 80,
              bottom: _isLarge ? 80 : 0,
              child: Offstage(
                offstage: model.isVisible,
                child: Card(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  elevation: 10,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _logLevelFilter.map((value) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 30,
                            child: MaterialButton(
                              onPressed: () {
                                filterLog(value);
                              },
                              child: Text(
                                value,
                                style: TextStyle(color: _levelName == value ? Colors.blue : Colors.black87, fontSize: 15, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          Offstage(child: _divider, offstage: value.contains("取消")),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ));
        });
  }

  /// 过滤log
  void filterLog(String buttonValue) {
    if (buttonValue != "取消") {
      if (mounted) {
        _closeKeyBoard();
        setState(() {
          switch (buttonValue) {
            case "all":
              _logLevel = _levelDefault;
              break;
            case "verbose":
              _logLevel = LoggerPrinter.verbose;
              break;
            case "debug":
              _logLevel = LoggerPrinter.debug;
              break;
            case "info":
              _logLevel = LoggerPrinter.info;
              break;
            case "warn":
              _logLevel = LoggerPrinter.warn;
              break;
            case "error":
              _logLevel = LoggerPrinter.error;
              break;
          }
          _levelName = buttonValue;
        });
      }
    }

    _menuValue.value.isVisible = true;
    _menuValue.notifyListeners();
  }

  /// 更改大小
  void _changeSize() {
    if (mounted) {
      setState(() {
        _closeKeyBoard();
        _isLarge = !_isLarge;
        // 如果是 大 的情况，直接让 top 设置为 0；
        if (_isLarge) {
          _marginTop = 0;
          _marginStart = 0;
        }
      });
    }
  }

  Widget _buildTextFiled() {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        autofocus: false,
        controller: _textController,
        onChanged: (value) {
          _filterText(value);
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "Search",
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _textController.clear();
              _filterText("");
            },
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  /// 过滤log
  void _filterText(String value) {
    setState(() {
      _filterStr = value;
    });
  }

  void _closeKeyBoard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
