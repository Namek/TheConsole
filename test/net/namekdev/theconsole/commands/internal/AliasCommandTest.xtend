package net.namekdev.theconsole.commands.internal

import com.eclipsesource.json.JsonObject
import net.namekdev.theconsole.commands.AliasStorage
import net.namekdev.theconsole.commands.AliasStorageMock
import net.namekdev.theconsole.commands.api.ICommand
import net.namekdev.theconsole.scripts.ConsoleProxy
import net.namekdev.theconsole.scripts.execution.JsUtilsProvider
import net.namekdev.theconsole.scripts.execution.ScriptAssertError
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.utils.api.IDatabase.ISectionAccessor
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentCaptor
import org.mockito.Mock
import org.powermock.modules.junit4.PowerMockRunner

import static org.mockito.Matchers.*
import static org.powermock.api.mockito.PowerMockito.*

import static extension org.junit.Assert.*

@RunWith(PowerMockRunner)
class AliasCommandTest {
	var ICommand cmd
	var AliasStorage aliases
	JsUtilsProvider jsUtils

	@Mock ISectionAccessor storage
	@Mock IConsoleContext executionContext
	@Mock ConsoleProxy consoleProxy
	@Mock JsonObject storageRoot


	@Before
	def void setUp() {
		aliases = new AliasStorage(new AliasStorageMock())
		jsUtils = spy(new JsUtilsProvider(executionContext))

		doThrow(new ScriptAssertError('', true))
			.when(jsUtils)
			.assertError(eq(false), anyString())

		when(executionContext.getJsUtils()).thenReturn(jsUtils)
		when(executionContext.getProxy()).thenReturn(consoleProxy)

		when(storageRoot.asObject()).thenReturn(null)
		when(storage.getRoot()).thenReturn(storageRoot)
		doNothing().when(storage).save()

		cmd = new AliasCommand(aliases)
	}


	@Test
	def void createAndRemoveAlias() {
		val aliasName = 'gbp'
		val aliasValue = 'currency gbp eur'

		// verify there are no aliases
		0.assertEquals(aliases.aliasCount)

		// create
		cmd.run(executionContext, '''«aliasName» «aliasValue»'''.toString.split(' '))
		1.assertEquals(aliases.aliasCount)

		// list it
		val logCaptor = ArgumentCaptor.forClass(String)
		doNothing().when(consoleProxy).log(logCaptor.capture())
		cmd.run(executionContext, 'list'.split(' '))
		assertTrue(logCaptor.allValues.get(0).contains(aliasValue))

		1.assertEquals(aliases.aliasCount)

		// remove it
		cmd.run(executionContext, 'remove gbp'.split(' '))
		0.assertEquals(aliases.aliasCount)
	}

	@Test
	def void shouldRemoveCorrectAlias() {
		// add 'gbp' and 'gbpp'
		0.assertEquals(aliases.aliasCount)
		cmd.run(executionContext, 'gbp currency gbp eur'.split(' '))
		cmd.run(executionContext, 'gbpp currency gbp eur'.split(' '))
		2.assertEquals(aliases.aliasCount)

		// remove the first one and validate
		cmd.run(executionContext, 'remove gbp'.split(' '))
		1.assertEquals(aliases.aliasCount)
		'currency gbp eur'.assertEquals(aliases.get('gbpp'))

		cmd.run(executionContext, 'list'.split(' '))
	}
}