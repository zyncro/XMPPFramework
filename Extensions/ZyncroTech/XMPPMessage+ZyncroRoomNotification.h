//
//  XMPPMessage+ZyncroNotification.h
//  Pods
//
//  Created by Moral on 18/3/15.
//
//

#import "XMPPMessage.h"

@interface XMPPMessage (ZyncroRoomNotification)

- (void)addNotificationType:(NSString *)notificationType toUser:(XMPPJID *)notificationUserJID;

- (NSString *)notificationType;
- (NSString *)notificationUser;
- (BOOL)hasNotification;

@end
