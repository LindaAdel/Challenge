//
//  ProductViewController.swift
//  Challenge
//
//  Created by Linda adel on 1/27/22.
//

import UIKit


class ProductViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDataSourcePrefetching , PinterestLayoutDelegate
                         
{
   
    var productService : ProductService?
    var products : [ProductModel]?
    var imageDownloader : ImageDownloader?
    var productFileManager : ProductFileManager?
    private var currentPage = 1
    private var isFetchingProducts : Bool = false
    private var networkConnectionStatus : Bool?
    //MARK: IBOutlets
    
    @IBOutlet weak var productsCollectionView: UICollectionView!{
        didSet{
            productsCollectionView.delegate = self
            productsCollectionView.dataSource = self
            productsCollectionView.prefetchDataSource = self
            productsCollectionView.isPrefetchingEnabled = true
            if let layout = productsCollectionView?.collectionViewLayout as? PinterestLayout {
              layout.delegate = self
            }
                    }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productService = ProductService()
        products = [ProductModel]()
        imageDownloader = ImageDownloader.shared
        productFileManager = ProductFileManager.shared
        networkConnectionStatus = NetworkMonitor.shared.isConnected
        self.checkNetworkConectivity()
        
    }
    //MARK: collection view methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let productDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "productDetail") as? ProductDetailViewController{
            if let selectedProduct = products?[indexPath.row]{
                productDetailVC.product = selectedProduct

            }
            productDetailVC.modalPresentationStyle = .fullScreen
            self.present(productDetailVC, animated: true, completion: nil)}
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let productCount =  self.products?.count {
            return productCount
        }
        return 0
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath)
        if let productCell = cell as? ProductCollectionViewCell {
           if let collectionViewProducts = self.products {
            if let productPrice = collectionViewProducts[indexPath.row].price , let productDetail = collectionViewProducts[indexPath.row].productDescription , let productImage = collectionViewProducts[indexPath.row].image
                {
                    productCell.productPriceLabel.text = "\(String(productPrice))$"
                    productCell.productDetailLabel.text = productDetail
                imageDownloader?.downloadImage(with: productImage.url , completionHandler: { image , cached in
                        productCell.productImage.image = image
                        productCell.productImage.contentMode = .scaleAspectFit
                    }, placeholderImage: UIImage(named: "placeholderImage"))
               
                }
            }
           
        }
        
        return cell
    }
   
//    //MARK: pinterest layout
    func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat {
        if let imageSize = (products?[indexPath.row].image?.height){
            return CGFloat(imageSize)

        }
        return productsCollectionView.frame.size.height/2

    }

   
   //MARK: collection view prefetch delegate
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if self.networkConnectionStatus == true {
            if let productCount =  self.products?.count {
                if indexPath.row >= productCount - 1  && !isFetchingProducts{
                    fetchProductsDataFromAPI()
                    break
                }
            }
        }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]){
       
            for indexPath in indexPaths {
                productService?.cancelFetchRequest()
                self.products?.remove(at: indexPath.row)
               }
            
        }
   //MARK: fetch product data
    func fetchProductsDataFromAPI (){
        
        isFetchingProducts = true
        productService?.fetchProductData(fetcgingPage: currentPage, completion: { products , error in
            if let error : Error = error{
                print("error in fetching \(error.localizedDescription)")
            }else{
    
                if let productsArray = products {
                   
                    self.products?.append(contentsOf: productsArray as [ProductModel])
                    if let cachedProducts = self.products {
                        self.productFileManager?.cacheProducts(with: cachedProducts)}
                    DispatchQueue.main.async {
                        self.productsCollectionView.reloadData()
                    }
                    self.currentPage += 1
                    self.isFetchingProducts = false
                  
                }
            }
          
        })
        
    }
 // MARK: adding internet obsserver for network changes
    func conectionObserver(){
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(listenToNetworkMonitor(_:)),
                                               name: NSNotification.Name("internetConnectivity"),
                                               object: nil)
    }
    @objc func listenToNetworkMonitor(_ notifications : Notification){
        if let data = notifications.userInfo  {
            if let isConnected = data["connectionStatus"] as? Bool {
                self.networkConnectionStatus = isConnected
                if isConnected {
                    self.fetchProductsDataFromAPI()
                }else{
                    self.products = self.productFileManager?.readCachedProducts()
                }
                DispatchQueue.main.async {
                    self.productsCollectionView.reloadData()
                }
            }
        }
        
    }
    //MARK: internet conectivity check
    func checkNetworkConectivity() {
        if NetworkMonitor.shared.isConnected{
            self.fetchProductsDataFromAPI()
            print("you are counected")
           
        }else{
            self.products = self.productFileManager?.readCachedProducts()
            print("you are offline")
          
        }
    }
    
}
