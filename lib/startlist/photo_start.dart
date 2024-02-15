// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photomatrix/DataBase/database.dart';
import 'package:photomatrix/startlist/photo_next.dart';
import 'package:photomatrix/theme/app_theme.dart';

var now = DateTime.now();
var dateFormat = DateFormat('dd.MM.yyyy');
String formattedDate = dateFormat.format(now);

class PhotoStart extends StatefulWidget {
  final String? filename;

  const PhotoStart({Key? key, this.filename}) : super(key: key);

  @override
  _PhotoStartState createState() => _PhotoStartState();
}

class _PhotoStartState extends State<PhotoStart> {
  FlutterSoundRecorder? _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String buttonText = 'запись не идёт';
  Color buttonColor = Colors.grey;
  DatabaseHelper dbHelper = DatabaseHelperImpl();

  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    initRecorder();
    initializeDatabase();
  }

  void initializeDatabase() async {
    await dbHelper.initDatabasePath(); // Установка пути к базе данных
    await dbHelper.initDatabase(); // Инициализация базы данных
    // После инициализации базы данных вы можете использовать dbHelper для других операций с базой данных
  }

  Future<void> initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Разрешение на использование микрофона не предоставлено';
    }
    await _recorder?.openAudioSession();
    _recorder?.setSubscriptionDuration(const Duration(milliseconds: 50));
  }

  void _toggleRecording() async {
    try {
      if (_recorder?.isRecording ?? false) {
        String? result = await _recorder?.stopRecorder();
        if (result != null) {
          print('Файл сохранен по пути: $result');
          await saveMusicFile(
              '${startTime.hour}_${startTime.minute}${widget.filename}',
              File(result).readAsBytesSync());
        }
        setState(() {
          isRecording = false;
          buttonText = 'Запись закончена';
          buttonColor = Colors.green;
        });
        // ignore: use_build_context_synchronously
        dbHelper.showNumberInput(context);
      } else {
        if (await Permission.storage.request().isDenied) {
          return;
        }
        Directory? appDocDir = await getExternalStorageDirectory();
        startTime = DateTime.now();
        String filePath = '${appDocDir?.path}/${widget.filename}';
        await _recorder?.startRecorder(toFile: filePath);
        print('Запись началась и сохраняется в: $filePath');

        setState(() {
          isRecording = true;
          buttonText = 'запись идёт';
          buttonColor = Colors.red;
        });
      }
    } catch (e) {
      print('Ошибка при начале/остановке записи: $e');
    }
  }

  Future<void> saveMusicFile(String fileName, List<int> musicData) async {
    startTime = DateTime.now();
    String namephoto = widget.filename ?? '';

    Dio dio = Dio();
    Directory storageDir = Directory(
        '/storage/emulated/0/Music/photomatrix/${formattedDate}_${widget.filename}/start');
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    String filePath = '${storageDir.path}/$fileName.mp3';
    File file = File(filePath);
    await file.writeAsBytes(musicData);
    print('Файл сохранен по пути: $filePath');

    // Подсчет количества файлов в папке
    List<FileSystemEntity> files = storageDir.listSync();
    int fileCount = files.length;
    int countphoto = fileCount;
    print('Количество файлов в папке: ${widget.filename}-$fileCount подходов');

    // Отправка данных на сервер

    try {
      Map<dynamic, String> jsonData = {
        'object1': '$namephoto$countphoto',
      };

      Response response = await dio.post(
        'https://script.google.com/macros/s/AKfycbxZIuWAXPe0cXTJeUly1rYn9j7Sfshx692bT1zMrhca-2DKL0trpmkQCfacBNk0AK62/exec',
        data: jsonData,
      );

      if (response.statusCode == 200) {
        print('Запрос успешно отправлен');
        print('Ответ сервера: ${response.data}');
      } else {
        print('Ошибка при отправке запроса');
      }
    } catch (e) {
      print('Ошибка при отправке HTTP-запроса: $e');
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Завершить запись'),
          content: const Text('Начать фотосет?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Нет'),
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалоговое окно
              },
            ),
            TextButton(
              child: const Text('Да'),
              onPressed: () {
                // Перейти на другую страницу или выполнить другую логику
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NextPage(
                      filename: widget.filename ?? '',
                    ),
                  ),
                ); // Закрыть диалоговое окно
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _recorder?.closeAudioSession();
    _recorder = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor:
            isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        appBar: AppBar(
          backgroundColor: AppTheme.nearlyBlack,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
              ),
              onPressed: _toggleRecording,
              child: Text(buttonText),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    widget.filename ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _toggleRecording,
                    child: const Text('Начать подход/Закончить подход'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
