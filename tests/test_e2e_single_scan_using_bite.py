"""Telescope end-to-end observation scan using BITE in the Mid PSI feature tests."""

from pytest_bdd import given, scenario, then, when


@scenario(
    "features/e2e_single_scan_using_bite.feature",
    "Automated Single E2E Observation Scan using BITE in Mid PSI",
)
def test_automated_single_e2e_observation_scan_using_bite_in_mid_psi():
    """Automated Single E2E Observation Scan using BITE in Mid PSI."""


@given("a SUT deployment in the Mid PSI")
def a_sut_deployment_in_the_mid_psi():
    """a SUT deployment in the Mid PSI."""
    print("a SUT deployment in the Mid PSI")


@given("the SUT is configured")
def the_sut_is_configured():
    """the SUT is configured."""
    print("the SUT is configured")


@when("the telescope is turned on")
def the_telescope_is_turned_on():
    """the telescope is turned on."""
    print("the telescope is turned on")


@when("BITE data is generated and replaying")
def bite_data_is_generated_and_replaying():
    """BITE data is generated and replaying."""
    print("BITE data is generated and replaying")


@when("resources are assigned")
def resources_are_assigned():
    """resources are assigned."""
    print("resources are assigned")


@when("scanning is executed for a scan duration of 30-45s")
def scanning_is_executed_for_a_scan_duration_of_3045s():
    """scanning is executed for a scan duration of 30-45s."""
    print("scanning is executed for a scan duration of 30-45s")


@when("the subarray is configured for a scan")
def the_subarray_is_configured_for_a_scan():
    """the subarray is configured for a scan."""
    print("the subarray is configured for a scan")


@then("a measurement set is captured")
def a_measurement_set_is_captured():
    """a measurement set is captured."""
    print("a measurement set is captured")


@then("the measurement set has size > 5 MB")
def the_measurement_set_has_size__5_mb():
    """the measurement set has size > 5 MB."""
    print("the measurement set has size > 5 MB")
