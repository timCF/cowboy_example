defmodule CowboyEx.Messanger do
	
	use ExActor.GenServer, export: :Messanger
	@timeout :timer.seconds 1
	@history_limit 300

	defp makeid do
		{a, b, c} = :erlang.now
		a*1000000000000 + b*1000000 + c
	end

	defp cleanup_history [] do
		[]
	end
	defp cleanup_history(history) when is_list(history) do
		case length(history) > @history_limit do
			true -> [_|rest] = history
					cleanup_history(rest)
			false -> history
		end
	end


	###################
	### API ###########
	###################

	def get_history_html do
		Enum.reduce(Exdk.get("messages_history"), "", fn(x, acc) -> x<>acc end)
	end

	def process_new_message(message, autor) when is_binary(message) and is_binary(autor) do
		mess = "<div class=\"subdata\"><hr>"<>String.strip(System.cmd("date"))<>"<br>"<>autor<>"<br></div><center>"<>message<>"</center>"
		new_history = Exdk.get("messages_history") ++ [mess]
		Exdk.put("messages_history", new_history)

		Enum.each(:pg2.get_members("users"), &(send &1, {:add_new_message, mess}))
	end


	definit do
		case Exdk.get "messages_history" do
	      :not_found -> Exdk.put "messages_history", []
	      list when is_list(list) -> :ok
	    end
		{:ok, nil, @timeout}
	end

	definfo :timeout do
		new_history = cleanup_history(Exdk.get("messages_history"))
		Exdk.put("messages_history", new_history)
		{:noreply, nil, @timeout}
	end
end