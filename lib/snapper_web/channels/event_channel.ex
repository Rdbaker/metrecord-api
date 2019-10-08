defmodule SnapperWeb.EventChannel do
  use Phoenix.Channel

  alias Snapper.Accounts
  alias Snapper.Events

  def join("event:" <> end_user_id, %{ "client_id" => client_id }, socket) do
    Accounts.find_or_create_end_user(end_user_id, client_id)

    {:ok, socket}
  end

  def handle_in("record_context", %{ "end_user_id" => end_user_id, "client_id" => client_id, "user_context" => user_context}, socket) do
    Events.create_event(
      client_id,
      end_user_id,
      %{
        data: user_context,
        event_type: "user_context",
        name: "user_context:#{end_user_id}"
      }
    )
    {:noreply, socket}
  end

  def handle_in("create:timer", %{"data" => data, "name" => name, "end_user_id" => end_user_id, "client_id" => client_id}, socket) do
    Events.create_event(
      client_id,
      end_user_id,
      %{
        data: data,
        event_type: "timer",
        name: name,
      }
    )

    {:noreply, socket}
  end

  def handle_in("create:increment", %{"data" => data, "name" => name, "end_user_id" => end_user_id, "client_id" => client_id}, socket) do
    Events.create_event(
      client_id,
      end_user_id,
      %{
        data: data,
        event_type: "count",
        name: name,
      }
    )

    {:noreply, socket}
  end
end
