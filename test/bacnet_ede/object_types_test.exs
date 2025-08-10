defmodule BACnetEDE.Test.ObjectTypesTest do
  use ExUnit.Case

  alias BACnetEDE.ObjectTypes

  @basedir Path.join([
             __DIR__,
             "stubs"
           ])

  @filepath Path.join([
              System.tmp_dir!(),
              "#{__MODULE__}-#{System.os_time()}-#{trunc(:rand.uniform() * 1_000)}.csv"
            ])

  @example_types %{
    0 => "Analog Input",
    1 => "Analog Output",
    2 => "Analog Value",
    3 => "Binary Input ",
    4 => "Binary Output",
    5 => "Binary Value",
    6 => "Calendar",
    7 => "Command",
    8 => "Device",
    9 => "Event-enrollment",
    10 => "File",
    11 => "Group",
    12 => "Loop",
    13 => "Multistate Input",
    14 => "Multistate Output",
    15 => "Notification Class",
    16 => "Program",
    17 => "Schedule",
    18 => "Averaging",
    19 => "Multistate Value",
    20 => "Trend Log",
    21 => "Life Safety Point",
    22 => "Life Safety Zone",
    23 => "Accumulator",
    24 => "Pulse Converter"
  }

  setup do
    File.rm_rf(@filepath)
    :ok
  end

  test "parse types from binary" do
    contents = File.read!(Path.join([@basedir, "example_ObjTypes.csv"]))

    assert {:ok, %ObjectTypes{object_types: @example_types} = _types} =
             ObjectTypes.from_binary(contents)
  end

  test "parse types from binary invalid opts arg" do
    assert_raise ArgumentError, fn ->
      ObjectTypes.from_binary("", [{5, 4}])
    end
  end

  test "parse types from binary with invalid ref number" do
    contents = """
    #Encoding of BACnet Object Types\r
    #Code;Object Type\r
    a;Analog Input
    """

    assert {:error, {:invalid_reference_number, line: 3}} = ObjectTypes.from_binary(contents)
  end

  test "parse types from file" do
    assert {:ok, %ObjectTypes{object_types: @example_types} = _types} =
             ObjectTypes.from_file(Path.join([@basedir, "example_ObjTypes.csv"]))
  end

  test "parse types from file invalid opts arg" do
    assert_raise ArgumentError, fn ->
      ObjectTypes.from_file("", [{5, 4}])
    end
  end

  test "parse types from stream" do
    contents = File.stream!(Path.join([@basedir, "example_ObjTypes.csv"]))

    assert {:ok, %ObjectTypes{object_types: @example_types} = _types} =
             ObjectTypes.from_stream(contents)
  end

  test "parse types from stream invalid opts arg" do
    assert_raise ArgumentError, fn ->
      ObjectTypes.from_stream([], [{5, 4}])
    end
  end

  test "parse types from binary and check transform" do
    contents = """
    #Encoding of BACnet Object Types\r
    #Code;Object Type\r
    52352;analog_input\r
    """

    assert {:ok, %ObjectTypes{object_types: %{52352 => "Analog Input"}} = _types} =
             ObjectTypes.from_binary(contents)
  end

  test "encode types to binary" do
    assert {:ok, contents} =
             ObjectTypes.to_binary(%ObjectTypes{
               object_types: %{
                 0 => "Analog Input"
               }
             })

    expected = """
    #Encoding of BACnet Object Types\r
    #Code;Object Type\r
    0;Analog Input\r
    """

    assert expected == contents
  end

  test "encode empty types to binary" do
    assert {:ok, contents} =
             ObjectTypes.to_binary(%ObjectTypes{object_types: %{}})

    expected = """
    #Encoding of BACnet Object Types\r
    #Code;Object Type\r
    """

    assert expected == contents
  end

  test "encode types to binary with all columns" do
    assert {:ok, contents} =
             ObjectTypes.to_binary(
               %ObjectTypes{
                 object_types: %{
                   62 => "Analog Input"
                 }
               },
               fill_all_columns: true
             )

    expected = """
    #Encoding of BACnet Object Types;\r
    #Code;Object Type\r
    62;Analog Input\r
    """

    assert expected == contents
  end

  test "encode types to binary invalid opts arg" do
    assert_raise ArgumentError, fn ->
      ObjectTypes.to_binary(%ObjectTypes{object_types: %{}}, [{5, 4}])
    end
  end

  test "encode types to file" do
    assert :ok =
             ObjectTypes.to_file(
               %ObjectTypes{
                 object_types: %{
                   0 => "Analog Input"
                 }
               },
               @filepath
             )

    contents = File.read!(@filepath)

    expected = """
    #Encoding of BACnet Object Types\r
    #Code;Object Type\r
    0;Analog Input\r
    """

    assert expected == contents
  end

  test "encode types to existing file" do
    File.write!(@filepath, "EDE")

    assert :ok =
             ObjectTypes.to_file(
               %ObjectTypes{
                 object_types: %{
                   0 => "Analog Input"
                 }
               },
               @filepath
             )

    contents = File.read!(@filepath)

    expected = """
    #Encoding of BACnet Object Types\r
    #Code;Object Type\r
    0;Analog Input\r
    """

    assert expected == contents
  end

  test "encode types to file invalid opts arg" do
    assert_raise ArgumentError, fn ->
      ObjectTypes.to_file(%ObjectTypes{object_types: %{}}, "", [{5, 4}])
    end
  end

  test "encode types to stream" do
    assert {:ok, stream} =
             ObjectTypes.to_stream(%ObjectTypes{
               object_types: %{
                 0 => "Analog Input",
                 1 => "Analog Output"
               }
             })

    contents =
      stream
      |> Enum.to_list()
      |> IO.iodata_to_binary()

    expected = """
    #Encoding of BACnet Object Types\r
    #Code;Object Type\r
    0;Analog Input\r
    1;Analog Output\r
    """

    assert expected == contents
  end

  test "encode types to stream invalid opts arg" do
    assert_raise ArgumentError, fn ->
      ObjectTypes.to_stream(%ObjectTypes{object_types: %{}}, [{5, 4}])
    end
  end
end
