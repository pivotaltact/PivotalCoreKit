#import <Cedar/SpecHelper.h>

#import "NSObject+MethodRedirection.h"

using namespace Cedar::Matchers;

@interface Redirectable : NSObject

+ (int)embiggen:(int)number;
- (NSString *)cheekify:(NSString *)string;

@end

@interface Redirectable (redirected_methods)

+ (int)embiggen_original:(int)number;
- (NSString *)cheekify_original:(NSString *)string;

@end

@implementation Redirectable

+ (int)embiggen:(int)number {
    return number + 1;
}

+ (int)embiggen_new:(int)number {
    return [self embiggen_original:number] + 1;
}

- (NSString *)cheekify:(NSString *)string {
    return [NSString stringWithFormat:@"%@ is so cheeky", string];
}

- (NSString *)cheekify_new:(NSString *)string {
    return [NSString stringWithFormat:@"No, really, %@", [self cheekify_original:string]];
}

@end

SPEC_BEGIN(NSObject_MethodRedirectionSpec)

describe(@"NSObject_MethodRedirection", ^{
    __block Redirectable *redirectable;

    beforeEach(^{
        redirectable = [[[Redirectable alloc] init] autorelease];
    });

    describe(@"redirecting instance methods", ^{
        it(@"should redirect calls to the original selector to the new implementation, and expose the original implementation via a renamed selector", ^{
            [redirectable cheekify:@"Herman"] should equal(@"Herman is so cheeky");

            [Redirectable redirectSelector:@selector(cheekify:) to:@selector(cheekify_new:) andRenameItTo:@selector(cheekify_original:)];

            [redirectable cheekify:@"Herman"] should equal(@"No, really, Herman is so cheeky");
        });

        it(@"should explode when a redirect is attempted twice", ^{
            ^{
                [Redirectable redirectSelector:@selector(cheekify:) to:@selector(cheekify_new:) andRenameItTo:@selector(cheekify_original:)];
            } should raise_exception();
        });
    });

    describe(@"redirecting class methods", ^{
        it(@"should redirect calls to the original selector to the new implementation, and expose the original implementation via a renamed selector", ^{
            [Redirectable embiggen:1] should equal(2);

            [Redirectable redirectClassSelector:@selector(embiggen:) to:@selector(embiggen_new:) andRenameItTo:@selector(embiggen_original:)];

            [Redirectable embiggen:1] should equal(3);
        });

        it(@"should explode when a redirect is attempted twice", ^{
            ^{
                [Redirectable redirectClassSelector:@selector(embiggen:) to:@selector(embiggen_new:) andRenameItTo:@selector(embiggen_original:)];
            } should raise_exception();
        });
    });
});

SPEC_END
