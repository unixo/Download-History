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

#define SQL_SELECT          @"SELECT * \
                              FROM LSQuarantineEvent  \
                              WHERE LSQuarantineDataURLString LIKE ? \
                              ORDER BY LSQuarantineTimeStamp DESC"
#define KEY_ID              @"LSQuarantineEventIdentifier"
#define KEY_URL             @"LSQuarantineDataURLString"
#define KEY_ORIGINAL_URL    @"LSQuarantineOriginURLString"
#define KEY_DATE            @"LSQuarantineTimeStamp"
#define KEY_AGENT           @"LSQuarantineAgentName"
#define KEY_TITLE           @"LSQuarantineOriginTitle"
#define NotEmptyString(s)   (s?s:@"")

@interface DHAppDelegate ()
{
    FMDatabaseQueue *queue;
    NSString *searchString;
}
@end

@implementation DHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *aPath = [@"~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2" stringByExpandingTildeInPath];
    queue = [FMDatabaseQueue databaseQueueWithPath:aPath];
    searchString = @"%%%%";
    [self reloadData];
}

- (IBAction)refresh:(id)sender
{
    searchString = @"%%%%";
    [_searchField setStringValue:@""];
    [self reloadData];
    if ([_items.arrangedObjects count])
        [_items setSelectionIndex:0];
}

- (void) reloadData
{
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:SQL_SELECT withArgumentsInArray:@[searchString]];
        NSMutableArray *records = [NSMutableArray array];
        
        while ([rs next]) {
            NSString *eID = [rs stringForColumn:@"LSQuarantineEventIdentifier"];
            NSDate *date = [[rs dateForColumn:@"LSQuarantineTimeStamp"] dateByAddingTimeInterval:978307200];
            NSString *url = NotEmptyString([rs stringForColumn:@"LSQuarantineDataURLString"]);
            NSString *origUrl = NotEmptyString([rs stringForColumn:@"LSQuarantineOriginURLString"]);
            NSString *agent = NotEmptyString([rs stringForColumn:@"LSQuarantineAgentName"]);
            NSString *title = NotEmptyString([rs stringForColumn:@"LSQuarantineOriginTitle"]);

            [records addObject:@{KEY_ID: eID, KEY_URL : url, KEY_DATE: date,
                     KEY_TITLE: title, KEY_AGENT: agent, KEY_ORIGINAL_URL: origUrl}];
        }
        [_items setContent:records];
        [_table reloadData];
    }];

}

- (IBAction)filter:(id)sender
{
    NSString *str = [(NSSearchField *) sender stringValue];
    searchString = [NSString stringWithFormat:@"%%%@%%", str];
    [self reloadData];
}

@end
