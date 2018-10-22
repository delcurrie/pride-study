//
//  AppConstants.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 6/3/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppConstants : NSObject

#define DEVELOPMENT 0 
#define PRODUCTION 1


//ENVIRONMENT SWITCH (possible inputs for the following is DEVELOPMENT or PRODUCTION

#define SERVER_ENVIRONMENT DEVELOPMENT

////////// User Identifiers //////////

#define USER_FLIGHTS_CLIMBED @"FlightsClimbed"
#define USER_STEPS_COUNT @"StepsCount"
#define USER_WALKING_RUNNING_DIS @"WalkingDistance"
#define USER_FIRST_NAME_IDENTIFIER @"FirstName"
#define USER_LOCATION_SETTING @"AceeptedLocation"
#define USER_LAST_NAME_IDENTIFIER @"LastName"
#define USER_FULL_NAME_IDENTIFIER @"FullName"
#define USER_EMAIL_IDENTIFIER @"Email"
#define USER_ZIP_IDENTIFIER @"ZipCode"
#define USER_BIRTHDAY_IDENTIFIER @"Birthday"
#define USER_HEIGHT_IDENTIFIER @"Height"
#define USER_WEIGHT_IDENTIFIER @"Weight"
#define USER_USER_ID_IDENTIFIER @"UserID"
#define USER_AUTOLOCK_TIME @"autolocktime"
#define USER_SHARING_ENABLED @"SharingEnabled"
#define USER_NOTIFICATION_POSTS @"NotificationNewPosts"
#define USER_NOTIFICATION_REPLIES @"NotificationReplies"
#define USER_NOTIFICATION_COMMENTS @"NotificationsComments"

#define USER_PIN_CODE @"Pin"
#define USER_SEX_IDENTIFIER @"Sex"
#define USER_SEXUAL_ORIENTATION_IDENTIFIER @"SexualOrientation"
#define USER_GENDER_IDENTITY_IDENTIFIER @"GenderIdentity"
#define USER_DEMOGRAPHIC_SURVEY_RESPONSE_ID_IDENTIFIER @"DemographicSurveyResponseIdentifier"
#define DASHBOARD_FORCE_REFRESH @"DashboardRefreshData"

#define USER_HAS_LEFT_STUDY @"UserHasLeftStudy"


////////// App State Identifiers //////////
#define STATE_CONSENT_COMPLETE @"completed_consent"
#define STATE_LEFT_STUDY @"left_study"
#define STATE_SHOW_PIN_POPUP @"show_pin_popup"
#define STATE_EXIT_TIME @"exit_time"
#define STATE_CHANGE_PIN_POPUP @"change_pin_popup"

//survey_types
#define DEMOGRAPHIC_SURVEY @"demographic_survey"
#define IMPROVING_SURVEY @"improving_survey"
#define PHYSICAL_SURVEY @"physical_survey"
#define MENTAL_SURVEY @"mental_survey"
#define SOCIAL_SURVEY @"social_survey"
#define AGE_SURVEY @"age_survey"

#define STATE_DEMOGRAPHIC_SURVEY_COMPLETE_DATE @"DemographicSurveyCompleteDate"
#define STATE_DEMOGRAPHIC_SURVEY_COMPLETE @"DemographicSurveyComplete"

#define STATE_IMPROVING_SURVEY_COMPLETE_DATE @"ImprovingSurveyCompleteDate"
#define STATE_IMPROVING_SURVEY_COMPLETE @"ImprovingSurveyComplete"

#define STATE_PHYSICAL_HEALTH_SURVEY_COMPLETE_DATE @"PhysicalHealthSurveyCompleteDate"
#define STATE_PHYSICAL_HEALTH_SURVEY_COMPLETE @"PhysicalHealthSurveyComplete"

#define STATE_MENTAL_HEALTH_SURVEY_COMPLETE_DATE @"MentalHealthSurveyCompleteDate"
#define STATE_MENTAL_HEALTH_SURVEY_COMPLETE @"MentalHealthSurveyComplete"

#define STATE_SOCIAL_HEALTH_SURVEY_COMPLETE_DATE @"SocialHealthSurveyCompleteDate"
#define STATE_SOCIAL_HEALTH_SURVEY_COMPLETE @"SocialHealthSurveyComplete"

#define STATE_AGE_SURVEY_COMPLETE_DATE @"AgeHealthSurveyCompleteDate"
#define STATE_AGE_SURVEY_COMPLETE @"AgeHealthSurveyComplete"
#define STATE_HAS_COMMUNITY_ACCOUNT @"HasCommunityAccount"
#define STATE_PROFILE_SURVEY_COMPLETE @"ProfileSurveyComplete"
#define STATE_CREATE_SCREEN_NAME_COMPLETE @"CreateScreenNameComplete"
#define STATE_CREATE_SCREEN_NAME_COMPLETE_DATE @"CreateScreenNameCompleteDate"
#define STATE_CREATE_TOPIC_COMPLETE @"CreateTopicComplete"
#define STATE_CREATE_TOPIC_COMPLETE_DATE @"CreateTopicCompleteDate"
#define STATE_REVIEW_TOPICS_COMPLETE @"ReviewTopicsComplete"
#define STATE_REVIEW_TOPICS_COMPLETE_DATE @"ReviewTopicsCompleteDate"
#define STATE_VOTE_ON_TOPICS_COMPLETE @"VoteOnTopicsComplete"
#define STATE_VOTE_ON_TOPICS_COMPLETE_DATE @"VoteOnTopicsCompleteDate"
#define STATE_COMMENT_ON_TOPICS_COMPLETE @"CommentOnTopicsComplete"
#define STATE_COMMENT_ON_TOPICS_COMPLETE_DATE @"CommentOnTopicsCompleteDate"

