import 'dart:async';

class StreamManager {
  static Map<String, List<StreamController>> streamData = {};

  static Stream getStream(String name) {
    StreamController stream = StreamController<String>();
    streamData[name] = [stream];
    return stream.stream;
  }

  static Stream getCommonStream(String name) {
    StreamController stream = StreamController<String>();
    final streamList = streamData[name];
    if (streamList != null) {
      streamList.add(stream);
    } else {
      streamData[name] = [stream];
    }
    return stream.stream;
  }

  static void addDataToStreamSink(String name, String data) {
    List<StreamController> streamList = streamData[name] ?? [];
    for (final streamController in streamList) {
      streamController.sink.add(data);
    }
  }

  static void removeStream(Stream stream, String name) {
    List<StreamController> streamList = streamData[name] ?? [];
    streamList.removeWhere((streamController) => streamController.stream == stream);
  }
}