defmodule BACnetEDE.Test.BACnetEDE.ProjectTest do
  use ExUnit.Case

  alias BACnetEDE.Project

  test "new/0 returns struct" do
    assert %Project{} = Project.new()
  end

  test "new/1 returns struct with updated field" do
    assert %Project{project_name: "Hello"} = Project.new(project_name: "Hello")
  end

  test "new/1 returns struct with updated field author" do
    assert %Project{author_last_change: "Hello"} = Project.new(author_last_change: "Hello")
  end

  test "new/1 returns struct with updated field objects" do
    assert %Project{objects: %{"a" => 1}} = Project.new(objects: %{"a" => 1})
  end

  test "new/1 returns struct with field author_last_change as string" do
    assert %Project{author_last_change: ""} = Project.new(author_last_change: nil)
  end

  test "new/1 returns struct with field objects as map" do
    assert %Project{objects: %{}} = Project.new(objects: nil)
  end

  test "valid?/0 validates struct" do
    assert Project.valid?(%Project{
             project_name: "EDEexample",
             version: "1",
             timestamp_last_change: ~N[2005-12-19 00:00:00],
             author_last_change: "G. Sampler",
             layout_version: "2.3",
             objects: %{
               "a" =>
                 BACnetEDE.Project.Object.new(
                   keyname: "a",
                   device_instance: 10,
                   object_name: "Hello",
                   object_type: 0,
                   object_instance: 5,
                   settable: false,
                   supports_cov: true,
                   more_keys: %{}
                 )
             }
           })

    refute Project.valid?(%Project{
             project_name: "EDEexample",
             version: "1",
             timestamp_last_change: ~N[2005-12-19 00:00:00],
             author_last_change: "G. Sampler",
             layout_version: "2.3",
             objects: %{
               "a" =>
                 BACnetEDE.Project.Object.new(
                   keyname: nil,
                   device_instance: 10,
                   object_name: "Hello",
                   object_type: 0,
                   object_instance: 5,
                   settable: false,
                   supports_cov: true,
                   more_keys: %{}
                 )
             }
           })

    refute Project.valid?(%Project{
             project_name: "EDEexample",
             version: "1",
             timestamp_last_change: ~N[2005-12-19 00:00:00],
             author_last_change: "G. Sampler",
             layout_version: "2.3",
             objects: %{nil => true}
           })

    refute Project.valid?(Project.new())
  end
end
