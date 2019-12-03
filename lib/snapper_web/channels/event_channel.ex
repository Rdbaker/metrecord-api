defmodule MetrecordWeb.EventChannel do
  use Phoenix.Channel

  alias Metrecord.Accounts
  alias Metrecord.Events

  def join("event:" <> end_user_id, %{ "client_id" => client_id }, socket) do
    Accounts.find_or_create_end_user(end_user_id, client_id)

    {:ok, socket}
  end

  # TODO: auth this
  def join("events:" <> org_secret, _params, socket) do
    case Accounts.get_org_by_secret_id(org_secret) do
      {:ok, _org} -> {:ok, socket}
      {:error, _} -> {:error, socket}
    end
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

  def handle_in("create:track", %{"data" => data, "name" => name, "end_user_id" => end_user_id, "client_id" => client_id}, socket) do
    {:ok, event} = Events.create_event(
      client_id,
      end_user_id,
      %{
        data: data,
        event_type: "track",
        name: name,
      }
    )
    Accounts.record_event_track_by_client_id(client_id, event.id)

    {:noreply, socket}
  end

  def handle_in("create:error", %{"data" => data, "name" => name, "end_user_id" => end_user_id, "client_id" => client_id}, socket) do
    Events.create_event(
      client_id,
      end_user_id,
      %{
        data: data,
        event_type: "error",
        name: name,
      }
    )

    {:noreply, socket}
  end

  def handle_in("create:highcpu", %{"data" => data, "name" => name, "end_user_id" => end_user_id, "client_id" => client_id}, socket) do
    Events.create_event(
      client_id,
      end_user_id,
      %{
        data: data,
        event_type: "highcpu",
        name: name,
      }
    )

    {:noreply, socket}
  end


end
