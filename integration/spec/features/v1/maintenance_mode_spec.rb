require 'spec_helper'

describe 'Maintenance mode' do
  let(:maintenance_content) do
    'Sorry, the service is unavailable'
  end

  context 'when maintenance mode is on' do
    let(:form) { MaintenanceModeApp.new }

    it 'redirects root page to the maintenance page' do
      form.load

      expect(form.text).to include(maintenance_content)
    end

    it 'redirects any request to the maintenance page' do
      form.load(url: '/step1')

      expect(form.text).to include(maintenance_content)
    end
  end

  context 'when maintenance mode is off' do
    let(:form) { FeaturesEmailApp.new }

    context 'when visiting any page' do
      it 'does not redirect requests to the maintenance page' do
        form.load

        expect(form.text).to_not include(maintenance_content)
      end
    end

    context 'when visiting the maintenance page' do
      it 'does not redirect requests to the maintenance page' do
        form.load('restricted/maintenance')

        expect(form.text).to_not include(maintenance_content)
      end
    end
  end
end
