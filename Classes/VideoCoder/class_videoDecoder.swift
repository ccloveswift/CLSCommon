//
//  class_videoDecoder.swift
//  Pods
//
//  Created by TT on 2021/11/23.
//  Copyright © 2021年 TT. All rights reserved.
//

import Foundation
import AVFoundation
import MetalKit

public class class_videoDecoder {
    
    private var _uri: URL
    private var _asset: AVURLAsset?
    private var _track: AVAssetTrack?
    private var _reader: AVAssetReader?
    private var _readerTrackOutput: AVAssetReaderTrackOutput?
    
    private var _cacheMTLTexture: MTLTexture?
    private var _cacheCVMetalTextureCache: CVMetalTextureCache?
    private var _cacheCMSampleBuffer: CMSampleBuffer?
    private var _cacheCVMetalTexture: CVMetalTexture?
    /// 缓存的那一buff的时间对应的帧下标
    private var _cacheSampleBufferFrameIndex: Int
    /// 缓存 buffer 的时间
    private var _cacheSampleBufferTime: Double
    /// 希望的时间
    private var _wantTime: Double
    private var _wantSize: CGSize
    private var _width: Int
    private var _height: Int
    /// 1帧时间
    private var _oneFrameTime: Double
    /// 半帧时间
    private var _oneFrameTimeHalf: Double
    private var _fps: Double
    
    public init(_ uri: URL, _ size: CGSize) {
        _uri = uri
        _wantSize = size
        _width = 0;
        _height = 0;
        _wantTime = -1
        _cacheSampleBufferFrameIndex = -1
        _cacheSampleBufferTime = -1
        _oneFrameTime = 0
        _oneFrameTimeHalf = 0
        _fps = 0
        
        createAsset()
        recalculateSize()
    }
    
    deinit {
        CLSLogInfo("deinit")
        _asset = nil
        _track = nil
        _reader = nil
        _readerTrackOutput = nil
        _cacheMTLTexture = nil
        _cacheCVMetalTextureCache = nil
        _cacheCMSampleBuffer = nil
        _cacheCVMetalTexture = nil
    }
    
    private func createAsset() {
        
        _asset = AVURLAsset.init(url: _uri, options: [AVURLAssetPreferPreciseDurationAndTimingKey :  true])
        guard let asset = _asset else {
            assert(false)
            return
        }
        _track = asset.tracks(withMediaType: .video).first
        guard let track = _track else {
            assert(false)
            return
        }
        _fps = Double(track.nominalFrameRate)
        _oneFrameTime = 1.0 / _fps
        _oneFrameTimeHalf = _oneFrameTime / 2.0
    }
    
    private func releaseAsset() {
        
        _reader?.cancelReading()
        _reader = nil
        _asset?.cancelLoading()
        _asset = nil
    }
    
    private func recalculateSize() {
        
        let w = getWidth()
        let h = getHeight()
        var rW = Double(w);
        var rH = Double(h);
        if rW > _wantSize.width {
            
            let s = _wantSize.width / Double(w)
            rW *= s;
            rH *= s;
        }
        if rH > _wantSize.height {
            
            let s = _wantSize.height / Double(h)
            rW *= s;
            rH *= s;
        }
        _width = Int(rW)
        _height = Int(rH)
    }
    
