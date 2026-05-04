#!/bin/bash
sleep 20
docker service ls
docker network inspect app_app-network | grep -A 20 Peers
docker run --rm --network app_app-network curlimages/curl:latest -sm3 http://backend:3000/health 2>&1
