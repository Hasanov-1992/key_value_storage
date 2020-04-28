defmodule CrossTest do
  use ExUnit.Case, async: true #Выполняет наборы тестов параллельно

  test "Добавить запись в хранилищи" do
    Storage.delete("key")
    assert Storage.read("key") == "Такой запись не существует"
    assert Storage.create("key", "value", 40000) == "Запись value добавлена"
    assert Storage.read("key") == "value"
  end

  test "Если запись существует в хранилищи" do
    Storage.delete("key")
    assert Storage.create("key", "value", 3000000) == "Запись value добавлена"
    assert Storage.create("key", "value", 3000000) == "Такой запись уже существует"
 end

 test "Проверка ttl" do
  assert Storage.create("key", "vakue", -900000) == "TTL должен быть равно либо больше нуля"
end

test "Читать запись из хранилищи" do
  Storage.create("key", "value", 40000)
  assert Storage.read("key") == "value"
end

test "Обновить запись в хранилищи" do
  Storage.delete("key")
  assert Storage.create("key", "value", 35000) == "Запись value добавлена"
  assert Storage.read("key") == "value"
  assert Storage.update("key", "new_value") == "Изменение значение на new_value"
  assert Storage.read("key") == "new_value"
end

  test "Удалить запись из хранилищи" do
    Storage.create("key1", "value1", 40000)
    assert Storage.delete("key1") == "Запись key1 удалена"
    assert Storage.read("key1") == "Такой запись не существует"
  end

  test "Проверить, существует ли запись после открытия / закрытия хранилища" do
    Storage.delete("20sec")
    assert Storage.create("20sec", "20000", 20000) == "Запись 20000 добавлена"
    assert Storage.read("20sec")  == "20000"
  end

end
