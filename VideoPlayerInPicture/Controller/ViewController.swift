//
//  ViewController.swift
//  VideoPlayerInPicture
//
//  Created by Harish Kumar on 09/04/19.
//  Copyright © 2019 Harish Kumar. All rights reserved.
//

import UIKit
import AVKit
import SDWebImage

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet var PlayAndPause: UIButton!
    @IBOutlet var PlayAndPauseView: UIView!
    @IBOutlet var TotalTimeLabel: UILabel!
    @IBOutlet var DurationSlider: UISlider!
    @IBOutlet var DurationView: UIView!
    @IBOutlet var pictureInPictureButton: UIButton!
    @IBOutlet var VideoLoader: UIActivityIndicatorView!
    @IBOutlet var VideosTableView: UITableView!
    @IBOutlet var TitleLabel: UILabel!
    @IBOutlet var PublicationDate: UILabel!
    @IBOutlet var BackgroundVideoView: UIView!
    @IBOutlet var CloseButton: UIButton!
    @IBOutlet var CloseButtonView: UIView!
    var isPlaying = false
    var shouldPlayerControllerVisible = true
    var pictureInPictureController : AVPictureInPictureController!
    var player : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!
    var panGesture = UIPanGestureRecognizer()
    var url : URL!
    var VideoData : [VideoInfo] = [VideoInfo]()
    var selectedVideo = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeVideoData()
        DurationSlider.value = 0
        DurationView.isHidden = true
        PlayAndPauseView.isHidden = true
        VideoLoader.isHidden = false
        CloseButtonView.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.updateVideoController))
        tap.delegate = self
        videoView.addGestureRecognizer(tap)
        let startImage = AVPictureInPictureController.pictureInPictureButtonStartImage(compatibleWith: nil)
        pictureInPictureButton.setImage(startImage, for: .normal)
        pictureInPictureButton.tintColor = UIColor.black
        initializeTableview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        url = URL(string: VideoData[selectedVideo].VideoURL)!
        TitleLabel.text = VideoData[selectedVideo].VideoTitle
        PublicationDate.text = "Publication Date: \(VideoData[selectedVideo].PublicationDate)"
        let avItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: avItem)
        avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        videoView.layer.addSublayer(avPlayerLayer)
        avPlayerLayer.frame = videoView.layer.bounds
        if AVPictureInPictureController.isPictureInPictureSupported() {
            pictureInPictureController = AVPictureInPictureController(playerLayer: avPlayerLayer)
            pictureInPictureController.delegate = self
        }else{
            pictureInPictureButton.isUserInteractionEnabled = false
            pictureInPictureButton.tintColor = UIColor.gray
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
            videoView.isUserInteractionEnabled = true
            videoView.addGestureRecognizer(panGesture)
            CloseButtonView.isHidden = false
            CloseButtonView.alpha = 0
        }
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        addTimeObserver()
        pauseVideo()
    }
    
    //Possible only for isPictureInPictureSupported is not suppotred
    @IBAction func CloseAction(_ sender: UIButton) {
        if player.timeControlStatus == .playing{
            pauseVideo()
        }
        CloseButtonView.alpha = 0
        self.videoView.frame = self.BackgroundVideoView.frame
    }
    
    @IBAction func togglePictureInPictureMode(_ sender: UIButton) {
        if pictureInPictureController.isPictureInPictureActive {
            pictureInPictureController.stopPictureInPicture()
            videoView.isUserInteractionEnabled = true
        } else {
            pictureInPictureController.startPictureInPicture()
            videoView.isUserInteractionEnabled = false
            if (shouldPlayerControllerVisible) {
                shouldPlayerControllerVisible = false
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                    self.PlayAndPauseView.alpha = 0.0
                    self.DurationView.alpha = 0.0
                }, completion: nil)
            }
        }
    }
    
    //Action for slider
    @IBAction func durationSlider(_ sender: UISlider) {
        player.seek(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
    }
    
    //Play and Pause the Video Action
    @IBAction func PlayAndPauseAction(_ sender: UIButton) {
        if (isPlaying == true) {
            pauseVideo()
        }else{
            playVideo()
        }
    }
    
    //Possible only for isPictureInPictureSupported is not suppotred
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        if player.timeControlStatus == .playing{
            self.view.bringSubviewToFront(videoView)
            let translation = sender.translation(in: self.view)
            videoView.center = CGPoint(x: videoView.center.x + translation.x, y: videoView.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
}

extension ViewController: AVPictureInPictureControllerDelegate{

    //Start Playing Video
    private func playVideo() {
        isPlaying = true
        let image = UIImage(named: "pauseIcon")
        PlayAndPause.setImage(image, for: .normal)
        videoView.bringSubviewToFront(PlayAndPauseView)
        videoView.bringSubviewToFront(DurationView)
        player.play()
    }
    
    //Pause Playing Video
    private func pauseVideo() {
        isPlaying = false
        let image = UIImage(named: "playIcon")
        PlayAndPause.setImage(image, for: .normal)
        videoView.bringSubviewToFront(PlayAndPauseView)
        videoView.bringSubviewToFront(DurationView)
        player.pause()
    }
    
    //Executed when coming back to App
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        videoView.isUserInteractionEnabled = true
        completionHandler(true)
    }
    
    //Hide OR Show Controllers
    @objc func updateVideoController(){
        if (shouldPlayerControllerVisible) {
            if self.videoView.frame != self.BackgroundVideoView.frame {
                CloseButtonView.alpha = 0
            }
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                self.PlayAndPauseView.alpha = 0.0
                self.DurationView.alpha = 0.0
            }, completion: nil)
        } else {
            if self.videoView.frame != self.BackgroundVideoView.frame {
                CloseButtonView.alpha = 1
            }
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                self.PlayAndPauseView.alpha = 0.6
                self.DurationView.alpha = 0.7
            }, completion: nil)
        }
        shouldPlayerControllerVisible = !shouldPlayerControllerVisible
    }
    
    //Update Slider duration of Video
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else {return}
            if !((Float(currentItem.duration.seconds)).isNaN) {
                self?.DurationSlider.maximumValue = Float(currentItem.duration.seconds)
                self?.DurationSlider.minimumValue = 0
                self?.DurationSlider.value = Float(currentItem.currentTime().seconds)
            }
        })
    }
    
    //Observe for player.currentItem update
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let time = player.currentItem?.duration.seconds, time > 0.0{
            VideoLoader.isHidden = true
            if (player.status == .readyToPlay){
                DurationView.isHidden = false
                PlayAndPauseView.isHidden = false
                self.TotalTimeLabel.text = "\(convertToTimeString(time: player.currentItem!.duration))"
            }else{
                print("Video failed to load.")
            }
        }
    }
    
    //Convert CMTime to readable string
    func convertToTimeString(time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if (hours > 0){
            return String(format: "%i:%02i:%02i", arguments: [hours, minutes, seconds])
        }else{
            return String(format: "%02i:%02i", arguments: [minutes, seconds])
        }
    }
    
}

