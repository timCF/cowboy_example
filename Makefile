all:
		git pull origin master
		mix deps.clean --all
		mix deps.get
		docker build -t strain/cowboy_example .