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
                              ORDER BY LSQuarantineTimeStamp"
#define KEY_URL             @"key_LSQuarantineDataURLString"
#define KEY_DATE            @"key_LSQuarantineTimeStamp"
#define KEY_AGENT           @"key_LSQuarantineAgentName"

@interface DHAppDelegate ()
{
    NSMutableArray *items;
    FMDatabaseQueue *queue;
    NSString *searchString;
}
@end

@implementation DHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *aPath = [@"~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2" stringByExpandingTildeInPath];
    queue = [FMDatabaseQueue databaseQueueWithPath:aPath];
    items = [[NSMutableArray alloc] init];
    searchString = @"%%%%";
    [self updateItemsCount];
    [self refresh];
}

- (void) refresh
{
    /*
     CREATE TABLE LSQuarantineEvent (  LSQuarantineEventIdentifier TEXT PRIMARY KEY NOT NULL,  LSQuarantineTimeStamp REAL,  LSQuarantineAgentBundleIdentifier TEXT,  LSQuarantineAgentName TEXT,  LSQuarantineDataURLString TEXT,  LSQuarantineSenderName TEXT,  LSQuarantineSenderAddress TEXT,  LSQuarantineTypeNumber INTEGER,  LSQuarantineOriginTitle TEXT,  LSQuarantineOriginURLString TEXT,  LSQuarantineOriginAlias BLOB );
     */
    [items removeAllObjects];
    
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:SQL_SELECT withArgumentsInArray:@[searchString]];
        
        while ([rs next]) {
            NSDate *date = [rs dateForColumn:@"LSQuarantineTimeStamp"];
            NSString *url = [rs stringForColumn:@"LSQuarantineDataURLString"];
            NSString *agent = [rs stringForColumn:@"LSQuarantineAgentName"];

            if (date && url)
                [items addObject:@{KEY_URL : url, KEY_DATE: date, KEY_AGENT: agent}];
        }
        [self updateItemsCount];
        [_table reloadData];
    }];

}

- (void) updateItemsCount
{
    [self willChangeValueForKey:@"itemsCount"];
    _itemsCount = @(items.count);
    [self didChangeValueForKey:@"itemsCount"];
}

#pragma mark - Table view datasource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return items.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSDictionary *item = items[rowIndex];
    id retValue = nil;
    
    if ([aTableColumn.identifier isEqualTo:@"colDate"]) {
        retValue = item[KEY_DATE];
    } else if ([aTableColumn.identifier isEqualTo:@"colURL"]) {
        retValue = item[KEY_URL];
    } else if ([aTableColumn.identifier isEqualTo:@"colAgent"]) {
        retValue = item[KEY_AGENT];
    }
    
    return retValue;
}

- (IBAction)filter:(id)sender
{
    NSString *str = [(NSSearchField *) sender stringValue];
    searchString = [NSString stringWithFormat:@"%%%@%%", str];
    [self refresh];
}

@end
