import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/features/contacts/presentation/view_model/contacts_events.dart';
import 'package:contacting_app/features/contacts/presentation/view_model/contacts_states.dart';
import 'package:contacting_app/features/contacts/presentation/view_model/contacts_view_model.dart';
import 'package:contacting_app/features/contacts/presentation/views/widgets/contact_tile.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_events.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_states.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  ContactsViewModel viewModel = getIt<ContactsViewModel>();
  ProfileViewModel profileViewModel = getIt<ProfileViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.doIntent(GetContactsEvent());
    profileViewModel.doIntent(GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return MultiBlocProvider(
      providers: [
        BlocProvider<ContactsViewModel>(create: (_) => viewModel),
        BlocProvider<ProfileViewModel>(create: (_) => profileViewModel),
      ],
      child: BlocBuilder<ProfileViewModel, ProfileStates>(
        builder: (context, profileState) {
          final currentUser = profileState.profileState?.data;

          return BlocBuilder<ContactsViewModel, ContactsStates>(
            builder: (context, state) {
              final contactsState = state.contactsState;

              if (contactsState?.isLoading == true) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              if (contactsState?.isLoading == false &&
                  contactsState?.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          contactsState!.errorMessage!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: height * 0.02),
                        ElevatedButton(
                          onPressed: () {
                            viewModel.doIntent(GetContactsEvent());
                          },
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final contacts = contactsState?.data ?? [];

              if (contacts.isEmpty) {
                return Center(
                  child: Text(AppLocalizations.of(context)!.no_contacts),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.02,
                ),
                itemBuilder: (context, index) {
                  return ContactTile(
                    contact: contacts[index],
                    currentUser: currentUser,
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: height * 0.01);
                },
                itemCount: contacts.length,
              );
            },
          );
        },
      ),
    );
  }
}
