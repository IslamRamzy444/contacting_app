import 'package:cached_network_image/cached_network_image.dart';
import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/core/ui_utils/dialog_utils.dart';
import 'package:contacting_app/core/validators/app_validators.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_events.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_states.dart';
import 'package:contacting_app/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  ProfileViewModel viewModel=getIt<ProfileViewModel>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _hasPopulated = false;
  @override
  void initState() {
    super.initState();
    viewModel.doIntent(GetProfileEvent());
  }
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return BlocProvider<ProfileViewModel>(
      create: (context) => viewModel,
      child: BlocConsumer<ProfileViewModel,ProfileStates>(
        builder: (context, state) {
          final user = viewModel.state.profileState?.data;
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.edit_profile,style: Theme.of(context).textTheme.headlineLarge,),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 0.04*width),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: height * 0.03),
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 0.15*width,
                            // ignore: deprecated_member_use
                            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                            backgroundImage: user?.photoUrl != null?CachedNetworkImageProvider(user!.photoUrl!):null,
                            child: user?.photoUrl == null?Icon(Icons.person,size: 0.18*width,color: AppColors.primaryColor,):null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: width * 0.045,
                              backgroundColor: AppColors.primaryColor,
                              child: Icon(Icons.camera_alt,size: width * 0.045,color: AppColors.whiteColor,),
                            )
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    Center(
                      child: Text(AppLocalizations.of(context)!.photo_editing_coming_soon,style: Theme.of(context).textTheme.bodyMedium,),
                    ),
                    SizedBox(height: height * 0.04),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.name,
                        prefixIcon: Icon(Icons.person,color: AppColors.greyColor,)
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        return AppValidators.validateUserName(value,context);
                      },
                    ),
                    SizedBox(height: height * 0.04),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.updateState?.isLoading == true?null:(){
                          if(_formKey.currentState?.validate()==true){
                            viewModel.doIntent(UpdateProfileEvent(name: _nameController.text.trim()));
                          }
                        }, 
                        child: Text(AppLocalizations.of(context)!.save_changes)
                      ),
                    )
                  ],
                )
              ),
            ),
          );
        }, 
        listener: (context, state) {
          if (state.profileState?.isLoading == false &&
              state.profileState?.data != null &&
              !_hasPopulated) {
            _nameController.text = state.profileState!.data!.name ?? '';
            _hasPopulated = true;
          }
          if(state.updateState?.isLoading == true){
            DialogUtils.showLoading(
              context: context,
              loadingText: AppLocalizations.of(context)!.loading,
            );
          }else if(state.updateState?.isLoading == false && state.updateState?.data != null){
            DialogUtils.removeLoading(context: context);
            DialogUtils.showMessage(
              context: context,
              title: AppLocalizations.of(context)!.success,
              message: AppLocalizations.of(context)!.profile_updated_success,
              posActionName: AppLocalizations.of(context)!.ok,
              posAction: () {
                Navigator.pop(context);
              },
            );
          }else if(state.updateState?.isLoading == false && state.updateState?.errorMessage != null){
            DialogUtils.removeLoading(context: context);
            DialogUtils.showMessage(
              context: context,
              title: AppLocalizations.of(context)!.failure,
              message: state.updateState!.errorMessage!,
              negActionName: AppLocalizations.of(context)!.cancel,
            );
          }
        },
      ),
    );
  }
}