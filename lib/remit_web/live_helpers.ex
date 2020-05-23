# Based on:
# https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#module-security-considerations-of-the-liveview-model

defmodule RemitWeb.LiveHelpers do
  import Phoenix.LiveView

  @expected_auth_key Application.get_env(:remit, :auth_key)

  def check_auth_key(session) do
    if session["auth_key"] != @expected_auth_key, do: throw("Invalid auth_key in LiveView!")
  end
end
