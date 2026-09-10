import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AppValidators {
  AppValidators._();
  static String? validateEmail(String? val,BuildContext context){
    RegExp emailRegex=RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if(val==null || val.trim().isEmpty){
      return AppLocalizations.of(context)!.required_field;
    }else if(emailRegex.hasMatch(val.trim())==false){
      return AppLocalizations.of(context)!.valid_email;
    }else{
      return null;
    }
  }
  static String? validatePassword(String? val,BuildContext context){
    RegExp passwordRegex=RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])');
    if(val==null || val.trim().isEmpty){
      return AppLocalizations.of(context)!.required_field;
    }else if(val.length<8 || passwordRegex.hasMatch(val.trim())==false){
      return AppLocalizations.of(context)!.valid_password;
    }else{
      return null;
    }
  }
  static String? validateConfirmPassword(String? val,String? password,BuildContext context){
    if(val==null || val.trim().isEmpty){
      return AppLocalizations.of(context)!.required_field;
    }else if(val.trim()!=password?.trim()){
      return AppLocalizations.of(context)!.passwords_mismatch;
    }else{
      return null;
    }
  }
  static String? validateUserName(String? val,BuildContext context){
    RegExp userNameRegex=RegExp(r'^[a-zA-Z0-9,.-]+$');
    if(val==null || val.trim().isEmpty){
      return AppLocalizations.of(context)!.required_field;
    }else if(!userNameRegex.hasMatch(val.trim())){
      return AppLocalizations.of(context)!.valid_user_name;
    }else{
      return null;
    }
  }
}