#define STATE_ACTIVITES_RATIO_COMPLETED @"ActivitesRatioCompleted"


////////// Survey Identifiers //////////
#define SURVEY_DEMOGRAPHIC_SURVEY_TASK_IDENTIFIER @"DemographicSurveyTaskIdentifier"

#define SURVEY_SEX @"QID1"
#define SURVEY_SEXUAL_ORIENTATION @"QID2"
#define SURVEY_SEXUAL_ORIENTATION_A @"QID33"
#define SURVEY_GENDER_IDENTITY @"QID3"
#define SURVEY_GENDER_IDENTITY_A @"QID39"

#define SURVEY_BORN_IN_US @"QID6"
#define SURVEY_HISPANIC @"QID7"
#define SURVEY_HISPANIC_A @"QID16"
#define SURVEY_HISPANIC_B @"QID40"
#define SURVEY_RACE @"QID8"
#define SURVEY_RACE_B @"QID50"
#define SURVEY_RACE_A @"QID31"

#define SURVEY_EDUCATION @"QID9"
#define SURVEY_INCOME @"QID10"
#define SURVEY_ARMED_SERVICES @"QID11"
#define SURVEY_HEALTH_INSURANCE @"QID12"

#define SURVEY_RELATIONSHIP @"QID13"
#define SURVEY_RELATIONSHIP_YES @"QID42"
#define SURVEY_RELATIONSHIP_ANOTHER @"QID45"
#define SURVEY_RELATIONSHIP_NO @"QID41"

#define SURVEY_HOW_DID_YOU_HEAR @"QID57"

#define SURVEY_HEIGHT @"QID60"
#define SURVEY_WEIGHT @"QID61"
#define SURVEY_USER_ID @"QID62"

#define SURVEY_RESULTS @"SurveyResults"

#define R1_CLIENT_KEY_DEV @""
#define R1_CLIENT_KEY_PROD @""
#define R1_DEV_ID @""
#define R1_PROD_ID @""

#define PRIDE_API_AUTH @""

#ifndef SERVER_ENVIRONMENT
//define SERVER_ENVIRONMENT PRODUCTION OR DEVELOPMENT
#error
#endif


#if SERVER_ENVIRONMENT == PRODUCTION
#define SERVER_URL @"your_api_url"
#else
#define SERVER_URL @"your_api_url"
#endif

#if SERVER_ENVIRONMENT == PRODUCTION
#define IMPROVING_SURVEY_URL @"your_qualtics_url"
#else
#define IMPROVING_SURVEY_URL @"your_qualtics_url"
#endif


#if SERVER_ENVIRONMENT == PRODUCTION
#define PHYSICAL_SURVEY_URL @"your_qualtics_url"
#else
#define PHYSICAL_SURVEY_URL @"your_qualtics_url"
#endif

#if SERVER_ENVIRONMENT == PRODUCTION
#define SOCIAL_HEALTH_SURVEY_URL @"your_qualtics_url"
#else
#define SOCIAL_HEALTH_SURVEY_URL @"your_qualtics_url"
#endif

#if SERVER_ENVIRONMENT == PRODUCTION
#define MENTAL_HEALTH_SURVEY_URL @"your_qualtics_url"
#else
#define MENTAL_HEALTH_SURVEY_URL @"your_qualtics_url"
#endif

#if SERVER_ENVIRONMENT == PRODUCTION
#define AGE_SURVEY_URL @"your_qualtics_url"
#else
#define AGE_SURVEY_URL @"your_qualtics_url"
#endif


#if SERVER_ENVIRONMENT == PRODUCTION
#define QUALTRICS_DEMOGRAPHICS_SURVEY_URL @"your_qualtics_url"
#else
#define QUALTRICS_DEMOGRAPHICS_SURVEY_URL @"your_qualtics_url"
#endif

#if SERVER_ENVIRONMENT == PRODUCTION
#define QUALTRICS_PROFILE_SURVEY_URL @"your_qualtics_url"
#else
#define QUALTRICS_PROFILE_SURVEY_URL @"your_qualtics_url"
#endif



////////// Activities Identifiers //////////
#define TASK_COMMUNITY_CREATE_SCREEN_NAME @"CreateScreenNameTask"
#define TASK_COMMUNITY_CREATE_TOPIC @"CreateTopicTask"
#define TASK_COMMUNITY_REVIEW_TOPICS @"ReviewTopicsTask"
#define TASK_COMMUNITY_VOTE_ON_TOPICS @"VoteOnTopicsTask"
#define TASK_COMMUNITY_COMMENT_ON_TOPICS @"CommentOnTopicsTask"

@end
