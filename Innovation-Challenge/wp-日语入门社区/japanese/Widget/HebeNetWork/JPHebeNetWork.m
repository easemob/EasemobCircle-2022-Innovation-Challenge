//
// Created by LYQ on 16/8/5.
// Copyright (c) 2020 LYQ. All rights reserved.
//

#import "JPHebeNetWork.h"
@import MobileCoreServices;

@interface JPHebeNetWork()

@end

@implementation JPHebeNetWork
static NSURLSession *session;
static NSString *basicurl = @"http://www.baidu.com";
static NSInteger GET = 0;
static NSInteger POST = 1;
static NSInteger TIMEOUT = 10;
static BOOL Debug = YES;

/**
 * 获取NSURLSession
 * @return
 */
+ (NSURLSession *)session
{
    if (!session) {
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        cfg.timeoutIntervalForRequest = 10;
        // 是否允许使用蜂窝网络（手机自带网络）
        cfg.allowsCellularAccess = YES;
        session = [NSURLSession sessionWithConfiguration:cfg];
    }
    return session;
}

/**
 * 获取默认params
 * @return
 */
+ (NSMutableDictionary *)getParams {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"]){
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_token"] forKey:@"user_token"];
    }
    return params;
}

/**
 * 获取拼接好的内容
 * @param params
 * @param type
 * @return
 */
+(NSMutableString *)getStringParams:(NSMutableDictionary *)params method:(NSInteger)type{
    if (!params || params.count == 0)
        return @"";
    NSMutableString *paramString = [[NSMutableString alloc] init];
    if (type == GET){
        [paramString appendFormat:@"?"];
        for (NSString * key in params){
            [paramString appendFormat:key];
            [paramString appendFormat:@"="];
            [paramString appendFormat:(NSString *)[params objectForKey:key]];
            [paramString appendFormat:@"&"];
        }
        paramString = [paramString substringToIndex:paramString.length-1];
        return paramString;
    } else if (type == POST){
        for (id key in params){
            [paramString appendFormat:key];
            [paramString appendFormat:@"="];
            [paramString appendFormat:(NSString *)[params objectForKey:key]];
            [paramString appendFormat:@"&"];
        }
        paramString = [paramString substringToIndex:paramString.length-1];
        return paramString;
    } else{
        return nil;
    }
}

/**
 * get请求
 * @param partUrl 请求分地址
 * @param params 请求参数
 * @param succ 成功回调
 * @param fail 失败回调
 */
+ (void)get:(NSString *)partUrl params:(NSMutableDictionary *)params success:(void (^)(NSString *data))succ fail:(void (^)(NSString *data))fail {
    if (Debug){
        NSLog(@"\n请求接口:GET->%@\n请求参数:%@",partUrl,params.description);
    }
    NSMutableString *allurl = [[NSMutableString alloc] initWithFormat:basicurl];
    if (partUrl)
        [allurl appendFormat:partUrl];
    [allurl appendFormat:[self getStringParams:params method:GET]];
    NSURL *url = [NSURL URLWithString:allurl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT];
    NSURLSessionTask *task = [[self session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpurlResponse = (NSHTTPURLResponse *) response;
        if (!data||!response){
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error.localizedDescription);
            });

            if (Debug){
                NSLog(@"\n错误结果:GET->%@\n错误内容:%@",partUrl,error.localizedDescription);
            }
        } else{
            if (httpurlResponse.statusCode == 200){
                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (result){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        succ(result);
                    });

                    if (Debug)
                        NSLog(@"\n成功结果:GET->%@\n成功内容:%@",partUrl,result);
                } else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fail(@"返回结果为空(nil)");
                    });

                    if (Debug)
                        NSLog(@"\n失败结果:GET->%@\n失败内容%@",partUrl,@"返回结果为空(nil)");
                }
            } else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    fail([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                });

                if (Debug)
                    NSLog(@"\n失败结果:GET->%@\n失败内容%@",partUrl,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    }];
    [task resume];
}

/**
 * post请求
 * @param partUrl 请求分地址
 * @param params 请求参数
 * @param succ 成功回调
 * @param fail 失败回调
 */
+ (void)post:(NSString *)partUrl params:(NSDictionary *)params success:(void (^)(NSString *data))succ fail:(void (^)(NSString *data))fail {
    if (Debug){
        NSLog(@"\n请求接口:POST->%@\n请求参数:%@",partUrl,params.description);
    }
    NSMutableString *allurl = [NSMutableString stringWithFormat:basicurl];
    if (partUrl)
        [allurl appendFormat:partUrl];
    NSURL *url = [NSURL URLWithString:allurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[self getStringParams:params method:POST] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask *task = [[self session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpurlResponse = (NSHTTPURLResponse *) response;
        if (!data||!response){
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error.localizedDescription);
            });

            if (Debug){
                NSLog(@"\n错误结果:POST->%@\n错误内容:%@",partUrl,error.localizedDescription);
            }
        } else{
            if (httpurlResponse.statusCode == 200){
                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (result){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        succ(result);
                    });

                    if (Debug)
                        NSLog(@"\n成功结果:POST->%@\n成功内容:%@",partUrl,result);
                } else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fail(@"返回结果为空(nil)");
                    });
                    if (Debug)
                        NSLog(@"\n失败结果:POST->%@\n失败内容%@",partUrl,@"返回结果为空(nil)");
                }
            } else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    fail([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                });

                if (Debug)
                    NSLog(@"\n失败结果:POST->%@\n失败内容%@",partUrl,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    }];
    [task resume];
}

