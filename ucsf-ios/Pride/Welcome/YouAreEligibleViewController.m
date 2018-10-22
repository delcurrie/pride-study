//
//  YouAreEligibleViewController.m
//  Pride
//
//  Created by Patrick Krabeepetcharat on 5/8/15.
//  Copyright (c) 2015 Patrick Krabeepetcharat. All rights reserved.
//

#import "YouAreEligibleViewController.h"

@interface YouAreEligibleViewController ()
{
    bool sharingAllowed;
}

@end

@implementation YouAreEligibleViewController

ORKTaskViewController *taskViewController;

- (void)viewDidAppear:(BOOL)animated{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"shouldStartConsent"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shouldStartConsent"];
        
        [self showConsent];
    }
    
    // RadiumOne Tracking
    [[R1Emitter sharedInstance] emitScreenViewWithDocumentTitle:@"You are eligible"
                                             contentDescription:nil
                                            documentLocationUrl:nil
                                               documentHostName:nil
                                                   documentPath:nil
                                                      otherInfo:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"You are eligible"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Stylize the "Join Study" button
    self.btn_startConsent.layer.cornerRadius = 5.0f;//any float value
    self.btn_startConsent.layer.borderWidth = 2.0f;//any float value
    self.btn_startConsent.layer.borderColor = [[UIColor primaryColor]CGColor];
    [self.btn_startConsent setTitleColor:[UIColor primaryColor] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startConsent:(id)sender {
    [self showConsent];
}

- (void)showConsent{
    NSURL *url;
    
    ORKConsentSignature*    signature = [ORKConsentSignature signatureForPersonWithTitle:@"Participant"
                                                                        dateFormatString:nil
                                                                              identifier:@"participant"];
    
    self.document = [ORKConsentDocument new];
    self.document.title = @"PRIDE Study";
    self.document.signaturePageTitle = @"Signature";
    [self.document addSignature:signature];
    
    // Set the review document
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-review-simple" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    self.document.htmlReviewContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionOverview =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeOverview];
    sectionOverview.title = @"Welcome";
    sectionOverview.summary = @"Researchers at the University of California, San Francisco are using this app to enable LGBTQ and other sexual and gender minority people to help design research studies for their own communities.\n\n The info collected will help create a long-term study which will help better understand the conditions and experiences that influence the physical and mental health of LGBTQ people and other sexual and gender minorities.\n\n Get started to learn more";
    sectionOverview.customLearnMoreButtonTitle = @"Learn More";
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-welcome" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionOverview.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionUnderstanding =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionUnderstanding.title = @"We’ll Test Your Understanding";
    sectionUnderstanding.summary = @"After you complete this walkthrough about the study, there will be a short quiz at the end to confirm your understanding.";
    sectionUnderstanding.customLearnMoreButtonTitle = @"Learn More";
    sectionUnderstanding.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"01_We’ll Test Your Understanding" withExtension:@"mp4"];
    sectionUnderstanding.customImage = [UIImage imageNamed:@"01_Well-Test-Your-Understanding"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-understanding" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionUnderstanding.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionInsight =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionInsight.title = @"Your Insight";
    sectionInsight.summary = @"Because we want to learn about your health questions and priorities, we will ask you to participate in a community discussion forum. Doing so will help us design a nationwide long-term health study.";
    sectionInsight.customLearnMoreButtonTitle = @"Learn More";
    sectionInsight.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"02_Your Insight" withExtension:@"mp4"];
    sectionInsight.customImage = [UIImage imageNamed:@"02_Your-Insight"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-insights" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionInsight.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionSurveys =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionSurveys.title = @"Surveys";
    sectionSurveys.summary = @"We will ask you to complete brief surveys about a variety of topics including your identities, your health, and your behaviors. You may always choose not to answer questions that make you uncomfortable.";
    sectionSurveys.customLearnMoreButtonTitle = @"Learn More";
    sectionSurveys.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"03_Surveys" withExtension:@"mp4"];
    sectionSurveys.customImage = [UIImage imageNamed:@"03_Surveys"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-surveys" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionSurveys.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionSensorData =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionSensorData.title = @"Sensor Data";
    sectionSensorData.summary = @"This study will gather sensor data from your iPhone and other personal devices with your permission.";
    sectionSensorData.customLearnMoreButtonTitle = @"Learn More";
    sectionSensorData.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"04_Sensor Data" withExtension:@"mp4"];
    sectionSensorData.customImage = [UIImage imageNamed:@"04_Sensor-Data"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-sensor" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionSensorData.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionDataUse =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionDataUse.title = @"Data Use";
    sectionDataUse.summary = @"We will not share your personal identifiable information with any commercial third parties, such as advertisers.";
    sectionDataUse.customLearnMoreButtonTitle = @"Learn More";
    sectionDataUse.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"05_Data Use" withExtension:@"mp4"];
    sectionDataUse.customImage = [UIImage imageNamed:@"05_Data-Use"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-data" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionDataUse.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionTimeCommitment =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionTimeCommitment.title = @"Time Commitment";
    sectionTimeCommitment.summary = @"Your participation in this study will average approximately 15 minutes per week for 6-9 months. You can adjust your level of participation, as you desire.";
    sectionTimeCommitment.customLearnMoreButtonTitle = @"Learn More";
    sectionTimeCommitment.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"06_Time Commitment" withExtension:@"mp4"];
    sectionTimeCommitment.customImage = [UIImage imageNamed:@"06_Time-Commitment"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-time" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionTimeCommitment.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionPotentialBenefits =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom ];
    sectionPotentialBenefits.title = @"Potential Benefits";
    sectionPotentialBenefits.summary = @"Many participants will experience personal satisfaction knowing that they are contributing to the planning of a national LGBTQ health study. However, we cannot guarantee that you will experience benefit from participating.";
    sectionPotentialBenefits.customLearnMoreButtonTitle = @"Learn More";
    sectionPotentialBenefits.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"07_Potential Benefits" withExtension:@"mp4"];
    sectionPotentialBenefits.customImage = [UIImage imageNamed:@"07_Potential-Benefits"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-benefits" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionPotentialBenefits.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionProtectingYourPrivacy =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionProtectingYourPrivacy.title = @"Protecting Your Privacy";
    sectionProtectingYourPrivacy.summary = @"To protect your privacy, information that identifies you (e.g., name, email address) is stored in a physically and digitally separate secure database from your study information.";
    sectionProtectingYourPrivacy.customLearnMoreButtonTitle = @"Learn More";
    sectionProtectingYourPrivacy.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"08_Protecting Your Privacy" withExtension:@"mp4"];
    sectionProtectingYourPrivacy.customImage = [UIImage imageNamed:@"08_Protecting-Your-Privacy"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-privacy" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionProtectingYourPrivacy.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionSecureDatabases =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
    sectionSecureDatabases.title = @"Secure Databases";
    sectionSecureDatabases.summary = @"Your data will be stored in military-grade secure databases on secure servers that use procedures to safeguard your information and prevent unauthorized access.";
    sectionSecureDatabases.customLearnMoreButtonTitle = @"Learn More";
    sectionSecureDatabases.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"09_Secure Databases" withExtension:@"mp4"];
    sectionSecureDatabases.customImage = [UIImage imageNamed:@"09_Secure-Databases"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-databases" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionSecureDatabases.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    ORKConsentSection *sectionWithdrawing =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom ];
    sectionWithdrawing.title = @"Withdrawing";
    sectionWithdrawing.summary = @"Your participation in this study is voluntary. You may withdraw your consent and stop your participation at any time.";
    sectionWithdrawing.customLearnMoreButtonTitle = @"Learn More";
    sectionWithdrawing.customAnimationURL = [[NSBundle mainBundle] URLForResource:@"10_Withdrawing" withExtension:@"mp4"];
    sectionWithdrawing.customImage = [UIImage imageNamed:@"10_Withdrawing"];
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-withdrawing" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    sectionWithdrawing.htmlContent = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    
    
    self.document.sections = @[sectionOverview, sectionUnderstanding, sectionInsight, sectionSurveys, sectionSensorData, sectionDataUse, sectionTimeCommitment, sectionPotentialBenefits, sectionProtectingYourPrivacy, sectionSecureDatabases, sectionWithdrawing];
    
    ORKVisualConsentStep *visualStep =
    [[ORKVisualConsentStep alloc] initWithIdentifier:@"VisualConsentIdentifier"
                                            document:self.document];
    
    // HTML content for sharing step
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                  pathForResource:@"consent-sharing" ofType:@"html" inDirectory:@"HTMLContent/pages"]];
    ORKConsentSharingStep *sharingStep =
    [[ORKConsentSharingStep alloc] initWithIdentifier:@"ConsentSharingIdentifier"
                         investigatorShortDescription:@"UCSF"
                          investigatorLongDescription:@"UCSF and its partners"
                        localizedLearnMoreHTMLContent:[[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil]];
    
    ORKConsentReviewStep *reviewStep =
    [[ORKConsentReviewStep alloc] initWithIdentifier:@"ConsentReviewIdentifier"
                                           signature:self.document.signatures[0]
                                          inDocument:self.document];
    reviewStep.text = @"";
    reviewStep.reasonForConsent = @"By agreeing you confirm that you read the information and that you wish to take part in this research study.";
    
    
    // The quiz steps
    /////////////////////////////////////////////////////////////////////////////////////////
    ORKAnswerFormat *formatAnswer;
    
    ORKInstructionStep *quizInstruction = [[ORKInstructionStep alloc] initWithIdentifier:@"instruction"];
    quizInstruction.title = @"Comprehension";
    quizInstruction.text = @"Let's do a quick and simple test of your understanding of this study.";
    
    NSArray *choicesText = [NSArray arrayWithObjects:
                            [ORKTextChoice choiceWithText:@"To help design research studies for the LGBTQ communities" value:@"help"],
                            [ORKTextChoice choiceWithText:@"To understand why people are LGBTQ" value:@"understand"],nil];
    formatAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:choicesText];
    ORKQuestionStep *quizPurpose =
    [ORKQuestionStep questionStepWithIdentifier:@"quizPurpose"
                                          title:@"What is the purpose of this study?"
                                         answer:formatAnswer];
    [quizPurpose setOptional:NO];
    
    formatAnswer = [ORKBooleanAnswerFormat new];
    ORKQuestionStep *quizSurvey =
    [ORKQuestionStep questionStepWithIdentifier:@"quizSurvey"
                                          title:@"I must answer all survey questions."
                                         answer:formatAnswer];
    [quizSurvey setOptional:NO];
    
    formatAnswer = [ORKBooleanAnswerFormat new];
    ORKQuestionStep *quizParticipation =
    [ORKQuestionStep questionStepWithIdentifier:@"quizParticipation"
                                          title:@"I can stop participating in the study if I would like."
                                         answer:formatAnswer];
    [quizParticipation setOptional:NO];
    
    formatAnswer = [ORKBooleanAnswerFormat new];
    ORKQuestionStep *quizEmergency =
    [ORKQuestionStep questionStepWithIdentifier:@"quizEmergency"
                                          title:@"If I have a medical emergency, I should use this app to contact a doctor."
                                         answer:formatAnswer];
    [quizEmergency setOptional:NO];
    
    formatAnswer = [ORKBooleanAnswerFormat new];
    ORKQuestionStep *quizResearch =
    [ORKQuestionStep questionStepWithIdentifier:@"quizResearch"
                                          title:@"This app is a medical research study."
                                         answer:formatAnswer];
    [quizResearch setOptional:NO];
    
    ORKInstructionStep *greatJobInstruction = [[ORKInstructionStep alloc] initWithIdentifier:@"greatJob"];
    greatJobInstruction.title = @"Great Job!";
    greatJobInstruction.text = @"You answered all the questions correctly. You will now be presented with the consent form to sign. Tap Next to continue.";
    greatJobInstruction.image = [UIImage imageNamed:@"Completion-Check"];
    
    
    PRIDEConsentOrderedTask *task =
    [[PRIDEConsentOrderedTask alloc] initWithIdentifier:@"ConsentTaskIdentifier"
                                                  steps:@[visualStep, sharingStep, quizInstruction, quizPurpose, quizSurvey, quizParticipation, quizEmergency, quizResearch, greatJobInstruction, reviewStep]];
    
    taskViewController =
    [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    [taskViewController setShowsProgressInNavigationBar:NO];
    taskViewController.delegate = self;
    [taskViewController.navigationBar.topItem setTitle:@"Consent"];
    taskViewController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor grayColor]};

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController pushViewController:taskViewController animated:YES];
}

