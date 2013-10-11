//
//  MasterViewController.m
//  CoffeeShop
//
//  Created by Daniele Ceglia on 10/10/13.
//  Copyright (c) 2013 Relifeit (Daniele Ceglia). All rights reserved.
//

#import "MasterViewController.h"
#import <RestKit/RestKit.h>
#import "Venue.h"
#import "VenueCell.h"
#import "Location.h" // con core data serve!
#import "Stats.h" // con core data serve!
#import "AppDelegate.h"

#define kCLIENTID "GGHC2ZDRME511ZY4NEUK4CN5IKIYE3K55YTX2OWW5HDSMIIZ"
#define kCLIENTSECRET "YO3G2Q0DZEYHWMSXUW41UBYV3TUIHZMW54CN0G2MQI34TZD1"

/*
 TUTORIAL SEGUITO DA: http://www.raywenderlich.com/13097/intro-to-restkit-tutorial
 
 MIGRAZIONE RESTKIT da 0.10.x a 0.20.0 vedere: https://github.com/RestKit/RestKit/wiki/Upgrading-from-v0.10.x-to-v0.20.0
 
 E CODICE GIÀ MEZZO CONVERTITO DA QUALCUNO SU INTERNET: http://madeveloper.blogspot.it/2013/01/ios-restkit-tutorial-code-for-version.html
 (che però è già deprecato su alcuni metodi...)
*/

@interface MasterViewController ()
{
    NSMutableArray *_objects;
    AppDelegate *appDelegate;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    
    /* DEFINIZIONE URL DEL WEBSERVICE REST */
    
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com/v2"];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    
    
    /* MAPPATURA JSON CON GLI OGGETTI DEL MODELLO */
    
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
    RKObjectMapping *statsMapping = [RKObjectMapping mappingForClass:[Stats class]];
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]];
    
    
    /*** mappatura location ***/
    
    [locationMapping addAttributeMappingsFromDictionary:@{@"address"     : @"address",
                                                          @"city"        : @"city",
                                                          @"country"     : @"country",
                                                          @"crossStreet" : @"crossStreet",
                                                          @"postalCode"  : @"postalCode",
                                                          @"state"       : @"state",
                                                          @"distance"    : @"distance",
                                                          @"lat"         : @"lat",
                                                          @"lng"         : @"lng"}];
    
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
    
    
    /*** mappatura stats ***/
    
    [statsMapping addAttributeMappingsFromDictionary:@{@"checkinsCount" : @"checkins",
                                                       @"tipCount"      : @"tips",
                                                       @"usersCount"    : @"users"}];
    
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"stats" withMapping:statsMapping]];
    
    
    /*** mappatura venues ***/
    
    [venueMapping addAttributeMappingsFromDictionary:@{@"name" : @"name"}];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:venueMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"response.venues" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    
    [self sendRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VenueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VenueCell"];

    Venue *venue = [_objects objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [venue.name length] > 25 ? [venue.name substringToIndex:25] : venue.name;
    
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.0fm", [venue.location.distance floatValue]];
    cell.checkinsLabel.text = [NSString stringWithFormat:@"%d checkins", [venue.stats.checkins intValue]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Metodi privati

- (void)sendRequest
{
    NSString *latLon = @"37.33,-122.03";
    NSString *clientID = [NSString stringWithUTF8String:kCLIENTID];
    NSString *clientSecret = [NSString stringWithUTF8String:kCLIENTSECRET];
    
    NSDictionary *queryParams;
    queryParams = [NSDictionary dictionaryWithObjectsAndKeys:latLon, @"ll", clientID, @"client_id", clientSecret, @"client_secret", @"coffee", @"query", @"20120602", @"v", nil];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    [objectManager getObjectsAtPath:@"https://api.foursquare.com/v2/venues/search"
                         parameters:queryParams
                            success:^(RKObjectRequestOperation *operaton, RKMappingResult *mappingResult)
                                    {
                                        NSLog(@"Mappatura riuscita: %@", mappingResult);
                                        
                                        NSArray *result = [mappingResult array];
                                        _objects = [[mappingResult array] mutableCopy];
                                        
                                        for (Venue *item in result)
                                        {
                                            NSLog(@"name: %@", item.name);
                                            NSLog(@"distance: %@", item.location.distance);
                                            NSLog(@"checkins: %@", item.stats.checkins);
                                        }
                                        
                                        [self.tableView reloadData];
                                    }
                            failure:^(RKObjectRequestOperation *operaton, NSError *error)
                                    {
                                        NSLog (@"Mappattura FALLITA: %@ \n\nErrore: %@", operaton, error);
                                    }];
}

@end
