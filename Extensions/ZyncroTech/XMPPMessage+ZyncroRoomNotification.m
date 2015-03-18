//
//  XMPPMessage+ZyncroNotification.m
//  Pods
//
//  Created by Moral on 18/3/15.
//
//

#import "XMPPMessage+ZyncroRoomNotification.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMExtension               = @"x";
static NSString *const ZMNameElement               = @"notification";
static NSString *const ZMAttributeMessageId        = @"code";
//static NSString *const ZMXMLNSZyncroMessenger       = @"http://www.zyncro.com/messenger";

@implementation XMPPMessage (ZyncroRoomNotification)

/**
 * <message>
 *      ...
 *      <body>XXX</body>
 *      <x xmlns="http://www.zyncro.com/messenger">
 *      <roommessage id="XXX" />
 *      <notification code="XXX"/>
 *      ...
 *      </x>
 *      ...
 * </message>
 */

- (NSString *)notificationCode {
    NSXMLElement *x = [self elementForName:ZMExtension];
    NSXMLElement *notification  = [x elementForName:ZMNameElement];
    NSString *code    = [notification attributeStringValueForName:ZMAttributeMessageId];
    return code;
}

- (BOOL)hasNotification {
    NSString *code = [self notificationCode];
    return (code && code.length > 0);
}

- (NSString *)notificationMessage {
    NSString *message = nil;
    if ([[self notificationCode] isEqualToString:@"307"]) {
        message = @"Message from room.";
    }
    return message;
}

@end
