class HerdrChat < Formula
  desc "Pilot Herdr and its agents from your phone"
  homepage "https://github.com/xDelph/herdr-chat"
  url "https://github.com/xDelph/herdr-chat/releases/download/v0.1.0/herdr-chat-0.1.0.tar.gz"
  sha256 "4c959f7f08f36403d02c60e7f9ac22244c41d17722db95b42e3d27eea424b937"
  license "PolyForm-Noncommercial-1.0.0"

  # Le serveur tourne en TypeScript : pas d'étape de compilation ici, les
  # sources sont livrées prêtes (la PWA est déjà construite dans l'archive).
  depends_on "bun"

  def install
    # ⚠️ **Les dépendances ne sont PAS dans l'archive.**
    # Le tarball livre les sources et la PWA déjà construite, pas `node_modules` :
    # sans cette étape, `bun` ne trouve même pas le paquet de workspace
    # `@herdr-remote/shared`, et le service meurt au démarrage sur
    # « Cannot find module ». Mesuré, pas supposé.
    #
    # ⚠️ On installe ICI, sur la machine de l'utilisateur, et pas dans la release :
    # les binaires natifs doivent correspondre à SON architecture. La release est
    # construite sur Linux, l'utilisateur est sur macOS.
    # ⚠️ **Tout à la racine du préfixe, jamais dans `libexec`.**
    # Le lanceur remonte d'un cran depuis son propre dossier pour trouver
    # `apps/server/src/main.ts` — c'est ainsi que le serveur résout lui-même ses
    # assets (`import.meta.dir`). Un `libexec.install` suivi d'un lien
    # symbolique casserait cette remontée : le lanceur ne résout pas les liens.
    prefix.install Dir["*"]

    # ⚠️ **APRÈS la copie, et pas avant — c'est tout le correctif.**
    #
    # La version précédente installait dans le *buildpath* puis copiait. Le
    # service démarrait alors et mourait aussitôt sur
    # « Cannot find module '@herdr-remote/shared' » : la copie détruit la
    # disposition que bun crée dans `node_modules/.bun`, et le paquet de
    # workspace devient introuvable.
    #
    # Mesuré, pas supposé : le MÊME tarball, extrait dans un dossier vide,
    # installé sur place et lancé, démarre correctement.
    #
    # ⚠️ Et ici, sur la machine de l'utilisateur : la release est construite sur
    # Linux, il est sur macOS — les binaires natifs doivent être les siens.
    cd prefix do
      system "bun", "install", "--frozen-lockfile", "--production"
    end
  end

  service do
    run [opt_bin/"herdrchat"]
    keep_alive true
    environment_variables HERDR_REMOTE_BIND: "127.0.0.1"
  end

  def caveats
    <<~EOS
      Herdr Chat lit les sessions de Herdr : Herdr doit tourner, et son socket
      doit exister (~/.config/herdr/herdr.sock).

      Le serveur écoute en local seulement. Pour l'atteindre depuis le
      téléphone, exposez-le avec Tailscale :

        tailscale serve --bg --https=8790 http://127.0.0.1:8791

      Puis ouvrez https://<votre-machine>.<tailnet>.ts.net:8790 et installez la
      PWA sur l'écran d'accueil.
    EOS
  end

  test do
    assert_predicate bin/"herdrchat", :executable?
  end
end
