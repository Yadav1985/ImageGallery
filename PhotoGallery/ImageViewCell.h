//
//  ImageViewCell.h
//  PhotoGallery
//
//  Created by Yadvendra on 6/9/14.
//  Copyright (c) 2014 Yadvendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageViewCell : UICollectionViewCell
@property(nonatomic, strong) ALAsset *asset;
@end
