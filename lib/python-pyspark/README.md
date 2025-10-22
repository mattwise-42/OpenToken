# OpenToken PySpark Bridge

A PySpark integration for the OpenToken library, enabling distributed privacy-preserving token generation for large-scale person matching workflows.

## Overview

The OpenToken PySpark Bridge provides a seamless interface between PySpark DataFrames and the OpenToken library, allowing you to generate cryptographically secure tokens for person matching in a distributed computing environment.

## Features

- **Distributed Processing**: Leverage PySpark's distributed computing capabilities for large datasets
- **Simple API**: Easy-to-use interface that accepts PySpark DataFrames
- **Compatible**: Works with standard OpenToken secrets for consistent token generation
- **Flexible Column Names**: Supports multiple column name variants (e.g., FirstName/GivenName)
- **Jupyter Ready**: Includes example notebooks for interactive exploration

## Installation

### Prerequisites

- Python 3.10 or higher
- PySpark 3.0.0 or higher
- OpenToken core library

### Install from Source

```bash
# First, install the OpenToken core library
cd lib/python
pip install -e .

# Then install the PySpark bridge
cd ../python-pyspark
pip install -e .
```

### Development Installation

For development with testing and Jupyter support:

```bash
cd lib/python-pyspark
pip install -e ".[dev]"
```

## Quick Start

```python
from pyspark.sql import SparkSession
from opentoken_pyspark import OpenTokenProcessor

# Create Spark session
spark = SparkSession.builder \
    .appName("OpenTokenExample") \
    .master("local[*]") \
    .getOrCreate()

# Load your data
df = spark.read.csv("data.csv", header=True)

# Initialize processor with your secrets
processor = OpenTokenProcessor(
    hashing_secret="your-hashing-secret",
    encryption_key="your-encryption-key"
)

# Generate tokens
tokens_df = processor.process_dataframe(df)

# View results
tokens_df.show()
```

## Input DataFrame Requirements

Your input DataFrame must contain the following columns (alternative names are supported):

| Standard Name | Alternative Names | Description |
|--------------|-------------------|-------------|
| RecordId | Id | Unique identifier (optional - auto-generated if not provided) |
| FirstName | GivenName | Person's first name |
| LastName | Surname | Person's last name |
| BirthDate | DateOfBirth | Date of birth in YYYY-MM-DD format |
| Sex | Gender | Sex/Gender (Male, Female, M, F) |
| PostalCode | ZipCode | US ZIP code or Canadian postal code |
| SocialSecurityNumber | NationalIdentificationNumber | SSN or national ID number |

## Output Format

The output DataFrame contains:

- **RecordId**: The original record identifier
- **RuleId**: Token rule identifier (T1, T2, T3, T4, T5)
- **Token**: The generated cryptographic token

Each input record produces multiple output rows (one per token rule).

## Example Notebook

See the included Jupyter notebook for a complete example:

```bash
cd notebooks
jupyter notebook OpenToken_PySpark_Example.ipynb
```

## Testing

Run the test suite:

```bash
# From the python-pyspark directory
pytest
```

## Performance Considerations

- **Partitioning**: PySpark processes data in parallel across partitions. Adjust `spark.sql.shuffle.partitions` for your cluster size.
- **Memory**: Token generation is memory-efficient but ensure adequate executor memory for your data volume.
- **Secrets**: Secrets are serialized to worker nodes - ensure secure cluster configuration.

## Architecture

The PySpark bridge uses Pandas UDFs (User Defined Functions) to efficiently process batches of records:

1. Data is partitioned across the Spark cluster
2. Each partition is processed by a Pandas UDF
3. Within each batch, the OpenToken library generates tokens
4. Results are collected back into a PySpark DataFrame

This architecture balances the benefits of distributed computing with the cryptographic requirements of token generation.

## Security Notes

- **Secrets Management**: Use secure secrets management systems in production (e.g., AWS Secrets Manager, Azure Key Vault)
- **Network Security**: Ensure secure communication between Spark nodes
- **Data Privacy**: Generated tokens are cryptographically secure and cannot be reversed to original values

## Related Documentation

- [OpenToken Core Library](../python/README.md)
- [Main OpenToken Documentation](../../README.md)
- [Development Guide](../../docs/dev-guide-development.md)

## Contributing

Contributions are welcome! Please see the main OpenToken contributing guidelines.

## License

Copyright (c) Truveta. All rights reserved.
