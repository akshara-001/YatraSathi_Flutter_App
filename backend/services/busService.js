import axios from "axios";
import { getCache, setCache } from "./cacheManager.js";


export const getBuses = async (from, to, date) => {
  const cacheKey = `bus_${from}_${to}_${date}`;
  const cached = await getCache(cacheKey);
  if (cached) return cached;

  try {
    const res = await axios.get("https://api.instantwebtools.net/v1/buses");
    const buses = res.data.slice(0, 5).map(b => ({
      name: b.name || "Express Bus",
      from,
      to,
      date,
      link: "https://www.redbus.in/"
    }));
    await setCache(cacheKey, buses);
    return buses;
  } catch (err) {
    console.error("Bus error:", err.message);
    return [];
  }
};
