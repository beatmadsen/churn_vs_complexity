package main

func calculateSum(numbers []int) int {
	total := 0
	for _, n := range numbers {
		total += n
	}
	return total
}

func isEven(n int) bool {
	return n%2 == 0
}
