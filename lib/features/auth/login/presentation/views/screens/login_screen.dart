import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/core/routes/app_routes.dart';
import 'package:contacting_app/core/ui_utils/dialog_utils.dart';
import 'package:contacting_app/core/validators/app_validators.dart';
import 'package:contacting_app/features/auth/login/presentation/view_model/login_events.dart';
import 'package:contacting_app/features/auth/login/presentation/view_model/login_states.dart';
import 'package:contacting_app/features/auth/login/presentation/view_model/login_view_model.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginViewModel viewModel=getIt<LoginViewModel>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var width=MediaQuery.sizeOf(context).width;
    var height=MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.login,style: Theme.of(context).textTheme.headlineLarge,),
      ),
      body: BlocProvider<LoginViewModel>(
        create: (context) => viewModel,
        child: BlocConsumer<LoginViewModel,LoginStates>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 0.04*width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 0.02*height,),
                  Text(AppLocalizations.of(context)!.welcome,style: Theme.of(context).textTheme.titleLarge,),
                  SizedBox(height: 0.03*height,),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          controller: passwordController,
                          obscureText: state.isPasswordHidden!,
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
                        SizedBox(height: 0.03*height,),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if(_formKey.currentState?.validate()==true){
                                viewModel.doIntent(LoginUserEvent(emailController.text, passwordController.text));
                              }
                            }, 
                            child: Text(AppLocalizations.of(context)!.login)
                          ),
                        ),
                        SizedBox(height: 0.02*height,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.do_not_have_account,style: Theme.of(context).textTheme.bodyMedium,),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.register);
                              },
                              child: Text(AppLocalizations.of(context)!.register,style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            );
          }, 
          listener: (context, state) {
            if(state.loginUserState?.isLoading==true){
              DialogUtils.showLoading(context: context, loadingText: AppLocalizations.of(context)!.loading);
            }else if(state.loginUserState?.isLoading==false && state.loginUserState?.data!=null){
              DialogUtils.removeLoading(context: context);
              DialogUtils.showMessage(
                context: context,
                title: AppLocalizations.of(context)!.success, 
                message: AppLocalizations.of(context)!.user_sign_in_success,
                posActionName: AppLocalizations.of(context)!.ok,
                posAction: () {
                  //Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
              );
            }else if(state.loginUserState?.isLoading==false && state.loginUserState?.errorMessage!=null){
              DialogUtils.removeLoading(context: context);
              DialogUtils.showMessage(
                context: context,
                title: AppLocalizations.of(context)!.failure, 
                message: state.loginUserState!.errorMessage!,
                negActionName: AppLocalizations.of(context)!.cancel
              );
            }
          },
        ),
      ),
    );
  }
}