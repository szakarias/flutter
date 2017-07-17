// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "FullNativeViewController.h"
#import <UIKit/UIButton.h>
#import <UIKit/UIBarButtonItem.h>
#import <UIKit/UIBarCommon.h>
#import <UIKit/UINavigationController.h>
#import <UIKit/UINavigationBar.h>


@interface FullNativeViewController ()
@property (weak, nonatomic) IBOutlet UIView *navigationBar;
@property (weak, nonatomic) IBOutlet UILabel *incrementLabel;
@end

@implementation FullNativeViewController

- (void) viewWillAppear:(BOOL)animated {
//  [self.navigationBar setBackgroundColor:[UIColor colorWithCGColor:<#(nonnull CGColorRef)#>]]
//  [self.navigationController setNavigationBarHidden:NO];
//  [self.navigationController.navigationBar setBarTintColor:UIColor.darkGrayColor];
//  
  [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
  [self.navigationController setNavigationBarHidden:YES];
  [self.delegate didUpdateCounter:self.counter];
  [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setIncrementLabelText];
}

- (IBAction)handleIncrement:(id)sender {
  self.counter++;
  [self setIncrementLabelText];
}

- (IBAction)switchToFlutterView:(id)sender {
  [self.navigationController popViewControllerAnimated:NO];
}

- (void)setIncrementLabelText {
  NSString* text = [NSString stringWithFormat:@"Button tapped %d %@.",
                    self.counter,
                    (self.counter == 1) ? @"time" : @"times"];
  self.incrementLabel.text = text;
}

@end



