import 'package:bloc/bloc.dart';

// Определение событий
abstract class MyEvent {}

class SetVariableEvent extends MyEvent {
  final String value;

  SetVariableEvent(this.value);
}

// Определение блока
class MyBloc extends Bloc<MyEvent, String> {
  MyBloc() : super('') {
    // Инициализация начального состояния
    on<SetVariableEvent>((event, emit) {
      myVariable = event.value; // Обновление переменной новым значением
      emit(myVariable); // Обновление состояния Bloc новым значением
    });
  }

  String myVariable = ''; // Ваша переменная
}
