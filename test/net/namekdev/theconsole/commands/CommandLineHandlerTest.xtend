package net.namekdev.theconsole.commands

import net.namekdev.theconsole.commands.api.ICommandLineUtils
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.view.api.IConsoleOutput
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.powermock.modules.junit4.PowerMockRunner
import org.mockito.Mock

import static org.mockito.Matchers.*
import static org.mockito.Mockito.times
import static org.mockito.Mockito.verify
import static org.powermock.api.mockito.PowerMockito.*
import static extension org.junit.Assert.*
import net.namekdev.theconsole.commands.internal.AliasCommand

@RunWith(PowerMockRunner)
class CommandLineHandlerTest {
	CommandLineHandler commandLineHandler
	CommandCollection commands
	AliasCollection aliases

	@Mock
	IConsoleContext consoleContext

	@Mock
	ICommandLineUtils commandLineUtils

	@Mock
	IConsoleOutput consoleOutput


	@Before
	def void setUp() {
		when(consoleContext.getOutput).thenReturn(consoleOutput)

		commandLineHandler = null
		aliases = new AliasCollection
		commands = new CommandCollection(aliases)
		commandLineHandler = new CommandLineHandler(commands)
		commandLineHandler.init(consoleContext, commandLineUtils)
	}

	@Test
	def void executeInputAsCommandWithArgs() {
		fail()
	}

	@Test
	def void executeInputAsJavaScriptOneLiner() {
		fail()
	}

	@Test
	def void aliasCommands() {
		// install alias command
		val aliasCommand = mock(AliasCommand)
		commands.put('alias', aliasCommand)

		// first make sure that alias doesn't exist
		0.assertEquals(aliases.aliasCount)

		when(consoleOutput.addInputEntry(anyString())).thenReturn(null)
		when(consoleOutput.addTextEntry(anyString())).thenReturn(null)
		when(consoleContext.runUnscopedJs(anyString())).thenReturn(null)
		commandLineHandler.handleExecution('wiki', commandLineUtils, consoleContext)

		verify(consoleOutput, times(1)).addInputEntry(anyString())
		verify(consoleContext, times(1)).runUnscopedJs('wiki')


		// create alias
		commandLineHandler.handleExecution('alias wiki wikipedia', commandLineUtils, consoleContext)

		1.assertEquals(aliases.aliasCount)
		'wikipedia'.assertEquals(aliases.get('wiki'))


		// use alias
//		commandLineHandler.handleExecution('wiki', commandLineUtils, consoleContext)
//		verify(aliasCommand, times(1)).run(consoleContext, any())
	}

	@Test
	def void dontCompleteUnknownStuff() {
		fail()
	}

	@Test
	def void completeCommandName() {
		fail()
	}

	@Test
	def void completeArgument() {
		fail()
	}

	@Test
	def void completeArgumentWithQuotes() {
		fail()
	}
}
