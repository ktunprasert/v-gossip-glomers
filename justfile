echo:
    v run echo/main.v

test_echo:
    # v -prod echo/main.v -o v-echo
    v echo/main.v -o v-echo
    maelstrom test -w echo --bin ./v-echo --node-count 1 --time-limit 10 --log-stderr
