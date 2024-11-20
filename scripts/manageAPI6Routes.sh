ADMINTOKEN=$(kSecret-show -f admin-token -n apisix plane-api -v)
IP_APISIXCONTROL=$(kGet -a svc control- -o yaml -v -n apisix | yq eval '.spec.clusterIP' -)

ROUTE_DEMO_JSON='{
  "name": "hello",
  "uri": "/hello",
  "host": "fiwaredsc-consumer.local",
  "methods": ["GET"],
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "echo-svc:8080": 1
    }
  },
  "plugins": {
      "proxy-rewrite": {
          "uri": "/"
      }
  }
}'

ROUTE_API6DASHBOARD_JSON='{
  "name": "api6Dashboard",
  "uri": "/*",
  "host": "fiwaredsc-api6dashboard.local",
  "methods": ["GET", "POST", "PUT", 
              "HEAD", "CONNECT", "OPTIONS",
              "PATCH", "DELETE" ],
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "apisix-dashboard:80": 1
    }
  }
}'


ROUTE_TIR_JSON='{
  "name": "TIR",
  "uri": "/*",
  "host": "fiwaredsc-trustanchor.local",
  "methods": ["GET", "POST", "PUT" ],
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "tir.trust-anchor.svc.cluster.local:8080": 1
    }
  }
}'

# https://fiwaredsc-consumer.ita.es/.well-known/did.json
ROUTE_DID_WEB_fiwaredsc_consumer_ita_es='{
  "uri": "/.well-known/did.json",
  "name": "Did.web"
  "host": "fiwaredsc-consumer.ita.es",
  "methods": ["GET"],
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "did.consumer.svc.cluster.local:3000": 1
    }
  },
  "plugins": {
      "proxy-rewrite": {
          "uri": "/did-material/did.json"
      }
  }
}'

# https://fiwaredsc-consumer.ita.es/
ROUTE_CONSUMER_KEYCLOAK_fiwaredsc_consumer_ita_es='{
  "uri": "/*",
  "name": "consumer",
  "host": "fiwaredsc-consumer.ita.es",
  "methods": ["GET", "POST", "PUT", "HEAD", "CONNECT", "OPTIONS", "PATCH", "DELETE"],
  "upstream": {
    "type": "roundrobin",
    "scheme": "https",
    "nodes": {
      "consumer-keycloak.consumer.svc.cluster.local:443": 1
    }
  }
}'

# https://fiwaredsc-wallet.ita.es/
ROUTE_WALLET_fiwaredsc_wallet_ita_es='{
  "uri": "/*",
  "name": "Wallet",
  "methods": [
    "GET",
    "POST",
    "PUT",
    "HEAD",
    "CONNECT",
    "OPTIONS",
    "PATCH",
    "DELETE"
  ],
  "host": "fiwaredsc-wallet.ita.es",
  "upstream": {
    "nodes": [
      {
        "host": "wallet.consumer.svc.cluster.local",
        "port": 3000,
        "weight": 1
      }
    ],
    "timeout": {
      "connect": 6,
      "send": 6,
      "read": 6
    },
    "type": "roundrobin",
    "scheme": "http",
    "pass_host": "pass",
    "keepalive_pool": {
      "idle_timeout": 60,
      "requests": 1000,
      "size": 320
    }
  },
  "status": 1
}' 

# https://fiwaredsc-provider.ita.es/ngsi-ld/
ROUTE_PROVIDER_SERVICE_fiwaredsc_provider_ita_es='{
  "uri": "/ngsi-ld/*",
  "name": "service",
  "host": "fiwaredsc-provider.ita.es",
  "methods": ["GET", "POST", "PUT", "HEAD", "CONNECT", "OPTIONS", "PATCH", "DELETE"],
  "upstream": {
    "type": "roundrobin",
    "scheme": "http",
    "nodes": {
      "ds-scorpio.service.svc.cluster.local:9090": 1
    }
  },
  "plugins": {
    "proxy-rewrite": {
        "regex_uri": ["^/ngsi-ld/(.*)", "/ngsi-ld/$1"]
    }
  }
}'

## management area
# curl -i -X POST -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes -H "X-API-KEY:$ADMINTOKEN" \
# -d "$ROUTE_PROVIDER_SERVICE_fiwaredsc_provider_ita_es"
# curl -i -X POST -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes -H "X-API-KEY:$ADMINTOKEN" \
# -d "$ROUTE_WALLET_fiwaredsc_wallet_ita_es"# curl -i -X POST -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes -H "X-API-KEY:$ADMINTOKEN" \
# -d "$ROUTE_CONSUMER_KEYCLOAK_fiwaredsc_consumer_ita_es"
# curl -i -X POST -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes -H "X-API-KEY:$ADMINTOKEN" \
# -d "$ROUTE_DID_WEB_fiwaredsc_consumer_ita_es"
# curl -i -X POST -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes -H "X-API-KEY:$ADMINTOKEN" \
# -d "$ROUTE_TIR_JSON"
# curl -i -X POST -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes -H "X-API-KEY:$ADMINTOKEN" \
# -d "$ROUTE_API6DASHBOARD_JSON"
# Output similar to: {"key":"/apisix/routes/00000000000000000077","value":{"create_time":1731400093,
#                     "upstream":{"nodes":{"echo-svc:8080":1},"pass_host":"pass","type":"roundrobin",
#                     "hash_on":"vars","scheme":"http"},"status":1,"methods":["GET"],
#                     "uri":"/hello","host":"fiwaredsc-consumer.local",
#                     "plugins":{"proxy-rewrite":{"uri":"/","use_real_request_uri_unsafe":false}},
#                     "update_time":1731400093,"id":"00000000000000000077","priority":0}}

# Test new route
# curl -k https://fiwaredsc-consumer.local/hello

# Fix the route
curl -i -X PUT -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes/00000000000000000269 \
    -H "X-API-KEY:$ADMINTOKEN" \
    -d "$ROUTE_PROVIDER_SERVICE_fiwaredsc_provider_ita_es"

# Get routes
# curl -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes -H "X-API-KEY:$ADMINTOKEN"

# Detele a route
# curl -i -X DELETE -k -H "X-API-KEY:$ADMINTOKEN" https://$IP_APISIXCONTROL:9180/apisix/admin/routes/00000000000000000244
