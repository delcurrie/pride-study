//
//  PRIDEConsentOrderedTask.m
//  pride
//
//  Created by Patrick Krabeepetcharat on 5/19/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "PRIDEConsentOrderedTask.h"

@implementation PRIDEConsentOrderedTask

- (ORKStep *)stepAfterStep:(nullable ORKStep *)step withResult:(ORKTaskResult * __nonnull)result{
    
//    NSString *ident = step.identifier;
//    NSLog(@"The identifier: %@", ident);
//    
//    ORKStepResult *stepResult = [result stepResultForStepIdentifier:ident];
//    ORKQuestionResult *questionResult = (ORKQuestionResult *)[stepResult firstResult];
//    NSLog(@"The Answer: %@", questionResult.answer);
    
    return [super stepAfterStep:step withResult:result];
}

@end
