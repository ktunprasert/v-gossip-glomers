module application

import domain
import os
import x.json2
import lib

pub type Body = map[string]json2.Any

type MsgHandler = fn (Body) !Body

pub struct App {
pub mut:
	node_id    string
	handlers   map[string]MsgHandler
	stdin      chan string
	body_hooks []fn (mut Body) !
}

pub fn new() &App {
	mut app := App{}
	app.init()
	return &app
}

fn (mut a App) init() {
	a.handle('init', fn [a] (body Body) !map[string]json2.Any {
		(*a).node_id = body['node_id']!.str()
		return body
	})

	a.body_hooks << fn (mut body Body) ! {
		body['type'] = body['type']!.str() + '_ok'

		if id := body['msg_id'] {
			body['in_reply_to'] = id.u64()
		}
	}
}

fn (mut a App) producer() {
	defer {
		a.stdin.close()
		eprintln('Closing stdin producer')
	}
	for line := os.get_line(); line.len != 0; line = os.get_line() {
		eprintln('Received: ${line}')
		a.stdin <- line
	}
}

fn (a &App) message(id u64, dest string, body Body) domain.Message {
	return domain.Message{
		id:   id
		src:  (*a).node_id
		dest: dest
		body: body
	}
}

pub fn (mut a App) start() ! {
	defer { eprintln('Exited successfully') }
	go a.producer()
	for {
		payload := <-a.stdin or {
			eprintln('Stopping consumer')
			return
		}

		msg := json2.decode[domain.Message](payload) or {
			eprintln('Unable to decode payload: ${payload.limit(30)}')
			continue
		}

		body := msg.body.as_map()
		eprintln('')

		type := body['type'] or {
			eprintln("Field 'type' does not exist in payload body")
			continue
		}

		if type.str() !in a.handlers {
			eprintln('Handler for ${type} does not exist')
			continue
		}

		mut res_body := a.handlers[type.str()](body) or {
			eprintln('Handler failed: ${err}')
			continue
		}

		for fun in a.body_hooks {
			fun(mut res_body) or {
				eprintln('Body hook failed: ${err}')
				continue
			}
		}

		response := a.message(msg.id, msg.src, res_body)

		lib.respond(json2.encode(response))
	}
}

pub fn (mut a App) handle(type string, handler MsgHandler) {
	a.handlers[type] = handler
}
