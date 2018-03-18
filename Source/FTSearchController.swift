//
//  FTSearchController.swift
//  FasKit
//
//  Created by 王俊硕 on 2018/3/12.
//  Copyright © 2018年 王俊硕. All rights reserved.
//

import UIKit

class FTSearchController: UIViewController {
    // MARK: View Properties
    internal var searchController: UISearchController!
    internal var contentView: UITableView!
    
    public var searchBarTintColor: UIColor = .white {
        didSet {
            searchController.searchBar.tintColor = searchBarTintColor
        }
    }
    
    // MARK: SearchBar Events
    typealias EmptySearchBarHandler = (UISearchBar)->()
    typealias BoolSearchBarHandler = (UISearchBar)->(Bool)
    
    public var searchButtonClickHandler: EmptySearchBarHandler?
    public var searchBarShouldBeginEditingHandler: BoolSearchBarHandler?
    public var searchBarShouldEndEditingHandler: BoolSearchBarHandler?
    public var searchBarCancelButtonClickHandler: EmptySearchBarHandler?
    
    public var searchTextDidChange: ((UISearchBar, String)->())?
    public var searchTextShouldChangeInRange: ((UISearchBar, NSRange, String)->(Bool))?
    //MARK: Flags
    public var showDebugInfo = true
    
    public var showCancelButtonWhenEditing: Bool = true {
        willSet {
            searchBar.showsCancelButton = newValue
        }
    }
    
    
    /// UISearchController的searchBar
    public var searchBar: UISearchBar {
        return searchController.searchBar
    }
    /// 集合了UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdater协议
    var contentDelegate: FTSearchControllerDataProvider! {
        willSet {
            contentView.delegate = newValue
            contentView.dataSource = newValue
            searchController.searchResultsUpdater = newValue
        }
    }
    
    // UI Customization
    
