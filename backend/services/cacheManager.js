import Cache from "../models/Cache.js";

export async function getCache(key) {
  const cache = await Cache.findOne({ key });
  return cache ? cache.data : null;
}

export async function setCache(key, data) {
  await Cache.findOneAndUpdate(
    { key },
    { data, createdAt: new Date() },
    { upsert: true, new: true }
  );
}