#pragma mark TaskViewController Delegates

- (void)taskViewController:(ORKTaskViewController * __nonnull)taskViewController stepViewControllerWillAppear:(ORKStepViewController * __nonnull)stepViewController{
    
    // Logic for testing if the quiz is passed
    // If We're done with the quiz and about to go into the sharing step
    if ([stepViewController.step.identifier isEqualToString:@"greatJob"]){
        ORKStepResult *resultPurpose = (ORKStepResult*)[taskViewController.result resultForIdentifier:@"quizPurpose"];
        ORKChoiceQuestionResult *questionResultPurpose = (ORKChoiceQuestionResult *)[resultPurpose firstResult];
        
        ORKStepResult *resultSurvey = (ORKStepResult*)[taskViewController.result resultForIdentifier:@"quizSurvey"];
        ORKBooleanQuestionResult *questionResultSurvey = (ORKBooleanQuestionResult *)[resultSurvey firstResult];
        
        ORKStepResult *resultParticipation = (ORKStepResult*)[taskViewController.result resultForIdentifier:@"quizParticipation"];
        ORKBooleanQuestionResult *questionResultParticipation = (ORKBooleanQuestionResult *)[resultParticipation firstResult];
        
        ORKStepResult *resultEmergency = (ORKStepResult*)[taskViewController.result resultForIdentifier:@"quizEmergency"];
        ORKBooleanQuestionResult *questionResultEmergency = (ORKBooleanQuestionResult *)[resultEmergency firstResult];
        
        ORKStepResult *resultResearch = (ORKStepResult*)[taskViewController.result resultForIdentifier:@"quizResearch"];
        ORKBooleanQuestionResult *questionResultResearch = (ORKBooleanQuestionResult *)[resultResearch firstResult];
        
        NSLog(@"Result Purpose: %@", resultPurpose);
        NSLog(@"Question Result Purpose: %@", questionResultPurpose);
        
        if([[questionResultPurpose.choiceAnswers firstObject] isEqualToString:@"help"] &&
           [questionResultSurvey.booleanAnswer isEqualToNumber:[NSNumber numberWithInt:0]] &&
           [questionResultParticipation.booleanAnswer isEqualToNumber:[NSNumber numberWithInt:1]]&&
           [questionResultEmergency.booleanAnswer isEqualToNumber:[NSNumber numberWithInt:0]]&&
           [questionResultResearch.booleanAnswer isEqualToNumber:[NSNumber numberWithInt:1]]){
            NSLog(@"PASSED THE QUIZ");
        }else{
            NSLog(@"FAILED THE QUIZ");
            
            // Go to fail screen if failed quiz
            [self performSegueWithIdentifier:@"FailedQuiz" sender:self];
        }
    }
    
    // Show the Nav bar
    [taskViewController.navigationBar setHidden:NO];
}

