//
//  ImageViewController.m
//  Imaginarium
//
//  Created by Danny Ho on 3/25/16.
//  Copyright © 2016 thanksdanny. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ImageViewController

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    // 上面两行代码与setImage()保持一致，因为scrollView这个属性可能会在setImage这个方法执行后被设置
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
//    self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];// 因为这行是从网上获取，所以会阻塞进程
    [self startDownloadingImage];
}

- (void)startDownloadingImage {
    self.image = nil; // 下载新图片时，旧图片需要清空
    if (self.imageURL) {
        [self.spinner startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL * _Nullable localfile, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (!error) {
                    if ([request.URL isEqual:self.imageURL]) { // 该判断防止某个对象，修改了这个imageURL在下载过程中
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]]; // 因为这是一个本地文件，所以不会阻塞
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.image = image; // 要在主队列上执行
                        });
                        [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                    }
                }
            }];
        [task resume];
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    [self.imageView sizeToFit];
    // 记得设置contentsize
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero; // 优化一下，添加个三目防止传进image为空的情况
    [self.spinner stopAnimating];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

@end
