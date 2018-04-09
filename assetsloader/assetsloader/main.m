//
//  main.m
//  assetsloader
//
//  Created by kevinliu on 3/30/18.
//  Copyright © 2018 jamcity. All rights reserved.
//
//  ----------------------------------------------
//
//  Asset loader for loading assets from iOS extensions/structures
//  Currently only work for loading icons from Assets.car and save to specific folder
//
//  Since loading car file using private runtime lib, which may be broken silently if Apple changes anything.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "CoreUI.h"

/**
 * The filename got from rendition has extension, remove it to get the filename
 */
NSString * removeExtension(NSString * filename)
{
    NSArray *myWords = [filename componentsSeparatedByString:@"."];
    return myWords[0];
}

/**
 * Generate asset name in similar to Apple format.
 */
NSString * generateAssetName(NSString * name, CGFloat scale)
{
    if(scale > 1.0)
    {
        return [NSString stringWithFormat:@"%@@%.0fx.png", name, scale];
    }
    else
    {
        return [NSString stringWithFormat:@"%@.png", name];
    }
}

/**
 * Extract image file from Assets.car.
 */
NSMutableArray <NSDictionary <NSString *, NSObject *> *> * extractFromCarFile(NSString * carPath)
{
    // Load catalog
    NSError *catalogError;
    CUICatalog *myCatalog = [[CUICatalog alloc] initWithURL:[NSURL fileURLWithPath:carPath] error:&catalogError];
    // Prepare return place
    NSMutableArray <NSDictionary <NSString *, NSObject *> *> * imageReps = [[NSMutableArray alloc] init];
    // Check each objects
    [[myCatalog _themeStore].themeStore.allAssetKeys enumerateObjectsWithOptions:0 usingBlock:^(CUIRenditionKey * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        CUIThemeRendition *rendition = [[myCatalog _themeStore] renditionWithKey:key.keyList];
        NSString *filename = generateAssetName(removeExtension(rendition.name), rendition.scale);
        // Only target unslicedImage
        if (rendition.unslicedImage) {
            NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:rendition.unslicedImage];
            imageRep.size = NSMakeSize(CGImageGetWidth(rendition.unslicedImage), CGImageGetHeight(rendition.unslicedImage));
            NSDictionary *desc = @{@"name" : rendition.name, @"filename": filename, @"imageRep": imageRep};
            [imageReps addObject:desc];
        }
    }];
    return imageReps;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if(argc < 2)
        {
            printf("Usage: assetloader <Assets.car path> [output directory]\n");
            return -1;
        }
        
        for(NSDictionary <NSString *, NSObject *> * imageObject in extractFromCarFile([NSString stringWithUTF8String:argv[1]]))
        {
            //NSData *data = [(NSBitmapImageRep *)imageObject[@"imageRep"] representationUsingType: NSPNGFileType properties: nil];
            NSData *data = [(NSBitmapImageRep *)imageObject[@"imageRep"] representationUsingType: NSPNGFileType properties: @{}];
            // if specifiy output folder
            if(argc > 2)
            {
                [data writeToFile: [NSString stringWithFormat: @"%@/%@", [NSString stringWithUTF8String:argv[2]], imageObject[@"filename"]] atomically: NO];
            }
            else
            {
                [data writeToFile: [NSString stringWithFormat: @"%@", imageObject[@"filename"]] atomically: NO];
            }
        }
    }
    return 0;
}
