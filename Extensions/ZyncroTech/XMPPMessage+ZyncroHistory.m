//
//  XMPPMessage+ZyncroHistory.m
//  ZyncroMessenger
//
//  Created by Luis Valdés on 4/3/15.
//  Copyright (c) 2015 Zyncro Tech. All rights reserved.
//

#import "XMPPMessage+ZyncroHistory.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMAttributeHistory = @"history";

@implementation XMPPMessage (ZyncroHistory)

- (void)addHistoryFlag {
    /**
     * <message from="user1@domain.com/resource" to="user2@domain.com/resource" history="1">
     *    <body>…</body>
     * </message>
     */
    if (!self.hasHistoryFlag) {
        [self addAttributeWithName:ZMAttributeHistory boolValue:YES];
    }
}

- (BOOL)hasHistoryFlag {
    return (self.historyFlag != nil);
}

- (DDXMLNode *)historyFlag {
    return [self attributeForName:ZMAttributeHistory];
}

@end
