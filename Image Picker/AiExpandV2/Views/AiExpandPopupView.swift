//
//  AiExpandPopupView.swift
//  Image Picker
//
//  Created by BCL Device-18 on 5/9/24.
//

import UIKit

class AiExpandPopupView: UIView {
    
    @IBOutlet private weak var popupBGView: UIView!
    @IBOutlet private weak var popupBGViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var popupView: UIView!
    @IBOutlet private weak var popupNavView: UIView!
    @IBOutlet private weak var popupNavViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var videoContainerView: UIView!
    @IBOutlet public var videoPlayerView: PlaybackView!
    private var videoAsset: AVAsset?
    private var player: AVPlayer?
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var continueButton: UIButton!
    
    var closePressed: (() -> Void)? = nil
    var continuePressed: (() -> Void)? = nil
    
    private var height = SCREEN_HEIGHT //* 0.979661
    
//    private func preparePlayerView(videoUrl: URL){
//        self.videoAsset = AVAsset(url: videoUrl)
//        let avPlayerItem = AVPlayerItem(asset: self.videoAsset!)
//        videoPlayerView.shouldRepeatPlayer = true
//        videoPlayerView.setPlayerItem(avPlayerItem) { [weak self] itemDuration in
//            self?.videoPlayerView.setVideoFillMode(.resizeAspectFill)
//        }
//    }
    
    private func preparePlayerView(videoUrl: URL){
        self.videoAsset = AVAsset(url: videoUrl)
        let avPlayerItem = AVPlayerItem(asset: self.videoAsset!)
        player = AVPlayer(playerItem: avPlayerItem)
        videoPlayerView.setVideoPlayer(player)
        videoPlayerView.shouldAutoplay = true
        videoPlayerView.shouldRegisterNotification = true
        videoPlayerView.setVideoFillModelToAspectFill()

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        popupBGView.translatesAutoresizingMaskIntoConstraints = false
        popupView.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.layer.cornerRadius = 24
        videoContainerView.clipsToBounds = true

        self.isHidden = true
        popupBGViewBottomConstraint.constant = -height
                
        
        let window = UIApplication.shared.windows.first
        let safeAreaTopInset = window?.safeAreaInsets.top
        print("safeAreaTopInset ", safeAreaTopInset)
        
        popupNavViewTopConstraint.constant = safeAreaTopInset ?? 0
        
//        let safeAreaInset = UIApplication.getTopViewController()?.view.safeAreaInsets.bottom
//        let thumbImage = UIImage(named: "Widgets_Intro_Thumb")
        let videoFileUrl = Bundle.main.url(forResource: "AI Expand", withExtension: "mp4")

        preparePlayerView(videoUrl: videoFileUrl!)
    }
    
    func show(delay: Double = 0.0, completion: @escaping () -> Void?) {
        self.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.35, delay: delay) { [weak self] in
                self?.popupBGViewBottomConstraint.constant = 0
                self?.layoutIfNeeded()
            } completion: { [weak self] _ in
                completion()
//                self!.videoPlayerView.playPlayer()
                self?.videoPlayerView.player.play()
            }
        }
    }
    
    func hide(delay: Double = 0.0, completion: @escaping () -> Void?) {
        UIView.animate(withDuration: 0.35, delay: delay) { [weak self] in
            self?.popupBGViewBottomConstraint.constant = -self!.height
            self?.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.isHidden = true
            completion()
//            self!.videoPlayerView.stopPlayer()
            self!.videoPlayerView.player.pause()

        }
    }
    
    @IBAction private func closeButtonPressed(_ sender: Any) {
        self.closePressed?()
    }
    
    @IBAction private func continueButtonPressed(_ sender: Any) {
        self.continuePressed?()
    }

}
