import 'package:app_ui/app_ui.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc({
    required IAuthenticationRepository authRepository,
    required String initialName,
    required String initialPhone,
  })  : _authRepository = authRepository,
        super(
          EditProfileState(
            name: FullName.dirty(initialName),
            phone: Phone.dirty(initialPhone),
          ),
        ) {
    on<EditProfileNameChanged>(_onNameChanged);
    on<EditProfilePhoneChanged>(_onPhoneChanged);
    on<EditProfileSubmitted>(_onSubmitted);
  }

  final IAuthenticationRepository _authRepository;

  void _onNameChanged(
    EditProfileNameChanged event,
    Emitter<EditProfileState> emit,
  ) {
    final name = FullName.dirty(event.name);
    emit(state.copyWith(
      name: name,
      status: FormzSubmissionStatus.initial,
    ));
  }

  void _onPhoneChanged(
    EditProfilePhoneChanged event,
    Emitter<EditProfileState> emit,
  ) {
    final phone = Phone.dirty(event.phone);
    emit(state.copyWith(
      phone: phone,
      status: FormzSubmissionStatus.initial,
    ));
  }

  Future<void> _onSubmitted(
    EditProfileSubmitted event,
    Emitter<EditProfileState> emit,
  ) async {
    if (state.name.isNotValid || state.phone.isNotValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      final response = await _authRepository.updateProfile(
        userId: event.userId,
        name: state.name.value,
        phone: state.phone.value,
      );

      response.when(
        (success) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
        (failure) => emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: failure.message,
        )),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
