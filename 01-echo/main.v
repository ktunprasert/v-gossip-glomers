module main

import application
import domain

type Msg = domain.Message

fn main() {
	mut app := application.new()

	app.handle('echo', fn [app] (msg Msg) !Msg {
		mut body := msg.body.as_map().clone()
		body['type'] = body['type']!.str() + '_ok'
		body['in_reply_to'] = body['msg_id']!

		return domain.Message{
			id:   msg.id
			src:  (*app).node_id
			dest: msg.src
			body: body
		}
	})

	app.start() or { panic(err) }
}
