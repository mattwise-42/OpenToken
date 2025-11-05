# OpenToken PySpark Installation Guide

This guide walks you through installing and setting up the OpenToken PySpark bridge.

## Prerequisites

- Python 3.10 or higher
- pip package manager
- Java 8 or higher (required by PySpark)

## Installation Steps

### 1. Install OpenToken Core Library

First, install the core OpenToken library:

```bash
cd lib/python
pip install -e .
```

Verify the installation:

```bash
python -c "import opentoken; print(f'OpenToken version: {opentoken.__version__}')"
```

### 2. Install PySpark

Install Apache PySpark:

```bash
pip install pyspark>=3.0.0
```

Verify PySpark installation:

```bash
python -c "import pyspark; print(f'PySpark version: {pyspark.__version__}')"
```

### 3. Install OpenToken PySpark Bridge

Install the PySpark bridge:

```bash
cd ../python-pyspark
pip install -e .
```

Verify the installation:

```bash
python -c "import opentoken_pyspark; print(f'OpenToken PySpark version: {opentoken_pyspark.__version__}')"
```

### 4. (Optional) Install Development Dependencies

For development, testing, and Jupyter notebook support:

```bash
cd lib/python-pyspark
pip install -e ".[dev]"
```

This installs additional packages:
- pytest (for running tests)
- jupyter (for running notebooks)
- notebook (Jupyter Notebook interface)
- ipykernel (Python kernel for Jupyter)
- flake8 (code linting)

## Verification

Run a simple test to verify everything is working:

```bash
cd lib/python-pyspark
python examples/simple_example.py
```

You should see output showing token generation for sample records.

## Running Tests

To run the test suite:

```bash
cd lib/python-pyspark
pytest
```

## Using Jupyter Notebooks

To explore the example notebook:

```bash
cd lib/python-pyspark/notebooks
jupyter notebook OpenToken_PySpark_Example.ipynb
```

## Troubleshooting

### Java Not Found

If you get an error about Java not being found:

1. Install Java 8 or higher
2. Set the `JAVA_HOME` environment variable:
   ```bash
   export JAVA_HOME=/path/to/java
   ```

### PySpark Import Errors

If you encounter import errors with PySpark:

1. Ensure you have a compatible Python version (3.10+)
2. Try reinstalling PySpark:
   ```bash
   pip uninstall pyspark
   pip install pyspark>=3.0.0
   ```

### Memory Issues

For large datasets, you may need to configure Spark memory:

```python
spark = SparkSession.builder \
    .appName("OpenToken") \
    .config("spark.executor.memory", "4g") \
    .config("spark.driver.memory", "4g") \
    .getOrCreate()
```

## Docker Installation (Alternative)

If you prefer using Docker:

```bash
# Build the OpenToken Docker image
cd /home/runner/work/OpenToken/OpenToken
docker build -t opentoken:latest .

# Run with PySpark
docker run -it opentoken:latest bash
# Then inside the container:
cd lib/python-pyspark
pip install pyspark
python examples/simple_example.py
```

## Next Steps

- Read the [README](README.md) for usage examples
- Explore the [Jupyter notebook](notebooks/OpenToken_PySpark_Example.ipynb)
- Check the [main documentation](../../README.md)

## Getting Help

If you encounter issues:

1. Check the [main OpenToken documentation](../../README.md)
2. Review the [development guide](../../docs/dev-guide-development.md)
3. Open an issue on GitHub with details about your environment and error
