//
//  UIImage+LSDObjcSugar.m
//  LSDObjcSugar
//
//  Created by ls on 16/6/7.
//  Copyright © 2016年 szrd. All rights reserved.
//

#import "UIImage+LSDObjcSugar.h"

@implementation UIImage (LSDObjcSugar)

#pragma mark -- 类方法
+(UIImage *)lsd_singleDotImageWithColor:(UIColor *)color{

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), YES, 0);
    
    [color setFill];
    UIRectFill(CGRectMake(0, 0, 1, 1));
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;

}


//裁剪圆形图片的工具方法
+(UIImage *)lsd_imageClipWithImageName:(NSString *)imageName andBoardMargin:(CGFloat)BoardMargin andBackgroundColor:(UIColor *)color{
    
    //获取图片
    UIImage *image = [UIImage imageNamed:imageName];
    //要先画大圆 必须先确定绘制大圆所需要得位图上下文矩形大小
    CGFloat margin = BoardMargin;
    CGFloat bigRoundW = image.size.width + margin;
    CGFloat bigRoundH = image.size.height + margin;
    
    //开启位图上下文 设置size
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(bigRoundW, bigRoundH), NO, 0 );
    
    //获取图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //画大圆(用绘制椭圆的方法)
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, bigRoundW, bigRoundH));
    //设置大圆的颜色属性
    [color set];
    //渲染大圆
    CGContextFillPath(ctx);
    
    //然后再图片的大小范围内画小圆
    //先确定小圆的区域的size
    CGFloat smallRoundX = margin * 0.5;
    CGFloat smallRoundY = margin * 0.5;
    //画小圆  小圆既是要显示图片的区域
    CGContextAddEllipseInRect(ctx, CGRectMake(smallRoundX, smallRoundY, image.size.width, image.size.height));
    //裁剪小圆区域
    CGContextClip(ctx);
    
    //将图片绘制在这个小圆中
    [image drawInRect:CGRectMake(smallRoundX, smallRoundY, image.size.width, image.size.height)];
    
    //获取当前位图上下文
    UIImage *newImage =  UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭位图上下文
    UIGraphicsEndImageContext();
    
    return newImage;
    
}


+(UIImage *)lsd_imageClipScreenWithView:(UIView *)clipView{
    //开启位图上下文
    UIGraphicsBeginImageContext(clipView.frame.size);
    //获取当前的图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //截屏
    [clipView.layer renderInContext:ctx];
    
    //获取当前的图片
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭位图上下文
    UIGraphicsEndImageContext();
    
    
    //    因为保存到相册中,我们不需要转化图片
    //    <#UIImage * _Nonnull image#>:保存图片的队像
    //    <#id  _Nullable completionTarget#>:当图片保存后,要调用一个方法来监听保存的状况,这个参数用来表示谁调用这个方法
    //    contextInfo:表示要传递的参数
    //    [UIImageWriteToSavedPhotosAlbum(clipImage, self, @selector(image:didFinishSavingWithError:contextInfo:), @"12345" )] ;
    
    //返回当前截图
    return clipImage;
}

//
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
//    if (error) {
//        NSLog(@"保存失败");
//        
//    }else{
//        
//        NSLog(@"保存成功");
//        
//    }
//    
//    NSLog(@"%@",contextInfo);
//    
//    
//}
+(UIImage *)lsd_imageStrentchWithImageName:(NSString *)imageName{
    
    UIImage *image = [UIImage imageNamed:imageName];
    
    UIImage *strenchImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width *0.5, image.size.height * 0.5, image.size.width *0.5)];
    return strenchImage;
}


/**
 *  返回一张添加水印的图片并保存到document中
 */
