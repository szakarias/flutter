// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

#import "NavigationViewController.h"
#import "MainViewController.h"

static NSString* const method = @"switchView";
static NSString* const channel = @"samples.flutter.io/platform_view";

@implementation NavigationViewController

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"FlutterViewControllerNavigationSegue"]) {
    FlutterViewController* flutterViewController = segue.destinationViewController;
    
    FlutterMethodChannel* methodChannel =
    [FlutterMethodChannel methodChannelWithName:@"samples.flutter.io/platform_view"
                                binaryMessenger:flutterViewController];
    
    NavigationViewController*  __weak weakSelf = self;
    [methodChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      if ([@"switchView" isEqualToString:call.method]) {
        MainViewController* mainViewController =
            [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"MainView"];
        [weakSelf.navigationController pushViewController:mainViewController animated:NO];
      } else {
        result(FlutterMethodNotImplemented);
      }
    }];
  }
}

@end
