const express = require("express");
const mysql = require("mysql2/promise");
const app = express();

const port = 3000;

// Read DB creds from environment variables
const dbConfig = {
  host: process.env.MYSQL_HOST || "mysql",
  user: process.env.MYSQL_USER || "root",
  password: process.env.MYSQL_PASSWORD || "password",
  database: process.env.MYSQL_DATABASE || "testdb",
};

app.get("/search", async (req, res) => {
  const name = req.query.name;
  if (!name) {
    return res.status(400).send("Please provide ?name= parameter");
  }

  try {
    const conn = await mysql.createConnection(dbConfig);
    const [rows] = await conn.execute("SELECT * FROM users WHERE name = ?", [name]);
    await conn.end();
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Database error");
  }
});

app.listen(port, () => {
  console.log(`Frontend listening on port ${port}`);
});
