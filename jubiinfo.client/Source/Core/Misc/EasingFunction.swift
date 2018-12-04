//
//  EasingFunction.swift
//  jubiinfo
//
//  Created by ggomdyu on 03/02/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation

private let PI = 3.14159265358979

public func easeInSine(t: Double) -> Double {
    return sin( 1.5707963 * t );
}

public func easeOutSine(t: Double) -> Double {
    return 1 + sin((PI * 0.5) * (t - 1.0));
}

public func easeInOutSine(t: Double) -> Double {
    return 0.5 * (1 + sin( PI * (t - 0.5)));
}

public func easeInOutBack(t: Double) -> Double {
    if t < 0.5 {
        return t * t * (7 * t - 2.5) * 2;
    }
    else {
        let t2 = t - 1.0
        return 1 + t2 * t2 * 2 * (7 * t2 + 2.5);
    }
}

public func easeInCubic(t: Double) -> Double {
    return t * t * t;
}

public func easeOutBounce(t: Double) -> Double {
    return 1 - pow( 2, -6 * t ) * abs( cos( t * PI * 3.5 ) );
}

public func easeOutLowBounce(t: Double) -> Double {
    return 1 - pow( 2, -12 * t ) * abs( cos( t * PI * 3.5 ) );
}

public func easeOutQuad(t: Double) -> Double {
    return t * (2 - t);
}
