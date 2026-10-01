ESG-ZK-Privacy-Derived-Dataset

ESG 零知識參數型碳保險驗證平台 (ESG-ZK) 之 PETs 隱私強化衍生資料集與驗證系統。基於環境部 GHG_P_01 開放資料，結合 Poseidon Commitment、Groth16 ZKP 與 EIP-712 預言機簽章，實現零明文暴露與 Base Sepolia 鏈上自動理賠驗證。

📂 專案目錄與架構說明

📁 01_derived_dataset (核心衍生資料集)

本目錄包含經過 PETs（隱私強化技術）處理後的最終產出結果。我們在地端使用 HMAC-SHA256 隱匿企業統編防禦字典攻擊，並透過 Poseidon(9) 雜湊與 Groth16 零知識電路產生證明，確保明文維度完全隔離。

📄 esg_zk_derived_dataset.csv：提交給大會的主要衍生資料集。內含 1,115 筆實測數據，保留了核心治理特徵（如盤查年度、邊界），並將敏感碳排數據轉化為可驗證的 poseidon_attestation_commitment 與 zk_proof 訊號。

📄 sample_manifest.json：衍生資料的完整 JSON 結構檔，完整記錄了每一筆資料對應的 ZKP Proof 參數（pi_a, pi_b, pi_c）與公開訊號，供下游驗證腳本讀取。

📄 local_mapping_index.json：本機映射對照表（僅供內部評測使用）。用於記錄衍生 record_id 與原始明文的對應關係，以利執行自動化的 Decision Consistency（決策一致性）與再識別率攻擊測試。

📁 02_derived_payload_json (預言機簽章負載)

存放由 Oracle（預言機）產生的鏈上交互資料檔。

包含符合 EIP-712 結構化簽章標準 的 JSON Payload（如 sample-attestation.json）。負責將前端產出的 ZKP 與合規結果，加上權威機構的 ECDSA 私鑰簽章，供智能合約驗證來源合法性與防重放攻擊。

📁 03_pets_pipeline_circuits (零知識電路與評測管線)

存放核心密碼學電路檔案與測試腳本。

包含 Circom 零知識電路源碼 (.circom)、編譯後的 WebAssembly (.wasm) 以及驗證密鑰 (verification_key.json)。

內含終極實機評測腳本 (evaluate_pets_metrics.js)，負責嚴格對齊 Node.js 與 Circom 參數，並產出系統效能與 PETs 攻擊模型防禦報告。

📁 04_verification_and_contracts (鏈上驗證與智能合約)

存放部署於區塊鏈上的 Solidity 智能合約與驗證腳本。

包含 Groth16Verifier.sol (ZKP 數學驗證合約) 與 ESGInsuranceOracle.sol (業務邏輯與簽章校驗合約)。用於在 Base Sepolia 測試網上執行去中心化的最終理賠資格審查。
