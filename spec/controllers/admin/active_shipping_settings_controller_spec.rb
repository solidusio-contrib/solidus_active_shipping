require 'spec_helper'

describe Spree::Admin::ActiveShippingSettingsController do
  stub_authorization!

  context '#edit' do
    it 'should assign a Spree::ActiveShippingConfiguration and render the view' do
      spree_get :edit
      expect(assigns(:config)).to be_an_instance_of(Spree::ActiveShippingConfiguration)
      expect(response).to render_template('edit')
    end
  end

  context '#update' do
    subject { spree_post :update, params }

    let(:config) { Spree::ActiveShippingConfiguration.new }

    context 'with existing value' do
      let(:params) { { default_weight: 42 } }

      around do |example|
        default_weight = config.get_preference(:default_weight)
        example.run
        config.set_preference(:default_weight, default_weight)
      end

      it "updates the existing value" do
        expect(config.has_preference?(:default_weight)).to be(true)
        subject
        expect(config.send("preferred_default_weight")).to be(42)
      end

      it "adds a flash message" do
        subject
        expect(flash[:success]).to eq("Successfully updated configuration")
      end
    end

    context 'without existing value' do
      let(:params) { { not_real_parameter_name: :not_real } }

      it "doesn't produce an error" do
        subject
        expect(response).to redirect_to(spree.edit_admin_active_shipping_settings_path)
      end
    end
  end
end
