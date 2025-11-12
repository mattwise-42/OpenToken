# Privacy-Preserving Record Linkage (PPRL) Demonstration

This demonstration shows how to use OpenToken for privacy-preserving record linkage between two organizations sharing patient data.

## Quick Start (TL;DR)

**Option 1: Run Everything at Once (with default demo secrets)**
```bash
cd demos/pprl-superhero-example/scripts
chmod +x run_complete_demo.sh
./run_complete_demo.sh
```

**Option 2: Run with Custom Secrets**
```bash
cd demos/pprl-superhero-example/scripts
chmod +x run_complete_demo.sh
./run_complete_demo.sh "YourHashingSecret" "Your-32-Character-Encryption-Key"
```

**Option 3: Step-by-Step**
```bash
# 1. Generate datasets
cd demos/pprl-superhero-example/scripts
python generate_superhero_datasets.py

# 2. Tokenize both datasets (simulates separate organizations)
chmod +x tokenize_datasets.sh
./tokenize_datasets.sh  # Uses default demo secrets
# OR with custom secrets:
# ./tokenize_datasets.sh "YourHashingSecret" "Your-32-Character-Encryption-Key"

# 3. Analyze overlap (decrypt and compare tokens)
python analyze_overlap.py  # Uses default encryption key
# OR with custom key:
# python analyze_overlap.py "Your-32-Character-Encryption-Key"
```

**Expected Result**: 40 matching patients found (40% of hospital dataset)

---

## Scenario

**Super Hero Hospital** and **Super Hero Pharmacy** want to link their patient records to improve care coordination, but they need to protect patient privacy. They use OpenToken to:

1. Generate encrypted tokens from patient identifiers (name, birthdate, SSN, etc.)
2. Share only the encrypted tokens (not raw patient data)
3. Find matching patients by comparing tokens

## Dataset Overview

- **Hospital Dataset**: 100 super hero patients with hospital-specific information
  - Columns: RecordId, FirstName, LastName, Sex, BirthDate, SocialSecurityNumber, PostalCode, Department, VisitReason
  
- **Pharmacy Dataset**: 120 super hero patients with pharmacy-specific information
  - Columns: RecordId, FirstName, LastName, Sex, BirthDate, SocialSecurityNumber, PostalCode, MedicationType, PrescriptionType
  
- **Expected Overlap**: 40 patients (40% of hospital dataset) appear in both datasets with identical person attributes

## How OpenToken Works

OpenToken generates 5 different tokens (T1-T5) for each patient using different combinations of attributes:

| Token ID | Token Components                                      |
|----------|------------------------------------------------------|
| T1       | `U(last-name)\|U(first-name-1)\|U(sex)\|birth-date`  |
| T2       | `U(last-name)\|U(first-name)\|birth-date\|postal-code-3` |
| T3       | `U(last-name)\|U(first-name)\|U(sex)\|birth-date`    |
| T4       | `social-security-number\|U(sex)\|birth-date`         |
| T5       | `U(last-name)\|U(first-name-3)\|U(sex)`              |

> **Note**: U(X) means uppercase(X), and attribute-N means taking the first N characters

Each token is:
1. Normalized (standardized format)
2. Hashed with HMAC-SHA256
3. Encrypted with AES-256-GCM (with random IV for security)

**For a match**: All 5 tokens must be identical between two records, meaning the underlying person attributes match exactly.

### Important Note About Token Comparison

OpenToken uses **AES-256-GCM encryption with random initialization vectors (IVs)** for enhanced security. This means:

- Each tokenization run produces different encrypted values, even for identical input data
- To compare tokens across independently tokenized datasets, **tokens must be decrypted first**
- Decryption reveals the underlying HMAC-SHA256 hash (not the original data)
- The HMAC-SHA256 hashes are deterministic and can be compared for matching

This demonstration shows how to properly compare tokens from two organizations that tokenized their data independently.

## Prerequisites

