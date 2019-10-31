//
//  UserDataViewController.m
//  PlanYourMeal
//
//  Created by мак on 27/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

#import "UserDataViewController.h"
#import "UserGoalViewController.h"
#import "PlanYourMeal-Swift.h"
@import FirebaseFirestore;
@import FirebaseAuth;

@interface UserDataViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderChooser;
@property (weak, nonatomic) IBOutlet UITextField *heightTextField;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property FIRFirestore *db;
@end

@implementation UserDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _db = [FIRFirestore firestore];
    [self designTextField:_heightTextField];
    [self designTextField:_weightTextField];
    [self designNextButton:_nextButton];
}

- (void)designNextButton:(UIButton *)button {
    button.layer.borderWidth = 2;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.cornerRadius = 25.0;
    button.tintColor = UIColor.blackColor;
}

- (void)designTextField:(UITextField *)textField {
    CALayer * bottomLine = [[CALayer alloc] init];
    bottomLine.frame = CGRectMake(0, textField.frame.size.height - 2, textField.frame.size.width, 2);
    
    bottomLine.backgroundColor = UIColor.systemGreenColor.CGColor;
    
    textField.borderStyle = NO;
    
    [textField.layer addSublayer:bottomLine];
    
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName:UIColor.grayColor}];
}

- (NSString *)validateFields {
    if ([_heightTextField.text  isEqual: @""] || [_weightTextField.text  isEqual: @""]) {
        return @"Please fill in all fields";
    }
    if ([_heightTextField.text intValue] < 10 || [_heightTextField.text intValue] > 230) {
        return @"Please change your height";
    }
    if ([_weightTextField.text intValue] < 10 || [_weightTextField.text intValue] > 300) {
        return @"Please change your weight";
    }
    return @"";
}

- (IBAction)nextTapped:(UIButton *)sender {
    NSString *answer = [self validateFields];
    if (![answer  isEqual: @""]) {
        _errorLabel.text = answer;
        _errorLabel.alpha = 1;
        return;
    }
    NSString *gender = _genderChooser.selectedSegmentIndex ? @"Female" : @"Male";
    NSString *pathToDoc = [NSString stringWithFormat:@"/%@/%@/%@",@"users", [FIRAuth auth].currentUser.uid, @"Additional info"];
    [[[_db collectionWithPath:pathToDoc] documentWithPath:@"Body type"] setData:@{
      @"gender": gender,
      @"height": _heightTextField.text,
      @"weight": _weightTextField.text
    } completion:^(NSError * _Nullable error) {
      if (error != nil) {
        NSLog(@"Error writing document: %@", error);
      } else {
        NSLog(@"Document successfully written!");
      }
    }];
    [self presentViewController:[[AllergensViewController alloc] init] animated:YES completion:nil];
}

@end
