module main

import lib
import application
import x.json2

fn main() {
	mut app := application.new()

	mut messages := lib.ref([]u64{})
	chan_msg := chan u64{}

	mut node_map := lib.ref(map[string]string{})

	go fn [chan_msg, mut messages] () {
		for {
			id := <-chan_msg or { return }
			messages << id
			eprintln('received message id: ${id}')
		}
	}()

	app.handle('broadcast', fn [chan_msg] (body map[string]json2.Any) !map[string]json2.Any {
		v := body['message']!.u64()
		chan_msg <- v

		mut resp := body.clone()
		resp.delete('message')

		return resp
	})

	app.handle('topology', fn [node_map] (body map[string]json2.Any) !map[string]json2.Any {
		unsafe {
			(*node_map) = body['topology']!.as_map_of_strings()
		}
		mut resp := body.clone()
		resp.delete('topology')

		return resp
	})

	app.handle('read', fn [messages] (body map[string]json2.Any) !map[string]json2.Any {
		mut resp := body.clone()
		resp['messages'] = messages.map(json2.Any(it))

		return resp
	})

	app.start() or { panic(err) }
}
