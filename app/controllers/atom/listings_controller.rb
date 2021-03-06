class Atom::ListingsController < ApplicationController
  include ListingsHelper

  respond_to :atom
  layout false

  # Renders atom feed of listings
  def index
    page, per_page = pagination(params)
    listings = @current_community.private ? [] : Listing.find_with(params, @current_user, @current_community, per_page, page)
    title = build_title(params)
    updated = listings.first.present? ? listings.first.updated_at : Time.now

    render locals: {listings: listings, title: title, updated: updated}
  end

  private

  def pagination(params)
    [params["page"] || 1, params["per_page"] || 50]
  end

  def build_title(params)
    category = Category.find_by_id(params["category"])
    category_label = (category.present? ? "(" + localized_category_label(category) + ")" : "")

    if ["request","offer"].include? params['share_type']
      listing_type_label = t("listings.index.#{params['share_type']+"s"}")
    else
      listing_type_label = t("listings.index.listings")
    end

    t("listings.index.feed_title",
      :optional_category => category_label,
      :community_name => @current_community.name_with_separator(I18n.locale),
      :listing_type => listing_type_label)
  end
end
