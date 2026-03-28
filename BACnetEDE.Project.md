# `BACnetEDE.Project`
[🔗](https://github.com/bacnet-ex/bacnet_ede/blob/master/lib/bacnet_ede/project.ex#L1)

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

# `t`

```elixir
@type t() :: %BACnetEDE.Project{
  author_last_change: String.t(),
  layout_version: String.t(),
  objects: %{optional(String.t()) =&gt; BACnetEDE.Project.Object.t()},
  project_name: String.t(),
  timestamp_last_change: NaiveDateTime.t(),
  version: String.t()
}
```

Represents an EDE project and contains basic project information
and objects that were part of the EDE.

Layout version is ideally 2.2 or 2.3, as those were the ones used for testing.
Layout version 2.3 is the current latest version.

# `valid?`

```elixir
@spec valid?(t()) :: boolean()
```

Validates the struct (type validation).

---

*Consult [api-reference.md](api-reference.md) for complete listing*
