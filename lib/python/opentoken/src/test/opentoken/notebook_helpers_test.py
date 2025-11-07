"""
Copyright (c) Truveta. All rights reserved.

Tests for notebook helpers module.
"""

import pytest
from opentoken.notebook_helpers import (
    TokenBuilder,
    CustomTokenDefinition,
    create_token_generator,
    quick_token,
    list_attributes,
    expression_help,
    ATTRIBUTE_MAP
)
from opentoken.attributes.person.first_name_attribute import FirstNameAttribute
from opentoken.attributes.person.last_name_attribute import LastNameAttribute
from opentoken.attributes.general.record_id_attribute import RecordIdAttribute


def test_token_builder_basic():
    """Test basic token builder functionality."""
    token = TokenBuilder("T6") \
        .add("last_name", "T|U") \
        .add("first_name", "T|U") \
        .build()
    
    assert token.get_identifier() == "T6"
    definition = token.get_definition()
    assert len(definition) == 2
    assert definition[0].attribute_class == LastNameAttribute
    assert definition[1].attribute_class == FirstNameAttribute


def test_token_builder_with_class():
    """Test token builder with attribute class instead of string."""
    token = TokenBuilder("T7") \
        .add(FirstNameAttribute, "T|U") \
        .add(LastNameAttribute, "T|S(0,3)|U") \
        .build()
    
    assert token.get_identifier() == "T7"
    definition = token.get_definition()
    assert len(definition) == 2


def test_token_builder_invalid_attribute():
    """Test that invalid attribute name raises error."""
    with pytest.raises(ValueError, match="Unknown attribute"):
        TokenBuilder("T8").add("invalid_attr", "T|U")


def test_custom_token_definition():
    """Test custom token definition."""
    token1 = TokenBuilder("T6").add("last_name", "T|U").build()
    token2 = TokenBuilder("T7").add("first_name", "T|U").build()
    
    definition = CustomTokenDefinition()
    definition.add_token(token1)
    definition.add_token(token2)
    
    assert definition.get_version() == "2.0-custom"
    assert definition.get_token_identifiers() == {"T6", "T7"}
    assert definition.get_token_definition("T6") is not None
    assert definition.get_token_definition("T7") is not None
    assert definition.get_token_definition("T99") is None


def test_create_token_generator():
    """Test token generator creation."""
    generator = create_token_generator(
        "test-hash-secret",
        "12345678901234567890123456789012"  # Exactly 32 characters
    )
    
    assert generator is not None


def test_create_token_generator_with_custom_definition():
    """Test token generator with custom definition."""
    token = TokenBuilder("T6").add("last_name", "T|U").build()
    definition = CustomTokenDefinition().add_token(token)
    
    generator = create_token_generator(
        "test-hash-secret",
        "12345678901234567890123456789012",  # Exactly 32 characters
        definition
    )
    
    assert generator is not None


def test_quick_token():
    """Test quick token creation."""
    generator = quick_token(
        "T6",
        [
            ("last_name", "T|U"),
            ("first_name", "T|U"),
            ("birth_date", "T|D")
        ],
        "test-hash-secret",
        "12345678901234567890123456789012"  # Exactly 32 characters
    )
    
    assert generator is not None


def test_quick_token_generates_tokens():
    """Test that quick token actually generates tokens."""
    generator = quick_token(
        "T6",
        [
            ("last_name", "T|U"),
            ("first_name", "T|U"),
        ],
        "test-hash-secret",
        "12345678901234567890123456789012"  # Exactly 32 characters
    )
    
    person_attrs = {
        RecordIdAttribute: "1",
        FirstNameAttribute: "John",
        LastNameAttribute: "Doe",
    }
    
    result = generator.get_all_tokens(person_attrs)
    assert "T6" in result.tokens
    assert result.tokens["T6"] is not None


def test_list_attributes():
    """Test listing available attributes."""
    attrs = list_attributes()
    
    assert "first_name" in attrs
    assert "last_name" in attrs
    assert "birth_date" in attrs
    assert attrs["first_name"] == FirstNameAttribute
    assert attrs["last_name"] == LastNameAttribute


def test_expression_help():
    """Test expression help text."""
    help_text = expression_help()
    
    assert "T" in help_text
    assert "U" in help_text
    assert "S(start,end)" in help_text
    assert "D" in help_text
    assert "Examples:" in help_text
