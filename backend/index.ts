import "dotenv/config"
import express from "express"
import http from "http"

const PORT = process.env.PORT || 3333;

const app = express();
const server = http.createServer(app);

server.listen(PORT, ()=>{
    console.log(`Server is running at PORT ${PORT}`);
})