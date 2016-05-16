package net.namekdev.theconsole.events

import com.google.common.eventbus.EventBus

interface Events {
	static val bus = new EventBus

	static def post(Event evt) {
		bus.post(evt)
	}

	static def register(Object obj) {
		bus.register(obj)
	}

	static def unregister(Object obj) {
		bus.unregister(obj)
	}
}