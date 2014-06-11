//
//  PhotoDetailsViewController.h
//  PhotoGallery
//
//  Created by Yadvendra on 6/9/14.
//  Copyright (c) 2014 Yadvendra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *fullScreenView;
@property (nonatomic,strong)UIImage *imageData;
@property (nonatomic,strong)NSString *imageTitle;
@property (nonatomic,strong)NSString *imageDate;
@property (nonatomic,strong)NSString *address;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end