    // MARK: - 搜索条
    /// 搜索条文本框
    private var searchField: UITextField? {
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            return searchField
        } else {
            return nil
        }
    }
    /// 文本框背景
    private var searchFieldBackgroudView: UIView? {
        if let field = searchField {
            return field.subviews.first
        } else {
            return nil
        }
    }
    /// 文本框清楚按钮
    private var clearButtonImage: UIImage {
        let image = UIImage(named: "x")!
        if let color = rightIconColor, let icon = image.rerender(with: color) {
            return icon
        } else {
            return image
        }
        
    }
    private var navigationBarheight: CGFloat {
        if #available(iOS 11.0, *) {
            return 0
        } else {
            return searchController.searchBar.frame.height
        }
    }
    
    
    /// 搜索条透明层 cornerRadius 10.0
    open var textFieldBlurLayer: UIView? {
        get {
            return searchFieldBackgroudView?.subviews.first
        }
    }
    // MARK: - 文本输入框
    /// 文本框背景色
    open var textFieldBackgroundColor: UIColor? {
        get {
            if #available(iOS 11.0, *) {
                return searchFieldBackgroudView?.backgroundColor
            } else {
                return searchField?.backgroundColor
            }
        }
        set {
            if #available(iOS 11.0, *) {
                searchFieldBackgroudView?.backgroundColor = newValue
            } else {
                searchField?.backgroundColor = newValue
            }
            textFieldCornerRadius = 10.0
        }
    }
    /// 文本框圆角值 系统自带一层10.0圆角值
    open var textFieldCornerRadius: CGFloat {
        get {
            return searchFieldBackgroudView?.layer.cornerRadius ?? 0
        }
        set {
            searchFieldBackgroudView?.layer.cornerRadius = newValue
            textFieldClipsToBounds = true
        }
    }
    /// 是否显示超出边缘的内容
    open var textFieldClipsToBounds: Bool {
        get {
            return searchField?.clipsToBounds ?? false
        }
        set {
            searchField?.clipsToBounds = newValue
        }
    }
    /// 文字颜色
    open var textFieldTextColor: UIColor? {
        get {
            return searchField?.textColor
        }
        set {
            searchField?.textColor = newValue
        }
    }
    /// 文字字体
    open var textFieldFont: UIFont? {
        get { return searchField?.font }
        set { searchField?.font = newValue }
    }
    /// 光标和取消按钮颜色 它们自动继承上级视图的tintColor属性
    open var cursorAndCancelButtonColor: UIColor? {
        get { return searchBar.tintColor }
        set { searchBar.tintColor = newValue }
    }
    open var attributedPlaceholder: NSAttributedString? {
        get {
            return searchField?.attributedPlaceholder
        }
        set {
            searchField?.attributedPlaceholder = newValue
        }
    }
    /// 放大镜颜色
    open var leftIconColor: UIColor? {
        willSet {
            if let field = searchField {
                let iconView = field.leftView as! UIImageView
                iconView.image = iconView.image?.withRenderingMode(.alwaysTemplate)
                iconView.tintColor = newValue
            }
        }
    }
    /// 右边图标颜色
    open var rightIconColor: UIColor?
    
    // MARK: - 取消按钮
    /// 设置取消按钮
    open var customizeCancelButton: ((UIButton)->())?
    /// 取消按钮标题，应用于所有点击状态，如果设置了setupCancelButton闭包或者富文本标题则会忽略这个属性
    open var cancelButtonTitle: String?
    /// 取消按钮颜色，应用于所有点击状态，如果设置了setupCancelButton闭包或者富文本标题则会忽略这个属性
    open var cancelButtonColor: UIColor?
    /// iOS11有效。取消按钮富文本标题，应用于所有点击状态，如果设置了setupCancelButton闭包则会忽略这个属性
    open var cencelButtonAttributedTitle: NSAttributedString?

    // MARK: - iOS 10 设置
    /// 是否隐藏搜索框的上下两条黑线
    open var hideBorderLines: Bool? {
        willSet {
            if newValue == true {
                searchBar.backgroundImage = UIImage()
            }
        }
    }
    /// iOS10 搜索条背景色, 如果导航栏是有模糊特效的颜色会不一样。 iOS11 的背景色通过导航栏的背景色来设置
    open var barBackgroundColor: UIColor? {
        willSet {
            searchBar.isTranslucent = false
            searchBar.barTintColor = newValue
        }
    }
    /// 导航栏和搜索条背景色，关闭导航栏模糊特效
    open var universalBackgoundColor: UIColor? {
        willSet {
        if let bar = navigationController?.navigationBar {
            bar.barTintColor = newValue
            if #available(iOS 11.0, *) {
            } else {
                barBackgroundColor = newValue
                hideNavitionBarBottomLine = true
                bar.isTranslucent = false
            }
            }
            
        }
    }
    private var hideNavitionBarBottomLine: Bool? {
        willSet {
            if newValue == true, let bar = navigationController?.navigationBar {
                
                findNavigationBarBottomLine(from: bar)?.isHidden = true
            }
        }
        
        
    }
    private func findNavigationBarBottomLine(from view: UIView) -> UIImageView? {
        if (view is UIImageView) && view.frame.size.height <= 1.0 {
            return (view as? UIImageView) ?? UIImageView()
        }
        var imageView: UIImageView?
        view.subviews.forEach() {
            if let picView = findNavigationBarBottomLine(from: $0) {
                imageView = picView;
                return
            }
        }
        return imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupContentView()
        setupSearchController()
        setupConstaints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            setupSearchBarForIOS11()
        } else {
            setupSearchBarForCompatible()
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    func setupCancelButton() {
        if showCancelButtonWhenEditing {
            searchController.searchBar.setShowsCancelButton(true, animated: true)
            print(searchBar.subviews.count)
            for view in searchBar.subviews[0].subviews {
                if view is UIButton {
                    let button = view as! UIButton
                    if let handler = customizeCancelButton {
                        handler(button)
                    } else {
                        if let attributedTitle = cencelButtonAttributedTitle {
                            allControlState() {
                                button.setAttributedTitle(attributedTitle, for: $0)
                            }
                        } else {
                            if let title = cancelButtonTitle { allControlState() {
                                button.setTitle(title, for: $0)
                                } }
                            if let color = cancelButtonColor { allControlState() {
                                button.setTitleColor(color, for: $0)
                                } }
                        }
                    }
                    break
                }
            }
        } else {
            searchBar.setShowsCancelButton(false, animated: false)
        }
    }
//    func sutupRightIconColor() {
//        if let color = rightIconColor, let field = searchField {
//            for view in field.subviews {
//                if view is UIButton {
//                    (view as! UIButton).imageView?.image = (view as! UIButton).imageView?.image?.withRenderingMode(.alwaysTemplate)
//                    view.tintColor = color
//                }
//            }
//            
//        }
//    }
    
    //MARK: - Setup UI
   
    func setupContentView() {
        contentView = UITableView(frame: CGRect.init(origin: CGPoint.init(x: 0, y: -1), size: UIScreen.main.bounds.size), style: .grouped)
        
        contentView.delegate = contentDelegate
//        if #available(iOS 11.0, *) {
//            contentView.contentInsetAdjustmentBehravior = .never
//        } else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
        contentView.dataSource = contentDelegate
        contentView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(contentView)
        
        
    }
    func setupSearchController() {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = contentDelegate
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "请输入"
//        searchController.searchBar.tintColor = UIColor.white // 组件的颜色
//        searchController.searchBar.backgroundColor = .red // 背景的颜色
//        searchController.searchBar.isTranslucent = false
//        searchController.searchBar.barTintColor = .red // 背景色IOS 11 失效即使去掉透明也没用
        
        // 去掉默认背景。实时搜索的时候点击可以自动退出搜索模式
        if #available(iOS 11.0, *) {
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = true // 编辑的时候隐藏导航栏
            self.navigationItem.hidesSearchBarWhenScrolling = false // 这样子可以在进入页面的时候不隐藏
            self.navigationItem.searchController = searchController
        } else {
            searchController.dimsBackgroundDuringPresentation = false// 多一层UIControl
            searchController.hidesNavigationBarDuringPresentation = false
            self.view.addSubview(searchController.searchBar)
        }
        
    }
    /// 在ViewDidAppear()中对iOS11导航栏内嵌入搜索框配置样式 子类需要重写来自定义样式
    func setupSearchBarForIOS11() {
        
    }
    /// 在ViewDidAppear()中对iOS11以下搜索框配置样式 子类需要重写来自定义样式
    func setupSearchBarForCompatible() {
        
    }
    /// AutoLayout
    func setupConstaints() {
        addContentViewAutoLayout()
    }
    func addContentViewAutoLayout() {
        
        
        let superVC: UIViewController = self
        let topItem: Any
        if #available(iOS 11, *) {
            topItem = superVC.topLayoutGuide
        } else {
            topItem = searchController.searchBar
        }
        let leftConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: superVC.view, attribute: .left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: superVC.view, attribute: .right, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: topItem, attribute: .bottom, multiplier: 1, constant: 100)
        let bottomConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: superVC.bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
        
        view.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        view.layoutIfNeeded()
        searchController.searchBar.layoutIfNeeded()
        contentView.layoutIfNeeded()
    }
    private func allControlState(execute: (UIControlState)->()) {
        [UIControlState.normal, UIControlState.selected, UIControlState.highlighted].forEach() {
            execute($0)
        }
    }
}

