module domain

import x.json2

pub struct Message {
pub:
	id   u64
	src  string
	dest string
	body json2.Any
}

pub fn Message.new(id u64, src string, dest string, body map[string]json2.Any) !Message {
	return Message{
		id:   id
		src:  src
		dest: dest
		body: body
	}
}

pub fn mapify(data map[string]json2.Any) !map[string]json2.Any {
	return data
}

pub fn make_body(items ...json2.Any) !map[string]json2.Any {
	if items.len % 2 == 1 {
		return error('incorrect usage you must use key-value pairs')
	}

	mut result := map[string]json2.Any{}
	for i := 0; i < items.len; i += 2 {
		a, b := items[i], items[i + 1]
		result[a.str()] = b
	}

	return result
}
