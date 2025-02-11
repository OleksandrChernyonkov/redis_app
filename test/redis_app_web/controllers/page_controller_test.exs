defmodule RedisAppWeb.PageControllerTest do
  use RedisAppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Create new pair"
    assert html_response(conn, 200) =~ "Key"
    assert html_response(conn, 200) =~ "Value"
    assert html_response(conn, 200) =~ "Edit"
    assert html_response(conn, 200) =~ "Delete"
  end

  test "Modal windows exist on the page", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Create pair"
    assert html_response(conn, 200) =~ "Update pair"
    assert html_response(conn, 200) =~ "Are you sure you want to delete this pair?"
  end
end
