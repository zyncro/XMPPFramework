//
//  ZyncroRoom.h
//  Pods
//
//  Created by Moral on 11/3/15.
//
//

#import <XMPPFramework/XMPPMessage.h>

@interface XMPPMessage (ZyncroRoom)

- (void)addRoomMessageId:(NSString *)roomMessageId;

- (NSString *)elementRoomID;
- (BOOL)hasElementRoomID;

@end
