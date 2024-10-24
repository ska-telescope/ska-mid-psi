Feature: Telescope end-to-end observation scan using BITE in the Mid PSI
	In this test the telescope is controlled via TMC. The telescope is taken from
    the telescope OFF state through loadDishCfg, TelescopeOn, AssignResources, ConfigureScan, 
    Scan, EndScan, End and finally telescope OFF. I.e. the full signal chain is tested.
	

	#h3. *Test Purpose*
	#
	#The purpose of this test is to execute an automated single E2E observation scan in the Mid PSI environment and capture the results. The following Mid products will be used:
	# * Dish LMC
	# * TMC
	# * CSP.LMC
	# * CBF (using BITE)
	# * SDP
	@XTP-68764 @XTP-66644 @Mid_PSI
	Scenario: Automated Single E2E Observation Scan using BITE in Mid PSI
		Given a SUT deployment in the Mid PSI
		And the SUT is configured
		When the telescope is turned on
		And BITE data is generated and flowing
		And resources are assigned
		And the subarray is configured for a scan
		And scanning is executed for a scan duration of 30-45s
		Then a measurement set is captured
		And the measurement set has size > 5 MB