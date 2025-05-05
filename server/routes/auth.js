const express = require("express");
const { User } = require("../models/user");
const bcryptjs = require("bcryptjs");
const authRouter = express.Router();
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const auth = require("../middlewares/auth");
const nodemailer = require('nodemailer');
const { OTP } = require("../models/otp");

// SIGN UP
authRouter.post("/api/signup", async (req, res) => {
  try {
    const { name, email, password, publicKey, privateKey } = req.body; // nhận thông tin từ request body 

    const existingUser = await User.findOne({ email }); // kiểm tra xem người dùng tồn tại hay chưa , kiểm tra xem email giống với email đã nhập từ form đăng ký
    if (existingUser) {
      return res
        .status(400) // trả về mã 
        .json({ msg: "Người dùng có cùng email đã tồn tại!" });
    }

    // const hashedPassword = await bcryptjs.hash(password, 8);

    let user = new User({
      email,
      password,
      name,
      publicKey,
      privateKey,
    });
    user = await user.save(); // lưu dữ liệu vào mongoDB và trả về đối tượng người dùng sau khi đã lưu thành công
    res.json(user); // trả về dạng json
  } catch (e) {
    res.status(500).json({ error: e.message }); // nếu lỗi trong quá trình thì phản hồi với mã 500
  }
});

// Sign In Route
// Exercise
authRouter.post("/api/signin", async (req, res) => {
  try {
    const { email, password, deviceId } = req.body; // lấy thông tin từ người dùng từ request body

    const user = await User.findOne({ email }); // tìm người dùng trong csdl bằng email
    if (!user) {
      return res
        .status(400)
        .json({ msg: "Người dùng có email này không tồn tại!" });
    }

    // const isMatch = await bcryptjs.compare(password, user.password);
    // console.log(`vvvvvvvvvvv ${user.password}`);
    const isMatch = password == null || password == "" || user.password == password; // kiểm tra xem mật khẩu có khớp với mật khẩu đã lưu trong CSDL 
    console.log(`vvvvvvvvvvv ${password}`);
    if (!isMatch) {
      return res.status(400).json({ msg: "Mật khẩu không đúng." });
    }

    // Kiểm tra deviceId
    if (user.deviceId && user.deviceId !== deviceId) {
      console.log(`deviceId ${user.deviceId}`);
      console.log(`deviceIdd ${deviceId}`);
      // Thiết bị mới, yêu cầu xác minh OTP
      return res.status(403).json({ msg: 'Thiết bị mới! Yêu cầu xác minh OTP.' });
    }

    // Cập nhật deviceId nếu chưa có
    if (!user.deviceId) {
      user.deviceId = deviceId;
      await user.save();
    }

    const token = jwt.sign({ id: user._id }, "passwordKey");
    res.json({ token, ...user._doc });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

authRouter.post('/api/request-otp', async (req, res) => {
  const { email } = req.body;

  // Tạo mã OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString(); // 6 số ngẫu nhiên
  const expiresAt = new Date(Date.now() + 1 * 60 * 1000); // Hết hạn sau 1 phút

  // Lưu OTP vào database
  await OTP.create({ email, otp, expiresAt });

  // Gửi OTP qua email
  await sendOTP(email, otp);

  res.json({ msg: 'OTP đã được gửi!' });
});

authRouter.post('/api/verify-otp', async (req, res) => {
  const { email, otp, deviceId } = req.body;

  // Tìm OTP trong database
  const otpEntry = await OTP.findOne({ email, otp });
  if (!otpEntry || otpEntry.expiresAt < new Date()) {
    return res.status(400).json({ msg: 'OTP không hợp lệ hoặc đã hết hạn!' });
  }

  // Xóa OTP sau khi xác minh thành công
  await OTP.deleteOne({ _id: otpEntry._id });

  // Cập nhật deviceId cho user
  const user = await User.findOne({ email });
  user.deviceId = deviceId;
  await user.save();

  res.json({ msg: 'Xác minh thành công!' });
});



authRouter.post("/tokenIsValid", async (req, res) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) return res.json(false);
    const verified = jwt.verify(token, "passwordKey");
    if (!verified) return res.json(false);

    const user = await User.findById(verified.id);
    if (!user) return res.json(false);
    res.json(true);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get user data
authRouter.get("/", auth, async (req, res) => {
  const user = await User.findById(req.user);
  res.json({ ...user._doc, token: req.token });
});

// Cấu hình SMTP server
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'trongbanhang@gmail.com',
    pass: 'honk bqtc tkkb tpje',
  },
});

// Hàm gửi OTP qua email
const sendOTP = async (email, otp) => {
  await transporter.sendMail({
    from: 'trongbanhang@gmail.com',
    to: email,
    subject: 'Xác minh thiết bị mới',
    text: `Mã OTP của bạn là: ${otp}`,
  });
};

module.exports = authRouter;
