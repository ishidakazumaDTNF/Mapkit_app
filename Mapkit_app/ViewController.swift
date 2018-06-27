//
//  ViewController.swift
//  Mapkit_app
//
//  Created by 石田一馬 on 2017/05/20.
//  Copyright © 2017年 HAL. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

var myLocationManager:CLLocationManager!

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate,MKMapViewDelegate{

    @IBOutlet weak var display: MKMapView!
    @IBOutlet weak var MapLabel: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var btnK: UIButton!
    
    //各座標登録
    let HalOsaka = CLLocationCoordinate2DMake(34.699875,135.493032)
    
    let HalTokyo = CLLocationCoordinate2DMake(35.691529,139.696872)
    
    let HalNagoya = CLLocationCoordinate2DMake(35.168145,136.885775)
    
    let NearStation = CLLocationCoordinate2DMake(37.331695, -122.030091)
    
    var pin = MKPointAnnotation()
    
    
    @IBAction func myButtonAction(_ sender: Any) {
        let buttonTagButton:UIButton = sender as! UIButton
        print(buttonTagButton.tag)
        let buttonTag = buttonTagButton.tag
        
        switch buttonTag {
            
        case 0:
            pin.coordinate = HalOsaka
            pin.title="HAL大阪"
            pin.subtitle = "https://www.hal.ac.jp/osaka"
            display.addAnnotation(pin)
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegionMake(HalOsaka, span)
            display.setRegion(region, animated:true)

        case 1:
            pin.coordinate = HalTokyo
            pin.title="HAL東京"
            pin.subtitle = "https://www.hal.ac.jp/tokyo"
            display.addAnnotation(pin)
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegionMake(HalTokyo, span)
            display.setRegion(region, animated:true)
            
        case 2:
            pin.coordinate = HalNagoya
            pin.title="HAL名古屋"
            pin.subtitle = "https://www.hal.ac.jp/nagoya"
            display.addAnnotation(pin)
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegionMake(HalNagoya, span)
            display.setRegion(region, animated:true)
            
        case 3:
            pin.coordinate = NearStation
            pin.title="Apple本社"
            pin.subtitle = "https://www.apple.com/jp/"
            display.addAnnotation(pin)
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegionMake(NearStation, span)
            display.setRegion(region, animated:true)
            
        default:break
        }
    }
    
    @IBAction func ChangeMap(_ sender: Any) {
        
        if display.mapType == .hybridFlyover {
            display.mapType = .standard
            MapLabel.text = "標準地図"
        }
        else if display.mapType == .standard {
            display.mapType = .satellite
            MapLabel.text = "2D衛生写真"
        }
        else if display.mapType == .satellite {
            display.mapType = .hybrid
            MapLabel.text = "2D衛生写真＋地名"
        }
        else if display.mapType == .hybrid {
            display.mapType = .satelliteFlyover
            MapLabel.text = "3D衛生写真"
        }
        else if display.mapType == .satelliteFlyover {
            display.mapType = .hybridFlyover
            MapLabel.text = "3D衛生写真＋地名"
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MapLabel.text = "標準地図"
        
        self.inputText.delegate = self
        
        // 位置情報取得の許可を求めるメッセージの表示.必須.
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        //位置情報の許可を得る(常時)
        myLocationManager.requestAlwaysAuthorization()
        
        //位置情報の許可を得る(アプリ起動時)
        myLocationManager.requestWhenInUseAuthorization()
        
        display.delegate = self
        
        
    }
    
    @IBOutlet weak var inputText: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(inputText.text!, completionHandler: {(placemarks,error) -> Void in
            
                if (placemarks?[0]) != nil{
                    if let targetCoordinate = placemarks?[0].location?.coordinate{
                        
                        self.display.setCenter(targetCoordinate,animated:true)
                        
                        let region = MKCoordinateRegionMake(targetCoordinate, MKCoordinateSpanMake(0.1, 0.1))
                        
                        self.display.setRegion(region, animated: true)
                        
                        self.pin.coordinate = targetCoordinate
                        self.pin.title = self.inputText.text
                        
                        self.display.addAnnotation(self.pin)
                    }
                }
            })
        textField.resignFirstResponder()
        return true
    }
    
    
    var strArray: [MyPointAnnotation] = []
    
    //緯度・経度情報(GPS)が変わった時に動く
    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        
        print("緯度:"+(manager.location?.coordinate.latitude.description)!)
        print("経度:"+(manager.location?.coordinate.longitude.description)!)
        
        self.latitude.text = "緯度:" + (manager.location?.coordinate.latitude.description)!
        self.longitude.text = "経度:"+(manager.location?.coordinate.longitude.description)!
        
        let myPointLati = (manager.location?.coordinate.latitude.description)!
        let myPointLong = (manager.location?.coordinate.longitude.description)!
        
        let DmyPointLati = atof(myPointLati)
        let DmyPointLong = atof(myPointLong)
        
        self.display.setCenter(CLLocationCoordinate2DMake(DmyPointLati,DmyPointLong), animated: true)
        
        let pinC = MyPointAnnotation()
        
        pinC.pinColor = UIColor.blue
        
        pinC.coordinate = CLLocationCoordinate2DMake(DmyPointLati,DmyPointLong)
        
        self.strArray.append(pinC)
        
        self.display.addAnnotations(strArray)
    }
    
    
    
    //緯度・経度情報(GPS)が取れなかった時に動く
    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error){
        print(error)
    }
    
    var flag = 0
    
    @IBAction func startWalk(_ sender: Any) {
        
        //現在位置の取得開始
        if flag == 0 {
            myLocationManager.startUpdatingLocation()
            
            btnK.setTitle("停止",for: .normal)
            flag = 1
        }
        else if(flag == 1){
            myLocationManager.stopUpdatingLocation()
            
            btnK.setTitle("開始",for: .normal)
            flag = 0
        }

    }
    
    @IBAction func clearPin(_ sender: Any) {

        
        for pin in strArray {
            display.removeAnnotation(pin)
        }
    }
    
    
    //MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let nowAnnotationView = MKPinAnnotationView()
        if let nowAnnotation = annotation as? MyPointAnnotation{
            nowAnnotationView.pinTintColor = nowAnnotation.pinColor

        } else {
            nowAnnotationView.annotation = annotation
            //色も画像も設定されていない場合
            let testPinView = MKPinAnnotationView()
            // pinのイベントを許可する
            testPinView.canShowCallout = true
            // pinをタップした時に出てくるポップアップの右側にボタンをつける
            testPinView.rightCalloutAccessoryView = UIButton(type: .infoLight)
            testPinView.annotation = annotation
            return testPinView
            
        }
        return nowAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let strUrl:String = view.annotation!.subtitle! ?? "null"
        
        if let url = URL(string: strUrl), UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        }
        }
    }

