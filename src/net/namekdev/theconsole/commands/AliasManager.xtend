package net.namekdev.theconsole.commands

import net.namekdev.theconsole.commands.api.IAliasManager
import java.util.ArrayList

class AliasManager implements IAliasManager {

	override get(String aliasName) {
		return null//TODO
	}

	override getAllAliasNames() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override getAliasCount() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override findAliasesStartingWith(String string, ArrayList<String> strings) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

}