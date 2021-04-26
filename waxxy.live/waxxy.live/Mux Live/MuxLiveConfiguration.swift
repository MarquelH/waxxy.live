//
//  MuxLiveConfiguration.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 11/6/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import Foundation
import AVFoundation
import CoreGraphics

/// MuxLive configuration
public class MuxLiveConfiguration {
}

/// MuxLive audio configuration
public class MuxLiveAudioConfiguration: MuxLiveConfiguration {
    
    /// Audio bit rate (kbps), AV dictionary key AVEncoderBitRateKey
    public var bitRate: Int = 96000
    
    /// Sample rate in hertz, AV dictionary key AVSampleRateKey
    public var sampleRate: Float64 = 44100
    
    /// Number of channels, AV dictionary key AVNumberOfChannelsKey
    public var channelsCount: Int?

}

/// MuxLive video configuration
public class MuxLiveVideoConfiguration: MuxLiveConfiguration {
    
    /// Video frame rate
    public var frameRate: CMTimeScale = 30
    
    /// Max video frame rate
    public var maxFrameRate: CMTimeScale = 30

    /// Min video frame rate
    public var minFrameRate: CMTimeScale = 15
    
    /// Video bit rate (kbps)
    public var bitRate: Int = 800000

    /// Max video bit rate (kbps)
    public var maxBitRate: Int = 960000
    
    /// Min video bit rate (kbps)
    public var minBitRate: Int = 600000
    
    /// Dimensions for video output, AV dictionary keys AVVideoWidthKey, AVVideoHeightKey
    public var dimensions: CGSize?
    
    /// Maximum interval between key frames, 1 meaning key frames only, AV dictionary key AVVideoMaxKeyFrameIntervalKey
    public var maxKeyFrameInterval: Int?
    
}
