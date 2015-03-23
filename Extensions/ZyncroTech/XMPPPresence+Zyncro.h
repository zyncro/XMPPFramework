//
//  ZyncroCheckNotificationRoom.h
//  Pods
//
//  Created by Moral on 19/3/15.
//
//

#import <Foundation/Foundation.h>
#import "XMPPPresence.h"

@interface XMPPPresence (Zyncro)

- (BOOL)isUnavailablePresence;
- (BOOL)hasCode;
- (BOOL)hasDestroyElement;
- (BOOL)hasError;

- (NSString *)codeAttribute;

@end
