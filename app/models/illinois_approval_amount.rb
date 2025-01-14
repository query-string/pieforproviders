# frozen_string_literal: true

# Subsidy rules that apply for Illinois
class IllinoisApprovalAmount < UuidApplicationRecord
  belongs_to :child_approval
  validates :month, presence: true
  validates :part_days_approved_per_week, numericality: true, allow_nil: true
  validates :full_days_approved_per_week, numericality: true, allow_nil: true

  scope :for_month,
        lambda { |date_time = Time.current|
          where(month: date_time.at_beginning_of_month.to_date..date_time.at_end_of_month.to_date)
        }
end

# == Schema Information
#
# Table name: illinois_approval_amounts
#
#  id                          :uuid             not null, primary key
#  deleted_at                  :date
#  full_days_approved_per_week :integer
#  month                       :date             not null
#  part_days_approved_per_week :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  child_approval_id           :uuid             not null
#
# Indexes
#
#  index_illinois_approval_amounts_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
