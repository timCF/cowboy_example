defmodule CowboyEx.OnlineUserkeeper do
	
	use ExActor.GenServer

	@timeout :timer.seconds 1

	##################
	### priv func ####
	##################

	defp makeid do
		{a, b, c} = :erlang.now
		a*1000000000000 + b*1000000 + c
	end

	##################
	### API ##########
	##################

	def add_username(username) when is_binary(username) do
		new_online_users = Dict.put(Exdk.get("online_users"), username, makeid)
		Exdk.put "online_users", new_online_users
		:ok
	end

	def user_exist?(username) when is_binary(username) do
		Enum.member?(Dict.keys(Exdk.get("online_users")), username)
	end

	#def get_users do
	#	Enum.map( Dict.to_list(Exdk.get("online_users")), fn({k,v}) )










	definit do
		case Exdk.get "online_users" do
			:not_found -> Exdk.put "online_users", %{}
			map when is_map(map) -> :ok
		end
		{:ok, nil} #, @timeout}
	end




end