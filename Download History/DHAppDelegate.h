//
//  DHAppDelegate.h
//  Download History
//
//  Created by Ferruccio Vitale on 22/01/13.
//  Copyright (c) 2013 Ferruccio Vitale. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DHAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *table;
@property (strong, nonatomic) NSNumber *itemsCount;

- (IBAction)filter:(id)sender;
@end
