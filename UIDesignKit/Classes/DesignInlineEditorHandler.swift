//
//  DesignInlineEditorHandler.swift
//  Pods
//
//  Created by Will Powell on 08/08/2017.
//
//

import Foundation

class DesignInlineEditorHandler:NSObject {
    
    func showAlert(view:UIView){
        let podBundle = Bundle(for: DesignInlineEditorHandler.self)
        let bundleURL = podBundle.url(forResource: "UIDesignKit", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        guard let vc = UIStoryboard(name: "Storyboard", bundle: bundle).instantiateViewController(withIdentifier: "DesignViewController") as? DesignViewController else {
            return
        }
        vc.targetView = view
        let popController = UINavigationController(rootViewController: vc)
        popController.navigationBar.barStyle = .default
        popController.modalPresentationStyle = .formSheet
        if #available(iOS 9.0, *) {
            if let vc = getParent(view) {
                vc.present(popController, animated: true, completion: nil)
            }
        }
    }
    
    func getParent(_ view:UIView) -> UIViewController?{
        var parentResponder: UIResponder? = view
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
