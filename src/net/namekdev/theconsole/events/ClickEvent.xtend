package net.namekdev.theconsole.events

class ClickEvent implements Event {
	val Object origin

	new(Object origin) {
		this.origin = origin
	}
}