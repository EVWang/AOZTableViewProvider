//
//  AOZTableViewDefaultConfigFileParser.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/28.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import "AOZTableViewDefaultConfigFileParser.h"
#import "AOZTableViewDefaultConfigFileParserAddons.h"


#pragma mark -
@implementation AOZTableViewDefaultConfigFileParser {
    NSString *_filePath;
    NSString *_configStr;
    AOZTableViewDefaultModeParser *_modeParser;
}

#pragma mark lifeCircle
- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = [filePath copy];
        _modeParser = [[AOZTableViewDefaultModeParser alloc] init];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)configStr {
    self = [super init];
    if (self) {
        _configStr = [configStr copy];
        _modeParser = [[AOZTableViewDefaultModeParser alloc] init];
    }
    return self;
}

#pragma mark public: setters
- (void)setDataProvider:(id)dataProvider {
    _modeParser.dataProvider = dataProvider;
}

- (void)setTableView:(UITableView *)tableView {
    _modeParser.tableView = tableView;
}

#pragma mark public: general
- (NSArray<AOZTVPMode *> *)parseConfigWithError:(NSError **)pError {
    @autoreleasepool {
        //读取，并分行
        NSArray<NSArray<NSString *> *> *linesArray = nil;
        if (_filePath.length > 0) {
            NSString *fileContentStr = [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:pError];
            linesArray = getLinesAndChunksArray(fileContentStr);
        } else if (_configStr.length > 0) {
            linesArray = getLinesAndChunksArray(_configStr);
        }
        
        //如果没有任何内容，则发起异常
        if (linesArray.count == 0) {
            if (pError) {
                *pError = [NSError errorWithDomain:AOZTableViewConfigFileParserErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"配置内容为空"}];
            }
            return nil;
        }
        
        //遍历每一行
        NSMutableArray<AOZTVPMode *> *modesArray = [[NSMutableArray alloc] init];
        NSMutableArray<NSArray<NSString *> *> *singleModeArray = nil;
        for (int index = 0; index < linesArray.count; index++) {
            NSArray<NSString *> *chunksArray = linesArray[index];
            
            if (chunksArray.count == 0) {
                continue;
            }
            
            NSString *prefix = chunksArray[0];
            if ([prefix isEqualToString:@"mode"]) {
                if (singleModeArray == nil) {
                    singleModeArray = [[NSMutableArray alloc] init];
                    [singleModeArray addObject:chunksArray];
                } else {
                    AOZTVPMode *mode = [_modeParser parseNewConfigs:singleModeArray error:pError];
                    if (mode) {
                        [modesArray addObject:mode];
                    }
                    singleModeArray = [[NSMutableArray alloc] init];
                    [singleModeArray addObject:chunksArray];
                }
            } else if ([prefix isEqualToString:@"section"] || [prefix isEqualToString:@"row"]) {
                if (singleModeArray == nil) {
                    singleModeArray = [[NSMutableArray alloc] init];
                }
                [singleModeArray addObject:chunksArray];
            }
        }
        
        //解析余项
        AOZTVPMode *mode = [_modeParser parseNewConfigs:singleModeArray error:pError];
        if (mode) {
            [modesArray addObject:mode];
        }

        return modesArray;
    }
}

@end
