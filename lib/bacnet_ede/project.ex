defmodule BACnetEDE.Project do
  @moduledoc """
  The `Project` is the main struct and contains the project information as included in the EDE.

  Each EDE file has a header which includes key information, such as:
  - Project Name
  - Version of the EDE file
  - Timestamp of the last change
  - Author of the last change
  - Version of the EDE file layout (2.3 is the latest currently)
  - Available columns, additionally to the mandatory ones

  The struct then contains a map of all the objects included in the EDE file,
  they are keyed by the `keyname`. See `BACnetEDE.Project.Object` for further details on objects.

  Validation on the project struct will happen:
  - Validating types as per `t:t/0` type
  - Validating each object passes their type test

  Information on the keys of the struct can be found in the `t:t/0` docs.
  """

  @dialyzer {:no_contracts, [new: 0]}

  defmodule Object do
    @moduledoc """
    The object struct identifies an object of the EDE.

    The object usually contains minimal information,
    such as key name, device instance, object name and object type.
    However some information, such as the default present value and whether it supports COV reporting,
    can be shared. All optional information is `nil`able and as such may not be present in the EDE.
    All additional information that are not part of the EDE format will be available in the `:more_keys` map.
    Since these information are not known, they are available as string only.

    Information on the keys of the struct can be found in the `t:t/0` docs.
    """

    @dialyzer {:no_contracts, [new: 0]}

    @typedoc """
    Represents an object of the EDE.

    The following keys are present and some are optional (`nil`):
    - `keyname` - System wide unique name of the object.
    - `device_instance` - The object instance number of the device the object resides in.
    - `object_name` - The object name and identical to the `object_name` BACnet property.
      The name must be unique inside the device.
    - `object_type` - The object type number as defined per ASHRAE 135 BACnet specification.
    - `object_instance` - The object instance number - within a device different objects
      of the same type are distinguished by their instance number.
    - `description` - An information text that provides more detailed description of the datapoint.
    - `default_present_value` - The default value for the `present_value` BACnet property.
      If the object is commandable, this field should contain the `relinquish_default` value.
    - `min_present_value` - The minimum value that can be in the `present_value` BACnet property.
    - `max_present_value` - The maximum value that can be in the `present_value` BACnet property.
    - `settable` - Indicates whether the `present_value` BACnet property is writable (can be set by a client).
    - `supports_cov` - Indicates whether the object supports COV reporting or not.
      An empty field may indicate that it does support COV. Boolean values will indicate if it does or not.
    - `high_limit` - Indicates whether the object supports Intrinsic reporting and will contain the value
      of the `high_limit` BACnet property if the field is readonly.
      This value should be absent the field is writable (can be set by a client).
      In practice, this value might also be absent if the object does not support Intrinsic reporting.
    - `low_limit` - Indicates whether the object supports Intrinsic reporting and will contain the value
      of the `low_limit` BACnet property if the field is readonly.
      This value should be absent the field is writable (can be set by a client).
      In practice, this value might also be absent if the object does not support Intrinsic reporting.
    - `state_text_ref` - The value is used as reference number to refer to entries in the state text file.
      Different objects listed in the EDE may refer to the same entry, if their textual representation are identical.
    - `unit_code` - The BACnet engineering unit as defined by ASHRAE 135 BACnet.
      A separate unit file may be used to point the value to a specific text
      (however the reserved numbers must be identical to the BACnet specification).
    - `vendor_specific_address` - This may be used to identify addresses used in the server device.
      The address may provide an internal datapoint identification or reference.
    - `notification_class` - Contains the instance number of the Notification Class object linked to the object.
      If the object does not support Intrinsic reporting, this value should be absent.
    - `more_keys` - Contains additional found (unknown) columns in the EDE that are not part of the EDE specification.
      The keys and values are all strings and may be further parsed, used or converted by the user.
    """
    @type t :: %__MODULE__{
            keyname: String.t(),
            device_instance: non_neg_integer(),
            object_name: String.t(),
            object_type: non_neg_integer(),
            object_instance: non_neg_integer(),
            description: String.t() | nil,
            default_present_value: String.t() | nil,
            min_present_value: float() | nil,
            max_present_value: float() | nil,
            settable: boolean() | nil,
            supports_cov: boolean() | nil,
            high_limit: float() | nil,
            low_limit: float() | nil,
            state_text_ref: non_neg_integer() | nil,
            unit_code: non_neg_integer() | nil,
            vendor_specific_address: String.t() | nil,
            notification_class: non_neg_integer() | nil,
            more_keys: %{
              optional(String.t()) => String.t()
            }
          }

    defstruct [
      :keyname,
      :device_instance,
      :object_name,
      :object_type,
      :object_instance,
      :description,
      :default_present_value,
      :min_present_value,
      :max_present_value,
      :settable,
      :supports_cov,
      :high_limit,
      :low_limit,
      :state_text_ref,
      :unit_code,
      :vendor_specific_address,
      :notification_class,
      :more_keys
    ]

    @doc false
    @spec new() :: t()
    def new() do
      %__MODULE__{more_keys: %{}}
    end

    @doc false
    @spec new(Enumerable.t()) :: t()
    def new(keys) do
      __MODULE__
      |> struct!(keys)
      |> Map.update!(:more_keys, fn
        nil -> %{}
        val -> val
      end)
    end

    @doc """
    Validates the struct (type validation).
    """
    @spec valid?(t()) :: boolean()
    # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
    def valid?(%__MODULE__{} = t) do
      is_binary(t.keyname) and
        is_integer(t.device_instance) and t.device_instance >= 0 and
        t.device_instance <= 4_194_302 and
        is_binary(t.object_name) and t.object_name != "" and
        is_integer(t.object_type) and t.object_type >= 0 and
        is_integer(t.object_instance) and t.object_instance >= 0 and
        t.object_instance <= 4_194_302 and
        (is_binary(t.description) or is_nil(t.description)) and
        (is_binary(t.default_present_value) or is_nil(t.default_present_value)) and
        (is_float(t.min_present_value) or is_nil(t.min_present_value)) and
        (is_float(t.max_present_value) or is_nil(t.max_present_value)) and
        (is_boolean(t.settable) or is_nil(t.settable)) and
        (is_boolean(t.supports_cov) or is_nil(t.supports_cov)) and
        (is_float(t.high_limit) or is_nil(t.high_limit)) and
        (is_float(t.low_limit) or is_nil(t.low_limit)) and
        (is_integer(t.state_text_ref) or is_nil(t.state_text_ref)) and
        ((is_integer(t.unit_code) and t.unit_code >= 0) or is_nil(t.unit_code)) and
        (is_binary(t.vendor_specific_address) or is_nil(t.vendor_specific_address)) and
        is_map(t.more_keys) and
        Enum.all?(t.more_keys, fn {key, value} -> is_binary(key) and is_binary(value) end)
    end
  end

  @typedoc """
  Represents an EDE project and contains basic project information
  and objects that were part of the EDE.

  Layout version is ideally 2.2 or 2.3, as those were the ones used for testing.
  Layout version 2.3 is the current latest version.
  """
  @type t :: %__MODULE__{
          project_name: String.t(),
          version: String.t(),
          timestamp_last_change: NaiveDateTime.t(),
          author_last_change: String.t(),
          layout_version: String.t(),
          objects: %{
            optional(String.t()) => Object.t()
          }
        }

  defstruct [
    :project_name,
    :version,
    :timestamp_last_change,
    :author_last_change,
    :layout_version,
    :objects
  ]

  @doc false
  @spec new() :: t()
  def new() do
    %__MODULE__{author_last_change: "", objects: %{}}
  end

  @doc false
  @spec new(Enumerable.t()) :: t()
  def new(keys) do
    __MODULE__
    |> struct!(keys)
    |> Map.update!(:objects, fn
      nil -> %{}
      other -> other
    end)
    |> Map.update!(:author_last_change, fn
      nil -> ""
      other -> other
    end)
  end

  @doc """
  Validates the struct (type validation).
  """
  @spec valid?(t()) :: boolean()
  def valid?(%__MODULE__{} = t) do
    is_binary(t.project_name) and
      is_binary(t.version) and
      is_struct(t.timestamp_last_change, NaiveDateTime) and
      (is_binary(t.author_last_change) or is_nil(t.author_last_change)) and
      is_binary(t.layout_version) and
      is_map(t.objects) and
      Enum.all?(t.objects, fn
        {key, %Object{} = value} -> is_binary(key) and Object.valid?(value)
        _else -> false
      end)
  end
end
