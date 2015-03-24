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
static NSString *const ZMXMLNSSearch        = @"jabber:iq:search";

@implementation XMPPIQ (ZyncroContacts)




- (void)addQueryWithItemsPerPage:(NSString *)itemsPerPage pageNumber:(NSString *)pageNumber {
    if (!itemsPerPage || itemsPerPage.length == 0 || pageNumber || pageNumber.length == 0){
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
    NSXMLElement *itemsperpage = [NSXMLElement elementWithName:itemsPerPage stringValue:itemsPerPage];
    NSXMLElement *pagenumber = [NSXMLElement elementWithName:pageNumber stringValue:pageNumber];
    
    [query addChild:itemsperpage];
    [query addChild:pagenumber];
    
    [self addChild:query];
}




@end
