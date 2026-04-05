func calculateSum(_ numbers: [Int]) -> Int {
    var total = 0
    for n in numbers {
        total += n
    }
    return total
}

func classify(_ value: Int) -> String {
    switch value {
    case 0:
        return "zero"
    case 1...10:
        return "low"
    case 11...100:
        return "medium"
    default:
        return "high"
    }
}

func isEven(_ n: Int) -> Bool {
    return n % 2 == 0
}
