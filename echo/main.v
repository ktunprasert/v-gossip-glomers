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

fn main() {
	mut node_id := ''

	// Read initialization message
	stdin := os.get_line()
	eprintln('Received init: ${stdin}')

	init := json2.decode[Message](stdin)!
	body := init.body.as_map()

	// Validate init message
	if body['type']! is json2.Null || body['type']!.str() != 'init' {
		eprintln('ERROR: unexpected initial payload')
		return
	}

	// Extract node info
	node_id = body['node_id']!.str()
	eprintln('Initialized node ${node_id}')

	// Send init_ok response
	init_resp := json2.encode(Message{
		id:   init.id
		src:  node_id
		dest: init.src
		body: map[string]json2.Any({
			'type':        json2.Any('init_ok')
			'in_reply_to': body['msg_id']!
		})
	})
	respond(init_resp)

	for line := os.get_line(); line.len != 0; line = os.get_line() {
		eprintln('Received: ${line}')

		msg := json2.decode[Message](line)!
		msg_body := msg.body.as_map()

		// Check if it's an echo message
		if msg_body['type']!.str() == 'echo' {
			// Create echo_ok response
			resp := json2.encode(Message{
				id:   msg.id
				src:  node_id
				dest: msg.src
				body: map[string]json2.Any({
					'type':        json2.Any('echo_ok')
					'echo':        msg_body['echo']!
					'in_reply_to': msg_body['msg_id']!
				})
			})
			respond(resp)
		}
	}
}
