//
//  ZyncroCheckNotificationRoom.m
//  Pods
//
//  Created by Moral on 19/3/15.
//
//

#import "XMPPPresence+Zyncro.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMNameExtension  = @"x";
static NSString *const ZMNameStatus     = @"status";
static NSString *const ZMNameDestroy    = @"destroy";
static NSString *const ZMAttributeCode  = @"code";

@implementation XMPPPresence (Zyncro)

- (BOOL)isUnavailablePresence {
    return [[self type] isEqualToString:@"unavailable"];
}

- (NSXMLElement *)extensionElement {
    NSXMLElement *x = [self elementForName:ZMNameExtension];
    return x;
}

- (NSXMLElement *)statusElement {
    NSXMLElement *status = [[self extensionElement] elementForName:ZMNameStatus];
    return status;
}

- (NSString *)codeAttribute {
    NSString *code = [[[self statusElement] attributeForName:ZMAttributeCode] stringValue];
    return code;
}

- (BOOL)hasDestroyElement {
    NSArray *status = [[self extensionElement] elementsForName:ZMNameDestroy];
    return (status.count > 0);
}

- (BOOL)hasExtension {
    NSString *extension = [[self extensionElement] stringValue];
    return (extension && extension.length > 0);
}

- (BOOL)hasStatus {
    NSString *status = [[self statusElement] stringValue];
    return (status && status.length > 0);
}

- (BOOL)hasCode {
    NSString *code = [self codeAttribute];
    return (code && code.length > 0);
}


@end
