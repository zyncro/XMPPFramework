//
//  ZyncroRoom.m
//  Pods
//
//  Created by Moral on 11/3/15.
//
//

#import "XMPPMessage+ZyncroRoom.h"
#import "NSXMLElement+XMPP.h"

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
     *      ...
     *      <rommmessage xmlns="http://www.zyncro.com/messenger" id="XXX" />
     *      ...
     * </message>
     */
    NSXMLElement *roommessage = [NSXMLElement elementWithName:ZMNameElement xmlns:ZMXMLNSZyncroMessenger];
    [roommessage addAttributeWithName:ZMAttributeMessageId        stringValue:roomMessageId];
    
    [self addChild:roommessage];
}

- (NSString *)elementRoomID {
    NSXMLElement *roomMessage  = [self elementForName:ZMNameElement xmlns:ZMXMLNSZyncroMessenger];
    NSString *roomMessageId    = [roomMessage attributeStringValueForName:ZMAttributeMessageId];
    return roomMessageId;
}

- (BOOL)hasElementRoomID {
    NSString *roomMessageId = [self elementRoomID];
    return (roomMessageId && roomMessageId.length > 0);
}

@end
