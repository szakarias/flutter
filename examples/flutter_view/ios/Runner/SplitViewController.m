// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.Copyright © 2017 The Chromium Authors. All rights reserved.


#import <Foundation/Foundation.h>

#import "SplitViewController.h"
#import "NativeViewController.h"

@interface SplitViewController ()

@property (nonatomic) NativeViewController* nativeViewController;
@property (nonatomic) FlutterViewController* flutterViewController;
@property (nonatomic) FlutterBasicMessageChannel* messageChannel;
@end

static NSString* const emptyString = @"";
static NSString* const ping = @"ping";
static NSString* const channel = @"samples.flutter.io/increment";


static NSString* const method = @"backPressed";
static NSString* const methodChannelName = @"samples.flutter.io/back";

@implementation SplitViewController

- (NSString*) messageName {
  return channel;
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {

  if ([segue.identifier isEqualToString: @"NativeViewControllerSegue"]) {
    self.nativeViewController = segue.destinationViewController;
    self.nativeViewController.delegate = self;
  }

  if ([segue.identifier isEqualToString:@"FlutterViewControllerSegue"]) {
    self.flutterViewController = segue.destinationViewController;
    [self.flutterViewController setInitialRoute:@"/splitView"];

    self.messageChannel = [FlutterBasicMessageChannel messageChannelWithName:channel
                                                             binaryMessenger:self.flutterViewController
                                                                       codec:[FlutterStringCodec sharedInstance]];

    SplitViewController*  __weak weakSelf = self;
    [self.messageChannel setMessageHandler:^(id message, FlutterReply reply) {
      [weakSelf.nativeViewController didReceiveIncrement];
      reply(emptyString);
    }];
  
    
    FlutterMethodChannel* methodChannel =
    [FlutterMethodChannel methodChannelWithName:methodChannelName
                                binaryMessenger:self.flutterViewController];
    
    [methodChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      if ([method isEqualToString:call.method]) {
        [weakSelf.navigationController popViewControllerAnimated:NO];
      } else {
        result(FlutterMethodNotImplemented);
      }
    }];
  
  }
  UIViewController* c = [UIApplication sharedApplication].keyWindow.rootViewController;
//  FlutterNavigationController* f = self.navigationController;
  
  
  
  
}

- (void)didTapIncrementButton {
  [self.messageChannel sendMessage:ping];

  }

@end
