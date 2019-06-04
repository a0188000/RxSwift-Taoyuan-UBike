//
//  InformationViewController.swift
//  Taoyuan-UBike
//
//  Created by 沈維庭 on 2019/1/22.
//  Copyright © 2019年 沈維庭. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class InformationViewController: UIViewController {

    private var infoView = UINib(nibName: "UBikeInfoView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UBikeInfoView

    private var viewModel: InformationViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    private var searchBar: UISearchBar!
    private var indicatorView: UIView!
    private var uBikesTableView = UITableView()
    private var isExpand: Bool = false

    init(viewModel: InformationViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.setRoundCorners(conrners: [.topLeft, .topRight], withRadii: 30)
        self.view.backgroundColor = .white
        self.view.isUserInteractionEnabled = true
        self.setupUI()
        self.bindUI()
        self.bindAction()
        self.bindViewModel()
        
        self.observerNotification()
        
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panView(_:))))
        
    }
    
    override func viewDidLayoutSubviews() {
        self.infoView.snp.updateConstraints { (make) in
            make.height.equalTo(160 + self.bottomHeight)
        }
    }
    
    private func observerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(InformationViewController.keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InformationViewController.keyboardWillHide(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    private func setupUI() {
        self.setupSearchBar()
        self.setupIndicatorView()
        self.setupInfoView()
        self.setupTableView()
    }
    
    private func setupSearchBar() {
        self.searchBar = UISearchBar {
            $0.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 56)
            $0.placeholder = "搜尋站點"
            $0.sizeToFit()
            $0.barStyle = .default
            $0.delegate = self
        }
    }
    
    private func setupIndicatorView() {
        self.indicatorView = UIView {
            $0.backgroundColor = .lightGray
            $0.layer.cornerRadius = 4
            $0.layer.zPosition = 1
        }
        self.view.addSubview(self.indicatorView)
        
        self.indicatorView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(8)
        }
    }
    
    private func setupTableView() {
        self.uBikesTableView = UITableView {
            $0.tableHeaderView = self.searchBar
            $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            $0.rx.setDelegate(self).disposed(by: self.disposeBag)
        }
        
        self.view.addSubview(self.uBikesTableView)
        
        self.uBikesTableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.indicatorView.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 2)
        }
    }
    
    private func setupInfoView() {
        self.view.addSubview(self.infoView)

        self.infoView.snp.makeConstraints { (make) in
            make.top.equalTo(self.indicatorView.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
            make.height.equalTo(160)
        }
    }
    
    private func bindUI() {
        
        self.viewModel.filteredUBikeInfos
            .observeOn(MainScheduler.instance)
            .bind(to: self.uBikesTableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { (_, recrodViewModel, cell) in
                cell.textLabel?.text = recrodViewModel.sna
                cell.selectionStyle = .none
            }.disposed(by: self.disposeBag)
        
        self.searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: self.viewModel.searchValue)
            .disposed(by: self.disposeBag)
    }
    
    private func bindAction() {
        self.infoView.navigationButton.rx.tap
            .bind(to: self.viewModel.navigationButtonTap)
            .disposed(by: self.disposeBag)
        
        self.infoView.routeButton.rx.tap
            .bind(to: self.viewModel.routeButtonTap)
            .disposed(by: self.disposeBag)
        
        self.uBikesTableView.rx
            .modelSelected(RecordViewModel.self)
            .map({ [weak self] in
                self?.view.endEditing(false)
                return $0
            })
            .bind(to: self.viewModel.didSelectedUBikeInfo)
            .disposed(by: self.disposeBag)   
    }
    
    private func bindViewModel() {
        self.viewModel.ubikeInfo
            .bind(to: self.infoView.rx.info)
            .disposed(by: self.disposeBag)
        
        self.viewModel.selectedAnnotationView
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (selected) in
                guard let `self` = self else { return }
                let y = UIScreen.main.bounds.height - 138
                self.updateViewOrigin(withY: y, completion: {[weak self] _ in
                    guard let `self` = self else { return }
                    self.isExpand = false
                })
        }).disposed(by: self.disposeBag)

        self.viewModel.didSelectedUBikeInfo
            .bind(to: self.viewModel.ubikeInfo)
            .disposed(by: self.disposeBag)
        
        self.viewModel.selectedAnnotationView
            .bind(to: self.uBikesTableView.rx.isHidden)
            .disposed(by: self.disposeBag)
    }
    
    private func updateViewOrigin(withY y: CGFloat,
                                  withDuration duration: TimeInterval = 0.3,
                                  completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration, animations: {
            self.view.frame.origin.y = y
            self.view.superview?.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }, completion: completion)
    }

    @objc private func panView(_ recognizer: UIPanGestureRecognizer) {
        if !self.uBikesTableView.isHidden { return }
        let translation = recognizer.translation(in: self.view)
        let transY = Double(translation.y)
        print(transY)
        switch recognizer.state {
        case .changed:
            let midY: CGFloat = transY > 0 ? 138 : 180 + self.bottomHeight
            let y = UIScreen.main.bounds.height - midY
            self.updateViewOrigin(withY: y, completion: nil)
        default: break
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardValue = userInfo[UIWindow.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIWindow.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIWindow.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        let keyboardFrame = keyboardValue.cgRectValue
        let y = UIScreen.main.bounds.height / 2
        self.updateViewOrigin(withY: y, completion: { _ in
            self.isExpand = true
        })
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        
    }
}

extension InformationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(false)
    }
}

extension InformationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        self.view.endEditing(false)
        let offsetY = scrollView.contentOffset.y
        if self.view.frame.origin.y > UIScreen.main.bounds.height / 2 {
            if offsetY > 0 && !self.isExpand {
                self.uBikesTableView.setContentOffset(.zero, animated: false)
                let y = UIScreen.main.bounds.height / 2
                self.updateViewOrigin(withY: y, completion: {[weak self] _ in
                    guard let `self` = self else { return }
                    self.isExpand = true
                })
            }
        }
        
        if self.view.frame.origin.y == UIScreen.main.bounds.height / 2 && self.isExpand && offsetY <= 0 {
            let y = UIScreen.main.bounds.height - 138
            self.updateViewOrigin(withY: y, completion: {[weak self] _ in
                guard let `self` = self else { return }
                self.isExpand = false
            })
        }
        
    }
}


