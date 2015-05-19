//
//  MMBarricadeResponseSet.h
//  Barricade
//
//  Created by John McIntosh on 5/12/15.
//  Copyright (c) 2015 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMBarricadeResponse.h"


/**
 A concrete implementation of `<MMBarricadeResponseSet>` is a collection of responses representing
 all possible responses that might be returned from the server for a particular API request.

 For example, for a request to `/login` one might create a response set with responses representing:
 
 - successful authentication
 - invalid credentials
 - user locked out
 - server unavailable
 - internet connection offline
 */
@interface MMBarricadeResponseSet : NSObject

///--------------------------------
/// @name Properties
///--------------------------------

/**
 The developer-facing name of the request that this object contains responses for. For example, if
 an instance of a response set contains responses for the `/login` endpoint, the `requestName`
 might be set to "Login" or "Authentication". This string is used for the developer to identify the
 response set, such as when adjusting the current response in a response set. The `requestName`
 should be unique among all registered response sets.
 
 If the Facebook Tweaks user interface is used, this name will be used to identify the response set.
 */
@property (nonatomic, copy) NSString *requestName;

/**
 The response that will be returned by default. If this value is not programmatically set, the first
 response added will be returned as the default response.
 */
@property (nonatomic, strong) id<MMBarricadeResponse> defaultResponse;

/**
 All responses that are part of this set.
 */
@property (nonatomic, copy) NSArray *allResponses;

/**
 This block determines whether this response set is capable of responding to a particular request.
 Return `YES` from the block to indicate that the response set can respond.
 
 A sample implementation of this block might look like:
 
 ```
 ^BOOL(NSURLRequest *request, NSURLComponents *URLComponents) {
     return [components.path isEqualToString:@"/login"];
 };
 ```
 */
@property (nonatomic, copy) BOOL (^respondsToRequest)(NSURLRequest *request, NSURLComponents *URLComponents);

///--------------------------------
/// @name Initializers
///--------------------------------

- (instancetype)initWithRequestName:(NSString *)requestName
                  respondsToRequest:(BOOL (^)(NSURLRequest *request, NSURLComponents *components))respondsToRequest;

+ (instancetype)responseSetForRequestName:(NSString *)requestName
                        respondsToRequest:(BOOL (^)(NSURLRequest *request, NSURLComponents *components))respondsToRequest;

- (instancetype)init __attribute__((unavailable("Use the designated initializer -initWithRequestName:respondsToRequest:")));

///--------------------------------
/// @name Methods
///--------------------------------

/**
 Add a response to the set.
 */
- (void)addResponse:(id<MMBarricadeResponse>)response;

/**
 Add a response to the set by declaring the response in a block. The block will be evaluated immediately
 upon calling the method.
 */
- (void)createResponseWithBlock:(id<MMBarricadeResponse> (^)(void))creationBlock;

/**
 A convenience method for creating a response in which a standard response is created internally and
 provided to the `populationBlock` to be filled in by the caller.
 */
- (void)createResponseWithName:(NSString *)name
               populationBlock:(void (^)(MMBarricadeResponse *response))populationBlock;

/**
 Return the response in this set which has the specified name.
 */
- (id<MMBarricadeResponse>)responseWithName:(NSString *)responseName;

@end
