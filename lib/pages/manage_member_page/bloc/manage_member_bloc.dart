import 'package:club_repository/club_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'manage_member_event.dart';
part 'manage_member_state.dart';

class ManageMemberBloc extends Bloc<IManageMemberEvent, ManageMemberState> {
  final IClubRepository _clubRepository;

  ManageMemberBloc({required IClubRepository clubRepository})
      : _clubRepository = clubRepository,
        super(const ManageMemberState.initial()) {
    on<GetTeatchersRequired>(_onGetTeatchersDataRequired);
    on<GetChildrenRequired>(_onGetChildrenDataRequired);
    on<AddTeacherToClubRequired>(_onAddTeacherToClubRequired);
  }

  Future<void> _onGetTeatchersDataRequired(
      GetTeatchersRequired event, Emitter<ManageMemberState> emit) async {
    emit(const ManageMemberState.loading());

    final response = await _clubRepository.getUsers(id: event.id);

    response.when(
      (success) => emit(
        ManageMemberState.success(teatchersModel: success),
      ),
      (failure) => emit(
        ManageMemberState.failure(message: failure.message),
      ),
    );
  }

  Future<void> _onGetChildrenDataRequired(
      GetChildrenRequired event, Emitter<ManageMemberState> emit) async {
    emit(const ManageMemberState.loading());

    final response = await _clubRepository.getChildren(id: event.id);

    response.when(
      (success) => emit(
        ManageMemberState.successChildren(childrenModel: success),
      ),
      (failure) => emit(
        ManageMemberState.failure(message: failure.message),
      ),
    );
  }

  Future<void> _onAddTeacherToClubRequired(
      AddTeacherToClubRequired event, Emitter<ManageMemberState> emit) async {
    emit(const ManageMemberState.loading());

    final response = await _clubRepository.joinClub(
        clubId: event.clubId, userId: event.teacherId);

    response.when(
      (success) {
        // Re-fetch teachers after successfully adding one
        add(GetTeatchersRequired(id: event.clubId));
      },
      (failure) => emit(
        ManageMemberState.failure(message: failure.message),
      ),
    );
  }
}
