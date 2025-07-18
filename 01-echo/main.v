module main

import application
import x.json2

fn main() {
	mut app := application.new()

	app.handle('echo', fn (body map[string]json2.Any) !map[string]json2.Any {
		mut resp := body.clone()
		resp['type'] = body['type']!.str() + '_ok'
		resp['in_reply_to'] = body['msg_id']!

		return resp
	})

	app.start() or { panic(err) }
}
