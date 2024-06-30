defmodule OwnHexWeb.ParamsTest do
  use ExUnit.Case, async: true

  alias OwnHexWeb.Params

  describe "param/4" do
    test "int param" do
      assert Params.param(plug_params(%{"foo" => "123"}), :foo, :int) == 123

      assert Params.param(plug_params(%{"foo" => "123"}), "foo", :int, 234) ==
               123

      assert Params.param(plug_params(%{"foo" => "123.0"}), :foo, :int, 234) ==
               234
    end

    test "string param" do
      assert Params.param(plug_params(%{"foo" => "bar"}), :foo, :string) ==
               "bar"

      assert Params.param(plug_params(%{"foo" => "bar"}), "foo", :string, "baz") ==
               "bar"

      assert Params.param(plug_params(%{"foo" => :bar}), :foo, :string, "baz") ==
               "baz"
    end
  end

  def plug_params(params) when is_map(params) do
    %Plug.Conn{params: params}
  end
end
