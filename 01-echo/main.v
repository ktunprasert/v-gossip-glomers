module main

import application
import x.json2

fn main() {
	mut app := application.new()

	app.handle('echo', fn (body map[string]json2.Any) !map[string]json2.Any {
		return body
	})

	app.start() or { panic(err) }
}
