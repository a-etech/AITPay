const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = 3001; // Use a different port than your JSON server

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Example route for payment processing
app.post('/api/payments', (req, res) => {
    const paymentData = req.body;

    // Here you would handle payment processing logic
    // For now, let's just simulate a successful payment response
    res.status(200).json({
        message: 'Payment processed successfully',
        data: paymentData,
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`Payment server running on http://localhost:${PORT}`);
});
