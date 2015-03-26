//
//  XMPPMessage+ZyncroExtension.m
//  Pods
//
//  Created by Luis Valdés on 26/3/15.
//
//

#import "XMPPMessage+ZyncroExtension.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMNameExtension          = @"x";
static NSString *const ZMXMLNSZyncroMessenger   = @"http://www.zyncro.com/messenger";

@implementation XMPPMessage (ZyncroExtension)

- (NSXMLElement *)addExtension {
    /**
     * <message>
     *      ...
     *      <body> __ZLink__ </body>
     *      ...
     *      <x xmlns="http://www.zyncro.com/messenger">
     *          ...
     *      </x>
     *      ...
     * </message>
     */
    NSXMLElement *x = [NSXMLElement elementWithName:ZMNameExtension xmlns:ZMXMLNSZyncroMessenger];
    [self addChild:x];
    return x;
}

- (NSXMLElement *)extensionElement {
    NSXMLElement *x = [self elementForName:ZMNameExtension xmlns:ZMXMLNSZyncroMessenger];
    return x;
}

@end
