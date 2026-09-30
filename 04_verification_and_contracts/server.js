const express = require('express');
const cors = require('cors');
const fs = require('fs');
const app = express();

app.use(cors());

// 前端呼叫這個 API，只會拿到加密後的密碼學憑證，完全看不到明文碳排
app.get('/api/latest-payload', (req, res) => {
    try {
        // 讀取你在 circuits 資料夾算好的最新 ZK Proof
        const proof = JSON.parse(fs.readFileSync('../circuits/proof.json', 'utf8'));
        const publicSignals = JSON.parse(fs.readFileSync('../circuits/public.json', 'utf8'));
        
        const oracleData = {
            signature: "0x4294164e56aea88c2bbb602f4a76086fce0ee5c69db2689a5f2de117462ee29022af21320b806cbdb1a51afe8381d4cd4ebd9e13cf50d7fe8ab7df4616ad74b51b",
            timestamp: 1789881034,
            companyHash: "0x0000000000000000000000000000000000000000000000000000000094025264"
        };

        res.json({ success: true, proof, publicSignals, oracleData });
    } catch (error) {
        res.status(500).json({ success: false, error: "憑證讀取失敗，請確認檔案路徑是否正確" });
    }
});

app.listen(3000, '0.0.0.0', () => console.log('API Server running'));