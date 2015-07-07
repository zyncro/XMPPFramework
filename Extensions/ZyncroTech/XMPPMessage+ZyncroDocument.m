//
//  XMPPMessage+ZyncroDocument.m
//  ZyncroMessenger
//
//  Created by Luis Valdés on 4/3/15.
//  Copyright (c) 2015 Zyncro Tech. All rights reserved.
//

#import "XMPPMessage+ZyncroDocument.h"
#import "XMPPMessage+ZyncroExtension.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMNameDocument               = @"document";
static NSString *const ZMAttributeDocumentId        = @"id";
static NSString *const ZMAttributeDocumentGroupId   = @"groupId";
static NSString *const ZMAttributeDocumentName      = @"name";
static NSString *const ZMAttributeDocumentURL       = @"url";

@implementation XMPPMessage (ZyncroDocument)

- (void)addDocumentId:(NSString *)documentId groupId:(NSString *)documentGroupId name:(NSString *)documentName andURL:(NSString *)documentURL {
    if (!documentId || documentId.length == 0
        || !documentGroupId || documentGroupId.length == 0) {
        return;
    }
    /**
     * <message>
     *      ...
     *      <body> __ZLink__ </body>
     *      ...
     *      <x xmlns="http://www.zyncro.com/messenger">
     *          ...
     *          <document id="__documentUrn__" groupId="__groupUrn__" name="__documentName__" url="__ZLink__" />
     *          ...
     *      </x>
     *      ...
     * </message>
     */
    NSXMLElement *document = [NSXMLElement elementWithName:ZMNameDocument];
    [document addAttributeWithName:ZMAttributeDocumentId        stringValue:documentId];
    [document addAttributeWithName:ZMAttributeDocumentGroupId   stringValue:documentGroupId];
    [document addAttributeWithName:ZMAttributeDocumentName      stringValue:documentName];
    [document addAttributeWithName:ZMAttributeDocumentURL       stringValue:documentURL];
    
    NSXMLElement *x = [self extensionElement];
    if (!x) {
        x = [self addExtension];
    }
    [x addChild:document];
}

- (NSXMLElement *)documentElement {
    NSXMLElement *x         = [self extensionElement];
    NSXMLElement *document  = [x elementForName:ZMNameDocument];
    return document;
}

- (NSString *)documentId {
    NSXMLElement *document  = [self documentElement];
    NSString *documentId    = [document attributeStringValueForName:ZMAttributeDocumentId];
    return documentId;
}

- (NSString *)documentGroupId {
    NSXMLElement *document      = [self documentElement];
    NSString *documentGroupId   = [document attributeStringValueForName:ZMAttributeDocumentGroupId];
    return documentGroupId;
}

- (NSString *)documentName {
    NSXMLElement *document  = [self documentElement];
    NSString *documentName  = [document attributeStringValueForName:ZMAttributeDocumentName];
    return documentName;
}

- (NSString *)documentURL {
    NSXMLElement *document  = [self documentElement];
    NSString *documentURL  = [document attributeStringValueForName:ZMAttributeDocumentURL];
    return documentURL;
}


- (BOOL)hasDocumentId {
    NSString *documentId = [self documentId];
    return (documentId && documentId.length > 0);
}

- (BOOL)hasDocumentGroupId {
    NSString *documentGroupId = [self documentGroupId];
    return (documentGroupId && documentGroupId.length > 0);
}

- (BOOL)hasDocumentName {
    NSString *documentName = [self documentName];
    return (documentName && documentName.length > 0);
}

- (BOOL)hasDocumentURL {
    NSString *documentURL = [self documentURL];
    return (documentURL && documentURL.length > 0);
}

@end
