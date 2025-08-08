defmodule BACnetEDE.MixProject do
  use Mix.Project

  def project do
    [
      app: :bacnet_ede,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      # This is the cause for unknown protocol __impl__/1 for built-in types
      consolidate_protocols: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings.exs",
        plt_add_apps: []
      ],
      source_url: "https://github.com/bacnet-ex/bacnet_ede",
      docs: [
        main: "BACnetEDE",
        source_ref: "master",
        groups_for_docs: [Guards: & &1[:guard]],
        groups_for_modules: [],
        nest_modules_by_prefix: [],
        before_closing_head_tag: &docs_before_closing_head_tag/1,
        before_closing_body_tag: &docs_before_closing_body_tag/1
      ],
      test_coverage: [
        ignore_modules: [~r"Inspect\..+", BACnetEDE.CSV],
        summary: true,
        tool: if(System.get_env("CI"), do: ExCoveralls, else: Mix.Tasks.Test.Coverage)
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "1.4.3", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.21", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.29", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: [:test], runtime: false},
      {:junit_formatter, "~> 3.3", only: [:test], runtime: false},
      {:nimble_csv, "~> 1.3"}
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs_before_closing_head_tag(:html) do
    """
    <!-- Markdown for details HTML tags -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/showdown/2.1.0/showdown.min.js"></script>

    <!-- Sortable tables -->
    <style>
      table th {
        cursor: pointer;
      }

      table th[aria-sort="ascending"] span::after {
        content: "▲";
        color: currentcolor;
        font-size: 100%;
        top: 0;
        margin-left: 5px;
      }

      table th[aria-sort="descending"] span::after {
        content: "▼";
        color: currentcolor;
        font-size: 100%;
        top: 0;
        margin-left: 5px;
      }
    </style>
    """
  end

  defp docs_before_closing_head_tag(:epub), do: ""

  defp docs_before_closing_body_tag(:html) do
    """
    <!-- Markdown for details HTML tags & sortable tables -->
    <script>
      class TableSortableColumns {
        constructor(tableNode) {
          this.tableNode = tableNode;
          this.columnHeaders = tableNode.querySelectorAll('thead th');
          this.sortColumns = [];

          for (var i = 0; i < this.columnHeaders.length; i++) {
            var ch = this.columnHeaders[i];

            if (ch) {
              ch.innerHTML += '<span aria-hidden="true"></span>';
              this.sortColumns.push(i);
              ch.setAttribute('data-column-index', i);
              ch.addEventListener('click', this.handleClick.bind(this));
            }
          }
        }

        setColumnHeaderSort(columnIndex) {
          if (typeof columnIndex === 'string') {
            columnIndex = parseInt(columnIndex);
          }

          for (var i = 0; i < this.columnHeaders.length; i++) {
            var ch = this.columnHeaders[i];

            if (i === columnIndex) {
              var value = ch.getAttribute('aria-sort');

              if (value === 'ascending') {
                ch.setAttribute('aria-sort', 'descending');
                this.sortColumn(
                  columnIndex,
                  'descending',
                  ch.classList.contains('num')
                );
              } else {
                ch.setAttribute('aria-sort', 'ascending');
                this.sortColumn(
                  columnIndex,
                  'ascending',
                  ch.classList.contains('num')
                );
              }
            } else if (ch.hasAttribute('aria-sort')) {
              ch.removeAttribute('aria-sort');
            }
          }
        }

        sortColumn(columnIndex, sortValue, isNumber) {
          function compareValues(a, b) {
            isNumber = !isNaN(parseFloat(a.value)) && !isNaN(parseFloat(b.value))

            if (sortValue === 'ascending') {
              if (a.value === b.value) {
                return 0;
              } else {
                if (isNumber) {
                  return a.value - b.value;
                } else {
                  return a.value < b.value ? -1 : 1;
                }
              }
            } else {
              if (a.value === b.value) {
                return 0;
              } else {
                if (isNumber) {
                  return b.value - a.value;
                } else {
                  return a.value > b.value ? -1 : 1;
                }
              }
            }
          }

          if (typeof isNumber !== 'boolean') {
            isNumber = false;
          }

          var tbodyNode = this.tableNode.querySelector('tbody');
          var rowNodes = [];
          var dataCells = [];

          var rowNode = tbodyNode.firstElementChild;

          var index = 0;
          while (rowNode) {
            rowNodes.push(rowNode);

            var rowCells = rowNode.querySelectorAll('th, td');
            var dataCell = rowCells[columnIndex];
            var data = {};

            data.index = index;
            data.value = dataCell.textContent.toLowerCase().trim();
            if (isNumber) {
              data.value = parseFloat(data.value);
            }

            dataCells.push(data);
            rowNode = rowNode.nextElementSibling;
            index += 1;
          }

          dataCells.sort(compareValues);

          while (tbodyNode.firstChild) {
            tbodyNode.removeChild(tbodyNode.lastChild);
          }

          for (var i = 0; i < dataCells.length; i += 1) {
            tbodyNode.appendChild(rowNodes[dataCells[i].index]);
          }
        }

        handleClick(event) {
          var target = event.currentTarget;
          this.setColumnHeaderSort(target.getAttribute('data-column-index'));
        }
      }

      document.addEventListener('DOMContentLoaded', function () {
        // This is the part where we load the <details> contents,
        // parse it using markdown and push the HTML back
        var converter = new showdown.Converter({});
        converter.setFlavor('github');

        var details = document.querySelectorAll('details');
        for (var i = 0; i < details.length; i++) {
          details[i].innerHTML = converter.makeHtml(details[i].innerHTML);
        }

        // Now apply sortable tables, because <details> could contain tables
        var tables = document.querySelectorAll('table');
        for (var i = 0; i < tables.length; i++) {
          new TableSortableColumns(tables[i]);
        }
      });
    </script>
    """
  end

  defp docs_before_closing_body_tag(:epub), do: ""
end
