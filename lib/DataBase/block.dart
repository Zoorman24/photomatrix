import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// События
abstract class PhotoEvent extends Equatable {
  const PhotoEvent();

  @override
  List<Object> get props => [];
}

class SetPhotoName extends PhotoEvent {
  final String name;

  const SetPhotoName(this.name);

  @override
  List<Object> get props => [name];
}

class UpdateNameEvent extends PhotoEvent {
  final String newName;

  const UpdateNameEvent(this.newName);

  @override
  List<Object> get props => [newName];
}

// Состояние
class PhotoState extends Equatable {
  final String name;

  const PhotoState(this.name);

  @override
  List<Object> get props => [name];
}

// BLoC
class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  PhotoBloc() : super(const PhotoState(''));

  @override
  Stream<PhotoState> mapEventToState(PhotoEvent event) async* {
    if (event is SetPhotoName) {
      yield PhotoState(event.name);
    } else if (event is UpdateNameEvent) {
      // Здесь вы можете добавить логику обновления имени в базе данных
      // и затем выдать новое состояние с обновленным именем
      yield PhotoState(event.newName);
    }
  }
}
