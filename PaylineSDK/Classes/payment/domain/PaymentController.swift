//
//  PaymentController.swift
//  Nimble
//
//  Created by Rayan Mehdi on 26/02/2019.
//

import Foundation
import UIKit
import WebKit

/**
 
 */
public final class PaymentController: WebController {
    
    // MARK: - Public Interface
    
    public init(presentingViewController: UIViewController, delegate: PaymentControllerDelegate) {
        super.init(presentingViewController: presentingViewController)
        self.delegate = delegate
    }
    
    public func showPaymentForm(token: String, environment: URL) {
        presentingViewController.present(webViewController, animated: true, completion: nil)
        webViewController.loadUrl(environment)
    }
    
    public func updateWebPaymentData(_ webPaymentData: String) {
        
    }
    
    public func getIsSandbox() {
        scriptHandler.execute(action: PaymentAction.isSandbox, in: webViewController.webView, callback: { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            guard let isSandbox = result as? Bool else { return }
            self?.delegate?.paymentController(strongSelf, didGetIsSandbox: isSandbox)
        })
    }
    
    public func doEndToken(additionalData: Encodable?, isHandledByMerchant: Bool) {
        scriptHandler.execute(action: PaymentAction.endToken(additionalData: additionalData, isHandledByMerchant: isHandledByMerchant), in: webViewController.webView, callback: nil)
    }
    
    public func getLanguage() {
        scriptHandler.execute(action: PaymentAction.getLanguage, in: webViewController.webView) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            guard let language = result as? String else { return }
            self?.delegate?.paymentController(strongSelf, didGetLanguage: language)
        }
    }
    
    public func getContextInfo(key: ContextInfoKeys) {
        scriptHandler.execute(action: PaymentAction.getContextInfo(key: key), in: webViewController.webView) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
           // guard let 

        }
        
    }
    
    // MARK: - Internal Interface
    
    weak var delegate: PaymentControllerDelegate?
    
    override func plWebViewControllerDidFinishLoadingWithSuccess(_ plWebViewController: PLWebViewController) {
      //  delegate?.paymentControllerDidShowPaymentForm(self)
    }
    
    override func handleReceivedEvent(_ event: ScriptEvent) {
        switch event {
            
        case .didShowState(let state):
            handleDidShowState(state: state)
            
        case .finalStateHasBeenReached(let state):
            handleFinalStateHasBeenReached(state: state)
            
        case .didEndToken:
            delegate?.paymentControllerDidCancelPaymentForm(self)
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    private func handleDidShowState(state: WidgetState) {
        switch state {
        case .paymentMethodsList:
            delegate?.paymentControllerDidShowPaymentForm(self)
        case .paymentFailureWithRetry:
            print(state.rawValue)
        case .paymentMethodNeedsMoreInfo:
            print(state.rawValue)
        case .paymentRedirectNoResponse:
            print(state.rawValue)
        case .manageWebWallet:
            print(state.rawValue)
        case .activeWaiting:
            print(state.rawValue)
        case .paymentCanceledWithRetry:
            print(state.rawValue)
        case .paymentMethodsListShortcut:
            print(state.rawValue)
        case .paymentTransitionalShortcut:
            print(state.rawValue)
            
        default:
            break
        }
    }
    
    private func handleFinalStateHasBeenReached(state: WidgetState) {
        switch state {
        case .paymentCanceled:
            delegate?.paymentControllerDidCancelPaymentForm(self)
        case .paymentSuccess:
            print(state.rawValue)
            delegate?.paymentControllerDidFinishPaymentForm(self)
        case .paymentFailure:
            print(state.rawValue)
            delegate?.paymentControllerDidFinishPaymentForm(self)
        case .tokenExpired:
            print(state.rawValue)
            delegate?.paymentControllerDidFinishPaymentForm(self)
        case .browserNotSupported:
            print(state.rawValue)
        case .paymentOnHoldPartner:
            print(state.rawValue)
        case .paymentSuccessForceTicketDisplay:
            print(state.rawValue)
            
        default:
            break
        }
    }
}
