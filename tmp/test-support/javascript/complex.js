function analyzeNumber(num) {
    let result = '';

    if (num < 0) {
        result += 'negative ';
    } else if (num > 0) {
        result += 'positive ';
    } else {
        return 'zero';
    }

    if (num % 2 === 0) {
        result += 'even ';
    } else {
        result += 'odd ';
    }

    if (num % 3 === 0) {
        result += 'divisible by 3 ';
    }

    if (num % 5 === 0) {
        result += 'divisible by 5 ';
    }

    if (isPrime(num)) {
        result += 'prime ';
    }

    return result.trim();
}

function isPrime(num) {
    if (num <= 1) return false;
    for (let i = 2; i <= Math.sqrt(num); i++) {
        if (num % i === 0) return false;
    }
    return true;
}

console.log(analyzeNumber(17));
console.log(analyzeNumber(30));
console.log(analyzeNumber(-7));