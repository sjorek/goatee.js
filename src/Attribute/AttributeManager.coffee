###

Order of Evaluation
===================

Goatee instruction attributes within a single element are evaluated in the
following order:

OuterAttributes
-------------------

* render        Formerly “transclude”. If a “render” attribute is present no
                further attributes are processed. If “jQuery” is available,
                “render” may be either an internal reference, implemented as
                `jQuery( “render”, eg: '#id .selector', this )` or an external
                reference, implemented as `jQuery(this).load( “render”, eg:
                'url #element-id' );`.
* select        Formerly “jsselect”. If “select” is array-valued, remaining
                 attributes will be copied  to each new duplicate element
                created by the “select” and processed when the dom-traversal
                visits the new elements. If “json:select” is available and
                “select” is a string, it is used as css3-like query onto the
                current context. Therefore the context must be suiteable as
                2nd argument of “JSONSelect.match”. @see http://jsonselect.org

Inner Attributes
-------------------

* display       Formerly “jsdisplay”.
* var(iables)   Formerly “jsvars”.
* val(ues)      Formerly “jsvalues”.
* eval(uate)    Formerly “jseval”.
* leaf          Formerly “jsskip”.
* markup        This attribute is present if `jQuery(…).html()` is available.
* content       Formerly “jscontent”.
* next          This attribute is present if `jQuery(…).next()` is available.

###

