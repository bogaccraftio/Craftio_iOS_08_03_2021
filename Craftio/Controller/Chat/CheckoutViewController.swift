
import UIKit
import Stripe
import PassKit

class CheckoutViewController: UIViewController {
    
    @IBOutlet weak var viewStack: UIView!
    var payableAmount = String()
    var totalAmount = String()
    var blockPaymentStatus: ((Bool, String, String) -> ())!
    var paymentIntentClientSecret: String?
    var paymentSucceeded = false
    var displayLabelText = String()
    var paymentType = ""

    //MARK:- Stripe Test Key
    var stripe_Test_key = ""
    var stripe_Secret_key = ""
    //MARK:-
    
    //MARK:- Paypal
    var PaypalKey = ""

    lazy var cardTextField: STPPaymentCardTextField = {
        let cardTextField = STPPaymentCardTextField()
        cardTextField.postalCodeEntryEnabled = false 
        return cardTextField
    }()
    
    lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor (red: 60.0/255.0, green: 56.0/255.0, blue: 53.0/255.0, alpha: 1.0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle("Pay", for: .normal)
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        return button
    }()
    
    lazy var applePayButton: PKPaymentButton = {
        let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
        button.isEnabled = Stripe.deviceSupportsApplePay()
        button.isHidden = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle("Pay", for: .normal)
        button.addTarget(self, action: #selector(applePayButtonTapped(sender:)), for: .touchUpInside)
        return button
    }()
        
    lazy var lblTotlaPrice: UILabel = {
        let label = UILabel()
        label.font = UIFont (name: "Cabin-Medium", size: 18)
        label.text = "Total Payable Amount: £\(self.payableAmount)"
        return label
    }()
    
    lazy var lblOr: UILabel = {
        let label = UILabel()
        label.font = UIFont (name: "Cabin-Medium", size: 15)
        label.text = "OR"
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    lazy var lblOr1: UILabel = {
        let label = UILabel()
        label.font = UIFont (name: "Cabin-Medium", size: 15)
        label.text = "OR"
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    lazy var lblOr2: UILabel = {
        let label = UILabel()
        label.font = UIFont (name: "Cabin-Medium", size: 15)
        label.text = "OR"
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        totalAmount = payableAmount.replacingOccurrences(of: ",", with: "")
        view.backgroundColor = .white
        var stackView = UIStackView(arrangedSubviews: [])
        if Stripe.deviceSupportsApplePay(){
            stackView = UIStackView(arrangedSubviews: [lblTotlaPrice,cardTextField, payButton, lblOr, applePayButton])
        }else{
            stackView = UIStackView(arrangedSubviews: [lblTotlaPrice,cardTextField, payButton])
        }
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        viewStack.addSubview(stackView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                stackView.leftAnchor.constraint(equalToSystemSpacingAfter: viewStack.leftAnchor, multiplier: 2),
                view.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
                stackView.topAnchor.constraint(equalToSystemSpacingBelow: viewStack.topAnchor, multiplier: 2),
                ])
        } else {
            // Fallback on earlier versions
            stackView.leftAnchor.constraint(equalTo: viewStack.leftAnchor, constant: 20).isActive = true
            view.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 20).isActive = true
            stackView.topAnchor.constraint(equalTo: viewStack.topAnchor, constant: 20).isActive = true

        }
        startCheckout()
        getCredentials()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Stripe.deviceSupportsApplePay(){
            applePayButton.isHidden = !Stripe.deviceSupportsApplePay()
            applePayButton.setTitle("", for: .normal)
            applePayButton.layer.cornerRadius = 5
            applePayButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[applePayButton(==300)]", options: [], metrics: nil, views: ["applePayButton": applePayButton]))
            applePayButton.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: payButton.frame.height))
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func applePayButtonTapped(sender: UIButton) {
        paymentType = PaymentTag.ApplePay
        let merchantIdentifier = "merchant.com.app.craftio"
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: "GB", currency: "GBP")
        
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem (label: "Craftio", amount: decimal(with: totalAmount))
        ]
        // ...continued in next step
        if Stripe.canSubmitPaymentRequest(paymentRequest),
            let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
            paymentAuthorizationViewController.delegate = self
            present(paymentAuthorizationViewController, animated: true)
        } else {
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "Something is wrong!")

        }

    }
    
    @objc func pay() {
//        
//        self.blockPaymentStatus(true, self.paymentType, "854353459484JHEH7")
//        self.dismiss(animated: true, completion: nil)
//        return
//        
        paymentType = PaymentTag.stripe
        WebService.Loader.show()
        guard let paymentIntentClientSecret:String = paymentIntentClientSecret else {
            return;
        }
        // Collect card details
        let cardParams = cardTextField.cardParams
        if cardParams.number == nil || cardParams.expMonth == 0 || cardParams.expYear == 0 || cardParams.cvc == nil{
            WebService.Loader.hide()
            self.view.endEditing(true)
            appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "Please fill card details!!!")
            return
        }
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
        paymentIntentParams.paymentMethodParams = paymentMethodParams
        
        // Submit the payment
        let paymentHandler = STPPaymentHandler.shared()
        
        paymentHandler.confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymentIntent, error) in
            switch (status) {
            case .failed:
                appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "Payment failed. Please try again later.")
                break
            case .canceled:
                //appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "Payment failed. Please try again later.")
                break
            case .succeeded:
                self.blockPaymentStatus(true, self.paymentType, paymentIntent?.stripeId ?? "")
                self.dismiss(animated: true, completion: nil)
                break
            @unknown default:
                fatalError()
                break
            }
            WebService.Loader.hide()
        }
    }

    func startCheckout() {
        let strPay = totalAmount.replacingOccurrences(of: ",", with: "")
        let json: [String: Any] = [
            "currency": "gbp",
            "amount": strPay
        ]
        WebService.Request.patch(url: generateClientSecret, type: .post, parameter: json) { (dict, error) in
            let clientSecret = dict?["data"] as? String
            self.paymentIntentClientSecret = clientSecret
        }
    }
    
    func getCredentials() {
        let json: [String: Any] = [:]
        WebService.Request.patch(url: getPaymentCredential, type: .post, parameter: json) { (dict, error) in
            let clientdata = dict?["data"] as? [String:Any]
            self.stripe_Test_key = clientdata?["stripe_publish_key"] as? String ?? "pk_test_29PZKlRu8tGzYW4BR3r7MRFE00yxJLqNmm"
            self.stripe_Secret_key = clientdata?["stripe_secret_key"] as? String ?? "sk_test_RyKPV3sJdUVndTZmQeLdVQRV008CHZAUmd"

            self.PaypalKey = clientdata?["paypal_key"] as? String ?? "AWQLCguAL4trSJLrSFP9Mdt9x5Sgfena2yJdqZ6kRIkR00Peev7TAlIy_MrGwOg9-USuspR_hil9FLs7"
            
            Stripe.setDefaultPublishableKey(self.stripe_Test_key)
        }
    }
}

