module main

import os
import x.json2
import lib

fn main() {
	mut node_id := ''

	for line := os.get_line(); line.len != 0; line = os.get_line() {
		eprintln('Received: ${line}')

		msg := json2.decode[lib.Message](line)!
		msg_body := msg.body.as_map()

		match msg_body['type']!.str() {
			'init' {
				node_id = msg_body['node_id']!.str()
				res := lib.Message.new(msg.id, node_id, msg.src, 'type', 'init_ok', 'in_reply_to',
					msg_body['msg_id']!)!

				lib.respond(json2.encode(res))
			}
			else {
				mut body := msg_body.clone()
				body['type'] = body['type']!.str() + '_ok'
				body['in_reply_to'] = body['msg_id']!
				resp := json2.encode(lib.Message{
					id:   msg.id
					src:  node_id
					dest: msg.src
					body: body
				})
				lib.respond(resp)
			}
		}
	}
}
