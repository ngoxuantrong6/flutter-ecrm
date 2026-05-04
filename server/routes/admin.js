const express = require("express");
const adminRouter = express.Router();
const admin = require("../middlewares/admin");
const { Product } = require("../models/product");
const Order = require("../models/order");
const { PromiseProvider } = require("mongoose");
const bcryptjs = require('bcryptjs');
const { User } = require("../models/user");

// Add product
adminRouter.post("/admin/add-product", admin, async (req, res) => {
  try {
    const { name, description, images, quantity, price, category, branchId } = req.body;
    let product = new Product({
      name,
      description,
      images,
      quantity,
      price,
      category,
      branchId,
    });
    product = await product.save();
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Edit product
adminRouter.patch("/admin/edit-product/:id", admin, async (req, res) => {
  try {
    const id = req.params.id;
    let product = await Product.findByIdAndUpdate(
      id,
      req.body,
      { new: true } // Return products after updating
    );
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get all your products
// adminRouter.get("/admin/get-products", admin, async (req, res) => {
//   try {
//     const products = await Product.find({});
//     res.json(products);
//   } catch (e) {
//     res.status(500).json({ error: e.message });
//   }
// });
adminRouter.get("/admin/get-products/", admin, async (req, res) => {
  try {
    const { branchId } = req.query;
    let query = {};
    if (branchId) {
      query.branchId = branchId;
    }
    const products = await Product.find(query);
    res.json(products);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get detail your product
adminRouter.get("/admin/get-product/:id", admin, async (req, res) => {
  try {
    const id = req.params.id;
    const product = await Product.findById(id);
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Delete the product
adminRouter.post("/admin/delete-product", admin, async (req, res) => {
  try {
    const { id } = req.body;
    let product = await Product.findByIdAndDelete(id);
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

adminRouter.get("/admin/get-orders", admin, async (req, res) => {
  try {
    const { branchId } = req.query;
    let query = {};
    if (branchId) {
      query.branchId = branchId;
    }
    const orders = await Order.find(query);
    res.json(orders);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

adminRouter.post("/admin/get-order-detail", admin, async (req, res) => {
  try {
    const { id } = req.body;
    const order = await Order.findById(id);
    res.json(order);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

adminRouter.post("/admin/change-order-status", admin, async (req, res) => {
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

adminRouter.get("/admin/analytics/", admin, async (req, res) => {
  try {
    const { branchId } = req.query;
    let query = {};
    if (branchId) {
      query.branchId = branchId;
    }
    const orders = await Order.find(query);
    let totalEarnings = 0;

    for (let i = 0; i < orders.length; i++) {
      for (let j = 0; j < orders[i].products.length; j++) {
        if (orders[i].products[j].product) {
          totalEarnings +=
            orders[i].products[j].quantity * orders[i].products[j].product.price;
        }
      }
    }
    // CATEGORY WISE ORDER FETCHING
    let mobileEarnings = await fetchCategoryWiseProduct("Điện thoại", branchId);
    let essentialEarnings = await fetchCategoryWiseProduct("Đồ thiết yếu", branchId);
    let applianceEarnings = await fetchCategoryWiseProduct("Đồ gia dụng", branchId);
    let booksEarnings = await fetchCategoryWiseProduct("Sách", branchId);
    let fashionEarnings = await fetchCategoryWiseProduct("Thời trang", branchId);

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
  let categoryOrders = Order.find();
  if (branchId !== "") {
    categoryOrders = await Order.find({
      "products.product.category": category,
      "products.product.branchId": branchId
    });
  } else {
    categoryOrders = await Order.find({
      "products.product.category": category,
    });
  }

  for (let i = 0; i < categoryOrders.length; i++) {
    for (let j = 0; j < categoryOrders[i].products.length; j++) {
      if (
        categoryOrders[i].products[j].product &&
        categoryOrders[i].products[j].product.category == category
      ) {
        earnings +=
          categoryOrders[i].products[j].quantity *
          categoryOrders[i].products[j].product.price;
      }
    }
  }
  return earnings;
}

// MANAGE BRANCH

// Add branch
adminRouter.post("/admin/add-branch", admin, async (req, res) => {
  try {
    const { branchName, address, email, password } = req.body;

    // Kiểm tra xem email đã được sử dụng chưa
    const existingBranch = await User.findOne({ email });
    if (existingBranch) {
      return res.status(400).json({ error: "Người dùng có cùng email đã tồn tại!" });
    }

    // Mã hóa mật khẩu
    const hashedPassword = await bcryptjs.hash(password, 8);

    let user = new User({
      name: branchName,
      email,
      password: hashedPassword,
      address,
      type: "branch"
    });

    user = await user.save();
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Edit branch
adminRouter.patch("/admin/edit-branch/:id", admin, async (req, res) => {
  try {
    const id = req.params.id;
    let user = await User.findByIdAndUpdate(
      id,
      req.body,
      { new: true },
    );
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get all branches
adminRouter.get("/admin/get-branches", admin, async (req, res) => {
  try {
    const branches = await User.find({ type: "branch" });
    res.json(branches);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get detail branch
adminRouter.get("/admin/get-branch/:id", admin, async (req, res) => {
  try {
    const id = req.params.id;
    const branch = await User.findById(id);
    res.json(branch);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Delete the branch
adminRouter.post("/admin/delete-branch", admin, async (req, res) => {
  try {
    const { id } = req.body;
    let branch = await User.findByIdAndDelete(id);
    res.json(branch);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = adminRouter;
