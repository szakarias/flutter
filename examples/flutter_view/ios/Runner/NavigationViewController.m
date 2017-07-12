// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

#import "NavigationViewController.h"
#import "SplitViewController.h"

@interface NavigationViewController ()
@end

static NSString* const method = @"showSplitView";
static NSString* const channel = @"samples.flutter.io/view";

@implementation NavigationViewController

- (void) viewWillAppear:(BOOL)animated {
//  [self.navigationController setNavigationBarHidden:YES];
  [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
//  [self.navigationController setNavigationBarHidden:NO];
  [super viewWillDisappear:animated];
}
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"FlutterViewControllerNavigationSegue"]) {
    FlutterViewController* flutterViewController = segue.destinationViewController;
    
    FlutterMethodChannel* methodChannel =
    [FlutterMethodChannel methodChannelWithName:channel
                                binaryMessenger:flutterViewController];
    
    NavigationViewController*  __weak weakSelf = self;
    [methodChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      if ([method isEqualToString:call.method]) {
        SplitViewController* splitViewController =
            [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"SplitView"];
   //     [weakSelf.navigationController test];
        [weakSelf.navigationController pushViewController:splitViewController animated:NO];
      } else {
        result(FlutterMethodNotImplemented);
      }
    }];
  }
}

@end
