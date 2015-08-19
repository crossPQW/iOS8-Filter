//
//  ViewController.m
//  iOS8-Filter
//
//  Created by 黄少华 on 15/8/19.
//  Copyright (c) 2015年 黄少华. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIPickerView *alert;

@property (nonatomic, strong) UIImage *orgImage;
@property (nonatomic, strong) NSArray *items;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.orgImage = self.image.image;
    self.image.image = self.orgImage;
    self.items = @[@"Original",
                   @"CIGlassDistortion",
                   @"CIDivideBlendMode",
                   @"CILinearBurnBlendMode",
                   @"CILinearDodgeBlendMode",
                   @"CIPinLightBlendMode",
                   @"CISubtractBlendMode",
                   ];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.items.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.items[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row == 0) {
        self.image.image = self.orgImage;
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        
        CIImage *ciImage = [[CIImage alloc] initWithImage:self.orgImage];
        
        NSDictionary *params = @{kCIInputImageKey: ciImage,
                                 };
        CIFilter *filter = [CIFilter filterWithName:self.items[row] withInputParameters:params];
        [filter setDefaults];
        
        // param for distortion
        if ([filter respondsToSelector:NSSelectorFromString(@"inputTexture")]) {
            CIImage *ciTextureImage = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"grassdistortion"]];
            [filter setValue:ciTextureImage forKey:@"inputTexture"];
        }
        
        // params for blend mode
        if ([filter respondsToSelector:NSSelectorFromString(@"inputBackgroundImage")]) {
            CIImage *ciOverlayImage = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"m5full3"]];
            [filter setValue:ciImage forKey:@"inputBackgroundImage"];
            [filter setValue:ciOverlayImage forKey:kCIInputImageKey];
        }
        
        // Apply filter
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *outputImage = [filter outputImage];
        CGImageRef cgImage = [context createCGImage:outputImage
                                           fromRect:[outputImage extent]];
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // draw
            self.image.image = image;
        });
        
    });
}
@end
