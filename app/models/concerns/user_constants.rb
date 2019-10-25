module UserConstants
  extend ActiveSupport::Concern

  included do
    GENDER_PRONOUNS = ["ae, aer, aers", "fae, faer, faers", "e/ey, em, eirs", "he, him, his", "per, per, pers", "she, her, hers", "they, them, theirs", "ve, ver, vis", "xe, xem, xyrs", "ze/zie, hir, hirs", "other"]
  end
end