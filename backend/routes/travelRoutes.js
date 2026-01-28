import express from "express";
import { getBuses } from "../services/busService.js";
import { getTrains } from "../services/trainService.js";
import { getFlights } from "../services/amadeusService.js";

// ✅ Map of Dhams → their nearest airports
const dhamAirportMap = {
  "Badrinath": "DED", // Dehradun (Jolly Grant Airport)
  "Kedarnath": "DED",
  "Gangotri": "DED",
  "Yamunotri": "DED",
  "Dwarka": "JGA", // Jamnagar Airport
  "Puri": "BBI",   // Bhubaneswar Airport
  "Rameswaram": "TRZ", // Tiruchirapalli Airport
};

const router = express.Router();

// ✅ Fetch flights (with dham mapping)

router.get("/flights", async (req, res) => {
  try {
    console.log("Flights route hit ✅", req.query);

    // Accept both 'origin/destination' (from Flutter) and 'from/to'
    let from = req.query.from || req.query.origin;
    let to = req.query.to || req.query.destination;
    let date = req.query.date;

    if (!from || !to || !date) {
      console.log("❌ Missing required fields:", { from, to, date });
      return res
        .status(400)
        .json({ success: false, message: "Missing required fields" });
    }

    // 🛫 If 'to' is a dham name, map it to its nearest airport
    if (dhamAirportMap[to]) {
      console.log(`Mapping dham "${to}" to nearest airport: ${dhamAirportMap[to]}`);
      to = dhamAirportMap[to];
    }

    const flights = await getFlights(from, to, date);
    console.log("✅ Flights fetched:", flights?.length || 0, "results");
    res.json(flights);
  } catch (err) {
    console.error("Flights route error:", err.message);
    res
      .status(500)
      .json({
        success: false,
        message: "Error fetching flights",
        error: err.message,
      });
  }
});


// ✅ Fetch trains
router.get("/trains", async (req, res) => {
  try {
    const { from, to, date } = req.query;
    if (!from || !to || !date)
      return res.status(400).json({ success: false, message: "Missing required fields" });

    const dhamTrains = {
      "Badrinath": [
        { name: "Dehradun Express", trainNo: "12001", price: 650 },
        { name: "Uttarakhand Sampark Kranti", trainNo: "15035", price: 780 },
      ],
      "Kedarnath": [
        { name: "Kedarnath Special", trainNo: "15045", price: 720 },
        { name: "Haridwar Express", trainNo: "14042", price: 600 },
      ],
      "Gangotri": [
        { name: "Yamuna Express", trainNo: "14510", price: 640 },
        { name: "Himalaya Mail", trainNo: "14232", price: 700 },
      ],
      "Yamunotri": [
        { name: "Shatabdi to Dehradun", trainNo: "12017", price: 800 },
        { name: "Mussoorie Express", trainNo: "14041", price: 580 },
      ],
      "Dwarka": [
        { name: "Dwarka Express", trainNo: "15636", price: 900 },
        { name: "Jamnagar Superfast", trainNo: "22906", price: 1050 },
      ],
      "Puri": [
        { name: "Puri Express", trainNo: "18410", price: 980 },
        { name: "Bhubaneswar SF", trainNo: "22820", price: 890 },
      ],
      "Rameswaram": [
        { name: "Rameswaram Express", trainNo: "16779", price: 1150 },
        { name: "Madurai Passenger", trainNo: "56725", price: 760 },
      ],
    };

    const trains = dhamTrains[to] || [
      { name: "Bharat Express", trainNo: "10001", price: 700 },
    ];

    res.json(
      trains.map((t) => ({
        ...t,
        from,
        to,
        date,
        link: "https://www.irctc.co.in/",
      }))
    );
  } catch (err) {
    console.error("Trains route error:", err.message);
    res.status(500).json({ success: false, message: "Error fetching trains", error: err.message });
  }
});

//fetch buses
router.get("/buses", async (req, res) => {
  try {
    const { from, to, date } = req.query;
    if (!from || !to || !date)
      return res.status(400).json({ success: false, message: "Missing required fields" });

    const dhamBuses = {
      "Badrinath": [
        { operator: "Uttarakhand Travels", busNo: "UK01-EXP", price: 550 },
        { operator: "Himalaya Deluxe", busNo: "UK02-AC", price: 750 },
      ],
      "Dwarka": [
        { operator: "Saurashtra Express", busNo: "GJ01-DWK", price: 980 },
        { operator: "Jamnagar Luxury", busNo: "GJ03-JAM", price: 1200 },
      ],
      "Puri": [
        { operator: "Odisha Travels", busNo: "OD01-PUR", price: 700 },
        { operator: "SeaCoast Express", busNo: "OD02-LUX", price: 950 },
      ],
      "Rameswaram": [
        { operator: "TNSTC", busNo: "TN63-RMM", price: 850 },
        { operator: "SouthLine Travels", busNo: "TN60-DELUXE", price: 1100 },
      ],
    };

    const buses = dhamBuses[to] || [
      { operator: "Bharat Express", busNo: "DLX001", price: 700 },
    ];

    res.json(
      buses.map((b) => ({
        ...b,
        from,
        to,
        date,
        link: "https://www.redbus.in/",
      }))
    );
  } catch (err) {
    console.error("Buses route error:", err.message);
    res.status(500).json({ success: false, message: "Error fetching buses", error: err.message });
  }
});

export default router;
