defmodule ExBinance.Rest.CancelAllOrders do
  alias ExBinance.Rest.HTTPClient
  alias ExBinance.Timestamp

  @type symbol :: String.t()
  @type credentials :: ExBinance.Credentials.t()
  @type ok_response :: ExBinance.Responses.CancelOrder.t()
  @type error_msg :: String.t()
  @type error_reason :: {:not_found, error_msg} | ExBinance.Rest.HTTPClient.shared_errors()

  @path "/api/v3/openOrders"
  @receiving_window 1000

  @spec cancel_all_orders(symbol, credentials) ::
          {:ok, ok_response} | {:error, error_reason}
  def cancel_all_orders(symbol, credentials) do
    params = %{
      symbol: symbol,
      timestamp: Timestamp.now(),
      recvWindow: @receiving_window
    }

    @path
    |> HTTPClient.delete(params, credentials)
    |> parse_response()
  end

  defp parse_response({:ok, response}), do:
    {:ok, Enum.reduce(response, [],
    fn
      (%{"orderId" => _} = r, acc) -> [ExBinance.Responses.CancelOrder.new(r) | acc]
      (_, acc) -> acc
    end)
  }

  defp parse_response({:error, {:binance_error, %{"code" => -2011, "msg" => msg}}}),
    do: {:error, {:not_found, msg}}

  defp parse_response({:error, _} = error), do: error
end
