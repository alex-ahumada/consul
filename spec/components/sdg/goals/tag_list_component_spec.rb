require "rails_helper"

describe SDG::Goals::TagListComponent, type: :component do
  let(:debate) do
    create(:debate,
           sdg_goals: [SDG::Goal[1], SDG::Goal[3]],
           sdg_targets: [SDG::Target[1.1], SDG::Target[3.2]]
          )
  end
  let(:component) { SDG::Goals::TagListComponent.new(debate) }

  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.debates"] = true
  end

  it "does not render when the feature is disabled" do
    Setting["feature.sdg"] = false

    render_inline component

    expect(page).not_to have_css "li"
  end

  it "does not render when the SDG process feature is disabled" do
    Setting["sdg.process.debates"] = false

    render_inline component

    expect(page).not_to have_css "li"
  end

  describe "goal list" do
    let(:goal_list) { page.find(".sdg-goal-tag-list") }

    it "renders a list of goals" do
      render_inline component

      expect(goal_list).to have_css "li", count: 2
    end

    it "renders links for each goal" do
      render_inline component

      expect(goal_list).to have_selector "a", count: 2
      expect(goal_list).to have_link "1. No Poverty",
                                title: "See all Debates related to goal 1",
                                href: "/debates?advanced_search#{CGI.escape("[goal]")}=1"
      expect(goal_list).to have_link "3. Good Health and Well-Being",
                                title: "See all Debates related to goal 3",
                                href: "/debates?advanced_search#{CGI.escape("[goal]")}=3"
    end

    it "orders goals by code" do
      render_inline component

      expect(goal_list.first("a")[:title]).to end_with "goal 1"
    end

    it "renders a link for more goals when out of limit" do
      component = SDG::Goals::TagListComponent.new(debate, limit: 1)

      render_inline component

      expect(goal_list).to have_selector "a", count: 2
      expect(goal_list).to have_link "1. No Poverty"
      expect(goal_list).to have_link "1+",
                                title: "One more goal",
                                href: "/debates/#{debate.to_param}"
    end

    context "given a class name" do
      let(:component) { SDG::Goals::TagListComponent.new("Debate") }

      it "renders all goals ordered by code" do
        render_inline component

        expect(goal_list).to have_selector "li", count: 17
        expect(goal_list.first("a")[:title]).to end_with "goal 1"
        expect(goal_list.all("a").last[:title]).to end_with "goal 17"
      end
    end
  end

  describe "target list" do
    let(:target_list) { page.find(".sdg-target-tag-list") }

    it "renders a list of targets" do
      render_inline component

      expect(target_list).to have_css "li", count: 2
    end

    it "renders links for each target" do
      render_inline component

      expect(target_list).to have_selector "a", count: 2
      expect(target_list).to have_link "target 1.1",
                                       title: "See all Debates related to target 1.1",
                                       href: "/debates?advanced_search#{CGI.escape("[target]")}=1.1"
      expect(target_list).to have_link "target 3.2",
                                       title: "See all Debates related to target 3.2",
                                       href: "/debates?advanced_search#{CGI.escape("[target]")}=3.2"
    end

    it "orders targets by code" do
      render_inline component

      expect(target_list.first("a")[:title]).to end_with "target 1.1"
    end

    it "renders a link for more targets when out of limit" do
      component = SDG::Goals::TagListComponent.new(debate, limit: 1)

      render_inline component

      expect(target_list).to have_selector "a", count: 2
      expect(target_list).to have_link "target 1.1"
      expect(target_list).to have_link "1+",
                                       title: "One more target",
                                       href: "/debates/#{debate.to_param}"
    end

    context "given a class name" do
      let(:component) { SDG::Goals::TagListComponent.new("Debate") }

      it "renders nothing" do
        render_inline component

        expect(page).not_to have_selector(".sdg-target-tag-list")
      end
    end
  end
end