    private func createAssetReader(_ startTime: Double)
    {
        guard let asset = _asset else {
            assert(false)
            return
        }
        guard let track = _track else {
            assert(false)
            return
        }
        
        do {
            _reader?.cancelReading()
            _reader = try AVAssetReader.init(asset: asset)
        }
        catch {
            CLSLogError("createAssetReader \(error)")
            assert(false)
            return
        }
        
        let pos = CMTimeMakeWithSeconds(startTime, preferredTimescale: asset.duration.timescale)
        let duration = CMTime.positiveInfinity
        _reader?.timeRange = CMTimeRangeMake(start: pos, duration: duration)
        
        _readerTrackOutput = AVAssetReaderTrackOutput.init(track: track,
                                                           outputSettings:[
                                                            kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA),
                                                            kCVPixelBufferWidthKey as String : OSType(_width),
                                                            kCVPixelBufferHeightKey as String : OSType(_height)
                                                           ])
        guard let rto = _readerTrackOutput else {
            assert(false)
            return
        }
        rto.alwaysCopiesSampleData = false
        if _reader?.canAdd(rto) ?? false {
            
            _reader?.add(rto)
            _reader?.startReading()
        }
    }
    
    private func getFrameIndex(_ time: Double) -> Int {
        
        var index = Int(time / _oneFrameTime)
        let diff = time - (Double(index) * _oneFrameTime);
        let diffP = diff / _oneFrameTime;
        if (diffP > 0.5) {
            index += 1
        }
        return index
    }
    
    private func getMTLTexture(_ buffer: CMSampleBuffer) -> MTLTexture? {
        
        let oimgBuff = CMSampleBufferGetImageBuffer(buffer)
        guard let imgBuff = oimgBuff else {
            assert(false)
            return nil
        }
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            assert(false)
            return nil
        }
        
        _cacheCVMetalTextureCache = nil
        
        _cacheCVMetalTextureCache = withUnsafeMutablePointer(to: &_cacheCVMetalTextureCache, { Ptr in
        
            let ret = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, Ptr)
            if ret != kCVReturnSuccess {
                assert(false)
                return nil
            }
            return Ptr.pointee
        })
        guard let textureCache = _cacheCVMetalTextureCache else {
            assert(false)
            return nil
        }
        
        let w = CVPixelBufferGetWidth(imgBuff)
        let h = CVPixelBufferGetHeight(imgBuff)
        
        _cacheCVMetalTexture = nil
        _cacheCVMetalTexture = withUnsafeMutablePointer(to: &_cacheCVMetalTexture) { Ptr in

            let ret = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imgBuff, nil, .bgra8Unorm, w, h, 0, Ptr)
            if ret != kCVReturnSuccess {
                assert(false)
                return nil
            }
            return Ptr.pointee
        }
        guard let texture = _cacheCVMetalTexture else {
            assert(false)
            return nil
        }
        
        return CVMetalTextureGetTexture(texture)
    }
    
    public func getTexture(time: Double) -> MTLTexture? {
        
        var ctime = time
        // 范围是 【 0 ～ 视频时长 】
        if ctime < 0 {
            ctime = 0;
        }
        else if ctime > getDuration() {
            ctime = getDuration()
        }
        
        // 判定是否直接返回纹理
        let isCopy0 = { abs(ctime - self._cacheSampleBufferTime) < self._oneFrameTimeHalf } // 是否在半帧内
        if isCopy0() {
            return _cacheMTLTexture
        }
        
        // 判定是否需要使用seek
        let isSeek0 = { self._wantTime == -1 } // 初始情况要seek一次
        let isSeek1 = { self._wantTime > ctime } // 往前拖动，想要的时间比我现在的时候小时，需要seek
        let isSeek2 = { abs(ctime - self._wantTime) > 5 }// 时间跨度达到了5秒，需要seek
        if isSeek0() || isSeek1() || isSeek2() {
            createAssetReader(ctime);
            _cacheSampleBufferFrameIndex = -1;
        }
        _wantTime = ctime
        
        // 获取纹理
        guard let rd = _reader else {
            assert(false)
            return nil
        }
        guard let rto = _readerTrackOutput else {
            assert(false)
            return nil
        }
        let wantFrameIndex = getFrameIndex(_wantTime)
        while rd.status == .reading {
            // 如果是一样的就直接返回
            if wantFrameIndex == _cacheSampleBufferFrameIndex {
                break
            }
            
            // 可以读取
            let obuffer = rto.copyNextSampleBuffer()
            guard let buffer = obuffer else {
                assert(false)
                break
            }
            
            let frameCMTime = CMSampleBufferGetOutputPresentationTimeStamp(buffer)
            if CMTIME_IS_INVALID(frameCMTime) {
                continue
            }
            
            let frameTime = CMTimeGetSeconds(frameCMTime);
            let frameIndex = getFrameIndex(frameTime);
            
            // ___               AAA                  ---
            _cacheCMSampleBuffer = buffer;
            _cacheSampleBufferFrameIndex = frameIndex;
            // ___               AAA                  ---
            
            if _cacheSampleBufferFrameIndex >= wantFrameIndex {
                // 需要返回这帧数据
                _cacheMTLTexture = getMTLTexture(buffer)
                break
            }
        }
        
        return _cacheMTLTexture
    }
    
    public func getDuration() -> Double {
        
        return _asset?.duration.seconds ?? 0
    }
    
    public func getWidth() -> Int {
        
        return Int(_track?.naturalSize.width ?? 0)
    }
    
    public func getHeight() -> Int {
        
        return Int(_track?.naturalSize.height ?? 0)
    }
}
