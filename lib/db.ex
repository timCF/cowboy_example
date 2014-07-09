use Amnesia

defmodule DBA do
  def install do
    Amnesia.Schema.create
    Amnesia.start
    DB.create()
    DB.wait
  end
  def install_disk do
    Amnesia.Schema.create
    Amnesia.start
    DB.create(disk: [node])
    DB.wait
  end
  def uninstall do
    Amnesia.start
    DB.destroy
    Amnesia.stop
    Amnesia.Schema.destroy
  end
end

defdatabase DB do
  deftable Storage, [:key,:value], type: :set do

  end
end

defmodule Exdk do
  def put(key, value) do
    Amnesia.transaction do
      DB.Storage.write %DB.Storage{key: key, value: value}
    end
  end
  def get(key) do
    Amnesia.transaction do
      case DB.Storage.read(key) do
        nil -> :not_found
        val -> val.value
      end
    end
  end
end