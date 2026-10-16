class HerdrChat < Formula
  desc "Pilot Herdr and its agents from your phone"
  homepage "https://github.com/xDelph/herdr-chat"
  url "https://github.com/xDelph/herdr-chat/releases/download/v0.1.7/herdr-chat-0.1.7.tar.gz"
  sha256 "5f65e0608bbbf64cd3a92ccd86313b02c9aebbf3591808bc0d7352577e21dee5"
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
    # ⚠️ **`PATH` n'est pas facultatif ici.**
    # Sans lui, le superviseur démarre le service avec `/usr/bin:/bin`
    # seulement. Le lanceur y cherche `bun`, ne le trouve pas, et sort en 1 : le
    # service reste en « error » sans jamais écrire une ligne.
    #
    # Mesuré : la MÊME commande lancée à la main fonctionne (elle hérite du PATH
    # du shell), et échoue avec un PATH minimal. `std_service_path_env` est le
    # PATH standard de Homebrew pour les services, macOS comme Linux.
    environment_variables HERDR_REMOTE_BIND: "127.0.0.1", PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      Herdr Chat lit les sessions de Herdr : Herdr doit tourner, et son socket
      doit exister (~/.config/herdr/herdr.sock).

      Le serveur n'écoute qu'en local. Pour l'atteindre depuis le téléphone,
      exposez-le avec Tailscale — le port HTTPS par défaut suffit :

        tailscale serve --bg http://127.0.0.1:8791

      Puis ouvrez https://<votre-machine>.<votre-tailnet>.ts.net et ajoutez la
      PWA à l'écran d'accueil.

      Si le port 443 est déjà pris, servez sur un port explicite :

        tailscale serve --bg --https=8790 http://127.0.0.1:8791

      L'adresse devient alors
      https://<votre-machine>.<votre-tailnet>.ts.net:8790.

      Dans les deux cas, Herdr Chat lit la configuration de Serve au démarrage
      et autorise l'origine correspondante : il n'y a rien à déclarer à la main.
    EOS
  end

  test do
    assert_predicate bin/"herdrchat", :executable?

    # ⚠️ **La PWA doit voyager avec l'archive.** Le serveur la sert depuis
    # `apps/web/dist` ; sans elle, `herdrchat` démarre et ne sert aucune page —
    # une panne silencieuse, et c'est exactement ce que `dist` dans
    # `.gitignore` rend possible. On le vérifie donc à l'installation.
    assert_predicate prefix/"apps/web/dist/index.html", :exist?

    # Le paquet de workspace aussi, sans quoi le service meurt au démarrage.
    assert_predicate prefix/"packages/shared/src/index.ts", :exist?
  end
end
