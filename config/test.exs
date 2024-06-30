import Config

config :own_hex, :auth, username: "hex", password: "s3cret"
config :own_hex, :registry_dir, "tmp/registry_test"
config :own_hex, :docs_dir, "tmp/docs_test"
config :own_hex, :private_key_path, "test/fixtures/private_key.pem"

config :own_hex, OwnHex.Packages, OwnHex.Packages.Mock

config :own_hex,
       OwnHex.Packages.Publisher,
       OwnHex.Packages.Publisher.Mock

config :own_hex,
       OwnHex.Packages.Publisher.Server,
       OwnHex.Packages.Publisher.Mock

config :own_hex, OwnHex.Registry, OwnHex.Registry.Mock
