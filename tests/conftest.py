# import json
import logging

import pytest
from lib.constants import LOG_FORMAT
from pytest_bdd import given, parsers, then

# import os
# import os.path
# import shutil
# import subprocess
# import warnings
# from typing import Generator, List


logging.basicConfig(format=LOG_FORMAT, level=logging.INFO)
_logger = logging.getLogger(__name__)


def pytest_addoption(parser):
    parser.addoption("--namespace", action="store", default="default")


@pytest.fixture(scope="session")
def namespace(request):
    namespace_value = request.config.option.namespace
    if namespace_value is None:
        pytest.skip()
    return namespace_value


def pytest_sessionstart(session):
    namespace = session.config.getoption("--namespace")

    _logger.info(f"pytest_sessionstart: namespace = {namespace}")


def pytest_bdd_after_scenario(request):
    namespace = request.config.getoption("--namespace")

    _logger.info(f"pytest_bdd_after_scenario hook: namespace = {namespace}")


# note that if sessionstart fails this step will not be executed
def pytest_sessionfinish():
    _logger.info(f"pytest_sessionfinish hook")
