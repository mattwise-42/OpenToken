# OpenToken PySpark Bridge - Implementation Notes

## Overview

This document provides implementation details for the OpenToken PySpark bridge library added to the OpenToken project.

## What Was Implemented

### 1. Package Structure (`lib/python-pyspark/`)

A complete Python package was created with the following structure:

```
lib/python-pyspark/
├── setup.py                    # Package configuration
├── requirements.txt            # Production dependencies
├── dev-requirements.txt        # Development dependencies
├── pyproject.toml             # pytest configuration
├── .flake8                    # Code style configuration
├── MANIFEST.in                # Package manifest
├── README.md                  # Package documentation
├── INSTALL.md                 # Detailed installation guide
├── IMPLEMENTATION_NOTES.md    # This file
├── src/
│   ├── main/
│   │   └── opentoken_pyspark/
│   │       ├── __init__.py           # Package initialization
│   │       └── token_processor.py    # Main implementation
│   └── test/
│       └── opentoken_pyspark/
│           ├── __init__.py
│           └── token_processor_test.py  # Comprehensive tests
├── examples/
│   └── simple_example.py      # Runnable example script
└── notebooks/
    └── OpenToken_PySpark_Example.ipynb  # Interactive tutorial
```

### 2. Core Implementation (`token_processor.py`)

The `OpenTokenProcessor` class provides the main functionality:

#### Key Features:
- **Accepts PySpark DataFrames**: Works seamlessly with distributed data
- **Pandas UDF Implementation**: Uses pandas UDFs for efficient batch processing
- **Column Name Flexibility**: Supports multiple column name variants (e.g., FirstName/GivenName)
- **Secret Management**: Validates and uses HMAC-SHA256 and AES-256 secrets
- **Error Handling**: Comprehensive validation and error messages

#### Architecture:
1. Input DataFrame is validated for required columns
2. Column names are mapped to standard attributes
3. Pandas UDF processes batches of records in parallel
4. For each record batch:
   - Token transformers are initialized with secrets
   - TokenGenerator creates tokens using OpenToken core library
   - Results are collected and returned
5. Output DataFrame contains: RecordId, RuleId, Token

### 3. Test Suite (`token_processor_test.py`)

Comprehensive tests covering:
- Initialization with valid/invalid secrets
- DataFrame processing with various column names
- Error handling for missing columns
- Token consistency and determinism
- Different secrets producing different tokens
- Empty DataFrames
- Column mapping functionality

All tests use pytest and PySpark's local testing mode.

### 4. Documentation

#### README.md
- Feature overview
- Quick start guide
- Input/output format specifications
- Performance considerations
- Security notes

#### INSTALL.md
- Step-by-step installation instructions
- Prerequisites
- Troubleshooting guide
- Docker alternative

#### Jupyter Notebook
- Interactive tutorial with examples
- Data loading from CSV
- Token generation
- Result analysis and visualization
- Alternative column name examples

#### Simple Example Script
- Standalone Python script
- Demonstrates basic usage
- Can be run directly for quick testing

### 5. Version Management

Updated version to 1.11.0 across all files:
- `.bumpversion.cfg` - Added python-pyspark entries
- `lib/java/pom.xml`
- `lib/java/src/main/java/com/truveta/opentoken/Metadata.java`
- `lib/python/setup.py`
- `lib/python/src/main/opentoken/__init__.py`
- `lib/python/src/main/opentoken/metadata.py`
- `lib/python-pyspark/setup.py`
- `lib/python-pyspark/src/main/opentoken_pyspark/__init__.py`
- `Dockerfile`

### 6. Main README Updates

Added sections:
- PySpark quick start guide
- Updated project structure diagram
- Links to PySpark bridge documentation

### 7. .gitignore Updates

Added exclusions for:
- `.ipynb_checkpoints/`
- `spark-warehouse/`
- `metastore_db/`
- `derby.log`

## Technical Design Decisions

### 1. Pandas UDF Choice
**Decision**: Use Pandas UDFs instead of Row-based UDFs
**Rationale**: 
- Better performance with vectorized operations
- More efficient serialization/deserialization
- Natural integration with OpenToken's Python API

### 2. Batch Processing
**Decision**: Process records in batches within each partition
**Rationale**:
- Reduces overhead of token generator initialization
- Balances memory usage with performance
- Leverages PySpark's natural partitioning

### 3. Column Name Flexibility
**Decision**: Support multiple column name variants
**Rationale**:
- Improves usability with existing datasets
- Matches OpenToken core library's approach
- Reduces need for data preprocessing

### 4. Secrets in UDF
**Decision**: Pass secrets as closure variables to UDF
**Rationale**:
- Secrets are broadcast to workers efficiently
- Transformer initialization happens once per batch
- Maintains security while enabling distributed processing

### 5. Separate Package
**Decision**: Create a separate package instead of integrating into core
**Rationale**:
- Optional dependency (PySpark is large and not always needed)
- Clear separation of concerns
- Easier to test and maintain independently
- Follows the project's structure pattern

## Security Considerations

1. **Secret Handling**: Secrets are serialized to worker nodes - ensure secure cluster configuration
2. **Token Security**: Uses same cryptographic approach as core library
3. **No Vulnerabilities**: Passed CodeQL security scan with zero issues
4. **Input Validation**: Comprehensive validation before processing

## Performance Characteristics

- **Partitioning**: Inherits PySpark's natural partitioning
- **Memory**: Memory-efficient batch processing
- **Scalability**: Linear scaling with cluster size
- **Optimization**: Can tune `spark.sql.shuffle.partitions` for workload

## Testing Approach

Tests were designed to be:
1. **Independent**: Each test runs in isolation
2. **Fast**: Use small datasets and local Spark mode
3. **Comprehensive**: Cover happy paths and error cases
4. **Maintainable**: Clear test names and structure

## Known Limitations

1. **Network Required**: PySpark installation requires internet connectivity
2. **Java Dependency**: Requires Java 8+ for PySpark
3. **Local Testing**: Full distributed testing requires a Spark cluster
4. **Memory**: Large DataFrames may require executor memory tuning

## Future Enhancements

Potential improvements for future versions:

1. **Caching**: Cache token transformers across batches
2. **Partitioning Strategy**: Optimize partition size for token generation
3. **Streaming**: Add support for Spark Structured Streaming
4. **Broadcast Variables**: Use broadcast variables for secrets
5. **Metrics**: Add detailed performance metrics
6. **Integration Tests**: Add tests against real Spark clusters

## Dependencies

### Required
- `pyspark>=3.0.0`: Apache Spark for distributed computing
- `opentoken`: Core OpenToken library (local install)

### Development
- `pytest`: Testing framework
- `jupyter`: Interactive notebooks
- `notebook`: Jupyter notebook interface
- `ipykernel`: Python kernel for Jupyter
- `flake8`: Code linting

## Compliance

- **Code Style**: Passes flake8 with project configuration
- **Security**: Passes CodeQL security scan
- **Tests**: Comprehensive test coverage
- **Documentation**: Complete documentation package
- **Versioning**: Follows project's bump2version pattern

## Integration Points

### With Core Library
- Uses `TokenGenerator` for token creation
- Imports all attribute classes
- Uses `TokenDefinition` for rule definitions
- Uses `TokenTransformer` implementations

### With PySpark
- Integrates with DataFrame API
- Uses Pandas UDFs for performance
- Leverages partitioning for parallelism
- Follows PySpark conventions

## Conclusion

The OpenToken PySpark bridge successfully extends OpenToken's capabilities to distributed computing environments, enabling large-scale privacy-preserving token generation while maintaining the security and correctness guarantees of the core library.
