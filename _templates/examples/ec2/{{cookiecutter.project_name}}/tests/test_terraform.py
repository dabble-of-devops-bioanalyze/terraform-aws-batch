#!/usr/bin/env python

"""Tests for `terraform` package.

Run as:

python -m pytest  -s  --log-cli-level=INFO tests/test_terraform.py
"""

import pytest
import time
import logging
from pprint import pprint

logging.basicConfig(level=logging.INFO)


def test_output():
    logging.info(f'Writing some tests')
    assert 1 == 1, print('did not succeed')
