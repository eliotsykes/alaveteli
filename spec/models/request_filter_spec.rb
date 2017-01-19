# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RequestFilter do

  describe '#update_attributes' do

    it 'assigns the filter' do
      request_filter = described_class.new
      request_filter.update_attributes(:filter => 'awaiting_response')
      expect(request_filter.filter).to eq 'awaiting_response'
    end

    it 'assigns the search' do
      request_filter = described_class.new
      request_filter.update_attributes(:search => 'lazy dog')
      expect(request_filter.search).to eq 'lazy dog'
    end

    it 'assigns the order' do
      request_filter = described_class.new
      request_filter.update_attributes(:order => 'created_at_asc')
      expect(request_filter.order).to eq 'created_at_asc'
    end

    it 'does not assign an empty filter' do
      request_filter = described_class.new
      request_filter.update_attributes(:filter => '')
      expect(request_filter.filter).to be nil
    end

  end

  describe '#filter_capital_label' do

    def expect_label(label, filter)
      request_filter = described_class.new
      request_filter.update_attributes(:filter => filter)
      expect(request_filter.filter_capital_label).to eq label
    end

    it 'is "All requests" when the filter is empty' do
      expect_label('All requests', '')
    end

    it 'is "Drafts" when the filter is "draft"' do
      expect_label('Drafts', 'draft')
    end

    it 'is "Awaiting response" when the filter is "awaiting_response"' do
      expect_label('Awaiting response', 'awaiting_response')
    end

    it 'is "Complete" when the filter is "complete"' do
      expect_label('Complete', 'complete')
    end

    it 'is "Clarification needed" when the filter is "clarification_needed"' do
      expect_label('Clarification needed', 'clarification_needed')
    end

    it 'is "Other" when the filter is "other"' do
      expect_label('Other', 'other')
    end

    it 'is "Response received" when the filter is "response_received"' do
      expect_label('Response received', 'response_received')
    end

    it 'is "Requests with expiring embargoes" when the filter is
        "embargoes_expiring"' do
      expect_label('Requests with expiring embargoes', 'embargoes_expiring')
    end
  end

  describe '#filter_label' do

    def expect_label(label, filter)
      request_filter = described_class.new
      request_filter.update_attributes(:filter => filter)
      expect(request_filter.filter_label).to eq label
    end

    it 'is "all requests" when the filter is empty' do
      expect_label('all requests', '')
    end

    it 'is "drafts" when the filter is "draft"' do
      expect_label('drafts', 'draft')
    end

    it 'is "awaiting response" when the filter is "awaiting_response"' do
      expect_label('awaiting response', 'awaiting_response')
    end

    it 'is "complete" when the filter is "complete"' do
      expect_label('complete', 'complete')
    end

    it 'is "clarification needed" when the filter is "clarification_needed"' do
      expect_label('clarification needed', 'clarification_needed')
    end

    it 'is "other" when the filter is "other"' do
      expect_label('other', 'other')
    end

    it 'is "response received" when the filter is "response_received"' do
      expect_label('response received', 'response_received')
    end

    it 'is "requests with expiring embargoes" when the filter
        is "embargoes_expiring"' do
      expect_label('requests with expiring embargoes', 'embargoes_expiring')
    end
  end

  describe '#order_options' do

    it 'returns a list of sort order options in label, parameter form' do
      expected = [['Last updated', 'updated_at_desc'],
                  ['First created', 'created_at_asc'],
                  ['Title (A-Z)', 'title_asc']]
      expect(described_class.new.order_options).to eq expected
    end
  end

  describe '#persisted?' do

    it 'returns false' do
      expect(described_class.new.persisted?).to be false
    end

  end

  describe '#results' do
    let(:user){ FactoryGirl.create(:user) }

    context 'when no attributes are supplied' do

      it 'sorts the requests by most recently updated' do
        first_request = FactoryGirl.create(:info_request, :user => user)
        second_request = FactoryGirl.create(:info_request, :user => user)

        request_filter = described_class.new
        expect(request_filter.results(user))
          .to eq([second_request, first_request])
      end
    end

    it 'applies a sort order' do
      first_request = FactoryGirl.create(:info_request, :user => user)
      second_request = FactoryGirl.create(:info_request, :user => user)

      request_filter = described_class.new
      request_filter.update_attributes(:order => 'created_at_asc')
      expect(request_filter.results(user))
        .to eq([first_request, second_request])
    end

    it 'applies a filter' do
      complete_request = FactoryGirl.create(:successful_request,
                                            :user => user)
      incomplete_request = FactoryGirl.create(:info_request,
                                              :user => user)
      request_filter = described_class.new
      request_filter.update_attributes(:filter => 'complete')
      expect(request_filter.results(user))
        .to eq([complete_request])
    end

    it 'applies a search to the request titles' do
      dog_request = FactoryGirl.create(:info_request,
                                       :title => 'Where is my dog?',
                                       :user => user)
      cat_request = FactoryGirl.create(:info_request,
                                       :title => 'Where is my cat?',
                                       :user => user)
      request_filter = described_class.new
      request_filter.update_attributes(:search => 'CAT')
      expect(request_filter.results(user))
        .to eq([cat_request])
    end

    context 'when the filter is "draft"' do

      it 'returns draft requests' do
        draft_request = FactoryGirl.create(:draft_info_request,
                                           :user => user)
        request_filter = described_class.new
        request_filter.update_attributes(:filter => 'draft')
        expect(request_filter.results(user))
          .to eq([draft_request])
      end

      it 'applies a search to the request titles' do
        dog_request = FactoryGirl.create(:draft_info_request,
                                         :title => 'Where is my dog?',
                                         :user => user)
        cat_request = FactoryGirl.create(:draft_info_request,
                                         :title => 'Where is my cat?',
                                         :user => user)
        request_filter = described_class.new
        request_filter.update_attributes(:search => 'CAT',
                                         :filter => 'draft')
        expect(request_filter.results(user))
          .to eq([cat_request])
      end

      it 'applies a sort order' do
        first_request = FactoryGirl.create(:draft_info_request, :user => user)
        second_request = FactoryGirl.create(:draft_info_request, :user => user)

        request_filter = described_class.new
        request_filter.update_attributes(:order => 'created_at_asc',
                                         :filter => 'draft')
        expect(request_filter.results(user))
          .to eq([first_request, second_request])
      end
    end
  end
end