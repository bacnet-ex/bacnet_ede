defmodule BACnetEDE.Test.UnitsTest do
  use ExUnit.Case

  alias BACnetEDE.Units

  @basedir Path.join([
             __DIR__,
             "..",
             "stubs"
           ])

  @filepath Path.join([
              System.tmp_dir!(),
              "#{__MODULE__}-#{System.os_time()}-#{trunc(:rand.uniform() * 1_000)}.csv"
            ])

  @example_units %{
    166 => "meters-per-second-per-second",
    39 => "kilograms",
    130 => "megahertz",
    222 => "becquerels",
    74 => "meters-per-second",
    135 => "cubic-meters-per-hour",
    253 => "pascal-seconds",
    232 => "decibels-a",
    218 => "milligrams-per-cubic-meter",
    59 => "millimeters-of-mercury",
    69 => "weeks",
    152 => "megajoules-per-degree-kelvin",
    67 => "years",
    170 => "farads",
    120 => "delta-degrees-fahrenheit",
    189 => "watts-per-meter-per-degree-kelvin",
    45 => "pounds-mass-per-minute",
    221 => "grams-per-cubic-centimeter",
    50 => "btus-per-hour",
    22 => "ton-hours",
    102 => "psi-per-degree-fahrenheit",
    121 => "delta-degrees-kelvin",
    217 => "grams-per-cubic-meter",
    51 => "horsepower",
    26 => "cycles-per-minute",
    124 => "millivolts",
    129 => "kilohertz",
    63 => "degrees-kelvin",
    47 => "watts",
    85 => "cubic-meters-per-second",
    251 => "joules-per-cubic-meter",
    27 => "hertz",
    47815 => "millirems-per-hour",
    77 => "feet-per-minute",
    0 => "square-meters",
    252 => "mole-percent",
    122 => "kilohms",
    5 => "volts",
    21 => "therms",
    86 => "imperial-gallons-per-minute",
    185 => "square-meters-per-newton",
    248 => "cubic-feet-per-day",
    173 => "siemens",
    245 => "volt-square-hours",
    62 => "degrees-celsius",
    30 => "millimeters",
    16 => "joules",
    3 => "amperes",
    206 => "millimeters-of-water",
    159 => "milliseconds",
    243 => "kilovolt-ampere-hours-reactive",
    53 => "pascals",
    33 => "feet",
    190 => "micro-siemens",
    162 => "millimeters-per-minute",
    244 => "megavolt-ampere-hours-reactive",
    210 => "grams-per-kilogram",
    14 => "degrees-phase",
    40 => "pounds-mass",
    37 => "luxes",
    24 => "btus-per-pound-dry-air",
    17 => "kilojoules",
    48 => "kilowatts",
    88 => "liters-per-minute",
    89 => "us-gallons-per-minute",
    249 => "cubic-meters-per-day",
    73 => "seconds",
    167 => "amperes-per-meter",
    148 => "mega-btus",
    119 => "pounds-mass-per-second",
    161 => "millimeters-per-second",
    81 => "imperial-gallons",
    11 => "volt-amperes-reactive",
    57 => "centimeters-of-water",
    158 => "hundredths-seconds",
    47808 => "standard-cubic-feet-per-day",
    43 => "kilograms-per-minute",
    83 => "us-gallons",
    186 => "kilograms-per-cubic-meter",
    138 => "kilowatt-hours-per-square-foot",
    193 => "kilometers",
    231 => "microsieverts-per-hour",
    174 => "siemens-per-meter",
    95 => "no-units",
    144 => "percent-obscuration-per-meter",
    199 => "decibels",
    214 => "grams-per-liter",
    6 => "kilovolts",
    184 => "radians-per-second",
    87 => "liters-per-second",
    20 => "btus",
    108 => "currency4",
    60 => "centimeters-of-mercury",
    107 => "currency3",
    47812 => "pounds-mass-per-day",
    145 => "milliohms",
    200 => "decibels-millivolt",
    223 => "kilobecquerels",
    28 => "grams-of-water-per-kilogram-dry-air",
    142 => "cubic-feet-per-second",
    25 => "cycles-per-hour",
    225 => "gray",
    177 => "volts-per-meter",
    1 => "square-feet",
    205 => "megawatt-hours-reactive",
    196 => "milligrams",
    133 => "hectopascals",
    197 => "milliliters",
    208 => "grams-per-gram",
    151 => "kilojoules-per-degree-kelvin",
    58 => "inches-of-water",
    242 => "volt-ampere-hours-reactive",
    32 => "inches",
    97 => "parts-per-billion",
    227 => "microgray",
    228 => "sieverts",
    165 => "cubic-meters-per-minute",
    155 => "grams-per-minute",
    126 => "megajoules",
    76 => "feet-per-second",
    36 => "lumens",
    35 => "watts-per-square-meter",
    216 => "micrograms-per-liter",
    180 => "candelas-per-square-meter",
    254 => "million-standard-cubic-feet-per-minute",
    117 => "btus-per-pound",
    188 => "newtons-per-meter",
    15 => "power-factor",
    80 => "cubic-meters",
    78 => "miles-per-hour",
    106 => "currency2",
    64 => "degrees-fahrenheit",
    131 => "per-hour",
    75 => "kilometers-per-hour",
    219 => "micrograms-per-cubic-meter",
    195 => "grams",
    109 => "currency5",
    66 => "degree-days-fahrenheit",
    118 => "centimeters",
    71 => "hours",
    198 => "milliliters-per-second",
    103 => "radians",
    224 => "megabecquerels",
    209 => "kilograms-per-kilogram",
    125 => "kilojoules-per-kilogram",
    183 => "joule-seconds",
    79 => "cubic-feet",
    49 => "megawatts",
    163 => "meters-per-minute",
    82 => "liters",
    9 => "kilovolt-amperes",
    203 => "watt-hours-reactive",
    112 => "currency8",
    220 => "nanograms-per-cubic-meter",
    215 => "milligrams-per-liter",
    23 => "joules-per-kilogram-dry-air",
    101 => "per-second",
    10 => "megavolt-amperes",
    47810 => "thousand-cubic-feet-per-day",
    44 => "kilograms-per-hour",
    47809 => "million-standard-cubic-feet-per-day",
    157 => "kilo-btus-per-hour",
    181 => "degrees-kelvin-per-hour",
    175 => "teslas",
    143 => "percent-obscuration-per-foot",
    111 => "currency7",
    8 => "volt-amperes",
    116 => "square-centimeters",
    246 => "ampere-square-hours",
    70 => "days",
    236 => "minutes-per-degree-kelvin",
    147 => "kilo-btus",
    250 => "watt-hours-per-cubic-meter",
    229 => "millisieverts",
    176 => "volts-per-degree-kelvin",
    127 => "joules-per-degree-kelvin",
    238 => "ampere-seconds",
    204 => "kilowatt-hours-reactive",
    178 => "webers",
    134 => "millibars",
    172 => "ohm-meters",
    115 => "square-inches",
    105 => "currency1",
    241 => "megavolt-ampere-hours",
    31 => "meters",
    187 => "newton-seconds",
    47811 => "thousand-standard-cubic-feet-per-day",
    104 => "revolutions-per-minute",
    230 => "microsieverts",
    141 => "watts-per-square-meter-degree-kelvin",
    137 => "kilowatt-hours-per-square-meter",
    65 => "degree-days-celsius",
    237 => "ohm-meter-squared-per-meter",
    201 => "decibels-volt",
    113 => "currency9",
    99 => "percent-per-second",
    61 => "inches-of-mercury",
    153 => "newton",
    56 => "pounds-force-per-square-inch",
    38 => "foot-candles",
    90 => "degrees-angular",
    7 => "megavolts",
    98 => "percent",
    233 => "nephelometric-turbidity-unit",
    192 => "us-gallons-per-hour",
    202 => "millisiemens",
    191 => "cubic-feet-per-hour",
    146 => "megawatt-hours",
    2 => "milliamperes",
    55 => "bars",
    149 => "kilojoules-per-kilogram-dry-air",
    42 => "kilograms-per-second",
    13 => "megavolt-amperes-reactive",
    140 => "megajoules-per-square-foot",
    171 => "henrys",
    29 => "percent-relative-humidity",
    100 => "per-minute",
    114 => "currency10",
    41 => "tons",
    212 => "milligrams-per-kilogram",
    139 => "megajoules-per-square-meter",
    164 => "meters-per-hour",
    91 => "degrees-celsius-per-hour",
    110 => "currency6",
    213 => "grams-per-milliliter",
    19 => "kilowatt-hours",
    182 => "degrees-kelvin-per-minute",
    12 => "kilovolt-amperes-reactive",
    156 => "tons-per-hour",
    234 => "pH",
    123 => "megohms",
    92 => "degrees-celsius-per-minute",
    154 => "grams-per-second",
    150 => "megajoules-per-kilogram-dry-air",
    52 => "tons-refrigeration",
    207 => "per-mille",
    132 => "milliwatts",
    168 => "amperes-per-square-meter",
    46 => "pounds-mass-per-hour",
    194 => "micrometers",
    247 => "joule-per-hours",
    128 => "joules-per-kilogram-degree-kelvin",
    211 => "milligrams-per-gram",
    240 => "kilovolt-ampere-hours",
    226 => "milligray",
    235 => "grams-per-square-meter",
    34 => "watts-per-square-foot",
    93 => "degrees-fahrenheit-per-hour",
    68 => "months",
    179 => "candelas",
    72 => "minutes",
    239 => "volt-ampere-hours",
    136 => "liters-per-hour",
    4 => "ohms",
    160 => "newton-meters",
    84 => "cubic-feet-per-minute",
    94 => "degrees-fahrenheit-per-minute",
    96 => "parts-per-million",
    169 => "ampere-square-meters",
    18 => "watt-hours",
    54 => "kilopascals",
    47814 => "millirems"
  }

  setup do
    File.rm_rf(@filepath)
    :ok
  end

  test "parse units from binary" do
    contents = File.read!(Path.join([@basedir, "example_Units.csv"]))

    assert {:ok, %Units{units: @example_units} = _units} = Units.from_binary(contents)
  end

  test "parse units from binary invalid opts arg" do
    assert_raise ArgumentError, fn ->
      Units.from_binary("", [{5, 4}])
    end
  end

  test "parse units from binary with invalid ref number" do
    contents = """
    #Encoding of BACnet Engineering Units\r
    #Code;Unit Text\r
    a;degrees-celsius
    """

    assert {:error, {:invalid_reference_number, line: 3}} = Units.from_binary(contents)
  end

  test "parse units from file" do
    assert {:ok, %Units{units: @example_units} = _units} =
             Units.from_file(Path.join([@basedir, "example_Units.csv"]))
  end

  test "parse units from file invalid opts arg" do
    assert_raise ArgumentError, fn ->
      Units.from_file("", [{5, 4}])
    end
  end

  test "parse units from stream" do
    contents = File.stream!(Path.join([@basedir, "example_Units.csv"]))

    assert {:ok, %Units{units: @example_units} = _units} = Units.from_stream(contents)
  end

  test "parse units from stream invalid opts arg" do
    assert_raise ArgumentError, fn ->
      Units.from_stream([], [{5, 4}])
    end
  end

  test "encode units to binary" do
    assert {:ok, contents} =
             Units.to_binary(%Units{
               units: %{
                 62 => "degrees-celsius"
               }
             })

    expected = """
    #Encoding of BACnet Engineering Units\r
    #Code;Unit Text\r
    62;degrees-celsius\r
    """

    assert expected == contents
  end

  test "encode empty units to binary" do
    assert {:ok, contents} =
             Units.to_binary(%Units{units: %{}})

    expected = """
    #Encoding of BACnet Engineering Units\r
    #Code;Unit Text\r
    """

    assert expected == contents
  end

  test "encode units to binary with all columns" do
    assert {:ok, contents} =
             Units.to_binary(
               %Units{
                 units: %{
                   62 => "degrees-celsius"
                 }
               },
               fill_all_columns: true
             )

    expected = """
    #Encoding of BACnet Engineering Units;\r
    #Code;Unit Text\r
    62;degrees-celsius\r
    """

    assert expected == contents
  end

  test "encode units to binary invalid opts arg" do
    assert_raise ArgumentError, fn ->
      Units.to_binary(%Units{units: %{}}, [{5, 4}])
    end
  end

  test "encode units to file" do
    assert :ok =
             Units.to_file(
               %Units{
                 units: %{
                   62 => "degrees-celsius"
                 }
               },
               @filepath
             )

    contents = File.read!(@filepath)

    expected = """
    #Encoding of BACnet Engineering Units\r
    #Code;Unit Text\r
    62;degrees-celsius\r
    """

    assert expected == contents
  end

  test "encode units to existing file" do
    File.write!(@filepath, "EDE")

    assert :ok =
             Units.to_file(
               %Units{
                 units: %{
                   62 => "degrees-celsius"
                 }
               },
               @filepath
             )

    contents = File.read!(@filepath)

    expected = """
    #Encoding of BACnet Engineering Units\r
    #Code;Unit Text\r
    62;degrees-celsius\r
    """

    assert expected == contents
  end

  test "encode units to file invalid opts arg" do
    assert_raise ArgumentError, fn ->
      Units.to_file(%Units{units: %{}}, "", [{5, 4}])
    end
  end

  test "encode units to stream" do
    assert {:ok, stream} =
             Units.to_stream(%Units{
               units: %{
                 62 => "degrees-celsius",
                 63 => "degrees-kelvin"
               }
             })

    contents =
      stream
      |> Enum.to_list()
      |> IO.iodata_to_binary()

    expected = """
    #Encoding of BACnet Engineering Units\r
    #Code;Unit Text\r
    62;degrees-celsius\r
    63;degrees-kelvin\r
    """

    assert expected == contents
  end

  test "encode units to stream invalid opts arg" do
    assert_raise ArgumentError, fn ->
      Units.to_stream(%Units{units: %{}}, [{5, 4}])
    end
  end
end
