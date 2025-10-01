package meta;

import meta.MetaType;
import meta.MetaMacro;

class Meta {
	private static var data:ScriptMetadata = MetaMacro.get();

	public static function getMetadata():ScriptMetadata {
		return data;
	}

	public static function getVersionString() {
		return '${data.version.major}.${data.version.minor}.${data.version.patch}';
	}
}
