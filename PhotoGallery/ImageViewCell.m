//
//  ImageViewCell.m
//  PhotoGallery
//
//  Created by Yadvendra on 6/9/14.
//  Copyright (c) 2014 Yadvendra. All rights reserved.
//

#import "ImageViewCell.h"
@interface ImageViewCell ()
@property(nonatomic, weak) IBOutlet UIImageView *photoImageView;
@end

@implementation ImageViewCell

- (instancetype)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setAsset:(ALAsset *)asset
{
    _asset = asset;
    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
}

@end
