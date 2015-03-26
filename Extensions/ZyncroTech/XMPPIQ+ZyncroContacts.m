//
//  ZyncroSearchContacts.m
//  Pods
//
//  Created by Moral on 24/3/15.
//
//

#import "XMPPIQ+ZyncroContacts.h"
#import "NSXMLElement+XMPP.h"

static NSString *const ZMNameQuery          = @"query";
static NSString *const ZMNameItemsPerPage   = @"itemsPerPage";
static NSString *const ZMNamePageNumber     = @"pageNumber";
static NSString *const ZMNameItem           = @"item";
static NSString *const ZMNameNick           = @"nick";
static NSString *const ZMIQResultType       = @"result";
static NSString *const ZMXMLNSSearch        = @"jabber:iq:search";

@implementation XMPPIQ (ZyncroContacts)


- (void)addQueryWithItemsPerPage:(NSUInteger)itemsPerPage pageNumber:(NSUInteger)pageNumber searchText:(NSString *)text {
    
    NSString *pageNumberStr = [NSString stringWithFormat:@"%lu", (unsigned long)pageNumber];
    NSString *itemsPerPageStr = [NSString stringWithFormat:@"%lu", (unsigned long)itemsPerPage];
    
    if (!itemsPerPageStr || itemsPerPageStr.length == 0 || !pageNumberStr || pageNumberStr.length == 0){
        return;
    }
    
    /* <iq type='set' from='jaumepaternoy@windbox.zyncro.com/jaume-notebook' to='windbox.zyncro.com' id='search1' xml:lang='en'>
    *    <query xmlns='jabber:iq:search'>
    *        <itemsPerPage>20</itemsPerPage>
    *        <pageNumber>1</pageNumber>
    *    </query>
    *  </iq>
    */
    
    NSXMLElement *query = [NSXMLElement elementWithName:ZMNameQuery xmlns:ZMXMLNSSearch];
    NSXMLElement *itemsperpage = [NSXMLElement elementWithName:ZMNameItemsPerPage stringValue:itemsPerPageStr];
    NSXMLElement *pagenumber = [NSXMLElement elementWithName:ZMNamePageNumber stringValue:pageNumberStr];
    
    if (text) {
        NSXMLElement *nick = [NSXMLElement elementWithName:ZMNameNick stringValue:text];
        [query addChild:nick];
    }
    
    [query addChild:itemsperpage];
    [query addChild:pagenumber];
    
    [self addChild:query];
}


- (BOOL)hasSearchQuery {
    NSArray *query = [self elementsForName:ZMNameQuery];
    if (query.count > 0) {
        if ([self elementForName:ZMNameQuery xmlns:ZMXMLNSSearch]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)items {
    NSArray *items = [NSMutableArray array];
    if ([self hasSearchQuery]) {
        items = [[self elementForName:ZMNameQuery] elementsForName:ZMNameItem];
    }
    return items;
}

@end
