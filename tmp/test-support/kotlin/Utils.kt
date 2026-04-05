fun calculateSum(numbers: List<Int>): Int {
    var total = 0
    for (n in numbers) {
        total += n
    }
    return total
}

fun isEven(n: Int): Boolean {
    return n % 2 == 0
}
