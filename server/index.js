// IMPORTS FROM PACKAGES
const express = require("express");
const mongoose = require("mongoose");
const adminRouter = require("./routes/admin");
// IMPORTS FROM OTHER FILES
const authRouter = require("./routes/auth");
const productRouter = require("./routes/product");
const userRouter = require("./routes/user");
const branchRouter = require("./routes/branch");
const messageRouter = require("./routes/message");

const { server, app } = require("./SocketIO/server");


// INIT
const PORT = process.env.PORT || 3000;
// const app = express();
const DB =
  "mongodb+srv://trongngo:trong123@cluster0.jlqp3va.mongodb.net/?retryWrites=true&w=majority";

// middleware
app.use(express.json());
app.use(authRouter);
app.use(adminRouter);
app.use(branchRouter);
app.use(productRouter);
app.use(userRouter);
app.use(messageRouter);

// Connections
mongoose
  .connect(DB)
  .then(() => {
    console.log("onnection SuccessCful");
  })
  .catch((e) => {
    console.log(e);
  });

server.listen(PORT, "0.0.0.0", () => {
  console.log(`connected at port ${PORT}`);
});

// const io = initializeSocket(server);
module.exports = server;
