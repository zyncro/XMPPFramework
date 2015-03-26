//
//  ZyncroRoom.m
//  Pods
//
//  Created by Moral on 11/3/15.
//
//

#import "XMPPMessage+ZyncroRoom.h"
#import "XMPPMessage+ZyncroExtension.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMNameRoomMessage        = @"roommessage";
static NSString *const ZMAttributeRoomMessageId = @"id";

@implementation XMPPMessage (ZyncroRoom)

- (void)addRoomMessageId:(NSString *)roomMessageId {
    if (!roomMessageId || roomMessageId.length == 0){
        return;
    }
    /**
     * <message>
     *      ...
     *      <body>XXX</body>
     *      ...
     *      <x xmlns="http://www.zyncro.com/messenger">
     *          ...
     *          <roommessage id="XXX" />
     *          ...
     *      </x>
     *      ...
     * </message>
     */
    NSXMLElement *roommessage = [NSXMLElement elementWithName:ZMNameRoomMessage];
    [roommessage addAttributeWithName:ZMAttributeRoomMessageId stringValue:roomMessageId];
    
    NSXMLElement *x = [self extensionElement];
    if (!x) {
        x = [self addExtension];
    }
    [x addChild:roommessage];
}

- (NSXMLElement *)roomMessageElement {
    NSXMLElement *x             = [self extensionElement];
    NSXMLElement *roomMessage   = [x elementForName:ZMNameRoomMessage];
    return roomMessage;
}

- (NSString *)roomMessageId {
    NSXMLElement *roomMessage   = [self roomMessageElement];
    NSString *roomMessageId     = [roomMessage attributeStringValueForName:ZMAttributeRoomMessageId];
    return roomMessageId;
}

- (BOOL)hasRoomMessageId {
    NSString *roomMessageId = [self roomMessageId];
    return (roomMessageId && roomMessageId.length > 0);
}

@end
