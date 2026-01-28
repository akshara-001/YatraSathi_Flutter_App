  import mongoose from "mongoose";

const gallerySchema = new mongoose.Schema({
  username: String,
  caption: String,
  dham: String,
  imageUrl: String,
  likes: { type: [String], default: [] },
});

export default mongoose.model("Gallery", gallerySchema);