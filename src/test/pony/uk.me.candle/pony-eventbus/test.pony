use "ponytest"


actor Main is TestList
	new create(env: Env) =>
		PonyTest(env, this)
	
	fun tag tests(test: PonyTest) =>
		_TestEventBus.make().tests(test)
