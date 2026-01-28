import axios from "axios";
import { getCache, setCache } from "./cacheManager.js";

export const getTrains = async (from, to, date) => {
  const cacheKey = `train_${from}_${to}_${date}`;
  const cached = await getCache(cacheKey);
  if (cached) return cached;

  try {
    const res = await axios.get("https://api.instantwebtools.net/v1/trains");
    const trains = res.data.slice(0, 5).map(t => ({
      name: t.name || "Express Train",
      number: t.number || "00000",
      from,
      to,
      date,
      link: "https://www.irctc.co.in/nget/train-search"
    }));
    await setCache(cacheKey, trains);
    return trains;
  } catch (err) {
    console.error("Train error:", err.message);
    return [];
  }
};
