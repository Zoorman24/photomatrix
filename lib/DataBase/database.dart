// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photomatrix/DataBase/block.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

abstract class DatabaseHelper {
  Future<void> initDatabasePath();
  Future<void> initDatabase();
  Future<void> insertData(
    int person,
    bool status,
    String myVariable,
  );
  Future<void> printDatabase();

  void showNumberInput(BuildContext context) {}
}

class DatabaseHelperImpl extends DatabaseHelper {
  late Database database;

  String databasePath = '';
  var uuid = const Uuid();
  final TextEditingController _numberController = TextEditingController();

  @override
  Future<void> initDatabasePath() async {
    // Получаем путь к папке файлов приложения на внешнем хранилище
    Directory? appDocDir = await getExternalStorageDirectory();

    if (appDocDir == null) {
      // Не удалось получить доступ к внешнему хранилищу
      return;
    }

    String appDocPath = appDocDir.path;

    // Создаём путь к файлу базы данных
    databasePath = join(appDocPath, 'test-database.db');

    // Проверяем, существует ли файл базы данных
    if (await File(databasePath).exists()) {
      initDatabase();
      print('База данных уже существует');
    } else {
      // Создаем базу данных, если она не существует
      initDatabase();
      print('База данных создана');
    }
  }

  @override
  Future<void> initDatabase() async {
    database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE my_table_true (id TEXT PRIMARY KEY, name TEXT, time TEXT, person INTEGER, status TEXT, param1 TEXT, param2 TEXT, statusphoto TEXT)",
        );
        await db.execute(
          "CREATE TABLE my_table_false (id TEXT PRIMARY KEY, name TEXT, time TEXT, person INTEGER, status TEXT)",
        );
      },
    );

    print('База данных создана по пути $databasePath');
  }

  @override
  Future<void> insertData(
    int person,
    bool status,
    String myVariable,
  ) async {
    var now = DateTime.now();
    var dateFormat = DateFormat('dd.MM-HH:mm');
    String formattedDate = dateFormat.format(now);
    String uniqueId = uuid.v4();
    if (status) {
      await database.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO my_table_true(id, name, time, person, status, param1, param2, statusphoto) VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
          [
            uniqueId,
            myVariable,
            formattedDate,
            person,
            status ? 'true' : 'false',
            'param 1',
            'param 2',
            'true'
          ],
        );
      });
    } else {
      await database.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO my_table_false(id, name, time, person, status) VALUES(?, ?, ?, ?, ?)',
          [
            uniqueId,
            myVariable,
            formattedDate,
            person,
            status ? 'true' : 'false'
          ],
        );
      });
    }

    print('Data inserted with ID: $uniqueId');
    printDatabase();
  }

  @override
  Future<void> printDatabase() async {
    try {
      // Получаем данные из первой таблицы
      List<Map> listTrue =
          await database.rawQuery('SELECT * FROM my_table_true');
      print('Данные из таблицы my_table_true: $listTrue');

      // Получаем данные из второй таблицы
      List<Map> listFalse =
          await database.rawQuery('SELECT * FROM my_table_false');
      print('Данные из таблицы my_table_false: $listFalse');
    } catch (e) {
      print('Ошибка при попытке чтения из базы данных: $e');
    }
  }

  @override
  void showNumberInput(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Введите кол-во людей в комании'),
          content: TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Число"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Далее'),
              onPressed: () {
                Navigator.of(context).pop();
                showConfirmationDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  void showConfirmationDialog(BuildContext context) {
    final myBloc = BlocProvider.of<MyBloc>(context);
    final myVariable = myBloc.state;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Компания согласилась на фото-сет?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Нет'),
              onPressed: () {
                final int person = int.tryParse(_numberController.text) ?? 0;
                insertData(person, false, myVariable);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Да'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showSaveConfirmationDialog(BuildContext context) {
    final myBloc = BlocProvider.of<MyBloc>(context);
    final myVariable = myBloc.state;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Закончить?'),
          content: const Text('Выберите статус для сохранения в базе данных.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Нет'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Да'),
              onPressed: () {
                final int person = int.tryParse(_numberController.text) ?? 0;
                insertData(person, true, myVariable);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     var brightness = MediaQuery.of(context).platformBrightness;
//     bool isLightMode = brightness == Brightness.light;

//     return SafeArea(
//       top: false,
//       child: Scaffold(
//         backgroundColor:
//             isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//
//               ElevatedButton(
//                 child: const Text('Save Data'),
//                 onPressed: () {
//                   showNumberInput(context);
//                 },
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
}
