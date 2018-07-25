# Be sure to restart your server when you modify this file.

Couchpotatoe::Application.config.session_store :cookie_store, key: "_couchpotatoe_session_#{Rails.env}", domain: :all, tld_length: 2
