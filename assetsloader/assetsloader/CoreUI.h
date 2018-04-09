//
//  CoreUI.h
//  assetsloader
//
//  Created by kevinliu on 3/30/18.
//  Copyright © 2018 jamcity. All rights reserved.
//
//  ----------------------------------------------
//
//  Minimum runtime class used.
//

@interface CUIThemeRendition: NSObject

@property (nonatomic, readonly) CGImageRef unslicedImage;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) NSString *name;

@end

@interface CUIRenditionKey: NSObject

@property (readonly) struct _renditionkeytoken *keyList;

@end

@interface CUICommonAssetStorage: NSObject

@property (readonly) NSArray <CUIRenditionKey *> *allAssetKeys;

@end

@interface CUIStructuredThemeStore : NSObject

- (CUIThemeRendition *)renditionWithKey:(const struct _renditionkeytoken *)key;
@property (readonly) CUICommonAssetStorage *themeStore;

@end

@interface CUICatalog : NSObject

- (instancetype)initWithURL:(NSURL *)url error:(NSError **)outError;
- (CUIStructuredThemeStore *)_themeStore;

@end
