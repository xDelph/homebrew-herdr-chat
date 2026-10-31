class HerdrChat < Formula
  desc "Drive Herdr and its coding agents from your phone (single Rust binary)"
  homepage "https://github.com/xDelph/herdr-chat"
  version "0.2.5"
  license "PolyForm-Noncommercial-1.0.0"

  on_macos do
    on_arm do
      url "https://github.com/xDelph/herdr-chat/releases/download/v#{version}/herdr-chat-macos-arm64.tar.gz"
      sha256 "152d92084633cef9394b9fee34ad78b9c12269a9e249a0159daf0da3d3ce8947"
    end
    on_intel do
      url "https://github.com/xDelph/herdr-chat/releases/download/v#{version}/herdr-chat-macos-x86_64.tar.gz"
      sha256 "37bfea82ed140aeb6e2321f352ba2803950d9925013f94bb246e62a0f1eac2d8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/xDelph/herdr-chat/releases/download/v#{version}/herdr-chat-linux-aarch64.tar.gz"
      sha256 "824632d9753e44112aa57e921d6d80661a18c06619251994b657f095da5cec80"
    end
    on_intel do
      url "https://github.com/xDelph/herdr-chat/releases/download/v#{version}/herdr-chat-linux-x86_64.tar.gz"
      sha256 "5615ef056ccd1459542863efdde6da7a2d649834e81331a1a93e55daa9c3bd51"
    end
  end

  def install
    bin.install "herdrchat"
    # Le service est un fichier fourni, pas un lancement implicite.
    (share/"herdr-chat").install "herdr-chat.service" if OS.linux?
  end

  test do
    # Un binaire qui répond à `--version` sans Bun, sans Node, sans base
    # système : c'est la propriété que l'archive doit garantir.
    assert_match "herdrchat", shell_output("#{bin}/herdrchat --version")
  end

  # ⚠️ `brew services` lance le démon sous launchd : PATH minimal, aucun
  # profil de shell lu. Or le démon lance `git`, `tailscale` et les CLI des
  # agents (`pi`, `codex`, `claude` — catalogue des modèles) par leur NOM : sans
  # leurs dossiers dans PATH, le catalogue d'un agent installé hors de Homebrew
  # (`~/.local/bin`, Bun) était introuvable.
  #
  # Les données restent dans le HOME, hors de la Cellar : `~/.herdr-remote/`
  # (abonnements push, lectures partagées, journal) — elles survivent aux mises
  # à jour et à `brew reinstall`.
  service do
    run [opt_bin/"herdrchat"]
    keep_alive true
    working_dir Dir.home
    log_path var/"log/herdr-chat.log"
    error_log_path var/"log/herdr-chat.log"
    environment_variables HERDR_REMOTE_BIND: "127.0.0.1",
                          HERDR_REMOTE_PORT: "8791",
                          PATH: [
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

  def caveats
    <<~EOS
      Start Herdr Chat in the background (and at login):
        brew services start herdr-chat

      It listens on 127.0.0.1:8791. To reach it from your phone over Tailscale:
        tailscale serve --bg --https=8790 http://127.0.0.1:8791

      Data (push subscriptions, read marks, log) lives in ~/.herdr-remote/.
      Agent CLIs (pi, codex, claude…) are looked up in Homebrew's bin,
      ~/.local/bin and ~/.bun/bin; set HERDR_REMOTE_* in the service if needed.
    EOS
  end
end
