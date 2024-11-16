// // socket.js
// const socketIO = require("socket.io");
// const Message = require("../models/message");

// // Hàm để khởi tạo socket.io
// function initializeSocket(server) {
//   const io = socketIO(server);
//   var clients = {};

//   io.on("connection", (socket) => {
//     console.log("connected");
//     console.log(`${socket.id} has joined`);

//     socket.on("signin", (id) => {
//       console.log(id);
//       clients[id] = socket;
//       console.log(clients);
//     });

//     socket.on("message", async (msg) => {
//       console.log(msg);
//       let targetId = msg.targetId;
//       if (clients[targetId]) clients[targetId].emit("message", msg);
//     });
//   });
// }

// module.exports = initializeSocket;

const express = require("express");
const http = require("http");
const Server = require("socket.io");

const app = express();


const server = http.createServer(app);
const io = Server(server, {
  cors: {
    origin: "https://ecrm-server.onrender.com",
    methods: ["GET", "POST"],
  },
});
// realtime message code goes here
const getReceiverSocketId = (receiverId) => {
  return users[receiverId];
};
const users = {};

// module.exports = { getReceiverSocketId };

// used to listen events on server side.
io.on("connection", (socket) => {
  console.log("a user connected", socket.id);
  const userId = socket.handshake.query.userId;
  console.log(`mmmmmmmmmmmmmmm ${userId}`);
  if (userId) {
    users[userId] = socket.id;
    console.log("Hello ", users);
  }
  // used to send the events to all connected users
  io.emit("getOnlineUsers", Object.keys(users));

  // used to listen client side events emitted by server side (server & client)
  socket.on("disconnect", () => {
    console.log("a user disconnected", socket.id);
    delete users[userId];
    io.emit("getOnlineUsers", Object.keys(users));
  });
});

module.exports = { app, server, io, getReceiverSocketId }

// socket.js
// const socketIO = require("socket.io");

// const users = {};

// const getReceiverSocketId = (receiverId) => {
//   return users[receiverId];
// };

// const initializeSocket = (server) => {
//   const io = socketIO(server);

//   io.on("connection", (socket) => {
//     console.log("a user connected", socket.id);
//     const userId = socket.handshake.query.userId;

//     if (userId) {
//       users[userId] = socket.id;
//       console.log("Hello ", users);
//     }

//     io.emit("getOnlineUsers", Object.keys(users));

//     socket.on("disconnect", () => {
//       console.log("a user disconnected", socket.id);
//       delete users[userId];
//       io.emit("getOnlineUsers", Object.keys(users));
//     });
//   });

//   return io;
// };

// module.exports = { initializeSocket, getReceiverSocketId };
