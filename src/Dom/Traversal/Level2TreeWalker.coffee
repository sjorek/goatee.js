###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>
© Copyright 2006 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
###

{Document}           = require 'goatee/Dom/Document'
{Level2NodeIterator} = require 'goatee/Dom/Visitor/Level2NodeIterator'

root = exports ? this

#### Level2TreeWalker

# A class to hold state for a dom traversal.
#
# @class
# @namespace goatee
root.Level2TreeWalker = \
class Level2TreeWalker extends Level2NodeIterator

  ##
  # Create TreeWalker instance for a single root node.
  #
  # @param {Node} root  The root node of the traversal.
  # @return {TreeWalker}
  prepare: (root) ->
    doc.ownerDocument(root).createTreeWalker(
      # Node to use as root
      root,

      # Only consider nodes that match this filter
      @filter,

      # Object containing the function to use as method of the NodeFilter
      @options,

      false
    )

Level2TreeWalker.create = (callback) ->
  new Level2TreeWalker callback
