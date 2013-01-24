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
#define FILTER_PREDICATE        @"LSQuarantineDataURLString like[cd] %@ OR LSQuarantineAgentName like[cd] %@"
#define NotEmptyString(s)       (s?s:@"")

@interface DHAppDelegate ()
{
    FMDatabase *db;
}
@end

@implementation DHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *aPath = [@"~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2" stringByExpandingTildeInPath];
    db = [FMDatabase databaseWithPath:aPath];
    [db open];
    [self reloadData];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [db close];
}

- (IBAction)refresh:(id)sender
{
    [_searchField setStringValue:@""];
    [self reloadData];
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
        [db executeUpdate:SQL_DELETE, item[KEY_ID]];
    }
    [self reloadData];
}

- (void)reloadData
{
    FMResultSet *rs = [db executeQuery:SQL_SELECT];
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
    // Set new content for array controller
    [_items setContent:records];
    
    // Ask the table to reload data
    [_table reloadData];
}

- (IBAction)filter:(id)sender
{
    NSString *str = [(NSSearchField *) sender stringValue];
    NSString *searchString = [NSString stringWithFormat:@"*%@*", str];
    NSPredicate *prd = [NSPredicate predicateWithFormat:FILTER_PREDICATE, searchString, searchString];
    [_items setFilterPredicate:prd];
}

- (IBAction)filterByAgent:(id)sender
{
    NSArray *selectedItems = [_items selectedObjects];
    if (selectedItems.count) {
        NSDictionary *item = selectedItems[0];
        NSString *searchString = [NSString stringWithFormat:@"*%@*", item[KEY_AGENT]];
        [_searchField setStringValue:item[KEY_AGENT]];
        NSPredicate *prd = [NSPredicate predicateWithFormat:FILTER_PREDICATE, searchString, searchString];
        [_items setFilterPredicate:prd];
    }
}

@end
