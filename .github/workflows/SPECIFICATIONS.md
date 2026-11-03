# Tempopo – Cahier des charges V1

> Nom en hommage au film culinaire *Tampopo* (Jūzō Itami, 1985). Signature : **« Cooking has a rhythm. »**
> Document de référence, placé à la racine du dépôt GitHub. L'identité visuelle est détaillée dans `DESIGN.md`.

## 1. Identité
- **Nom :** Tempopo
- **Plateforme :** Android 8+ (API 26). Code Flutter structuré pour permettre une version iPhone plus tard.
- **Langues :** français et anglais (selon la langue du téléphone ; choix manuel dans les réglages).
- **Modèle :** gratuit, sans publicité, sans compte, aucune donnée collectée.
- **Diffusion :** Google Play Store.

## 2. Recettes
- Une recette contient :
  - un **nom** ;
  - une **illustration** choisie dans un catalogue prédéfini (illustration générique par défaut) ;
  - une ou plusieurs **étapes** ;
  - un **rappel** facultatif entre deux étapes ;
  - un **message de fin** facultatif.
- **Une étape** comprend :
  - une durée (roulettes h/min/s) ;
  - un **type** qui fixe son icône : Four, Feu, Eau bouillante, Repos ou Autre. Un type est proposé automatiquement, par exemple « Four » si la température contient « °C » ;
  - un nom facultatif ;
  - une température facultative en texte libre.
- Actions : créer, modifier, dupliquer, supprimer, réordonner les étapes.
- **Aucune photographie**, ni import de photo : uniquement des illustrations prédéfinies.
- **Minuteur rapide** : lancer une durée sans l'enregistrer.
- **3 recettes d'exemple** au premier lancement (dans la langue du téléphone) :
  - **Œufs mollets** (illustration : œuf coupé en deux) : 1 étape de 6 min.
  - **Poulet rôti** (illustration : poulet entier) : 15 min à 210 °C → « Baisser le four à 190 °C » → 25 min à 190 °C → « Arroser et retourner le poulet » → 25 min à 190 °C → fin : « Laisser reposer 10 min ».
  - **Riz basmati** (illustration : bol de riz) : 10 min à feu doux → « Couper le feu, laisser couvert » → 5 min de repos → fin : « Égrener à la fourchette ».

## 3. Écrans
| Écran | Contenu et règles |
|---|---|
| **A. Accueil** | Logo, signature, casserole fumante, bouton « Commencer ». **Au premier lancement uniquement**, enchaîné avec l'assistant d'autorisations. Ensuite, l'application s'ouvre directement sur « Mes recettes » |
| **B. Mes recettes** | En-tête avec logo et signature. Cartes illustrées (illustration, nom, nombre d'étapes, durée totale, bouton ▶). Tri par dernière utilisation. **Toucher la carte ouvre le Détail**, ▶ lance la recette, le menu ⋮ propose modifier, dupliquer et supprimer. Bouton « Nouvelle recette » toujours accessible |
| **C. Détail** | Illustration en haut, nom, nombre d'étapes, durée totale. **Partition de cuisson verticale** : étapes numérotées avec icône, durée, température et nom ; rappels et message de fin visuellement distincts. Bouton « Lancer la cuisson » ; accès à la modification |
| **Éditeur** | Nom, choix de l'illustration, étapes (type, durée, nom, température, rappel), message de fin |
| **D. Choix du mode** | Fenêtre simple : automatique ou confirmation, dernier choix présélectionné |
| **E. En cours** | Une carte par minuteur. Actions : pause/reprise, +1 / −1 min, étape suivante, arrêter (avec confirmation). Tri par échéance |
| **F. Minuteur actif** | Plein écran, **toujours en thème sombre** (fond Soy Ink, chiffres Noodle Cream, accents Egg Yolk et Tomato Red). Grand compte à rebours, étape, température, progression, heure de fin, aperçu de l'étape suivante, grandes commandes |
| **G. Alerte de fin d'étape** | Plein écran. Titre générique (« C'est le moment ! »), rappel affiché en grand, illustration de la recette. Bouton principal « C'est fait ! » ; bouton secondaire « +1 minute » |
| **H. Fin de recette** | Même écran que l'alerte de fin (sonne jusqu'à l'arrêt) : grande illustration, vapeur, « À table ! » / « That's a wrap! », message de fin, bouton « Terminé » |
| **I. Réglages** | Sobres, lignes espacées, petites icônes |

## 4. Lancement
- Recette à 1 étape : lancement immédiat.
- Recette à plusieurs étapes : fenêtre D.
- Une même recette peut être lancée plusieurs fois, avec numérotation automatique : « Poulet rôti (2) ».
- Plusieurs minuteurs en parallèle, sans limite pratique.

## 5. Sonneries et alertes
| Situation | Sonnerie | Durée | Suite |
|---|---|---|---|
| Fin d'étape, mode automatique | « étape » | Quelques secondes (≈ 5 s, réglable), puis arrêt seul | L'étape suivante démarre **à l'heure exacte de fin**, pendant la sonnerie. Le message reste affiché |
| Fin d'étape, mode confirmation | « étape » | Jusqu'à l'arrêt par l'utilisateur | L'étape suivante démarre quand on appuie sur « C'est fait ! » |
| Fin de recette | « fin » (distincte) | Jusqu'à l'arrêt par l'utilisateur | Recette terminée |

