class HerdrChat < Formula
  desc "Drive Herdr and its coding agents from your phone (single Rust binary)"
  homepage "https://github.com/xDelph/herdr-chat"
  version "0.2.7"
  license "PolyForm-Noncommercial-1.0.0"

  on_macos do
    on_arm do
      url "https://github.com/xDelph/herdr-chat/releases/download/v#{version}/herdr-chat-macos-arm64.tar.gz"
      sha256 "d0909b95d7cfdffd844b386ebcb4535458df2f9846c400b6f270ce91e478b042"
    end
    on_intel do
      url "https://github.com/xDelph/herdr-chat/releases/download/v#{version}/herdr-chat-macos-x86_64.tar.gz"
      sha256 "2403bfbcbaa938092bc3cae451c9409fc0dcafba3cdc754df27d724a98b10c62"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/xDelph/herdr-chat/releases/download/v#{version}/herdr-chat-linux-aarch64.tar.gz"
      sha256 "08fa6cd0e09c03762b3b6c3767e9718f9f6c4b3ae2bb4f823909750b30112330"
    end
    on_intel do
      url "https://github.com/xDelph/herdr-chat/releases/download/v#{version}/herdr-chat-linux-x86_64.tar.gz"
      sha256 "fd99811355b72c513f6222022a2302693e9a49e7aa1ddb9570bed49c6c0acb4a"
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
