defmodule Cross.Router do #committtttt
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> Plug.Conn.fetch_query_params
    Plug.Conn.assign(conn, :response, Storage.read(conn.params["key"]))
    |> result
  end
  post "/" do
    conn
    |> Plug.Conn.fetch_query_params
    {ttl, _} = Integer.parse(conn.params["ttl"])
    Plug.Conn.assign(conn, :response, Storage.create(conn.params["key"], conn.params["value"], ttl))
    |> result
  end
  put "/" do
    conn
    |> Plug.Conn.fetch_query_params
    Plug.Conn.assign(conn, :response, Storage.update(conn.params["key"], conn.params["value"]))
    |> result
  end
  delete "/" do
    conn
    |> Plug.Conn.fetch_query_params
    Plug.Conn.assign(conn, :response, Storage.delete(conn.params["key"]))
    |> result
  end

  defp result(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, Poison.encode!(conn.assigns[:response]))
  end

  match _, do: send_resp(conn, 404, "Oops!")

end
