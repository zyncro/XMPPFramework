//
//  XMPPMessage+ZyncroHistory.h
//  ZyncroMessenger
//
//  Created by Luis Valdés on 4/3/15.
//  Copyright (c) 2015 Zyncro Tech. All rights reserved.
//

#import "XMPPMessage.h"

@interface XMPPMessage (ZyncroHistory)

- (void)addHistoryFlag;
- (BOOL)hasHistoryFlag;

@end
