
import SwiftUI

struct ShaderExample : Identifiable {
    var id: String { return title }
    let title: String
    let fileName: String
    let entryPoint: String = "fragment_main"

    var fragmentShaderSource: String? {
        if let sourceURL = Bundle.main.url(forResource: fileName, withExtension: "metal") {
            return try? String(contentsOf: sourceURL, encoding: .utf8)
        }
        return nil
    }
}

struct ShaderExampleSection : Identifiable {
    var id: String { return title }
    let title: String
    let examples: [ShaderExample]
}

class ShaderExampleStore : ObservableObject {
    @Published var sections : [ShaderExampleSection] = [
        ShaderExampleSection(title: "Hello World", examples: [
            ShaderExample(title: "Solid Color", fileName: "02-hello-world")
        ]),
        ShaderExampleSection(title: "Uniforms", examples: [
            ShaderExample(title: "Time", fileName: "03a-uniforms-time"),
            ShaderExample(title: "Fragment Coordinates", fileName: "03b-fragment-coord")
        ]),
        ShaderExampleSection(title: "Shaping Functions", examples: [
            ShaderExample(title: "Line", fileName:"05a-shape-line"),
            ShaderExample(title: "Quintic Curve", fileName:"05b-shape-quintic"),
            ShaderExample(title: "Step", fileName:"05c-shape-step"),
            ShaderExample(title: "Smoothstep", fileName:"05d-shape-smoothstep")
        ]),
        ShaderExampleSection(title: "Colors", examples: [
            ShaderExample(title: "Mixing Colors", fileName:"06a-color-mix"),
            //ShaderExample(title: "Color Gradients", fileName:"06b-color-gradient"),
            //ShaderExample(title: "HSB Color Space", fileName:"06c-color-hsb"),
            //ShaderExample(title: "HSB in Polar Coordinates", fileName:"06d-color-polar")
        ]),
        /*
        ShaderExampleSection(title: "Shapes", examples: [
            ShaderExample(title: "Rectangle", fileName: "07a-shape-rectangle"),
            ShaderExample(title: "Circle", fileName: "07b-shape-circle"),
            ShaderExample(title: "Circle SDF", fileName: "07c-sdf-circle"),
            ShaderExample(title: "Round Rect", fileName: "07d-sdf-circles"),
            ShaderExample(title: "Polar Shapes", fileName: "07e-sdf-lobes"),
            ShaderExample(title: "Triangle", fileName: "07f-sdf-triangle")
        ]),
        ShaderExampleSection(title: "Matrices", examples: [
            ShaderExample(title: "Translate", fileName: "08a-matrix-translate"),
            ShaderExample(title: "Rotate", fileName: "08b-matrix-rotate"),
            ShaderExample(title: "Scale", fileName: "08c-matrix-scale"),
            ShaderExample(title: "YUV Color Space", fileName: "08d-matrix-yuv")
        ]),
        ShaderExampleSection(title: "Patterns", examples: [
            ShaderExample(title: "Spaces", fileName: "09a-pattern-spaces"),
            ShaderExample(title: "Squares", fileName: "09b-pattern-squares"),
            ShaderExample(title: "Bricks", fileName: "09c-pattern-bricks"),
            ShaderExample(title: "Tiles", fileName: "09d-pattern-tiles"),
        ]),
        ShaderExampleSection(title: "Random", examples: [
            ShaderExample(title: "Random", fileName: "10a-random"),
            ShaderExample(title: "Random Grid", fileName: "10b-random-grid"),
            ShaderExample(title: "Random Truchet Tiles", fileName: "10c-random-truchet")
        ]),
        ShaderExampleSection(title: "Noise", examples: [
            ShaderExample(title: "Noise", fileName: "11a-noise"),
            ShaderExample(title: "Simplex Noise", fileName: "11b-noise-simplex")
        ]),
        ShaderExampleSection(title: "Cellular Noise", examples: [
            ShaderExample(title: "Point Distance", fileName: "12a-point-distance"),
            ShaderExample(title: "Cellular Noise", fileName: "12b-cellular-noise"),
            ShaderExample(title: "Voronoi", fileName: "12c-voronoi")
        ]),
        ShaderExampleSection(title: "Fractal Brownian Motion", examples: [
            ShaderExample(title: "fBm", fileName: "13a-fbm"),
            ShaderExample(title: "Domain Warping", fileName: "13b-fbm-domain-warping")
        ])
        */
    ]

    func example(for id: String) -> ShaderExample? {
        // Linear scan isn't great, but given that we'll never have more than a few dozen examples, it's fine.
        for section in sections {
            for example in section.examples {
                if example.id == id {
                    return example
                }
            }
        }
        return nil
    }
}