- L'alerte s'affiche en plein écran, même téléphone verrouillé, avec de gros boutons.
- Les mêmes boutons sont présents dans la notification.
- Une notification avec compte à rebours reste affichée pour chaque minuteur actif.
- Les alertes simultanées s'affichent l'une après l'autre, chacune avec le nom de sa recette.
- Arrêt de sécurité de toute sonnerie après X minutes (réglable).

## 6. Réglages
- Sonnerie d'étape.
- Sonnerie de fin.
- Vibration.
- Durée de sonnerie (mode automatique).
- Arrêt de sécurité.
- Écran toujours allumé.
- Thème clair, sombre ou automatique.
- Langue.

## 7. Premier lancement
Écran d'accueil (A), puis assistant d'autorisations :
- notifications ;
- alarmes exactes ;
- alerte plein écran ;
- exclusion de l'optimisation de batterie, avec des conseils selon la marque du téléphone.

## 8. Identité visuelle (résumé, détail dans `DESIGN.md`)
- **Palette :** Tomato Red #C94F35 (signature), Noodle Cream #F4EBD9, Soy Ink #292C25, Egg Yolk #D7A747, Shiso Green #71816A, Sesame Beige #D8C5A8. Variantes plus foncées pour les petits textes colorés (accessibilité) et variantes pour le mode sombre. Pas de couleurs froides ni de dégradés.
- **Polices :** Fraunces (titres) et Manrope (interface), intégrées localement. Chiffres tabulaires pour les minuteurs.
- **Illustrations :** SVG prédéfinis, style naïf vintage, aplats de la palette. Les versions provisoires sont réalisées par Claude, les définitives viendront plus tard sans changement de code (mêmes noms de fichiers).
- **Motifs :** vapeur, vagues Seigaiha, fleurs, étoiles, avec parcimonie.
- **UX cuisine :** zones tactiles ≥ 48 dp (boutons principaux ≥ 56 dp), contrastes élevés, peu de texte, animations discrètes.
- **Règles :** aucune photo ; la lisibilité des minuteurs passe avant la décoration ; aucune régression fonctionnelle.

## 9. Sauvegarde
- V1 : sauvegarde automatique Android (Google) activée.
- V2 : export et import manuels des recettes (fichier JSON, fusion sans écrasement).

## 10. Principes techniques
- Alarmes système programmées à l'heure exacte (pas de décompte seconde par seconde).
- Mode automatique : toutes les alarmes de la recette sont programmées au lancement.
- Mode confirmation : l'alarme de l'étape suivante est programmée à l'appui sur « C'est fait ! ».
- Reprogrammation des minuteurs après un redémarrage du téléphone.
- Données stockées localement dans `recettes.json`. Format versionné ; la migration v1 → v2 ajoute l'illustration et le type d'étape.
- Textes FR/EN regroupés dans `lib/l10n/strings.dart`.
- Thème et composants centralisés dans `lib/theme/` et `lib/widgets/`.
- La couche « alarmes / sons / notifications » est isolée du reste du code, pour une future version iOS.

## 11. Hors V1 (V2 et plus tard)
- Export et import des recettes.
- Rappels au milieu d'une étape.
- Synchronisation des fins de plusieurs recettes.
- Étape « préchauffage » sans durée fixe.
- Lecture vocale des rappels.
- Widget.
- Illustrations définitives réalisées par un illustrateur.
- Version iPhone.

## 12. Plan
| Phase | Contenu |
|---|---|
| 0 ✅ | Projet Flutter, dépôt GitHub, chaîne de compilation |
| 1 ✅ | Recettes, stockage, recettes d'exemple, traductions FR/EN, éditeur |
| 1c | Socle graphique (thème, polices, composants, illustrations provisoires), refonte de « Mes recettes » et de l'éditeur, écran Détail |
| 2 | Moteur de minuteurs, écrans D, E et F |
| 3 | Alarmes, 2 sonneries, plein écran, notifications, écrans G et H (tests critiques) |
| 4 | Accueil et assistant d'autorisations, réglages (I), icône de l'application |
| 5 | Fiche Play Store FR/EN, politique de confidentialité, test fermé (12 testeurs × 14 jours), publication |

## 13. Organisation du développement
- **Dépôt :** https://github.com/gflorence/tempopo (public).
- **Identifiant Android :** `com.gflorence.tempopo`.
- **Édition du code :** VS Code (code fourni par Claude, copié-collé), Git pour synchroniser avec GitHub.
- **Pas de Flutter installé localement :** la compilation est faite par GitHub Actions.
  - `.github/workflows/bootstrap.yml` : initialisation du projet (exécutée une seule fois).
  - `.github/workflows/build-apk.yml` : compilation et signature de l'APK à chaque envoi sur `main`, publication dans *Releases*.
- **Signature :** clé stockée dans les secrets GitHub `KEYSTORE_BASE64` et `KEYSTORE_PASSWORD` (jamais dans le code).
- **Tests :** installation de l'APK sur le téléphone depuis https://github.com/gflorence/tempopo/releases/latest.
- **Règle de travail :** chaque phase est présentée sous forme de plan et validée avant l'écriture du code.