import SpriteKit

enum Sound {
    case swoosh

    var action: SKAction {
        switch self {
        case .swoosh: SKAction.playSoundFileNamed("sounds/sfx_swooshing.caf",
                                                  waitForCompletion: false)
        }
    }
}
