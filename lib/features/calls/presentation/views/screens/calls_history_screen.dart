// ignore_for_file: deprecated_member_use

import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_events.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_states.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_view_model.dart';
import 'package:contacting_app/features/calls/presentation/views/widgets/call_history_tile.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_events.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_states.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallsHistoryScreen extends StatefulWidget {
  const CallsHistoryScreen({super.key});

  @override
  State<CallsHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallsHistoryScreen> {
  CallViewModel viewModel = getIt<CallViewModel>();
  ProfileViewModel profileViewModel = getIt<ProfileViewModel>();

  @override
  void initState() {
    super.initState();

    profileViewModel.doIntent(GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileViewModel>(create: (_) => profileViewModel),
      ],
      child: BlocListener<ProfileViewModel, ProfileStates>(
        listener: (context, profileState) {
          final userId = profileState.profileState?.data?.id;
          if (userId != null) {
            viewModel.doIntent(GetCallHistoryEvent(userId));
          }
        },
        child: BlocBuilder<CallViewModel, CallStates>(
          builder: (context, state) {
            final historyState = state.callHistoryState;
            final currentUserId = profileViewModel.state.profileState?.data?.id;

            
            if (historyState?.isLoading == true) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }
            if (historyState?.isLoading == false &&
                historyState?.errorMessage != null) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(width * 0.06),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: width * 0.16,
                        color: AppColors.redColor,
                      ),
                      SizedBox(height: height * 0.02),
                      Text(
                        historyState!.errorMessage!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.02),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (currentUserId != null) {
                            viewModel.doIntent(
                              GetCallHistoryEvent(currentUserId),
                            );
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                ),
              );
            }
            final calls = historyState?.data ?? [];
            if (calls.isEmpty) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: width * 0.2,
                      color: AppColors.greyColor.withOpacity(0.5),
                    ),
                    SizedBox(height: height * 0.02),
                    Text(
                      AppLocalizations.of(context)!.no_call_history,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.02,
              ),
              itemCount: calls.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: height * 0.01),
              itemBuilder: (context, index) {
                return CallHistoryTile(
                  call: calls[index],
                  currentUserId: currentUserId ?? '',
                );
              },
            );
          },
        ),
      ),
    );
  }
}
