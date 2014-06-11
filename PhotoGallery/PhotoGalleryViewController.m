//
//  PhotoGalleryViewController.m
//  PhotoGallery
//
//  Created by Yadvendra on 6/9/14.
//  Copyright (c) 2014 Yadvendra. All rights reserved.
//

#import "PhotoGalleryViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import "PhotoDetailsViewController.h"
#import "ImageViewCell.h"


@interface PhotoGalleryViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *assets;
@property(nonatomic, strong) UIImage *slectedImage;

@end


@implementation PhotoGalleryViewController
{
    
    NSString *imageLoc;
}

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadImageData];
}
-(void)loadImageData
{
    _assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    // 1
    ALAssetsLibrary *assetsLibrary = [PhotoGalleryViewController defaultAssetsLibrary];
    // 2
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result)
            {
                // 3
                [tmpAssets addObject:result];
            }
        }];
        
        // 4
         self.assets = tmpAssets;
         [self.collectionView reloadData];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading images %@", error);
    }];
}
#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageViewCell *cell = (ImageViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageViewCell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[indexPath.row];
    cell.asset = asset;
    cell.backgroundColor = [UIColor redColor];
    
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

#pragma mark - segue function

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showFullPhoto"]) {
       
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        PhotoDetailsViewController *destViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        ALAsset *asset = self.assets[indexPath.row];
        ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
       
        UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage] scale:[defaultRep scale] orientation:0];
         destViewController.imageData = image;
        destViewController.imageDate = [self getDateString:[asset valueForProperty:ALAssetPropertyDate]];
        destViewController.imageTitle=[[asset defaultRepresentation] filename];
        destViewController.address=[self getLocationOfImage:[asset valueForProperty:ALAssetPropertyLocation]];
        
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

//Get location of captured imge
-(NSString*)getLocationOfImage:(CLLocation*)imageLocation
{
    //last year and it would return the date and time I 'modified' the image).
    
    if (imageLocation!=nil) {
    
    NSString *latitude  = [NSString stringWithFormat:@"%g",imageLocation.coordinate.latitude];
    NSLog(@"Found Latitude:%@",latitude);
    NSString *longitude = [NSString stringWithFormat:@"%g",imageLocation.coordinate.longitude];
    NSLog(@"Found Longitude:%@",longitude);
        CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
        [geocoder reverseGeocodeLocation:imageLocation
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                           
                           if (error){
                               NSLog(@"Geocode failed with error: %@", error);
                               return;
                           }
                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                           
                           imageLoc = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                       placemark.subThoroughfare, placemark.thoroughfare,
                                       placemark.postalCode, placemark.locality,
                                       placemark.administrativeArea,
                                       placemark.country];
                        }];
    
    }
    
    return imageLoc;
}

//get date coverted to string
-(NSString*)getDateString:(NSDate*)date
{
    NSString *imgdate =@"";
    if (date!=nil)
    {
        //date formatter for the above string
        NSDateFormatter *dateFormatterWS = [[NSDateFormatter alloc] init];
        [dateFormatterWS setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        
        NSString *strdate =[dateFormatterWS stringFromDate:date];
        NSDate *stringForNewDate = [dateFormatterWS dateFromString:strdate];
        
        NSDateFormatter *dateFormatterNews = [[NSDateFormatter alloc] init];
        [dateFormatterNews setDateFormat:@"dd-MMM-yyyy hh:mm:ss"];
        
        imgdate =[NSString stringWithFormat:@"Date: %@",[dateFormatterNews stringFromDate:stringForNewDate]];
       
    }
   return imgdate;
}


#pragma mark - assets

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark - Actions

- (IBAction)takePhotoButtonTapped:(id)sender
{
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO))
    {
        
       UIAlertView *alert=[ [UIAlertView alloc]initWithTitle:@"Alert" message:@"Camera feature not supported in simulator" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:nil];
}

- (IBAction)albumsButtonTapped:(id)sender
{
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary] == NO))
        return;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:nil];
    
}

#pragma mark - image picker delegate


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = (UIImage *) [info objectForKey:
                                  UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        // Do something with the image
        [self saveImageToAssetLibrary:image];
    }];
}

-(void)saveImageToAssetLibrary:(UIImage *)image
{
    
    ALAssetsLibrary *assetsLibrary = [PhotoGalleryViewController defaultAssetsLibrary];
    [assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:0 completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error!=nil) {
            
        }else{
            [self loadImageData];
        }
    }];
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	
}
*/

@end
