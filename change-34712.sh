#!/bin/bash
#
~gchen1/scripts/repeat_jmx_call.sh ini 'HtmlAdaptor?action=invokeOpByName&amp;name=Gen3-sh-ecomm-ears-integrationsvcear%3Aname%3DCentralizedMbean&amp;methodName=setProperty&amp;argType=java.lang.String&amp;arg0=barcode2D.enable.26.postfix.string&amp;argType=java.lang.String&amp;arg1=' OK
#
~gchen1/scripts/repeat_jmx_call.sh stj 'HtmlAdaptor?action=invokeOpByName&name=Gen3-sh-ecomm-ears-cstoolear%3Aname%3DCentralizedMbean&methodName=setProperty&argType=java.lang.String&arg0=barcode2D.enable.26.postfix.string&argType=java.lang.String&arg1=' OK
#
~gchen1/scripts/repeat_jmx_call.sh myx 'HtmlAdaptor?action=invokeOpByName&name=Gen3-sh-ecomm-ears-myxbigear%3Aname%3DCentralizedMbean&methodName=setProperty&argType=java.lang.String&arg0=barcode2D.enable.26.postfix.string&argType=java.lang.String&arg1=' OK
echo
echo 'All Done!'
