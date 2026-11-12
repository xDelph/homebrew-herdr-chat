# Formule Homebrew de Herdr Core Chat — SOURCE de la formule publiée.
#
# Publiée dans le tap d'Herdr Chat, `xDelph/homebrew-herdr-chat`, à côté de
# `herdr-chat.rb` : `brew install xDelph/herdr-chat/herdr-core-chat`. Un tap,
# deux formules, deux versions indépendantes.
# Ce gabarit n'est jamais copié à la main : `scripts/formule-release.sh <version>`
# y met la version et les empreintes de la release GitHub `v<version>`
# (fichiers `.sha256` produits par `xtask release` dans la CI `release-rust`)
# et écrit le résultat dans le tap. Les marqueurs restent ici.
#
# ⚠️ Coexistence (docs/COEXISTENCE.md) : tout diffère d'Herdr Chat
# (`herdr-chat`) — formule, service `sh.brew.herdr-core-chat`, binaire, port
# 8792, journal, données `~/.herdr-core-chat/`.
class HerdrCoreChat < Formula
  desc "Drive Herdr.app (herdr-core) and its coding agents from your phone"
  homepage "https://github.com/xDelph/herdr-core-chat"
  license "PolyForm-Noncommercial-1.0.0"

  # La version vient de l'URL (`/download/v<version>/`) : `brew audit --strict`
  # refuse un `version` redondant. `formule-release.sh` réécrit les quatre.
  on_macos do
    on_arm do
      url "https://github.com/xDelph/herdr-core-chat/releases/download/v0.1.5/herdr-core-chat-macos-arm64.tar.gz"
      sha256 "d7c9035bcec3a6c1e7991d8c7fd5b501bc2d91e0835e86df1f5f4c17abdfb362"
    end
    on_intel do
      url "https://github.com/xDelph/herdr-core-chat/releases/download/v0.1.5/herdr-core-chat-macos-x86_64.tar.gz"
      sha256 "6f43bbb2238dd49c299cc3621434fccfd5410bf2c3ae49a3d243aa006f5d0041"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/xDelph/herdr-core-chat/releases/download/v0.1.5/herdr-core-chat-linux-aarch64.tar.gz"
      sha256 "5e0beb2e5551a799a9052bc8f85815bea9a8a09018f4f7153a6ddf411a08d9bb"
    end
    on_intel do
      url "https://github.com/xDelph/herdr-core-chat/releases/download/v0.1.5/herdr-core-chat-linux-x86_64.tar.gz"
      sha256 "ad4a00f6ad5d97b6ec570d290eb6a5be419828cdfaec6bc9640c65122e798d9b"
    end
  end

  def install
    bin.install "herdr-core-chat"
    # Le service est un fichier fourni, pas un lancement implicite.
    pkgshare.install "herdr-core-chat.service" if OS.linux?
  end

  def caveats
    <<~EOS
      Start Herdr Core Chat in the background (and at login):
        brew services start herdr-core-chat

      It listens on 127.0.0.1:8792 and talks to herdr-core
      (~/.local/state/herdr-core/default/default.sock). To reach it from your
      phone over Tailscale:
        tailscale serve --bg --https=443 http://127.0.0.1:8792

      It runs alongside Herdr Chat (8791) without sharing anything.
      Data (push subscriptions, read marks, log) lives in ~/.herdr-core-chat/.
      Agent CLIs (pi, codex, claude…) are looked up in Homebrew's bin,
      ~/.local/bin and ~/.bun/bin; set HERDR_CORE_CHAT_* in the service if needed.
    EOS
  end

  # ⚠️ `brew services` lance le démon sous launchd : PATH minimal, aucun
  # profil de shell lu. Or le démon lance `git`, `tailscale` et les CLI des
  # agents (`pi`, `codex`, `claude` — catalogue des modèles) par leur NOM : sans
  # leurs dossiers dans PATH, le catalogue d'un agent installé hors de Homebrew
  # (`~/.local/bin`, Bun) était introuvable.
  #
  # Les données restent dans le HOME, hors de la Cellar : `~/.herdr-core-chat/`
  # (abonnements push, clés VAPID, lectures partagées, journal) — elles
  # survivent aux mises à jour et à `brew reinstall`.
  service do
    run [opt_bin/"herdr-core-chat"]
    keep_alive true
    working_dir Dir.home
    log_path var/"log/herdr-core-chat.log"
    error_log_path var/"log/herdr-core-chat.log"
    environment_variables HERDR_CORE_CHAT_BIND: "127.0.0.1",
                          HERDR_CORE_CHAT_PORT: "8792",
                          PATH:                 [
                            HOMEBREW_PREFIX/"bin",
                            "#{Dir.home}/.local/bin",
                            "#{Dir.home}/.bun/bin",
                            "/usr/local/bin",
                            "/usr/bin",
                            "/bin",
                            "/usr/sbin",
                            "/sbin",
                          ].join(":")
  end

  test do
    # Un binaire qui répond à `--version` sans Bun, sans Node, sans base
    # système : c'est la propriété que l'archive doit garantir.
    assert_match "herdr-core-chat #{version}", shell_output("#{bin}/herdr-core-chat --version")
  end
end
