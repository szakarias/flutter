// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

@protocol FullNativeViewControllerDelegate <NSObject>
- (void)didUpdateCounter:(int)counter;
@end


@interface FullNativeViewController : UIViewController
@property (strong, nonatomic) id<FullNativeViewControllerDelegate> delegate;
@property int counter;
@end
