//
//  ZyncroCheckNotificationRoom.m
//  Pods
//
//  Created by Moral on 19/3/15.
//
//

#import "XMPPPresence+Zyncro.h"

@implementation XMPPPresence (Zyncro)

- (BOOL)isUnavailablePresence {
    return [[self type] isEqualToString:@"unavailable"];
}


@end
