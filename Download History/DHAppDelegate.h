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
@property (weak) IBOutlet NSArrayController *items;
@property (weak) IBOutlet NSSearchField *searchField;

- (IBAction)filter:(id)sender;
- (IBAction)refresh:(id)sender;
@end
