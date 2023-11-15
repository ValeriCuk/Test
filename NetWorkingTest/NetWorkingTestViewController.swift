import UIKit
import WebKit

class NetWorkingTestViewController: UIViewController {
//    200 https://jsonplaceholder.typicode.com/todos/1
//    base https://bubblecrush.xyz/starting
    let apiEndpoint = "https://bubblecrush.xyz/starting"
    @IBOutlet weak var code200ImageView: UIImageView!
    var webView: WKWebView?
    var currentResponse: HTTPURLResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAndDisplayImage(apiEndpoint: apiEndpoint)
    }
    
    private func createWebView(in view: UIView) {
        webView = WKWebView(frame: view.bounds)
        webView?.navigationDelegate = self
        if let webView = webView {
            view.addSubview(webView)
        }
    }
    
    private func loadAndDisplayImage(apiEndpoint: String) {
        guard let url = URL(string: apiEndpoint) else {
            print("Invalid URL")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("Помилка при виклику API: \(error!.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Невідома помилка відповіді")
                return
            }
            self.currentResponse = httpResponse
            if httpResponse.statusCode == 200 {
                let imageName = "star"
                if let image = UIImage(named: imageName) {
                    DispatchQueue.main.async {
                        self.code200ImageView.image = image
                    }
                } else {
                    print("Не вдалося знайти зображення в ресурсах з ім'ям: \(imageName)")
                }
            } else if httpResponse.statusCode == 302 {
                print("Отримано перенаправлення. Відкриття WKWebView.")
                DispatchQueue.main.async {
                    if let webView = self.webView {
                        self.createWebView(in: webView)
                    }
                }
            } else {
                print("Отримано неприпустимий код статусу: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
}

extension NetWorkingTestViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let statusCode = currentResponse?.statusCode {
            if statusCode == 200 {
                decisionHandler(.allow)
            } else if statusCode == 302 {
                decisionHandler(.cancel)
                if let newURL = navigationAction.request.url {
                    let newWebView = WKWebView(frame: view.bounds)
                    newWebView.navigationDelegate = self
                    view.addSubview(newWebView)
                    newWebView.load(URLRequest(url: newURL))
                }
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}
