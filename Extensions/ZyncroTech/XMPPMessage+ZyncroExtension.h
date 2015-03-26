//
//  XMPPMessage+ZyncroExtension.h
//  Pods
//
//  Created by Luis Valdés on 26/3/15.
//
//

#import "XMPPMessage.h"

@interface XMPPMessage (ZyncroExtension)

- (NSXMLElement *)addExtension;
- (NSXMLElement *)extensionElement;

@end
