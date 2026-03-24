part of 'manage_member_bloc.dart';

abstract class IManageMemberEvent extends Equatable {
  const IManageMemberEvent();

  @override
  List<Object> get props => [];
}

// class EditClubNameRequired extends IManageUsersEvent {
//   final String name;
//   final String id;

//   const EditClubNameRequired({required this.name, required this.id});

//   @override
//   List<Object> get props => [name];
// }

// class EditClubAddressRequired extends IManageClubEvent {
//   final String address;
//   final String id;

//   const EditClubAddressRequired({required this.address, required this.id});

//   @override
//   List<Object> get props => [address];
// }

class GetTeatchersRequired extends IManageMemberEvent {
  final String id;

  const GetTeatchersRequired({required this.id});

  @override
  List<Object> get props => [id];
}

class GetChildrenRequired extends IManageMemberEvent {
  final String id;

  const GetChildrenRequired({required this.id});

  @override
  List<Object> get props => [id];
}

class AddTeacherToClubRequired extends IManageMemberEvent {
  final String teacherId;
  final String clubId;

  const AddTeacherToClubRequired({required this.teacherId, required this.clubId});

  @override
  List<Object> get props => [teacherId, clubId];
}
