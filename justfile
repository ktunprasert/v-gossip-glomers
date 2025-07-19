alias e := echo
alias g := generate

echo t="true" *FLAGS: (_runner "echo" t "01-echo" "v-echo" FLAGS )
generate t="true" *FLAGS: (_runner "generate" t "02-generate" "v-generate" FLAGS)
broadcast t="true" *FLAGS: (_runner "broadcast" t "03-broadcast" "v-broadcast" FLAGS)

_runner name t path binary *FLAGS:
    v {{path}}/main.v -o {{binary}}
    @if [ "{{t}}" != "false" ]; then just test_{{name}}; \
    else v {{FLAGS}} run {{path}}/main.v; fi

_test test_case binary *FLAGS:
    maelstrom test --log-stderr -w {{test_case}} --bin ./{{binary}} {{FLAGS}}

test_echo: (_test "echo" "v-echo" "--node-count 1 --time-limit 10")
test_generate: (_test "unique-ids" "v-generate" "--time-limit 30 --rate 1000 --node-count 3 --availability total --nemesis partition")
test_broadcast: (_test "broadcast" "v-broadcast" "--node-count 1 --time-limit 20 --rate 10")