- (void)taskViewController:(ORKTaskViewController * __nonnull)taskViewController didChangeResult:(ORKTaskResult * __nonnull)result{
    ORKStepResult *stepResult;
    stepResult = [result stepResultForStepIdentifier:@"ConsentSharingIdentifier"];
    
    ORKChoiceQuestionResult *questionResult = (ORKChoiceQuestionResult*)[stepResult.results firstObject];
    NSArray *answer = questionResult.choiceAnswers;
    
    if([[answer firstObject] isEqual:[NSNumber numberWithInt:1]]){
        sharingAllowed = YES;
    }else if([[answer firstObject] isEqual:[NSNumber numberWithInt:0]]){
        sharingAllowed = NO;
    }
}

- (void) taskViewController:(ORKTaskViewController * __nonnull)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)error{
    
    ORKConsentSignatureResult *signatureResult =
    (ORKConsentSignatureResult *)[[[taskViewController result] stepResultForStepIdentifier:@"ConsentReviewIdentifier"] firstResult];
    [signatureResult applyToDocument:self.document];
//    NSData* imageData = UIImagePNGRepresentation(signatureResult.signature.signatureImage);
//    NSData* myEncodedImageData = [NSKeyedArchiver archivedDataWithRootObject:imageData];
//    [[NSUserDefaults standardUserDefaults] setObject:myEncodedImageData forKey:@"signature"];
    [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(signatureResult.signature.signatureImage) forKey:@"signature"];

    [[NSUserDefaults standardUserDefaults] synchronize];

    if (reason == 1) {
        // Canceled the consent
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if (reason == 2){
        // Finished Consent
        
        // Save sharing option
        [[NSUserDefaults standardUserDefaults] setBool:sharingAllowed forKey:USER_SHARING_ENABLED];
        
        // Save the PDF to disk
        [self.document makePDFWithCompletionHandler:^(NSData *pdfData, NSError *error) {
            if(pdfData){
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = [paths objectAtIndex:0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"consent.pdf"];
                BOOL savedPDF = [pdfData writeToFile:filePath atomically:YES];
                
                if(savedPDF){
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ConsentFormSaved"];
                    NSLog(@"Save succeeded");
                }else{
                    NSLog(@"Save failed");
                }
            }
        }];
        
        // Save the registered name as user defaults
        NSString *firstName = signatureResult.signature.givenName;
        NSString *lastName = signatureResult.signature.familyName;
        
        [[NSUserDefaults standardUserDefaults] setObject:firstName forKey:USER_FIRST_NAME_IDENTIFIER];
        [[NSUserDefaults standardUserDefaults] setObject:lastName forKey:USER_LAST_NAME_IDENTIFIER];
    }
    
    
    //  if no signature (no consent result) then assume the user failed the quiz
    if (signatureResult != nil && signatureResult.signature.requiresName && (signatureResult.signature.givenName && signatureResult.signature.familyName)){
        NSLog(@"Performing the segue");
        [self performSegueWithIdentifier:@"WhatToExpect" sender:self];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    // quit reason = 1
    // finish reason = 2
}

// This isn't being called for some reason
- (void)taskViewController:(ORKTaskViewController * __nonnull)taskViewController learnMoreForStep:(ORKStepViewController * __nonnull)stepViewController{
    NSLog(@"LEARN MORE");
}


@end
