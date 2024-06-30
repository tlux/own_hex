import Config

config :own_hex, :port, 4000
config :own_hex, :registry_dir, "public/registry"
config :own_hex, :docs_dir, "public/docs"
config :own_hex, :private_key_path, "priv/private_key.pem"
config :own_hex, :registry_name, "my_registry"

import_config "#{config_env()}.exs"
