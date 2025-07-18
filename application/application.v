module application

import domain
import os
import x.json2
import lib

type MsgHandler = fn (domain.Message) !domain.Message

pub struct App {
pub mut:
	node_id  string
	handlers map[string]MsgHandler
	stdin    chan string
}

pub fn new() &App {
	mut app := App{}
	app.init()
	return &app
}

fn (mut a App) init() {
	a.handle('init', fn [a] (msg domain.Message) !domain.Message {
		msg_body := msg.body.as_map()
		(*a).node_id = msg_body['node_id']!.str()

		return domain.Message.new(msg.id, a.node_id, msg.src, {
			'type':        'init_ok'
			'in_reply_to': msg_body['msg_id']!
		})!
	})
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

		type := body['type'] or {
			eprintln("Field 'type' does not exist in payload body")
			continue
		}

		if type.str() !in a.handlers {
			eprintln('Handler for ${type} does not exist')
			continue
		}

		response := a.handlers[type.str()](msg) or {
			eprintln('Handler failed: ${err}')
			continue
		}

		lib.respond(json2.encode(response))
	}
}

pub fn (mut a App) handle(type string, handler MsgHandler) {
	a.handlers[type] = handler
}
