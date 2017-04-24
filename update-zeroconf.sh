#!/bin/bash

# Copyright (c) 2015 naymspace software (Dennis Nissen)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -f platforms/android/libs/jmdns.jar ]
	then
	rm platforms/android/libs/jmdns.jar
fi
cd platforms/android/CordovaLib
mkdir libs
cd libs
if [ -f jmdns.jar ]
	then
	rm jmdns.jar
fi
wget -N http://downloads.sourceforge.net/project/jmdns/jmdns/JmDNS%203.4.1/jmdns-3.4.1.tgz
tar xvfz jmdns-3.4.1.tgz lib/jmdns.jar
mkdir unjar
cd unjar
jar xf ../lib/jmdns.jar
jar cfm jmdns.jar META-INF/MANIFEST.MF javax/*
cd ../
mv unjar/jmdns.jar ../../libs
rm -r lib
rm -r unjar
rm jmdns-3.4.1.tgz
