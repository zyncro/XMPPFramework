//
//  XMPPMessage+ZyncroNotification.m
//  Pods
//
//  Created by Moral on 18/3/15.
//
//

#import "XMPPMessage+ZyncroRoomNotification.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMNameExtension              = @"x";
static NSString *const ZMNameNotification           = @"notification";
static NSString *const ZMAttributeNotificationType  = @"type";
static NSString *const ZMAttributeNotificationJID   = @"jid";
static NSString *const ZMXMLNSZyncroMessenger       = @"http://www.zyncro.com/messenger";

@implementation XMPPMessage (ZyncroRoomNotification)

/**
 * <message>
 *      ...
 *      <body>XXX</body>
 *      <x xmlns="http://www.zyncro.com/messenger">
 *          <notification type="XXX" jid="YYY" />
 *      </x>
 *      ...
 * </message>
 */

- (NSXMLElement *)extensionElement {
    NSXMLElement *x = [self elementForName:ZMNameExtension xmlns:ZMXMLNSZyncroMessenger];
    return x;
}

- (NSString *)notificationType {
    NSXMLElement *x = [self extensionElement];
    NSXMLElement *notification  = [x elementForName:ZMNameNotification];
    NSString *type    = [notification attributeStringValueForName:ZMAttributeNotificationType];
    return type;
}

- (NSString *)notificationUser {
    NSXMLElement *x = [self extensionElement];
    NSXMLElement *notification  = [x elementForName:ZMNameNotification];
    NSString *jid    = [notification attributeStringValueForName:ZMAttributeNotificationJID];
    return [XMPPJID jidWithString:jid].user;
}

- (BOOL)hasNotification {
    NSString *code = [self notificationType];
    return (code && code.length > 0);
}

//- (NSString *)notificationMessage {
//    NSString *message = nil;
//    if ([[self notificationType] isEqualToString:@"user-joined"]) {
//        message = @"User joined.";
//    } else if ([[self notificationType] isEqualToString:@"user-banned"]) {
//        message = @"User left the room.";
//    } else {
//        message = @"User left the room.";
//    }
//    return message;
//}

@end
