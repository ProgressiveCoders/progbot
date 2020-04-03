module UserConstants
  extend ActiveSupport::Concern

  included do
    GENDER_PRONOUNS = ["ae, aer, aers", "fae, faer, faers", "e/ey, em, eirs", "he, him, his", "per, per, pers", "she, her, hers", "they, them, theirs", "ve, ver, vis", "xe, xem, xyrs", "ze/zie, hir, hirs", "other"]

    COLUMN_NAMES_FOR_DISPLAY = ["id", "name", "email", "join_reason", "overview", "location", "anonymous", "phone", "slack_username", "slack_userid", "read_manifesto", "read_code_of_conduct", "referer_id", "created_at", "updated_at", "optin", "hear_about_us", "verification_urls", "is_approved", "gender_pronouns", "additional_info", "airtable_id"]
  end
end