extension ViewController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VideoData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideosTableViewCell", for: indexPath) as! VideosTableViewCell
        cell.VideoTitle.text = VideoData[indexPath.row].VideoTitle
        cell.Thumbnail.sd_setImage(with: URL(string: VideoData[indexPath.row].ImageURL), placeholderImage: UIImage(named: "playIcon"))
        return cell
    }
    
    //On select video
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedVideo{
            if player.timeControlStatus == .playing{
                pauseVideo()
            }
            let movieURL = URL(string: VideoData[indexPath.row].VideoURL)!
            let avItem = AVPlayerItem(url: movieURL)
            self.player.replaceCurrentItem(with: avItem)
            self.DurationSlider.value = 0
            self.TotalTimeLabel.text = "00:00"
            DurationView.isHidden = true
            PlayAndPauseView.isHidden = true
            VideoLoader.isHidden = false
            player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
            addTimeObserver()
            videoView.bringSubviewToFront(VideoLoader)
            selectedVideo = indexPath.row
            TitleLabel.text = VideoData[selectedVideo].VideoTitle
            PublicationDate.text = "Publication Date: \(VideoData[selectedVideo].PublicationDate)"
        }
    }
    
}

extension ViewController{
    
    func initializeVideoData() {
        VideoData.append(VideoInfo(VideoTitle: "Popeye for President", VideoURL: "https://ia600208.us.archive.org/4/items/Popeye_forPresident/Popeye_forPresident_512kb.mp4", PublicationDate: "1956", ImageURL: "https://archive.org/download/Popeye_forPresident/Popeye_forPresident.thumbs/Popeye_forPresident_000030.jpg"))
        VideoData.append(VideoInfo(VideoTitle: "Popeye: Taxi-Turvy", VideoURL: "https://ia802304.us.archive.org/30/items/popeye_taxi-turvey/popeye_taxi-turvey_512kb.mp4", PublicationDate: "1954", ImageURL: "https://archive.org/download/popeye_taxi-turvey/popeye_taxi-turvey.thumbs/popeye_taxi-turvey_000030.jpg"))
        VideoData.append(VideoInfo(VideoTitle: "Popeye The Sailor: Big Bad Sinbad", VideoURL: "https://ia800301.us.archive.org/7/items/popeye_big_bad_sinbad/popeye_big_bad_sinbad_512kb.mp4", PublicationDate: "1952", ImageURL: "https://archive.org/download/popeye_big_bad_sinbad/popeye_big_bad_sinbad.thumbs/popeye_big_bad_sinbad_000030.jpg"))
        VideoData.append(VideoInfo(VideoTitle: "Charlie Chaplin Festival", VideoURL: "https://ia802303.us.archive.org/18/items/charlie_chaplin_film_fest/charlie_chaplin_film_fest.mp4", PublicationDate: "1938", ImageURL: "https://archive.org/download/charlie_chaplin_film_fest/charlie_chaplin_film_fest.thumbs/charlie_chaplin_film_fest_000060.jpg"))
        VideoData.append(VideoInfo(VideoTitle: "Charlie Chaplin's The Floorwalker", VideoURL: "https://ia800206.us.archive.org/13/items/CC_1916_05_15_TheFloorwalker/CC_1916_05_15_TheFloorwalker_512kb.mp4", PublicationDate: "1916", ImageURL: "https://archive.org/download/CC_1916_05_15_TheFloorwalker/CC_1916_05_15_TheFloorwalker.thumbs/CC_1916_05_15_TheFloorwalker_000060.jpg"))
        VideoData.append(VideoInfo(VideoTitle: "Charlie Chaplin's The Count", VideoURL: "https://ia800303.us.archive.org/16/items/CC_1916_09_04_TheCount/CC_1916_09_04_TheCount_512kb.mp4", PublicationDate: "1916", ImageURL: "https://archive.org/download/CC_1916_09_04_TheCount/CC_1916_09_04_TheCount.thumbs/CC_1916_09_04_TheCount_000060.jpg"))
    }
    
    func initializeTableview() {
        let nib = UINib(nibName: "VideosTableViewCell", bundle: nil)
        VideosTableView.register(nib, forCellReuseIdentifier: "VideosTableViewCell")
        VideosTableView.dataSource = self
        VideosTableView.delegate = self
        VideosTableView.estimatedRowHeight = 50
        VideosTableView.rowHeight = UITableView.automaticDimension
    }
    
}
