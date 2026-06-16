const http = require('http');

http.get('http://127.0.0.1:8080/api/v1/blog/posts/organization/6a280f7d1d4cb6863889ed55', (res) => {
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    res.on('end', () => {
        console.log(data);
    });
}).on('error', (err) => {
    console.error("HTTP Error:", err);
});
