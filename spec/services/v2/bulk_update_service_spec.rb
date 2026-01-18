# frozen_string_literal: true

require "rails_helper"

describe V2::BulkUpdateService do
  let(:user) { create(:user) }
  let(:list) { create(:list, owner: user) }
  let(:list_item_configuration) { create(:list_item_configuration, user: user) }
  let(:list_item_field_configuration) do
    create(:list_item_field_configuration, list_item_configuration: list_item_configuration)
  end
  let(:item) { create(:list_item, user: user, list: list) }

  describe "#fetch_items_with_fields" do
    it "reloads fields when association is not loaded" do
      create(:list_item_field, user:, list_item: item, list_item_field_configuration:)
      params = { list_id: list.id, item_ids: item.id.to_s }
      service = described_class.new(params, {}, user)

      items_relation = ListItem.where(id: item.id)
      allow(items_relation).to receive(:includes).and_return([item])
      allow(service).to receive(:items).and_return(items_relation)

      association = item.association(:list_item_fields)
      allow(association).to receive(:loaded?).and_return(false)

      fields = service.send(:fetch_items_with_fields).first[:fields]

      expect(fields.first[:label]).to eq(list_item_field_configuration.label)
    end
  end
end
