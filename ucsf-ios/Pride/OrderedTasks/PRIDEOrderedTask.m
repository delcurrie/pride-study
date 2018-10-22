//
//  PRIDEOrderedTask.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/14/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "PRIDEOrderedTask.h"

@implementation PRIDEOrderedTask

// Present the next step
- (ORKStep *)stepAfterStep:(nullable ORKStep *)step withResult:(ORKTaskResult * __nonnull)result{
    
    NSString *identifier = step.identifier;
    
    ORKStepResult *stepResult = [result stepResultForStepIdentifier:identifier];
    ORKChoiceQuestionResult *choiceQuestionResult = (ORKChoiceQuestionResult *)[stepResult firstResult];
    ORKBooleanQuestionResult *booleanQuestionResult = (ORKBooleanQuestionResult *)[stepResult firstResult];
    
    NSLog(@"The question choice is: %@", choiceQuestionResult);
    
    if([identifier isEqualToString:SURVEY_SEXUAL_ORIENTATION]){
        for (NSString *val in choiceQuestionResult.choiceAnswers){
            if([val isEqualToString:@"Another"]){
                return [self getStepWithIdentifier:SURVEY_SEXUAL_ORIENTATION_A];
            }
        }

        return [self getStepWithIdentifier:SURVEY_GENDER_IDENTITY];
    }
    else if([identifier isEqualToString:SURVEY_GENDER_IDENTITY]){
        for (NSString *val in choiceQuestionResult.choiceAnswers){
            if([val isEqualToString:@"Another"]){
                return [self getStepWithIdentifier:SURVEY_GENDER_IDENTITY_A];
            }
        }
        if(_showSexuality)
        {
            return nil;
            
        }
        
        return [self getStepWithIdentifier:SURVEY_BORN_IN_US];
    }
    else if([identifier isEqualToString:SURVEY_HISPANIC]){
        if([booleanQuestionResult.booleanAnswer isEqualToNumber:[NSNumber numberWithInt:1]]){
            return [self getStepWithIdentifier:SURVEY_HISPANIC_A];
        }
        
        return [self getStepWithIdentifier:SURVEY_RACE];
    }
    else if([identifier isEqualToString:SURVEY_HISPANIC_A]){
        for (NSString *val in choiceQuestionResult.choiceAnswers){
            if([val isEqualToString:@"Another"]){
                return [self getStepWithIdentifier:SURVEY_HISPANIC_B];
            }
        }
        
        return [self getStepWithIdentifier:SURVEY_RACE];
    }
    else if([identifier isEqualToString:SURVEY_RACE]){
        for (NSString *val in choiceQuestionResult.choiceAnswers){
            if([val isEqualToString:@"American Indian"]){
                return [self getStepWithIdentifier:SURVEY_RACE_A];
            }else if([val isEqualToString:@"Other Pacific Islander"]){
                return [self getStepWithIdentifier:SURVEY_RACE_B];
            }else if([val isEqualToString:@"Other Asian"]){
                return [self getStepWithIdentifier:SURVEY_RACE_B];
            }else if([val isEqualToString:@"Another"]){
                return [self getStepWithIdentifier:SURVEY_RACE_B];
            }
        }
        
        return [self getStepWithIdentifier:SURVEY_EDUCATION];
    }
    else if([identifier isEqualToString:SURVEY_RACE_A]){
        // Gets the race results
        stepResult = [result stepResultForStepIdentifier:SURVEY_RACE];
        choiceQuestionResult = (ORKChoiceQuestionResult *)[stepResult firstResult];
        
        NSLog(@"THE RACE RESULTS: %@", choiceQuestionResult);
        
        for (NSString *val in choiceQuestionResult.choiceAnswers){
            if([val isEqualToString:@"Other Pacific Islander"]){
                return [self getStepWithIdentifier:SURVEY_RACE_B];
            }else if([val isEqualToString:@"Other Asian"]){
                return [self getStepWithIdentifier:SURVEY_RACE_B];
            }else if([val isEqualToString:@"Another"]){
                return [self getStepWithIdentifier:SURVEY_RACE_B];
            }
        }
        
        return [self getStepWithIdentifier:SURVEY_EDUCATION];
    }
    else if([identifier isEqualToString:SURVEY_RELATIONSHIP]){
        if([booleanQuestionResult.booleanAnswer isEqualToNumber:[NSNumber numberWithInt:1]]){
            return [self getStepWithIdentifier:SURVEY_RELATIONSHIP_YES];
        }else{
            return [self getStepWithIdentifier:SURVEY_RELATIONSHIP_NO];
        }
    }
    else if([identifier isEqualToString:SURVEY_RELATIONSHIP_YES]){
        for (NSString *val in choiceQuestionResult.choiceAnswers){
            if([val isEqualToString:@"Another"]){
                return [self getStepWithIdentifier:SURVEY_RELATIONSHIP_ANOTHER];
            }
        }
        
      
        return [self getStepWithIdentifier:SURVEY_HOW_DID_YOU_HEAR];
    }
    else if([identifier isEqualToString:SURVEY_RELATIONSHIP_ANOTHER]){
        return [self getStepWithIdentifier:SURVEY_HOW_DID_YOU_HEAR];
    }
    
    return [super stepAfterStep:step withResult:result];
}

// Present the previous step
- (ORKStep *)stepBeforeStep:(nullable ORKStep *)step withResult:(ORKTaskResult * __nonnull)result{
    
    NSString *identifier = step.identifier;
    
    if([identifier isEqualToString:SURVEY_GENDER_IDENTITY]){
        return [self getStepWithIdentifier:SURVEY_SEXUAL_ORIENTATION];
    }
    else if([identifier isEqualToString:SURVEY_BORN_IN_US]){
        return [self getStepWithIdentifier:SURVEY_GENDER_IDENTITY];
    }
    else if([identifier isEqualToString:SURVEY_RACE]){
        return [self getStepWithIdentifier:SURVEY_HISPANIC];
    }
    else if([identifier isEqualToString:SURVEY_RACE_B]){
        return [self getStepWithIdentifier:SURVEY_RACE];
    }
    else if([identifier isEqualToString:SURVEY_RACE_A]){
        return [self getStepWithIdentifier:SURVEY_RACE];
    }
    else if([identifier isEqualToString:SURVEY_EDUCATION]){
        return [self getStepWithIdentifier:SURVEY_RACE];
    }
    else if([identifier isEqualToString:SURVEY_RELATIONSHIP_YES]){
        return [self getStepWithIdentifier:SURVEY_RELATIONSHIP];
    }
    else if([identifier isEqualToString:SURVEY_RELATIONSHIP_ANOTHER]){
        return [self getStepWithIdentifier:SURVEY_RELATIONSHIP_YES];
    }
    else if([identifier isEqualToString:SURVEY_RELATIONSHIP_NO]){
        return [self getStepWithIdentifier:SURVEY_RELATIONSHIP];
    }
    else if([identifier isEqualToString:SURVEY_HOW_DID_YOU_HEAR]){
        return [self getStepWithIdentifier:SURVEY_RELATIONSHIP];
    }
    else{
        return [super stepBeforeStep:step withResult:result];
    }
}


- (ORKStep *)getStepWithIdentifier:(NSString *)identifier{
    for(ORKStep *step in self.steps){
        if ([step.identifier isEqualToString:identifier]) {
            return step;
        }
    }
    
    return [self.steps firstObject];
}

@end
