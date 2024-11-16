const mongoose = require("mongoose");
const { userSchema } = require("./user");
const { messageSchema } = require("./message");
const { User } = require("./user");

const conversationSchema = mongoose.Schema({
  // members: [userSchema],
  members: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: User,
    },
  ],
  messages: [messageSchema],
  lastMessage: messageSchema,
  createdAt: {
    type: Number,
    // required: true,
  },
});

const Conversation = mongoose.model("Conversation", conversationSchema);
module.exports = Conversation;
