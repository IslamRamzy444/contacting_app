import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/core/routes/app_routes.dart';
import 'package:contacting_app/core/ui_utils/dialog_utils.dart';
import 'package:contacting_app/core/validators/app_validators.dart';
import 'package:contacting_app/features/auth/register/presentation/view_model/register_events.dart';
import 'package:contacting_app/features/auth/register/presentation/view_model/register_states.dart';
import 'package:contacting_app/features/auth/register/presentation/view_model/register_view_model.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  RegisterViewModel viewModel=getIt<RegisterViewModel>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var width=MediaQuery.sizeOf(context).width;
    var height=MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.register,style: Theme.of(context).textTheme.headlineLarge,),
      ),
      body: BlocProvider<RegisterViewModel>(
        create: (context) => viewModel,
        child: BlocConsumer<RegisterViewModel,RegisterStates>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.04*width),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 0.02*height,),
                    Text(AppLocalizations.of(context)!.create_account,style: Theme.of(context).textTheme.titleLarge,),
                    SizedBox(height: 0.03*height,),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.name,
                              prefixIcon: Icon(Icons.person,color: AppColors.greyColor,)
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              return AppValidators.validateUserName(value,context);
                            },
                          ),
                          SizedBox(height: 0.02*height,),
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.email,
                              prefixIcon: Icon(Icons.email,color: AppColors.greyColor,)
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              return AppValidators.validateEmail(value,context);
                            },
                          ),
                          SizedBox(height: 0.02*height,),
                          TextFormField(
                            obscureText: state.isPasswordHidden!,
                            controller: passwordController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.password,
                              prefixIcon: Icon(Icons.lock,color: AppColors.greyColor,),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  viewModel.doIntent(TogglePasswordVisibilityEvent());
                                }, 
                                icon: state.isPasswordHidden!?Icon(Icons.visibility_off_outlined,color: AppColors.greyColor,):Icon(Icons.visibility_outlined,color: AppColors.greyColor,)
                              )
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              return AppValidators.validatePassword(value,context);
                            },
                          ),
                          SizedBox(height: 0.02*height,),
                          TextFormField(
                            obscureText: state.isConfirmPasswordHidden!,
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.confirm_password,
                              prefixIcon: Icon(Icons.lock,color: AppColors.greyColor,),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  viewModel.doIntent(ToggleConfirmPasswordVisibilityEvent());
                                }, 
                                icon: state.isConfirmPasswordHidden!?Icon(Icons.visibility_off_outlined,color: AppColors.greyColor,):Icon(Icons.visibility_outlined,color: AppColors.greyColor,)
                              )
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              return AppValidators.validateConfirmPassword(value,passwordController.text,context);
                            },
                          ),
                          SizedBox(height: 0.03*height,),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if(_formKey.currentState?.validate()==true){
                                  viewModel.doIntent(RegisterUserEvent(emailController.text, nameController.text, passwordController.text));
                                }
                              }, 
                              child: Text(AppLocalizations.of(context)!.register)
                            ),
                          ),
                          SizedBox(height: 0.02*height,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context)!.already_have_account,style: Theme.of(context).textTheme.bodyMedium,),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(AppLocalizations.of(context)!.login,style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.blueColor,
                                  color: AppColors.blueColor
                                ),),
                              )
                            ],
                          )
                        ],
                      )
                    )
                  ],
                ),
              ),
            );
          }, 
          listener: (context, state) {
            if(state.registerState?.isLoading==true){
              DialogUtils.showLoading(context: context, loadingText: AppLocalizations.of(context)!.loading);
            }else if(state.registerState?.isLoading==false && state.registerState?.data!=null){
              DialogUtils.removeLoading(context: context);
              DialogUtils.showMessage(
                context: context,
                title: AppLocalizations.of(context)!.success, 
                message: AppLocalizations.of(context)!.user_sign_up_success,
                posActionName: AppLocalizations.of(context)!.ok,
                posAction: () {
                  //Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
              );
            }else if(state.registerState?.isLoading==false && state.registerState?.errorMessage!=null){
              DialogUtils.removeLoading(context: context);
              DialogUtils.showMessage(
                context: context,
                title: AppLocalizations.of(context)!.failure, 
                message: state.registerState!.errorMessage!,
                negActionName: AppLocalizations.of(context)!.cancel,
              );
            }
          },
        ),
      ),
    );
  }
}