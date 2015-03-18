//
//  ZyncroRoom.m
//  Pods
//
//  Created by Moral on 11/3/15.
//
//

#import "XMPPMessage+ZyncroRoom.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMNameExtension          = @"x";
static NSString *const ZMNameRoomMessage        = @"roommessage";
static NSString *const ZMAttributeRoomMessageId = @"id";
static NSString *const ZMXMLNSZyncroMessenger   = @"http://www.zyncro.com/messenger";

@implementation XMPPMessage (ZyncroRoom)

- (void)addRoomMessageId:(NSString *)roomMessageId {
    if (!roomMessageId || roomMessageId.length == 0){
        return;
    }
    /**
     * <message>
     *      ...
     *      <body>XXX</body>
     *      <x xmlns="http://www.zyncro.com/messenger">
     *          <roommessage id="XXX" />
     *      ...
     *      </x>
     *      ...
     * </message>
     */
    NSXMLElement *x = [NSXMLElement elementWithName:ZMNameExtension xmlns:ZMXMLNSZyncroMessenger];
    NSXMLElement *roommessage = [NSXMLElement elementWithName:ZMNameRoomMessage];
    [roommessage addAttributeWithName:ZMAttributeRoomMessageId stringValue:roomMessageId];
    
    [x addChild:roommessage];
    
    [self addChild:x];
}

- (NSXMLElement *)extensionElement {
    NSXMLElement *x = [self elementForName:ZMNameExtension xmlns:ZMXMLNSZyncroMessenger];
    return x;
}

- (NSString *)elementRoomID {
    NSXMLElement *x = [self extensionElement];
    NSXMLElement *roomMessage  = [x elementForName:ZMNameRoomMessage];
    NSString *roomMessageId    = [roomMessage attributeStringValueForName:ZMAttributeRoomMessageId];
    return roomMessageId;
}

- (BOOL)hasElementRoomID {
    NSString *roomMessageId = [self elementRoomID];
    return (roomMessageId && roomMessageId.length > 0);
}

@end
