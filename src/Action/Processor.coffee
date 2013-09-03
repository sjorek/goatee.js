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

###

Gaotee Evaluation
===================

> Overview
> -------------------
> The processing instructions that define the results of Processor for a
  template are encoded as attributes in template HTML elements.  There are
  <del>eight such</del> special attributes: *jsselect*, *jsdisplay*, *jsskip*,
  *jscontent*, *jsvars*, *jsvalues*, *jseval*, and *transclude*.  Before you
  dive into the details of individual instructions, however, you should know a
  little bit about the namespace within which these instructions are processed.

> Processing Environment
> -------------------
> With the single exception of the *transclude* instruction, the values of all
  Template attributes will contain <del>javascript</del> expressions.  These
  will be evaluated in an environment that includes bindings from a variety of
  sources, and names defined by any of these sources can be referenced in
  attribute expressions as if they were variables:
>
> - *Context* data: All the properties of the *Context*'s data object are included
    in the processing environment.
  - Explicitly declared variables: The `setVariable(name, value);` method of
    *Context* creates a new variable with the `name` in the processing
    environment if no such variable exists, assigning it the `value`. If the
    variable already exists, it will be reassigned the `value`.  Variables can
    also be created and assigned with the *jsvalues* instruction (see below).
>
>   Note that variables defined in either of these ways are distinct from the
    *Context* data object. Calling `setVariable` will not alter the data wrapped
    by the *Context* instance.  This fact can have important consequences when
    template processing is traversing the hierarchy of the data object (through
    the use of the *jsselect* instruction, for example -- see below): no matter
    what portion of the data hierarchy has been selected for processing, variables
    created with `setVariable` will always be available for use in template
    processing instructions.
> - Special variables: Jst also defines three special variables that can be used
    in processing instruction attributes:
>
>   - `this`: The keyword `this` in *Template* attribute expressions will
      evaluate to the element on which the attribute is defined.  In this
      respect *Template* attributes mirror event handler attributes like
      `onclick`.
>   - `$index`: Array-valued data can result in a duplicate template node being
      created for each array element (see *jsselect*, below).  In this case the
      processing environment for each of those nodes includes `$index` variable,
      which will contain the array index of the element associated with the node.
>   - `$this`: refers to the *Context* data object used in processing the current
      node.  So in the above example (TODO which example?!?) we could substitute
      `$this.end` for `end` without changing the meaning of the *jscontent*
      expression.  This may not seem like a very useful thing to do in this
      case, but there are other cases in which `$this` is necessary.  If the
      *Context* contains a value such as a string or a number rather than an
      object with named properties, there is no way to retrieve the value using
      object-property notation, and so we need `$this` to access the value.
>
> So if you have the template
>
>      <div id="witha">
>        <div id="Hey"
>             jscontent="this.parentNode.id +
>                        this.id +
>                        dataProperty +
>                        $this.dataProperty +
>                        declaredVar"
>        ><!-- empty content to be replaced --></div>
>      </div>
>
> and you process it with the statements
>
>      var mydata = {dataProperty: 'Nonny'};
>      var context = new JsEvalContext(mydata);
>      context.setVariable('declaredVar', 'Ho');
>      var template = document.getElementById('witha');
>      jstProcess(context, template);
>
> then the document will display the string `withaHeyNonnyNonnyHo`. The values
  of `id` and `parentNode.id` are available as properties of the current node
  (accessible through the keyword `this`), the value of `dataProperty` is
  available (via both a naked reference and the special variable `$this`)
  because it is defined in the *Context*'s data object, and the value of
  `declaredVar` is available because it is defined in the *Context*'s variables.
>
> In the discussion of specific instruction attributes below, the phrase
  *“current node”* refers to the DOM element on which the attribute is defined.

Goatee action attributes and event action names have been choosen
carefully in order to avoid naming collision with existing dom attributes,
events and properties.

Within a single element the actions are evaluated in the following order:

Outer Actions
-------------------

Outer actions operate with and on tag and context, without touching any tag-
attributes. They implement aspects like automation, recursion or multiplicity.

