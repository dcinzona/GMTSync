//
//  GMTSync.mm
//  GMTSync
//
//  Created by Gustavo Tandeciarz on 3/23/12.
//  Copyright (c) 2012 GMTAZ.com. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <Foundation/Foundation.h>
#import "CaptainHook/CaptainHook.h"
#import <UIKit/UIKit.h>

CHDeclareClass(GMTThemeSync); // declare class
CHDeclareClass(themeConverter); // declare class
CHDeclareClass(GMTHelper); // declare class

CHMethod0(BOOL, GMTThemeSync, testHook){
    
    NSLog(@"Test PASSED");
    return YES;
    
}
CHMethod0(BOOL, GMTThemeSync, respring){
    
    NSLog(@"Respinging from hook");
    system("killall lsd SpringBoard");
    return YES;
    
}

CHMethod0(BOOL, themeConverter, checkIfJB){
    
    NSLog(@"ThemeConverter (hooked) checkIfJB PASSED");
    return YES;
    
}
CHMethod0(BOOL, GMTHelper, checkIfJB){
    
    NSLog(@"GMTHelper (hooked) checkIfJB PASSED");
    return YES;
    
}

CHMethod0(NSString *, GMTHelper, getGMTSyncVersion){
    
    NSLog(@"getting GMTSync version from hook");
    return @"1.1-7";
    
}
CHMethod0(NSString *, GMTThemeSync, getGMTSyncVersion){
    
    NSLog(@"getting GMTSync version from hook");
    return @"1.1-7";
    
}
CHMethod0(BOOL, themeConverter, checkIfThemeInstalled){
    
    NSLog(@"checkIfThemeInstalled from tweak");
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *themeDirPath = @"/Library/Themes/TypoClockBuilder.theme";
    BOOL exists = [fm fileExistsAtPath:themeDirPath];
    
    if(exists)
        NSLog(@"checkIfThemeInstalled found theme");
    else
        NSLog(@"checkIfThemeInstalled did not find theme");
    
    return exists;
    
}

CHMethod2( BOOL, GMTThemeSync, syncFilesFromPath, NSString *, sourcePath, toPath, NSString *, target){
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error;
        NSArray *fileList = [fm contentsOfDirectoryAtPath:sourcePath error:&error];
            if(fileList == nil){
                NSLog(@"Error: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error Copying Files" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                });
            }
            else {
                
                BOOL ret = NO;
                for (NSString *fileName in fileList){
                    
                    NSString *sourceFile = [sourcePath stringByAppendingPathComponent:fileName];
                    NSString *targetFile = [target stringByAppendingPathComponent:fileName];
                    NSError *fileCopyError;
                    if([fm fileExistsAtPath:targetFile]){
                        NSLog(@"%@ exists at target.  Deleting...", fileName);
                        NSError *errorDeleting;
                        if(![fm removeItemAtPath:targetFile error:&errorDeleting]){
                            NSLog(@"Error deleting %@:\n%@",fileName,errorDeleting.localizedDescription);
                        }
                    }
                    if([fm copyItemAtPath:sourceFile toPath:targetFile error:&fileCopyError]){
                        ret = YES;
                    }
                    else {
                        NSLog(@"Error copying %@ to %@ \n%@",sourceFile,targetFile,fileCopyError.localizedDescription);
                        ret = NO;
                        //break;
                    }
                    
                }
            }
        
        NSLog(@"logged from tweak");
    });
    return YES;
}

CHMethod2( BOOL, GMTThemeSync, syncFilesArray, NSArray *, fileList, toFolderAtPath, NSString *, targetFolder){
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSFileManager *fm = [NSFileManager defaultManager];
        
        BOOL ret = NO;
        for (NSString *filePath in fileList){
            
            NSString *sourceFileName = [[filePath pathComponents] objectAtIndex:[filePath pathComponents].count-1 ];
            NSString *targetFilePath = [targetFolder stringByAppendingPathComponent:sourceFileName];
            NSError *fileCopyError;
            if([fm fileExistsAtPath:targetFilePath]){
                NSLog(@"%@ exists at target.  Deleting...", sourceFileName);
                NSError *errorDeleting;
                if(![fm removeItemAtPath:targetFilePath error:&errorDeleting]){
                    NSLog(@"Error deleting %@:\n%@",sourceFileName,errorDeleting.localizedDescription);
                }
            }
            if([fm copyItemAtPath:filePath toPath:targetFilePath error:&fileCopyError]){
                ret = YES;
            }
            else {
                NSLog(@"Error copying %@ to %@ \n%@",sourceFileName,targetFilePath,fileCopyError.localizedDescription);
                ret = NO;
                //break;
            }
            
        }
    });
    
    return YES;
    
}

CHMethod2( BOOL, GMTThemeSync, syncFileAtPath, NSString *, filePath, toFolderAtPath, NSString *, targetFolder){
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSError *error;
        NSString *fileName = [[filePath pathComponents] objectAtIndex:filePath.pathComponents.count-1];
        if ([fm fileExistsAtPath:targetFolder]) {
            if(![fm removeItemAtPath:[targetFolder stringByAppendingString:fileName] error:&error]){
                NSLog(@"Error removing file %@:\n%@",[targetFolder stringByAppendingString:fileName],error.localizedDescription);
            }
        }           
        if(![fm copyItemAtPath:filePath toPath:[targetFolder stringByAppendingString:fileName] error:&error]){
            NSLog(@"Error copying filePath: \n%@\nTo Path:\n%@\nError:%@",filePath,targetFolder,error.localizedDescription);
        }
        
        
    });
    
    return YES;
}

CHMethod1(BOOL, GMTThemeSync, deleteFileAtPath, NSString *, targetFile){
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSError *error;
        if ([fm fileExistsAtPath:targetFile]) {
            if(![fm removeItemAtPath:targetFile error:&error]){
                NSLog(@"Error removing file %@:\n%@",targetFile,error.localizedDescription);
            }
        }
        
        
    });
    
    return YES;
}
CHConstructor // code block that runs immediately upon load
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    CHLoadLateClass(GMTThemeSync);
    CHLoadLateClass(themeConverter);
    
    CHHook0( GMTThemeSync, testHook);
    CHHook0( GMTThemeSync, respring);
    CHHook0( GMTThemeSync, getGMTSyncVersion);
    CHHook0( GMTHelper, getGMTSyncVersion);
    CHHook0( themeConverter, checkIfJB);
    CHHook0( GMTHelper, checkIfJB);
    CHHook0( themeConverter, checkIfThemeInstalled);
	CHHook2( GMTThemeSync, syncFilesFromPath, toPath);
	CHHook2( GMTThemeSync, syncFilesArray, toFolderAtPath);
	CHHook2( GMTThemeSync, syncFileAtPath, toFolderAtPath);
	CHHook1( GMTThemeSync, deleteFileAtPath);
	
	[pool drain];
}
