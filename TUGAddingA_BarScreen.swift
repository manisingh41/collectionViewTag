//
//  TUGAddingA_BarScreen.swift
//  Teepso
//
//  Created by TechUgo on 1/11/18.
//  Copyright © 2018 TechUgo. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
class TUGAddingA_BarScreen: UIViewController,GMSAutocompleteViewControllerDelegate, UIPickerViewDelegate,UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var takeBarPicture: UILabel!
    @IBOutlet weak var placeholderImgSpot: UIImageView!
    @IBOutlet weak var cvImages: UICollectionView!
    @IBOutlet weak var lblHowDoYou: UILabel!
    @IBOutlet weak var lblWhatTypeOfBar: UILabel!
    @IBOutlet weak var tblTagsSuggestions: UITableView!
    @IBOutlet weak var constHeightSelectedTagsCV: NSLayoutConstraint!
    @IBOutlet weak var cvTagsList: UICollectionView!
    @IBOutlet weak var txtTags: UITextField!
    @IBOutlet weak var cvSelectedTags: UICollectionView!
    @IBOutlet weak var lblCounter: UILabel!
    var aryCategoryList: [GetCategoriesDataModel]? = []
    var aryCategoryListTags: [GetTagFromCAtegoryIdDataModel]? = []
    var arySearchingTags: [GetTagFromCAtegoryIdDataModel]? = []
    var selectedTagCount:Int = 0
    var arySelectedCategoryListTags: [GetTagFromCAtegoryIdDataModel]? = []
    let cellReuseIdentifier = "cell"
    @IBOutlet var taptoHideAlpha: UITapGestureRecognizer!
    @IBOutlet var sectionsPickerView: UIPickerView!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtRegion: UITextField!
    @IBOutlet weak var vwAlpha: UIView!
    let imagePickerController = UIImagePickerController()
    var imagePickedArray:[UIImage]=[]
    var spotLatLong = ""
    var spotAddress = ""
    var regionArray:[SectionsData]?=[]
    var regionId = ""
    var region = ""
    var regionIdEdit = ""
    var spotObj: Spots?
    var isComingToEdit = false
    @IBOutlet weak var lblSectionName: UILabel!
    @IBOutlet weak var txtNameBar: UITextField!
    @IBOutlet weak var vwHeader: UIView!
    var updatelist : (Void)->(Void) = {_ in}
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setUpHeaderView()
        getBarsAPI()
        requestToGetTagsFromCAtegories()
        
    }
    
    func setEditingTags() {
        txtNameBar.text = spotObj?.spotName
        lblSectionName.text = region
        regionId = regionIdEdit
        spotAddress = (spotObj?.spot)!
        spotLatLong = (spotObj?.spotLocation)!
        for i in (spotObj?.tags)!{
            let dict:NSDictionary = ["tagId":i.tagId!,"tagName":i.tagName!] as NSDictionary
            print(dict.value(forKey: "tagName")!)
            let obj:GetTagFromCAtegoryIdDataModel = GetTagFromCAtegoryIdDataModel.init(json: JSON(dict))
            print(obj.tagName!)
            self.arySelectedCategoryListTags?.append(obj)
            if (self.aryCategoryListTags?.contains(where: {$0.tagId==i.tagId}))!{
                let index = self.aryCategoryListTags?.index(where: {$0.tagId==i.tagId})!
                self.aryCategoryListTags?[index!].isSelected = true
            }
        }
        if (self.arySelectedCategoryListTags?.count)! > 0
        {
            self.constHeightSelectedTagsCV.constant = 80.0
        }
        self.lblCounter.text = "\((self.arySelectedCategoryListTags?.count)!)"+" out of 20"
        self.cvTagsList.reloadData()
        self.cvSelectedTags.reloadData()
    }
    
    func initialSetup() {
        placeholderImgSpot.image = placeholderImgSpot.image!.withRenderingMode(.alwaysTemplate)
        placeholderImgSpot.tintColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        sectionsPickerView.delegate = self
        sectionsPickerView.dataSource = self
        self.taptoHideAlpha.addTarget(self, action: #selector(hideViewAlpha))
        self.vwAlpha.addGestureRecognizer(self.taptoHideAlpha)
        self.imagePickerController.delegate = self
        // Do any additional setup after loading the view.
        let nibImageCell = UINib(nibName: "TUGImageCollectionCell", bundle: nil)
        self.cvImages.register(nibImageCell, forCellWithReuseIdentifier: "TUGImageCollectionCell")
        cvImages.delegate=self
        cvImages.dataSource=self
        
        let nib = UINib(nibName: "TagsCollectionCellsCollectionViewCell", bundle: nil)
        self.cvTagsList.register(nib, forCellWithReuseIdentifier: "TagsCollectionCellsCollectionViewCell")
        cvTagsList.delegate=self
        cvTagsList.dataSource=self
        
        let nibSelectedTags = UINib(nibName: "TagsSelected", bundle: nil)
        self.cvSelectedTags.register(nibSelectedTags, forCellWithReuseIdentifier: "TagsSelected")
        cvSelectedTags.delegate=self
        cvSelectedTags.dataSource=self
        // Set the PinterestLayout delegate
        if let layout = cvTagsList?.collectionViewLayout as? AddBarCVLayout {
            layout.delegate = self
        }
        if let layout = cvSelectedTags?.collectionViewLayout as? SelectedTagsLayout {
            layout.delegate = self
        }
        
        self.tblTagsSuggestions.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tblTagsSuggestions.delegate=self
        tblTagsSuggestions.dataSource=self
        tblTagsSuggestions.isHidden=true
        txtTags.delegate=self
        cvImages.isHidden = true
    }
    
    @IBAction func ClickToQuestionMark(_ sender: UIButton) {
        showAlert(str: "Put your spots in different sections on your profile to make them more distinct and easier for other users to see")
    }
    
    // Mark:- textfield delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " "{
            //lblHowDoYou.text = "What do you prefer in this place?"
            //lblWhatTypeOfBar.text = "What type of Bar is it?"
            return false
        }
        lblHowDoYou.text = ""
        lblWhatTypeOfBar.text = ""
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        if newString == ""
        {
            lblHowDoYou.text = "What do you prefer in this place?"
            lblWhatTypeOfBar.text = "What type of Bar is it?"
        }
        
        self.arySearchingTags = self.aryCategoryListTags?.filter { item in
            return (item.tagName?.lowercased().contains(newString.lowercased()))!
        }
        if self.arySearchingTags?.count == 0
        {
            self.tblTagsSuggestions.isHidden=true
        }else{
            self.tblTagsSuggestions.isHidden=false
        }
        self.tblTagsSuggestions.reloadData()
        return true
    }
    
    @IBAction func ClickToOK(_ sender: UIButton) {
        if self.arySelectedCategoryListTags?.count == 20
        {
            TUGHelpers().showAlertWithTitle(alertTitle: "", messageBody: "You have selected the maximum limit", controller: self)
            txtTags.text = ""
            txtTags.resignFirstResponder()
            lblHowDoYou.text = "What do you prefer in this place?"
            lblWhatTypeOfBar.text = "What type of Bar is it?"
        }
        else{
            if txtTags.text != ""
            {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showProcessingIndicatorOnView(vwBg: self.view, title: APP_NAME)
                var request = CYLRequestObject()
                let dictBody:[String:Any] = ["categoryId":"5","tagName":txtTags.text!]
                request = CYLServices.requestToAddTag(dict: dictBody as NSDictionary)
                CYLServiceMaster.sharedInstance.callWebServiceWithRequest(rqst: request, withResponse:
                    { (serviceResponse) -> Void in
                        if ((serviceResponse?.object?.value(forKey: "status") as! NSNumber) == 200)
                        {
                            
                            let dict:NSDictionary = serviceResponse?.object?.value(forKey: "data") as! NSDictionary
                            print(dict.value(forKey: "tagName")!)
                            let obj:GetTagFromCAtegoryIdDataModel = GetTagFromCAtegoryIdDataModel.init(json: JSON(dict))
                            print(obj.tagName!)
                            self.arySelectedCategoryListTags?.append(obj)
                            self.cvSelectedTags.collectionViewLayout.invalidateLayout()
                            self.cvSelectedTags.reloadData()
                            self.lblCounter.text = "\((self.arySelectedCategoryListTags?.count)!)"+" out of 20"
                            if (self.arySelectedCategoryListTags?.count)! > 0
                            {
                                self.constHeightSelectedTagsCV.constant = 80.0
                            }
                            self.txtTags.text = ""
                            self.txtTags.resignFirstResponder()
                            self.lblHowDoYou.text = "What do you prefer in this place?"
                            self.lblWhatTypeOfBar.text = "What type of Bar is it?"
                            appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
                        }
                        else
                        {
                            if let msg = serviceResponse?.object?.value(forKey: "message")
                            {
                                TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: msg as! String, controller: self)
                            }
                        }
                },  withError: { (error) -> Void in
                    appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
                    TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: "Please Try Again.", controller: self)
                }) { (isNetworkFailure) -> Void in
                    
                    appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
                    TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: INTERNET_CONNECTION_MESSAGE, controller: self)
                }
                //appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
            }
        }
    }
    
    
    // MARK: - Api calling
    func requestToGetCAtegories()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showProcessingIndicatorOnView(vwBg: self.view, title: APP_NAME)
        var request = CYLRequestObject()
        let dictBody:[String:Any] = ["":""]
        request = CYLServices.requestTOGetCategoryList(dict: dictBody as NSDictionary)
        CYLServiceMaster.sharedInstance.callWebServiceWithRequest(rqst: request, withResponse:
            { (serviceResponse) -> Void in
                if ((serviceResponse?.object?.value(forKey: "status") as! NSNumber) == 200)
                {
                    
                    let obj:GetCategoriesModel = GetCategoriesModel.init(object: serviceResponse?.object! ?? "")
                    self.aryCategoryList = obj.data!
                    self.requestToGetTagsFromCAtegories()
                    
                }
                else
                {
                    if let msg = serviceResponse?.object?.value(forKey: "message")
                    {
                        TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: msg as! String, controller: self)
                    }
                }
        },  withError: { (error) -> Void in
            appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
            TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: "Please Try Again.", controller: self)
        }) { (isNetworkFailure) -> Void in
            
            appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
            TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: INTERNET_CONNECTION_MESSAGE, controller: self)
        }
        appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
        
    }
    func requestToGetTagsFromCAtegories()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showProcessingIndicatorOnView(vwBg: self.view, title: APP_NAME)
        var request = CYLRequestObject()
        let dictBody:[String:Any] = ["categoryId":"5"]
        request = CYLServices.requestTOGetTagsAccordingToCategory(dict: dictBody as NSDictionary)
        CYLServiceMaster.sharedInstance.callWebServiceWithRequest(rqst: request, withResponse:
            { (serviceResponse) -> Void in
                if ((serviceResponse?.object?.value(forKey: "status") as! NSNumber) == 200)
                {
                    
                    let obj:GetTagFromCAtegoryIdModel = GetTagFromCAtegoryIdModel.init(object: serviceResponse?.object! ?? "")
                    self.aryCategoryListTags = obj.data!
                    self.cvTagsList.reloadData()
                    self.tblTagsSuggestions.reloadData()
                    if self.isComingToEdit{
                        self.setEditingTags()
                    }
                    
                }
                else
                {
                    if let msg = serviceResponse?.object?.value(forKey: "message")
                    {
                        TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: msg as! String, controller: self)
                    }
                }
        },  withError: { (error) -> Void in
            appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
            TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: "Please Try Again.", controller: self)
        }) { (isNetworkFailure) -> Void in
            
            appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
            TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: INTERNET_CONNECTION_MESSAGE, controller: self)
        }
        appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
        
    }
    
    // MARK: - table view delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.arySearchingTags?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tblTagsSuggestions.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        cell.backgroundColor = UIColor.init(colorLiteralRed: 219.0/255.0, green: 239.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.init(colorLiteralRed: 17.0/255.0, green: 163.0/255.0, blue: 168.0/255.0, alpha: 1.0)
        cell.textLabel?.text = self.arySearchingTags?[indexPath.row].tagName
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        txtTags.text = self.arySearchingTags?[indexPath.row].tagName
        if !(self.arySelectedCategoryListTags?.contains(where: {$0.tagId==self.arySearchingTags?[indexPath.row].tagId}))!
        {
            let indextemp = self.aryCategoryListTags?.index(where: {$0.tagId == self.arySearchingTags?[indexPath.row].tagId})
            
            let indexpathTemp = IndexPath(item: indextemp!, section: 0)
            
            if let cell = self.cvTagsList.cellForItem(at: indexpathTemp) as? TagsCollectionCellsCollectionViewCell
            {
                cell.lblTab.textColor = UIColor.white
                cell.lblTab.backgroundColor = UIColor.init(colorLiteralRed: 17.0/255.0, green: 163.0/255.0, blue: 168.0/255.0, alpha: 1.0)
            }
            
            if self.arySelectedCategoryListTags?.count == 0
            {
                self.constHeightSelectedTagsCV.constant = 80.0
            }
            let obj = self.aryCategoryListTags?[indexpathTemp.row]
            obj?.isSelected = true
            self.arySelectedCategoryListTags?.append(obj!)
            cvSelectedTags.collectionViewLayout.invalidateLayout()
            self.cvSelectedTags.reloadData()
            lblCounter.text = "\((self.arySelectedCategoryListTags?.count)!)"+" out of 20"
            if self.arySelectedCategoryListTags?.count == 0
            {
                self.constHeightSelectedTagsCV.constant = 0.0
            }
        }
        txtTags.text=""
        txtTags.resignFirstResponder()
        lblHowDoYou.text = "What do you prefer in this place?"
        lblWhatTypeOfBar.text = "What type of Bar is it?"
        tblTagsSuggestions.isHidden=true
    }
    // MARK: - collection View delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvImages
        {
            return self.imagePickedArray.count
        }
        else if collectionView == cvSelectedTags
        {
            return self.arySelectedCategoryListTags!.count
        }
        else
        {
            return self.aryCategoryListTags!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvImages
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TUGImageCollectionCell", for: indexPath)
            if let annotateCell = cell as? TUGImageCollectionCell {
                annotateCell.setImage = imagePickedArray[indexPath.item]
            }
            return cell
        }
        else if collectionView == cvSelectedTags
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagsSelected", for: indexPath)
            if let annotateCell = cell as? TagsSelected {
                annotateCell.setTag = arySelectedCategoryListTags?[indexPath.item].tagName
            }
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagsCollectionCellsCollectionViewCell", for: indexPath)
            if let annotateCell = cell as? TagsCollectionCellsCollectionViewCell {
                if aryCategoryListTags?[indexPath.row].isSelected == true
                {
                    annotateCell.lblTab.layer.cornerRadius = 10.0
                    annotateCell.lblTab.layer.borderColor = UIColor.clear.cgColor
                    annotateCell.lblTab.layer.borderWidth = 2.0
                    annotateCell.lblTab.clipsToBounds=true
                    annotateCell.lblTab.backgroundColor = UIColor.init(red: 242.0/255.0, green: 183.0/255.0, blue: 75.0/255.0, alpha: 1.0)
                }else{
                    annotateCell.lblTab.backgroundColor = UIColor.clear
                    annotateCell.lblTab.layer.cornerRadius = 10.0
                    annotateCell.lblTab.layer.borderColor = UIColor.white.cgColor
                    annotateCell.lblTab.layer.borderWidth = 2.0
                    annotateCell.lblTab.clipsToBounds=true
                }
                annotateCell.setTag = aryCategoryListTags?[indexPath.item].tagName
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected item is",indexPath.row)
        if collectionView == cvImages
        {
            self.imagePickedArray.remove(at: indexPath.row)
            if self.imagePickedArray.count == 0{
                self.cvImages.isHidden = true
                self.takeBarPicture.isHidden = false
            }
            self.cvImages.reloadData()
        }
        else if collectionView == cvTagsList
        {
            if (self.arySelectedCategoryListTags?.contains(where: {$0.tagId==self.aryCategoryListTags?[indexPath.row].tagId}))!{
                
                self.arySelectedCategoryListTags?.remove(at: (self.arySelectedCategoryListTags?.index(where: {$0.tagId==self.aryCategoryListTags?[indexPath.row].tagId}))!)
                lblCounter.text = "\((self.arySelectedCategoryListTags?.count)!)"+" out of 20"
                if self.arySelectedCategoryListTags?.count == 0
                {
                    self.constHeightSelectedTagsCV.constant = 0.0
                }
                cvSelectedTags.collectionViewLayout.invalidateLayout()
                self.cvSelectedTags.reloadData()
                self.aryCategoryListTags?[indexPath.row].isSelected = false
                let cell = collectionView.cellForItem(at: indexPath) as! TagsCollectionCellsCollectionViewCell
                cell.lblTab.backgroundColor = UIColor.clear
                cell.lblTab.layer.borderColor = UIColor.white.cgColor
            }else{
                if self.arySelectedCategoryListTags?.count == 20
                {
                    TUGHelpers().showAlertWithTitle(alertTitle: "", messageBody: "You have selected the maximum limit", controller: self)
                }
                else{
                    let cell = collectionView.cellForItem(at: indexPath) as! TagsCollectionCellsCollectionViewCell
                    cell.lblTab.textColor = UIColor.white
                    cell.lblTab.backgroundColor = UIColor.init(red: 242.0/255.0, green: 183.0/255.0, blue: 75.0/255.0, alpha: 1.0)
                    cell.lblTab.layer.borderColor = UIColor.clear.cgColor
                    if self.arySelectedCategoryListTags?.count == 0
                    {
                        self.constHeightSelectedTagsCV.constant = 80.0
                    }
                    let obj = self.aryCategoryListTags?[indexPath.row]
                    obj?.isSelected = true
                    self.arySelectedCategoryListTags?.append(obj!)
                    cvSelectedTags.collectionViewLayout.invalidateLayout()
                    self.cvSelectedTags.reloadData()
                    lblCounter.text = "\((self.arySelectedCategoryListTags?.count)!)"+" out of 20"
                    if self.arySelectedCategoryListTags?.count == 0
                    {
                        self.constHeightSelectedTagsCV.constant = 0.0
                    }
                }
                
            }
        }else{
            if (self.aryCategoryListTags?.contains(where: {$0.tagId==self.arySelectedCategoryListTags?[indexPath.row].tagId}))!{
                
                let indextemp = self.aryCategoryListTags?.index(where: {$0.tagId == self.arySelectedCategoryListTags?[indexPath.row].tagId})
                
                let indexpathTemp = IndexPath(item: indextemp!, section: 0)
                
                self.arySelectedCategoryListTags?.remove(at: indexPath.row)
                cvSelectedTags.collectionViewLayout.invalidateLayout()
                self.cvSelectedTags.reloadData()
                lblCounter.text = "\((self.arySelectedCategoryListTags?.count)!)"+" out of 20"
                if self.arySelectedCategoryListTags?.count == 0
                {
                    self.constHeightSelectedTagsCV.constant = 0.0
                }
                let cell = cvTagsList.cellForItem(at: indexpathTemp)
                if let annotateCell = cell as? TagsCollectionCellsCollectionViewCell
                {
                    annotateCell.lblTab.backgroundColor = UIColor.clear
                    annotateCell.lblTab.layer.borderColor = UIColor.white.cgColor
                    self.aryCategoryListTags?[indexpathTemp.row].isSelected = false
                }else{
                    self.aryCategoryListTags?[indexpathTemp.row].isSelected = false
                }
                
            }else{
                self.arySelectedCategoryListTags?.remove(at: indexPath.row)
                cvSelectedTags.collectionViewLayout.invalidateLayout()
                self.cvSelectedTags.reloadData()
                lblCounter.text = "\((self.arySelectedCategoryListTags?.count)!)"+" out of 20"
                if self.arySelectedCategoryListTags?.count == 0
                {
                    self.constHeightSelectedTagsCV.constant = 0.0
                }
            }
        }
    }

    
    func hideViewAlpha() {
        vwAlpha.isHidden=true
    }
    
    func setUpHeaderView()
    {
        let commonHeader = TUGCommonHeader()
        self.vwHeader.addSubview(commonHeader.view)
        commonHeader.lblPersonalDetail.text = "Bars"
        self.addChildViewController(commonHeader)
        commonHeader.setScreenComponentsWithTitleAndFlag(strTitle: "Save", menuFlag: "3")
        commonHeader.backBtnAction =
            {_ in
                self.navigationController!.popViewController(animated: true)
        }
        commonHeader.loginBtnAction =
            {_ in
                if self.isValidated()
                {
                  self.APItoAddBar()
                }
        }
    }
    
    func APItoAddBar() {
        AppDelegate().showProcessingIndicatorOnView(vwBg: self.view, title: "")
        var request = CYLRequestObject()
        var arrTagString:[String] = []
        for i in self.arySelectedCategoryListTags!{
            
            arrTagString.append("\(i.tagId!)")
        }
        let dictBody:[String:Any]?
        if regionId == ""
        {
            if isComingToEdit{
                dictBody = ["spotId":String(describing: (spotObj?.spotId)!),"tagIdArr":String(describing: arrTagString),"region":lblSectionName.text!,"spot":self.spotAddress,"spotName":txtNameBar.text!,"spotLocation":self.spotLatLong]
            }else{
                dictBody = ["categoryId":"5","tagIdArr":String(describing: arrTagString),"region":lblSectionName.text!,"spot":self.spotAddress,"spotName":txtNameBar.text!,"spotLocation":self.spotLatLong]
            }
            
        }else{
            if isComingToEdit{
                dictBody = ["spotId":String(describing: (spotObj?.spotId)!),"tagIdArr":String(describing: arrTagString),"regionId":regionId,"spot":self.spotAddress,"spotName":txtNameBar.text!,"spotLocation":self.spotLatLong]
            }else{
                dictBody = ["categoryId":"5","tagIdArr":String(describing: arrTagString),"regionId":regionId,"spot":self.spotAddress,"spotName":txtNameBar.text!,"spotLocation":self.spotLatLong]
            }
            
        }
        var selectedImagetemp = [Data]()
        if self.imagePickedArray.count>0{
        for i in 0...self.imagePickedArray.count-1
        {
            var imagedatatemp:Data?=nil
            let compressedImage = TUGHelpers().getCompressedImage(image: self.imagePickedArray[i])
            imagedatatemp = UIImageJPEGRepresentation(compressedImage, 1.0)! as Data
            selectedImagetemp.append(imagedatatemp!)
        }
        //let imageData = NSKeyedArchiver.archivedData(withRootObject: selectedImagetemp)
            if isComingToEdit{
                request = CYLServices.requestToUpdateSpot(dict: dictBody! as NSDictionary, image: (selectedImagetemp as NSArray) as! [Data])
            }else{
                request = CYLServices.requestToaddSpot(dict: dictBody! as NSDictionary, image: (selectedImagetemp as NSArray) as! [Data])
            }
        
        
        
        CYLServiceMaster.sharedInstance.callDataUploadServiceWithRequest(rqst: request, withResponse:
            { (serviceResponse) -> Void in
                
                if ((serviceResponse?.object?.value(forKey: "status") as! NSNumber) == 200)
                {
                    if self.isComingToEdit{
                        self.showAlert(str: "Bar updated successfully")
                    }else{
                        self.showAlert(str: "Bar added successfully")
                    }
                    
                    AppDelegate().hideProcessingIndicatorFromView(vwBg: self.view)
                    self.updatelist()
                    self.navigationController?.popViewController(animated: true)
                }
                else
                {
                    AppDelegate().hideProcessingIndicatorFromView(vwBg: self.view)
                    if let msg = serviceResponse?.object?.value(forKey: "message")
                    {
                        TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: msg as! String, controller: self)
                    }
                }
 
                
        },
                                                                         withError: { (error) -> Void in
                                                                            
                                                                            AppDelegate().hideProcessingIndicatorFromView(vwBg: self.view)
                                                                            TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: "Please Try Again.", controller: self)
                                                                            
        }) { (isNetworkFailure) -> Void in
            // self.myAct.stopAnimating()
            AppDelegate().hideProcessingIndicatorFromView(vwBg: self.view)
            TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: "Please Check Your Network Connection.", controller: self)
            
        }
        }else{
            
            if isComingToEdit{
                request = CYLServices.requestToUpdateSpotWithoutImage(dict: dictBody! as NSDictionary)
            }else{
                request = CYLServices.requestToaddSpotWithoutImage(dict: dictBody! as NSDictionary)
            }
            
            
            
            CYLServiceMaster.sharedInstance.callWebServiceWithRequest(rqst: request, withResponse:
                { (serviceResponse) -> Void in
                    
                    if ((serviceResponse?.object?.value(forKey: "status") as! NSNumber) == 200)
                    {
                        if self.isComingToEdit{
                            self.showAlert(str: "Bar updated successfully")
                        }else{
                            self.showAlert(str: "Bar added successfully")
                        }
                        AppDelegate().hideProcessingIndicatorFromView(vwBg: self.view)
                        self.updatelist()
                        self.navigationController?.popViewController(animated: true)
                    }
                    else
                    {
                        AppDelegate().hideProcessingIndicatorFromView(vwBg: self.view)
                        if let msg = serviceResponse?.object?.value(forKey: "message")
                        {
                            TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: msg as! String, controller: self)
                        }
                    }
                    
                    
            },
                                                                             withError: { (error) -> Void in
                                                                                
                                                                                AppDelegate().hideProcessingIndicatorFromView(vwBg: self.view)
                                                                                TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: "Please Try Again.", controller: self)
                                                                                
            }) { (isNetworkFailure) -> Void in
                // self.myAct.stopAnimating()
                AppDelegate().hideProcessingIndicatorFromView(vwBg: self.view)
                TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: "Please Check Your Network Connection.", controller: self)

        }
        }

    }
    
    func isValidated() -> Bool {
        if txtNameBar.text == ""
        {
            showAlert(str: "Please enter Bar name.")
            return false
        }
        else if lblSectionName.text == "Section on your profile"
        {
            showAlert(str: "Please choose or enter section.")
            return false
        }
        else if arySelectedCategoryListTags?.count == 0
        {
            showAlert(str: "Please select atleast one tag for the bar.")
            return false
        }
        else
        {
            return true
        }
    }
    //MARK: - pickerview delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.regionArray!.count+1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0
        {
            return "Create one section"
        }
        else{
            return self.regionArray?[row-1].region
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if row == 0{
//            print("selected 0th element")
//        }
//        else{
//            lblSectionName.text = "abc"
//        }
//        
//    }
    
    @IBAction func ClickOnSection(_ sender: UIButton) {
        let action = UIAlertController.init(title: "\n\n\n\n\n\n\n", message: "", preferredStyle: .actionSheet)
        let margin:CGFloat = 10.0
        let rect = CGRect(x: margin, y: margin, width: action.view.bounds.size.width - margin * 4.0, height: 180)
        sectionsPickerView.frame = rect
        action.view.addSubview(sectionsPickerView)
        let done = UIAlertAction.init(title: "Done", style: .default) { (action) in
            if self.sectionsPickerView.selectedRow(inComponent: 0) == 0
            {
                self.vwAlpha.isHidden = false
            }
            else{
                self.lblSectionName.text = self.regionArray?[self.sectionsPickerView.selectedRow(inComponent: 0)-1].region
                self.regionId = "\(String(describing: (self.regionArray?[self.sectionsPickerView.selectedRow(inComponent: 0)-1].regionId)!))"
            }
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
        }
        action.addAction(done)
        action.addAction(cancel)
        
        self.present(action, animated: true, completion: nil)
    }
    
    @IBAction func ClickToSaveButton(_ sender: UIButton) {
        if txtRegion.text == "" && txtCity.text == ""{
            showAlert(str: "Please enter Region name or City")
        }
        else if txtRegion.text != "" && txtCity.text != ""{
            lblSectionName.text = txtRegion.text!+", "+txtCity.text!
            txtRegion.text = ""
            txtCity.text=""
            vwAlpha.isHidden = true
        }
        else if txtRegion.text != ""{
            lblSectionName.text = txtRegion.text!
            txtRegion.text = ""
            txtCity.text=""
            vwAlpha.isHidden = true
        }
        else{
            lblSectionName.text = txtCity.text!
            txtRegion.text = ""
            txtCity.text=""
            vwAlpha.isHidden = true
        }
    }
    func showAlert(str:String) {
        TUGHelpers().showAlertWithTitle(alertTitle: "", messageBody: str, controller: self)
    }
    // MARK:- api calling
    func getBarsAPI() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showProcessingIndicatorOnView(vwBg: self.view, title: APP_NAME)
        var request = CYLRequestObject()
        let dictBody:[String:Any] = ["categoryId":"5"]
        request = CYLServices.requestToGetRegion(dict: dictBody as NSDictionary)
        CYLServiceMaster.sharedInstance.callWebServiceWithRequest(rqst: request, withResponse:
            { (serviceResponse) -> Void in
                if ((serviceResponse?.object?.value(forKey: "status") as! NSNumber) == 200)
                {
                    appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
                    let masterData = SectionsModel.init(object: (serviceResponse?.object)!) as SectionsModel
                    self.regionArray = masterData.data!
                    self.sectionsPickerView.reloadAllComponents()
                    
                }
                else
                {
                    if let msg = serviceResponse?.object?.value(forKey: "message")
                    {
                        appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
                        TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: msg as! String, controller: self)
                    }
                }
        },  withError: { (error) -> Void in
            appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
            TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: "Please Try Again.", controller: self)
        }) { (isNetworkFailure) -> Void in
            
            appDelegate.hideProcessingIndicatorFromView(vwBg: self.view)
            TUGHelpers().showAlertWithTitle(alertTitle: APP_NAME, messageBody: INTERNET_CONNECTION_MESSAGE, controller: self)
        }
        
        
    }
    
    func openGoogleSuggestion() {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    @IBAction func ClickToPickBarAddress(_ sender: UIButton) {
        self.openGoogleSuggestion()
    }
    
    //MARK: - GMSAutocompleteViewControllerDelegate
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace)
    {
        self.txtNameBar.text = place.name
        for i in place.addressComponents!{
            if "locality" == i.type{
                lblSectionName.text = i.name
            }
            
        }
        self.spotAddress = place.formattedAddress!
        self.spotLatLong = "\(place.coordinate.latitude)"+","+"\(place.coordinate.longitude)"
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error)
    {
        // TODO: handle the error.
        //        print("Error: ", error.localizedescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
   

    @IBAction func ClickToClearTheBarAddress(_ sender: UIButton) {
        txtNameBar.text = ""
    }

    @IBAction func ClickToCamera(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePickerController.allowsEditing = false
            self.imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
            self.imagePickerController.cameraCaptureMode = .photo
            self.imagePickerController.modalPresentationStyle = .fullScreen
        } else {
        }
        self.present(self.imagePickerController, animated: true, completion: nil)
        print("Delete")
    }
    @IBAction func ClickToGallery(_ sender: UIButton) {
        
        self.imagePickerController.allowsEditing = false
        self.imagePickerController.sourceType = .photoLibrary
        //            self.imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.imagePickerController.modalPresentationStyle = .popover
        //  self.imagePickerController.startOnFrontCamera = true
        
        self.present(self.imagePickerController, animated: true, completion: nil)
        
        print("Save")
    }
    
    //MARK: IMAGE PICKER DELEGATES
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        var  chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        //self.imgProfilePic.contentMode = .scaleAspectFill //3
        //self.imgProfilePic.image = chosenImage //4
        //self.imagePicked = chosenImage
        self.imagePickedArray.append(chosenImage)
        cvImages.isHidden = false
        takeBarPicture.isHidden = true
        dismiss(animated:true, completion: nil) //5
        self.cvImages.reloadData()
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - PINTEREST LAYOUT DELEGATE
extension TUGAddingA_BarScreen : SelectedTagsLayoutDelegate {
    
    // 1. Returns the photo height
    func collectionViewSelectedTag(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        return 50.0
    }
    
    func collectionViewSelectedTag(_ collectionView: UICollectionView, widthForTagAtIndexPath indexPath:IndexPath) -> CGFloat {
        let widt = CGFloat((arySelectedCategoryListTags?[indexPath.item].tagName?.characters.count)!*10)+51.0
        return widt
    }
}
//MARK: - PINTEREST LAYOUT DELEGATE
extension TUGAddingA_BarScreen : AddBarCVLayoutDelegate {
    
    // 1. Returns the photo height
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        return 50.0
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForTagAtIndexPath indexPath:IndexPath) -> CGFloat {
        let widt = CGFloat((aryCategoryListTags?[indexPath.item].tagName?.characters.count)!*10)+51.0
        return widt
    }
}
