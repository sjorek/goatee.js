###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>  
© Copyright 2006 Google Inc. <http://www.google.com>

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

# ~require
{Constants:{
  GLOB_default,
  VAR_context,
  VAR_count,
  VAR_index,
  VAR_this,
  VAR_top,
  STRING_empty
}}              = require '../Core/Constants'

Expression      = require('./Expression/Javascript').Javascript

# ~export
exports = module?.exports ? this

# Context
# ================================

# --------------------------------
# Context for processing a goatee-template. The context contains a context
# object, whose properties can be referred to in goatee-template expressions,
# and it holds the locally defined variables.
#
# @public
# @class      Context
# @namespace  goatee.Action
exports.Context = class Context

  # --------------------------------
  # Holds this context's local variables
  #
  # @private
  # @property _variables
  # @type     {Object.<Mixed>}
  _variables : {}

  # --------------------------------
  # Holds this context's data
  #
  # @private
  # @property _data
  # @type     {Mixed}
  _data      : null

  # --------------------------------
  # Constructs the `Context`.
  #
  # @param  {Object}  [data=null]     The context object.  Null if no context
  #                                   has been given.
  # @param  {Context} [parent=null]   The parent context, from which local
  #                                   variables are inherited.  Normally the
  #                                   context object of the parent context is
  #                                   the object whose property the parent
  #                                   object is.   Null if no parent has been
  #                                   given, ie. when creating the root-context.
  # @constructor
  constructor: (data, parent) ->

    # If there is a parent node, inherit local variables from the parent. If a
    # root node, inherit global symbols.  Since every parent chain has a root
    # with no parent, global variables will be present in the case above too.
    # This means that globals can be overridden by locals, as it should be.
    variables = if parent? then parent._variables else Context._globals
    for own name, value of variables
      @_variables[name] = value

    # The current context object is assigned to the special variable
    # $this so it is possible to use it in expressions.
    @_variables[VAR_this] = data

    # The entire context structure is exposed as a variable so it can be
    # passed to javascript invocations through the execute action.
    @_variables[VAR_context] = this

    # The local context of the input data in which the goatee-template
    # expressions are evaluated. Notice that this is usually an Object, but it
    # can also be a scalar value (and then still the expression `$this` can be
    # used to refer to it).  Notice this can be any value, `undefined` or
    # `null`.  Hence, we have to protect `do` (formerly `jsexec()`) from using
    # `undefined` or `null`, yet we want `$this` to reflect the true value of
    # the current context.  Thus we assign the original value to `$this`, above,
    # but for the expression context we replace `null` and `undefined` by the
    # empty string (which is the default value).
    #
    # (Note sjorek: `undefined` isn't checked here on purpose,
    #  see <https://github.com/jashkenas/coffee-script/issues/993>)
    @_data = data ? STRING_empty

    # If this is a top-level context, create a variable reference to the data
    # to allow for  accessing top-level properties of the original context data
    # from child contexts.
    @_variables[VAR_top] = @_data unless parent?

  # --------------------------------
  # Executes a function created using evalToFunction() in the context of
  # variables, data, and template.
  #
  # @public
  # @method execute
  # @param  {Function}    fn         A function created from an action value
  # @param  {Node}        template   DOM node of the template
  # @return {Object|null} The value of the expression from which expression was
  #                       created in the current expression's context and the
  #                       context of template.
  execute: (fn, template) ->
    try
      return fn.call(template, this._variables, this._data);
    catch e
      console.log "Exception #{e} while executing #{fn} on #{template}"
    return Context._globals[GLOB_default]

  # --------------------------------
  # Clones the current context for a new context object.  The cloned context has
  # the data object as its context object and the current context as its parent
  # context.  It also sets the `$index` variable to the given value.  This value
  # usually is the position of the data object in a list for which a template is
  # instantiated multiply.
  #
  # @public
  # @method clone
  # @param  {Object}  data    The new context object
  # @param  {Number}  index   Position of the new context when multiple are
  #                           instantiated
  # @param  {Number}  count   The total number of contexts that were multiple
  #                           are instantiated
  # @return {goatee.Action.Context}
  # @see `goatee.Action.Outer.Repeat`
  clone: (data, index, count) ->
    ret = Context.create data, this
    ret.set VAR_index, index
    ret.set VAR_count, count
    return ret

  # --------------------------------
  # Binds a local variable to the given value.  If set from an `alter` action
  # (formerly `jsvalues`) expressions, variable names must start with `$`, but
  # depending on the API, they might only have to be valid <del>JavaScript</del>
  # GoateeScript identifier.
  #
  # @public
  # @method set
  # @param  {String}  name
  # @param  {Mixed}   value
  set: (name, value) ->
    @_variables[name] = value
    return

  # --------------------------------
  # Returns the value bound to the local variable of the given name, or
  # `undefined` if it wasn't set.  There is no way to distinguish a variable
  # that wasn't set from a variable that was set to `undefined`.  Used mostly
  # for testing.
  #
  # @public
  # @method get
  # @param  {String}  name
  # @return {Mixed}   value
  get: (name) ->
    @_variables[name]

  # --------------------------------
  # Holds a reference to a compiler singleton instance's evaluation function.
  # Notice, this value will also be referenced once when loading this script,
  # therefore changing this value won't have any effect here.
  #
  # @static
  # @public
  # @property compile
  # @type     {Function}
  @compile: _compile = Expression.get().evaluateToFunction

  # --------------------------------
  # Evaluates a string expression within the scope of this context and returns
  # the result.
  #
  # @public
  # @method evaluate
  # @param  {String}  expression  <del>JavaScript</del>GoateeScript expression
  # @param  {Node}    [template]  An optional node to serve as `this`
  # @return {Mixed}   value
  evaluate: (expression, template) ->
    @execute _compile(expression), template

  # --------------------------------
  # Holds all global context variables
  #
  # @static
  # @private
  # @property _globals
  # @type     {Object.<Mixed>}
  @_globals: {}

  # --------------------------------
  # Sets a global symbol.  It will be available like a variable in every Context
  # instance.  This is intended mainly to register immutable global objects,
  # such as functions, at load time, and not to add global data at runtime. I.e.
  # the same objections as to global variables in general apply also here.
  # (Hence the name `global`, and not `global var`.)
  #
  # @static
  # @public
  # @method setGlobal
  # @param  {String}  name
  # @param  {Mixed}   value
  @setGlobal: (name, value) ->
    Context._globals[name] = value

  # Set the default value to be returned if context evaluation results in an
  # error.  This can occur if an `Exception` raises, ie. when requesting
  # non-existent values 
  Context.setGlobal GLOB_default, null

  # --------------------------------
  # A cache to reuse `Context` instances, performance wise.
  #
  # @static
  # @private
  # @property _recycled
  # @type     {Array.<goatee.Action.Context>}
  @_recycled: []

  # --------------------------------
  # A factory to create a `Context` instance, possibly reusing one from
  # `Context._recycled` to increase performance.
  #
  # @static
  # @public
  # @method create
  # @param  {Object}                [data]
  # @param  {goatee.Action.Context} [parent]
  # @return {goatee.Action.Context}
  @create: (data, parent) ->
    return new Context data, parent if Context._recycled.length is 0
    instance = Context._recycle.pop()
    Context.call instance, data, parent
    return instance

  # --------------------------------
  # Recycle a used `Context` instance, so we can avoid creating one the next
  # time we need one.  Should increase performance.
  #
  # @static
  # @public
  # @method recyle
  # @param  {goatee.Action.Context} instance
  @recycle: (instance) ->
    for own name of instance._variables
      # NOTE(mesch): We avoid object creation here. (IE performance)
      delete instance._variables[name]
    instance._data = null
    Context._recycled.push instance
    return
