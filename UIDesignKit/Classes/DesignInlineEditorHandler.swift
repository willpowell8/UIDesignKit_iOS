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
        let vc = DesignViewController()
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
