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

### herdr-core-chat

Drive Herdr.app (herdr-core) and its coding agents from your phone. The
successor of `herdr-chat`, built on herdr-core's own protocol; both can be
installed and run side by side.

```bash
brew trust xDelph/herdr-chat
brew install xDelph/herdr-chat/herdr-core-chat
brew services start herdr-core-chat
```

Runs alongside Herdr Chat without sharing anything: port `8792` (Herdr Chat:
`8791`), data in `~/.herdr-core-chat/`, service `sh.brew.herdr-core-chat`. Needs
**Herdr.app** (herdr-core) on the same machine; the formula's `caveats` print the
`tailscale serve` command to reach it from a phone.

Source: <https://github.com/xDelph/herdr-core-chat> · PolyForm Noncommercial 1.0.0

## Other taps

`devcli` still lives in its own tap, unchanged:
`brew install xDelph/devcli`.
