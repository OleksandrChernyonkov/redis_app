defmodule RedisAppWeb.RedisLive do
  import Surface
  use RedisAppWeb, :surface_live_view

  alias RedisApp.PairContext
  alias RedisApp.Pair
  alias Moon.Design.{Table, Button, Modal, Form}
  alias Moon.Design.Table.Column
  alias Moon.Design.Form.{Input, Field}

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       pairs: PairContext.list_all_pairs(),
       creating_modal_open: false,
       updating_key: nil,
       deleting_key: nil,
       form_data: empty_form_data()
     )}
  end

  def handle_event("validate_form", %{"pair" => pair_params}, socket) do
    {:noreply, assign(socket, form_data: Pair.changeset(%Pair{}, pair_params))}
  end

  def handle_event("open_update_modal", %{"value" => key}, socket) do
    pair = PairContext.get_pair(key)
    changeset = Pair.changeset(%Pair{}, %{"key" => pair.key, "value" => pair.value})

    {:noreply, assign(socket, updating_key: key, form_data: changeset)}
  end

  def handle_event("update_pair", %{"pair" => pair_params}, socket) do
    old_key = socket.assigns.updating_key

    if old_key && old_key != pair_params["key"] do
      PairContext.delete(old_key)
    end

    PairContext.set(pair_params["key"], pair_params["value"])

    {:noreply, socket
    |> put_flash(:info, "#{pair_params["key"]} => #{pair_params["value"]} pair updated!")
    |> assign(updating_key: nil, form_data: empty_form_data(), pairs: PairContext.list_all_pairs())}
  end

  def handle_event("open_create_modal", _, socket) do
    {:noreply, assign(socket, creating_modal_open: true, form_data: empty_form_data())}
  end

  def handle_event("create_pair", %{"pair" => pair_params}, socket) do
    PairContext.set(pair_params["key"], pair_params["value"])

    {:noreply, socket
    |> put_flash(:info, "#{pair_params["key"]} => #{pair_params["value"]} pair created!")
    |> assign(creating_modal_open: false, form_data: empty_form_data(), pairs: PairContext.list_all_pairs())}
  end

  def handle_event("open_delete_modal", %{"value" => key}, socket) do
    {:noreply, assign(socket, deleting_key: key)}
  end

  def handle_event("delete_pair", _, socket) do
    key = socket.assigns.deleting_key

    if key do
      PairContext.delete(key)
    end

    {:noreply, socket
    |> put_flash(:info, "pair with key #{key} deleted!")
    |> assign(deleting_key: nil, pairs: PairContext.list_all_pairs())}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, creating_modal_open: false, updating_key: nil, deleting_key: nil)}
  end

  defp empty_form_data, do: Pair.changeset(%Pair{}, %{"key" => "", "value" => ""})

  def render(assigns) do
    ~F"""
    <div class="w-full mb-4">
      <Button class="add_button mb-4" on_click="open_create_modal">Create new pair</Button>

      <Table items={pair <- @pairs} class="w-full cursor-pointer border border-gray-300 rounded-lg">
        <Column class="column_class" name="key" label="Key">{pair.key}</Column>
        <Column class="column_class" name="value" label="Value">{pair.value}</Column>
        <Column class="column_class w-[20px]">
          <Button class="edit_button" on_click="open_update_modal" value={pair.key}>Edit</Button>
        </Column>
        <Column class="column_class w-[30px]">
          <Button class="delete_button" on_click="open_delete_modal" value={pair.key}>Delete</Button>
        </Column>
      </Table>

      <Modal id="update_modal" on_close="close_modal" is_open={@updating_key}>
        <Modal.Backdrop />
        <Modal.Panel class="p-3">
          <Form for={@form_data} change="validate_form" submit="update_pair">
            <Field field={:key} label="Key"><Input value={@form_data.data.key} /></Field>
            <Field field={:value} label="Value"><Input value={@form_data.data.value} /></Field>
            <div class="flex justify-between pt-3 ">
              <Button class="edit_button" type="submit">Update pair</Button>
              <Button class="close_button" on_click="close_modal" type="button">Close</Button>
            </div>
          </Form>
        </Modal.Panel>
      </Modal>

      <Modal id="create_modal" on_close="close_modal" is_open={@creating_modal_open}>
        <Modal.Backdrop />
        <Modal.Panel class="p-3">
          <Form for={@form_data} change="validate_form" submit="create_pair">
            <Field field={:key} label="Key"><Input value={@form_data.data.key} /></Field>
            <Field field={:value} label="Value"><Input value={@form_data.data.value} /></Field>
            <div class="flex justify-between pt-3">
              <Button class="add_button" type="submit">Create pair</Button>
              <Button class="close_button" on_click="close_modal" type="button">Close</Button>
            </div>
          </Form>
        </Modal.Panel>
      </Modal>

      <Modal id="delete_modal" on_close="close_modal" is_open={@deleting_key}>
        <Modal.Backdrop />
        <Modal.Panel class="p-3">
          <p class="p-3">Are you sure you want to delete this pair?</p>
          <div class="flex justify-between pt-3">
            <Button class="delete_button" on_click="delete_pair" type="button">Delete</Button>
            <Button class="close_button" on_click="close_modal" type="button">Close</Button>
          </div>
        </Modal.Panel>
      </Modal>
    </div>
    """
  end
end
