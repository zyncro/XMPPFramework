//
//  XMPPMessage+ZyncroDocument.m
//  ZyncroMessenger
//
//  Created by Luis Valdés on 4/3/15.
//  Copyright (c) 2015 Zyncro Tech. All rights reserved.
//

#import "XMPPMessage+ZyncroDocument.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMNameDocument           = @"document";
static NSString *const ZMAttributeDocument      = @"id";
static NSString *const ZMXMLNSZyncroMessenger   = @"http://www.zyncro.com/messenger";

@implementation XMPPMessage (ZyncroDocument)

- (void)addDocumentId:(NSString *)documentId {
    if (!documentId || documentId.length == 0) {
        return;
    }
    /**
     * <message>
     *      ...
     *      <body> __ZLink__ </body>
     *      ...
     *      <document xmlns="http://www.zyncro.com/messenger" id="__documentUrn__" />
     *      ...
     * </message>
     */
    NSXMLElement *document = [NSXMLElement elementWithName:ZMNameDocument xmlns:ZMXMLNSZyncroMessenger];
    [document addAttributeWithName:ZMAttributeDocument stringValue:documentId];
    
    [self addChild:document];
}

- (NSString *)documentId {
    NSXMLElement *document  = [self elementForName:ZMNameDocument xmlns:ZMXMLNSZyncroMessenger];
    NSString *documentId    = [document attributeStringValueForName:ZMAttributeDocument];
    return documentId;
}

- (BOOL)hasDocumentId {
    NSString *documentId = [self documentId];
    return (documentId && documentId.length > 0);
}

@end
