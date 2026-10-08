import "dotenv/config";
import express from "express";
import http from "http";
import cors from "cors";
import status from "http-status";
import cookieParser from "cookie-parser";
import AuthRoutes from "./src/features/auth/auth.route";
import BillsRoutes from "./src/features/bills/bills.route";
import DocsRoutes from "./src/docs/docs.route";

const PORT = process.env.PORT || 3333;

const app = express();
const server = http.createServer(app);

app.use(express.json());
app.use(cookieParser());
app.use(
  cors({
    origin: true,
    credentials: true,
  }),
);

app.get("/", (req, res) => {
  res.status(status.OK).json({ message: "OK" });
});

app.use("/api/v1/auth", AuthRoutes);
app.use("/api/v1/bills", BillsRoutes);
app.use("/docs", DocsRoutes);

server.listen(PORT, () => {
  console.log(`Server is running at PORT ${PORT}`);
});
