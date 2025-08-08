defmodule BACnetEDE.Test.ObjectTest do
  use ExUnit.Case

  alias BACnetEDE.Project.Object

  test "new/0 returns struct" do
    assert %Object{} = Object.new()
  end

  test "new/1 returns struct with updated field" do
    assert %Object{device_instance: 5} = Object.new(device_instance: 5)
  end

  test "new/1 returns struct with updated field more_keys" do
    assert %Object{more_keys: %{"a" => 1}} = Object.new(more_keys: %{"a" => 1})
  end

  test "valid?/0 validates struct" do
    assert Object.valid?(
             Object.new(
               keyname: "a",
               device_instance: 10,
               object_name: "Hello",
               object_type: 0,
               object_instance: 5,
               settable: false,
               supports_cov: true,
               more_keys: %{}
             )
           )

    refute Object.valid?(
             Object.new(
               keyname: nil,
               device_instance: 10,
               object_name: "Hello",
               object_type: 0,
               object_instance: 5,
               settable: false,
               supports_cov: true,
               more_keys: %{}
             )
           )

    refute Object.valid?(
             Object.new(
               keyname: "a",
               device_instance: 10,
               object_name: "Hello",
               object_type: 0,
               object_instance: 5,
               settable: false,
               supports_cov: true,
               more_keys: %{nil => true}
             )
           )

    refute Object.valid?(Object.new())
  end
end
