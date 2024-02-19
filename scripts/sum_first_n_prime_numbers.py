def is_number_prime(num: int) -> bool:
    result = True
    if num < 2:
        result = False
    else: 
        count = 2
        while count < num:
            if (num/count)%1 == 0:
                result = False
                break
            count = count + 1
    return result


# calculates the sum of the first n prime numbers
def sum_of_prime_numbers(number_of_primes: int) -> int:
    sum_of_primes, primes_found, count = 0, 0, 0
    while primes_found < number_of_primes:
        if is_number_prime(count):
            primes_found = primes_found + 1
            sum_of_primes += count
        count = count + 1

    return sum_of_primes

n = 100
print(sum_of_prime_numbers(n))
