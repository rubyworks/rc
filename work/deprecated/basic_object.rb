# TODO: Maybe use `backports` for future version.

unless Object.const_defined?(:BasicObject)
  require 'blankslate'
  Object::BasicObject = Object::BlankSlate
end

