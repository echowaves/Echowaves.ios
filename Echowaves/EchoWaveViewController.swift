//
//  EchoWaveViewController.swift
//  Echowaves
//
//  Created by D on 11/29/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

import Foundation

class EchoWaveViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var imagesCollectionView:UICollectionView!
    @IBOutlet var waveSelected:UITextField!
    @IBOutlet var emptyWaveLabel:UILabel!
    @IBOutlet var wavesPicker:UIPickerView!
    
    var waveImages = []
    var myWaves = []
    var refreshControl:UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("$$$$$$$$$$$$$$$$calling viewDidLoad for EchoWaveViewController")
        
        self.emptyWaveLabel.hidden = true
        
        if(self.refreshControl == nil) {
            self.refreshControl = UIRefreshControl()
            self.refreshControl.addTarget(self, action: Selector("refreshView"), forControlEvents: .ValueChanged)
            self.imagesCollectionView.addSubview(self.refreshControl)
        }    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.imagesCollectionView.autoresizingMask = .FlexibleHeight
        UIViewAutoresizing.FlexibleWidth
        self.reloadWavesPicker()
    }
    
    func reloadWavesPicker() -> Void {
        EWWave.getAllMyWaves({ (waves) -> () in
            self.myWaves = waves;
            NSLog("11111111111 currentWaveName: \(APP_DELEGATE.currentWaveName)")
            
            if APP_DELEGATE.currentWaveName == "" {
                if let credential:NSURLCredential = EWWave.getStoredCredential() {
                    APP_DELEGATE.currentWaveName = credential.user!
                    APP_DELEGATE.currentWaveIndex = 0
                }
            }
            NSLog("2222222222 currentWaveName: \(APP_DELEGATE.currentWaveName)")
            NSLog("3333333333 wavesPickerSize: \(self.myWaves.count)")
            
            self.wavesPicker = UIPickerView(frame: CGRectZero)
            
            self.attachPickerToTextField(self.waveSelected, picker: self.wavesPicker)
            
            self.wavesPicker.selectRow(APP_DELEGATE.currentWaveIndex, inComponent: 0, animated: true)
            
            NSLog("setting wave index: \(APP_DELEGATE.currentWaveIndex)")
            self.navigationController?.navigationBar.topItem?.title = ""
            
            self.waveSelected.text = APP_DELEGATE.currentWaveName
            
            self.refreshView()
            
            },
            failure: { (error) -> () in
                EWWave.showErrorAlertWithMessage(error.description, fromSender: self)
        })
        
    }
    
    
    func refreshView() -> Void {
        self.startRefresh(self.refreshControl)
    }
    
    
    func attachPickerToTextField(textField:UITextField!, picker:UIPickerView!) -> Void {
        picker.delegate = self
        picker.dataSource = self
        
        textField.delegate = self
        textField.inputView = picker
    }
    
    
    func startRefresh(sender:UIRefreshControl!) -> Void {
        NSLog("starting the refresh")
        EWImage.getAllImagesForWave(APP_DELEGATE.currentWaveName,
            success: { (waveImages) -> () in
                self.waveImages = waveImages;
                NSLog("@total images \(self.waveImages.count)")
                self.imagesCollectionView.reloadData()
                self.imagesCollectionView.reloadInputViews()
                
                if self.waveImages.count == 0 {
                    NSLog("hiding false")
                    self.emptyWaveLabel.hidden = false
                } else {
                    NSLog("hiding true");
                    self.emptyWaveLabel.hidden = true
                }
                
                sender.endRefreshing()
                
            }, failure: { (error) -> () in
                NSLog("error \(error.description)")
        })
        
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.myWaves.count
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let label = UILabel()
        label.backgroundColor = UIColor.orangeColor()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "HelveticaNeue", size: CGFloat(14))
        label.textAlignment = .Center
        //WithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 60)];
        
        label.text = ((self.myWaves.objectAtIndex(row) as NSDictionary).objectForKey("name") as String)
        
        return label
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.waveSelected.text = ((self.myWaves.objectAtIndex(row) as NSDictionary).objectForKey("name") as String)
        self.waveSelected.resignFirstResponder()
        
        NSLog(",,,,,,,,,,,,,,,,,,, did select row: \(row)")
        APP_DELEGATE.currentWaveName = ((self.myWaves.objectAtIndex(row) as NSDictionary).objectForKey("name") as String)
        APP_DELEGATE.currentWaveIndex = row
        
        self.navigationController?.navigationBar.topItem?.title = "";//[APP_DELEGATE currentWaveName];
        self.refreshView()
    }
    
    
    
    func numberOfRowsInPickerView(pickerView:UIPickerView) -> Int {
        return self.myWaves.count
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        NSLog("total images in wave: \(self.waveImages.count)")
        return self.waveImages.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:UICollectionViewCell  = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as UICollectionViewCell
        
        let waveImageView:UIImageView = cell.viewWithTag(100) as UIImageView
        
        let rowValue:NSDictionary = self.waveImages.objectAtIndex(indexPath.row) as NSDictionary
        
        let imageName = (rowValue.objectForKey("name") as String)
        let waveName = (rowValue.objectForKey("name_2") as String)
        
        
        //    ((UIImageView *)[cell viewWithTag:100]).image = nil;//[UIImage imageNamed:@"echowave.png"]; // no need to show the background image
        waveImageView.image = nil
        
        
        EWImage.loadThumbImage(
            imageName,
            waveName: waveName,
            success: { (image) -> () in
                if contains(collectionView.indexPathsForVisibleItems() as [NSIndexPath], indexPath) {
                    waveImageView.image = image
                    waveImageView.contentMode = .ScaleAspectFit
                }
            },
            failure: { (error) -> () in
                NSLog("error: \(error.description)")
            },
            progress: { (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> () in
        })
        return cell;
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        NSLog("selecting image")
        let detailedImagePageViewController:DetailedImagePageViewController! = UIStoryboard(name: "Main_iPhone", bundle: nil).instantiateViewControllerWithIdentifier("DetailedImagePageView") as DetailedImagePageViewController
        
        NSLog("index path: \(indexPath.row) and unsigned \(UInt(indexPath.row))")
        
        detailedImagePageViewController.initialViewIndex = UInt(indexPath.row)
        detailedImagePageViewController.waveImages = self.waveImages
        
        self.navigationController?.pushViewController(detailedImagePageViewController, animated: true)
    }
    
    
    
    
}