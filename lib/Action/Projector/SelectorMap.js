// Generated by CoffeeScript 1.7.1

/*
© Copyright 2013-2014 Stephan Jorek <stephan.jorek@gmail.com>  

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
 */

(function() {
  var Emitter, Processor, SelectorMap, exports, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Processor = require('goatee/Action/Processor').Processor;

  Emitter = require('goatee/Action/Emitter/DomEvents').DomEvents;

  exports = (_ref = typeof module !== "undefined" && module !== null ? module.exports : void 0) != null ? _ref : this;

  exports.SelectorMap = SelectorMap = (function(_super) {
    var _emitter;

    __extends(SelectorMap, _super);

    function SelectorMap() {
      return SelectorMap.__super__.constructor.apply(this, arguments);
    }

    _emitter = null;

    SelectorMap.prototype.collect = function(node) {
      return (_emitter != null ? _emitter : _emitter = Emitter.create(this)).collect(node);
    };

    return SelectorMap;

  })(Processor);

}).call(this);

//# sourceMappingURL=SelectorMap.map
