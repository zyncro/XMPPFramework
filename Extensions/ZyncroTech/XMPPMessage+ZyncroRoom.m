//
//  ZyncroRoom.m
//  Pods
//
//  Created by Moral on 11/3/15.
//
//

#import "XMPPMessage+ZyncroRoom.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMExtension               = @"x";
static NSString *const ZMNameElement               = @"roommessage";
static NSString *const ZMAttributeMessageId        = @"id";
static NSString *const ZMXMLNSZyncroMessenger       = @"http://www.zyncro.com/messenger";

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
     *      <roommessage id="XXX" />
     *      ...
     *      </x>
     *      ...
     * </message>
     */
    NSXMLElement *x = [NSXMLElement elementWithName:ZMExtension xmlns:ZMXMLNSZyncroMessenger];
    NSXMLElement *roommessage = [NSXMLElement elementWithName:ZMNameElement];
    [roommessage addAttributeWithName:ZMAttributeMessageId        stringValue:roomMessageId];
    
    [x addChild:roommessage];
    
    [self addChild:x];
}

- (NSString *)elementRoomID {
    NSXMLElement *x = [self elementForName:ZMExtension];
    NSXMLElement *roomMessage  = [x elementForName:ZMNameElement];
    NSString *roomMessageId    = [roomMessage attributeStringValueForName:ZMAttributeMessageId];
    return roomMessageId;
}

- (BOOL)hasElementRoomID {
    NSString *roomMessageId = [self elementRoomID];
    return (roomMessageId && roomMessageId.length > 0);
}

@end
