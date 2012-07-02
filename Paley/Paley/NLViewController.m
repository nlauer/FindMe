//
//  NLViewController.m
//  Paley
//
//  Created by Nick Lauer on 12-07-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLViewController.h"
#import "NLAppDelegate.h"
#import <AddressBook/AddressBook.h>

@interface NLViewController ()
@property (strong, nonatomic) NSMutableArray *phoneNumbers;
@property (strong, nonatomic) ABPeoplePickerNavigationController *picker;
@end

@implementation NLViewController
@synthesize phoneNumbers = _phoneNumbers;
@synthesize picker = _picker;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _phoneNumbers = [[NSMutableArray alloc] init];}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self displayPeoplePickerNavigationController:[NSNumber numberWithBool:NO]];
}

- (void)displayPeoplePickerNavigationController:(NSNumber*)animated
{
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [picker setDelegate:self];
    self.picker = picker;
    [self presentViewController:picker animated:[animated boolValue] completion:nil];
    picker.navigationBar.topItem.title = @"Come Here!";
    [picker.navigationBar setBarStyle:UIBarStyleBlack];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(donePickingPeople)];
    [viewController.navigationItem setRightBarButtonItem:doneButton animated:NO]; 
}

- (void)donePickingPeople
{
    [self sendTextMessage];
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    //never gets called
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                     kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }
    
    UIView *view = peoplePicker.topViewController.view;
    UITableView *tableView = nil;
    for(UIView *uv in view.subviews)
    {
        if([uv isKindOfClass:[UITableView class]])
        {
            tableView = (UITableView*)uv;
            break;
        }
    }
    
    if(tableView != nil)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[tableView indexPathForSelectedRow]];
        cell.accessoryType == UITableViewCellAccessoryNone ? [_phoneNumbers addObject:phone] : [_phoneNumbers removeObject:phone];
        cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryNone ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        [cell setSelected:NO animated:YES];
    }
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)sendTextMessage {
    NSString *gooleMapsString = [((NLAppDelegate*)[[UIApplication sharedApplication] delegate]) googleMapsString];
    NSString *textString = [NSString stringWithFormat:@"Come here! %@", gooleMapsString];
    [self sendSMS:textString recipientList:_phoneNumbers];
}

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = bodyOfMessage;    
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        [_picker presentModalViewController:controller animated:YES];
    }    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [_picker dismissModalViewControllerAnimated:YES];
}
@end
