use "ponytest"
// use "$groupId/$artifactId"
use "uk.me.candle/pony-eventbus"

actor _TestEventBus is TestList
	new create(env: Env) =>
		PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
		test(_TestOneHandler)
		test(_TestTwoHandlers)
		test(_TestFailHandler)
		test(_TestAppendHandler)

class val TestEvent
	let name: String
	new val create(name': String) =>
		name = name'

actor TestHandler is Handler[TestEvent val]
	let _collector: TestHandlerCollector
	let _idx: USize
	new create(idx': USize, collector': TestHandlerCollector) =>
		_idx = idx'
		_collector = collector'
	be handle(event: TestEvent) =>
		_collector.called(_idx)

actor TestFailHandler is FilterHandler[TestEvent val]
	let _helper: TestHelper
	new create(helper': TestHelper) =>
		_helper = helper'
	fun filter(item: TestEvent): Bool => false
	be handle(event: TestEvent) =>
		_helper.complete(false)

actor TestHandlerCollector
	var _counts: Array[Bool]
	let _helper: TestHelper
	new create(helper': TestHelper, count: USize) =>
		_helper = helper'
		_counts = Array[Bool].init(false, count)
	be called(num: USize) =>
		try _counts(num) = true end
		if not _counts.contains(false) then
			_helper.complete(true)
		end

class iso _TestOneHandler is UnitTest
	fun name(): String => "event bus / one handler"
	fun apply(h: TestHelper) =>
		h.long_test(10000000)
		let collector = TestHandlerCollector.create(h, 1)
		let handler: Handler[TestEvent val] tag = TestHandler.create(0, collector)
		var bus = EventBus[TestEvent].from_array(recover val [handler] end)
		bus.dispatch(TestEvent.create("event"))

class iso _TestTwoHandlers is UnitTest
	fun name(): String => "event bus / two handlers"
	fun apply(h: TestHelper) =>
		h.long_test(10000000)
		let collector = TestHandlerCollector.create(h, 2)
		let handler': Handler[TestEvent val] tag = TestHandler.create(0, collector)
		let handler'': Handler[TestEvent val] tag = TestHandler.create(1, collector)
		var bus = EventBus[TestEvent].from_array(recover val [handler', handler''] end)
		bus.dispatch(TestEvent.create("event"))

class iso _TestFailHandler is UnitTest
	fun name(): String => "event bus / one filtered handler"
	fun apply(h: TestHelper) =>
		h.long_test(10000000)
		let collector = TestHandlerCollector.create(h, 1)
		let handler: Handler[TestEvent val] tag = TestHandler.create(0, collector)
		let nonHandler: Handler[TestEvent val] tag = TestFailHandler.create(h)
		var bus = EventBus[TestEvent].from_array(recover val [nonHandler, handler] end)
		bus.dispatch(TestEvent.create("event"))

class iso _TestAppendHandler is UnitTest
	fun name(): String => "event bus / add handler"
	fun apply(h: TestHelper) =>
		h.long_test(10000000)
		let collector = TestHandlerCollector.create(h, 2)
		let handler': Handler[TestEvent val] tag = TestHandler.create(0, collector)
		var bus = EventBus[TestEvent].from_array(recover val [handler'] end)
		let handler'': Handler[TestEvent val] tag = TestHandler.create(1, collector)
		bus.add(handler'')
		bus.dispatch(TestEvent.create("event"))

