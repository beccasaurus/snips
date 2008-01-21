$SNIP_MANAGER = Snip::Manager.new

module GlobalSnipHelpers

  def snip name_or_matcher
    $SNIP_MANAGER.snip name_or_matcher
  end

  def require_snip snip
    require $SNIP_MANAGER.which( snip )
  end

  def load_snip snip
    load $SNIP_MANAGER.which( snip )
  end

  def eval_snip snip
    eval $SNIP_MANAGER.read( snip )
  end

  def snip_source snip
    $SNIP_MANAGER.read snip
  end

end