extension FTSearchController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        allControlState() {
            searchBar.setImage(clearButtonImage, for: UISearchBarIcon.clear, state: $0)
        }
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        setupCancelButton()
        
        if let handler = searchBarShouldBeginEditingHandler {
            return handler(searchBar)
        } else {
            showDebugInfo ~= { print("[FSSearchBarController]: SearchBar ShouldBeginEditing not Handled") }
            return true
        }
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if let handler = searchBarShouldEndEditingHandler {
            return handler(searchBar)
        } else {
            showDebugInfo ~= { print("[FSSearchBarController]: SearchBar ShouldEndEditing not Handled") }
            return true
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //request
        if let handler = searchButtonClickHandler {
            handler(searchBar)
        } else {
            showDebugInfo ~= { print("[FSSearchBarController]: SearchBar ButtonClickEvent not handled") }
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let handler = searchBarCancelButtonClickHandler {
            handler(searchBar)
        } else {
            showDebugInfo ~= { print("[FSSearchBarController]: SearchBar CancelButtonClickEvent not Handled") }
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let handler = searchTextDidChange {
            handler(searchBar, searchText)
        } else {
            showDebugInfo ~= { print("[FSSearchBarController]: SearchBar TextDidChange event not Handled") }
        }
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let handler = searchTextShouldChangeInRange {
            return handler(searchBar, range, text)
        } else {
            showDebugInfo ~= { print("[FSSearchBarController]: SearchBar CancelButtonClickEvent not Handled") }
            return true
        }
    }
    
}
protocol FTSearchControllerDataProvider: UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
}

extension UIImage {
    func rerender(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        if let context = UIGraphicsGetCurrentContext(), let cg = cgImage {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.normal)
            color.setFill()
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.clip(to: rect, mask: cg) // 乘以alpha
            context.fill(rect)
            let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage }
        else {
            print("Failed to get current context or cgImage not exist")
            return nil
        }
    }
}
extension CGRect {
    func scale(x: CGFloat, y: CGFloat) -> CGRect {
         return CGRect(x: 0, y: 0, width: width*x, height: height*y)
    }
}

func ~= (lhs: Bool, rhs: ()->()) {
    if lhs { rhs() }
}
