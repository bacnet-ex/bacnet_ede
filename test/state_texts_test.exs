defmodule BACnetEDE.Test.StateTextsTest do
  use ExUnit.Case

  alias BACnetEDE.StateTexts

  @basedir Path.join([
             __DIR__,
             "stubs"
           ])

  @filepath Path.join([
              System.tmp_dir!(),
              "#{__MODULE__}-#{System.os_time()}-#{trunc(:rand.uniform() * 1_000)}.csv"
            ])

  setup do
    File.rm_rf(@filepath)
    :ok
  end

  test "parse state text from binary" do
    contents = File.read!(Path.join([@basedir, "example_StateTexts.csv"]))

    assert {:ok,
            %StateTexts{
              texts: %{
                4 => ["OFF", "State 1", "State 2", "State 3", "State 4"],
                22 => ["OFF", "ON"],
                35 => ["OFF", "AUTO", "STAGE 1", "STAGE 2", "STAGE 3"],
                120 => ["DARK", "BRIGHT"],
                121 => ["ON", "OFF"],
                5432 => ["OPEN", "CLOSED"]
              }
            } = _texts} = StateTexts.from_binary(contents)
  end

  test "parse state text from binary invalid opts arg" do
    assert_raise ArgumentError, fn ->
      StateTexts.from_binary("", [{5, 4}])
    end
  end

  test "parse state text from binary with invalid ref number" do
    contents = """
    #State Text Reference\r
    #Reference Number;Text 1 or Inactive-Text;Text 2 or Active-Text;Text 3;Text 4;Text 5\r
    Test;OFF;State 1;State 2;State 3;State 4\r
    """

    assert {:error, {:invalid_reference_number, line: 3}} = StateTexts.from_binary(contents)
  end

  test "parse state text from file" do
    assert {:ok,
            %StateTexts{
              texts: %{
                4 => ["OFF", "State 1", "State 2", "State 3", "State 4"],
                22 => ["OFF", "ON"],
                35 => ["OFF", "AUTO", "STAGE 1", "STAGE 2", "STAGE 3"],
                120 => ["DARK", "BRIGHT"],
                121 => ["ON", "OFF"],
                5432 => ["OPEN", "CLOSED"]
              }
            } = _texts} = StateTexts.from_file(Path.join([@basedir, "example_StateTexts.csv"]))
  end

  test "parse state text from file invalid opts arg" do
    assert_raise ArgumentError, fn ->
      StateTexts.from_file("", [{5, 4}])
    end
  end

  test "parse state text from stream" do
    contents = File.stream!(Path.join([@basedir, "example_StateTexts.csv"]))

    assert {:ok,
            %StateTexts{
              texts: %{
                4 => ["OFF", "State 1", "State 2", "State 3", "State 4"],
                22 => ["OFF", "ON"],
                35 => ["OFF", "AUTO", "STAGE 1", "STAGE 2", "STAGE 3"],
                120 => ["DARK", "BRIGHT"],
                121 => ["ON", "OFF"],
                5432 => ["OPEN", "CLOSED"]
              }
            } = _texts} = StateTexts.from_stream(contents)
  end

  test "parse state text from stream invalid opts arg" do
    assert_raise ArgumentError, fn ->
      StateTexts.from_stream([], [{5, 4}])
    end
  end

  test "encode state text to binary" do
    assert {:ok, contents} =
             StateTexts.to_binary(%StateTexts{
               texts: %{
                 4 => ["OFF", "State 1", "State 2", "State 3", "State 4"],
                 22 => ["OFF", "ON"],
                 35 => ["OFF", "AUTO", "STAGE 1", "STAGE 2", "STAGE 3"],
                 120 => ["DARK", "BRIGHT"],
                 121 => ["ON", "OFF"],
                 5432 => ["OPEN", "CLOSED"]
               }
             })

    expected = """
    #State Text Reference\r
    #Reference Number;Text 1 or Inactive-Text;Text 2 or Active-Text;Text 3;Text 4;Text 5\r
    4;OFF;State 1;State 2;State 3;State 4\r
    22;OFF;ON;;;\r
    35;OFF;AUTO;STAGE 1;STAGE 2;STAGE 3\r
    120;DARK;BRIGHT;;;\r
    121;ON;OFF;;;\r
    5432;OPEN;CLOSED;;;\r
    """

    assert expected == contents
  end

  test "encode empty state text to binary" do
    assert {:ok, contents} =
             StateTexts.to_binary(%StateTexts{texts: %{}})

    expected = """
    #State Text Reference\r
    #Reference Number;Text 1 or Inactive-Text;Text 2 or Active-Text\r
    """

    assert expected == contents
  end

  test "encode state text to binary with all columns" do
    assert {:ok, contents} =
             StateTexts.to_binary(
               %StateTexts{
                 texts: %{
                   4 => ["OFF", "State 1", "State 2", "State 3", "State 4"],
                   22 => ["OFF", "ON"],
                   35 => ["OFF", "AUTO", "STAGE 1", "STAGE 2", "STAGE 3"],
                   120 => ["DARK", "BRIGHT"],
                   121 => ["ON", "OFF"],
                   5432 => ["OPEN", "CLOSED"]
                 }
               },
               fill_all_columns: true
             )

    expected = """
    #State Text Reference;;;;;\r
    #Reference Number;Text 1 or Inactive-Text;Text 2 or Active-Text;Text 3;Text 4;Text 5\r
    4;OFF;State 1;State 2;State 3;State 4\r
    22;OFF;ON;;;\r
    35;OFF;AUTO;STAGE 1;STAGE 2;STAGE 3\r
    120;DARK;BRIGHT;;;\r
    121;ON;OFF;;;\r
    5432;OPEN;CLOSED;;;\r
    """

    assert expected == contents
  end

  test "encode state text to binary invalid opts arg" do
    assert_raise ArgumentError, fn ->
      StateTexts.to_binary(%StateTexts{texts: %{}}, [{5, 4}])
    end
  end

  test "encode state text to file" do
    assert :ok =
             StateTexts.to_file(
               %StateTexts{
                 texts: %{
                   4 => ["OFF", "State 1", "State 2", "State 3", "State 4"],
                   22 => ["OFF", "ON"],
                   35 => ["OFF", "AUTO", "STAGE 1", "STAGE 2", "STAGE 3"],
                   120 => ["DARK", "BRIGHT"],
                   121 => ["ON", "OFF"],
                   5432 => ["OPEN", "CLOSED"]
                 }
               },
               @filepath
             )

    contents = File.read!(@filepath)

    expected = """
    #State Text Reference\r
    #Reference Number;Text 1 or Inactive-Text;Text 2 or Active-Text;Text 3;Text 4;Text 5\r
    4;OFF;State 1;State 2;State 3;State 4\r
    22;OFF;ON;;;\r
    35;OFF;AUTO;STAGE 1;STAGE 2;STAGE 3\r
    120;DARK;BRIGHT;;;\r
    121;ON;OFF;;;\r
    5432;OPEN;CLOSED;;;\r
    """

    assert expected == contents
  end

  test "encode state text to existing file" do
    File.write!(@filepath, "EDE")

    assert :ok =
             StateTexts.to_file(
               %StateTexts{
                 texts: %{
                   4 => ["OFF", "State 1", "State 2", "State 3", "State 4"],
                   22 => ["OFF", "ON"],
                   35 => ["OFF", "AUTO", "STAGE 1", "STAGE 2", "STAGE 3"],
                   120 => ["DARK", "BRIGHT"],
                   121 => ["ON", "OFF"],
                   5432 => ["OPEN", "CLOSED"]
                 }
               },
               @filepath
             )

    contents = File.read!(@filepath)

    expected = """
    #State Text Reference\r
    #Reference Number;Text 1 or Inactive-Text;Text 2 or Active-Text;Text 3;Text 4;Text 5\r
    4;OFF;State 1;State 2;State 3;State 4\r
    22;OFF;ON;;;\r
    35;OFF;AUTO;STAGE 1;STAGE 2;STAGE 3\r
    120;DARK;BRIGHT;;;\r
    121;ON;OFF;;;\r
    5432;OPEN;CLOSED;;;\r
    """

    assert expected == contents
  end

  test "encode state text to file invalid opts arg" do
    assert_raise ArgumentError, fn ->
      StateTexts.to_file(%StateTexts{texts: %{}}, "", [{5, 4}])
    end
  end

  test "encode state text to stream" do
    assert {:ok, stream} =
             StateTexts.to_stream(%StateTexts{
               texts: %{
                 4 => ["OFF", "State 1", "State 2", "State 3", "State 4"],
                 22 => ["OFF", "ON"],
                 35 => ["OFF", "AUTO", "STAGE 1", "STAGE 2", "STAGE 3"],
                 120 => ["DARK", "BRIGHT"],
                 121 => ["ON", "OFF"],
                 5432 => ["OPEN", "CLOSED"]
               }
             })

    contents =
      stream
      |> Enum.to_list()
      |> IO.iodata_to_binary()

    expected = """
    #State Text Reference\r
    #Reference Number;Text 1 or Inactive-Text;Text 2 or Active-Text;Text 3;Text 4;Text 5\r
    4;OFF;State 1;State 2;State 3;State 4\r
    22;OFF;ON;;;\r
    35;OFF;AUTO;STAGE 1;STAGE 2;STAGE 3\r
    120;DARK;BRIGHT;;;\r
    121;ON;OFF;;;\r
    5432;OPEN;CLOSED;;;\r
    """

    assert expected == contents
  end

  test "encode state text to stream invalid opts arg" do
    assert_raise ArgumentError, fn ->
      StateTexts.to_stream(%StateTexts{texts: %{}}, [{5, 4}])
    end
  end

  test "encode state text invalid texts" do
    assert {:error, :invalid_state_texts} =
             StateTexts.to_binary(%StateTexts{texts: %{5 => [5.0]}})

    assert {:error, :invalid_state_texts} =
             StateTexts.to_file(%StateTexts{texts: %{5 => [5.0]}}, @filepath)

    assert {:error, :invalid_state_texts} =
             StateTexts.to_stream(%StateTexts{texts: %{5 => [5.0]}})
  end

  test "validate state text" do
    assert true == StateTexts.valid?(%StateTexts{texts: %{}})
    assert true == StateTexts.valid?(%StateTexts{texts: %{5 => []}})
    assert true == StateTexts.valid?(%StateTexts{texts: %{5 => ["hello"]}})
    assert true == StateTexts.valid?(%StateTexts{texts: %{5 => ["hello", "wolrd"]}})
    assert false == StateTexts.valid?(%StateTexts{texts: %{5.0 => []}})
    assert false == StateTexts.valid?(%StateTexts{texts: %{5 => [5.0]}})
    assert false == StateTexts.valid?(%StateTexts{texts: %{5 => ["hello", 5.0]}})
  end
end
