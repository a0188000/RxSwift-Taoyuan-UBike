//
//  UBikeMapViewController.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/21.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation
import RxCocoa
import RxSwift
import MapKit
import RxMKMapView


class UBikeMapViewController: UIViewController {

    // View
    private var mapView: MKMapView = MKMapView()
    private var locationButton: UIButton = UIButton()
    // Modle
    private var viewModel: UBikeMapViewModelProtocol
    // DisposeBag
    private let disposeBag: DisposeBag = DisposeBag()
    
    private var informationViewController: InformationViewController!
    private var uBikeDetailViewModel: InformationViewModelProtocol = InformationViewModel()
    
    init(viewModel: UBikeMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.setupInformationView()
        self.setupViews()
        self.bindUI()
        self.bindAction()

        self.uBikeDetailViewModel.didSelectedUBikeInfo
            .map({UBikeAnnotationViewModel($0)})
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                let info = $0
                self.setRegion($0.coordinate)
                self.mapView.annotations.forEach({ (ann) in
                    if ann.title == info.title {
                        self.mapView.selectAnnotation(ann, animated: true)
                    }
                })
            }).disposed(by: self.disposeBag)
    }
    
    private func setupViews() {
        self.setupMapView()
        self.locationButton = UIButton {
            $0.setBackgroundImage(UIImage(named: "location_arrow"), for: .normal)
        }
        self.view.addSubview(self.locationButton)
        self.locationButton.snp.makeConstraints { (make) in
            make.right.equalTo(-8)
            make.bottom.equalTo(self.informationViewController.view.snp.top).offset(-8)
            make.width.height.equalTo(44)
        }
    }

    private func setupMapView() {
        self.mapView = MKMapView()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.view.addSubview(self.mapView)
        self.view.sendSubviewToBack(self.mapView)
        
        self.mapView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    private func bindUI() {
        self.viewModel.uBikeAnns
            .observeOn(MainScheduler.instance)
            .bind(onNext:  { [weak self] in
                guard let `self` = self else { return }
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations($0)
            }).disposed(by: self.disposeBag)
        
        self.viewModel.userLocation
            .filter({ $0.latitude != 0 && $0.longitude != 0})
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.setRegion($0)
            }).disposed(by: self.disposeBag)
        
        self.viewModel.uBikeInfo
            .bind(to: self.uBikeDetailViewModel.ubikeInfo)
            .disposed(by: self.disposeBag)

        self.viewModel.uBikeInfos
            .drive(self.uBikeDetailViewModel.uBikeInfos.asObserver())
            .disposed(by: self.disposeBag)
        
        self.viewModel.routes
            .map({ [weak self] (route) -> MKRoute in
                self?.mapView.overlays.forEach({
                    if $0 is MKPolyline { self?.mapView.removeOverlay($0) }
                })
                return route
            })
            .subscribe(onNext: { [weak self] (route) in
                self?.mapView.addOverlay(route.polyline)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindAction() {
        self.mapView.rx
            .didSelectAnnotationView
            .map({ (view) -> UBikeAnnotationViewModel in
                self.mapView.removeOverlays(self.mapView.overlays)
                self.setRegion(view.annotation!.coordinate)
                self.uBikeDetailViewModel.selectedAnnotationView.onNext(true)
                return view.annotation as! UBikeAnnotationViewModel
            })
            .bind(to: self.viewModel.uBikeDidSelect)
            .disposed(by: self.disposeBag)

        self.mapView.rx
            .didDeselectAnnotationView
            .map({ [weak self] _ in
                if let `self` = self {
                    self.mapView.removeOverlays(self.mapView.overlays)
                }
                return false
            })
            .bind(to: self.uBikeDetailViewModel.selectedAnnotationView)
            .disposed(by: self.disposeBag)
        
        self.locationButton.rx.tap
            .bind(to: self.viewModel.locationRestart)
            .disposed(by: self.disposeBag)
    }
    
    func setupInformationView() {
        self.informationViewController = InformationViewController(viewModel: self.uBikeDetailViewModel)
        self.informationViewController.view.frame = CGRect(x: 0, y: self.view.bounds.height - 138, width: self.view.bounds.width, height: 400)
        self.addChild(self.informationViewController)
        self.view.addSubview(informationViewController.view)

        self.uBikeDetailViewModel.routeButtonTap
            .bind(to: self.viewModel.routeButtonTap)
            .disposed(by: self.disposeBag)
    }
    
    private func setRegion(_ coordinate: CLLocationCoordinate2D) {
        self.mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
    }
}

extension UBikeMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? UBikeAnnotationViewModel else {
            return nil
        }
        if let pin = mapView.dequeueReusableAnnotationView(withIdentifier: "reuseAnnotation") as? MKPinAnnotationView {
            pin.annotation = annotation
            pin.pinTintColor = GeneralHelper.sharedInstance.isConnected ? .red : .blue
            return pin
        }
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "reuseAnnotation")
        pin.canShowCallout = true
        pin.pinTintColor = GeneralHelper.sharedInstance.isConnected ? .red : .blue
        return pin
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if overlay is MKPolyline {
            polylineRenderer.strokeColor = .darkGray
            polylineRenderer.lineWidth = 3
        }
        return polylineRenderer
    }
}



