//
//  TACAnalyticsTests.m
//  TACSamplesTests
//
//  Created by erichmzhang(张恒铭) on 26/02/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TACCore/TACAnalytics.h>
@interface TACAnalyticsTests : XCTestCase

@end

@implementation TACAnalyticsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTrackPageAppearAndDisappear {
    static NSString* testPageName = @"testPageName";
    [TACAnalyticsService trackPageAppear:testPageName];
    XCTestExpectation* expectation = [self expectationWithDescription:@"track page"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TACAnalyticsService trackPageDisappear:testPageName];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:80 handler:nil];
}

- (void)testTrackSingleEvent {
    TACAnalyticsEvent* event = [TACAnalyticsEvent eventWithIdentifier:@"test_single_event"];
    [TACAnalyticsService trackEvent:event];
    
}

- (void)testTrackEventDuration {
    TACAnalyticsEvent* event = [TACAnalyticsEvent eventWithIdentifier:@"test_event_duration"];
    [TACAnalyticsService trackEventDurationBegin:event];
    XCTestExpectation* expectation = [self expectationWithDescription:@"track event duration"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TACAnalyticsService trackEventDurationEnd:event];
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:80 handler:nil];
}

- (void)testTrackEvnetDurationDirectly {
    TACAnalyticsEvent* event = [TACAnalyticsEvent eventWithIdentifier:@"test_event_duration_directly"];
    [TACAnalyticsService trackEvent:event duration:3.0f];
}

- (void)testTrackEventWithParamters {
    TACAnalyticsEvent* event = [TACAnalyticsEvent eventWithIdentifier:@"test_event_with_paramters" properties:[[TACAnalyticsProperties alloc] initWithDictionary:@{@"testParamters":@"testParamters"}]];
    [TACAnalyticsService trackEvent:event duration:3.0f];
}

@end
