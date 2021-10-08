module DeadEnd
  # Value object for accessing lex values
  #
  # This lex:
  #
  #   [1, 0], :on_ident, "describe", CMDARG
  #
  # Would translate into:
  #
  #  lex.line # => 1
  #  lex.type # => :on_indent
  #  lex.token # => "describe"
  class LexValue
    attr_reader :line, :type, :token, :state

    def initialize(line, type, token, state)
      @line = line
      @type = type
      @token = token
      @state = state

      set_kw_end
    end

    private def set_kw_end
      @is_end = false
      @is_kw = false
      return if type != :on_kw

      case token
      when "if", "unless", "while", "until"
        # Only count if/unless when it's not a "trailing" if/unless
        # https://github.com/ruby/ruby/blob/06b44f819eb7b5ede1ff69cecb25682b56a1d60c/lib/irb/ruby-lex.rb#L374-L375
        @is_kw = true unless expr_label?
      when "def", "case", "for", "begin", "class", "module", "do"
        @is_kw = true
      when "end"
        @is_end = true
      end
    end

    def ignore_newline?
      type == :on_ignored_nl
    end

    def is_end?
      @is_end
    end

    def is_kw?
      @is_kw
    end

    def expr_beg?
      state.anybits?(Ripper::EXPR_BEG)
    end

    def expr_label?
      state.allbits?(Ripper::EXPR_LABEL)
    end
  end
end