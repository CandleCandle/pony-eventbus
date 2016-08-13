use "collections"

actor EventBus[E: Any val]
	"""
	E: type of event that is distributed
	"""

	var _handlers: List[Handler[E] tag] = List[Handler[E] tag]

	new create() => None

	new from_array(handlers': Array[Handler[E] tag] val) =>
		_handlers.append(handlers')

	be dispatch(event: E) =>
		for handler in _handlers.values() do
			handler.handoff(event)
		end

	be add(handler: Handler[E] tag) =>
		_handlers.push(handler)

trait Handler[E: Any val]
	be with_name(cb: {(String)} iso) =>
		cb(name())
	fun name(): String => ""
	be handoff(event: E) =>
		handle(event)
	be handle(event: E) => None

trait FilterHandler[E: Any val] is Handler[E]
	fun filter(item: E): Bool =>
		"""
		return true if this handler should process this event.
		"""
		true
	be handoff(event: E) =>
		if (filter(event)) then
			handle(event)
		end
	be handle(event: E) => None

