#!/bin/sh

# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# These steps must be executed once the host /var and /lib volumes have
# been mounted, and therefore cannot be done in the docker build stage.

# For systems without journald
mkdir -p /var/log/journal

# Copy host libsystemd into image to avoid compatibility issues.
if [ ! -z "$(ls /host/lib/libsystemd* 2>/dev/null)" ]; then
  rm /lib/x86_64-linux-gnu/libsystemd*
  cp -a /host/lib/libsystemd* /lib/x86_64-linux-gnu/
fi

# App credentials
#
# TODO: Check if env var present
#
# @see https://cloud.google.com/logging/docs/agent/authorization
if [ ! -z ${GOOGLE_APPLICATION_CREDENTIALS+x} ]; then
  mkdir -p /etc/google/auth
  echo $GOOGLE_APPLICATION_CREDENTIALS > \
    /etc/google/auth/application_default_credentials.json
  chown root:root /etc/google/auth/application_default_credentials.json
  chmod 0400 /etc/google/auth/application_default_credentials.json
fi

/usr/local/bin/fluentd $@
