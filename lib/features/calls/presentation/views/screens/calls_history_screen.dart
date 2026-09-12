import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CallsHistoryScreen extends StatefulWidget {
  const CallsHistoryScreen({super.key});

  @override
  State<CallsHistoryScreen> createState() => _CallsHistoryScreenState();
}

class _CallsHistoryScreenState extends State<CallsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.calls,style: Theme.of(context).textTheme.bodyLarge,),);
  }
}