const mongoose = require("mongoose");
const { productSchema } = require("./product");

const messageSchema = mongoose.Schema({
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },
  receiverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },
  message: {
    type: String,
  },
  image: {
    type: String,
  },
  product: productSchema,
  createdAt: {
    type: Number,
  },
});

const Message = mongoose.model("Message", messageSchema);
module.exports = { Message, messageSchema };
