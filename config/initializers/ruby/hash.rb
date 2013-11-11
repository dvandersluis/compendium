class Hash
  # Remove nil values
  def compact
    delete_if{ |_, v| v.blank? }
  end unless method_defined?(:compact)
end
