
async function test() {
    const res = await fetch('http://localhost:3000/api/auth/login', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({email: 'partner@example.com', password: 'password123'})
    });
    const data = await res.json();
    console.log("Login:", data.user ? "Success" : data);
    
    const res2 = await fetch('http://localhost:3000/api/partner/stats', {
        headers: { 'Authorization': 'Bearer ' + data.token }
    });
    console.log("Stats status:", res2.status);
    console.log("Stats body:", await res2.text());
}
test();
