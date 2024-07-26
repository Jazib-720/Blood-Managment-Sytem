const express = require('express');
const ejs = require('ejs');
const methodOverride = require('method-override');
const mysql = require('mysql2');
const path = require('path');
const app = express();
const port = process.env.PORT || 3090;

// Connect to the MySQL database
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'root',
    database: 'BloodBank_Management',
});

db.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL:', err);
    } else {
        console.log('Connected to MySQL');
    }
});

// Set EJS as the view engine
app.set('view engine', 'ejs');
app.use(express.json());
app.use(express.urlencoded({ extended: true })); // This is for parsing form data
app.use(methodOverride('_method'));
// Middleware - You may add more middleware as needed
app.use(express.static('public'));
app.set('views', path.join(__dirname, 'views'));

app.get('/', (req, res) => {
    res.redirect('/login');
});
//-------------------------LOGIN PAGE---------------------
app.get('/login', (req, res) => {
    res.render('login');
  });
  
  app.post('/login', (req, res) => {
    const { username, password } = req.body;
  
    // Assuming you have a 'users' table for authentication
    db.query(
        'SELECT * FROM users WHERE username = ? AND password = ?',
        [username, password],
        (error, results) => {
            if (error) {
                console.error('Error executing query:', error);
                res.status(500).json({ error: 'Internal Server Error' });
                return;
            }
  
            // Check if the user exists
            if (results.length > 0 && results[0].Username === username && results[0].Password === password) {
                res.render('index');
            } else {
                res.status(401).json({ error: 'Invalid username or password' });
            }
        }
    );
  });
  app.get('/index', (req, res) => {
    res.render('index');
});

// top donor 
app.get('/topDonor', (req, res) => {
    // Query the view TopDonor to get the top donor
    db.query('SELECT  Userid,Username,Total_bottlesdonate FROM Donor ORDER BY Total_bottlesdonate DESC LIMIT 1;', (err, results) => {
        if (err) {
            console.error('Error getting top donor:', err);
            res.status(500).json({ error: 'Error getting top donor' });
            return;
        }

        if (results.length > 0)  {
            const [topDonor] = results;
            const topDonorsData = results;

            // Extract Total_bottlesdonate from topDonor
            const { Total_bottlesdonate } = topDonor;

            // Log the Total_bottlesdonate value
            console.log("Total_bottlesdonate:", Total_bottlesdonate);

            // Render the topdonor.ejs template with the fetched top donor data
            res.render('topDonor', { topDonorsData, topDonor, Total_bottlesdonate });
        } else {
            res.json({ message: 'No top donor found' });
        }
    });
});





app.get('/signup', (req, res) => {
    const nationality = 'pakistani';  // Replace with your actual data

    res.render('signup', { nationality });
    
});











app.post('/signup', (req, res) => {
    const {
        username,
        password,
        email,
        phoneNumber,
        nationality,
        location,
        bloodGroup,
    } = req.body;
    console.log('Received data:');
    console.log('Username:', username);
    console.log('Password:', password);
    console.log('Email:', email);
    console.log('Phone Number:', phoneNumber);
    console.log('Nationality:', nationality);
    console.log('Location:', location);
    console.log('Blood Group:', bloodGroup);
    // Use stored procedure for sign up
    db.query(
        'CALL SignUpUser(NULL, ?, ?, ?, ?, ?, ?, ?)',
        [username, password, email, phoneNumber, nationality, location, bloodGroup],
        (error, results) => {
            if (error) {
                console.error('Error executing signup query:', error);
                res.status(500).json({ error: 'Internal Server Error' });
                return;
            }

            // Check the status returned by the stored procedure
            if (results[0][0].Status === 'User already exists') {
                res.status(400).json({ error: 'User already exists' });
            } else {
                // Render success page or redirect as needed
                res.render('login');
            }
        }
    );
});
app.get('/BloodCatalogue', (req, res) => {
    // Fetch blood donors from the database
    db.query('SELECT * FROM Donor', (err, results) => {
        if (err) {
            console.error('Error getting blood donors:', err);
            res.status(500).json({ error: 'Error getting blood donors' });
            return;
        }

        const bloodDonors = results;

        // Render the catalog page with the fetched blood donors data
        res.render('BloodCatalogue', { bloodDonors });
    });
});

app.get('/faq', (req, res) => {
    res.render('faq');
  });
  app.get('/aboutUs', (req, res) => {
    res.render('aboutUs', {
        founder: 'Jazib Zafar',
        foundingYear: 2023,
      });
  });

  app.get('/feedBack', (req, res) => {
    res.render('feedBack');
  });
  
  // Define a route to handle the form submission
  app.post('/submit-feedback', (req, res) => {
    const { name, email, feedback } = req.body;
    if (!feedback) {
        return res.status(400).send('Feedback is required');
    }
    // Insert feedback into the database
    db.query(
      'INSERT INTO Feedback (UserID, FeedbackText, FeedbackDate) VALUES (?, ?, NOW())',
      [1, feedback],
      (err, results) => {
        if (err) {
          console.error(err);
          res.status(500).send('Internal Server Error');
        } else {
          // You can also redirect to a thank-you page or display a thank-you message
          res.send('Thank you for your feedback!');
        }
      }
    );
  });





//------------PROFILE UPDATE PAGE-----------------
// Update Profile Page
// Update Profile Page
app.get('/update-profile', (req, res) => {
    res.render('update-profile');
});
app.get('/update-profile/:userId', (req, res) => {
    const userId = req.params.userId;

    const query = 'SELECT * FROM Users WHERE UserID = ?';
    db.query(query, [userId], (err, results) => {
        if (err) {
            console.error('Error executing query:', err);
            return res.status(500).json({ message: 'Internal server error.' });
        }

        if (results.length === 1) {
            const user = results[0];
            console.log('User found:', user);
            return res.render('update-profile', { user });
        } else {
            console.log('User not found.');
            return res.status(404).json({ message: 'User not found.' });
        }
        
    });
});

  
  app.put('/update-profile/:userId', (req, res) => {
    const userId = req.params.userId;
    const { phoneNumber, location, bloodgroup } = req.body;
  
    const query = 'UPDATE Users SET phoneNumber=?, location=?, bloodgroup=? WHERE UserID=?';
    db.query(query, [phoneNumber, location, bloodgroup, userId], (err, results) => {
      if (err) {
        console.error('Error executing query:', err);
        return res.status(500).json({ message: 'Internal server error.' });
      }
  
      if (results.affectedRows === 1) {
        return res.json({ message: 'Profile updated successfully.' });
      } else {
        return res.status(404).json({ message: 'User not found.' });
      }
    });
  });





  
      
  
    
  



















// Start the server
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});




