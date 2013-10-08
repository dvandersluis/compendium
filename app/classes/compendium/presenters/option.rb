module Compendium::Presenters
  class Option < Base
    MISSING_CHOICES_ERROR = "choices must be specified"

    presents :option

    def name
      t(option.name)
    end

    def label(form)
      label = case option.type.to_sym
        when :boolean, :radio
          name

        else
          form.label option.name, name
      end

      out = ActiveSupport::SafeBuffer.new
      out << content_tag(:span, label, class: 'option-label')

      if option.note?
        note = t(option.note == true ? :"#{option.name}_note" : option.note)

        if defined?(AccessibleTooltip)
          return accessible_tooltip(:help, label: out, title: t("#{option.name}_note_title", default: '')) { note }
        else
          out << content_tag(:div, note, class: 'option-note')
        end
      end

      out
    end

    def note
      if option.note?
        key = option.note === true ? :"#{option.name}_note" : option.note
        content_tag(:div, t(key), class: 'option-note')
      end
    end

    def input(ctx, form)
      out = ActiveSupport::SafeBuffer.new

      case option.type.to_sym
        when :date
          out << date_field(form)

        when :dropdown
          raise ArgumentError, MISSING_CHOICES_ERROR unless option.choices?

          options = option.choices
          options = ctx.instance_exec(&options) if options.respond_to?(:call)
          out << dropdown(form, options)

        when :boolean, :radio
          choices = if option.radio?
            raise ArgumentError, MISSING_CHOICES_ERROR unless option.choices?
            option.choices
          else
            %w(true false)
          end

          choices.each.with_index { |choice, index| out << radio_button(form, choice, index) }
      end

      out
    end

  private

    def date_field(form, include_time = false)
      content_tag('div', class: 'option-date') do
        if defined?(CalendarDateSelect)
          form.calendar_date_select option.name, time: include_time, popup: 'force'
        else
          form.text_field option.name
        end
      end
    end

    def dropdown(form, choices = {})
      content_tag('div', class: 'option-dropdown') do
        form.select option.name, choices
      end
    end

    def radio_button(form, label, value)
      content_tag('div', class: 'option-radio') do
        div_content = ActiveSupport::SafeBuffer.new
        div_content << form.radio_button(option.name, value)
        div_content << form.label(option.name, t(label), value: value)
      end
    end
  end
end