pub fn allowed(age: u8, has_ticket: bool) bool {
    return age >= 18 and has_ticket;
}
