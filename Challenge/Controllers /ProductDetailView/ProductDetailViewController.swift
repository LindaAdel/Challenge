//
//  ProductDetailViewController.swift
//  Challenge
//
//  Created by Linda adel on 1/27/22.
//

import UIKit

class ProductDetailViewController: UIViewController {
    var product : ProductModel?
    var imageDownloader : ImageDownloader?
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productDetail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageDownloader = ImageDownloader.shared
        self.setProductInformationOnScreen()
    }
    
    
    @IBAction func backToProductsList(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func setProductInformationOnScreen(){
        if let productImage = product?.image , let productDetail = product?.productDescription  {
            imageDownloader?.downloadImage(with: productImage.url , completionHandler: { image , cached in
            self.productImage.image = image
        }, placeholderImage: UIImage(named: "placeholderImage"))
            self.productDetail.text = productDetail
    }
    }
}