extension CheckoutViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}

extension CheckoutViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    @available(iOS 11.0, *)
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Convert the PKPayment into a PaymentMethod
        STPAPIClient.shared().createPaymentMethod(with: payment) { (paymentMethod: STPPaymentMethod?, error: Error?) in
            guard let paymentMethod = paymentMethod, error == nil else {
                // Present error to customer...
                return
            }
            let clientSecret = self.paymentIntentClientSecret
            let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret!)
            paymentIntentParams.paymentMethodId = paymentMethod.stripeId
            
            // Confirm the PaymentIntent with the payment method
            STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymentIntent, error) in
                switch (status) {
                case .succeeded:
                    // Save payment success
                    self.paymentSucceeded = true
                    self.blockPaymentStatus(true, self.paymentType, paymentIntent?.stripeId ?? "")
                    handler(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                case .canceled:
                    handler(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                case .failed:
                    // Save/handle error
                    let errors = [STPAPIClient.pkPaymentError(forStripeError: error)].compactMap({ $0 })
                    handler(PKPaymentAuthorizationResult(status: .failure, errors: errors))
                @unknown default:
                    handler(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                }
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // Dismiss payment authorization view controller
        dismiss(animated: true, completion: {
            if (self.paymentSucceeded) {
                // Show a receipt page...
            } else {
                // Present error to customer...
            }
        })
    }
}
