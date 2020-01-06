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
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private var videoPlayer: AVPlayer?
    private var videoPlayerLayer: AVPlayerLayer?
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLastSession()
        setUpOutlets()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpVideo()
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    private func checkLastSession() {
        if Auth.auth().currentUser != nil {
            let newVC = TabBarViewController()
            newVC.modalPresentationStyle = .fullScreen
            present(newVC, animated: true, completion: nil)
        }
    }
    
    private func setUpOutlets() {
        Design.styleFilledButton(signUpButton)
        Design.styleHollowButton(signInButton)
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        navigationController?.pushViewController(SignInViewController(), animated: true)
    }
    
    private func setUpVideo() {
        let bundlePath = Bundle.main.path(forResource: "WokVideo", ofType: "mov")
        guard bundlePath != nil else { return }
        let url = URL(fileURLWithPath: bundlePath!)
        let item = AVPlayerItem(url: url)
        videoPlayer = AVPlayer(playerItem: item)
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height)
        guard videoPlayerLayer != nil else { return }
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        videoPlayer?.playImmediately(atRate: 0.6)
        videoPlayer?.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.videoDidPlayToEnd(_:)), name: Notification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: videoPlayer?.currentItem)
    }
    
    @objc private func videoDidPlayToEnd(_ notification: Notification) {
        let player = notification.object as? AVPlayerItem
        player?.seek(to: .zero, completionHandler: nil)
    }
}
