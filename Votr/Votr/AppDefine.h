//
//  AppDefine.h
//  Votr
//
//  Created by tmaas510 on 22/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#ifndef AppDefine_h
#define AppDefine_h

#define main_color [UIColor colorWithRed:20.0f/255 green:43.0f/255 blue:74.0f/255 alpha:1.0]
#define bg_color   [UIColor colorWithRed:237.0f/255 green:237.0f/255 blue:237.0f/255 alpha:1.0]
#define tab_color   [UIColor colorWithRed:73.0f/255 green:171.0f/255 blue:173.0f/255 alpha:1.0]
#define vBlue_color   [UIColor colorWithRed:41.0f/255 green:86.0f/255 blue:147.0f/255 alpha:1.0]

#define my_deviceID @"6BADFA4E-9869-495D-BAA0-8DC489A5A319" //iPhone 5S
//#define my_deviceID @"09B10BF0-E3BF-403B-81D0-AD185A4B307C" //iPad Air 2

#define appDel (AppDelegate *)[[UIApplication sharedApplication] delegate]

//===================   Define Message   ====================//
#define msg_e_error         @"Error"
#define msg_e_fillAll       @"Please fill all fields!"
#define msg_e_invalidEmail  @"Invalid Email!"
#define msg_e_wrongPassword @"Wrong Password!"



//===================   Define Keys   ====================//
#define vClass_Poll     @"Poll"
#define vClass_Comment  @"Comment"
#define vClass_Vote     @"Vote"


//===================   Define Keys   ====================//
//user: username, password
#define kAvatar             @"avatar"
#define kTopics             @"topics"

//Poll
#define kPoster             @"poster"
#define kTitle              @"title"
#define kPosttype           @"posttype"
#define kType               @"type"
#define kDateStart          @"startDate"
#define kDateEnd            @"endDate"
#define kDatePost           @"postDate"
#define kTags               @"tags"
#define kTitle1             @"title1"
#define kTitle2             @"title2"
#define kDescribe1          @"describe1"
#define kDescribe2          @"describe2"
#define kThumb1             @"thumb1"
#define kThumb2             @"thumb2"
#define kCountVote          @"countVote"
#define kCountVote1         @"countVote1"
#define kCountVote2         @"countVote2"
#define kCountComment       @"countComment"

//Vote
#define kUser               @"user"
#define kPoll               @"poll"
#define kVoted              @"voted"

//Comment
#define kComment            @"comment"
#define kCountLike          @"countLike"

#endif /* AppDefine_h */
