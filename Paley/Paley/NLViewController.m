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
@property (nonatomic, assign) CFArrayRef arrayOfPeople;
@property (strong, nonatomic) NSMutableArray *selectedIndexes;
@end

@implementation NLViewController
@synthesize navItem = _navItem;
@synthesize navBar = _navBar;
@synthesize tableView = _tableView;
@synthesize phoneNumbers = _phoneNumbers;
@synthesize arrayOfPeople = _arrayOfPeople;
@synthesize selectedIndexes = _selectedIndexes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        self.arrayOfPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByLastName);
        self.selectedIndexes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _phoneNumbers = [[NSMutableArray alloc] init];
     UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(donePickingPeople)];
    [self.navItem setRightBarButtonItem:doneButton];
    [self.navBar setBarStyle:UIBarStyleBlack];
    self.navItem.title = @"Come Here!";
}

- (void)viewDidUnload
{
    [self.tableView setDelegate:nil];
    [self.tableView setDataSource:nil];
    [self setTableView:nil];
    [self setNavBar:nil];
    [self setNavItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)donePickingPeople
{
    if ([((NLAppDelegate*)[[UIApplication sharedApplication] delegate]) googleMapsString]) {
        [self sendTextMessage];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Undeterminable Location" 
                                                        message:@"Check your connection settings" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark Sending the SMS

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
        [self presentModalViewController:controller animated:YES];
    }    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    return [(__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByLastName) count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    int index = indexPath.row;
    ABRecordRef person = CFArrayGetValueAtIndex(self.arrayOfPeople, index);
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                         kABPersonFirstNameProperty);
    NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                        kABPersonLastNameProperty);
    NSString *name = nil;
    if (firstName && lastName) {
        name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    } else if (firstName) {
        name = [NSString stringWithFormat:@"%@", firstName];
    } else if (lastName) {
        name = [NSString stringWithFormat:@"%@", lastName];
    } else {
        name = @"Unavailable";
    }
    cell.accessoryType = [_selectedIndexes containsObject:indexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.text = name;
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    int index = indexPath.row;
    ABRecordRef person = CFArrayGetValueAtIndex(self.arrayOfPeople, index);
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                     kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    } 
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [_selectedIndexes addObject:indexPath];
        if (phone) {
            [_phoneNumbers addObject:phone];
        }
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [_selectedIndexes removeObject:indexPath];
        if (phone) {
            [_phoneNumbers removeObject:phone];
        }
    } 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
@end
