defmodule Storage do
  @moduledoc"""
  key-value хранилищи
  """
  use GenServer
  require Logger  

@name __MODULE__

  def start_link do
    GenServer.start_link(@name, [], [{:name, @name}])
  end
  
  @doc """
    Добавить запись
    Для проверки-->
      method: POST
      localhost:4000/?key=65&value=m1&ttl=900000
  """
  def create(key, value, ttl) when is_integer(ttl) do
    if ttl >= 0 do
      if read(key) do
        case GenServer.call(@name, {:create, {key, value, ttl}}) do
          true -> "Запись #{value} добавлена"
          false -> "Такой запись уже существует"
        end
      else
        "Такой запись не существует"
      end
    else
      "TTL должен быть равно либо больше нуля"
    end
  end

  @doc """
    Проверить запись
    Для проверки-->
      method: GET
      localhost:4000/?key=65
  """
  def read(key) do
    case GenServer.call(@name, {:read, key}) do
      :no_element -> "Такой запись не существует"
      str_value -> str_value
    end
  end

@doc """
    Обновить запись
    Для проверки-->
      method: PUT
      localhost:4000/?key=65&value=m1&ttl=900000
  """
  def update(key, value) do
    case read(key) do
      :no_element -> "Такой запись не существует"
      _element ->
        case GenServer.call(@name, {:update, {key, value}}) do
          :no_element -> "Такой запись не существует"
          :ok -> "Изменение значение на #{value}"
        end
    end
  end

@doc """
    Удалить запись
    Для проверки-->
      method: DELETE
      localhost:4000/?key=65
  """
  def delete(key) do
    case read(key) do
      :no_element -> "Такой запись не существует"
      _element ->
        case GenServer.call(@name, {:delete, key}) do
          :ok -> "Запись #{key} удалена"
        end
    end
  end

@doc """
  Посмотреть все записи!
  """
  def list do
    {:ok, table} = :dets.open_file(:disk_storage, [type: :set])
    select_all = :ets.fun2ms(&(&1))
    :dets.select(table, select_all)
  end

  def stop() do
    GenServer.stop(@name)
  end

  def init([]) do
    disk_name = Application.get_env(:cross, :disk_name, :disk_storage)
    table = init_ttl(disk_name)
    {:ok, table}
  end

  def handle_call({:create, {key, value, ttl}}, _from, table) do
    {:reply, create_element(table, {key, value, ttl}), table}
  end

  def handle_call({:read, key}, _from, table) do
    {
      :reply,
      case :dets.lookup(table, key) do
        [] -> "Такой запись не существует"
        [{_key, value, _ttl, _timestamp, _pid}] -> value
      end ,
      table
    }
  end

  def handle_call({:update, value}, _from, table) do
    {:reply, update_element(table, value), table}
  end

  def handle_call({:delete, key}, _from, table) do
    {:reply, delete_element(table, key), table}
  end

  def terminate(_reason, table) do
    close_storage(table)
    {:ok}
  end

  def create_element(table, {key, value, ttl}) do
    {:ok, pid} = Task.start_link fn -> delete_element_after(table, key, ttl) end
    time = :os.system_time(:milli_seconds)
    :dets.insert_new(table, {key, value, ttl, time, pid})

  end

  def update_element(table, {key, value}) do
    case :dets.lookup(table, key) do
      [] -> "Такой запись не существует"
      [{key, _pvalue, ttl, timestamp, pid}] -> :dets.insert(table, {key, value, ttl, timestamp, pid})
    end
  end

  def delete_all do
    {:ok, table} = :dets.open_file(:disk_storage, [type: :set])
    :dets.delete_all_objects(table)
    :dets.sync(table)
  end

  def delete_element(table, key) do
    [{_key, _value, _ttl, _timestamp, pid}] = :dets.lookup(table, key)
    send pid, {:close}
    :dets.delete(table, key)
  end

  def close_storage(table) do
    :dets.sync(table)
    :dets.close(table)
    :timer.sleep(5000)
  end

  defp open_file(disk_name) do
    {:ok, table} = :dets.open_file(disk_name, [type: :set])
    table
  end

  defp init_ttl(disk_name) do
    table = open_file(disk_name)
    table
  end

  defp delete_element_after(table, key, ttl) do
    receive do
      {:update_ttl, new_ttl} -> delete_element_after(table, key, new_ttl)
      {:close} -> :ok
    after
      ttl ->
        :dets.delete(table, key)
    end
    
  end

end

