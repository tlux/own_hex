import Config

with {:ok, port} <- System.fetch_env("PORT") do
  config :own_hex, :port, String.to_integer(port)
end

config :own_hex, :registry_name, System.fetch_env("REGISTRY_NAME")

with {:ok, username} <- System.fetch_env("AUTH_USERNAME"),
     {:ok, password} <- System.fetch_env("AUTH_PASSWORD") do
  config :own_hex, :auth, username: username, password: password
end

if config_env() == :prod do
  config :own_hex,
         :registry_dir,
         System.get_env("REGISTRY_DIR", "/registry")

  config :own_hex, :docs_dir, System.get_env("DOCS_DIR", "/docs")

  config :own_hex,
         :private_key_path,
         System.get_env("PRIVATE_KEY_PATH", "/private_key.pem")
else
  with {:ok, registry_dir} <- System.fetch_env("REGISTRY_DIR") do
    config :own_hex, :registry_dir, registry_dir
  end

  with {:ok, docs_dir} <- System.fetch_env("DOCS_DIR") do
    config :own_hex, :docs_dir, docs_dir
  end

  with {:ok, private_key_path} <- System.fetch_env("PRIVATE_KEY_PATH") do
    config :own_hex, :private_key_path, private_key_path
  end
end

config :own_hex, :file_ownership,
  uid:
    (case System.get_env("UID") do
       nil -> nil
       uid -> String.to_integer(uid)
     end),
  gid:
    (case System.get_env("GID") do
       nil -> nil
       gid -> String.to_integer(gid)
     end)

with {:ok, cors_origins} <- System.fetch_env("CORS_ORIGINS") do
  config :cors_plug,
    origin: String.split(cors_origins, ",", trim: true),
    max_age: String.to_integer(System.get_env("CORS_MAX_AGE", "86400")),
    methods: ["GET", "POST", "PUT"]
end
