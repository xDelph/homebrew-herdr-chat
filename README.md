# xDelph Homebrew taps

Formulae for my own tools. Nothing here is affiliated with Homebrew.

## Install

Newer Homebrew versions refuse to load non-official taps until you trust them, so
the first command is not optional:

```bash
brew trust xDelph/herdr-chat
brew install xDelph/herdr-chat
brew services start herdr-chat
```

## Available

### herdr-chat

Pilot Herdr and its agents from your phone. A local PWA that reads your Pi and
codex sessions and drives them through Herdr's own API.

```bash
brew trust xDelph/herdr-chat
brew install xDelph/herdr-chat
brew services start herdr-chat
```

Needs **Herdr** running on the same machine, and **Tailscale** to reach it from a
phone. The formula's `caveats` print the exact `tailscale serve` command after
installation — the server listens on `127.0.0.1` only, by design.

Source: <https://github.com/xDelph/herdr-chat> · PolyForm Noncommercial 1.0.0

## Other taps

`devcli` still lives in its own tap, unchanged:
`brew install xDelph/devcli`.
