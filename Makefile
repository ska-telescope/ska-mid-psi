
PROJECT = ska-mid-psi

# KUBE_NAMESPACE defines the Kubernetes Namespace that will be deployed to
# using Helm.  If this does not already exist it will be created
KUBE_NAMESPACE ?= ska-mid-psi
KUBE_NAMESPACE_SDP ?= $(KUBE_NAMESPACE)-sdp

# UMBRELLA_CHART_PATH Path of the umbrella chart to work with
HELM_CHART ?= ska-mid-psi
UMBRELLA_CHART_PATH ?= charts/$(HELM_CHART)/

# RELEASE_NAME is the release that all Kubernetes resources will be labelled
# with
RELEASE_NAME = $(HELM_CHART)

KUBE_APP ?= ska-mid-psi

TARANTA ?= true # Enable Taranta
TARANTA_AUTH ?= false # Enable Taranta
MINIKUBE ?= false ## Minikube or not

LOADBALANCER_IP ?= 142.73.34.170# psi mid head node
INGRESS_PROTOCOL ?= https
ifeq ($(strip $(MINIKUBE)),true)
LOADBALANCER_IP ?= $(shell minikube ip)
INGRESS_HOST ?= $(LOADBALANCER_IP)
INGRESS_PROTOCOL ?= http
endif

EXPOSE_All_DS ?= true ## Expose All Tango Services to the external network (enable Loadbalancer service)
SKA_TANGO_OPERATOR ?= true
SKA_TANGO_ARCHIVER ?= true ## Set to true to deploy EDA

# Chart for testing
K8S_CHART ?= $(HELM_CHART)
K8S_CHARTS ?= $(K8S_CHART)

DISH_ID ?= ska001

# include OCI Images support
include .make/oci.mk

# include k8s support
include .make/k8s.mk

# include Helm Chart support
include .make/helm.mk

# Include Python support
include .make/python.mk

# include raw support
include .make/raw.mk

# include core make support
include .make/base.mk

# include xray support
include .make/xray.mk

# include your own private variables for custom deployment configuration
-include PrivateRules.mak

# ska-tango-archiver params for EDA deployment
#include archiver/archiver.mk 

TARANTA_PARAMS = --set ska-taranta.enabled=$(TARANTA) \
				 --set global.taranta_auth_enabled=$(TARANTA_AUTH) \
				 --set global.taranta_dashboard_enabled=$(TARANTA)

ifneq ($(MINIKUBE),)
ifneq ($(MINIKUBE),true)
TARANTA_PARAMS = --set ska-taranta.enabled=$(TARANTA) \
				 --set global.taranta_auth_enabled=$(TARANTA_AUTH) \
				 --set global.taranta_dashboard_enabled=$(TARANTA)
endif
endif

CI_JOB_ID ?= local##pipeline job id
TANGO_HOST ?= databaseds-tango-base:10000## TANGO_HOST connection to the Tango DS
TANGO_HOSTNAME ?= databaseds-tango-base
CLUSTER_DOMAIN ?= cluster.local## Domain used for naming Tango Device Servers


K8S_EXTRA_PARAMS ?=
K8S_CHART_PARAMS = --set global.minikube=$(MINIKUBE) \
	--set global.exposeAllDS=$(EXPOSE_All_DS) \
	--set global.tango_host=$(TANGO_HOST) \
	--set global.cluster_domain=$(CLUSTER_DOMAIN) \
	--set global.operator=$(SKA_TANGO_OPERATOR) \
	--set ska-sdp.helmdeploy.namespace=$(KUBE_NAMESPACE_SDP) \
	--set ska-sdp.ska-sdp-qa.zookeeper.clusterDomain=$(CLUSTER_DOMAIN) \
	--set ska-sdp.ska-sdp-qa.kafka.clusterDomain=$(CLUSTER_DOMAIN) \
	--set ska-sdp.ska-sdp-qa.redis.clusterDomain=$(CLUSTER_DOMAIN) \
	--set global.labels.app=$(KUBE_APP) \
	--set spfrx.enabled=$(SPFRX_ENABLED) \
	--set ska-tmc-mid.enabled=$(TMC_ENABLED) \
	--set ska-sdp.enabled=$(SDP_ENABLED) \
	--set global.tangodb_fqdn=$(TANGO_HOSTNAME).$(KUBE_NAMESPACE).svc.$(CLUSTER_DOMAIN) \
	--set global.tango_host=$(TANGO_HOST) \
	--set global.tangodb_port=10000 \
	--set global.dish_id=$(DISH_ID) \
	$(TARANTA_PARAMS)

