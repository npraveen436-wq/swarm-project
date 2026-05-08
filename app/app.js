const express = require('express');
const os = require('os');
const app = express();

app.get('/', (req, res) => {
  res.send(`
    <html>
      <body style="font-family: sans-serif; text-align: center; padding: 50px;">
        <h1>🐳 Hello from Docker Swarm!v2</h1>
        <p>Served by container on host: <b>${os.hostname()}</b></p>
        <p>Refresh the page — you'll see different hostnames as Swarm load-balances.</p>
      </body>
    </html>
  `);
});

app.get('/health', (req, res) => res.json({ status: 'ok', host: os.hostname() }));

app.listen(8080, () => console.log('Listening on 8080'));
