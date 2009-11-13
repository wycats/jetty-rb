module Rack::Mount
  class MetaMethod #:nodoc:
    class Block < Array #:nodoc:
      def initialize(*parts)
        replace(parts)
        yield(self) if block_given?
      end

      def multiline?
        length > 1
      end

      def inspect(indented = 2)
        return Const::EMPTY_STRING if empty?
        space = ' ' * indented
        space + map { |p|
          if p.is_a?(Condition)
            p.inspect(indented)
          else
            p
          end
        }.join("\n#{space}")
      end

      def to_str
        map { |p| p.to_str }.join('; ')
      end
    end

    class Condition #:nodoc:
      attr_accessor :body, :else

      def initialize(*conditions)
        @conditions = conditions.map { |c| c.is_a?(Block) ? c : Block.new(c) }
        @body = Block.new
        @else = Block.new
        yield(@body) if block_given?
      end

      def <<(condition)
        @conditions << condition
      end

      def inspect(indented = 2)
        return @body.inspect(indented) if @conditions.empty?
        space = ' ' * indented
        str = 'if '
        str << @conditions.map { |b|
          b.multiline? ?
            "begin\n#{b.inspect(indented + 4)}\n#{space}  end" :
            b.inspect(0)
        }.join(' && ')
        str << "\n#{@body.inspect(indented + 2)}" if @body.any?
        if @else.any?
          str << "\n#{space}else\n#{@else.inspect(indented + 2)}"
        end
        str << "\n#{space}end"
        str
      end

      def to_str
        return @body.to_str if @conditions.empty?
        str = 'if '
        str << @conditions.map { |b|
          b.multiline? ? "(#{b.to_str})" : b.to_str
        }.join(' && ')
        str << "; #{@body.to_str}" if @body.any?
        if @else.any?
          str << "; else; #{@else.to_str}"
        end
        str << "; end"
        str
      end
    end

    def initialize(sym, *args)
      @sym = sym
      @args = args
      @body = Block.new
    end

    def <<(line)
      @body << line
    end

    def inspect
      str = ""
      str << "def #{@sym}"
      str << "(#{@args.join(', ')})" if @args.any?
      str << "\n#{@body.inspect}" if @body.any?
      str << "\nend\n"
      str
    end

    def to_str
      str = []
      str << "def #{@sym}"
      str << "(#{@args.join(', ')})" if @args.any?
      str << "\n#{@body.to_str}" if @body.any?
      str << "\nend"
      str.join
    end
  end
end
