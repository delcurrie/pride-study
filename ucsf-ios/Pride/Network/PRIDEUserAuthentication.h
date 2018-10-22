//
//  PRIDEAuthenticateUser.h
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/22/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>
#import <AFNetworking/AFNetworking.h>

@interface PRIDEUserAuthentication : NSObject

+ (NSString *)createUserWithId:(NSString *)id;

@end
