defmodule BACnetEDE.Test.BACnetEDEWriteTest do
  use ExUnit.Case

  alias BACnetEDE

  # @basedir Path.join([
  #            __DIR__,
  #            "stubs"
  #          ])

  @filepath Path.join([
              System.tmp_dir!(),
              "#{__MODULE__}-#{System.os_time()}-#{trunc(:rand.uniform() * 1_000)}.csv"
            ])

  setup_all do
    File.rm_rf(@filepath)
    :ok
  end

  test "to_binary suceeds with empty objects" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert {:ok, actual} = BACnetEDE.to_binary(project)

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU\r
    PROJECT_NAME;EDEexample\r
    VERSION_OF_REFERENCEFILE;1\r
    TIMESTAMP_OF_LAST_CHANGE;19. Dec 2005\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler\r
    VERSION_OF_LAYOUT;2.3\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address\r
    """

    assert expected == actual
  end

  test "to_binary invalid opts argument" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert_raise ArgumentError, fn ->
      BACnetEDE.to_binary(project, [{5, 6}])
    end
  end

  test "to_binary returns validation error" do
    project = %BACnetEDE.Project{
      project_name: nil,
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert {:error, :invalid_project} = BACnetEDE.to_binary(project)
  end

  test "to_binary with all extra columns" do
    project = %BACnetEDE.Project{
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
            more_keys: %{"commandValue" => "false", "anotherkey" => ""}
          )
      }
    }

    assert {:ok, actual} = BACnetEDE.to_binary(project, dump_all_keys: true)

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU\r
    PROJECT_NAME;EDEexample\r
    VERSION_OF_REFERENCEFILE;1\r
    TIMESTAMP_OF_LAST_CHANGE;19. Dec 2005\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler\r
    VERSION_OF_LAYOUT;2.3\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address;commandValue\r
    a;10;Hello;0;5;;;;;N;Y;;;;;;false\r
    """

    assert expected == actual
  end

  test "to_binary with all rows having same column count" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert {:ok, actual} = BACnetEDE.to_binary(project, fill_all_columns: true)

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU;;;;;;;;;;;;;;;\r
    PROJECT_NAME;EDEexample;;;;;;;;;;;;;;\r
    VERSION_OF_REFERENCEFILE;1;;;;;;;;;;;;;;\r
    TIMESTAMP_OF_LAST_CHANGE;19. Dec 2005;;;;;;;;;;;;;;\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler;;;;;;;;;;;;;;\r
    VERSION_OF_LAYOUT;2.3;;;;;;;;;;;;;;\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address\r
    """

    assert expected == actual
  end

  test "to_binary with all rows having same column count and extra column" do
    project = %BACnetEDE.Project{
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
            more_keys: %{"commandValue" => "false"}
          )
      }
    }

    assert {:ok, actual} =
             BACnetEDE.to_binary(project, fill_all_columns: true, dump_all_keys: true)

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU;;;;;;;;;;;;;;;;\r
    PROJECT_NAME;EDEexample;;;;;;;;;;;;;;;\r
    VERSION_OF_REFERENCEFILE;1;;;;;;;;;;;;;;;\r
    TIMESTAMP_OF_LAST_CHANGE;19. Dec 2005;;;;;;;;;;;;;;;\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler;;;;;;;;;;;;;;;\r
    VERSION_OF_LAYOUT;2.3;;;;;;;;;;;;;;;\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address;commandValue\r
    a;10;Hello;0;5;;;;;;;;;;;;false\r
    """

    assert expected == actual
  end

  test "to_binary test all date format named months" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-02 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    for {month, offset} <- [
          {"Jan", 1},
          {"Feb", 2},
          {"Mar", 3},
          {"Apr", 4},
          {"May", 5},
          {"Jun", 6},
          {"Jul", 7},
          {"Aug", 8},
          {"Sep", 9},
          {"Oct", 10},
          {"Nov", 11},
          {"Dec", 12}
        ] do
      project =
        Map.update!(project, :timestamp_last_change, &NaiveDateTime.add(&1, offset * 31, :day))

      assert {:ok, actual} =
               BACnetEDE.to_binary(project, date_format: :named)

      assert Regex.match?(
               ~r"TIMESTAMP_OF_LAST_CHANGE;\d+\. #{month} 2006",
               actual
             )
    end
  end

  test "to_binary with date format german" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert {:ok, actual} =
             BACnetEDE.to_binary(project, date_format: :german)

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU\r
    PROJECT_NAME;EDEexample\r
    VERSION_OF_REFERENCEFILE;1\r
    TIMESTAMP_OF_LAST_CHANGE;19.12.2005\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler\r
    VERSION_OF_LAYOUT;2.3\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address\r
    """

    assert expected == actual
  end

  test "to_binary with date format german and time" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 01:05:08],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert {:ok, actual} =
             BACnetEDE.to_binary(project, date_format: :german_with_time)

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU\r
    PROJECT_NAME;EDEexample\r
    VERSION_OF_REFERENCEFILE;1\r
    TIMESTAMP_OF_LAST_CHANGE;19.12.2005 01:05:08\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler\r
    VERSION_OF_LAYOUT;2.3\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address\r
    """

    assert expected == actual
  end

  test "to_binary with date format german and time 3" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-02-09 11:15:58],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert {:ok, actual} =
             BACnetEDE.to_binary(project, date_format: :german_with_time)

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU\r
    PROJECT_NAME;EDEexample\r
    VERSION_OF_REFERENCEFILE;1\r
    TIMESTAMP_OF_LAST_CHANGE;09.02.2005 11:15:58\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler\r
    VERSION_OF_LAYOUT;2.3\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address\r
    """

    assert expected == actual
  end

  test "to_binary with date format ISO8601" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-02-09 11:15:58],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert {:ok, actual} =
             BACnetEDE.to_binary(project, date_format: :iso8601)

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU\r
    PROJECT_NAME;EDEexample\r
    VERSION_OF_REFERENCEFILE;1\r
    TIMESTAMP_OF_LAST_CHANGE;2005-02-09T11:15:58\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler\r
    VERSION_OF_LAYOUT;2.3\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address\r
    """

    assert expected == actual
  end

  test "to_binary with date format unknown" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert_raise ArgumentError, fn ->
      BACnetEDE.to_binary(project, date_format: :hello)
    end
  end

  test "to_binary uses latest layout version" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.2",
      objects: %{}
    }

    assert {:ok, actual} = BACnetEDE.to_binary(project)

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU\r
    PROJECT_NAME;EDEexample\r
    VERSION_OF_REFERENCEFILE;1\r
    TIMESTAMP_OF_LAST_CHANGE;19. Dec 2005\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler\r
    VERSION_OF_LAYOUT;2.3\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address\r
    """

    assert expected == actual
  end

  test "to_binary unlock layout version" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.2",
      objects: %{}
    }

    assert {:ok, actual} = BACnetEDE.to_binary(project, unlock_layout_version: true)

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU\r
    PROJECT_NAME;EDEexample\r
    VERSION_OF_REFERENCEFILE;1\r
    TIMESTAMP_OF_LAST_CHANGE;19. Dec 2005\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler\r
    VERSION_OF_LAYOUT;2.2\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address\r
    """

    assert expected == actual
  end

  test "to_file writes non-existing file" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    # Assert it does not exist
    File.rm_rf(@filepath)

    assert :ok == BACnetEDE.to_file(project, @filepath)
    assert File.exists?(@filepath)

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU\r
    PROJECT_NAME;EDEexample\r
    VERSION_OF_REFERENCEFILE;1\r
    TIMESTAMP_OF_LAST_CHANGE;19. Dec 2005\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler\r
    VERSION_OF_LAYOUT;2.3\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address\r
    """

    assert expected == File.read!(@filepath)
  end

  test "to_file writes existing file" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    File.write!(@filepath, "")
    assert :ok = BACnetEDE.to_file(project, @filepath)
  end

  test "to_file invalid opts argument" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert_raise ArgumentError, fn ->
      BACnetEDE.to_file(project, @filepath, [{5, 6}])
    end
  end

  test "to_file returns validation error" do
    project = %BACnetEDE.Project{
      project_name: nil,
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert {:error, :invalid_project} = BACnetEDE.to_file(project, @filepath)
  end

  test "to_stream writes file" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert {:ok, stream} = BACnetEDE.to_stream(project)

    File.write!(@filepath, "")
    Enum.into(stream, File.stream!(@filepath))

    expected = """
    # Engineering-Data-Exchange - B.I.G.-EU\r
    PROJECT_NAME;EDEexample\r
    VERSION_OF_REFERENCEFILE;1\r
    TIMESTAMP_OF_LAST_CHANGE;19. Dec 2005\r
    AUTHOR_OF_LAST_CHANGE;G. Sampler\r
    VERSION_OF_LAYOUT;2.3\r
    #mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;\
    optional;optional;optional;optional;optional\r
    # keyname;device obj.-instance;object-name;object-type;object-instance;description;present-value-default;\
    min-present-value;max-present-value;settable;supports COV;hi-limit;low-limit;state-text-reference;\
    unit-code;vendor-specific-address\r
    """

    assert expected == File.read!(@filepath)
  end

  test "to_stream invalid opts argument" do
    project = %BACnetEDE.Project{
      project_name: "EDEexample",
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert_raise ArgumentError, fn ->
      BACnetEDE.to_stream(project, [{5, 6}])
    end
  end

  test "to_stream returns validation error" do
    project = %BACnetEDE.Project{
      project_name: nil,
      version: "1",
      timestamp_last_change: ~N[2005-12-19 00:00:00],
      author_last_change: "G. Sampler",
      layout_version: "2.3",
      objects: %{}
    }

    assert {:error, :invalid_project} = BACnetEDE.to_stream(project)
  end
end
