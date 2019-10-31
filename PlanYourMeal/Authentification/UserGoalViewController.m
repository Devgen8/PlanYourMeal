//
//  UserGoalViewController.m
//  PlanYourMeal
//
//  Created by мак on 24/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

#import "UserGoalViewController.h"
#import "UserDataViewController.h"
@import FirebaseAuth;
@import Firebase;
@import FirebaseFirestore;

@interface UserGoalViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *goalButtons;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property int goal;

@property FIRFirestore *db;

@end

@implementation UserGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _db = [FIRFirestore firestore];
    _goal = -1;
    for(UIButton* button in _goalButtons) {
        [self designGoalButton:button];
    }
    [self designNextButton:_nextButton];
}

- (void)designGoalButton:(UIButton *)button {
    button.backgroundColor = UIColor.systemGreenColor;
    button.layer.cornerRadius = 25.0;
    button.tintColor = UIColor.whiteColor;
}

- (void)designNextButton:(UIButton *)button {
    button.layer.borderWidth = 2;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.cornerRadius = 25.0;
    button.tintColor = UIColor.blackColor;
}
- (void)changeBorderOfButton:(int)index1 and:(int)index2 {
    UIButton *button = [_goalButtons objectAtIndex: index1];
    button.layer.borderWidth = 0;
    button = [_goalButtons objectAtIndex: index2];
    button.layer.borderWidth = 0;
}
- (IBAction)loseWeightTapped:(UIButton *)sender {
    sender.layer.borderWidth = 2;
    sender.layer.borderColor = [UIColor blueColor].CGColor;
    [self changeBorderOfButton:1 and:2];
    _goal = 0;
}
- (IBAction)beHealthyTapped:(UIButton *)sender {
    sender.layer.borderWidth = 2;
    sender.layer.borderColor = [UIColor blueColor].CGColor;
    [self changeBorderOfButton:0 and:2];
    _goal = 1;
}
- (IBAction)gainWeightTapped:(UIButton *)sender {
    sender.layer.borderWidth = 2;
    sender.layer.borderColor = [UIColor blueColor].CGColor;
    [self changeBorderOfButton:0 and:1];
    _goal = 2;
}
- (IBAction)nextTapped:(UIButton *)sender {
    if(_goal == -1) {
        _errorLabel.alpha = 1;
        _errorLabel.text = @"Please choose your goal";
        return;
    }
    NSDictionary *goalValue = @{@0:@"Lose weight", @1:@"Be healthy", @2:@"Gain weight"};
    NSString *pathToDoc = [NSString stringWithFormat:@"/%@/%@/%@",@"users", [FIRAuth auth].currentUser.uid, @"Additional info"];
    [[[_db collectionWithPath:pathToDoc] documentWithPath:@"Goal"] setData:@{
      @"goal": goalValue[@(_goal)]
    } completion:^(NSError * _Nullable error) {
      if (error != nil) {
        NSLog(@"Error writing document: %@", error);
      } else {
        NSLog(@"Document successfully written!");
      }
    }];
    [self presentViewController:[[UserDataViewController alloc] init] animated:YES completion:nil];
}
@end
