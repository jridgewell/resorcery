#!/bin/bash
#
# Copyright 2019 Google LLC
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

DIR="$(dirname $0)"
NODE_BIN=`npm bin`

rm "$DIR"/files/*.js*

if [ ! -f "$NODE_BIN/babel" ]; then
  npm install --no-save @babel/cli @babel/preset-env
fi
"$NODE_BIN/babel" "$DIR/files" --config-file "./$DIR/babel.config.js" --source-maps -d "$DIR/files"

# Strip the sourceMappingURL to prevent rollup from auto collapsing sourcemaps
for f in $DIR/files/*.js; do
  sed '$d' $f > $f.tmp
  mv $f.tmp $f
done

npx rollup -i "$DIR/files/index.js" -f cjs -o "$DIR/files/bundle.js" --sourcemap
npx prettier "$DIR/files/*.map" --parser json --write
