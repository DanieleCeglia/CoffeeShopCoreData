//
//  Stats.h
//  CoffeeShopCoreData
//
//  Created by Daniele Ceglia on 11/10/13.
//  Copyright (c) 2013 Relifeit (Daniele Ceglia). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Venue;

@interface Stats : NSManagedObject

@property (nonatomic, retain) NSNumber * checkins;
@property (nonatomic, retain) NSNumber * tips;
@property (nonatomic, retain) NSNumber * users;
@property (nonatomic, retain) Venue *padreVenue;

@end
