import Foundation

struct YogaPose: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let focus: String
    let cue: String
    let holdDuration: Int
    let figure: YogaFigureSpec
}

struct YogaFigureSpec: Codable, Hashable {
    let torsoAngle: Double
    let leftUpperArmAngle: Double
    let leftLowerArmAngle: Double
    let rightUpperArmAngle: Double
    let rightLowerArmAngle: Double
    let leftUpperLegAngle: Double
    let leftLowerLegAngle: Double
    let rightUpperLegAngle: Double
    let rightLowerLegAngle: Double
}

extension YogaPose {
    static let mountain = YogaPose(
        id: "mountain",
        name: "Mountain",
        focus: "Grounding",
        cue: "Root through both feet and soften your shoulders.",
        holdDuration: 20,
        figure: YogaFigureSpec(
            torsoAngle: -90,
            leftUpperArmAngle: 128,
            leftLowerArmAngle: 128,
            rightUpperArmAngle: 52,
            rightLowerArmAngle: 52,
            leftUpperLegAngle: 104,
            leftLowerLegAngle: 92,
            rightUpperLegAngle: 76,
            rightLowerLegAngle: 88
        )
    )

    static let chair = YogaPose(
        id: "chair",
        name: "Chair",
        focus: "Heat",
        cue: "Sink the hips back and keep the chest lifted.",
        holdDuration: 18,
        figure: YogaFigureSpec(
            torsoAngle: -98,
            leftUpperArmAngle: -112,
            leftLowerArmAngle: -98,
            rightUpperArmAngle: -68,
            rightLowerArmAngle: -82,
            leftUpperLegAngle: 122,
            leftLowerLegAngle: 82,
            rightUpperLegAngle: 58,
            rightLowerLegAngle: 98
        )
    )

    static let forwardFold = YogaPose(
        id: "forward_fold",
        name: "Forward Fold",
        focus: "Release",
        cue: "Let the neck hang and drape the torso over the legs.",
        holdDuration: 16,
        figure: YogaFigureSpec(
            torsoAngle: 132,
            leftUpperArmAngle: 112,
            leftLowerArmAngle: 104,
            rightUpperArmAngle: 68,
            rightLowerArmAngle: 76,
            leftUpperLegAngle: 102,
            leftLowerLegAngle: 94,
            rightUpperLegAngle: 78,
            rightLowerLegAngle: 86
        )
    )

    static let lowLunge = YogaPose(
        id: "low_lunge",
        name: "Low Lunge",
        focus: "Opening",
        cue: "Lift the heart and keep the front knee stacked above the ankle.",
        holdDuration: 20,
        figure: YogaFigureSpec(
            torsoAngle: -88,
            leftUpperArmAngle: -120,
            leftLowerArmAngle: -108,
            rightUpperArmAngle: -60,
            rightLowerArmAngle: -72,
            leftUpperLegAngle: 160,
            leftLowerLegAngle: 160,
            rightUpperLegAngle: 62,
            rightLowerLegAngle: 90
        )
    )

    static let warriorTwo = YogaPose(
        id: "warrior_two",
        name: "Warrior II",
        focus: "Strength",
        cue: "Reach long through both fingertips and settle into the front thigh.",
        holdDuration: 24,
        figure: YogaFigureSpec(
            torsoAngle: -90,
            leftUpperArmAngle: 180,
            leftLowerArmAngle: 180,
            rightUpperArmAngle: 0,
            rightLowerArmAngle: 0,
            leftUpperLegAngle: 176,
            leftLowerLegAngle: 176,
            rightUpperLegAngle: 62,
            rightLowerLegAngle: 92
        )
    )

    static let tree = YogaPose(
        id: "tree",
        name: "Tree",
        focus: "Balance",
        cue: "Stand tall and gather the hands overhead.",
        holdDuration: 20,
        figure: YogaFigureSpec(
            torsoAngle: -90,
            leftUpperArmAngle: -114,
            leftLowerArmAngle: -96,
            rightUpperArmAngle: -66,
            rightLowerArmAngle: -84,
            leftUpperLegAngle: 138,
            leftLowerLegAngle: 24,
            rightUpperLegAngle: 78,
            rightLowerLegAngle: 90
        )
    )

    static let dailyFlow: [YogaPose] = [
        .mountain,
        .chair,
        .forwardFold,
        .lowLunge,
        .warriorTwo,
        .tree
    ]
}