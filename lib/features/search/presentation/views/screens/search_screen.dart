import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/features/contacts/presentation/views/widgets/contact_tile.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_events.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_states.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:contacting_app/features/search/presentation/view_model/search_events.dart';
import 'package:contacting_app/features/search/presentation/view_model/search_states.dart';
import 'package:contacting_app/features/search/presentation/view_model/search_view_model.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchViewModel viewModel = getIt<SearchViewModel>();
  final ProfileViewModel profileViewModel = getIt<ProfileViewModel>();
  final TextEditingController _controller = TextEditingController();

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    final userId = profileViewModel.state.profileState?.data?.id;
    if (userId != null) {
      _currentUserId = userId;
      viewModel.doIntent(LoadSearchContactsEvent(userId));
    } else {
      profileViewModel.doIntent(GetProfileEvent());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchViewModel>(create: (_) => viewModel),
        BlocProvider<ProfileViewModel>.value(value: profileViewModel),
      ],
      child: BlocListener<ProfileViewModel, ProfileStates>(
        listenWhen: (p, c) =>
            p.profileState?.data?.id != c.profileState?.data?.id &&
            c.profileState?.data?.id != null,
        listener: (context, state) {
          final id = state.profileState!.data!.id;
          _currentUserId = id;
          viewModel.doIntent(LoadSearchContactsEvent(id));
        },
        child: Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _controller,
              autofocus: true,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.search_people,
                border: InputBorder.none,
              ),
              onChanged: (q) =>
                  viewModel.doIntent(SearchQueryChangedEvent(q)),
            ),
            actions: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    viewModel.doIntent(ClearSearchEvent());
                  },
                ),
            ],
          ),
          body: BlocBuilder<SearchViewModel, SearchStates>(
            builder: (context, state) {
              final isSearching = state.query.trim().isNotEmpty;
              final base =
                  isSearching ? state.searchState : state.allContactsState;

              if (base?.isLoading == true) {
                return const Center(child: CircularProgressIndicator());
              }

              if (base?.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: width * 0.15,
                          color: AppColors.redColor,
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          base!.errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: height * 0.02),
                        ElevatedButton(
                          onPressed: () {
                            if (isSearching) {
                              viewModel.doIntent(
                                SearchQueryChangedEvent(state.query),
                              );
                            } else if (_currentUserId != null) {
                              viewModel.doIntent(
                                LoadSearchContactsEvent(_currentUserId!),
                              );
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final contacts = base?.data ?? [];
              final currentUser = profileViewModel.state.profileState?.data;

              if (contacts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: width * 0.15,
                        color: AppColors.greyColor,
                      ),
                      SizedBox(height: height * 0.02),
                      Text(
                        isSearching
                            ? AppLocalizations.of(context)!.no_results_found
                            : AppLocalizations.of(context)!.no_contacts,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.01,
                ),
                itemCount: contacts.length,
                separatorBuilder: (_, __) => SizedBox(height: height * 0.015),
                itemBuilder: (context, i) {
                  return ContactTile(
                    contact: contacts[i],
                    currentUser: currentUser,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}