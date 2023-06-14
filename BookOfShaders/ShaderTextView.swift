
import Foundation
import AppKit
import Combine
import SwiftUI

class ShaderTextView: NSTextView {
    func setup(_ initialText: NSAttributedString) {
        attributedString = initialText
        allowsImageEditing = false
        allowsUndo = true
        backgroundColor = .clear
        layoutManager?.defaultAttachmentScaling = .scaleProportionallyDown
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    var attributedString: NSAttributedString {
        get { attributedString() }
        set { textStorage?.setAttributedString(newValue) }
    }

    var isFirstResponder: Bool {
        window?.firstResponder == self
    }
}

class ShaderTextEditorContext: ObservableObject {
    @Published var attributedString: NSAttributedString?
}

class ShaderTextViewDelegate: NSObject, NSTextViewDelegate {
    public init(
        text: Binding<NSAttributedString>,
        textView: ShaderTextView,
        context: ShaderTextEditorContext
    ) {
        textView.attributedString = text.wrappedValue
        self.text = text
        self.textView = textView
        self.context = context
        super.init()
        self.textView.delegate = self
        subscribeToContextChanges()
    }

    public let context: ShaderTextEditorContext

    public var text: Binding<NSAttributedString>

    var textView: ShaderTextView

    public var cancellables = Set<AnyCancellable>()

    func subscribeToContextChanges() {
        context.$attributedString.sink(receiveCompletion: { _ in },
                                       receiveValue: { [weak self] in
            let selection = self?.textView.selectedRange()
            self?.setAttributedString(to: $0)
            if let selection {
                self?.textView.selectedRange = selection
            }
        }).store(in: &cancellables)
    }

    func syncContextWithTextView() {
        // This is admittedly janky, but it cuts down on flicker
        DispatchQueue.main.async {
            self.syncContextWithTextViewImmediate()
        }
    }

    func syncContextWithTextViewImmediate() {
        context.attributedString = self.textView.attributedString
    }

    func setAttributedString(to newValue: NSAttributedString?) {
        guard let newValue else { return }
        textView.attributedString = newValue
        text.wrappedValue = newValue
    }

    func textDidChange(_ notification: Notification) {
        syncContextWithTextView()
    }
}

struct ShaderTextEditor : NSViewRepresentable {
    typealias ViewUserConfiguration = (NSTextView) -> Void

    public let scrollView = ShaderTextView.scrollableTextView()

    public var textView: ShaderTextView {
        scrollView.documentView as? ShaderTextView ?? ShaderTextView()
    }

    private var text: Binding<NSAttributedString>

    @ObservedObject
    private var context: ShaderTextEditorContext

    private var userConfiguration: ViewUserConfiguration

    public init(
        text: Binding<NSAttributedString>,
        context: ShaderTextEditorContext,
        userConfiguration: @escaping ViewUserConfiguration = { _ in }
    ) {
        self.text = text
        self._context = ObservedObject(wrappedValue: context)
        self.userConfiguration = userConfiguration
    }

    func makeNSView(context: Context) -> some NSView {
        textView.setup(text.wrappedValue)
        userConfiguration(textView)
        return scrollView
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
    }

    func makeCoordinator() -> ShaderTextViewDelegate {
        return ShaderTextViewDelegate(text: text,
                                      textView: textView,
                                      context: context)
    }
}
