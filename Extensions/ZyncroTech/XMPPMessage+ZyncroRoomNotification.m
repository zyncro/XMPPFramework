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



- (void)addNotificationType:(NSString *)notificationType toUser:(XMPPJID *)notificationUserJID {
    if (!notificationType || notificationType.length == 0 || !notificationUserJID) {
        return;
    }
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
    
    NSXMLElement *x = [self extensionElement];
    if (!x) {
        x = [NSXMLElement elementWithName:ZMNameExtension xmlns:ZMXMLNSZyncroMessenger];
        [self addChild:x];
    }
    
    NSXMLElement *notification  = [x elementForName:ZMNameNotification];
    if (notification) {
        [notification detach];
    }
    notification = [NSXMLElement elementWithName:ZMNameNotification];
    [notification addAttributeWithName:ZMAttributeNotificationType  stringValue:notificationType];
    [notification addAttributeWithName:ZMAttributeNotificationJID   stringValue:notificationUserJID.bare];
    
    [x addChild:notification];
}

- (NSXMLElement *)extensionElement {
    NSXMLElement *x = [self elementForName:ZMNameExtension xmlns:ZMXMLNSZyncroMessenger];
    return x;
}

- (NSXMLElement *)notificationElement {
    NSXMLElement *x = [self extensionElement];
    NSXMLElement *notification  = [x elementForName:ZMNameNotification];
    return notification;
}

- (NSString *)notificationType {
    NSXMLElement *notification  = [self notificationElement];
    NSString *type    = [notification attributeStringValueForName:ZMAttributeNotificationType];
    return type;
}

- (NSString *)notificationUser {
    NSXMLElement *notification  = [self notificationElement];
    NSString *jid    = [notification attributeStringValueForName:ZMAttributeNotificationJID];
    return [XMPPJID jidWithString:jid].user;
}

- (BOOL)hasNotification {
    NSString *code = [self notificationType];
    return (code && code.length > 0);
}


@end
