//
//  Unoptimize.m
//  Carmine
//
//  Created by WhitetailAni on 7/28/24.
//

#import <Foundation/Foundation.h>
#import "Unoptimize.h"

void unoptimize(void) {
    __asm__ volatile ("nop");
}
