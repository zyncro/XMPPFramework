//
//  XMPPMessage+ZyncroNotification.h
//  Pods
//
//  Created by Moral on 18/3/15.
//
//

#import "XMPPMessage.h"

@interface XMPPMessage (ZyncroRoomNotification)

- (NSString *)notificationType;
- (NSString *)notificationUser;
- (BOOL)hasNotification;
//- (NSString *)notificationMessage;

@end
