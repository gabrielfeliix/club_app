part of 'edit_profile_bloc.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object> get props => [];
}

class EditProfileNameChanged extends EditProfileEvent {
  const EditProfileNameChanged(this.name);
  final String name;

  @override
  List<Object> get props => [name];
}

class EditProfilePhoneChanged extends EditProfileEvent {
  const EditProfilePhoneChanged(this.phone);
  final String phone;

  @override
  List<Object> get props => [phone];
}

class EditProfileSubmitted extends EditProfileEvent {
  const EditProfileSubmitted({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}
