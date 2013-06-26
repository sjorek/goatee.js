###

Order of Evaluation
===================

Goatee instruction attributes and event processors within a single element are
evaluated in the following order:

Outer Processors
-------------------

* render        This processor initiates the rendering automatically, after the
                dom is ready. The algorithm uses the given “render”-Data as
                Context. Additionally if “jQuery” is available and the given
                data is a string, “render” may be either an global javascript
                variable reference, or if that fails an url to an external json-
                file. Changes to the render value, will stop any process 
                rendering the same tag and start re-rendering. The rendering-
                process will skip all nested tags which it-self contain a
                “render”-Attribute, since any of those tags will be processed
                automatically in the order of their appearance.
* source        Formerly “transclude”. If a “source” processor is present no
                further processors are processed. Additionally if “jQuery” is
                available, “source” may be either an internal template-
                reference, implemented as
                   `jQuery( “source eg: '#id .selector'”, this )`
                or an external reference, implemented as
                   `jQuery(this).load( “source, eg: 'url #element-id'” );`.
* select        Formerly “jsselect”. If “select” is array-valued, remaining
                processors will be copied to each new duplicate element created
                by the “select” and processed when the further dom-traversal
                visits the new elements. If “json:select” is available and
                “select” is a string, it is used as css3-like query onto the
                current context. Therefore the context must be suiteable as 2nd
                argument of “JSONSelect.match”. @see http://jsonselect.org

Inner Processors
-------------------

* display       Formerly “jsdisplay”.
* var(iables)   Formerly “jsvars”.
* val(ues)      Formerly “jsvalues”.
* eval(uate)    Formerly “jseval”.
* leaf          Formerly “jsskip”.
* markup        This processor is present if `jQuery(…).html()` is available.
* content       Formerly “jscontent”.
* next          This processor is present if `jQuery(…).next()` is available.

###

