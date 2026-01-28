// galleryRoutes.js
import express from "express";
import multer from "multer";
import path from "path";
import Gallery from "../models/galleryModel.js";

const router = express.Router();

// Multer setup
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads/");
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage });

// ✅ POST /api/gallery/upload
router.post("/upload", upload.single("image"), async (req, res) => {
  try {
    const { username, caption, dham } = req.body;
    const fileName = req.file.filename.replace(/\\/g, "/");
    const imageUrl = `http://10.42.0.24:5000/uploads/${fileName}`;


    const newPhoto = new Gallery({
      username,
      caption,
      dham,
      imageUrl,
      likes: [],
    });

    await newPhoto.save();

    res.status(201).json({ message: "Uploaded", photo: newPhoto });
  } catch (error) {
    console.error("Upload error:", error);
    res.status(500).json({ error: "Upload failed" });
  }
});

// ✅ GET /api/gallery/:dhamName
router.get("/:dhamName", async (req, res) => {
  try {
    const photos = await Gallery.find({ dham: req.params.dhamName });
    res.json(photos);
  } catch (error) {
    res.status(500).json({ error: "Error fetching gallery" });
  }
});
// ✅ PUT /api/gallery/:id/like
router.put("/:id/like", async (req, res) => {
  try {
    const { username } = req.body;
    const photo = await Gallery.findById(req.params.id);

    if (!photo) {
      return res.status(404).json({ message: "Photo not found" });
    }

    // Toggle like
    if (photo.likes.includes(username)) {
      photo.likes = photo.likes.filter((user) => user !== username);
    } else {
      photo.likes.push(username);
    }

    await photo.save();
    res.status(200).json(photo);
  } catch (error) {
    console.error("Like error:", error);
    res.status(500).json({ error: "Error toggling like" });
  }
});

export default router;
