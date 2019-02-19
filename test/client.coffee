client = require 'mqtt'
  .connect process.env.MQTTURL,
    clientId: 'mqttjs_persistence'
    username: process.env.MQTTUSER
    clean: false
  .on 'connect', ->
    console.log "mqtt connected"
    client.subscribe process.env.MQTTTOPIC, qos: 2
  .on 'message', (topic, msg) ->
    console.log "#{topic}: #{msg}"
  .on 'error', console.error
