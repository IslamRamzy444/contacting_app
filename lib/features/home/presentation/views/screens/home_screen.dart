import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/config/entities/call_entity.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/core/routes/app_routes.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_events.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_states.dart';
import 'package:contacting_app/features/calls/presentation/view_model/call_view_model.dart';
import 'package:contacting_app/features/calls/presentation/views/screens/calls_history_screen.dart';
import 'package:contacting_app/features/contacts/presentation/views/screens/contacts_screen.dart';
import 'package:contacting_app/features/home/presentation/view_model/home_events.dart';
import 'package:contacting_app/features/home/presentation/view_model/home_states.dart';
import 'package:contacting_app/features/home/presentation/view_model/home_view_model.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_events.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_states.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:contacting_app/features/profile/presentation/views/screens/profile_screen.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewModel homeViewModel = getIt<HomeViewModel>();
  CallViewModel callViewModel = getIt<CallViewModel>();
  ProfileViewModel profileViewModel = getIt<ProfileViewModel>();
  String? _subscribedUserId;
  String? _lastNavigatedCallId;

  @override
  void initState() {
    super.initState();
    profileViewModel.doIntent(GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeViewModel>(create: (_) => homeViewModel),
        BlocProvider<ProfileViewModel>(create: (_) => profileViewModel),
      ],
      child: BlocListener<ProfileViewModel, ProfileStates>(
        listener: (context, profileState) {
          final userId = profileState.profileState?.data?.id;

          
          if (userId != null && _subscribedUserId != userId) {
            _subscribedUserId = userId;
            callViewModel.doIntent(ListenToIncomingCallsEvent(userId));
          }
        },
        child: BlocListener<CallViewModel, CallStates>(
          listenWhen: (previous, current) {
            final prevCall = previous.incomingCallState?.data;
            final currCall = current.incomingCallState?.data;
            return prevCall?.id != currCall?.id &&
                currCall != null &&
                currCall.status == CallStatus.calling;
          },
          listener: (context, state) {
            final incomingCall = state.incomingCallState?.data;
            if (incomingCall == null) return;
            if (incomingCall.status != CallStatus.calling) return;

            
            final currentUserId = profileViewModel.state.profileState?.data?.id;
            if (incomingCall.callerId == currentUserId) return;

            
            if (_lastNavigatedCallId == incomingCall.id) return;
            _lastNavigatedCallId = incomingCall.id;

            Navigator.pushNamed(
              context,
              AppRoutes.incomingCall,
              arguments: {'call': incomingCall},
            ).then((_) {
              _lastNavigatedCallId = null;
            });
          },
          child: BlocBuilder<HomeViewModel, HomeStates>(
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(
                    AppLocalizations.of(context)!.connect_call,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.search);
                      },
                      icon: Icon(
                        Icons.search,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ],
                ),
                body: IndexedStack(
                  index: state.selectedTab.index,
                  children: const [
                    ContactsScreen(),
                    CallsHistoryScreen(),
                    ProfileScreen(),
                  ],
                ),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: state.selectedTab.index,
                  onTap: (index) {
                    homeViewModel.doIntent(ChangeTabEvent(AppTab.values[index]));
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.people),
                      label: AppLocalizations.of(context)!.contacts,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.history),
                      label: AppLocalizations.of(context)!.calls,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person),
                      label: AppLocalizations.of(context)!.profile,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
