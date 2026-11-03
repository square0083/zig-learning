pub fn factorial(n: u8) u64 {
    var result: u64 = 1;
    var i: u8 = 2;
    while (i <= n) : (i += 1) {
        result *= i;
    }
    return result;
}
