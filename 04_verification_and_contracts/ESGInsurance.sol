// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGroth16Verifier {
    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[3] calldata _pubSignals 
    ) external view returns (bool);
}

contract ESGInsurance {
    address public oracleAddress;
    IGroth16Verifier public verifier;
    uint256 public payoutAmount = 10 ether;

    mapping(uint256 => bool) public claimedHashes;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 public constant ATTESTATION_TYPEHASH = keccak256("Attestation(bytes32 companyHash,uint256 attestationCommitment,uint256 timestamp)");
    bytes32 public DOMAIN_SEPARATOR;

    event ClaimProcessed(uint256 indexed oracleHash, address indexed recipient, uint256 amount);
    event ContractFunded(address indexed funder, uint256 amount);

    constructor(address _oracleAddress, address _verifierAddress) {
        oracleAddress = _oracleAddress;
        verifier = IGroth16Verifier(_verifierAddress);
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            DOMAIN_TYPEHASH,
            keccak256(bytes("ESG_ZK_Insurance_Oracle")),
            keccak256(bytes("1")),
            31337,
            address(0) 
        ));
    }

    receive() external payable {
        emit ContractFunded(msg.sender, msg.value);
    }

    function claimInsurance(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[3] calldata _pubSignals, 
        bytes32 _companyHash,     
        uint256 _oracleTimestamp, 
        uint8 v, bytes32 r, bytes32 s
    ) external {
        uint256 oracleHash = _pubSignals[1]; 
        require(!claimedHashes[oracleHash], "This claim has already been processed.");

        bytes32 structHash = keccak256(abi.encode(
            ATTESTATION_TYPEHASH,
            _companyHash,
            oracleHash,
            _oracleTimestamp
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            structHash
        ));

        address signer = ecrecover(digest, v, r, s);
        require(signer == oracleAddress, "Invalid Oracle Signature: Data not verified by third party.");

        bool isProofValid = verifier.verifyProof(_pA, _pB, _pC, _pubSignals);
        require(isProofValid, "Invalid ZK Proof: Emissions do not meet the criteria.");
        
        require(address(this).balance >= payoutAmount, "Insufficient contract balance.");
        claimedHashes[oracleHash] = true;

  
        (bool success, ) = payable(msg.sender).call{value: payoutAmount}("");
        require(success, "Transfer failed.");

        emit ClaimProcessed(oracleHash, msg.sender, payoutAmount);
    }
}