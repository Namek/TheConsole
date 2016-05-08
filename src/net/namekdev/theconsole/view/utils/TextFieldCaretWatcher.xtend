package net.namekdev.theconsole.view.utils

import javafx.application.Platform
import javafx.beans.value.ChangeListener
import javafx.scene.control.IndexRange
import javafx.scene.control.TextField

/**
 * This class is a hack around JavaFX TextField to bring
 * back previous text selection or caret position after
 * refocused by TAB key.
 * <p>By default whole TextField content is selected,
 * this code prevents from it.</p>
 *
 * {@link https://bugs.openjdk.java.net/browse/JDK-8092126}
 * {@link http://stackoverflow.com/questions/14965318/javafx-method-selectall-just-works-by-focus-with-keyboard}
 */
class TextFieldCaretWatcher {
	val TextField field
	var IndexRange oldSelection
	var int oldCaretPos


	new(TextField field) {
		this.field = field
		field.focusedProperty.addListener(focusedListener)
	}

	def void dispose() {
		field.focusedProperty.removeListener(focusedListener)
	}

	private def void bringBackState() {
		if (oldSelection != null && oldSelection.length > 0) {
			field.selectRange(oldSelection.start, oldCaretPos)
		}
		else {
			field.selectRange(oldCaretPos, oldCaretPos)
		}
	}

	val ChangeListener<Boolean> focusedListener = [input, wasFocused, isFocused |
		val justLostFocus = wasFocused && !isFocused
		val justGainedFocus = !wasFocused && isFocused

		if (justLostFocus) {
			oldCaretPos = field.caretPosition
			oldSelection = field.selection
		}
		else if (justGainedFocus) {
			// HACK JavaFX: runLater because text selection occurs after this event
			Platform.runLater [
				bringBackState()
			]
		}
	]
}