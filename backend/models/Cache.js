import mongoose from "mongoose";

const cacheSchema = new mongoose.Schema({
  key: { type: String, unique: true },
  data: { type: mongoose.Schema.Types.Mixed },
  createdAt: { type: Date, default: Date.now, expires: 1800 } // auto delete after 30 mins
});

export default mongoose.model("Cache", cacheSchema);
