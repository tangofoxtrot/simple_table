module TangoFoxtrot
  module SimpleTable
    def simple_table(collection, methods, show_url, options={})
      defaults = {:skip_first_link => false}
      options = defaults.merge(options)
      unless collection.empty?
        haml_tag :table, {:class => "table #{collection.first.class}"} do
          haml_tag :thead do
            haml_tag :tr do
              methods.each_with_index do |something_method, index|
                tag_class = [method_name_or_array(something_method)]
                tag_class << 'first' if index == 0
                tag_class << 'last' if index == methods.size - 1
                haml_tag :th, {:class => tag_class.join(' ')} do
                  haml_concat method_name_or_array(something_method).gsub(/_ans/, "").titleize
                end
              end
            end 
          end # thead
      
          if collection.is_a?(WillPaginate::Collection) && WillPaginate::ViewHelpers.total_pages_for_collection(collection) > 1
            haml_tag :tfoot do
              haml_tag :tr do
                haml_tag :td, {:colspan => methods.size} do
                  haml_concat will_paginate(collection)
                end
              end
            end # tfoot
          end # if WillPaginate::Collection
      
          haml_tag :tbody do
            collection.each do |something|
              haml_tag :tr, {:id => dom_id(something), :class => cycle('odd', 'even')} do
                methods.each_with_index do |something_method, index|
                  tag_class = [method_name_or_array(something_method)]
                  tag_class << 'first' if index == 0
                  tag_class << 'last' if index == methods.size - 1
                  haml_tag :td, {:class => tag_class.join(' ')} do
                    if index == 0 && !options[:skip_first_link]
                      haml_concat link_to(something.send(something_method), eval(show_url))
                    else
                      haml_concat method_or_array(something, something_method)
                    end
                  end
                end
              end
            end # end collection block
          end # tbody
      
        end # table
      else
        haml_tag :p do
          haml_concat "Currently Empty"
        end
      end # unless empty?
    end
  
    def admin?
      @current_user && @current_user.admin?
    end

    def writer?
      @current_user && @current_user.writer?
    end
  
    def page_class_with_container
      page_class + " container"
    end
  
  protected

    def method_name_or_array(method_to_be_called)
      if method_to_be_called.is_a?(Array)
        method_to_be_called[0]
      else
        method_to_be_called.to_s
      end
    end

    def method_or_array(something, method_to_be_called)
      if method_to_be_called.is_a?(Array)
        eval(method_to_be_called[1])
      else
        something.send(method_to_be_called)
      end
    end
  end
end