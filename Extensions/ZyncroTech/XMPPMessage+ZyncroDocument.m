//
//  XMPPMessage+ZyncroDocument.m
//  ZyncroMessenger
//
//  Created by Luis Valdés on 4/3/15.
//  Copyright (c) 2015 Zyncro Tech. All rights reserved.
//

#import "XMPPMessage+ZyncroDocument.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMNameDocument               = @"document";
static NSString *const ZMAttributeDocumentId        = @"id";
static NSString *const ZMAttributeDocumentGroupId   = @"groupId";
static NSString *const ZMXMLNSZyncroMessenger       = @"http://www.zyncro.com/messenger";

@implementation XMPPMessage (ZyncroDocument)

- (void)addDocumentId:(NSString *)documentId withGroupId:(NSString *)documentGroupId {
    if (!documentId || documentId.length == 0
        || !documentGroupId || documentGroupId.length == 0) {
        return;
    }
    /**
     * <message>
     *      ...
     *      <body> __ZLink__ </body>
     *      ...
     *      <document xmlns="http://www.zyncro.com/messenger" id="__documentUrn__" groupId="__groupUrn__" />
     *      ...
     * </message>
     */
    NSXMLElement *document = [NSXMLElement elementWithName:ZMNameDocument xmlns:ZMXMLNSZyncroMessenger];
    [document addAttributeWithName:ZMAttributeDocumentId        stringValue:documentId];
    [document addAttributeWithName:ZMAttributeDocumentGroupId   stringValue:documentGroupId];
    
    [self addChild:document];
}

- (NSString *)documentId {
    NSXMLElement *document  = [self elementForName:ZMNameDocument xmlns:ZMXMLNSZyncroMessenger];
    NSString *documentId    = [document attributeStringValueForName:ZMAttributeDocumentId];
    return documentId;
}

- (NSString *)documentGroupId {
    NSXMLElement *document      = [self elementForName:ZMNameDocument xmlns:ZMXMLNSZyncroMessenger];
    NSString *documentGroupId   = [document attributeStringValueForName:ZMAttributeDocumentGroupId];
    return documentGroupId;
}

- (BOOL)hasDocumentId {
    NSString *documentId = [self documentId];
    return (documentId && documentId.length > 0);
}

- (BOOL)hasDocumentGroupId {
    NSString *documentGroupId = [self documentGroupId];
    return (documentGroupId && documentGroupId.length > 0);
}

@end