- **process** : This action initiates the processing automatically, after
                the dom is ready. The algorithm uses the given *process*-data
                as Context.  Additionally if “[jQuery](http://jquery.com)” is
                available and the given data is a string, *process* may be
                either an global javascript variable reference, or if that fails
                an url to an external json-file.  Changes to the process value,
                will stop any process processing the same tag and start
                re-processing.  The process will skip all nested tags which
                itself contain a *process*-Attribute, hence any of those tags
                will be processed automatically in the order of their
                appearance.

- **match**   : If “[json:select](http://jsonselect.org)” is available *match*
                value is used as css3-like query onto the current context.
                Therefore the context must be suiteable as 2nd argument of
                `JSONSelect.match(…)`.

- **render**  : Formerly “[transclude](http://code.google.com/p/google-jstemplate/wiki/TemplateProcessingInstructionReference)”.
                If a *render* action is present no further actions are
                processed.  Additionally if either “[jQuery](http://jquery.com)”,
                “[cheerio](http://matthewmueller.github.io/cheerio/)”, or
                “[Sizzle](http://sizzlejs.com)” is available, *render* may be an
                internal template-reference, like in:
                   `(cheerio||jQuery||Sizzle)( 'source #id .selector', this );`
                or in the case of *jQuery* an external reference, like in:
                   `jQuery(this).load( 'http://source.url #element-id' );`
                >
                > As *jsselect* does, the *transclude* instruction expands the
                  structure of a template.  It does so by copying a structure
                  from some other element in the document.  The value of the
                  *transclude* attribute is interpreted as an element id literal
                  rather than as a <del>javascript</del> expression. (This
                  difference, by the way, is the reason for the absence of a
                  “js” in its name.)
                >
                > If an element with the given id exists in the document, it is
                  cloned and **the clone replaces** the node with the *transclude*
                  attribute.  Template processing continues on the new element.
                  If no element with the given id exists, the node with the
                  *transclude* attribute is removed.  No further processing
                  instruction attributes will be evaluated on a node if it has
                  a *transclude* attribute.
                >
                > The *transclude* attribute allows for recursion, because a
                  template can be transcluded into itself.  This feature can be
                  handy when you want to display hierarchically structured data.
                  If you have a hierarchically structured table of contents, for
                  example, recursive *transclude* statements allow you represent
                  the arbitrarily complex hierarchy with a simple template:
                >
                >     <script>
                >        …
                >        // Hierarchical data:
                >        var tplData = {
                >          title: "JsTemplate",
                >          items: [ {
                >            title: "Using JsTemplate",
                >            items: [ {
                >              title: "The JsTemplate Module"
                >            }, {
                >              title: "Javascript Data"
                >            }, {
                >              title: "Template HTML"
                >            }, {
                >              title: "Processing Templates with Javascript Statements"
                >            } ]
                >          }, {
                >            title: "Template Processing Instructions",
                >            items: [ {
                >              title: "Processing Environment"
                >            }, {
                >              title: "Instruction Attributes",
                >              items: [ {
                >                title: "jscontent"
                >              }, {
                >                title: "jsselect"
                >              }, {
                >                title: "jsdisplay"
                >              }, {
                >                title: "transclude"
                >              }, {
                >                title: "jsvalues"
                >              }, {
                >                title: "jsskip"
                >              }, {
                >                title: "jseval"
                >              } ]
                >            } ]
                >          } ]
                >        };
                >        …
                >      </script>
                >      <div id="tpl">
                >        <span jscontent="title">Outline heading</span>
                >        <ul jsdisplay="items.length">
                >          <li jsselect="items">
                >            <div transclude="tpl"><!-- recursive tranclusion --></div>
                >          </li>
                >        </ul>
                >      </div>
                >
                > The recursion in this example terminates because eventually
                  it reaches data objects that have no `items` property.  When
                  the *jsselect* asks for `items` on one of these leaves, it
                  evaluates to `null` and no further processing will be
                  performed on that node.  Note also that when the node with a
                  *transclude* attribute is replaced with the transcluded node
                  in this example, the replacement node will not have a
                  *transclude* attribute.
                >
                > *“How to use JsTemplate”* described the use of the
                  `jstGetTemplate` function to process a copy of a template
                  rather than the original template.  Templates with recursive
                  transcludes must be cloned in this way before processing.
                  Because of the internal details of Jst processing, a template
                  that contains a recursive reference to itself may be processed
                  incorrectly if the original template is processed directly.
                  The following (incomplete) javascript code will perform the
                  required duplication for the above template:
                >
                >     <script>
                >       var PEG_NAME = 'peg';
                >       var TEMPLATE_NAME = 'tpl';
                >       // Called by the body onload handler:
                >       function jsinit() {
                >         pegElement = domGetElementById(document, PEG_NAME);
                >         loadData(pegElement, TEMPLATE_NAME, tplData);
                >       }
                >
                >       function loadData(peg, templateId, data) {
                >         // Get a copy of the template:
                >         var templateToProcess = jstGetTemplate(templateId);
                >         // Wrap our data in a context object:
                >         var processingContext = new JsEvalContext(data);
                >         // Process the template
                >         jstProcess(processingContext, templateToProcess);
                >         // Clear the element to which we'll attach the processed template:
                >         peg.innerHTML = '';
                >         // Attach the template:
                >         appendChild(peg, templateToProcess);
                >       }
                >     </script>
                >

- **repeat**  : Formerly “[jsselect](http://code.google.com/p/google-jstemplate/wiki/TemplateProcessingInstructionReference)”.
                If *repeat* is array-valued, remaining actions will be copied to
                each new duplicate element created by the *repeat* and processed
                when the further dom- traversal visits the new elements.
                >
                > The primary function of JsTemplate is to create mappings
                  between data structures and HTML representations of those data
                  structures.  The *jsselect* attribute handles much of the work
                  of defining this mapping by allowing you to associate a
                  particular subtree of the data with a particular subtree of
                  the template's DOM structure. When a template node with a
                  *jsselect* attribute is processed, the value of the *jsselect*
                  attribute is evaluated as a <del>javascript</del> expression
                  in the current processing environment, as described above.
                  If the result of this evaluation is not an array, the
                  processor automatically creates a new *Context* object to wrap
                  the result of the evaluation.  The processing environment for
                  the current node now uses this new *Context* rather than the
                  original *Context*.
                >
                > For example, imagine that you have the following data object
                  (wrapped in a *Context* object constructed with
                  `new Context(tplData);`):
                >
                >     <script>
                >       …
                >       var tplData = {
                >         username:"Jane User",
                >         addresses:[ {
                >           location:"111 8th Av.",
                >           label:"NYC front door"
                >         }, {
                >           location:"76 9th Av.",
                >           label:"NYC back door"
                >         }, {
                >           location:"Mountain View",
                >           label:"Mothership"
                >         } ]
                >       };
                >       …
                >     </script>
                >
                > and you use this data in processing the template
                >
                >     <div id="tpl">
                >       <span jsselect="username"
                >             jscontent="$this"
                >       ><!-- empty --></span>'s Address Book
                >     </div>
                >
                > The *jsselect* attribute tells the processor to retrieve the
                  username property of the data object, wrap this value
                  (*“Jane User”*) in a new JsEvalContext, and use the new
                  *Context* in processing the span element.  As a result,
                  `$this` refers to *“Jane User”* in the context of the span,
                  and the *jscontent* attribute evaluates to `"Jane User"`.
                >
                > Note that the *jsselect* has to be executed before the
                  *jscontent* in order for this example to work.  In fact,
                  *jsselect* is always evaluated before any other JsTemplate
                  attributes (with the exception of *transclude*), and so the
                  processing of all subsequent instructions for the same
                  template element will take place in the new environment
                  created by the jsselect (see *“Order of Evaluation”* below).
                >
                > What happens if you try to *jsselect* the array-valued
                  addresses property of the data object?  If the result of
                  evaluating a *jsselect* expression is an array, a duplicate
                  of the current template node is created for each item in the
                  array.  For each of these duplicate nodes a `new Context( … );`
                  will be created to wrap the array item, and the processing
                  environment for the duplicate node now uses this *Context*
                  rather than the original.  In other words, *jsselect* operates
                  as a sort of `foreach` statement in the case of arrays.  So
                  you can expand your address book template to list addresses in
                  your data object like so:
                >
                >     <div id="tpl">
                >       <h1>
                >         <span jsselect="username"
                >               jscontent="$this">
                >           User de Fault
                >         </span>'s Address Book
                >       </h1>
                >       <table cellpadding="5">
                >         <tr>
                >           <th>Location:</th>
                >           <th>Label:</th>
                >         </tr>
                >         <tr jsselect="addresses">
                >           <td jscontent="location"><!-- location --></td>
                >           <td jscontent="label"><!-- label --></td>
                >         </tr>
                >       </table>
                >     </div>
                >
                > Processing this template with your *“Jane User”* address book
                  data will produce a nice table with a row for each address.
                  Since the execution of a *jsselect* instruction can change the
                  number of children under a template node, we might worry that
                  if we try to reprocess a template with new data the template
                  will no longer have the structure we want.  JsTemplate manages
                  this problem with a couple of tricks.  First, whenever a
                  *jsselect* produces duplicate nodes as a result of an
                  array-valued expression, the processor records an index for
                  each node as an attribute of the element.  So if the duplicate
                  nodes are reprocessed, the processor can tell that they
                  started out as a single node and will reprocess them as if
                  they are still the single node of the original template.
                  Second, a template node is never entirely removed, even if a
                  *jsselect* evaluates to `null`.  If it evaluates to `null` (or
                  `undefined`), the current node will be hidden by setting
                  `style="display:none"`, and no further processing will be
                  performed on it.  But the node will still be present, and
                  available for future reprocessing.

Inner Actions
-------------------

Inner actions operate on tag element-attributes, -properties and -methods as
well as the context-data, -variables and -values.

- **appear**  : Formerly “[jsdisplay](http://code.google.com/p/google-jstemplate/wiki/TemplateProcessingInstructionReference)”.
                The result determines if the node appears on page.  Therefore
                the result is either booleanized and applied as css-display,
                with `false` ~ `style="display: none"` and `true` ~
                `style="display: block"`.  If the result matches a valid value
                for css-display it is used directly in `display: …`.
                > The value of the *jsdisplay* attribute is evaluated as a
                  <del>javascript</del> expression.  If the result is `false`,
                  `0`, `""` or any other <del>javascript</del> value that is
                  `true` when negated, the CSS display property of the current
                  template node will be set to *“none”*, rendering it invisible
                  <insert>*without detaching it from the DOM*<insert>, and no
                  further processing will be done on this node or its children.
                  This instruction is particularly useful for checking for empty
                  content.  You might want to display an informative message if
                  a user's address book is empty, for example, rather than just
                  showing them an empty table.  The following template will
                  accomplish this goal:
                >
                >     <div id="tpl">
                >       <h1>
                >         <span jsselect="username"
                >               jscontent="$this">User de Fault</span>'s Address Book
                >       </h1>
                >       <span jsdisplay="addresses.length==0">Address book is empty.</span>
                >       <table cellpadding="5" jsdisplay="addresses.length">
                >         <tr>
                >           <th>Location:</th>
                >           <th>Label:</th>
                >         </tr>
                >         <tr jsselect="addresses">
                >           <td jscontent="location"><!-- location --></td>
                >           <td jscontent="label"><!-- label --></td>
                >         </tr>
                >       </table>
                >     </div>
                >
                > If the addresses array is empty, the user will see
                  *“Address book is empty”*, but otherwise they will see the
                  table of addresses as usual.

- **set**     : Formerly “[jsvars](http://code.google.com/p/google-jstemplate/wiki/TemplateProcessingInstructionReference)”.
                > This instruction is identical to *jsvalues*, except that all
                  assignment targets are interpreted as variable names, whether
                  or not they start with a dolar-sign (*“$”*) or a dot (*“.”*).
                  That is, all assignment targets are interpreted as described
                  in section 1 of the *jsvalues* section below.

- **alter**   : Formerly “[jsvalues](http://code.google.com/p/google-jstemplate/wiki/TemplateProcessingInstructionReference)”.
                > The *jsvalues* instruction provides a way of making
                  assignments that alter the template processing environment.
                  The template processor parses the value of the *jsvalues*
                  attribute value as a semicolon-delimited list of name value
                  pairs, with every name separated from its value by a colon.
                  Every name represents a target for assignment.  Every value
                  will be evaluated as a javascript expression and assigned to
                  its associated target.  The nature of the target depends on
                  the first character of the target name:
                > - If the first character of the target name is "$", then the
                    target name is interpreted as a reference to a variable in
                    the current `JsEvalContext` processing environment.  This
                    variable is created if it doesn't already exist, and
                    assigned the result of evaluating its associated expression.
                    It will then be available for subsequent template processing
                    on this node and its descendants (including subsequent
                    name-value pairs in the same *jsvalues* attribute). Note
                    that the dollar sign is actually part of the variable name:
                    if you create a variable with `jsvalues="$varname:varvalue"`,
                    you must use `$varname` to retrieve the value.
                > - If the first character of the target name is ".", then the
                    target name is interpreted as a reference to a javascript
                    property of the current template node.  The property is
                    created if it doesn't already exist, and is assigned the
                    result of evaluating its associated expression. So the
                    instruction `jsvalues=".id:'Joe';.style.fontSize:'30pt'"`
                    would change the id of the current template node to "Joe"
                    and change its font size to 30pt.
                > - If the first character of the target name is neither a dot
                    nor a dollar sign, then the target name is interpreted as a
                    reference to an XML attribute of the current template
                    element.  In this case the instruction `jsvalues="name:value"`
                    is equivalent to the javascript statement `this.setAttribute('name','value');`,
                    where this refers to the current template node.  Just as in
                    the case of a call to setAttribute, the value will be
                    interpreted as a string (after javascript evaluation). So
                    `jsvalues="sum:1+2"` is equivalent to `this.setAttribute('sum', '3');`.
                >
                > The jsvalues instruction makes a handy bridge between the DOM
                  and context data.  If you want a built-in event handler
                  attribute like `onclick=" … "` to be able to access the
                  currently selected portion of the `JsEvalContext` data, for
                  example, you can use *jsvalues* to copy a reference to the
                  data into an attribute of the current element, where it will
                  be accessible in the `onclick=" … "` attribute via `this.
                  The following example uses this approach to turn our outline
                  into a collapsible outline:
                >
                >     <script>
                >       // Function called by onclick to record state of
                >       // closedness and refresh the outline display
                >       function setClosed(jstdata, closedVal) {
                >         jstdata.closed = closedVal;
                >         loadData(PEG_ELEMENT, TEMPLATE_NAME, tplData);
                >       }
                >     </script>
                >     <div id="tpl">
                >       <!-- Links to open and close outline sections: -->
                >       <a href="#"
                >          jsdisplay="closed"
                >          jsvalues=".jstdata:$this"
                >          onclick="setClosed(this.jstdata,0)">[Open]</a>
                >       <a href="#"
                >          jsdisplay="!closed && items.length"
                >          jsvalues=".jstdata:$this"
                >          onclick="setClosed(this.jstdata,1)">[Close]</a>
                >       <span jscontent="title">Outline heading</span>
                >       <ul jsdisplay="items.length && !closed">
                >         <li jsselect="items">
                >           <div transclude="tpl">
                >             <!-- recursive tranclusion -->
                >           </div>
                >         </li>
                >       </ul>
                >     </div>

- **do**      : Formerly “[jseval](http://code.google.com/p/google-jstemplate/wiki/TemplateProcessingInstructionReference)”.
                > The processor evaluates a jseval instruction as a javascript
                  expression, or a series of javascript expressions separated by
                  semicolons.  The jseval instruction thus allows you to invoke
                  javascript functions during template processing, in the usual
                  template processing environment, but without any of the
                  predefined template processing effects of *jsselect*, *jsvalues*,
                  *jsdisplay*, *jsskip*, or *jscontent*.  For example, with the
                  addition of a jseval instruction to our outline title span,
                  the processor can record a count of the total number of
                  outline items with and without titles as it traverses the data
                  hierarchy.
                >
                > The count information in this example is stored in the
                  processing context with a call to setVariable, so that it
                  will be available to template processing throughout the data
                  hierarchy:
                >
                >     var counter = { full: 0 };
                >     processingContext.setVariable('$counter', counter);
                >
                > A jseval expression increments the count:
                >
                >     <span jscontent="title"
                >           jseval="title? $counter.full++: $counter.empty++">
                >       Outline heading
                >     </span>
                >
                > and then a separate template displays these counts at the
                  bottom of the page:
                >
                >     <div id="titleCountTpl">
                >       <p>
                >         This outline has
                >         <span jscontent="$counter.empty">0</span>
                >         empty titles and
                >         <span jscontent="$counter.full">0</span>
                >         titles with content.
                >       </p>
                >     </div>
                >
                > Note that when you close headings the counts change:
                  *jsdisplay* is not only hiding the closed elements, but also
                  aborting the processing of these elements, so that the
                  *jseval* expressions on these elements are never evaluated.

- **skip**    : Formerly “[jsskip](http://code.google.com/p/google-jstemplate/wiki/TemplateProcessingInstructionReference)”.
                > The value of the *jsskip* attribute is evaluated as a
                  javascript expression.  If the result is any javascript value
                  that evaluates to true in a boolean context, then the
                  processor will not process the subtree under the current node.
                  This instruction is useful for improving the efficiency of an
                  application (to avoid unnecessarily processing deep trees, for
                  example).
                >
                > The effect of a jsskip that evaluates to true is very similar
                  to the result of a jsdisplay that evaluates to false.  In both
                  cases, no processing will be performed on the node's children.
                  However, *jsskip* will not prevent the current node from being
                  displayed.

- **markup**  : This action is present if `(cheerio|jQuery)( … ).html( … );` is
                available.  This is nearly the same action as the *text*-action
                below, except it allows markup to be embedded.
                **Use it with absolute caution! You have been warned !**

- **text**    : Formerly “[jscontent](http://code.google.com/p/google-jstemplate/wiki/TemplateProcessingInstructionReference)”.
                Uses `(cheerio|jQuery)( … ).text( … );` if available.  Otherwise
                the given content will be assigned to `Node.innerHTML`.
                > This attribute is evaluated as a javascript expression in the
                  current processing environment.  The string value of the
                  result then becomes the text content of the current node.
                  So the template:
                >
                >     <p id="tpl">
                >       Welcome <span jscontent="$this">username</span>
                >     </p>
                >
                > … when processed with the javascript statements:
                >
                >     var tplData = "Joe User",
                >         input   = new JsEvalContext(tplData),
                >         output  = document.getElementById('tpl');
                >     jstProcess(input, output);
                >
                > … will display `Welcome Joe User` in the browser.  Note the
                  use of `$this` here: the `JsEvalContext` constructor is passed
                  the string `"Joe User"`, and so this is the object to which
                  `$this` refers.
                >
                > When the processor executes a *jscontent* instruction, a new
                  text node object is created with the string value of the
                  result as its nodeValue, and this new text node becomes the
                  only child of the current node.  This implementation ensures
                  that no markup in the result is evaluated.

- **next**    : This action is present if `(cheerio|jQuery)( … ).next( … );` is
                available.  The processor will jump to the first element of the
                resulting selection.

###

# ~require
{Constants:{
  DEBUG,
  ATT_cache,
  PROP_cache,
  STRING_assigment,
  STRING_empty,
  STRING_seperator,
  STRING_zero
}}                    = require '../Core/Constants'

{Document:{
  getAttribute,
  setAttribute,
  traverseElements,
  ownerDocument
}}                    = require '../Dom/Document'

{Utility:{
  bind
}}                    = require '../Core/Utility'

# ~export
exports = module?.exports ? this

# Processor
# ================================

# --------------------------------
# Internal class used by templates to maintain context.  This necessary to
# process deep templates in Safari≤5 and mobile browsers having a relatively
# shallow maximum recursion depth of 100.
#
# @class      Process
# @namespace  goatee.Action
exports.Processor = class Processor

  # --------------------------------
  # Caches the document of the template node, so we don't have to access it
  # through ownerDocument.
  #
  # @public
  # @property document
  # @type     {Document}
  document: null

  # --------------------------------
  # Holds this instance's options.
  #
  # @public
  # @property options
  # @type     {Object}
  options: null

  # --------------------------------
  # Constructs the `Processor` instance.
  #
  # @param        {Object}    [options]
  # @param        {Document}  [options.document]
  # @constructor
  constructor: (@options) ->
    {@document} = @options if not @document? and @options? and @options.document?

  # --------------------------------
  # Runs the given function `fn` in our state machine.
  #
  # It's informative to view the set of all function calls as a tree:
  #
  # - nodes are states
  # - edges are state transitions, implemented as calls to the pending functions
  #   in the stack.
  #   - pre-order function calls are downward edges (recursion into call).
  #   - post-order function calls are upward edges (return from call).
  # - leaves are nodes which do not recurse.
  #
  # We represent the call tree as an array of array of calls, indexed as
  # stack[depth][index].  Here [depth] indexes into the call stack, and [index]
  # indexes into the call queue at that depth.  We require a call-queue so that
  # a node may branch to more than one child (which will be called serially),
  # typically due to a loop structure.
  #
  # @public
  # @method run
  # @param  {Function}  fn  The first function to run.
  run: (fn) ->

    # A stack of queues of pre-order calls.  The inner arrays (constituent
    # queues) are structured as `[ arg2, arg1, method, arg2, arg1, method, ...]`
    # ie. a flattened array of methods with 2 arguments, in reverse order for
    # efficient push/pop.
    #
    # The outer array is a stack of such queues.
    #
    # @public
    # @property calls
    # @type     {Array.<Array>}
    @calls = calls = []

    # The index into the queue for each depth.  Notice, an alternative would be
    # to maintain the queues in reverse order (popping off of the end) but the
    # repeated calls to `Array.pop()` consumed 90% of this function's execution
    # time.
    #
    # @public
    # @property indices
    # @type     {Array.<Number>}
    @indices = indices = []

    # A pool of empty arrays.  Minimizes object allocation as performance and
    # memory benefit.
    #
    # @public
    # @property arrays
    # @type     {Array.<Array>}
    @arrays = arrays = []

    # After initializing this state-machine execute the given start function.
    # It should have scope and arguments pre-bound.
    fn()

    while 0 < calls.length
      # Determine the next queue.
      queue = calls[calls.length - 1]
      index = indices[indices.length - 1]

      # If the index is out of the queue's bound look for the next candidate
      if index >= queue.length
        @recycleArray calls.pop()
        indices.pop()
        continue

      # Run the first function in the queue and record it's index.
      method = queue[index++]
      arg1 = queue[index++]
      arg2 = queue[index++]
      indices[indices.length - 1] = index
      method.call(this, arg1, arg2)
    return

  # --------------------------------
  # Pushes one or more functions onto the stack.  These will be run in sequence,
  # interspersed with any recursive calls that they make.
  #
  # This method takes ownership of the given array!
  #
  # @public
  # @method push
  # @param  {Array} args  Array of method calls structured as
  #                       `[ method, arg1, arg2, method, arg1, arg2, ... ]`
  push: (args) ->
    @calls.push args
    @indices.push 0
    return

  # --------------------------------
  # Prepares the template: pre-processes all template actions (formerly called
  # instructions).
  #
  # @public
  # @method setup
  # @param {Element} template
  setup: (template) ->
    unless @getCacheProperty(template)?
      self = this
      Document.traverseElements(template, (node) -> self.prepare(node))
    return

  # --------------------------------
  # A list of attributes we use to specify the processing actions (formerly
  # called instructions) and the functions used to parse their values.
  #
  # @static
  # @public
  # @property actions
  # @type     {Array.<Array>}
  @actions: [
  #!    [ Constants.ATT_select, jsEvalToFunction ],
  #!    [ Constants.ATT_display, jsEvalToFunction ],
  #!    [ Constants.ATT_values, jsEvalToValues ],
  #!    [ Constants.ATT_vars, jsEvalToValues ],
  #!    [ Constants.ATT_eval, jsEvalToExpressions ],
  #!    [ Constants.ATT_transclude, jsEvalToSelf ],
  #!    [ Constants.ATT_content, jsEvalToFunction ],
  #!    [ Constants.ATT_skip, jsEvalToFunction ]
  ]

  # --------------------------------
  # A list for storing non-empty actions found on a node in prepare().  The
  # array is not an instance property, hence a kind of global, since it can be
  # reused.  This way there is no need to construct a new array object for each
  # invocation, which should increase the performance.
  #
  # @private
  # @property _list
  # @type     {Array}
  _list   = []

  # --------------------------------
  # A map for storing temporary action values in `prepare()` so they don't have
  # to be retrieved twice, which should increase the performance.  The object is
  # not an instance property, hence a kind of global, since it can be reused.
  # This way there is no need to construct a new object for each invocation,
  # which should increase the performance.
  #
  # @private
  # @property _list
  # @type     {Object}
  _values = {}

  # --------------------------------
  # A counter to generate cache ids.  These ids will be stored used to lookup
  # the pre-processed actions from the cache.  The id is stored with the element
  # to survive `cloneNode()` and thus cloned template nodes can share the same
  # cache entry.
  #
  # @private
  # @property _id
  # @type     {Number}
  _id = 0

  # --------------------------------
  # Map from cache `_id` to processed actions.
  #
  # @private
  # @property _actions
  # @type     {Object}
  _actions = {}

  # --------------------------------
  # The neutral cache entry.  Used for all nodes that lack any actions. We still
  # set the id on those nodes so we can avoid looking again for all the other
  # actions that aren't there.  Remember, not only the processing of the action-
  # values is expensive and we thus want to cache it.  The access to the actions
  # on the Node in the first place is very expensive too.
  #
  # @private
  # @property _empty
  # @type     {Object}
  _empty = _actions[Constants.STRING_zero] = {}

  # --------------------------------
  # Prepares a single node: pre-processes all template attributes of the node
  # and if there are any, assigns an cache-identifier-attribute and stores the
  # pre-processed attributes under the identification in the `_actions`-cache.
  #
  # @public
  # @method prepare
  # @param  {Element}   node  The node to prepare for processing
  # @return {Object}          The cache entry, an object consisting of processed
  #                           attributes or the `_empty` object, if the node has
  #                           no relevant attributes
  prepare: (node) ->

    # If the node already has a cache property, return it.
    cache = @getCacheProperty node
    return cache if cache?

    # If it is not found, we always set a `PROP_cache`-property on the node.
    # Accessing the property is faster than executing `getAttribute()`.  If we
    # don't find the property on a node that was cloned, ie. by the _repeat_-
    # action (formerly `jstSelect_()`), we will fall back to check for the
    # attribute and set the property from cache.

    # If the node has a cache-identifier, get the related cache object, set it
    # as a property and return it.
    id = @getCacheIdentifier(node)
    if id?
      cache = @getCache id
      if cache?
        return @setCacheProperty(node, cache)

    # Collect all action-attributes and their values
    @collect(node, _list, _values)

    # If none found, mark this node to prevent further inspection, and return
    # an empty cache object.
    return @setEmpty node if _list.length is 0

    # Concatenates the action-attributes and their values in a way, that allows
    # comparison of these flattened string with other nodes' action attributes
    # (or possibly to reuse in other contexts, sometime in the future)
    source = @flatten _list

    # If we already have a cache entry corresponding to the flattened
    # attributes, annotate the node with it, and return it
    id = @getSourceIdentifier source
    if id?
      cache = @getCache id
      if cache?
        @setCacheIdentifier node, id
        return @setCacheProperty node, cache

    # Otherwise, build a new cache object …
    cache = @createCache(node, _values)

    # … and generate a new cache identifier.
    id    = Constants.STRING_empty + ++_id

    # Now, cache the fresh entry.
    @setCache(id, cache)

    # Store the `cloneNode()`-surviving cache identifier
    # for quicker access directly as a node attribute.
    @setCacheIdentifier(node, id)

    # Store the flattened cache entry for
    # quick rebuilds in the `_source`-cache.
    @setSourceIdentifier(source, id)

    # Store the fresh cache entry for quicker
    # access directly on the node and return it.
    @setCacheProperty(node, cache)

  # --------------------------------
  # Collect actions from or for the given `node`.
  #
  # @public
  # @method collect
  # @param  {Element}         node
  # @param  {Array.<String>}  list    Array to append the collected actions
  #                                   (formerly called instructions) to
  # @param  {Object.<String>} values  Object finally having the actions' names
  #                                   mapped to their raw values
  collect: (node, list, values) ->
    for [name] in Processor.actions
      value = Document.getAttribute node, name
      values[name] = value
      list.push @combine(name, value) if value?
    return

  # --------------------------------
  # Combines an action's name with its value, suitable for string comparisons.
  #
  # @public
  # @method combine
  # @param  {String}  name
  # @param  {String}  value
  combine: (name, value) ->

    # Alternative 1: Raw rule, using `|=|` as assignment. Obviously the fastest
    # implementation.
    Constants.STRING_empty + name + Constants.STRING_assigment + value

    # Alternative 2: URL encoded rule, using `=` as assignment and encoding the
    # value as URI.
    # `
    #     Constants.STRING_empty + name + Constants.CHAR_equals + \
    #     encodeUriComponent(value)
    # `

    # Alternative 3: CSS-like rule, using `:` as assignment and escaping the
    # double-quoted value.
    # `
    #     Constants.STRING_empty + name + Constants.CHAR_colon + \
    #     Constants.CHAR_doublequote + \
    #     (Constants.STRING_empty + value).replace('"','\\"') + \
    #     Constants.CHAR_doublequote
    # `

  # --------------------------------
  # Concatenates a list of strings consisting of action-names combined with its
  # value, suitable for string comparisons, hence flatten.
  #
  # @public
  # @method flatten
  # @param  {Array.<String>}  list  The list of actions-strings to concatenate
  # @return {String}                The concatenated list
  flatten: (list) ->
    # Alternative 1: Raw rules, using `|||` as separator.
    list.join Constants.STRING_seperator

    # Alternative 2: URL encoded rules, using `&` as separator.
    # `
    #     list.join Constants.CHAR_ampersand
    # `

    # Alternative 3: CSS-like rules, using `;` as separator.
    # `
    #     list.join Constants.CHAR_semicolon
    # `

  # --------------------------------
  # Create a new cache object.
  #
  # @public
  # @method createCache
  # @param  {Element}           node
  # @param  {Object.<String>}   values  Object having the actions' names mapped
  #                                     to their raw values
  # @return {Object.<Function,String>}  Object having the actions' names mapped
  #                                     to their parsed values, skipping
  #                                     `undefined` and `null` values
  createCache: (node, values) ->
    cache = {}
    for [name, parse] in Processor.actions
      value = values[name]
      continue unless value?
      cache[name] = parse value
      if Constants.DEBUG
        _debugCache = cache._debugCache ? cache._debugCache = {}
        _debugCache[name] = value
    cache

  # --------------------------------
  # Get cached actions-property from given node.
  #
  # @public
  # @method getCacheProperty
  # @param  {Element}   node                      The node to lookup the cache
  # @return {Object.<Function,String>|undefined}  An object having the actions'
  #                                               names mapped to their parsed
  #                                               values or `undefined` if no
  #                                               cache-property is available
  getCacheProperty: (node) ->
    node[Constants.PROP_cache]

  # --------------------------------
  # Cache actions in a node-property.
  #
  # @public
  # @method setCacheProperty
  # @param  {Element}                   node      The node to set the cache to.
  # @param  {Object.<Function,String>}  actions   An object having the actions'
  #                                               names mapped to their parsed
  #                                               values
  # @return {Object.<Function,String>}            The cached actions
  setCacheProperty: (node, actions) ->
    node[Constants.PROP_cache] = actions

  # --------------------------------
  # Get cached actions from `_actions`-cache for given identifier.
  #
  # @public
  # @method getCache
  # @param  {String}  id                          Cache identifier to lookup
  # @return {Object.<Function,String>|undefined}  An object having the actions'
  #                                               names mapped to their parsed
  #                                               values or `undefined` if no
  #                                               cache-entry is available
  getCache: (id) ->
    _actions[id]

  # --------------------------------
  # Cache actions in `_actions`-cache under given identifier.
  #
  # @public
  # @method setCache
  # @param  {String}                    id        Identifier to store actions
  # @param  {Object.<Function,String>}  actions   An object having the actions'
  #                                               names mapped to their parsed
  #                                               values
  # @return {Object.<Function,String>}            The cached actions
  setCache: (id, actions) ->
    _actions[id] = actions

  # --------------------------------
  # Get cached identifier(-attribute) from given node.
  #
  # @public
  # @method getCacheIdentifier
  # @param  {Element}           node  The node to lookup the cache-identifier
  # @return {String|undefined}        The cache-identifier or `undefined` if
  #                                   none is present
  getCacheIdentifier: (node) ->
    Document.getAttribute node, Constants.ATT_cache

  # --------------------------------
  # Store the cache identifier (as node-attribute).
  #
  # @public
  # @method setCacheIdentifier
  # @param  {Element}   node  The node to store the identifier to
  # @param  {String}    id    The identifier to store
  # @return {String}          The stored identifier
  setCacheIdentifier: (node, id) ->
    Document.setAttribute node, Constants.ATT_cache, id
    id

  # --------------------------------
  # Map from source, a concatenated action string, to cache identifiers.  The
  # key is the concatenation of all `_actions` found on a node formatted as
  # `name1=value1&name2=value2&...`, in the order of the `Processor.actions`
  # array.  The value is the identifier of the cache-entry that can be used for
  # this node.  This allows the reuse of cache entries in cases when a cached
  # entry already exists for a given combination of attribute values.  For
  # example when two template-nodes share the same actions, like those created
  # by the _repeat_-action (formerly _jsselect_-instruction).
  #
  # @private
  # @property _sources
  # @type {Object}
  _sources = {}

  # --------------------------------
  # Get cached identifier for given source.
  #
  # @public
  # @method getSourceIdentifier
  # @param  {String}            source  A concatenated action string
  # @return {String|undefined}          The cache-identifier or `undefined` if
  #                                     none is present
  getSourceIdentifier: (source) ->
    _sources[source]

  # --------------------------------
  # Cache identifier for given source.
  #
  # @public
  # @method setSourceIdentifier
  # @param  {String}  source  A concatenated action string
  # @param  {String}  id      The cache-identifier to store to
  # @return {String}          The stored cache-identifier
  setSourceIdentifier: (source, id) ->
    _sources[source] = id

  # --------------------------------
  # Mark all relevant caches as empty on given node.
  #
  # @public
  # @method setEmpty
  # @param  {Element}   node  The node to mark as beeing empty (=has no actions)
  # @return {Object}          The `_empty` cache-object
  setEmpty: (node) ->
    @setCacheIdentifier node, Constants.STRING_zero
    @setCacheProperty _empty

  # --------------------------------
  # Create a new `Processor`-instance.
  #
  # @static
  # @method create
  # @param  {Object}    [options]  Options passed to `new Processor()`.
  # @param  {Document}  [options.document]
  # @return {goaate.Action.Processor}
  @create: (options) ->
    return new Processor options

  # --------------------------------
  # HTML template processor. Data values are bound to HTML templates using the
  # attributes defined in the `Processor.actions`-registry.  The template is
  # modified in place.  The values of those attributes are <del>JavaScript</del>
  # GoateeScript-expressions that are evaluated in the context of the data
  # object fragment.
  #
  # @static
  # @method process
  # @param  {Context}   context             Context created from the input data
  #                                         object.
  # @param  {Element}   template            DOM node of the template to be
  #                                         processed in place.  Afterwards it
  #                                         will still be a valid template that,
  #                                         if processed again with the same
  #                                         data, will remain unchanged.
  # @param  {Object}    [options]           Options passed to `new Processor()`.
  # @param  {Document}  [options.document]
  @process = (context, template, options) ->

    processor = Processor.create options

    # Cache the owner document
    processor.document = Document.ownerDocument(template)

    # Traverse the template, emit actions and cache them
    processor.setup template

    # Execute all actions
    processor.run Utility.bind(processor, processor.outer, context, template)
    return
