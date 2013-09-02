###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
###

{Constants} = require 'goatee/Core/Constants'
{Utility}   = require 'goatee/Core/Utility'
{Document}  = require 'goatee/Dom/Document'

exports = module?.exports ? this

## Processor
# Internal class used by goatee-templates to maintain context.  This is
# necessary to process deep templates in Safari which has a
# relatively shallow maximum recursion depth of 100.
# @class
# @namespace goatee.Action.Engine
exports.ElementAttribute = class ElementAttribute extends Processor
