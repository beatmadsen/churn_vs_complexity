fn calculate_sum(numbers: &[i32]) -> i32 {
    let mut total = 0;
    for n in numbers {
        total += n;
    }
    total
}

fn classify(value: i32) -> &'static str {
    match value {
        0 => "zero",
        1..=10 => "low",
        11..=100 => "medium",
        _ => "high",
    }
}

fn is_even(n: i32) -> bool {
    n % 2 == 0
}
