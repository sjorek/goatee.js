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
  var Document, Level2NodeIterator, Level2TreeWalker, root, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Document = require('goatee/Dom/Document').Document;

  Level2NodeIterator = require('goatee/Dom/Visitor/Level2NodeIterator').Level2NodeIterator;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.Level2TreeWalker = Level2TreeWalker = (function(_super) {
    __extends(Level2TreeWalker, _super);

    function Level2TreeWalker() {
      _ref = Level2TreeWalker.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Level2TreeWalker.prototype.prepare = function(root) {
      return doc.ownerDocument(root).createTreeWalker(root, this.filter, this.options, false);
    };

    return Level2TreeWalker;

  })(Level2NodeIterator);

  Level2TreeWalker.create = function(callback) {
    return new Level2TreeWalker(callback);
  };

}).call(this);