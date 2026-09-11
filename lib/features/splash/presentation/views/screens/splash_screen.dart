import 'package:contacting_app/config/di/di.dart';
import 'package:contacting_app/core/resources/app_assets.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/core/routes/app_routes.dart';
import 'package:contacting_app/features/splash/presentation/view_model/splash_events.dart';
import 'package:contacting_app/features/splash/presentation/view_model/splash_states.dart';
import 'package:contacting_app/features/splash/presentation/view_model/splash_view_model.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashViewModel viewModel=getIt<SplashViewModel>();
  @override
  void initState() {
    super.initState();
    viewModel.doIntent(CheckAuthStatusEvent());
  }
  @override
  Widget build(BuildContext context) {
    var width=MediaQuery.sizeOf(context).width;
    var height=MediaQuery.sizeOf(context).height;
    return BlocProvider(
      create: (context) => viewModel,
      child: BlocListener<SplashViewModel,SplashStates>(
        listener: (context, state) {
          if(state.authStatusState?.isLoading==false && state.authStatusState?.data!=null){
            final isLoggedIn = state.authStatusState!.data!;
            Navigator.pushReplacementNamed(context, isLoggedIn?AppRoutes.home:AppRoutes.login);
          }
        },
        child: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsetsGeometry.only(left: 0.04*width,right: 0.04*width,top: 0.02*height),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: width * 0.7,   
                    height: height * 0.7,  
                    child: Image.asset(
                      AppAssets.logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 0.02*height,),
                  Text(AppLocalizations.of(context)!.connect_call,style: Theme.of(context).textTheme.bodyLarge,),
                  SizedBox(height: 0.01*height,),
                  Text(AppLocalizations.of(context)!.tag_line,style: Theme.of(context).textTheme.bodySmall,),
                  SizedBox(height: 0.02*height,),
                  CircularProgressIndicator(color: AppColors.primaryColor,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}