- Java 11 or higher
- Maven 3.6 or higher
- Python 3.7+ (for data generation and analysis)

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     DATA GENERATION                              │
│  Hospital (100)          40% Overlap          Pharmacy (120)    │
│  Super Heroes    ←────────────────────────→   Super Heroes      │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                    TOKENIZATION (Separate)                       │
│  Hospital uses OpenToken    │    Pharmacy uses OpenToken         │
│  + Shared Keys              │    + Shared Keys                   │
│  → hospital_tokens.csv      │    → pharmacy_tokens.csv           │
│  (encrypted tokens)         │    (encrypted tokens)              │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                    RECORD LINKAGE                                │
│  1. Decrypt tokens (using shared key)                            │
│  2. Compare decrypted hashes                                     │
│  3. Find matches (all 5 tokens must match)                       │
│  → matching_records.csv (40 matches)                             │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Start Guide

### Step 1: Generate Datasets

```bash
cd scripts
python generate_superhero_datasets.py
```

This creates:
- `datasets/hospital_superhero_data.csv` (100 records)
- `datasets/pharmacy_superhero_data.csv` (120 records with 40 overlapping)

### Step 2: Tokenize the Data

Each organization tokenizes their own dataset independently:

**Using Default Demo Secrets:**
```bash
cd scripts
chmod +x tokenize_datasets.sh
./tokenize_datasets.sh
```

**Using Custom Secrets:**
```bash
cd scripts
chmod +x tokenize_datasets.sh
./tokenize_datasets.sh "YourHashingSecret" "Your-32-Character-Encryption-Key"
```

This script simulates two separate tokenization processes:
1. **Hospital tokenizes their dataset** → `outputs/hospital_tokens.csv`
2. **Pharmacy tokenizes their dataset** → `outputs/pharmacy_tokens.csv`
3. Metadata files are created for both datasets

**Critical Requirements**:
- Both organizations must use the **same hashing and encryption keys**
- The encryption key must be exactly **32 characters** long
- Keys must be shared securely between organizations before tokenization
- In production, use strong keys and secure key exchange protocols

### Step 3: Measure Overlap

**Using Default Encryption Key:**
```bash
cd scripts
python analyze_overlap.py
```

**Using Custom Encryption Key:**
```bash
cd scripts
python analyze_overlap.py "Your-32-Character-Encryption-Key"
```

This script performs the record linkage analysis:
1. **Loads** encrypted tokens from both datasets
2. **Decrypts** tokens to get the underlying HMAC-SHA256 hashes
   - Decryption is necessary because OpenToken uses random IVs for encryption
   - Each tokenization produces different encrypted values for the same data
   - Decryption reveals the deterministic hash values that can be compared
3. **Compares** decrypted tokens to find matches
4. **Reports** matching statistics
5. **Saves** results to `outputs/matching_records.csv`

**Note**: The encryption key provided to the analysis script must match the one used during tokenization.

## Expected Results

After running the analysis, you should see:

```
MATCH SUMMARY
======================================================================
Total matching record pairs: 40

Matches with 5 tokens: 40

OVERLAP STATISTICS
======================================================================
Hospital records with matches: 40 out of 100 (40.0%)
Pharmacy records with matches: 40 out of 120 (33.3%)
======================================================================
```

## Understanding the Output

### Token Files

The tokenized CSV files (`hospital_tokens.csv`, `pharmacy_tokens.csv`) contain:

| Column    | Description                                              |
|-----------|----------------------------------------------------------|
| RecordId  | Original record identifier from source dataset           |
| TokenId   | Token type (T1, T2, T3, T4, or T5)                      |
| Token     | Encrypted token value (Base64-encoded)                   |

Example:
```csv
RecordId,TokenId,Token
891dda6c-961f-4154-8541-b48fe18ee620,T1,Gn7t1Zj16E5Qy+z9iINtczP6fRDYta6C0XFr...
891dda6c-961f-4154-8541-b48fe18ee620,T2,pUxPgYL9+cMxkA+8928Pil+9W+dm9kISwHYP...
```

Each record generates 5 rows (one per token type).

### Metadata Files

The metadata JSON files contain:
- Total records processed
- Valid/invalid record counts
- Processing timestamp
- Library version
- SHA-256 hashes of the secrets used (not the secrets themselves)

### Matching Results

`matching_records.csv` shows which records match:

| Column              | Description                                    |
|---------------------|------------------------------------------------|
| HospitalRecordId    | Record ID from hospital dataset                |
| PharmacyRecordId    | Record ID from pharmacy dataset                |
| MatchingTokens      | Which tokens matched (e.g., "T1\|T2\|T3\|T4\|T5") |
| TokenCount          | Number of matching tokens (should be 5)        |

## Understanding Token Decryption in PPRL

