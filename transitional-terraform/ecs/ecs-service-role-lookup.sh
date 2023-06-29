#!/bin/bash
set -e
eval "$(aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com > /dev/null 2>&1)"
jq -n '{"create":"true"}'
