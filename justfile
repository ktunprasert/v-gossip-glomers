echo t="false" *FLAGS:
    v 01-echo/main.v -o v-echo
    @if [ "{{t}}" != "true" ]; then just test_echo; \
    else v {{FLAGS}} run 01-echo/main.v; fi

_test test_case binary:
    maelstrom test -w {{test_case}} --bin ./{{binary}} --node-count 1 --time-limit 10 --log-stderr

test_echo: (_test "echo" "v-echo")
