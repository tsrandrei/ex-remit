defmodule RemitWeb.SettingsLive do
  use RemitWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    check_auth_key(session)

    {:ok, assign(socket, username: session["username"])}
  end

  @impl true
  def handle_event("form_change", %{"username" => username}, socket) do
    {:noreply, assign(socket, username: Remit.Utils.normalize_string(username))}
  end
end