+ (void)postjson:(NSString *)partUrl params:(NSMutableDictionary *)params successjson:(void (^)(id json))successjson fail:(void (^)(NSString *data))fail {
    if (Debug){
        NSLog(@"\n请求接口:POST->%@\n请求参数:%@",partUrl,params.description);
    }
    NSMutableString *allurl = [NSMutableString stringWithFormat:basicurl];
    if (partUrl)
        [allurl appendFormat:partUrl];
    NSURL *url = [NSURL URLWithString:allurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[self getStringParams:params method:POST] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask *task = [[self session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpurlResponse = (NSHTTPURLResponse *) response;
        if (!data||!response){
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error.localizedDescription);
            });

            if (Debug){
                NSLog(@"\n错误结果:POST->%@\n错误内容:%@",partUrl,error.localizedDescription);
            }
        } else{
            if (httpurlResponse.statusCode == 200){
                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (result){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        successjson([NSJSONSerialization JSONObjectWithData:data options:nil error:nil]);
                    });

                    if (Debug)
                        NSLog(@"\n成功结果:POST->%@\n成功内容:%@",partUrl,result);
                } else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fail(@"返回结果为空(nil)");
                    });
                    if (Debug)
                        NSLog(@"\n失败结果:POST->%@\n失败内容%@",partUrl,@"返回结果为空(nil)");
                }
            } else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    fail([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                });

                if (Debug)
                    NSLog(@"\n失败结果:POST->%@\n失败内容%@",partUrl,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    }];
    [task resume];
}


/**
 * 设置是否输出参数
 * @param isDebug YES 输出 NO 不输出
 */
+ (void)setDebug:(BOOL)isDebug {
    Debug = isDebug;
}

/**
 * 上传一个NSData对象
 * @param partUrl 请求分地址
 * @param params 文字参数
 * @param data 上传文件或者图片对象
 * @param mimetype 类型
 * @param filekey 文件的key
 * @param filename 服务器保存的文件名
 * @param succ 成功回调
 * @param fail 失败回调
 */
+ (void)uploadOneData:(NSString *)partUrl params:(NSMutableDictionary *)params data:(NSData *)data mimetype:(NSString *)mimetype fileKeyName:(NSString *)filekey fileName:(NSString *)filename success:(void (^)(NSString *data))succ fail:(void (^)(NSString *data))fail {
    if (Debug){
        NSLog(@"\n请求接口:POST->%@\n请求参数:%@",partUrl,params.description);
    }
    NSMutableString *allurl = [NSMutableString stringWithFormat:basicurl];
    if (partUrl)
        [allurl appendFormat:partUrl];
    NSURL *url = [NSURL URLWithString:allurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT];
    NSString *boundary = [self generateBoundaryString];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [self createOneDataBodyWithBoundary:boundary parameters:params data:data mimetype:mimetype fileKeyName:filekey fileName:filename];
    NSURLSessionTask *task = [[self session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpurlResponse = (NSHTTPURLResponse *) response;
        if (!data||!response){
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error.localizedDescription);
            });

            if (Debug){
                NSLog(@"\n错误结果:POST->%@\n错误内容:%@",partUrl,error.localizedDescription);
            }
        } else{
            if (httpurlResponse.statusCode == 200){
                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (result){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        succ(result);
                    });

                    if (Debug)
                        NSLog(@"\n成功结果:POST->%@\n成功内容:%@",partUrl,result);
                } else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        fail(@"返回结果为空(nil)");
                    });
                    if (Debug)
                        NSLog(@"\n失败结果:POST->%@\n失败内容%@",partUrl,@"返回结果为空(nil)");
                }
            } else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    fail([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                });

                if (Debug)
                    NSLog(@"\n失败结果:POST->%@\n失败内容%@",partUrl,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    }];
    [task resume];
}

+ (void)loadImage:(UIImageView *)imageView imageurl:(NSString *)imageUrl {
    if (Debug){
        NSLog(@"\n图片地址:%@",imageUrl);
    }
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT];
    NSURLSessionTask *task = [[self session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data){
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = [[UIImage alloc] initWithData:data];
            });

        }
    }];
    [task resume];
}

/**
 * 获取一个Boundary
 * @return
 */
+ (NSString *)generateBoundaryString {
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

/**
 * 根据文件路径生成httpboddy
 * @param boundary 分割
 * @param parameters 文字参数
 * @param paths 文件路径
 * @param fieldName 服务器接收的key
 * @return
 */
+ (NSData *)createBodyWithBoundary:(NSString *)boundary parameters:(NSDictionary *)parameters paths:(NSArray *)paths fieldName:(NSString *)fieldName{
    NSMutableData *httpBody = [NSMutableData data];

    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];

    // add image data

    for (NSString *path in paths) {
        NSString *filename  = [path lastPathComponent];
        NSData   *data      = [NSData dataWithContentsOfFile:path];
        NSString *mimetype  = [self mimeTypeForPath:path];

        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    return httpBody;
}

/**
 * 根据data获得一个httpbody
 * @param boundary 分割符
 * @param parameters 文字参数
 * @param data data数据
 * @param mimetype 类型
 * @param fileKey 服务器的key
 * @param filename 服务器收到文件名
 * @return
 */
+ (NSData *)createOneDataBodyWithBoundary:(NSString *)boundary parameters:(NSDictionary *)parameters data:(NSData *)data mimetype:(NSString *)mimetype fileKeyName:(NSString *)fileKey fileName:(NSString *)filename{
    NSMutableData *httpBody = [NSMutableData data];

    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    NSLog([[NSString alloc]initWithData:httpBody encoding:NSUTF8StringEncoding]);
    // add image data

    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileKey, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:data];
    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    return httpBody;
}


/**
 * 根据文件路径获取文件类型
 * @param path
 * @return
 */
+ (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework

    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);

    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);

    CFRelease(UTI);

    return mimetype;
}


@end
