//
//  DHAppDelegate.m
//  Download History
//
//  Created by Ferruccio Vitale on 22/01/13.
//  Copyright (c) 2013 Ferruccio Vitale. All rights reserved.
//

#import "DHAppDelegate.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

#define SQL_SELECT              @"SELECT * \
                                  FROM LSQuarantineEvent  \
                                  WHERE LSQuarantineDataURLString LIKE ? \
                                  ORDER BY LSQuarantineTimeStamp DESC"
#define SQL_DELETE              @"DELETE FROM LSQuarantineEvent \
                                  WHERE LSQuarantineEventIdentifier = ?"
#define KEY_ID                  @"LSQuarantineEventIdentifier"
#define KEY_URL                 @"LSQuarantineDataURLString"
#define KEY_ORIGINAL_URL        @"LSQuarantineOriginURLString"
#define KEY_DATE                @"LSQuarantineTimeStamp"
#define KEY_AGENT               @"LSQuarantineAgentName"
#define KEY_TITLE               @"LSQuarantineOriginTitle"
#define KEY_SENDER_NAME         @"LSQuarantineSenderName"
#define KEY_SENDER_ADDRESS      @"LSQuarantineSenderAddress"
#define KEY_SELECTED            @"selected"
#define NotEmptyString(s)       (s?s:@"")

@interface DHAppDelegate ()
{
    FMDatabase *db;
    NSString *searchString;
}
@end

@implementation DHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *aPath = [@"~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2" stringByExpandingTildeInPath];
    db = [FMDatabase databaseWithPath:aPath];
    [db open];
    
    searchString = @"%%%%";
    [self reloadData];
}

- (IBAction)refresh:(id)sender
{
    searchString = @"%%%%";
    [_searchField setStringValue:@""];
    [self reloadData];
    if ([_items.arrangedObjects count]) {
        [_items setSelectionIndex:0];
    }
}

- (IBAction)selectAll:(id)sender
{
    [_items.arrangedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        obj[KEY_SELECTED] = @(YES);
    }];
}

- (IBAction)deselectAll:(id)sender
{
    [_items.arrangedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        obj[KEY_SELECTED] = @(NO);
    }];
}

- (IBAction)deleteSelected:(id)sender
{
    NSPredicate *prd = [NSPredicate predicateWithFormat:@"selected == YES"];
    NSArray *selectedObjs = [_items.arrangedObjects filteredArrayUsingPredicate:prd];
    
    if (selectedObjs.count == 0)
        return;
    
    for (NSDictionary *item in selectedObjs) {
        NSLog(@"Delete item %@", item[KEY_ID]);
        [db executeUpdate:SQL_DELETE, item[KEY_ID]];
    }
    [self reloadData];
}

- (void) reloadData
{
    FMResultSet *rs = [db executeQuery:SQL_SELECT withArgumentsInArray:@[searchString]];
    NSMutableArray *records = [NSMutableArray array];
    
    while ([rs next]) {
        NSString *eID = [rs stringForColumn:@"LSQuarantineEventIdentifier"];
        NSDate *date = [[rs dateForColumn:KEY_DATE] dateByAddingTimeInterval:978307200];
        NSString *url = NotEmptyString([rs stringForColumn:KEY_URL]);
        NSString *origUrl = NotEmptyString([rs stringForColumn:KEY_ORIGINAL_URL]);
        NSString *agent = NotEmptyString([rs stringForColumn:KEY_AGENT]);
        NSString *title = NotEmptyString([rs stringForColumn:KEY_TITLE]);
        NSString *senderName = NotEmptyString([rs stringForColumn:KEY_SENDER_NAME]);
        NSString *senderAddr = NotEmptyString([rs stringForColumn:KEY_SENDER_ADDRESS]);

        NSDictionary *item = @{
            KEY_ID: eID, KEY_URL : url, KEY_DATE: date,
            KEY_TITLE: title, KEY_AGENT: agent,
            KEY_SENDER_NAME: senderName, KEY_SENDER_ADDRESS: senderAddr,
            KEY_ORIGINAL_URL: origUrl, KEY_SELECTED: @(NO)
        };
        
        [records addObject:[item mutableCopy]];
    }
    [_items setContent:records];
    [_table reloadData];
}

- (IBAction)filter:(id)sender
{
    NSString *str = [(NSSearchField *) sender stringValue];
    searchString = [NSString stringWithFormat:@"%%%@%%", str];
    [self reloadData];
}

@end
