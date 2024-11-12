ADMINTOKEN=$(kSecret-show -f admin-token plane-api -v)
IP_APISIXCONTROL=$(kGet -a svc control- -o yaml -v  | yq eval '.spec.clusterIP' -)


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


curl -i -X POST -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes -H "X-API-KEY:$ADMINTOKEN" \
-d "$ROUTE_DEMO_JSON"
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
# curl -i -X PUT -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes/00000000000000000033 \
#     -H "X-API-KEY:$ADMINTOKEN" \
#     -d "$ROUTE_DEMO_JSON"

# Get routes
curl -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes -H "X-API-KEY:$ADMINTOKEN"

# Detele a route
# curl -i -X DELETE -k -H "X-API-KEY:$ADMINTOKEN" https://$IP_APISIXCONTROL:9180/apisix/admin/routes/00000000000000000033
