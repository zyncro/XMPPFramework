//
//  XMPPMessage+ZyncroNotification.h
//  Pods
//
//  Created by Moral on 18/3/15.
//
//

#import "XMPPMessage.h"

@interface XMPPMessage (ZyncroRoomNotification)

- (NSString *)notificationCode;
- (BOOL)hasNotification;
- (NSString *)notificationMessage;

@end
