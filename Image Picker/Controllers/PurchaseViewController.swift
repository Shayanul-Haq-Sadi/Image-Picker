//
//  PurchaseViewController.swift
//  Image Picker
//
//  Created by BCL Device-18 on 2/6/24.
//

import UIKit
import AVFoundation

class PurchaseViewController: UIViewController {
    
    static let identifier = "PurchaseViewController"

    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var purchaseButton: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    var closeCompletion: (() -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addPlayer()
        watchNotifications()
    }
    
    private func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
        
        if PurchaseManager.shared.isPremiumUser {
            purchaseButton.setTitle("PURCHASED", for: .normal)
        }
    }
    
    private func addPlayer() {
        guard let url = Bundle.main.url(forResource: "purchaseVideo", withExtension: "mp4") else { return }
        
        player = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.playerView.bounds
        playerLayer?.videoGravity = .resizeAspect
        
        if let playerLayer {
            self.playerView.layer.addSublayer(playerLayer)
        }
        
        player?.play()
    }
    
    private func watchNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object:  player?.currentItem)
        NotificationCenter.default.addObserver( self, selector: #selector(applicationDidEnterBackgroundNotification(notification:)), name:UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(applicationWillEnterForeground(notification:)), name:UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func playerDidFinishPlaying(notification: Notification) {
        print("playerDidFinishPlaying")
        player?.seek(to: CMTime.zero)
        player?.play()
    }
    
    @objc func applicationDidEnterBackgroundNotification(notification: NSNotification)  {
        print("applicationDidEnterBackground")
        player?.pause()
    }
    
    @objc func applicationWillEnterForeground(notification: NSNotification)  {
        print("applicationWillEnterForeground")
        player?.play()
    }
    
    deinit {
        // Remove the observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
        
    @IBAction func purchaseButtonPressed(_ sender: Any) {
        PurchaseManager.shared.buy()
        if PurchaseManager.shared.isPremiumUser {
            purchaseButton.setTitle("PURCHASED", for: .normal)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {     
        closeCompletion?()
        player?.pause()
    }
    
}