### Why Decryption is Necessary

OpenToken uses **AES-256-GCM encryption with random IVs** (initialization vectors) for each encryption operation. This is a security best practice that prevents pattern analysis attacks. However, it creates a challenge for multi-party record linkage:

1. **Problem**: Hospital tokenizes their data → produces encrypted tokens with random IVs
2. **Problem**: Pharmacy tokenizes their data → produces different encrypted tokens (different IVs)
3. **Result**: Even for identical patients, encrypted tokens differ and won't match directly

### The Solution

To enable record linkage across independently tokenized datasets:

1. **Decrypt** tokens to reveal the underlying HMAC-SHA256 hash layer
2. **Compare** the decrypted hashes (which are deterministic and identical for matching data)
3. **Important**: Decryption only reveals the hash, NOT the original patient data

**Example**:
```
Hospital encrypts: 
  Patient "John Doe" → HMAC-SHA256 hash → AES encrypt with IV₁ → Token A

Pharmacy encrypts:
  Patient "John Doe" → HMAC-SHA256 hash → AES encrypt with IV₂ → Token B

Token A ≠ Token B (different IVs)

But decrypt(Token A) = decrypt(Token B) = same HMAC-SHA256 hash ✓
```

### Decryption Layer Structure

```
Raw Data → Normalization → HMAC-SHA256 → AES-GCM Encryption
                              ↑               ↑
                         Deterministic    Random IV
                         (comparable)    (not comparable)
```

For matching: We decrypt to the HMAC layer, which is deterministic and comparable.

## Privacy Considerations

### What is Protected
- **Raw patient data** is never shared between organizations
- **HMAC-SHA256 hashes** cannot be reversed to get original data
- **Encryption key** controls who can decrypt and perform linkage
- **Hashing secret** ensures only parties with the key can generate comparable tokens

### What is Shared
- **Encrypted tokens** for secure transmission between organizations
- **Decrypted hashes** (within secure matching environment only)
- **Matching statistics** - organizations see overlap counts without raw identities

### Security Best Practices

1. **Key Management**:
   - Use strong, cryptographically random keys (not the demo keys!)
   - Share keys only through secure channels (encrypted email, key management systems)
   - Rotate keys periodically (requires re-tokenization)

2. **Access Control**:
   - Limit decryption capability to authorized matching systems only
   - Log all decryption and matching operations
   - Use separate environments for tokenization vs. matching

3. **Data Governance**:
   - Establish data use agreements before sharing tokens
   - Define permitted uses of matching results
   - Implement audit trails for all token operations

4. **Technical Controls**:
   - Never store decrypted hashes long-term
   - Perform matching in secure, isolated environments
   - Delete tokens after matching is complete (per agreement)

### Real-World Deployment Considerations

In production PPRL systems:

1. **Trusted Third Party (TTP)**: A neutral organization holds decryption keys and performs matching
2. **Secure Multi-Party Computation (SMPC)**: Advanced protocols for matching without any party seeing decrypted tokens
3. **Hardware Security Modules (HSMs)**: Store keys in tamper-resistant hardware
4. **Differential Privacy**: Add noise to matching statistics to prevent re-identification

## File Structure

```
pprl-superhero-example/
├── README.md                          # This file
├── datasets/                          # Generated datasets
│   ├── hospital_superhero_data.csv
│   └── pharmacy_superhero_data.csv
├── scripts/                           # Scripts for demo
│   ├── generate_superhero_datasets.py # Generate test data
│   ├── tokenize_datasets.sh          # Tokenize both datasets
│   └── analyze_overlap.py            # Analyze overlaps
└── outputs/                           # Tokenization outputs
    ├── hospital_tokens.csv
    ├── hospital_tokens.csv.metadata.json
    ├── pharmacy_tokens.csv
    ├── pharmacy_tokens.csv.metadata.json
    └── matching_records.csv
```

## Step-by-Step: How Organizations Would Use This

### In Real-World Scenarios

This demo simulates how two separate organizations would perform PPRL:

#### Phase 1: Key Agreement (Done Once)
Both organizations agree on shared secrets:
- **Hashing secret**: A shared secret for HMAC-SHA256 (any length)
- **Encryption key**: A shared 32-character key for AES-256-GCM

**Security Note**: In production, use secure key exchange protocols (e.g., encrypted email, key management systems, HSMs).

