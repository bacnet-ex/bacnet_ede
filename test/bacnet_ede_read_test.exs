defmodule BACnetEDE.Test.BACnetEDEReadTest do
  use ExUnit.Case

  alias BACnetEDE

  # doctest BACnetEDE

  @basedir Path.join([
             __DIR__,
             "stubs"
           ])

  @sample_data %{
    project_name: "EDEexample",
    version: "1",
    timestamp: ~N[2005-12-19 00:00:00],
    author: "G. Sampler",
    layout_version: "2.2",
    objects: [
      %BACnetEDE.Project.Object{
        keyname: "Building03Room15Temperature",
        device_instance: 10,
        object_name: "RoomTemperature",
        object_type: 0,
        object_instance: 4123,
        description: "This is a Room Temperature",
        default_present_value: "20",
        settable: false,
        supports_cov: false,
        high_limit: 24.0,
        low_limit: 18.0,
        unit_code: 62,
        vendor_specific_address: "T1.128.15",
        more_keys: %{}
      },
      %BACnetEDE.Project.Object{
        keyname: "Building03Room15DamperPosition",
        device_instance: 10,
        object_name: "Damper",
        object_type: 1,
        object_instance: 1234,
        description: "Damper in Duct 2",
        default_present_value: "55",
        min_present_value: 0,
        max_present_value: 100,
        settable: true,
        supports_cov: true,
        unit_code: 98,
        vendor_specific_address: "D12.111.2345",
        more_keys: %{}
      },
      %BACnetEDE.Project.Object{
        keyname: "Building03Room15Damper",
        device_instance: 10,
        object_name: "Damper",
        object_type: 2,
        object_instance: 1111,
        description: "Raw Value Damper",
        default_present_value: "555",
        min_present_value: 0,
        max_present_value: 1000,
        settable: false,
        supports_cov: true,
        unit_code: 95,
        vendor_specific_address: "DR12.111.2345",
        more_keys: %{}
      },
      %BACnetEDE.Project.Object{
        keyname: "Building03Room15",
        device_instance: 10,
        object_name: "ASB03R15",
        object_type: 8,
        object_instance: 10,
        description: "Controller10",
        settable: false,
        supports_cov: false,
        vendor_specific_address: "A1.19.02",
        more_keys: %{}
      },
      %BACnetEDE.Project.Object{
        keyname: "Building17Room01WindowStatus",
        device_instance: 12,
        object_name: "Window",
        object_type: 3,
        object_instance: 4711,
        description: "Window Contact",
        settable: false,
        supports_cov: true,
        state_text_ref: 5432,
        vendor_specific_address: "W123.12.7",
        more_keys: %{}
      },
      %BACnetEDE.Project.Object{
        keyname: "Building17Room01FanMode",
        device_instance: 12,
        object_name: "Fan",
        object_type: 14,
        object_instance: 4711,
        description: "Fan",
        default_present_value: "1",
        min_present_value: 1,
        max_present_value: 5,
        settable: false,
        supports_cov: false,
        state_text_ref: 35,
        vendor_specific_address: "F24242.1234",
        more_keys: %{}
      },
      %BACnetEDE.Project.Object{
        keyname: "Building17Room01Temperature",
        device_instance: 12,
        object_name: "RoomTemperature",
        object_type: 0,
        object_instance: 1000,
        description: "This is a Room Temperature",
        default_present_value: "20",
        settable: false,
        supports_cov: true,
        high_limit: 26.0,
        low_limit: 17.0,
        unit_code: 62,
        vendor_specific_address: "T1.128.01",
        more_keys: %{}
      },
      %BACnetEDE.Project.Object{
        keyname: "Building17Room01",
        device_instance: 12,
        object_name: "ASB17R01",
        object_type: 8,
        object_instance: 12,
        description: "Controller12",
        settable: false,
        supports_cov: false,
        vendor_specific_address: "A1.19.03",
        more_keys: %{}
      }
    ]
  }

  sample_file_contents = File.read!(Path.join([@basedir, "example.csv"]))

  test "parse sample as binary" do
    assert {:ok, %BACnetEDE.Project{} = project} =
             BACnetEDE.from_binary(unquote(sample_file_contents))

    assert BACnetEDE.Project.valid?(project) == true

    assert project.project_name == @sample_data.project_name
    assert project.version == @sample_data.version
    assert project.timestamp_last_change == @sample_data.timestamp
    assert project.author_last_change == @sample_data.author
    assert project.layout_version == @sample_data.layout_version

    assert map_size(project.objects) == length(@sample_data.objects)

    for obj <- @sample_data.objects do
      object = Map.fetch!(project.objects, obj.keyname)
      assert object == obj
    end
  end

  test "parse sample as binary with BOM" do
    assert {:ok, %BACnetEDE.Project{} = _project} =
             BACnetEDE.from_binary(
               :unicode.encoding_to_bom(:utf8) <>
                 String.replace(unquote(sample_file_contents), ";Y;", ";y;")
             )
  end

  test "from_binary invalid keyword opts" do
    assert_raise ArgumentError, fn ->
      BACnetEDE.from_binary("", [:list])
    end
  end

  test "from_binary with validation error" do
    sample = unquote(sample_file_contents)

    sample =
      String.replace(sample, "Building03Room15Temperature;10", "Building03Room15Temperature;")

    assert {:error, str, %BACnetEDE.Project{} = _project} = BACnetEDE.from_binary(sample)
    assert str =~ ~r"Invalid EDE File failed at type validation"
  end

  test "from_binary with disable_with_error" do
    sample = unquote(sample_file_contents)

    sample =
      String.replace(sample, "Building03Room15Temperature;10", "Building03Room15Temperature;")

    assert {:error, str} = BACnetEDE.from_binary(sample, disable_with_error: true)
    assert str =~ ~r"Invalid EDE File failed at type validation"
  end

  test "from_binary with invalid float type error" do
    sample = unquote(sample_file_contents)

    sample =
      String.replace(sample, "N;N;24;18", "N;N;aaa;18")

    assert {:error, {:invalid_float_value, line: 9, column: "hi-limit"}} =
             BACnetEDE.from_binary(sample)
  end

  test "from_binary with invalid integer type error" do
    sample = unquote(sample_file_contents)

    sample =
      String.replace(sample, "62;T1.128.15", "aaaaa;T1.128.15")

    assert {:error, {:invalid_integer_value, line: 9, column: "unit-code"}} =
             BACnetEDE.from_binary(sample)
  end

  test "from_binary with skip type error" do
    sample = unquote(sample_file_contents)

    sample =
      String.replace(sample, "62;T1.128.15", "aaaaa;T1.128.15")

    assert {:ok, project} = BACnetEDE.from_binary(sample, skip_type_errors: true)

    assert project.objects["Building03Room15Temperature"].unit_code == nil
  end

  test "from_binary with and without fixed_mandatory_columns" do
    sample = unquote(sample_file_contents)

    sample =
      String.replace(sample, "device obj.-instance", "device instance")

    assert {:error, str, %BACnetEDE.Project{} = _project} = BACnetEDE.from_binary(sample)
    assert str =~ ~r"Invalid EDE File failed at type validation"

    assert {:ok, %BACnetEDE.Project{} = project} =
             BACnetEDE.from_binary(unquote(sample_file_contents), fixed_mandatory_columns: true)

    assert map_size(project.objects) == length(@sample_data.objects)

    for obj <- @sample_data.objects do
      object = Map.fetch!(project.objects, obj.keyname)
      assert object == obj
    end
  end

  test "from_binary with unsupported layout version" do
    sample = "# PROJECT_NAME;H_W1H3-01_416_HQ_ABT_Site_de_V2;
