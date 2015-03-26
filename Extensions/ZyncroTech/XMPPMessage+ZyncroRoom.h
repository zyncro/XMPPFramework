//
//  ZyncroRoom.h
//  Pods
//
//  Created by Moral on 11/3/15.
//
//

#import "XMPPMessage.h"

@interface XMPPMessage (ZyncroRoom)

- (void)addRoomMessageId:(NSString *)roomMessageId;

- (NSXMLElement *)roomMessageElement;
- (NSString *)roomMessageId;
- (BOOL)hasRoomMessageId;

@end