**Example Keys (for demo only):**
- Hashing secret: `SuperHeroHashingKey2024`
- Encryption key: `SuperHero-Encryption-Key-32chars` (exactly 32 characters)

#### Phase 2: Hospital Tokenizes Their Data

```bash
# Hospital has: hospital_superhero_data.csv
# Hospital uses their agreed-upon secrets
java -jar opentoken-1.10.0.jar \
    -t csv \
    -i hospital_superhero_data.csv \
    -o hospital_tokens.csv \
    -h "<AGREED_HASHING_SECRET>" \
    -e "<AGREED_32_CHAR_ENCRYPTION_KEY>"

# Hospital shares: hospital_tokens.csv (encrypted, safe to share)
```

#### Phase 3: Pharmacy Tokenizes Their Data

```bash
# Pharmacy has: pharmacy_superhero_data.csv
# Pharmacy uses the SAME secrets as hospital
java -jar opentoken-1.10.0.jar \
    -t csv \
    -i pharmacy_superhero_data.csv \
    -o pharmacy_tokens.csv \
    -h "<AGREED_HASHING_SECRET>" \
    -e "<AGREED_32_CHAR_ENCRYPTION_KEY>"

# Pharmacy shares: pharmacy_tokens.csv (encrypted, safe to share)
```

#### Phase 4: Trusted Third Party Performs Matching

A trusted third party (or secure computation environment):

1. Receives both token files
2. Has the encryption key (to decrypt)
3. Runs the analysis script with the encryption key:

```bash
python analyze_overlap.py "<AGREED_32_CHAR_ENCRYPTION_KEY>"
```

4. Returns only matching statistics (not individual patient data)

#### What Each Party Learns

- **Hospital**: "40 of our 100 patients match with pharmacy"
- **Pharmacy**: "40 of our 120 patients match with hospital"
- **Neither party sees**: The other party's raw patient data
- **Optional**: With agreement, they can exchange matched RecordIds to link specific records

## Customization

### Changing Dataset Size

Edit `generate_superhero_datasets.py`:

```python
num_hospital = 200      # Hospital records
num_pharmacy = 250      # Pharmacy records
overlap_percentage = 0.30  # 30% overlap
```

### Using Different Secrets

Pass secrets as command-line arguments:

**For tokenization:**
```bash
./tokenize_datasets.sh "YourCustomHashingKey" "YourCustomEncryptionKey-32chars"
```

**For analysis:**
```bash
python analyze_overlap.py "YourCustomEncryptionKey-32chars"
```

**For complete demo:**
```bash
./run_complete_demo.sh "YourCustomHashingKey" "YourCustomEncryptionKey-32chars"
```

**Important**: 
- The encryption key must be exactly 32 characters long
- Both datasets must use the same secrets for tokens to be comparable
- The analysis script needs the same encryption key used during tokenization

### Adjusting Match Criteria

Edit `analyze_overlap.py` to require fewer matching tokens:

```python
# Find matches with at least 4 out of 5 tokens matching
matches = find_matches(hospital_tokens, pharmacy_tokens, required_token_matches=4)
```

## Troubleshooting

### "No matches found"

**Cause**: Datasets were tokenized with different secrets.

**Solution**: Ensure both tokenizations use identical hashing and encryption keys.

### "Invalid attribute" errors during tokenization

**Cause**: Some generated data doesn't meet OpenToken validation rules.

**Solution**: This is expected. OpenToken validates data (e.g., SSN format, birthdate ranges) and skips invalid records. Check the metadata file for details.

### Build errors

**Cause**: Maven or Java not installed/configured.

**Solution**: 
```bash
# Check Java
java -version  # Should be 11+

# Check Maven
mvn -version   # Should be 3.6+
```

## Real-World Applications

This demonstration can be adapted for:

- **Healthcare**: Hospital-to-hospital patient matching
- **Insurance**: Claims linkage across providers
- **Research**: Multi-site study participant matching
- **Government**: Cross-agency identity resolution
- **Financial Services**: Anti-fraud systems

## Additional Resources

- [OpenToken Main README](../../README.md)
- [Development Guide](../../docs/dev-guide-development.md)
- [Metadata Format Documentation](../../docs/metadata-format.md)

## Questions?

For issues or questions about OpenToken, please visit the [GitHub repository](https://github.com/mattwise-42/OpenToken).
