const express = require("express");
const Conversation = require("../models/conversation");
const { Message } = require("../models/message");
const { Product } = require("../models/product");
const { User } = require("../models/user");
const auth = require("../middlewares/auth");
const { getReceiverSocketId, io } = require("../SocketIO/server");
const messageRouter = express.Router();

messageRouter.post("/api/message/send-message/:id", auth, async (req, res) => {
    try {
        const { messageEncryptForMe, messageEncryptForReveiver, image, productId } = req.body;
        const { id: receiverId } = req.params;
        const senderId = req.user; // current logged in user
        const product = await Product.findById(productId);
        let conversation = await Conversation.findOne({
            members: { $all: [senderId, receiverId] },
        });
        if (!conversation) {
            conversation = await Conversation.create({
                members: [senderId, receiverId],
                createdAt: new Date().getTime(),
            });
        }
        const newMessage = new Message({
            senderId,
            receiverId,
            messageEncryptForMe: messageEncryptForMe || "",
            messageEncryptForReveiver: messageEncryptForReveiver || "",
            image: image || null,
            product: product || null,
            createdAt: new Date().getTime(),
        });
        if (newMessage) {
            conversation.messages.push(newMessage);
            conversation.lastMessage = newMessage;
        }
        // await conversation.save()
        // await newMessage.save();
        await Promise.all([conversation.save(), newMessage.save()]); // run parallel
        const receiverSocketId = getReceiverSocketId(receiverId);
        if (receiverSocketId) {
            io.to(receiverSocketId).emit("newMessage", newMessage);
        }
        res.json(newMessage);
    } catch (error) {
        console.log("Error in sendMessage", error);
        res.status(500).json({ error: error.message });
    }
});
messageRouter.get("/api/message/get-message/:id", auth, async (req, res) => {
    try {
        const { id: chatUser } = req.params;
        const senderId = req.user; // current logged in user
        let conversation = await Conversation.findOne({
            members: { $all: [senderId, chatUser] },
        }).populate("messages");
        if (!conversation) {
            return res.status(201).json([]);
        }
        const messages = conversation.messages;
        res.json(messages);
    } catch (error) {
        console.log("Error in getMessage", error);
        res.status(500).json({ error: error.message });
    }
});

messageRouter.get("/api/conversation/list", auth, async (req, res) => {
    try {
        const userId = req.user; // Lấy ID của người dùng hiện tại từ middleware auth

        // Tìm tất cả các cuộc trò chuyện có sự tham gia của người dùng hiện tại
        const conversations = await Conversation.find({
            members: userId
        })
            .populate("members", "-password"); // Populate để lấy thông tin của các thành viên, loại bỏ trường `password`
        // .populate({
        //     path: "messages",
        //     options: { sort: { createdAt: -1 }, limit: 1 } // Lấy tin nhắn cuối cùng
        // });

        // Trả về danh sách các cuộc trò chuyện
        res.json(conversations);
    } catch (error) {
        console.log("Error in getConversationList", error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = messageRouter;