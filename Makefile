
PROJECT = ska-mid-psi

# KUBE_NAMESPACE defines the Kubernetes Namespace that will be deployed to
# using Helm.  If this does not already exist it will be created
KUBE_NAMESPACE ?= ska-mid-psi
KUBE_NAMESPACE_SDP ?= $(KUBE_NAMESPACE)-sdp
CI_PIPELINE_ID ?= unknown
ODA_DB_NS ?= oda-db

# UMBRELLA_CHART_PATH Path of the umbrella chart to work with
HELM_CHARTS ?= ska-mid-psi/ ska-mid-psi-dish-lmc/
HELM_CHART ?= ska-mid-psi/ ska-mid-psi-dish-lmc/
DISH_LMC_CHART ?= ska-mid-psi-dish-lmc
UMBRELLA_CHART_PATH ?= ./charts/ska-mid-psi/
LMC_CHART_PATH ?= ./charts/ska-mid-psi-dish-lmc/
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
ARCHIVING_ENABLED ?= false ## Set to true to deploy EDA

#  Arguments for ODA services. Currently targets a ODA deployed within the same namespace
OET_URL ?= $(INGRESS_PROTOCOL)://142.73.34.170/$(KUBE_NAMESPACE)/oet/api/v8
ODA_URL ?= $(INGRESS_PROTOCOL)://142.73.34.170/$(ODA_DB_NS)/oda/api/v8
SLT_SERVICES_URL ?= $(INGRESS_PROTOCOL)://142.73.34.170/$(KUBE_NAMESPACE)/slt/api/v0
PTT_SERVICES_URL ?= $(INGRESS_PROTOCOL)://142.73.34.170/$(KUBE_NAMESPACE)/ptt/api/v0

# Chart for testing
K8S_CHART ?= $(HELM_CHART)
K8S_CHARTS ?= $(K8S_CHART)
DISH_ID ?= ska001

DISH_LMC_ENABLED ?= true
SPFRX_ENABLED ?= false

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

TARANTA_PARAMS = --set ska-taranta.enabled=$(TARANTA) \
				 --set global.taranta_auth_enabled=$(TARANTA_AUTH) \
				 --set global.taranta_dashboard_enabled=$(TARANTA)

DISH_PARAMS = --set global.dishes=001 \
			  --set global.dish_id=$(DISH_ID) \
			  --set ska-dish-lmc.ska-mid-dish-manager.dishmanager.spfrx.fqdn=$(TANGO_HOST)/ska001/spfrxpu/controller \
			  --set ska-tmc-mid.global.namespace_dish.dish_names[0]=$(TANGO_HOSTNAME).$(KUBE_NAMESPACE).svc.$(CLUSTER_DOMAIN)/mid-dish/dish-manager/SKA001

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
	--set global.kafka_host=ska-mid-psi-kafka.$(KUBE_NAMESPACE) \
	--set ska-sdp.helmdeploy.namespace=$(KUBE_NAMESPACE_SDP) \
	--set ska-sdp.qa.zookeeper.clusterDomain=$(CLUSTER_DOMAIN) \
	--set kafka.clusterDomain=$(CLUSTER_DOMAIN) \
	--set ska-sdp.qa.redis.clusterDomain=$(CLUSTER_DOMAIN) \
	--set global.labels.app=$(KUBE_APP) \
	--set ska-dish-lmc.enabled=$(DISH_LMC_ENABLED) \
	--set ska-pst.enabled=$(PST_ENABLED) \
	--set global.tangodb_fqdn=$(TANGO_HOSTNAME).$(KUBE_NAMESPACE).svc.$(CLUSTER_DOMAIN) \
	--set global.tango_host=$(TANGO_HOST) \
	--set global.tangodb_port=10000 \
	--set ska-oso-integration.ska-oso-oet-ui.backendURLOET=$(OET_URL) \
 	--set ska-oso-integration.ska-oso-oet-ui.backendURLODA=$(ODA_URL) \
	--set ska-oso-integration.ska-oso-ptt.backendURL=$(PTT_SERVICES_URL) \
	--set ska-oso-integration.ska-oso-slt-ui.backendURL=$(SLT_SERVICES_URL) \
	--set ska-oso-integration.ska-oso-services.rest.oda.postgres.host=psi-oda-db-postgresql.$(ODA_DB_NS) \
	$(TARANTA_PARAMS)

