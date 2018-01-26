# Monkey patch to determine if an object is numeric
# Only Numerics and Strings/Symbols that are representations of numbers are numeric

class Object
  def numeric?
    false
  end
end

class String
  def numeric?
    !(self =~ /\A-?\d+(\.\d+)?\z|\A-?\.\d+\z/).nil?
  end
end

class Symbol
  def numeric?
    to_s.numeric?
  end
end

class Numeric
  def numeric?
    true
  end
end
