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

struct YogaStyle: Identifiable, Hashable {
    let id: String
    let name: String
    let bestFor: String
    let researchSummary: String
    let intensity: String
    let practiceFeel: String
    let breathCue: String
    let poses: [YogaPose]
}

struct YogaGoalGuide: Identifiable, Hashable {
    let id: String
    let goal: String
    let styles: String
    let rationale: String
}

extension YogaPose {
    static let easySeat = YogaPose(
        id: "easy_seat",
        name: "Easy Seat",
        focus: "Centering",
        cue: "Sit tall, soften the jaw, and let the breath settle into a calm rhythm.",
        holdDuration: 18,
        figure: YogaFigureSpec(
            torsoAngle: -90,
            leftUpperArmAngle: 140,
            leftLowerArmAngle: 96,
            rightUpperArmAngle: 40,
            rightLowerArmAngle: 84,
            leftUpperLegAngle: 148,
            leftLowerLegAngle: 18,
            rightUpperLegAngle: 32,
            rightLowerLegAngle: 162
        )
    )

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

    static let goddess = YogaPose(
        id: "goddess",
        name: "Goddess Squat",
        focus: "Power",
        cue: "Keep the spine tall, knees wide, and draw the hands together at the heart.",
        holdDuration: 20,
        figure: YogaFigureSpec(
            torsoAngle: -102,
            leftUpperArmAngle: 28,
            leftLowerArmAngle: -52,
            rightUpperArmAngle: 118,
            rightLowerArmAngle: 208,
            leftUpperLegAngle: 150,
            leftLowerLegAngle: 98,
            rightUpperLegAngle: 32,
            rightLowerLegAngle: 80
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

    static let plank = YogaPose(
        id: "plank",
        name: "Plank",
        focus: "Core",
        cue: "Press the floor away and keep one long line from shoulders to heels.",
        holdDuration: 16,
        figure: YogaFigureSpec(
            torsoAngle: 182,
            leftUpperArmAngle: 112,
            leftLowerArmAngle: 112,
            rightUpperArmAngle: 102,
            rightLowerArmAngle: 102,
            leftUpperLegAngle: 184,
            leftLowerLegAngle: 184,
            rightUpperLegAngle: 176,
            rightLowerLegAngle: 176
        )
    )

    static let cobra = YogaPose(
        id: "cobra",
        name: "Cobra",
        focus: "Chest opening",
        cue: "Lift through the sternum and keep the shoulders sliding away from the ears.",
        holdDuration: 14,
        figure: YogaFigureSpec(
            torsoAngle: -32,
            leftUpperArmAngle: 92,
            leftLowerArmAngle: 92,
            rightUpperArmAngle: 88,
            rightLowerArmAngle: 88,
            leftUpperLegAngle: 8,
            leftLowerLegAngle: 4,
            rightUpperLegAngle: -4,
            rightLowerLegAngle: -8
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

    static let seatedTwist = YogaPose(
        id: "seated_twist",
        name: "Seated Twist",
        focus: "Mobility",
        cue: "Lengthen upward before gently rotating from the rib cage.",
        holdDuration: 18,
        figure: YogaFigureSpec(
            torsoAngle: -70,
            leftUpperArmAngle: 18,
            leftLowerArmAngle: 122,
            rightUpperArmAngle: 102,
            rightLowerArmAngle: 188,
            leftUpperLegAngle: 154,
            leftLowerLegAngle: 12,
            rightUpperLegAngle: 26,
            rightLowerLegAngle: 176
        )
    )

    static let bridge = YogaPose(
        id: "bridge",
        name: "Bridge",
        focus: "Recovery",
        cue: "Press into the feet and broaden the chest without gripping the neck.",
        holdDuration: 18,
        figure: YogaFigureSpec(
            torsoAngle: -18,
            leftUpperArmAngle: 86,
            leftLowerArmAngle: 86,
            rightUpperArmAngle: 94,
            rightLowerArmAngle: 94,
            leftUpperLegAngle: 126,
            leftLowerLegAngle: 82,
            rightUpperLegAngle: 54,
            rightLowerLegAngle: 98
        )
    )

    static let childsPose = YogaPose(
        id: "childs_pose",
        name: "Child's Pose",
        focus: "Rest",
        cue: "Soften the belly toward the thighs and let the back body widen.",
        holdDuration: 24,
        figure: YogaFigureSpec(
            torsoAngle: 26,
            leftUpperArmAngle: 24,
            leftLowerArmAngle: 18,
            rightUpperArmAngle: 12,
            rightLowerArmAngle: 8,
            leftUpperLegAngle: 136,
            leftLowerLegAngle: 182,
            rightUpperLegAngle: 42,
            rightLowerLegAngle: -6
        )
    )

    static let legsUpWall = YogaPose(
        id: "legs_up_wall",
        name: "Legs Up The Wall",
        focus: "Reset",
        cue: "Relax the jaw and let the legs be heavy and supported.",
        holdDuration: 26,
        figure: YogaFigureSpec(
            torsoAngle: 180,
            leftUpperArmAngle: 188,
            leftLowerArmAngle: 188,
            rightUpperArmAngle: 172,
            rightLowerArmAngle: 172,
            leftUpperLegAngle: -90,
            leftLowerLegAngle: -90,
            rightUpperLegAngle: -90,
            rightLowerLegAngle: -90
        )
    )

    static let corpse = YogaPose(
        id: "corpse",
        name: "Corpse Pose",
        focus: "Integration",
        cue: "Let the breath move naturally and release any effort from the body.",
        holdDuration: 30,
        figure: YogaFigureSpec(
            torsoAngle: 180,
            leftUpperArmAngle: 206,
            leftLowerArmAngle: 206,
            rightUpperArmAngle: 154,
            rightLowerArmAngle: 154,
            leftUpperLegAngle: 174,
            leftLowerLegAngle: 174,
            rightUpperLegAngle: 186,
            rightLowerLegAngle: 186
        )
    )
}

extension YogaStyle {
    static let hatha = YogaStyle(
        id: "hatha",
        name: "Hatha",
        bestFor: "Beginners",
        researchSummary: "A slower, foundational practice built around basic postures, breath awareness, and steady pacing, which makes it approachable for new practitioners.",
        intensity: "Gentle",
        practiceFeel: "Measured, instructional, balanced",
        breathCue: "Match each movement with a long inhale or exhale.",
        poses: [.mountain, .chair, .forwardFold, .lowLunge, .warriorTwo, .tree]
    )

    static let restorative = YogaStyle(
        id: "restorative",
        name: "Restorative",
        bestFor: "Beginners, flexibility, recovery",
        researchSummary: "Restorative yoga emphasizes stillness, longer supported holds, and nervous-system downshifting, which is why it is often recommended for recovery, better sleep, and stress relief.",
        intensity: "Very low",
        practiceFeel: "Quiet, supported, deeply calming",
        breathCue: "Lengthen the exhale and allow the body to settle on each breath out.",
        poses: [.childsPose, .bridge, .legsUpWall, .corpse]
    )

    static let iyengar = YogaStyle(
        id: "iyengar",
        name: "Iyengar",
        bestFor: "Beginners, precision",
        researchSummary: "Iyengar is known for alignment detail, prop use, and pose precision, making it especially helpful for building safe form and body awareness.",
        intensity: "Low to moderate",
        practiceFeel: "Precise, structured, alignment-led",
        breathCue: "Slow the pace enough to notice alignment before depth.",
        poses: [.mountain, .chair, .warriorTwo, .forwardFold, .tree]
    )

    static let vinyasa = YogaStyle(
        id: "vinyasa",
        name: "Vinyasa",
        bestFor: "Fitness, weight loss",
        researchSummary: "Vinyasa links breath with continuous movement in flowing sequences, which tends to raise heat, increase cardiovascular demand, and keep practice dynamic.",
        intensity: "Moderate",
        practiceFeel: "Fluid, energizing, rhythmic",
        breathCue: "Keep the breath steady so the flow never outruns control.",
        poses: [.mountain, .chair, .plank, .cobra, .lowLunge, .warriorTwo]
    )

    static let power = YogaStyle(
        id: "power",
        name: "Power Yoga",
        bestFor: "Fitness, weight loss",
        researchSummary: "Power Yoga is a more athletic, strength-forward evolution of flowing practice, often used by people who want a stronger conditioning effect from yoga.",
        intensity: "High",
        practiceFeel: "Athletic, hot, strength-heavy",
        breathCue: "Use strong nasal breaths to stay composed under effort.",
        poses: [.chair, .goddess, .plank, .lowLunge, .warriorTwo, .tree]
    )

    static let yin = YogaStyle(
        id: "yin",
        name: "Yin",
        bestFor: "Flexibility, recovery",
        researchSummary: "Yin uses passive, longer holds to work into connective tissue and joint range, which is why it is commonly chosen for flexibility and slower recovery sessions.",
        intensity: "Low",
        practiceFeel: "Still, deep, meditative",
        breathCue: "Relax muscular effort and breathe into the edge of sensation.",
        poses: [.forwardFold, .childsPose, .seatedTwist, .bridge, .legsUpWall]
    )

    static let ashtanga = YogaStyle(
        id: "ashtanga",
        name: "Ashtanga",
        bestFor: "Discipline, challenge",
        researchSummary: "Ashtanga follows progressive, repeatable sequences with a strong emphasis on consistency, stamina, and disciplined repetition.",
        intensity: "High",
        practiceFeel: "Structured, demanding, disciplined",
        breathCue: "Keep the breath even and deliberate as effort builds.",
        poses: [.mountain, .chair, .forwardFold, .plank, .cobra, .lowLunge, .warriorTwo, .tree]
    )

    static let kundalini = YogaStyle(
        id: "kundalini",
        name: "Kundalini",
        bestFor: "Mindfulness, energy work",
        researchSummary: "Kundalini blends posture, breathwork, meditation, and focused repetition to support awareness, mental clarity, and a stronger sense of internal energy.",
        intensity: "Low to moderate",
        practiceFeel: "Meditative, energizing, inwardly focused",
        breathCue: "Let the breath lead attention inward before each movement.",
        poses: [.easySeat, .mountain, .goddess, .tree, .corpse]
    )

    static let catalog: [YogaStyle] = [
        .hatha,
        .restorative,
        .iyengar,
        .vinyasa,
        .power,
        .yin,
        .ashtanga,
        .kundalini
    ]
}

extension YogaGoalGuide {
    static let recommendations: [YogaGoalGuide] = [
        YogaGoalGuide(
            id: "beginners",
            goal: "Beginners",
            styles: "Hatha, Restorative, Iyengar",
            rationale: "These styles move slower, teach foundations clearly, and give more room to learn alignment and breath control."
        ),
        YogaGoalGuide(
            id: "fitness",
            goal: "Fitness & Weight Loss",
            styles: "Vinyasa, Power Yoga",
            rationale: "These sessions keep you moving continuously, build heat, and add more full-body effort."
        ),
        YogaGoalGuide(
            id: "flexibility",
            goal: "Flexibility & Recovery",
            styles: "Yin, Restorative",
            rationale: "Longer holds and calmer pacing support tissue release, mobility work, and recovery days."
        ),
        YogaGoalGuide(
            id: "discipline",
            goal: "Discipline & Challenge",
            styles: "Ashtanga",
            rationale: "Ashtanga rewards repetition, stamina, and a more rigorous practice rhythm."
        ),
        YogaGoalGuide(
            id: "mindfulness",
            goal: "Mindfulness & Energy Work",
            styles: "Kundalini",
            rationale: "Kundalini puts more emphasis on breath, meditation, repetition, and inward focus."
        )
    ]
}