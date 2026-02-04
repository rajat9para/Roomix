const express = require('express');
const chatController = require('../controllers/chatController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// Protect all routes with auth middleware
router.use(authMiddleware);

// Send a message
router.post('/send', chatController.sendMessage);

// Get messages between two users
router.get('/messages/:conversationId', chatController.getMessages);

// Get all conversations
router.get('/conversations', chatController.getConversations);

// Mark messages as read
router.put('/read/:conversationId', chatController.markAsRead);

// Delete message
router.delete('/message/:messageId', chatController.deleteMessage);

module.exports = router;
