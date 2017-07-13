// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

#import "NavigationViewController.h"
#import "SplitViewController.h"

@interface NavigationViewController ()
@property (nonatomic) FlutterViewController* flutterViewController;
@end

static NSString* const showSplitViewMethod = @"showSplitView";
static NSString* const showFullViewMethod = @"showFullView";
static NSString* const channel = @"samples.flutter.io/view";

@implementation NavigationViewController

  FlutterResult _flutterResult;

- (void) viewWillAppear:(BOOL)animated {
//  [self.navigationController setNavigationBarHidden:YES];
  [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
//  [self.navigationController setNavigationBarHidden:NO];
  [super viewWillDisappear:animated];
}
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
      NavigationViewController*  __weak weakSelf = self;
  if ([segue.identifier isEqualToString:@"FlutterViewControllerNavigationSegue"]) {
    FlutterViewController* flutterViewController = segue.destinationViewController;
    
    FlutterMethodChannel* methodChannel =
    [FlutterMethodChannel methodChannelWithName:channel
                                binaryMessenger:flutterViewController];
    

    [methodChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      if ([showSplitViewMethod isEqualToString:call.method]) {
        SplitViewController* splitViewController =
            [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"SplitView"];
        [weakSelf.navigationController pushViewController:splitViewController animated:NO];
      } else if ([showFullViewMethod isEqualToString:call.method]) {
        [self performSegueWithIdentifier:@"FullFlutterViewSegue" sender:self];
        
//        FlutterViewController* flutterViewController = [FlutterViewController alloc] init
//        FullViewController* fullViewController =
//            [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"FullView"];
//        [weakSelf.navigationController pushViewController:fullViewController animated:NO];
      } else {
        result(FlutterMethodNotImplemented);
      }
    }];
  } else if ([segue.identifier isEqualToString:@"FullFlutterViewSegue"]) {
    self.flutterViewController = segue.destinationViewController;
    [self.flutterViewController setInitialRoute:@"/fullScreenView"];
    
    FlutterMethodChannel* switchViewChannel =
        [FlutterMethodChannel methodChannelWithName:@"samples.flutter.io/platform_view"
                                binaryMessenger:self.flutterViewController];
    
    
    
    [switchViewChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      if ([@"switchView" isEqualToString:call.method]) {
        _flutterResult = result;
        FullNativeViewController* fullNativeViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"FullNativeView"];
        fullNativeViewController.counter = ((NSNumber*)call.arguments).intValue;
        fullNativeViewController.delegate = self;
        
        [weakSelf.navigationController pushViewController:fullNativeViewController animated:NO];
      } else {
        result(FlutterMethodNotImplemented);
      }
    }];
    
    
  }
}

- (void)didUpdateCounter:(int)counter {
  _flutterResult([NSNumber numberWithInt:counter]);
}

@end
