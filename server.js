const express = require('express');
const mysql = require('mysql2');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Isku xidhka Database-ka
const db = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'smart_farming'
}).promise();

// --- AUTH ROUTES ---

// 1. Register
app.post('/api/auth/register', async (req, res) => {
  const { name, email, password, role } = req.body;
  try {
    const hashed = await bcrypt.hash(password, 10);
    await db.execute(
      'INSERT INTO users (name, email, password, role) VALUES (?,?,?,?)',
      [name, email, hashed, role || 'User']
    );
    res.status(201).json({ success: true, message: "User Created" });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// 2. Login
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const [rows] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0 || !(await bcrypt.compare(password, rows[0].password))) {
      return res.status(401).json({ success: false, message: "Email ama Password khaldan" });
    }
    const token = jwt.sign({ id: rows[0].id }, 'secret123', { expiresIn: '24h' });
    res.json({ 
      success: true, 
      token: token, 
      user: { id: rows[0].id, name: rows[0].name, email: rows[0].email, role: rows[0].role } 
    });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// --- CROP ROUTES ---

// 1. Get All Crops
app.get('/api/crops', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM crops');
    res.json(rows); 
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 2. Add New Crop (Halkan ayaa la saxay - user_id)
app.post('/api/crops', async (req, res) => {
  const { name, status, user_id } = req.body; 
  try {
    const [result] = await db.execute(
      'INSERT INTO crops (name, status, user_id) VALUES (?, ?, ?)',
      [name, status, user_id]
    );
    res.status(201).json({ success: true, message: "La kaydiyey" });
  } catch (e) {
    console.error("DATABASE ERROR:", e.message);
    res.status(500).json({ success: false, message: e.message });
  }
});

// 3. Update Crop
app.put('/api/crops/:id', async (req, res) => {
  const { name, status } = req.body;
  const { id } = req.params;
  try {
    await db.execute(
      'UPDATE crops SET name = ?, status = ? WHERE id = ?',
      [name, status, id]
    );
    res.json({ success: true, message: "Waa la cusboonaysiiyey" });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// 4. Delete Crop
app.delete('/api/crops/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await db.execute('DELETE FROM crops WHERE id = ?', [id]);
    res.json({ success: true, message: "Waa la tirtiray" });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// CONFIGURATION
const PORT = 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Server is running on http://localhost:${PORT}`);
});