//
//  NRJson.m
//  PadDemo
//
//  Created by landyu on 2/28/14.
//  Copyright (c) 2014 landyu. All rights reserved.
//

#import "NRJson.h"

@implementation NRJson

//@synthesize arr1;
//@synthesize arr2;
//@synthesize dic;

-(NSString *) getStringWithKey:(id)key
{
//    NSArray * arr1 = [NSArray arrayWithObjects:@"dog",@"cat",nil];
//    
//    NSArray * arr2 = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],[NSNumber numberWithInt:30],nil];
    
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@[@"dog",@"cat"],@"pets",@[[NSNumber numberWithBool:YES],[NSNumber numberWithInt:30]],@"other",nil];
    
    
    
    
//NSError *error;
//    
//    if ([NSJSONSerialization isValidJSONObject:dic])
//    {
//        
//        NSData *registerData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
//        NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:registerData encoding:NSUTF8StringEncoding]);
//        
//        NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:registerData options:kNilOptions error:&error];
//        
//        NSString *status = [resultJSON objectForKey:key];
//        
//        //NSLog(@"%@", status);
//        
//        return status;
//
//    }
    
    
    //NSString *dirHome=NSHomeDirectory();
    //NSLog(@"app_home: %@",dirHome);
    
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSLog(@"app_home_doc: %@",documentsDirectory);
    
    //NSString *documentsPath =documentsDirectory;
    //NSString *configFileDirectory = [documentsPath stringByAppendingPathComponent:@"/Users/landyu/Work/xcode/xcode/CocoaAsyncSocket-master/GCD/Xcode/UdpEchoClient/Mobile/UdpEchoClient/"];
    //NSString *configFilePath = [configFileDirectory stringByAppendingPathComponent:@"TestJsonFile.geojson"];
    //    NSData *data = [NSData dataWithContentsOfFile:testPath];
    //    NSLog(@"文件读取成功: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSString *content=[NSString stringWithContentsOfFile:@"/Users/landyu/Work/xcode/xcode/CocoaAsyncSocket-master/GCD/Xcode/UdpEchoClient/Mobile/UdpEchoClient/TestJsonFile.geojson" encoding:NSUTF8StringEncoding error:nil];
    if(content != nil)
    NSLog(@"文件读取成功: %@",content);
    
    NSError *error;
    
    NSData *configData = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    
    //NSArray *configDataArray = [[NSArray alloc] init];
    //NSArray *configDataArray = [NSJSONSerialization JSONObjectWithData:configData options:kNilOptions error:&error];
    NSDictionary *configDataDictionary = [NSJSONSerialization JSONObjectWithData:configData options:kNilOptions error:&error];
    if (configDataDictionary != nil)
    {
        NSLog(@"configDataArray count : %lu\r\n", (unsigned long)[configDataDictionary count]);
        
        //NSArray *geonameId = [configDataArray objectForKey:@"geonameId"];
        //NSDictionary *floorCount = [floorCountArray objectAtIndex:0];
        //NSLog(@"floorCount : %@", geonameId);
        
        //NSArray *floor1Array = [configDataArray objectForKey:@"geonames"];
        //NSLog(@"floor1Array: %@\r\n  floor1Array count : %d\r\n",floor1Array, [floor1Array count]);
        
        //NSDictionary *room1 = [floor1Array objectAtIndex:0];
        //NSLog(@"room1 info: %@\t\n",room1);
        
        //int count = [room1 count];
        //NSLog(@"词典的数量为： %d",count);
        
        //得到词典中所有KEY值
        NSEnumerator * enumeratorKey = [configDataDictionary keyEnumerator];
        
        //快速枚举遍历所有KEY的值
        for (NSObject *levelObject in enumeratorKey) {
            NSLog(@"遍历KEY的值: %@",levelObject);
            
            NSDictionary *level1DataDictionary = [configDataDictionary objectForKey:levelObject];
            //NSString *level1String =[level1Array  componentsJoinedByString:@","];
            //NSData *level1Data = [NSKeyedArchiver archivedDataWithRootObject:level1Array];
            //NSData *level1Data = [level1String dataUsingEncoding:NSUTF8StringEncoding];
            //NSData *level1Data = [NSKeyedArchiver archivedDataWithRootObject:level1Array];
            //NSDictionary *level1DataDictionary = [NSJSONSerialization JSONObjectWithData:level1Data options:kNilOptions error:&error];
            //NSDictionary *level1DataDictionary = [floor1Array objectAtIndex:0];
            
            NSLog(@"level1 info: %@\t\n",level1DataDictionary);
            NSArray *level1Id = [level1DataDictionary objectForKey:@"id"];
            NSLog(@"level1 id : %@\t\n", level1Id);
            
            NSEnumerator * level1EnumeratorKey = [level1DataDictionary keyEnumerator];
            for (NSObject *subObject in level1EnumeratorKey)
            {
                if (![subObject  isEqual: @"id"])
                {
                    NSDictionary *level1SubDataDictionary = [level1DataDictionary objectForKey:subObject];
                    NSLog(@"%@ level1 sub %@ info: %@\t\n",levelObject ,subObject, level1SubDataDictionary);
                }
            }
//            NSDictionary *level1 = [level1Array objectAtIndex:0];
            
        }
        
        
        //NSLog(@" \n configDataArray 的东东个数：%d ",[configDataArray count]);
        //NSLog(@" \n configDataArray 的东东个数：%@ ",[configDataArray objectAtIndex:0]);
        //NSString *status = [configDataArray objectAtIndex:0];
//        if (status != nil)
//            {
//                return status;
//            }
    }
    
    //NSMutableData * configData = [[NSMutableData alloc] initWithBytes:(__bridge const void *)(content) length:content.length];
    
//    NSData *registerData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    
//    NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:configData options:kNilOptions error:&error];
//    if(resultJSON != nil)
//    {
//        NSString *status = [resultJSON objectForKey:key];
//        if (status != nil) {
//            return status;
//        }
//    }
    
    
    
    return Nil;
}

@end
