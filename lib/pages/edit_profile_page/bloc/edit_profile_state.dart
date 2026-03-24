part of 'edit_profile_bloc.dart';

class EditProfileState extends Equatable {
  const EditProfileState({
    this.name = const FullName.pure(),
    this.phone = const Phone.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final FullName name;
  final Phone phone;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  EditProfileState copyWith({
    FullName? name,
    Phone? phone,
    FormzSubmissionStatus? status,
    String? errorMessage,
  }) {
    return EditProfileState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [name, phone, status, errorMessage];
}
