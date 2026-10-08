import "dotenv/config";
import express from "express";
import http from "http";
import cors from "cors";
import status from "http-status";
import AuthRoutes from "./src/features/auth/auth.route";

const PORT = process.env.PORT || 3333;

const app = express();
const server = http.createServer(app);

app.use(express.json());
app.use(cors());

app.get("/", (req, res) => {
  res.status(status.OK).json({ message: "OK" });
});

app.use("/api/v1", AuthRoutes);

server.listen(PORT, () => {
  console.log(`Server is running at PORT ${PORT}`);
});
