import 'package:bloc/bloc.dart';

class SettingCubit extends Cubit<bool> {
  SettingCubit(bool initialState) : super(initialState);

  void setTheme(bool value) => emit(value);

  void toggle() => emit(!state);
}
