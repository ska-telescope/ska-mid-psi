## ska-tango-archiver parameters for TimeScale DB and Archiver
TANGO_HOST_NAME?= $(shell echo $(TANGO_HOST) | cut -d ":" -f 1)

TELESCOPE ?= SKA-mid
ARCHIVER_DBNAME ?= default_timescaledb
TIMESCALE_POD_NAME ?= timescaledb
TIMESCALE_DB_NAMESPACE ?= ska-eda-mid-db
EVENT_SUBSCRIBER ?= "mid-eda/es/01"
CONFIG_MANAGER ?= mid-eda/cm/01 #without quotes because used for ARCHWIZARD_CONFIG
ARCHIVER_TIMESCALE_HOST_NAME ?= $(TIMESCALE_POD_NAME).$(TIMESCALE_DB_NAMESPACE).svc.$(CLUSTER_DOMAIN)
ARCHIVER_TIMESCALE_PORT ?= 5432#for testing
ARCHIVER_TIMESCALE_DB_USER ?= admin#for testing
ARCHIVER_TIMESCALE_DB_PWD ?= admin#for testing
#ARCHIVER_TIMESCALE_DB_PWD ?= TfqQuRxku4aYTRpk#for testing
ARCHWIZARD_VIEW_DBNAME ?= MyHDB
ARCHWIZARD_CONFIG ?= $(ARCHWIZARD_VIEW_DBNAME)=tango://$(TANGO_HOST_NAME).$(KUBE_NAMESPACE).svc.$(CLUSTER_DOMAIN):10000/$(CONFIG_MANAGER)
TELESCOPE_ENVIRONMENT ?= MID_PSI
SKA_TANGO_ARCHIVER_PARAMS = --set ska-tango-archiver.enabled=$(SKA_TANGO_ARCHIVER) \
							--set ska-tango-archiver.telescope=$(TELESCOPE) \
							--set ska-tango-archiver.hostname=$(ARCHIVER_TIMESCALE_HOST_NAME) \
							--set ska-tango-archiver.dbname=$(ARCHIVER_DBNAME) \
							--set ska-tango-archiver.port=$(ARCHIVER_TIMESCALE_PORT) \
							--set ska-tango-archiver.dbuser=$(ARCHIVER_TIMESCALE_DB_USER) \
							--set ska-tango-archiver.dbpassword=$(ARCHIVER_TIMESCALE_DB_PWD) \
							--set ska-tango-archiver.archwizard_config=$(ARCHWIZARD_CONFIG) \
							--set ska-tango-archiver.configuration_manager="$(CONFIG_MANAGER)"\
							--set ska-tango-archiver.event_subscriber=$(EVENT_SUBSCRIBER)\
							--set ska-tango-archiver.telescope_environment=$(TELESCOPE_ENVIRONMENT)\
							--set ska-tango-archiver.archviewer.instances[0].name="mid"\
							--set ska-tango-archiver.archviewer.instances[0].timescale_host="$(ARCHIVER_TIMESCALE_HOST_NAME)"\
							--set ska-tango-archiver.archviewer.instances[0].timescale_databases=""\
							--set ska-tango-archiver.archviewer.instances[0].timescale_login="$(ARCHIVER_TIMESCALE_DB_USER):$(ARCHIVER_TIMESCALE_DB_PWD)"