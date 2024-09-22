function fibonacci(n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

function printFibonacciSequence(length) {
    for (let i = 0; i < length; i++) {
        console.log(fibonacci(i));
    }
}

printFibonacciSequence(10);