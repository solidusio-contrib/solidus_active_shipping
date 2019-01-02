require 'carmen'
require 'spree/testing_support/factories/country_factory'

FactoryBot.define do
  # The state factory was changed too drastically in 1.3 to shim
  # we will need to bring this in until we no longer care about old Solidus
  factory :state_with_autodiscover, class: Spree::State do
    transient do
      country_iso { 'US' }
      state_code { 'AL' }

      carmen_subregion do
        carmen_country = Carmen::Country.coded(country.iso)
        carmen_country.subregions.coded(state_code) ||
          carmen_country.subregions.sort_by(&:name).first ||
          fail("Country #{country.iso} has no subregions")
      end
    end

    abbr { carmen_subregion.code }
    name { carmen_subregion.name }

    country do |country|
      Spree::Country.find_by(iso: country_iso) ||
        country.association(:country, iso: country_iso)
    end
  end
end
