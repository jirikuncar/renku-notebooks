#!/bin/env bash
#
# Copyright 2018 - Swiss Data Science Center (SDSC)
# A partnership between École Polytechnique Fédérale de Lausanne (EPFL) and
# Eidgenössische Technische Hochschule Zürich (ETHZ).
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

set -e

# generate ssh key to use for docker hub login
openssl aes-256-cbc -K "${encrypted_e84d0b1b700e_key}" -iv "${encrypted_e84d0b1b700e_iv}" -in secrets.tar.enc -out secrets.tar -d
tar xvf secrets.tar

chmod 600 secrets/sdsc-key
eval $(ssh-agent -s)
ssh-add secrets/sdsc-key

cat secrets/docker-password | docker login -u="${DOCKER_USERNAME}" --password-stdin ${DOCKER_REGISTRY}

# build charts/images and push
cd helm-chart
chartpress --push --publish-chart
git diff
# push also images tagged with "latest"
chartpress --tag latest --push
cd ..
