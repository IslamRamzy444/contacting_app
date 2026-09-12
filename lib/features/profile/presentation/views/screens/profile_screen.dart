import 'package:cached_network_image/cached_network_image.dart';
import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/core/routes/app_routes.dart';
import 'package:contacting_app/core/ui_utils/dialog_utils.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_events.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_states.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileViewModel viewModel = getIt<ProfileViewModel>();
  @override
  void initState() {
    super.initState();
    viewModel.doIntent(GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    var width=MediaQuery.sizeOf(context).width;
    var height=MediaQuery.sizeOf(context).height;
    return BlocProvider<ProfileViewModel>(
      create: (context) => viewModel,
      child: BlocConsumer<ProfileViewModel, ProfileStates>(
        builder: (context, state) {
          final profileState = state.profileState;
          if (profileState?.isLoading == true) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          if(profileState?.isLoading == false && profileState?.errorMessage != null){
            return Center(
              child: Column(
                children: [
                  Text(profileState!.errorMessage!,style: Theme.of(context).textTheme.bodyLarge,),
                  SizedBox(height: 0.02*height,),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.doIntent(GetProfileEvent());
                    }, 
                    child: Text(AppLocalizations.of(context)!.retry)
                  )
                ],
              ),
            );
          }
          final user = profileState?.data;
          if (user == null) {
            return const SizedBox.shrink();
          }
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.04*width),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 0.16*width,
                    // ignore: deprecated_member_use
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    backgroundImage: user.photoUrl != null?CachedNetworkImageProvider(user.photoUrl!):null,
                    child: user.photoUrl == null?Icon(Icons.person,size: 72,color: AppColors.primaryColor,):null,
                  ),
                  SizedBox(height: 0.02*height,),
                  Text(user.name??'unknown',style: Theme.of(context).textTheme.bodyLarge,),
                  SizedBox(height: 0.01*height,),
                  Text(user.email,style: Theme.of(context).textTheme.bodyLarge,),
                  SizedBox(height: 0.01*height,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: user.isOnline?AppColors.greenColor:AppColors.greyColor,
                          shape: BoxShape.circle
                        ),
                      ),
                      SizedBox(width: 0.01*width,),
                      Text(user.isOnline?AppLocalizations.of(context)!.online:AppLocalizations.of(context)!.offline,style: Theme.of(context).textTheme.bodyMedium,),
                    ],
                  ),
                  SizedBox(height: height * 0.08),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.editProfile).then((_) {
                          viewModel.doIntent(GetProfileEvent());
                        },);
                      },
                      icon: const Icon(Icons.edit), 
                      label: Text(AppLocalizations.of(context)!.edit_profile)
                    ),
                  ),
                  SizedBox(height: 0.01*height,),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        DialogUtils.showMessage(
                          context: context,
                          title: AppLocalizations.of(context)!.logout, 
                          message: AppLocalizations.of(context)!.logout_confirmation,
                          posActionName: AppLocalizations.of(context)!.yes,
                          posAction: () {
                            viewModel.doIntent(LogoutEvent());
                          },
                          negActionName: AppLocalizations.of(context)!.no
                        );
                      },
                      icon: const Icon(Icons.logout), 
                      label: Text(AppLocalizations.of(context)!.logout)
                    ),
                  )
                ],
              ),
            ),
          );
        },
        listener: (context, state) {
          if (state.isLoggedOut) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        },
      ),
    );
  }
}
