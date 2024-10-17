const express = require("express");
const branchRouter = express.Router();
const branch = require("../middlewares/branch");
const { Product } = require("../models/product");
const Order = require("../models/order");

// Add product
branchRouter.post("/branch/add-product", branch, async (req, res) => {
  try {
    const { name, description, images, quantity, price, category } = req.body;
    let product = new Product({
      name,
      description,
      images,
      quantity,
      price,
      category,
      branchId: req.user, // Gán userId của branch để biết sản phẩm thuộc về ai
    });
    product = await product.save();
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Edit product
branchRouter.patch("/branch/edit-product/:id", branch, async (req, res) => {
  try {
    const id = req.params.id;
    let product = await Product.findOneAndUpdate(
      { _id: id, branchId: req.user }, // Chỉ cho phép chỉnh sửa sản phẩm của chính mình
      req.body,
      { new: true }
    );
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get all your products
branchRouter.get("/branch/get-products", branch, async (req, res) => {
  try {
    const products = await Product.find({ branchId: req.user }); // Chỉ lấy sản phẩm của branch hiện tại
    res.json(products);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get detail of your product
branchRouter.get("/branch/get-product/:id", branch, async (req, res) => {
  try {
    const id = req.params.id;
    const product = await Product.findOne({ _id: id, branchId: req.user }); // Chỉ lấy sản phẩm thuộc branch hiện tại
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Delete the product
branchRouter.post("/branch/delete-product", branch, async (req, res) => {
  try {
    const { id } = req.body;
    let product = await Product.findOneAndDelete({ _id: id, branchId: req.user }); // Chỉ xóa sản phẩm của branch hiện tại
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get orders for your products
branchRouter.get("/branch/get-orders", branch, async (req, res) => {
  try {
    const orders = await Order.find({ "products.product.branchId": req.user });
    res.json(orders);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get order detail
branchRouter.post("/branch/get-order-detail", branch, async (req, res) => {
  try {
    const { id } = req.body;
    const order = await Order.findById(id);
    res.json(order);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Change order status
branchRouter.post("/branch/change-order-status", branch, async (req, res) => {
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

// Analytics (This may need to be restricted per branch)
branchRouter.get("/branch/analytics", branch, async (req, res) => {
  try {
    const orders = await Order.find({ "products.product.branchId": req.user });
    let totalEarnings = 0;
  
    for (let i = 0; i < orders.length; i++) {
      for (let j = 0; j < orders[i].products.length; j++) {
        totalEarnings +=
          orders[i].products[j].quantity * orders[i].products[j].product.price;
      }
    }
    // CATEGORY WISE ORDER FETCHING
    let mobileEarnings = await fetchCategoryWiseProduct("Điện thoại", req.user);
    let essentialEarnings = await fetchCategoryWiseProduct("Đồ thiết yếu", req.user);
    let applianceEarnings = await fetchCategoryWiseProduct("Đồ gia dụng", req.user);
    let booksEarnings = await fetchCategoryWiseProduct("Sách", req.user);
    let fashionEarnings = await fetchCategoryWiseProduct("Thời trang", req.user);
  
    let earnings = {
      totalEarnings,
      mobileEarnings,
      essentialEarnings,
      applianceEarnings,
      booksEarnings,
      fashionEarnings,
    };
  
    res.json(earnings);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

async function fetchCategoryWiseProduct(category, branchId) {
  let earnings = 0;
  let categoryOrders = await Order.find({
    "products.product.category": category,
    "products.product.branchId": branchId
  });

  for (let i = 0; i < categoryOrders.length; i++) {
    for (let j = 0; j < categoryOrders[i].products.length; j++) {
      if (categoryOrders[i].products[j].product.category == category) {
        earnings +=
          categoryOrders[i].products[j].quantity *
          categoryOrders[i].products[j].product.price;
      }
    }
  }
  return earnings;
}

module.exports = branchRouter;
