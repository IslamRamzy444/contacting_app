// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:contacting_app/config/entities/contact_entity.dart';
import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:contacting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final ContactEntity contact;
  const ContactTile({super.key,required this.contact});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        borderRadius: BorderRadius.circular(width * 0.03),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: width * 0.07,
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            backgroundImage: contact.photoUrl != null?CachedNetworkImageProvider(contact.photoUrl!):null,
            child: contact.photoUrl == null?Icon(Icons.person,size: width * 0.08,color: AppColors.primaryColor,):null,
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name,style: Theme.of(context).textTheme.bodyLarge,overflow: TextOverflow.ellipsis,),
                SizedBox(height: height * 0.005),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: contact.isOnline?AppColors.greenColor:AppColors.greyColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: width * 0.01),
                    Text(contact.isOnline?AppLocalizations.of(context)!.online:AppLocalizations.of(context)!.offline,
                    style: Theme.of(context).textTheme.bodySmall,)
                  ],
                )
              ],
            )
          ),
          IconButton(
            onPressed: () {
              
            },
            icon: Icon(
              Icons.call,
              color: AppColors.greenColor,
              size: width * 0.06,
            ),
            tooltip: AppLocalizations.of(context)!.audio_call,
          ),
          IconButton(
            onPressed: () {
            
            },
            icon: Icon(
              Icons.videocam,
              color: AppColors.primaryColor,
              size: width * 0.06,
            ),
            tooltip: AppLocalizations.of(context)!.video_call,
          ),
        ],
      ),
    );
  }
}