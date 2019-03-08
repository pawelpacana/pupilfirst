require 'rails_helper'

describe TimelineEventFilePolicy do
  subject { described_class }

  permissions(:download?) do
    let(:startup) { create :startup }
    let(:another_startup) { create :startup, course: startup.course }

    let(:course_faculty) { create :faculty, school: startup.school }
    let(:startup_faculty) { create :faculty, school: startup.school }

    let(:target_group) { create :target_group, level: startup.level }
    let(:target) { create :target, target_group: target_group }
    let(:timeline_event) { create :timeline_event, target: target, founders: startup.founders }
    let(:timeline_event_file) { create :timeline_event_file, timeline_event: timeline_event }

    let!(:course_enrollment) { create :faculty_course_enrollment, faculty: course_faculty, course: startup.course }
    let!(:startup_enrollment) { create :faculty_startup_enrollment, faculty: startup_faculty, startup: startup }

    context 'for the public' do
      let(:pundit_user) { OpenStruct.new }

      it 'denies access' do
        expect(subject).not_to permit(pundit_user, timeline_event_file)
      end
    end

    context "when the current user is a course coach for the linked course" do
      let(:pundit_user) do
        OpenStruct.new(
          current_coach: course_faculty
        )
      end

      it 'grants access' do
        expect(subject).to permit(pundit_user, timeline_event_file)
      end
    end

    context 'when the current user is a startup coach for the linked startup' do
      let(:pundit_user) do
        OpenStruct.new(
          current_coach: startup_faculty
        )
      end

      it 'grants access' do
        expect(subject).to permit(pundit_user, timeline_event_file)
      end
    end

    context 'when the current user is one of the founders linked to the timeline event' do
      let(:pundit_user) { OpenStruct.new(current_founder: startup.founders.first) }

      it 'grants access' do
        expect(subject).to permit(pundit_user, timeline_event_file)
      end
    end

    context 'for any other user' do
      let(:pundit_user) { OpenStruct.new(current_founder: another_startup.founders.first) }

      it 'denies access' do
        expect(subject).not_to permit(pundit_user, timeline_event_file)
      end
    end
  end
end