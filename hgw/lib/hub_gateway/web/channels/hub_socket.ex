defmodule HubGateway.Web.HubSocket do
  use Phoenix.Socket

  # Channels
  # channel "room:*", HubGateway.Web.RoomChannel
  channel "*", HubGateway.Web.HubChannel

  # Transports
  transport :websocket, Phoenix.Transports.WebSocket,
    serializer: HubGateway.MsgpackSerializer, timeout: :infinity
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(params, socket) do
    if is_binary(params["t"]) do
      {:ok, assign(socket, :token, params["t"])}
    else
      :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     HubGateway.Web.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket) do
    "hubsock:#{socket.topic}"
  end
end
