//
//  NLViewController.h
//  Paley
//
//  Created by Nick Lauer on 12-07-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <AddressBookUI/AddressBookUI.h>

@interface NLViewController : UIViewController <MFMessageComposeViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate>
@end
