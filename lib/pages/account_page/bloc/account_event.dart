part of 'account_bloc.dart';

abstract class IAccountEvent extends Equatable {
  const IAccountEvent();

  @override
  List<Object> get props => [];
}

class GetAccountDataRequired extends IAccountEvent {
  final String userId;

  const GetAccountDataRequired({required this.userId});

  @override
  List<Object> get props => [userId];
}
