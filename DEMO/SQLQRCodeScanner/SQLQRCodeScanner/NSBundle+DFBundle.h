//
//  NSBundle+DFBundle.h
//  SQLPopViewController1
//
//  Created by DOFAR on 2021/4/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (DFBundle)
+ (NSBundle *)bundleWithBundleName:(NSString *)bundleName podName:(NSString *)podName;
@end

NS_ASSUME_NONNULL_END
