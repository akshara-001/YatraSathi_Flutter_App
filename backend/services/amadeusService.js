import axios from "axios";
import dotenv from "dotenv";
dotenv.config();
console.log("Amadeus Key:", process.env.AMADEUS_CLIENT_ID);
console.log("Amadeus Secret:", process.env.AMADEUS_CLIENT_SECRET);
const { AMADEUS_CLIENT_ID, AMADEUS_CLIENT_SECRET } = process.env;

let accessToken = null;
let tokenExpiry = null;

// 🟢 Get a new token (cached until expired)
export async function getAmadeusToken() {
  console.log("🔐 Requesting new Amadeus access token...");
  const response = await axios.post(
    "https://test.api.amadeus.com/v1/security/oauth2/token",
    new URLSearchParams({
      grant_type: "client_credentials",
      client_id: AMADEUS_CLIENT_ID,
      client_secret: AMADEUS_CLIENT_SECRET,
    }),
    { headers: { "Content-Type": "application/x-www-form-urlencoded" } }
  );

  accessToken = response.data.access_token;
  tokenExpiry = Date.now() + response.data.expires_in * 1000;
  console.log("✅ Amadeus token received.");
  return accessToken;
}

// ✈️ Get flights safely
export async function getFlights(from, to, date) {
  try {
    if (!accessToken || Date.now() > tokenExpiry) {
      await getAmadeusToken();
    }

    console.log(`🛫 Fetching flights: ${from} → ${to} (${date})`);

    const url = `https://test.api.amadeus.com/v2/shopping/flight-offers?originLocationCode=${from}&destinationLocationCode=${to}&departureDate=${date}&adults=1&currencyCode=INR&max=5`;

    const response = await axios.get(url, {
      headers: { Authorization: `Bearer ${accessToken}` },
      timeout: 15000, // 15s timeout
    });

    console.log("✅ Amadeus API success, flights:", response.data.data?.length || 0);

    return (response.data.data || []).map((f) => ({
      airline: f.validatingAirlineCodes?.[0] || "Unknown Airline",
      price: f.price?.total || "N/A",
      departure:
        f.itineraries?.[0]?.segments?.[0]?.departure?.at || "Unknown",
      arrival:
        f.itineraries?.[0]?.segments?.slice(-1)[0]?.arrival?.at || "Unknown",
      link: "https://www.makemytrip.com/flights/",
    }));
  } catch (error) {
    if (error.response) {
      console.error("🔥 Amadeus API error:", error.response.status, error.response.data);
    } else if (error.request) {
      console.error("🌐 Network error: No response from Amadeus API");
    } else {
      console.error("❌ Unknown error:", error.message);
    }
    throw new Error("Failed to fetch flights");
  }
}
