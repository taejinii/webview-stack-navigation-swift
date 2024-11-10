import WebKit

protocol WebViewNavigatorDelegate: AnyObject {
    func push(with url: URL)
    func pop(steps: Int)
}

class WebViewNavigator {
    weak var delegate: WebViewNavigatorDelegate?
    
    func handleNavigationMessage(_ message: [String: Any]){
        guard let action = message["action"] as? String else {return}
        
        switch action {
        case "push":
            if let urlString = message["url"] as? String,
               let url = URL(string: urlString){
                delegate?.push(with: url)
            }
        case "pop":
            if let steps = message["steps"] as? Int {
                delegate?.pop(steps: abs(steps))
            }else{
                delegate?.pop(steps: 1)
            }
        default:
            break
        }
    }
}
