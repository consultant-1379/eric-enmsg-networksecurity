ARG ERIC_ENM_SLES_EAP7_IMAGE_NAME=eric-enm-sles-eap7
ARG ERIC_ENM_SLES_EAP7_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-enm
ARG ERIC_ENM_SLES_EAP7_IMAGE_TAG=1.64.0-32

FROM ${ERIC_ENM_SLES_EAP7_IMAGE_REPO}/${ERIC_ENM_SLES_EAP7_IMAGE_NAME}:${ERIC_ENM_SLES_EAP7_IMAGE_TAG}

ARG BUILD_DATE=unspecified
ARG IMAGE_BUILD_VERSION=unspecified
ARG GIT_COMMIT=unspecified
ARG ISO_VERSION=unspecified
ARG RSTATE=unspecified
ARG SGUSER=270421

LABEL \
com.ericsson.product-number="CXC Placeholder" \
com.ericsson.product-revision=$RSTATE \
enm_iso_version=$ISO_VERSION \
org.label-schema.name="ENM networksecurity Service Group" \
org.label-schema.build-date=$BUILD_DATE \
org.label-schema.vcs-ref=$GIT_COMMIT \
org.label-schema.vendor="Ericsson" \
org.label-schema.version=$IMAGE_BUILD_VERSION \
org.label-schema.schema-version="1.0.0-rc1"

ARG RM=/bin/rm

RUN zypper install -y ERICserviceframework4_CXP9037454 \
    ERICserviceframeworkmodule4_CXP9037453 \
    ERICmodelserviceapi_CXP9030594 \
    ERICmodelservice_CXP9030595 \
    ERICpib2_CXP9037459 \
    ERICddc_CXP9030294 \
    ERICcryptographyservice_CXP9031013 \
    ERICcryptographyserviceapi_CXP9031014 \
    ERICdpsruntimeimpl_CXP9030468 \
    ERICdpsmediationclient2_CXP9038436 \
    ERICdpsruntimeapi_CXP9030469 \
    ERICpostgresqljdbc_CXP9031176 \
    ERICpostgresutils_CXP9038493 \
    ERICmediationengineapi2_CXP9038435 \
    ERICvaultloginmodule_CXP9036201 && \
    zypper download ERICnpamservice_CXP9043009 ERICenmsgnetworksecurity_CXP9043001 && \
    rpm -ivh --replacefiles /var/cache/zypp/packages/enm_iso_repo/ERICnpamservice_CXP9043009*.rpm --nodeps --noscripts && \
    rpm -ivh --replacefiles /var/cache/zypp/packages/enm_iso_repo/ERICenmsgnetworksecurity_CXP9043001*.rpm --nodeps --noscripts && \
    zypper clean -a

# Deleted uneccessary files no longer needed on cENM
RUN $RM /ericsson/3pp/jboss/bin/post-start/update_management_credential_permissions.sh \
       /ericsson/3pp/jboss/bin/post-start/update_standalone_permissions.sh && \
    echo "$SGUSER:x:$SGUSER:$SGUSER:An Identity for netsecserv:/nonexistent:/bin/false" >>/etc/passwd && \
    echo "$SGUSER:!::0:::::" >>/etc/shadow

ENV ENM_JBOSS_SDK_CLUSTER_ID="netsecserv" \
    ENM_JBOSS_BIND_ADDRESS="0.0.0.0" \
    GLOBAL_CONFIG="/gp/global.properties" \
    CLOUD_DEPLOYMENT=TRUE \
    JBOSS_CONF="/ericsson/3pp/jboss/app-server.conf"

EXPOSE 4447 8009 8080 8443 9990 9999

USER $SGUSER
