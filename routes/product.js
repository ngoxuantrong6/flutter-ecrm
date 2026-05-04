const express = require("express");
const productRouter = express.Router();
const auth = require("../middlewares/auth");
const { Product } = require("../models/product");
const { User } = require("../models/user");

productRouter.get("/api/product/:id", auth, async (req, res) => {
  try {
    const id = req.params.id;
    const product = await Product.findById(id);
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

productRouter.get("/api/products/", auth, async (req, res) => {
  try {
    const { category, branchId } = req.query;
    // Tạo điều kiện truy vấn ban đầu
    let query = {};

    // Thêm điều kiện truy vấn theo category nếu có
    if (category) {
      query.category = category;
    }

    // Thêm điều kiện truy vấn theo branchId nếu có
    if (branchId) {
      query.branchId = branchId;
    }

    // Tìm sản phẩm theo điều kiện đã tạo
    const products = await Product.find(query);
    res.json(products);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


// productRouter.get("/api/products/", auth, async (req, res) => {
//   try {
//     const products = await Product.find({ category: req.query.category });
//     res.json(products);
//   } catch (e) {
//     res.status(500).json({ error: e.message });
//   }
// });

// create a get request to search products and get them
// /api/products/search/i
productRouter.get("/api/products/search/:name", auth, async (req, res) => {
  try {
    const products = await Product.find({
      name: { $regex: req.params.name, $options: "i" },
    });

    res.json(products);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// create a post request route to rate the product.
productRouter.post("/api/rate-product", auth, async (req, res) => {
  try {
    const { id, rating } = req.body;
    let product = await Product.findById(id);

    for (let i = 0; i < product.ratings.length; i++) {
      if (product.ratings[i].userId == req.user) {
        product.ratings.splice(i, 1);
        break;
      }
    }

    const ratingSchema = {
      userId: req.user,
      rating,
    };

    product.ratings.push(ratingSchema);
    product = await product.save();
    res.json(product);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

productRouter.get("/api/deal-of-day", auth, async (req, res) => {
  try {
    let products = await Product.find({});

    products = products.sort((a, b) => {
      let aSum = 0;
      let bSum = 0;

      for (let i = 0; i < a.ratings.length; i++) {
        aSum += a.ratings[i].rating;
      }

      for (let i = 0; i < b.ratings.length; i++) {
        bSum += b.ratings[i].rating;
      }
      return aSum < bSum ? 1 : -1;
    });

    res.json(products[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


// Route để lấy danh sách các chi nhánh
productRouter.get("/api/branches", auth, async (req, res) => {
  try {
    const branches = await User.find({ type: "branch" }); // Truy vấn lấy tất cả các chi nhánh
    res.json(branches); // Trả về danh sách chi nhánh dưới dạng JSON
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// GET /api/users/:id - Lấy user theo ID
productRouter.get("/api/users/:id", async (req, res) => {
  try {
      const userId = req.params.id;
      const user = await User.findById(userId);

      if (!user) {
          return res.status(404).json({ message: "User not found" });
      }
      res.json(user);
  } catch (error) {
      console.error("Error fetching user:", error);
      res.status(500).json({ error: error.message });
  }
});

module.exports = productRouter;