# VERSION_OF_REFERENCEFILE;1;
# TIMESTAMP_OF_LAST_CHANGE;04.08.2025;
# VERSION_OF_LAYOUT;2.1;
# mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;optional;optional;optional;optional;
# keyname;device-obj-instance;object-name;object-type;object-instance;description;present-value-default;min-present-value;max-present-value;commandValue;hi-limit;low-limit;unit-code;object-tag-text;state-text;
"

    assert {:error, str, %BACnetEDE.Project{} = _project} = BACnetEDE.from_binary(sample)
    assert str =~ ~r"EDE layout version is neither 2.2 nor 2.3"
  end

  test "from_binary cover all word months" do
    months = [
      "Jan",
      "feb",
      "mar",
      "apr",
      "may",
      "mai",
      "jun",
      "jul",
      "aug",
      "sep",
      "oct",
      "okt",
      "nov",
      "dec",
      "dez"
    ]

    for month <- months do
      # CRLF needed instead of LF
      sample =
        String.replace(
          """
          # PROJECT_NAME;H_W1H3-01_416_HQ_ABT_Site_de_V2;
          # VERSION_OF_REFERENCEFILE;1;
          # TIMESTAMP_OF_LAST_CHANGE;04. #{month} 2025;
          # VERSION_OF_LAYOUT;2.3;
          # mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;optional;optional;optional;optional;
          # keyname;device-obj-instance;object-name;object-type;object-instance;description;present-value-default;min-present-value;max-present-value;commandValue;hi-limit;low-limit;unit-code;object-tag-text;state-text;
          """,
          "\n",
          "\r\n"
        )

      assert {:ok, _project} = BACnetEDE.from_binary(sample)
    end
  end

  test "from_binary cover german format with time" do
    # CRLF needed instead of LF
    sample =
      String.replace(
        """
        # PROJECT_NAME;H_W1H3-01_416_HQ_ABT_Site_de_V2;
        # VERSION_OF_REFERENCEFILE;1;
        # TIMESTAMP_OF_LAST_CHANGE;04.08.2025 16:20:15;
        # VERSION_OF_LAYOUT;2.3;
        # mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;optional;optional;optional;optional;
        # keyname;device-obj-instance;object-name;object-type;object-instance;description;present-value-default;min-present-value;max-present-value;commandValue;hi-limit;low-limit;unit-code;object-tag-text;state-text;
        """,
        "\n",
        "\r\n"
      )

    assert {:ok, %BACnetEDE.Project{timestamp_last_change: ~N[2025-08-04 16:20:15]} = _project} =
             BACnetEDE.from_binary(sample)
  end

  test "from_binary cover date format ISO8601" do
    # CRLF needed instead of LF
    sample =
      String.replace(
        """
        # PROJECT_NAME;H_W1H3-01_416_HQ_ABT_Site_de_V2;
        # VERSION_OF_REFERENCEFILE;1;
        # TIMESTAMP_OF_LAST_CHANGE;2005-02-09T11:15:58;
        # VERSION_OF_LAYOUT;2.3;
        # mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;optional;optional;optional;optional;
        # keyname;device-obj-instance;object-name;object-type;object-instance;description;present-value-default;min-present-value;max-present-value;commandValue;hi-limit;low-limit;unit-code;object-tag-text;state-text;
        """,
        "\n",
        "\r\n"
      )

    assert {:ok, %BACnetEDE.Project{timestamp_last_change: ~N[2005-02-09 11:15:58]} = _project} =
             BACnetEDE.from_binary(sample)
  end

  test "from_binary error on unknown word month" do
    # CRLF needed instead of LF
    sample =
      String.replace(
        """
        # PROJECT_NAME;H_W1H3-01_416_HQ_ABT_Site_de_V2;
        # VERSION_OF_REFERENCEFILE;1;
        # TIMESTAMP_OF_LAST_CHANGE;04. something 2025;
        # VERSION_OF_LAYOUT;2.3;
        # mandatory;mandatory;mandatory;mandatory;mandatory;optional;optional;optional;optional;optional;optional;optional;optional;optional;optional;
        # keyname;device-obj-instance;object-name;object-type;object-instance;description;present-value-default;min-present-value;max-present-value;commandValue;hi-limit;low-limit;unit-code;object-tag-text;state-text;
        """,
        "\n",
        "\r\n"
      )

    assert {:error, {{:unknown_timestamp_value, "04. something 2025"}, line: 3}} =
             BACnetEDE.from_binary(sample)
  end

  test "parse sample as file" do
    assert {:ok, %BACnetEDE.Project{} = project} =
             BACnetEDE.from_file(Path.join([@basedir, "example.csv"]))

    assert BACnetEDE.Project.valid?(project) == true

    assert project.project_name == @sample_data.project_name
    assert project.version == @sample_data.version
    assert project.timestamp_last_change == @sample_data.timestamp
    assert project.author_last_change == @sample_data.author
    assert project.layout_version == @sample_data.layout_version

    assert map_size(project.objects) == length(@sample_data.objects)

    for obj <- @sample_data.objects do
      object = Map.fetch!(project.objects, obj.keyname)
      assert object == obj
    end
  end

  test "parse siemens sample as file" do
    assert {:ok, %BACnetEDE.Project{} = project} =
             BACnetEDE.from_binary(
               "# AUTHOR_OF_LAST_CHANGE;;\r\n" <>
                 File.read!(Path.join([@basedir, "siemens.csv"])),
               skip_type_errors: true
             )

    assert BACnetEDE.Project.valid?(project) == true
  end

  test "from_file invalid keyword opts" do
    assert_raise ArgumentError, fn ->
      BACnetEDE.from_file("", [:list])
    end
  end

  test "from_file file does not exist" do
    assert {:error, :enoent} = BACnetEDE.from_file("./samples/something.csv")
  end

  test "parse sample as stream" do
    assert {:ok, %BACnetEDE.Project{} = project} =
             BACnetEDE.from_stream(File.stream!(Path.join([@basedir, "example.csv"])))

    assert BACnetEDE.Project.valid?(project) == true

    assert project.project_name == @sample_data.project_name
    assert project.version == @sample_data.version
    assert project.timestamp_last_change == @sample_data.timestamp
    assert project.author_last_change == @sample_data.author
    assert project.layout_version == @sample_data.layout_version

    assert map_size(project.objects) == length(@sample_data.objects)

    for obj <- @sample_data.objects do
      object = Map.fetch!(project.objects, obj.keyname)
      assert object == obj
    end
  end

  test "from_stream invalid keyword opts" do
    assert_raise ArgumentError, fn ->
      BACnetEDE.from_stream(nil, [:list])
    end
  end

  test "from_stream invalid header" do
    stream = [""]
    assert {:error, {:invalid_header, line: 1}} = BACnetEDE.from_stream(stream)
  end
end
