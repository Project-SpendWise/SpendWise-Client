import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/statement.dart';

class ProfileState {
  final String? selectedProfileId;
  final BankStatement? selectedProfile;

  ProfileState({
    this.selectedProfileId,
    this.selectedProfile,
  });

  ProfileState copyWith({
    String? selectedProfileId,
    BankStatement? selectedProfile,
    bool clearSelectedProfile = false,
  }) {
    return ProfileState(
      selectedProfileId: clearSelectedProfile ? null : (selectedProfileId ?? this.selectedProfileId),
      selectedProfile: clearSelectedProfile ? null : (selectedProfile ?? this.selectedProfile),
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState());

  void selectProfile(String? profileId, BankStatement? profile) {
    state = ProfileState(
      selectedProfileId: profileId,
      selectedProfile: profile,
    );
  }

  void clearSelection() {
    state = ProfileState();
  }

  bool isProfileSelected() {
    return state.selectedProfileId != null;
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

