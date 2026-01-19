# frozen_string_literal: true

require "rails_helper"

RSpec.describe List do
  it "instantiates the STI list classes" do
    expect(create(:book_list)).to be_a(BookList)
    expect(create(:grocery_list)).to be_a(GroceryList)
    expect(create(:music_list)).to be_a(MusicList)
    expect(create(:simple_list)).to be_a(SimpleList)
    expect(create(:to_do_list)).to be_a(ToDoList)
  end
end
