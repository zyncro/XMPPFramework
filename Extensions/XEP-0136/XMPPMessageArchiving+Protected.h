//
//  XMPPMessageArchiving+Protected.h
//  Pods
//
//  Created by Moral on 22/1/15.
//
//

#import "XMPPMessageArchiving.h"

@interface XMPPMessageArchiving (Protected)

- (BOOL)shouldArchiveMessage:(XMPPMessage *)message outgoing:(BOOL)isOutgoing xmppStream:(XMPPStream *)xmppStream;

@end
