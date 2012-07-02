//
//  NLAppDelegate.h
//  Paley
//
//  Created by Nick Lauer on 12-07-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class NLViewController;

@interface NLAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NLViewController *viewController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString *googleMapsString;

@end