ifeq ($(KUBE_NAMESPACE),ska-mid-psi-staging)
	K8S_CHART_PARAMS += --set ska-oso-integration.enabled=true 
endif

ifeq ($(ARCHIVING_ENABLED),true)
	include archiver/archiver.mk
	K8S_CHART_PARAMS += $(SKA_TANGO_ARCHIVER_PARAMS)
endif

ifneq (,$(wildcard $(VALUES)))
	K8S_CHART_PARAMS += $(foreach f,$(wildcard $(VALUES)),--values $(f))
endif

ifeq ($(DISH_LMC_ENABLED),true)
	ifeq ($(SPFRX_ENABLED),true)
		K8S_CHART_PARAMS += --set spfrx.enabled=true \
							$(DISH_PARAMS) \
							-f charts/ska-mid-psi/tmc-1-dish-lmc-values.yaml
	else ifeq ($(SPFRX_ENABLED),false)
		K8S_CHART_PARAMS += --set spfrx.enabled=false --set ska-dish-lmc.ska-mid-dish-simulators.deviceServers.spfrxdevice.enabled=true -f charts/ska-mid-psi/tmc-4-dish-lmc-values.yaml
	endif
else ifeq ($(DISH_LMC_ENABLED),false)
	K8S_CHART_PARAMS += --set spfrx.enabled=false -f charts/ska-mid-psi/tmc-mock-values.yaml
endif

PYTHON_VARS_AFTER_PYTEST = -s --cucumberjson=build/reports/cucumber.json --json-report --json-report-file=build/reports/report.json --namespace $(KUBE_NAMESPACE) -v -rpfs 

ARCHIVE_CONFIG ?= "archiver/mid-telescope.yaml" # can override the default config file for archiving
eda-add-attributes:
	@. archiver/configure.sh -n $(KUBE_NAMESPACE) -a add_update -f $(ARCHIVE_CONFIG) 

eda-get-attributes:
	@. archiver/configure.sh -n $(KUBE_NAMESPACE) -a get

eda-remove-attributes:
	@. archiver/configure.sh -n $(KUBE_NAMESPACE) -a remove -f $(ARCHIVE_CONFIG)

k8s-pre-install-chart:
	@echo "k8s-pre-install-chart: creating the SDP namespace $(KUBE_NAMESPACE_SDP)"
	@make k8s-namespace KUBE_NAMESPACE=$(KUBE_NAMESPACE_SDP)
	@make k8s-namespace KUBE_NAMESPACE=$(KUBE_NAMESPACE)
	
k8s-pre-install-chart-car:
	@echo "k8s-pre-install-chart-car: creating the SDP namespace $(KUBE_NAMESPACE_SDP)"
	@make k8s-namespace KUBE_NAMESPACE=$(KUBE_NAMESPACE_SDP)

k8s-pre-uninstall-chart:
	@echo "k8s-post-uninstall-chart: deleting the SDP namespace $(KUBE_NAMESPACE_SDP)"
	@if [ "$(KEEP_NAMESPACE)" != "true" ]; then make k8s-delete-namespace KUBE_NAMESPACE=$(KUBE_NAMESPACE_SDP); fi
	
k8s-do-install-chart:
	@echo "----------------------------------------------"
	@echo "k8s-do-install-chart: starting Dish LMC first".
	@echo "Installing $(LMC_CHART_PATH) into $(KUBE_NAMESPACE)"
	helm upgrade --install $(HELM_RELEASE) \
	$(K8S_CHART_PARAMS) \
	$(LMC_CHART_PATH) --namespace $(KUBE_NAMESPACE)
	@echo "Waiting for pods to start running..."
	@echo "Getting resources"
	@make k8s-wait HELM_RELEASE=$(HELM_RELEASE) KUBE_NAMESPACE=$(KUBE_NAMESPACE)
	@echo "Done installing Dish LMC chart"
	@echo "----------------------------------------------"
	@echo "k8s-do-install-chart: Installing umbrella chart".
	@echo "Installing $(UMBRELLA_CHART_PATH) into $(KUBE_NAMESPACE)"
	helm upgrade --install $(HELM_RELEASE) \
	$(K8S_CHART_PARAMS) \
	$(UMBRELLA_CHART_PATH) --namespace $(KUBE_NAMESPACE)
	@echo "Waiting for rest of the pods to start running..."
	@echo "Getting resources"

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
