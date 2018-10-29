//
//  ViewController.m
//  FileDiffTool
//
//  Created by 白云 on 2018/10/26.
//  Copyright © 2018 byxc. All rights reserved.
//

#import "ViewController.h"
#import "BYDragDropView.h"

@interface ViewController () <BYDragDropViewDelegate>

/// 去重数组
@property (nonatomic, strong) NSMutableDictionary *cacheFragments;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cacheFragments = [NSMutableDictionary dictionary];
    BYDragDropView *view = (BYDragDropView *)self.view;
    view.delegate = self;
}

#pragma mark - BYDragDropViewDelegate
- (void)disposeDragingFiles:(NSArray *)files {
    NSString *path = files.firstObject;
    NSError *error = nil;
    NSString *string = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSArray *codes = [string componentsSeparatedByString:@"\n"];
    NSMutableArray *cacheArr = [NSMutableArray arrayWithArray:codes];
    [_cacheFragments removeAllObjects];
    for (NSString *string in codes) {
        if ([string hasPrefix:@"#define"]) {
            // 处理并替换字符
            NSString *changeString = [self changeString:string];
            [cacheArr replaceObjectAtIndex:[cacheArr indexOfObject:string] withObject:changeString];
        }
    }
    // 生成并写入新文件
    NSString *newString = [cacheArr componentsJoinedByString:@"\n"];
    NSString *newPath = nil;
    if ([path hasSuffix:@".h"]) {
        newPath = [path stringByReplacingOccurrencesOfString:@".h" withString:@"_new.h"];
    }
    else {
        newPath = [path stringByAppendingString:@"_new.h"];
    }
    BOOL state = [newString writeToFile:newPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (state) {
        NSLog(@"写入成功!");
    }
    else {
        NSLog(@"写入失败: %@",error);
    }
}

- (NSString *)changeString:(NSString *)string {
    NSString *relust = nil;
    NSRange keyRange = NSMakeRange(0, 0);
    NSString *keyString = nil;
    NSString *orignKeyString = nil;
    NSMutableArray *fragments = [NSMutableArray arrayWithArray:[string componentsSeparatedByString:@" "]];
    if (3 == fragments.count) {
        NSString *code = fragments[1];
        NSString *orignCode = fragments[2];
        if ([code hasPrefix:@"_is"]) {
            if (5 < code.length) {
                // 替换"_is"后的两个字符
                keyRange = NSMakeRange(3, 2);
            }
        }
        else if ([code hasPrefix:@"_"]) {
            if (3 < code.length) {
                // 替换"_"后的两个字符
                keyRange = NSMakeRange(1, 2);
            }
        }
        else if ([code hasPrefix:@"setIs"]) {
            if (7 < code.length) {
                // 替换"setIs"后的两个字符
                keyRange = NSMakeRange(5, 2);
            }
        }
        else if ([code hasPrefix:@"set"]) {
            if (5 < code.length) {
                // 替换"set"后的两个字符
                keyRange = NSMakeRange(3, 2);
            }
        }
        else if ([code hasPrefix:@"is"]) {
            if (4 < code.length) {
                // 替换"is"后的两个字符
                keyRange = NSMakeRange(2, 2);
            }
        }
        else if ([code hasPrefix:@"init"]) {
            if (6 < code.length) {
                // 替换"init"后的两个字符
                keyRange = NSMakeRange(4, 2);
            }
        }
        else {
            if (2 < code.length) {
                // 替换前两个字符
                keyRange = NSMakeRange(0, 2);
            }
        }
        if (0 < keyRange.length) {
            // 计算缓存key
            NSString *endString = [code substringFromIndex:keyRange.location];
            if (0 < endString.length) {
                NSString *firstString = [endString substringToIndex:1];
                NSString *newFirstString = [firstString lowercaseString];
                endString = [endString stringByReplacingOccurrencesOfString:firstString withString:newFirstString];
            }
            NSString *randomString = nil;
            // 取字符
            keyString = [code substringWithRange:keyRange];
            orignKeyString = [orignCode substringWithRange:keyRange];
            // 判重
            if ([_cacheFragments.allKeys containsObject:endString]) {
                // 取缓存
                randomString = [_cacheFragments objectForKey:endString];
            }
            else {
                randomString = [self getRandomStringWithLength:keyString.length];
                // 避免重复
                while ([randomString isEqualToString:keyString] || [randomString isEqualToString:orignKeyString]) {
                    randomString = [self getRandomStringWithLength:keyString.length];
                }
                // 缓存已计算的字符串
                [_cacheFragments setObject:randomString forKey:endString];
            }
            relust = [code stringByReplacingOccurrencesOfString:keyString withString:randomString];
            [fragments replaceObjectAtIndex:2 withObject:relust];
        }
    }
    
    return [fragments componentsJoinedByString:@" "];
}

#pragma makr - Random
- (NSString *)getRandomStringWithLength:(NSInteger)len {
    NSMutableString *string = [NSMutableString string];
    for (NSInteger i = 0; i < len; i++) {
        [string appendString:[self getRandomString]];
    }
    return string;
}

- (NSString *)getRandomString {
    static NSString *string = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSInteger index = arc4random()%string.length;
    return [string substringWithRange:NSMakeRange(index, 1)];
}

@end
