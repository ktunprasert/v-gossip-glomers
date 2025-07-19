module main

import application
import rand
import x.json2

fn id_generator(ch_id chan string) {
	for {
		mut session := rand.new_uuid_v7_session()
		ch_id <- session.next()
	}
}

fn main() {
	mut app := application.new()
	ch_id := chan string{cap: 1} // buffered for fast
	go id_generator(ch_id)

	app.handle('generate', fn [ch_id] (body map[string]json2.Any) !map[string]json2.Any {
		mut resp := body.clone()
		resp['id'] = <-ch_id
		return resp
	})

	defer { ch_id.close() }

	app.start() or { panic(err) }
}
