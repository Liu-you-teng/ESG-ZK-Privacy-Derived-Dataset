const { buildPoseidon } = require("circomlibjs");
const fs = require("fs");
const path = require("path");

async function main() {
    const poseidon = await buildPoseidon();

    // 1. 完全照搬 Oracle (sample-attestation.json) 的真實機密數據
    const companyHashStr = "0x0000000000000000000000000000000000000000000000000000000094025264";
    const companyHashBigInt = BigInt(companyHashStr);
    
    // 進行 128-bit 切割
    const part2 = companyHashBigInt & ((1n << 128n) - 1n);
    const part1 = companyHashBigInt >> 128n;

    // 完美對應你提供的最新 JSON 數值
    const reportingPeriod = 2024;
    const organizationalBoundary = 1;
    const emissionFactorVersion = 2024;
    const scope1Emission = 106527;
    const scope2Emission = 42401;
    const scope3Emission = 0;
    const eligibleReduction = 10000;
    const emissionThreshold = 1000000; // 對應 JSON 裡的 insuranceThreshold

    // 2. 計算 Poseidon 雜湊承諾 (確保 9 個參數順序與 .circom 電路完全一致)
    const hash = poseidon([
        companyHashBigInt, 
        reportingPeriod, 
        organizationalBoundary, 
        emissionFactorVersion,
        scope1Emission, 
        scope2Emission, 
        scope3Emission, 
        eligibleReduction, 
        emissionThreshold
    ]);
    const commitment = poseidon.F.toString(hash);

    // 3. 輸出 ZK 電路需要的 input.json 
    // (左邊的 key 必須對應 carbon_esg.circom 裡的 signal input 名稱)
    const inputData = {
        attestationCommitment: commitment,
        emissionThreshold: emissionThreshold.toString(),
        companyHash_part1: part1.toString(),
        companyHash_part2: part2.toString(),
        reportingPeriod: reportingPeriod.toString(),
        organizationalBoundary: organizationalBoundary.toString(),
        emissionFactorVersion: emissionFactorVersion.toString(),
        scope1Emission: scope1Emission.toString(),
        scope2Emission: scope2Emission.toString(),
        scope3Emission: scope3Emission.toString(),
        eligibleReduction: eligibleReduction.toString()
    };

    fs.writeFileSync(path.join(__dirname, "input.json"), JSON.stringify(inputData, null, 2));
    console.log("=== 9 欄位標準產生成功 ===");
    console.log("ZKP 算出來的 Commitment:", commitment);
}

main();