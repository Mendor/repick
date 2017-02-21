defmodule Repick do
  use Application

  def start(_type, _args) do
    config_file = Application.fetch_env!(:repick, :config_file)
    config_path = File.cwd! |> Path.join(config_file)
    parsed_config = YamlElixir.read_from_file(config_path)

    Application.put_env(:nadia, :token, parsed_config["telegram_bot_token"])
    Application.put_env(:repick, :pomf_upload_url, parsed_config["pomf_upload_url"])
    Application.put_env(:repick, :pomf_download_url, parsed_config["pomf_download_url"])

    import Supervisor.Spec, warn: false
    children = [
      worker(Repick.Telegram, [])
    ]

    opts = [strategy: :one_for_one, name: Repick.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
