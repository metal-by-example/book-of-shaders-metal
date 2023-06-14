import Foundation
import SwiftUI
import MetalKit
import Splash

class ShaderEditorModel: ObservableObject {
    @Published var selectedExampleID: String? {
        didSet {
            if let selectedExampleID,
               let example = exampleStore.example(for: selectedExampleID),
               let source = example.fragmentShaderSource
            {
                renderer.example = example
                renderer.fragmentFunctionSource = example.fragmentShaderSource
                sourceString = sourceHighlighter.highlight(source)
            }
        }
    }

    @Published var sourceString = NSAttributedString(string: "") {
        didSet {
            renderer.fragmentFunctionSource = sourceString.string
        }
    }

    let theme: Theme
    let font = Splash.Font(name: "Monaco", size: 12.0)
    let grammar = MetalGrammar()
    let sourceHighlighter: SyntaxHighlighter<AttributedStringOutputFormat>
    let exampleStore = ShaderExampleStore()
    let device: MTLDevice
    let renderDelegate: MTKViewDelegate

    private let renderer: ShaderRenderer

    init() {
        device = MTLCreateSystemDefaultDevice()!
        renderer = ShaderRenderer(device: device)
        renderDelegate = renderer

        theme = Theme.wwdc18(withFont: font)
        sourceHighlighter = SyntaxHighlighter(format: AttributedStringOutputFormat(theme: theme),
                                              grammar: grammar)

        defer {
            // Auto-select the first available example
            selectedExampleID = exampleStore.sections.first?.examples.first?.id
        }
    }
}

struct MetalView : NSViewRepresentable {
    typealias NSViewType = MTKView

    let device: MTLDevice
    let delegate: MTKViewDelegate

    func makeNSView(context: Context) -> MTKView {
        let view = MTKView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.device = device
        view.delegate = delegate
        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {}
}

struct ShaderEditorView: View {
    @StateObject var context = ShaderTextEditorContext()
    @Binding var sourceString: NSAttributedString

    let device: MTLDevice
    let renderDelegate: MTKViewDelegate
    let theme: Splash.Theme
    let sourceHighlighter: SyntaxHighlighter<AttributedStringOutputFormat>

    init(sourceString: Binding<NSAttributedString>, editorModel: ShaderEditorModel) {
        self._sourceString = sourceString
        self.device = editorModel.device
        self.renderDelegate = editorModel.renderDelegate
        self.theme = editorModel.theme
        self.sourceHighlighter = editorModel.sourceHighlighter
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ShaderTextEditor(text: $sourceString, context: context) { textView in
                textView.backgroundColor = theme.backgroundColor
                textView.insertionPointColor = NSColor.white
            }
            .onChange(of: context.attributedString, perform: { newContents in
                guard let newString = newContents?.string else { return }
                // Re-highlight text on every keystroke. This might look like
                // it leads to an infinite loop, but updates via the context
                // are designed not to cause changes to be published back to us
                context.attributedString = sourceHighlighter.highlight(newString)
            })
            MetalView(device: device, delegate: renderDelegate)
                .frame(width: 200.0, height: 200.0)
                .cornerRadius(4.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 5.0)
                        .inset(by: -1.0)
                        .stroke(.white, lineWidth: 2.0)
                )
                .padding(EdgeInsets(top: 5.0, leading: 0.0, bottom: 0.0, trailing: 20.0))
        }
    }
}
