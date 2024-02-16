// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photomatrix/DataBase/block.dart';
import 'package:photomatrix/DataBase/database.dart';
import 'package:photomatrix/startlist/photo_start.dart';
import 'package:photomatrix/theme/app_theme.dart';
import 'package:photomatrix/photomatrix_repository/model_list.dart';
import 'package:photomatrix/photomatrix_repository/photomatrix_repository.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController? animationController;
  String? dropdownValue;
  List<String> dropdownItems = [];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    fetchData();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    // Создаем экземпляр ApiClient
    ApiClient apiClient = ApiClient();

    try {
      // Получаем список имен фото с помощью метода getName из ApiClient
      List<Photoname> photoList = await apiClient.getName();

      // Преобразуем список имен фото в список строк
      List<String> photoNames = photoList.map((photo) => photo.name).toList();

      // Фильтруем список имен фото, исключая пустые элементы
      List<String> filteredPhotoNames =
          photoNames.where((name) => name.isNotEmpty).toList();

      // Обновляем состояние dropdownItems с отфильтрованным списком имен фото
      setState(() {
        dropdownItems = filteredPhotoNames;
      });
    } catch (e) {
      // Обработка ошибок при получении списка имен фото
      print('Ошибка при получении списка имен фото: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Scaffold(
      backgroundColor:
          isLightMode == true ? AppTheme.white : AppTheme.nearlyBlack,
      body: SafeArea(
        child: Stack(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 13),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Авторизация',
                  style: TextStyle(color: Colors.red, fontSize: 24),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (dropdownItems.isNotEmpty)
                    DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 0, 0)),
                      underline: Container(
                        height: 2,
                        color: const Color.fromARGB(255, 255, 0, 0),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                        BlocProvider.of<MyBloc>(context)
                            .add(SetVariableEvent(newValue!));
                      },
                      itemHeight: 50, // Задаем фиксированную высоту элемента
                      items: dropdownItems
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  if (dropdownItems.isEmpty) const CircularProgressIndicator(),
                  ElevatedButton(
                    onPressed: dropdownValue != null &&
                            dropdownValue!.isNotEmpty
                        ? () {
                            if (dropdownValue != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoStart(
                                      dbHelper: DatabaseHelperImpl()),
                                ),
                              );
                            } else {
                              print('dropdownValue is null, not navigating');
                            }
                          }
                        : null,
                    child: const Text(
                      'Начать фотосет',
                      style: TextStyle(color: Colors.red),
                    ), // Делаем кнопку неактивной, если dropdownValue равно null
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
