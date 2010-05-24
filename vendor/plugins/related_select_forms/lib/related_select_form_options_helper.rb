#--
# Copyright (C) 2006 Dimitrij Denissenko
# Please read LICENCE document for more information.
#++

module ActionView #:nodoc:
  module Helpers #:nodoc:
    # This plugin adds a new helper to the great RubyOnRails framework that 
    # allows to generate multiple, dependent HTML select tags. It handles 
    # the relations with simple JavaScript (requires prototype.js library), 
    # so you do not need to code any AJAX callbacks (can be handy when you
    # only deal with a small amount of data). This plugin works also 
    # well with RJS templates and supports recursive pre-selection of the
    # related select tags.
    module RelatedSelectFormOptionsHelper
    
      # Return a dependent select tag with options related to the 
      # parent_select_tag selection for the given object and method using 
      # options_from_collection_for_select to generate the list of option tags.
      # 
      # === Arguments:
      # 
      # * 'object', 'method', 'collection', 'value_method', 'text_method', 
      #   'options' & 'html_options' are used exactly the same way as in
      #   the standard collection_select helper method. 
      # * 'parent_select_tag' specifies, as the name says, the parent 
      #   select tag; argument can be passed as an array 
      #   [:parent_object, :method] or directly as string referencing the 
      #   tag id (e.g. "parent_object_method")
      # * Parameter 'reference_method' specifies the method that is used to get
      #   a reference to parent selection.
      #   
      # Additionally the 'options' argument can include a ':selected' attribute,
      # that will override the default pre-selection behaviour (which uses to call 
      # '@object.method' to determine the to be selected option).
      # 
      # 
      # === Example usage:
      # 
      # <b>tables</b>
      # 
      #     car_companies: id, name
      #     car_models:    id, name, car_company_id  
      #     
      # <b>view</b>
      #
      #     <%= collection_select(
      #           :car_company, :id, CarCompany.find(:all), :id, :name) %>
      #     <%= related_collection_select(:car_model, :id, [:car_company, :id], 
      #           CarModel.find(:all), :id, :name, :car_company_id) %>
      #           
      # The code above will create two drop-down select tags. The 1st allows the
      # selection of a car company. Based on this decision the 2nd select tag shows
      # company specific car models.
      def related_collection_select(object, method, parent_select_tag, collection, value_method, text_method, reference_method, options = {}, html_options = {})
        if parent_select_tag.is_a?(Array) && parent_select_tag.length == 2        
          parent_select_tag_id = "#{parent_select_tag[0].to_s}_#{parent_select_tag[1].to_s}" 
        else
          parent_select_tag_id = parent_select_tag
        end
                        
        relations = extract_relations(collection, reference_method)                   
        tag, js_code, tag_id, selected_value = InstanceTag.new(object, method, self).to_related_collection_select_tag(parent_select_tag_id, relations, value_method, text_method, options, html_options)
        
        @rc_select_ds ||= {} #  data store, used for preselecting
        @rc_select_ds[:relations] ||= {}
        @rc_select_ds[:relations][tag_id] = { 
          :parent => parent_select_tag_id, 
          :ref => reverse_relations(relations, value_method) 
        }
        
        tag + javascript_tag(js_init + js_code + js_preselect(selected_value, tag_id))
      end
            
      private
        # Creates initial code. Generates a HTMLRelatedSelectStruct element, the select tags can be extended with.
        def js_init
          "
          var HTMLRelatedSelectStruct = {
            select_children: undefined, 
            select_parent: undefined,
            relation_hash: undefined,
            extended_html_select_object: true,
            select: function(value) {
              for (i=0; i < this.options.length; i++) { 
                if (this.options[i].value == value) this.selectedIndex = i; 
              }
              this.refresh_children();
            },
            child_add: function(child) {
              if (this.select_children == undefined) this.select_children = [];
              this.select_children.push(child);
            },            
            refresh_children: function() {
              if (this.select_children != undefined) {
                this.select_children.each( function(child){ child.refresh(); } );
              }
            },
            refresh: function() {
              this.options.length = 0;
              if (this.select_parent != undefined && this.relation_hash != undefined && this.select_parent.selectedIndex > -1) {
                opts = this.relation_hash[this.select_parent.options[this.select_parent.selectedIndex].value];
                if (opts != undefined) {
                  for (i=0; i<opts.length; i++) this.options[i] = opts[i];
                  this.refresh_children();
                }
              }
            },
            onchange: function() { this.refresh_children(); }            
          };        
          "
        end      
         
        def js_preselect(selected_value, tag_id)
          return "$('#{tag_id}').refresh();" if selected_value.blank?
          selected_value = selected_value.id unless selected_value.is_a?(Numeric) || selected_value.is_a?(String)
          selected_value = selected_value.to_s
        
          js_code = []
          js_code << "$('#{tag_id}').select('#{selected_value}');"
          while relations = @rc_select_ds[:relations][tag_id]
            tag_id = relations[:parent]
            selected_value = relations[:ref][selected_value]
            js_code << "$('#{tag_id}').select('#{selected_value}');"
          end
          js_code.reverse.join("\n          ")
        end      
                  
        def extract_relations(collection, reference_method)
          collection.inject({}) do |result,o|
            reference_value = o.send(reference_method).to_s
            result[reference_value] ||= []
            result[reference_value] << o
            result
          end
        end    
      
        def reverse_relations(relations, value_method)
          reverse = {}
          relations.each_pair do |reference_value,opts|
            opts.each {|o| reverse[o.send(value_method).to_s] = reference_value}
          end
          reverse
        end

    end
    
    
    class InstanceTag #:nodoc:  
      include RelatedSelectFormOptionsHelper
      include ActionView::Helpers::JavaScriptHelper
      
      def to_related_collection_select_tag(parent_select_tag_id, relations, value_method, text_method, options = {}, html_options = {})  #:nodoc: 
        options.symbolize_keys!
        html_options.stringify_keys!
        add_default_name_and_id(html_options)        
    
        relation_hash = js_collection_relation_hash(relations, value_method, text_method, options)
        js_code = js_relation_code(parent_select_tag_id, relation_hash)
    
        selected_value = self.class.respond_to?(:value) ? value(object) : value # compatible with Rails 1.1 & 1.2
        selected_value = options[:selected] ? options[:selected].to_s : selected_value
        
        [content_tag("select", '', html_options), js_code, tag_id, selected_value]
      end
       
      private     
  
        def js_relation_code(parent_select_tag_id, relation_hash)
          "
          if ($('#{parent_select_tag_id}').extended_html_select_object != true)
            Object.extend($('#{parent_select_tag_id}'), HTMLRelatedSelectStruct); 
          if ($('#{tag_id}').extended_html_select_object != true)
            Object.extend($('#{tag_id}'), HTMLRelatedSelectStruct); 
          $('#{parent_select_tag_id}').child_add($('#{tag_id}'));
          $('#{tag_id}').select_parent = $('#{parent_select_tag_id}');
          $('#{tag_id}').relation_hash = {
            #{relation_hash}};
          "
        end
    
        def js_collection_relation_hash(relations, value_method, text_method, options)
          option_relations = []
          relations.each_pair do |reference_value,opts|
            reference_value_options = []
            
            selected_value = self.class.respond_to?(:value) ? value(object) : value # compatible with Rails 1.1 & 1.2
            if selected_value.blank? && options[:prompt] 
              prompt = options[:prompt].is_a?(String) ? escape_javascript(options[:prompt]) : 'Please select'
              reference_value_options << "new Option('prompt', '')"
            end

            if options[:include_blank]
              reference_value_options << "new Option('', '')"
            end

            reference_value_options << opts.collect do |o| 
              key = o.send(text_method).is_a?(String) ? escape_javascript(o.send(text_method)) : o.send(text_method)
              val = o.send(value_method).is_a?(String) ? escape_javascript(o.send(value_method)) : o.send(value_method)
              "new Option('#{key}', '#{val}')" 
            end

            option_relations << "#{reference_value}: [#{reference_value_options.flatten.join(', ')}]"
          end
          option_relations.join(",\n            ")
        end      

    end    
    
  end
end