+(UIImage *)lsd_waterImageWithBackground:(NSString *)bg logo:(NSString *)logo pathComponent:(NSString *)pathComponent{
    // 1、加载原图
    UIImage *bgImage = [UIImage imageNamed:bg];
    
    // 2、开启上下文
    UIGraphicsBeginImageContextWithOptions(bgImage.size, NO, 0.0);
    // 3、画背景图片
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    
    // 4、画右下角的水印
    UIImage *waterImage = [UIImage imageNamed:logo];
    // 4.1 图片缩放的比例
    CGFloat scale = 0.2;
    // 4.2 间距
    CGFloat margin = 5;
    // 4.3 设置水印的位置和尺寸
    CGFloat waterW = waterImage.size.width * scale;
    CGFloat waterH = waterImage.size.height *scale;
    CGFloat waterX = bgImage.size.width - waterW - margin;
    CGFloat waterY = bgImage.size.height - waterH - margin;
    [waterImage drawInRect:CGRectMake(waterX, waterY, waterW, waterH)];
    
    // 5、从上下文中取出制作完毕的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 6、结束上下文
    UIGraphicsEndImageContext();
    
    // 7、将image对象压缩成PNG格式的二进制数据
    NSData *data = UIImagePNGRepresentation(newImage);
    
    // 8、写入文件
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:pathComponent];
    [data writeToFile:path atomically:YES];
    
    return newImage;
}

//从一个大的图片中 区域截取图片的方法
+(UIImage *)lsd_clipImageWithBigImage:(UIImage *)bigImage andIndex:(NSInteger)index andSmallImageCount:(NSInteger)count{
    //由于运行设备不同 需要在获取图片的时候获得缩放倍数
    CGFloat screenScale = [UIScreen mainScreen].scale;
    //从一个大图片中 区域截取图片的方法
    UIImage *image = bigImage;
    
    CGFloat btnW = image.size.width / count * screenScale;
    CGFloat btnH = image.size.height * screenScale;
    CGImageRef clipImage = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(index * btnW , 0, btnW, btnH));
    
    return  [UIImage imageWithCGImage:clipImage scale:1.8 orientation:UIImageOrientationUp];
    
}

#pragma mark -- 对象方法
-(void)lsd_clipRoundImageWithSize:(CGSize)size fillColor:(UIColor *)fillColor completedBlock:(CompletedBlock)completedBlock{
    
    ///异步切圆
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ///开启图像的上下文
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
        
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        ///填充颜色
        [fillColor setFill];
        UIRectFill(rect);
        ///通过贝塞尔曲线来绘制路线
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        ///贝塞尔切圆操作
        [path addClip];
        
        ///将图片绘制到一个rect中
        [self drawInRect:rect];
        
        ///从当前图像上下文中获取到图片
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        ///关闭图形上下文
        UIGraphicsEndImageContext();
        
        ///回到主线程  通过block的回调来执行
        dispatch_async(dispatch_get_main_queue(), ^{
            ///使用block一定要判断是否有值
            if (completedBlock) {
                completedBlock(result);
            }
        });
        
        
        
    });
    
    
}





///截取部分图像
-(UIImage *)lsd_getSubImage:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect)
    ;
    
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    
    UIImage *smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return  smallImage;
}


#pragma mark - 方向校正方法
+(UIImage*)lsd_fixOrientation:(UIImage*)aImage
{
    
    //1. 如果图像朝上, 就返回
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    
    //2. 如果发现方向不对, 就旋转成图像朝上
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    //3. 镜像旋转
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    //4. 合成图像返回
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.height, aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.width, aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage* img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


//压缩图片
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}



//图片放大或压缩处理 ，图片放大倍数 0 ~ 2 之间 ，0~1 缩小图片，1~2 放大图片
/**
 *  根据image 返回放大或缩小之后的图片
 *
 *  @param image    原始图片
 *  @param multiple 放大倍数 0 ~ 2 之间
 *
 *  @return 新的image
 */
+ (UIImage *) createNewImageWithColor:(UIImage *)image multiple:(CGFloat)multiple
{
    CGFloat newMultiple = multiple;
    if (multiple == 0) {
        newMultiple = 1;
    }
    else if((fabs(multiple) > 0 && fabs(multiple) < 1) || (fabs(multiple)>1 && fabs(multiple)<2))
    {
        newMultiple = multiple;
    }
    else
    {
        newMultiple = 1;
    }
    CGFloat w = image.size.width*newMultiple;
    CGFloat h = image.size.height*newMultiple;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIImage *tempImage = nil;
    CGRect imageFrame = CGRectMake(0, 0, w, h);
    UIGraphicsBeginImageContextWithOptions(image.size, NO, scale);
    [[UIBezierPath bezierPathWithRoundedRect:imageFrame cornerRadius:0] addClip];
    [image drawInRect:imageFrame];
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tempImage;
}


@end












