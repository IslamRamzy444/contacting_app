import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/core/routes/app_routes.dart';
import 'package:contacting_app/features/calls/presentation/views/screens/calls_history_screen.dart';
import 'package:contacting_app/features/contacts/presentation/views/screens/contacts_screen.dart';
import 'package:contacting_app/features/home/presentation/view_model/home_events.dart';
import 'package:contacting_app/features/home/presentation/view_model/home_states.dart';
import 'package:contacting_app/features/home/presentation/view_model/home_view_model.dart';
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
  HomeViewModel viewModel=getIt<HomeViewModel>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeViewModel>(
      create: (context) => viewModel,
      child: BlocBuilder<HomeViewModel,HomeStates>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(AppLocalizations.of(context)!.connect_call,style: Theme.of(context).textTheme.headlineLarge,),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.search);
                  }, 
                  icon: Icon(Icons.search,color: AppColors.whiteColor,)
                )
              ],
            ),
            body: IndexedStack(
              index: state.selectedTab.index,
              children: [
                ContactsScreen(),
                CallsHistoryScreen(),
                ProfileScreen()
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state.selectedTab.index,
              onTap: (index) {
                viewModel.doIntent(ChangeTabEvent(AppTab.values[index]));
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
              ]
            ),
          );
        },
      ),
    );
  }
}