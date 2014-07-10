defmodule CowboyEx.OnlineUserkeeper do
	
	use ExActor.GenServer, export: :OnlineUserkeeper

	@timeout :timer.seconds 1
	@online_delay 60000000 # 1 min of delay before make user offline

	##################
	### priv func ####
	##################

	defp makeid do
		{a, b, c} = :erlang.now
		a*1000000000000 + b*1000000 + c
	end

	defp user_entered_notification(username) do
		Enum.each(:pg2.get_members("users"), &(send &1, {:user_entered, username}))
		date = String.strip(System.cmd("date"))
		mess = 	EEx.eval_file :erlang.list_to_binary(:code.priv_dir(:cowboy_ex))<>"/static/ex/user_entered.ex",
				[date: date, username: username]	
		Enum.each(:pg2.get_members("users"), &(send &1, {:add_new_message, mess}))
	end

	defp make_user_disconnect(username) do
		Exdk.put "online_users", Dict.delete(Exdk.get("online_users"), username)
		Enum.each(:pg2.get_members("users"), &(send &1, {:user_exited, username}))
		date = String.strip(System.cmd("date"))
		mess = EEx.eval_file :erlang.list_to_binary(:code.priv_dir(:cowboy_ex))<>"/static/ex/user_exited.ex",
				[date: date, username: username]
		Enum.each(:pg2.get_members("users"), &(send &1, {:add_new_message, mess}))
	end	

	##################
	### API ##########
	##################

	def add_username(username) when is_binary(username) do
		new_online_users = Dict.put(Exdk.get("online_users"), username, makeid)
		Exdk.put "online_users", new_online_users
		user_entered_notification(username)
		:ok
	end

	def ping_username(username) when is_binary(username) do
		new_online_users = Dict.put(Exdk.get("online_users"), username, makeid)
		Exdk.put "online_users", new_online_users
		:ok
	end

	def user_exist?(username) when is_binary(username) do
		Enum.member?(Dict.keys(Exdk.get("online_users")), username)
	end

	def get_userlist_html do
		Enum.reduce( Dict.keys(Exdk.get("online_users")),
							"Online users:<br><br>",
							fn(username, acc) -> 
								acc<>username<>"<br>"
							end)
	end










	definit do
		case Exdk.get "online_users" do
			:not_found -> Exdk.put "online_users", %{}
			map when is_map(map) -> :ok
		end
		{:ok, nil, @timeout}
	end

	definfo :timeout do
		Enum.each(Dict.to_list(Exdk.get("online_users")), 
			fn({username, timestamp}) ->
				case (makeid - timestamp) > @online_delay do
					true -> make_user_disconnect(username)
					false -> :ok
				end
			end)
		{:noreply, nil, @timeout}
	end


end