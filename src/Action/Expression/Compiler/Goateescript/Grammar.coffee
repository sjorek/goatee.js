###
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>

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

{Parser} = require 'jison'
{Expression} = require './Expression'

root = module?.exports ? this

$1 = $2 = $3 = null

#  lifted from coffeescript http:#jashkenas.github.com/coffee-script/documentation/docs/grammar.html
unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/

r = (patternString, action) ->
    if patternString.source?
        patternString = patternString.source
    return [patternString, 'return;'] unless action
    action = if match = unwrap.exec action then match[1] else "(#{action}())"
    [patternString, "return #{action};"]

o = (patternString, action, options) ->
    return [patternString, '$$ = $1;', options] unless action
    action = if match = unwrap.exec action then match[1] else "(#{action}())"
    [patternString, "$$ = #{action};", options]

bop = (op) -> o 'Expression ' + op + ' Expression', -> new yy.Expression $2, [$1, $3]   #  binary operation shortcut

root.grammar = grammar =
  header:
      '''
      var global = (function(){return this;})();
      require('./Expression');
      Expression = global.goatee.Expression;

      '''
  footer:
      '''

      Expression.parse = (function() {
          var cache = {};
          return function(code) {
              if (cache.hasOwnProperty(code)) {
                  return cache[string];
              }
              var expression = parser.parse(code);
              return cache[code] = cache[expression.toString()] = expression;
          }
      })()
      if (typeof module !== 'undefined')
          module.exports = Expression.parse;
      '''
  comment: 'Goatee Expression Parser'
  lex:
    rules: [
      r /\s+/                     , ->
      r /0[xX][a-fA-F0-9]+\b/     , -> 'NUMBER'
      r ///
        ([1-9][0-9]+|[0-9])
        (\.[0-9]+)?
        ([eE][-+]?[0-9]+)?
        \b
        ///                       , -> 'NUMBER'
      r /return\b/                , -> 'RETURN'
      r /if\b/                    , -> 'IF'
      #r /for\b/                   , -> 'FOR'
      r /else\b/                  , -> 'ELSE'
      r /null\b/                  , -> 'NULL'
      r /true\b/                  , -> 'TRUE'
      r /false\b/                 , -> 'FALSE'
      r /new\b/                   , -> 'NEW'
      r /[@$.:]/                  , -> 'CONTEXT'
      r /[a-zA-Z_$]\w*/           , -> 'REFERENCE'    # identifier has to come AFTER reserved words

      # identifier above
      r ///
        "
        (
          \\x[a-fA-F0-9]{2} |
          \\u[a-fA-F0-9]{4} |
          \\[^xu]           |
          [^\\"]
        )*
        "
        ///                       , -> 'STRING'
      r ///
        '
        (
          \\[/'\\bfnrt]     |
          \\u[a-fA-F0-9]{4} |
          [^\\']
        )*
        '
        ///                       , -> 'STRING'
      r /\/\*(?:.|[\r\n])*?\*\//  , ->
      # operators below

      r '\\.'                     , -> '.'
      r '\\['                     , -> '['
      r '\\]'                     , -> ']'
      r '\\('                     , -> '('
      r '\\)'                     , -> ')'
      r '\\*'                     , -> '*'
      r '\\/'                     , -> '/'

      r '%'                       , -> '%'
      r '-'                       , -> '-'
      r '\\+'                     , -> '+'

      r '==='                     , -> '==='
      r '!=='                     , -> '!=='
      r '=='                      , -> '=='
      r '!='                      , -> '!='
      r '<='                      , -> '<='
      r '>='                      , -> '>='
      r '<'                       , -> '<'
      r '>'                       , -> '>'
      r '='                       , ->    '='
      r '-='                      , ->   '-='
      r '\\+='                    , ->   '+='
      r '\\*='                    , ->   '*='
      r '\\/='                    , ->   '/='
      r '<<='                     , ->  '<<='
      r '>>='                     , ->  '>>='
      r '>>>='                    , -> '>>>='
      r '&='                      , ->   '&='
      r '\\^='                    , ->   '^='
      r '\\|='                    , ->   '|='
      r '%='                      , ->   '%='
      r '\\&\\&'                  , -> '&&'
      r '\\|\\|'                  , -> '||'
      r '\\?'                     , -> '?'
      r ':'                       , -> ':'
      r ';'                       , -> ';'
      r ','                       , -> ','
      r '{'                       , -> '{'
      r '}'                       , -> '}'
      r '!'                       , -> '!'    # must be lower priority than != and !==
      r '$'                       , -> 'EOF'
    ]
  operators: [
    # from highest to lowest precedence
    ['left', '.', '[', ']']
    ['left', '(', ')']
    ['right', '!']
    ['left', '*', '/', '%']
    ['left', '+', '-']
    ['left', '<=', '>=', '<', '>']
    ['left', '===', '!==', '==', '!=']
    ['left', '&&']
    ['left', '||']
    ['right', '?', ':']
    ['left', '*=', '/=', '%=']
    ['left', '+=', '-=']
    ['left', '=']
    ['left', ',']
  # Reverse the operators because Jison orders precedence from low to high,
  # and we have it high to low
  # (as in [Yacc](http://dinosaur.compilertools.net/yacc/index.html)).
  ].reverse()
  startSymbol : 'Root'

# The syntax description
# ----------------------
grammar.bnf = bnf =
  # The **Root** is the top-level node in the syntax tree. Since we parse bottom-up,
  # all parsing must end here.
  Root: [
    r 'EOF'                       , -> null
    r 'Statements EOF'            , -> if $1 is yy.Empty then null else $1
    r 'Statements'                , -> if $1 is yy.Empty then null else $1
  ]
  Parameters: [
    o ''                          , -> []
    o 'Expression'                , -> [$1]
    o 'Parameters , Expression'   , -> $1.concat $3
  ]
  Key: [
    o 'Primitive'                 , -> $1
    o 'Identifier'                , -> $1
  ]
  KeyValue: [
    o 'Key : Expression'          , -> [$1,$3]
  ]
  KeyValues: [
    o ''                          , -> []
    o 'KeyValue'                  , -> $1
    o 'KeyValues , KeyValue'      , -> $1.concat $3
  ]
  Object: [
    o '{ KeyValues }'             , -> new yy.Expression 'object', $2
  ]
  Elements: [
    o ''                          , -> []
    o 'Expression'                , -> [$1]
    o 'Elements , Expression'     , -> $1.concat $3
  ]
  Array: [
    o '[ Elements ]'              , -> new yy.Expression 'array', $2
  ]
  Assign: [
    o '='
    o '-='
    o '+='
    o '*='
    o '/='
    o '<<='
    o '>>='
    o '>>>='
    o '&='
    o '^='
    o '|='
    o '%='
  ]
  Statements: [
    o 'Statement'
    o 'Statements Statement'      , ->
      if $1 is yy.Empty
        if $2 is yy.Empty
          yy.Empty
        else
          new yy.Expression 'block', [$2]
      else if $1.operator.name is 'block'
        $1.parameters.push $2 unless $2 is yy.Empty
        $1
      else if $2 is yy.Empty
        new yy.Expression 'block', [$1]
      else
        new yy.Expression 'block', [$1, $2]
  ]
  Statement: [
    o 'EmptyStatement'
    o 'ExpressionStatement'
    o 'ConditionalStatement'
    o 'AssignStatement'
  ]
  Block: [
    o '{ Statements }'            , -> if $2 is yy.Empty then null else $2
  ]
  EmptyStatement: [
    o ';'                         , -> yy.Empty
  ]
  ExpressionStatement: [
    o 'Expression ;'
    o 'Expression EOF'
  ]
  ConditionalStatement: [
    o 'Conditional ;'
    o 'Conditional EOF'
  ]
  AssignStatement: [
    o 'Identifier Assign ExpressionStatement', -> new yy.Expression $2, [$1, $3]   #  assignment
  ]
  Conditional: [
    o 'IF ( Expression ) Block ELSE Conditional', -> new yy.Expression 'if',  [$3,$5,$7]
    o 'IF ( Expression ) Block ELSE Block'      , -> new yy.Expression 'if',  [$3,$5,$7]
    o 'IF ( Expression ) Block'                 , -> new yy.Expression 'if',  [$3,$5]
    #o 'FOR ( e ) block'                         , -> new yy.Expression 'for', [$3,$5]
  ]
  Primitive: [
    o 'NUMBER'                    , -> Number($1)
    o '- NUMBER'                  , -> - Number($2)
    o 'NULL'                      , -> null
    o 'TRUE'                      , -> true
    o 'FALSE'                     , -> false
    o 'STRING'                    , -> yy.escapeString($1)
  ]
  Math: [
    bop '*'
    bop '/'
    bop '%'
    bop '+'
    bop '-'
  ]
  Boolean: [
    # logical not
    o '! Expression'              , -> new yy.Expression '!' , [$2]
    bop '<='
    bop '>='
    bop '<'
    bop '>'
    bop '==='
    bop '!=='
    bop '=='
    bop '!='
    bop '&&'
    bop '||'
  ]
  Literal: [
    o 'Object'                   , -> $1                                    # object literal
    o 'Array'                    , -> $1                                    # array literal
    o 'Primitive'                , -> new yy.Expression 'primitive',  [$1]     # number, boolean, string, null
  ]
  Identifier: [
    o 'REFERENCE'                , -> $1                                    # identifier
  ]
  Scope: [
    o 'CONTEXT'                  , -> new yy.Expression 'context', $1
  ]
  Reference: [
    o 'Identifier'               , -> new yy.Expression 'reference', [$1]
    o 'Scope Identifier'         , -> new yy.Expression '.', [$1, $2]          # shorthand dot operator
    o 'Scope'                    , -> $1                                       # global or local
  ]
  Path: [
      o 'Expression . Identifier' , -> new yy.Expression $2, [$1, new yy.Expression('reference', [$3])]
  ]
  Expression: [
    o 'Expression ? Expression : Expression',          -> new yy.Expression '?:', [$1, $3, $5]     # ternary conditional
    o 'Expression ( Parameters )',   -> new yy.Expression '()', [$1].concat $3   # function call
    o 'Expression [ Expression ]',   -> new yy.Expression '[]', [$1, $3]         # indexer
    o 'Reference',          -> $1
    o 'Literal',            -> $1
    o 'Math',               -> $1
    o 'Boolean',            -> $1
    o 'Path',               -> $1
  ]


# Wrapping Up
# -----------

# Finally, now that we have our **grammar** and our **operators**, we can create
# our **Jison.Parser**. We do this by processing all of our rules, recording all
# terminals (every symbol which does not appear as the name of a rule above)
# as "tokens".
tokens = []

for own name, alternatives of bnf
  bnf[name] = for alt in alternatives
    for token in alt[0].split ' '
      tokens.push token unless bnf[token]
    alt[1] = "#{alt[1]}" if name is 'Root'
    alt

grammar.tokens = tokens.join ' '

# Initialize the **Parser** with our grammar
root.parser = parser = new Parser grammar

parser.yy.escapeString = (s) -> s.replace(/\\\n/,'').replace(/\\([^xubfnvrt0\\])/g, '$1')
parser.yy.Expression   = Expression
parser.yy.Empty        = {operator:{name:'empty'}}
