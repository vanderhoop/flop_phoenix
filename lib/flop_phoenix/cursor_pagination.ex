defmodule Flop.Phoenix.CursorPagination do
  @moduledoc false

  use Phoenix.Component

  alias Flop.Meta
  alias Flop.Phoenix.Misc

  require Logger

  def path_on_paginate_error_msg do
    """
    path or on_paginate attribute is required

    At least one of the mentioned attributes is required for the cursor
    pagination component. Combining them will both patch the URL and execute
    the JS command.

    The :path value can be a path as a string, a
    {module, function_name, args} tuple, a {function, args} tuple, or an 1-ary
    function.

    ## Example

        <Flop.Phoenix.cursor_pagination
          meta={@meta}
          path={~p"/pets"}
        />

    or

        <Flop.Phoenix.cursor_pagination
          meta={@meta}
          path={{Routes, :pet_path, [@socket, :index]}}
        />

    or

        <Flop.Phoenix.cursor_pagination
          meta={@meta}
          path={{&Routes.pet_path/3, [@socket, :index]}}
        />

    or

        <Flop.Phoenix.cursor_pagination
          meta={@meta}
          path={&build_path/1}
        />

    or

        <Flop.Phoenix.cursor_pagination
          meta={@meta}
          on_paginate={JS.push("paginate")}
        />

    or

        <Flop.Phoenix.cursor_pagination
          meta={@meta}
          path={~"/pets"}
          on_paginate={JS.dispatch("scroll-to", to: "#my-table")}
        />
    """
  end

  @spec default_opts() :: [Flop.Phoenix.cursor_pagination_option()]
  def default_opts do
    [
      disabled_class: "disabled",
      next_link_attrs: [
        aria: [label: "Go to next page"],
        class: "pagination-next"
      ],
      next_link_content: "Next",
      previous_link_attrs: [
        aria: [label: "Go to previous page"],
        class: "pagination-previous"
      ],
      previous_link_content: "Previous",
      wrapper_attrs: [
        class: "pagination",
        role: "navigation",
        aria: [label: "pagination"]
      ]
    ]
  end

  def merge_opts(opts) do
    default_opts()
    |> Misc.deep_merge(Misc.get_global_opts(:cursor_pagination))
    |> Misc.deep_merge(opts)
  end

  # meta, direction, reverse
  def disable?(%Meta{has_previous_page?: true}, :previous, false), do: false
  def disable?(%Meta{has_next_page?: true}, :next, false), do: false
  def disable?(%Meta{has_previous_page?: true}, :next, true), do: false
  def disable?(%Meta{has_next_page?: true}, :previous, true), do: false
  def disable?(%Meta{}, _, _), do: true

  def pagination_path(_, nil, _), do: nil

  def pagination_path(direction, path, %Flop.Meta{} = meta) do
    params =
      meta
      |> Flop.set_cursor(direction)
      |> Flop.Phoenix.to_query(backend: meta.backend, for: meta.schema)

    Flop.Phoenix.build_path(path, params)
  end
end
