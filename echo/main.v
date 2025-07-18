module main

import os
import x.json2

struct Message {
	id   u64
	src  string
	dest string
	body json2.Any
}

fn respond(payload string) {
	eprintln('responding ${payload}')
	println(payload)
	flush_stdout()
}

fn make_body(items ...json2.Any) !map[string]json2.Any {
	if items.len % 2 == 1 {
		return error('incorrect usage you must use key pairs')
	}

	mut result := map[string]json2.Any{}
	for i := 0; i < items.len; i += 2 {
		a, b := items[i], items[i + 1]
		result[a.str()] = b
	}

	return result
}

fn main() {
	mut node_id := ''

	for line := os.get_line(); line.len != 0; line = os.get_line() {
		eprintln('Received: ${line}')

		msg := json2.decode[Message](line)!
		msg_body := msg.body.as_map()

		match msg_body['type']!.str() {
			'init' {
				node_id = msg_body['node_id']!.str()
				init_resp := json2.encode(Message{
					id:   msg.id
					src:  node_id
					dest: msg.src
					body: make_body('type', 'init_ok', 'in_reply_to', msg_body['msg_id']!)!
				})
				respond(init_resp)
			}
			else {
				mut body := msg_body.clone()
				body['type'] = body['type']!.str() + '_ok'
				body['in_reply_to'] = body['msg_id']!
				resp := json2.encode(Message{
					id:   msg.id
					src:  node_id
					dest: msg.src
					body: body
				})
				respond(resp)
			}
		}
	}
}
