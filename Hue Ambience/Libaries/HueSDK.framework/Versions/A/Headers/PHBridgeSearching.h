/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import <Foundation/Foundation.h>

@class PHHttpRequester;
@class AsyncUdpSocket;

/**
    This is a block used for getting the response of the bridge search class.
    It takes a dictionary as parameter, which contains mac addresses as keys and
    ip addresses as values.
 */
typedef void (^PHBridgeSearchCompletionHandler)(NSDictionary *bridgesFound);

/**
	This class is used for searching for SmartBridge using UPnP and portal based discovery.
 */
@interface PHBridgeSearching : NSObject

/**
    Socket used for doing the UPnP search
 */
@property (nonatomic, strong) AsyncUdpSocket *ssdpSocket;

/**
    Http requester used for portal search
 */
@property (nonatomic, strong) PHHttpRequester *httpRequester;

/**
	Initializes a PHBridgeSearch object which can search for bridges
    @param searchUpnp Indicates whether UPnP should be used for searching
    @param searchPortal Indicates whether portal based discovery should be used for searching
	@returns PHBridgeSearch instance
 */
- (id)initWithUpnpSearch:(BOOL)searchUpnp andPortalSearch:(BOOL)searchPortal;

/**
	Does a search for bridges, sends the result to the given completion handler.
	@param completionHandler the completion handler to call when done searching
    @see PHBridgeSearchCompletionHandler
 */
- (void)startSearchWithCompletionHandler:(PHBridgeSearchCompletionHandler)completionHandler;

@end
