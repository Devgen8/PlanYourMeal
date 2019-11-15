//
//  LoginViewController.swift
//  PlanYourMeal
//
//  Created by мак on 23/10/2019.
//  Copyright © 2019 мак. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class LoginViewController: UIViewController {
    
    var videoPlayer: AVPlayer?
    
    var videoPlayerLayer: AVPlayerLayer?

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpOutlets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpVideo()
        
    }
    
    func setUpOutlets() {
        Design.styleFilledButton(signUpButton)
        Design.styleHollowButton(signInButton)
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    
    
    @IBAction func signInTapped(_ sender: UIButton) {
        navigationController?.pushViewController(SignInViewController(), animated: true)
    }
    
    func setUpVideo() {
        let bundlePath = Bundle.main.path(forResource: "IMG_2299", ofType: "MOV")
        
        guard bundlePath != nil else { return }
        
        let url = URL(fileURLWithPath: bundlePath!)
        
        let item = AVPlayerItem(url: url)
        
        videoPlayer = AVPlayer(playerItem: item)
        
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height)
        
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        videoPlayer?.playImmediately(atRate: 0.6)
        
        videoPlayer?.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.videoDidPlayToEnd(_:)), name: Notification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: videoPlayer?.currentItem)
    }
    
    
    @objc func videoDidPlayToEnd(_ notification: Notification) {
        let player = notification.object as? AVPlayerItem
        player?.seek(to: .zero, completionHandler: nil)
    }
}
