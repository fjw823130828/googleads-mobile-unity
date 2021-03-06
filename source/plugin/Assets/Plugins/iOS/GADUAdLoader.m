// Copyright 2014 Google Inc. All Rights Reserved.

#import "GADUAdLoader.h"

#import "GADUNativeCustomTemplateAd.h"
#import "GADUObjectCache.h"
#import "GADUPluginUtil.h"
#import "UnityAppController.h"

@interface GADUAdLoader () <GADAdLoaderDelegate, GADNativeCustomTemplateAdLoaderDelegate>
@end

@implementation GADUAdLoader

- (instancetype)initWithAdLoaderClientReference:(GADUTypeAdLoaderClientRef *)adLoaderClient
                                       adUnitID:(NSString *)adUnitID
                                    templateIDs:(NSArray *)templateIDs
                                        adTypes:(NSArray *)adTypes
                                        options:(NSArray *)options {
  self = [super init];
  if (self) {
    _adLoaderClient = adLoaderClient;
    _adLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitID
                                   rootViewController:[GADUPluginUtil unityGLViewController]
                                              adTypes:adTypes
                                              options:options];
    _adLoader.delegate = self;
    _templateIDs = [NSArray arrayWithArray:templateIDs];
    _adTypes = [NSArray arrayWithArray:adTypes];
  }
  return self;
}

- (void)loadRequest:(GADRequest *)request {
  if (!self.adLoader) {
    NSLog(@"GoogleMobileAdsPlugin: AdLoader is nil. Ignoring ad request.");
    return;
  }
  [self.adLoader loadRequest:request];
}

- (NSArray *)nativeCustomTemplateIDsForAdLoader:(GADAdLoader *)adLoader {
  return self.templateIDs;
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
  if (self.adFailedCallback) {
    self.adFailedCallback(self.adLoaderClient, (__bridge GADUTypeErrorRef)error);
  }
}

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeCustomTemplateAd:(GADNativeCustomTemplateAd *)nativeCustomTemplateAd {
  if (self.customTemplateAdReceivedCallback) {
    GADUObjectCache *cache = [GADUObjectCache sharedInstance];
    GADUNativeCustomTemplateAd *internalNativeAd =
        [[GADUNativeCustomTemplateAd alloc] initWithAd:nativeCustomTemplateAd];
    cache[internalNativeAd.gadu_referenceKey] = internalNativeAd;
    self.customTemplateAdReceivedCallback(
        self.adLoaderClient, (__bridge GADUTypeNativeCustomTemplateAdRef)internalNativeAd,
        [nativeCustomTemplateAd.templateID cStringUsingEncoding:NSUTF8StringEncoding]);
  }
}

@end
