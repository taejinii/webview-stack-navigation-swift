import WebKit

class WebViewController: UIViewController {
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    private let navigator = WebViewNavigator()
    private let initialURL: URL
    
    init(url: URL = URL(string: "https://webview-stack-navigation.vercel.app/")!) {
        self.initialURL = url
        super.init(nibName: nil, bundle: nil)
        navigator.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialURL()
    }
    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupWebView()
        setupActivityIndicator()
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(self, name: "navigationHandler")
        configuration.userContentController = contentController
        
        webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        
        // 디바이스 회전 또는 크기 변경시 웹뷰가 자동으로 적절한 크기로 조정 되도록함.
        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        
        view.addSubview(webView!)
    
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func loadInitialURL() {
        let request = URLRequest(url: initialURL)
        webView.load(request)
    }
}

// WebViewController+WKScriptMessageHandler
extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let messageBody = message.body as? [String: Any] else { return }
        navigator.handleNavigationMessage(messageBody)
    }
}

// WebViewController+WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url {
            push(with: url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}


extension WebViewController: WebViewNavigatorDelegate {
    func push(with url: URL) {
        let newViewController = WebViewController(url: url)
        navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func pop(steps: Int) {
        guard let navigationController = navigationController else { return }
        
        let currentStackCount = navigationController.viewControllers.count
        print("currentStackCount",currentStackCount)
        let maxPossibleSteps = currentStackCount - 1
        let actualSteps = min(steps, maxPossibleSteps)
        print("actualSteps",actualSteps)
        
        if actualSteps > 0 {
                   
                   let destinationIndex = currentStackCount - 1 - actualSteps
                   let destinationViewController = navigationController.viewControllers[destinationIndex]
                   navigationController.popToViewController(destinationViewController, animated: true)
               }

        
    }
}
