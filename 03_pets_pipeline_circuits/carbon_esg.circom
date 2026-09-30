pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template ESGInsuranceOracle() {
    // === 1. 公開輸入 (Public Inputs) ===
    signal input attestationCommitment; 
    signal input emissionThreshold;     

    // === 2. 私密輸入 (Private Inputs) -  ===
    signal input companyHash_part1;     
    signal input companyHash_part2;     
    signal input reportingPeriod;       
    signal input organizationalBoundary;
    signal input emissionFactorVersion; 
    signal input scope1Emission;
    signal input scope2Emission;
    signal input scope3Emission;
    signal input eligibleReduction;     

    signal output isCompliant;

    // === 3. 重組 Company Hash (解決 253-bit 上限) ===
    signal companyHash;
    companyHash <== companyHash_part1 * (2 ** 128) + companyHash_part2;

    // === 4. Poseidon ===
    component hasher = Poseidon(9);
    
    hasher.inputs[0] <== companyHash;
    hasher.inputs[1] <== reportingPeriod;
    hasher.inputs[2] <== organizationalBoundary;
    hasher.inputs[3] <== emissionFactorVersion;
    hasher.inputs[4] <== scope1Emission;
    hasher.inputs[5] <== scope2Emission;
    hasher.inputs[6] <== scope3Emission;
    hasher.inputs[7] <== eligibleReduction;
    hasher.inputs[8] <== emissionThreshold; 

    // 電路算出的雜湊，必須與預言機簽章完全一致
    hasher.out === attestationCommitment;

    // === 5. ZK 內部防偽計算：自動計算淨碳排 ===
    signal totalNetEmissions;
    totalNetEmissions <== scope1Emission + scope2Emission + scope3Emission - eligibleReduction;

    // === 6. 保險理賠門檻判定 ===
    component lessEq = LessEqThan(252);  
    lessEq.in[0] <== totalNetEmissions;
    lessEq.in[1] <== emissionThreshold;

    isCompliant <== lessEq.out;
    isCompliant === 1; 
}

component main {public [attestationCommitment, emissionThreshold]} = ESGInsuranceOracle();