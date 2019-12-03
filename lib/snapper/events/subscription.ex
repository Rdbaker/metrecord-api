defmodule Metrecord.Events.Subscription do
  import HTTPoison
  import Poison

  def get_invoice_for_subscription(sub_id) do
    url = "https://api.stripe.com/v1/invoices/upcoming?subscription=#{sub_id}"
    headers = %{
      "Content-Type" => "application/x-www-form-urlencoded",
      "Authorization" => "Bearer #{Application.get_env(:stripe, :secret_key)}"
    }
    case HTTPoison.get(url, headers) do
      {:ok, %{status_code: 200, body: body}} -> Poison.Parser.parse! body, %{}
      {:ok, e} ->
        IO.inspect e
        nil
      {:error, e} ->
        IO.inspect e
        nil
    end
  end

  def record_event_for_subscription(sub, event_id) do
    Enum.map(
      sub["items"]["data"],
      fn item -> record_event_for_subscription_item(item["id"], "#{event_id}-#{item["id"]}") end
    )
  end

  defp record_event_for_subscription_item(item_id, event_id) do
    url = "https://api.stripe.com/v1/subscription_items/#{item_id}/usage_records"
    body = URI.encode_query(%{
      "timestamp" => DateTime.to_unix(DateTime.utc_now()),
      "quantity" => 1,
      "action" => "increment"
    })
    headers = %{
      "Idempotency-Key" => event_id,
      "Content-Type" => "application/x-www-form-urlencoded",
      "Authorization" => "Bearer #{Application.get_env(:stripe, :secret_key)}"
    }
    case HTTPoison.post(url, body, headers) do
      {:ok, %{status_code: 200, body: body}} -> %{}
      {:ok, e} ->
        IO.inspect e
        %{}
      {:error, e} ->
        IO.inspect e
        %{}
    end
  end
end