## ska-tango-archiver parameters for TimeScale DB and Archiver
TANGO_HOST_NAME?= $(shell echo $(TANGO_HOST) | cut -d ":" -f 1)
# CLUSTER_DOMAIN ?= cluster.local

TELESCOPE ?= SKA-mid
ARCHIVER_DBNAME ?= default_timescaledb
TIMESCALE_POD_NAME ?= timescaledb
TIMESCALE_DB_NAMESPACE ?= ska-eda-mid-db
EVENT_SUBSCRIBER ?= "mid-eda/es/01"
CONFIG_MANAGER ?= mid-eda/cm/01 #without quotes because used for ARCHWIZARD_CONFIG
ARCHIVER_TIMESCALE_HOST_NAME ?= $(TIMESCALE_POD_NAME).$(TIMESCALE_DB_NAMESPACE).svc.$(CLUSTER_DOMAIN)
ARCHIVER_TIMESCALE_PORT ?= 5432#for testing
ARCHIVER_TIMESCALE_DB_USER ?= admin#for testing
ARCHIVER_TIMESCALE_DB_PWD ?= TfqQuRxku4aYTRpk#for testing
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

ifeq ($(SKA_TANGO_ARCHIVER),true)
	K8S_CHART_PARAMS += $(SKA_TANGO_ARCHIVER_PARAMS)
endif

ifneq (,$(wildcard $(VALUES)))
	K8S_CHART_PARAMS += $(foreach f,$(wildcard $(VALUES)),--values $(f))
endif

CONFIG_FILE = "archiver/default.yaml" # can override the default config file for archiving
eda-add-attributes:
	@. archiver/configure.sh -n $(KUBE_NAMESPACE) -a add_update -f ${CONFIG_FILE} 

eda-get-attributes:
	@. archiver/configure.sh -n $(KUBE_NAMESPACE) -a get

eda-remove-attributes:
	@. archiver/configure.sh -n $(KUBE_NAMESPACE) -a remove -f ${CONFIG_FILE}

k8s-pre-install-chart:
	@echo "k8s-pre-install-chart: creating the SDP namespace $(KUBE_NAMESPACE_SDP)"
	@make k8s-namespace KUBE_NAMESPACE=$(KUBE_NAMESPACE_SDP)

k8s-pre-install-chart-car:
	@echo "k8s-pre-install-chart-car: creating the SDP namespace $(KUBE_NAMESPACE_SDP)"
	@make k8s-namespace KUBE_NAMESPACE=$(KUBE_NAMESPACE_SDP)

k8s-pre-uninstall-chart:
	@echo "k8s-post-uninstall-chart: deleting the SDP namespace $(KUBE_NAMESPACE_SDP)"
	@if [ "$(KEEP_NAMESPACE)" != "true" ]; then make k8s-delete-namespace KUBE_NAMESPACE=$(KUBE_NAMESPACE_SDP); fi

run-pylint:
	pylint --output-format=parseable tests/ test_parameters/ | tee build/code_analysis.stdout

vars:
	$(info ##### PSI Mid deploy vars)
	@echo "$(VARS)" | sed "s#VAR_#\n#g"

links:
	@echo ${CI_JOB_NAME}
	@echo "############################################################################"
	@echo "#            Access the Skampi landing page here:"
	@echo "#            $(INGRESS_PROTOCOL)://$(INGRESS_HOST)/$(KUBE_NAMESPACE)/start/"
	@echo "#     NOTE: Above link will only work if you can reach $(INGRESS_HOST)"
	@echo "############################################################################"
	@if [[ -z "${LOADBALANCER_IP}" ]]; then \
		exit 0; \
	elif [[ $(shell curl -I -s -o /dev/null -I -w \'%{http_code}\' http$(S)://$(LOADBALANCER_IP)/$(KUBE_NAMESPACE)/start/) != '200' ]]; then \
		echo "ERROR: http://$(LOADBALANCER_IP)/$(KUBE_NAMESPACE)/start/ unreachable"; \
		exit 10; \
	fi
