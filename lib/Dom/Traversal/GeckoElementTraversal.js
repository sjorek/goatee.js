// Generated by CoffeeScript 1.6.3
/*
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
*/


(function() {
  var GeckoElementTraversal, Level1NodeTypeMatcher, root, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Level1NodeTypeMatcher = require('goatee/Dom/Traversal/Level1NodeTypeMatcher').Level1NodeTypeMatcher;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.GeckoElementTraversal = GeckoElementTraversal = (function(_super) {
    __extends(GeckoElementTraversal, _super);

    function GeckoElementTraversal() {
      _ref = GeckoElementTraversal.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    GeckoElementTraversal.prototype.collect = function(node) {
      var result;
      result = [];
      for (var child = node.firstElementChild; child; child = child.nextElementSibling) {
        result.push(child);
      };
      return result;
    };

    return GeckoElementTraversal;

  })(Level1NodeTypeMatcher);

  GeckoElementTraversal.create = function(callback) {
    return new GeckoElementTraversal(callback);
  };

}).call(this);