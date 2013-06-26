
#### Action

# A abstract class implementing a basic action 
# 
# @class
# @namespace goatee
exports.Action = class Action

  ##
  # Derivates must implement this method to perform the action.
  #
  # @param {Processor}  processor   The calling processor
  # @param {Context}    context     The current evaluation context
  # @param {Node}       template    The currently processed node of the template
  # @param {Function}   attribute   Processed value of the content attribute
  # @return Boolean
  process: (processor, context, template, attribute) ->
    throw new Exception 'Missing “process”-method implementation'
    return false
