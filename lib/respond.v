module lib

pub fn respond(payload string) {
	eprintln('responding ${payload}')
	println(payload)
	flush_stdout()
}
