module FilterSearch::Filter
  def self.included(base)
    base.send :include, Ext::IndexedModel

    base.class_eval do
      index_options :extended_json=>:extended_index_attrs,
                    :display_attrs=>[:name]

      mapping do
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_sort, :type => 'string', :index => :not_analyzed
      end
    end

    def extended_index_attrs
      {}
    end
  end
end