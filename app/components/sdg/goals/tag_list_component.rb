class SDG::Goals::TagListComponent < ApplicationComponent
  attr_reader :record_or_name, :limit
  delegate :link_list, to: :helpers

  def initialize(record_or_name, limit: nil)
    @record_or_name = record_or_name
    @limit = limit
  end

  def render?
    process.enabled?
  end

  private

    def record
      record_or_name if record_or_name.respond_to?(:sdg_goals)
    end

    def goal_links_with_see_more
      [*goal_links, see_more_link("goals")]
    end

    def goal_links
      goals.order(:code).limit(limit).map do |goal|
        [
          render(SDG::Goals::IconComponent.new(goal)),
          index_by_goal(goal),
          title: filter_text(goal)
        ]
      end
    end

    def goals
      record&.sdg_goals || SDG::Goal.all
    end

    def target_links_with_see_more
      [*target_links, see_more_link("targets")]
    end

    def target_links
      targets.sort[0..(limit.to_i - 1)].map do |target|
        [
          "#{SDG::Target.model_name.human} #{target.code}",
          index_by_target(target),
          title: filter_text(target),
          data: { code: target.code }
        ]
      end
    end

    def targets
      record&.sdg_targets || []
    end

    def see_more_link(namespace)
      return unless limit && count_out_of_limit > 0

      [
        "#{count_out_of_limit}+",
        polymorphic_path(record_or_name),
        class: "more-goals", title: t("sdg.#{namespace}.filter.more", count: count_out_of_limit)
      ]
    end

    def index_by_goal(goal)
      index_by(goal: goal.code)
    end

    def index_by_target(target)
      index_by(target: target.code)
    end

    def index_by(advanced_search)
      polymorphic_path(model, advanced_search: advanced_search)
    end

    def filter_text(goal_or_target)
      t("sdg.#{goal_or_target.model_name.element.pluralize}.filter.link",
        resources: model.model_name.human(count: :other),
        code: goal_or_target.code)
    end

    def count_out_of_limit
      goals.size - limit
    end

    def model
      process.name.constantize
    end

    def process
      @process ||= SDG::ProcessEnabled.new(record_or_name)
    end
end
