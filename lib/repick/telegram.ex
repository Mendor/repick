defmodule Repick.Telegram do
  require Logger
  use GenServer

  @server_name Repick.Telegram

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @server_name)
  end

  def init(_) do
    schedule()
    state = %{:offset => 0}
    {:ok, state}
  end

  def handle_cast({:photo, photolist, chat_id, user_id, username}, state) do
    file_id = List.last(photolist).file_id
    {:ok, file} = Nadia.get_file(file_id)
    {:ok, link} = Nadia.get_file_link(file)
    uploaded_url = upload(file_id, link)
    Logger.info("#{username} (id: #{user_id}) uploaded a photo: #{uploaded_url}")
    Nadia.send_message(chat_id, uploaded_url)
    {:noreply, state}
  end

  # API poller callback for new messages sent by Telegram user
  def handle_info(:poll, state) do
    offset = state[:offset]
    # Sometimes we are getting an exception here, thanks Telegram API
    # 'Unexpected token at position 0: <'
    {:ok, updates} = try do
      Nadia.get_updates(limit: 5, offset: offset)
    rescue Poison.SyntaxError ->
      {:ok, []}
    end
    new_offset = process_updates(updates, offset)
    schedule()
    {:noreply, %{state | :offset => new_offset}}
  end

  # API poller scheduler
  defp schedule() do
    Process.send_after(@server_name, :poll, 1000)
  end

  defp process_updates([], offset) do
    offset
  end

  defp process_updates([update | tail], _offset) do
    new_offset = update.update_id + 1
    msg = update.message
    unless msg.photo == [] do
      GenServer.cast(@server_name, {:photo, msg.photo,
                                            msg.chat.id,
                                            msg.from.id,
                                            msg.from.username})
    end
    process_updates(tail, new_offset)
  end

  # TODO: REWRITE THIS SHIT
  defp upload(file_id, link) do
    upload_url = Application.get_env(:repick, :pomf_upload_url)
    download_url = Application.get_env(:repick, :pomf_download_url)

    req_download = HTTPoison.get! link
    body = req_download.body
    temp_file = "/tmp/#{file_id}.jpg"
    {:ok, f} = File.open(temp_file, [:write])
    IO.binwrite(f, body)
    req_upload = HTTPoison.post!(upload_url,
                                 {:multipart, [{:file, temp_file, { ["form-data"], [name: "\"files[]\"", filename: "\"" <> temp_file <> "\""]},[]}]}, [], [])
    {:ok, decoded} = Poison.decode(req_upload.body)
    url = List.first(decoded["files"])["url"]
    "#{download_url}#{url}"
  end
  
end
