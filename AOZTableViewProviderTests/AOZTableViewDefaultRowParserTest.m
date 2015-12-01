//
//  AOZTableViewDefaultRowParserTest.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/29.
//  Copyright © 2015年 Aozorany. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AOZTableViewDefaultConfigFileParserAddons.h"
#import "AOZTableViewCell.h"


@interface AOZTableViewDefaultRowParserTest : XCTestCase
@end


@implementation AOZTableViewDefaultRowParserTest {
    AOZTableViewDefaultRowParser *_rowParser;
    NSArray *_datasArray;
    NSArray *_emptyDatasArray;
}

#pragma mark setup and teardown
- (void)setUp {
    [super setUp];
    _rowParser = [[AOZTableViewDefaultRowParser alloc] init];
    _rowParser.dataProvider = self;
    _datasArray = @[@"1", @"2", @"3"];
    _emptyDatasArray = @[];
}

- (void)tearDown {
    _rowParser = nil;
    [super tearDown];
}

#pragma mark testCases
/** 测试存在性 */
- (void)testExistance {
    NSAssert(_rowParser != nil, @"_rowParser初始化后为空");
}

/** 测试非法输入情形 */
- (void)testIrregularLines {
    AOZTVPRowCollection *rowCollection = [_rowParser parseNewConfig:@""];
    NSAssert(rowCollection == nil, @"输入参数为空行的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"mode 0"];
    NSAssert(rowCollection == nil, @"输入参数为mode 0的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"section"];
    NSAssert(rowCollection == nil, @"输入参数为section的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"row"];
    NSAssert(rowCollection == nil, @"输入参数为row的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"row 1 2 3 4 5"];
    NSAssert(rowCollection == nil, @"输入参数为row 1 2 3 4 5的时候结果不为空");
}

/** 测试合法输入情形 */
- (void)testRegularLines {
    AOZTVPRowCollection *rowCollectionResult = [[AOZTVPRowCollection alloc] init];
    rowCollectionResult.rowRange = NSMakeRange(0, _datasArray.count);
    rowCollectionResult.dataConfig.cellClass = [AOZTableViewCell class];
    rowCollectionResult.dataConfig.source = _datasArray;
    rowCollectionResult.dataConfig.elementsPerRow = 1;
    AOZTVPRowCollection *rowCollection = [_rowParser parseNewConfig:@"row -s _datasArray"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _datasArray与预期结果不相等");
    
    rowCollectionResult.dataConfig.elementsPerRow = 2;
    rowCollectionResult.rowRange = NSMakeRange(0, ceil(_datasArray.count / 2.0f));
    rowCollection = [_rowParser parseNewConfig:@"row -s _datasArray -n 2"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _datasArray -n 2与预期结果不相等");
    
    rowCollectionResult.dataConfig.elementsPerRow = -1;
    rowCollectionResult.rowRange = NSMakeRange(0, 1);
    rowCollection = [_rowParser parseNewConfig:@"row -s _datasArray -all"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _datasArray -all与预期结果不相等");
    
    rowCollectionResult.dataConfig.elementsPerRow = 2;
    rowCollectionResult.rowRange = NSMakeRange(0, 0);
    rowCollection = [_rowParser parseNewConfig:@"row -s _emptyDatasArray -n 2"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _emptyDatasArray -n 2与预期结果不相等");
}

@end