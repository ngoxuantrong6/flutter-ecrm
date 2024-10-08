const express = require("express");
const sellerRouter = express.Router();
const seller = require("../middlewares/seller");
const { Product } = require("../models/product");
const Order = require("../models/order");

// Add product
sellerRouter.post("/seller/add-product", seller, async (req, res) => {
  try {
    const { name, description, images, quantity, price, category } = req.body;
    let product = new Product({
      name,
      description,
      images,
      quantity,
      price,
      category,
      userId: req.user, // Gán userId của seller để biết sản phẩm thuộc về ai
    });
    product = await product.save();
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Edit product
sellerRouter.patch("/seller/edit-product/:id", seller, async (req, res) => {
  try {
    const id = req.params.id;
    let product = await Product.findOneAndUpdate(
      { _id: id, userId: req.user }, // Chỉ cho phép chỉnh sửa sản phẩm của chính mình
      req.body,
      { new: true }
    );
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get all your products
sellerRouter.get("/seller/get-products", seller, async (req, res) => {
  try {
    const products = await Product.find({ userId: req.user }); // Chỉ lấy sản phẩm của seller hiện tại
    res.json(products);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get detail of your product
sellerRouter.get("/seller/get-product/:id", seller, async (req, res) => {
  try {
    const id = req.params.id;
    const product = await Product.findOne({ _id: id, userId: req.user }); // Chỉ lấy sản phẩm thuộc seller hiện tại
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Delete the product
sellerRouter.post("/seller/delete-product", seller, async (req, res) => {
  try {
    const { id } = req.body;
    let product = await Product.findOneAndDelete({ _id: id, userId: req.user }); // Chỉ xóa sản phẩm của seller hiện tại
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get orders for your products
sellerRouter.get("/seller/get-orders", seller, async (req, res) => {
  try {
    const orders = await Order.find({ "products.product.userId": req.user });
    res.json(orders);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get order detail
sellerRouter.post("/seller/get-order-detail", seller, async (req, res) => {
  try {
    const { id } = req.body;
    const order = await Order.findById(id);
    res.json(order);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Change order status
sellerRouter.post("/seller/change-order-status", seller, async (req, res) => {
  try {
    const { id, status } = req.body;
    let order = await Order.findById(id);
    order.status = status;
    order = await order.save();
    res.json(order);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Analytics (This may need to be restricted per seller)
sellerRouter.get("/seller/analytics", seller, async (req, res) => {
  try {
    const orders = await Order.find({ "products.product.userId": req.user });
    let totalEarnings = 0;

    for (let i = 0; i < orders.length; i++) {
      for (let j = 0; j < orders[i].products.length; j++) {
        if (orders[i].products[j].product.userId.toString() === req.user.toString()) {
          totalEarnings +=
            orders[i].products[j].quantity * orders[i].products[j].product.price;
        }
      }
    }

    let earnings = {
      totalEarnings,
    };

    res.json(earnings);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = sellerRouter;
