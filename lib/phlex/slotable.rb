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

        if callable.is_a?(Proc)
          define_method :"__call_#{slot_name}__", &callable
          private :"__call_#{slot_name}__"
        end

        if many
          define_method :"with_#{slot_name}" do |*args, **kwargs, &block|
            instance_variable_set(:"@#{slot_name}_slots", []) unless instance_variable_defined?(:"@#{slot_name}_slots")

            value = case callable
            when nil
              block
            when String
              self.class.const_get(callable).new(*args, **kwargs, &block)
            when Proc
              -> { self.class.instance_method(:"__call_#{slot_name}__").bind_call(self, *args, **kwargs, &block) }
            else
              callable.new(*args, **kwargs, &block)
            end

            instance_variable_get(:"@#{slot_name}_slots") << value
          end

          define_method :"#{slot_name}_slots?" do
            !send(:"#{slot_name}_slots").empty?
          end
          private :"#{slot_name}_slots?"

          define_method :"#{slot_name}_slots" do
            instance_variable_get(:"@#{slot_name}_slots") || instance_variable_set(:"@#{slot_name}_slots", [])
          end
          private :"#{slot_name}_slots"
        else
          define_method :"with_#{slot_name}" do |*args, **kwargs, &block|
            value = case callable
            when nil
              block
            when String
              self.class.const_get(callable).new(*args, **kwargs, &block)
            when Proc
              -> { self.class.instance_method(:"__call_#{slot_name}__").bind_call(self, *args, **kwargs, &block) }
            else
              callable.new(*args, **kwargs, &block)
            end

            instance_variable_set(:"@#{slot_name}_slot", value)
          end

          define_method :"#{slot_name}_slot?" do
            !instance_variable_get(:"@#{slot_name}_slot").nil?
          end
          private :"#{slot_name}_slot?"

          attr_reader :"#{slot_name}_slot"
        end
      end
    end
  end
end
