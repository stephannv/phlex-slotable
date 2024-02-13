# frozen_string_literal: true

require "phlex"

module Phlex
  module Slotable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def slot(slot_name, callable = nil, many: false)
        include Phlex::DeferredRender

        define_setter_method(slot_name, callable, many: many)
        define_lambda_method(slot_name, callable) if callable.is_a?(Proc)
        define_predicate_method(slot_name, many: many)
        define_getter_method(slot_name, many: many)
      end

      private

      def define_setter_method(slot_name, callable, many:)
        setter_method = if many
          <<-RUBY
            def with_#{slot_name}(*args, **kwargs, &block)
              @#{slot_name}_slots ||= []
              @#{slot_name}_slots << #{callable_value(slot_name, callable)}
            end
          RUBY
        else
          <<-RUBY
            def with_#{slot_name}(*args, **kwargs, &block)
              @#{slot_name}_slot = #{callable_value(slot_name, callable)}
            end
          RUBY
        end

        class_eval(setter_method, __FILE__, __LINE__ + 1)
      end

      def define_lambda_method(slot_name, callable)
        define_method :"__call_#{slot_name}__", &callable
        private :"__call_#{slot_name}__"
      end

      def define_getter_method(slot_name, many:)
        getter_method = if many
          <<-RUBY
            def #{slot_name}_slots
              @#{slot_name}_slots ||= []
            end
            private :#{slot_name}_slots
          RUBY
        else
          <<-RUBY
            def #{slot_name}_slot = @#{slot_name}_slot
            private :#{slot_name}_slot
          RUBY
        end

        class_eval(getter_method, __FILE__, __LINE__ + 1)
      end

      def define_predicate_method(slot_name, many:)
        predicate_method = if many
          <<-RUBY
            def #{slot_name}_slots? = #{slot_name}_slots.any?
            private :#{slot_name}_slots?
          RUBY
        else
          <<-RUBY
            def #{slot_name}_slot? = !#{slot_name}_slot.nil?
            private :#{slot_name}_slot?
          RUBY
        end

        class_eval(predicate_method, __FILE__, __LINE__ + 1)
      end

      def callable_value(slot_name, callable)
        case callable
        when nil
          %(block)
        when Proc
          %(-> { self.class.instance_method(:"__call_#{slot_name}__").bind_call(self, *args, **kwargs, &block) })
        else
          %(#{callable}.new(*args, **kwargs, &block))
        end
      end
    end
  end
end
