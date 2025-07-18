module main

import application
import domain

type Msg = domain.Message

fn main() {
	mut app := application.new()
	app_ref := &app

	app.handle('init', fn [app_ref] (msg Msg) !Msg {
		msg_body := msg.body.as_map()
		(*app_ref).node_id = msg_body['node_id']!.str()

		return domain.Message.new(msg.id, app_ref.node_id, msg.src, {
			'type':        'init_ok'
			'in_reply_to': msg_body['msg_id']!
		})!
	})

	app.handle('echo', fn [app_ref] (msg Msg) !Msg {
		mut body := msg.body.as_map().clone()
		body['type'] = body['type']!.str() + '_ok'
		body['in_reply_to'] = body['msg_id']!

		return domain.Message{
			id:   msg.id
			src:  (*app_ref).node_id
			dest: msg.src
			body: body
		}
	})

	app.start() or { panic(err) }
}
