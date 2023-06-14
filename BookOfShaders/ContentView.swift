import SwiftUI

struct ContentView: View {
    @EnvironmentObject var editorModel: ShaderEditorModel

    var body: some View {
        NavigationView {
            List {
                ForEach(editorModel.exampleStore.sections) { section in
                    Section(section.title) {
                        ForEach(section.examples) { example in
                            NavigationLink(example.title,
                                           destination: ShaderEditorView(sourceString: $editorModel.sourceString,
                                                                         editorModel: editorModel),
                                           tag: example.id,
                                           selection: $editorModel.selectedExampleID)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(idealWidth: 225)
            Text("Select a shader")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ShaderEditorModel())
    }
}
