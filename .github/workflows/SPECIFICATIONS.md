# Tempopo – Cahier des charges V1

> Nom en hommage au film culinaire *Tampopo* (Jūzō Itami, 1985).
> Document de référence, à placer à la racine du dépôt GitHub (`SPECIFICATIONS.md`).

## 1. Identité
- **Nom :** Tempopo
- **Plateforme :** Android 8+ (API 26). Code Flutter structuré pour permettre une version iPhone plus tard.
- **Langues :** français et anglais (selon la langue du téléphone).
- **Modèle :** gratuit, sans publicité, sans compte, aucune donnée collectée.
- **Diffusion :** Google Play Store.

## 2. Recettes
- Une recette contient :
  - un **nom** ;
  - une ou plusieurs **étapes** (durée h/min/s, nom facultatif, température facultative en texte libre) ;
  - un **rappel** facultatif entre deux étapes (texte) ;
  - un **message de fin** facultatif.
- Actions : créer, modifier, dupliquer, supprimer, réordonner les étapes.
- **Minuteur rapide** : lancer une durée sans l'enregistrer.
- **3 recettes d'exemple** au premier lancement (traduites FR/EN) :
  - **Œufs mollets** : 1 étape de 6 min.
  - **Poulet rôti** : 15 min à 210 °C → « Baisser le four à 190 °C » → 25 min à 190 °C → « Arroser et retourner le poulet » → 25 min à 190 °C → fin : « Laisser reposer 10 min ».
  - **Riz basmati** : 10 min à feu doux → « Couper le feu, laisser couvert » → 5 min de repos → fin : « Égrener à la fourchette ».

## 3. Lancement
- Recette à 1 étape : lancement immédiat.
- Recette à plusieurs étapes : fenêtre de choix du mode **automatique** ou **confirmation**. Le dernier choix est présélectionné.
- Une même recette peut être lancée plusieurs fois. Les copies sont numérotées automatiquement : « Poulet rôti (2) ».
- Plusieurs minuteurs en parallèle, sans limite pratique.

## 4. Écran « En cours »
- Une carte par minuteur actif : nom, étape (« 2/3 »), température, compte à rebours, barre de progression, heure de fin prévue.
- Actions : pause / reprise, +1 / −1 min, passer l'étape, arrêter (avec confirmation).
- Tri par prochaine échéance. Une recette en attente de confirmation est clairement signalée.

## 5. Sonneries et alertes
| Situation | Sonnerie | Durée | Suite |
|---|---|---|---|
| Fin d'étape, mode automatique | « étape » | Quelques secondes (≈ 5 s, réglable), puis arrêt seul | L'étape suivante démarre **à l'heure exacte de fin**, pendant la sonnerie. Le message reste affiché |
| Fin d'étape, mode confirmation | « étape » | Jusqu'à l'arrêt par l'utilisateur | L'étape suivante démarre quand on appuie sur « Fait » |
| Fin de recette | « fin » (distincte) | Jusqu'à l'arrêt par l'utilisateur | Recette terminée |

- L'alerte s'affiche en plein écran, même téléphone verrouillé, avec de gros boutons.
- Les mêmes boutons sont présents dans la notification.
- Une notification avec compte à rebours reste affichée pour chaque minuteur actif.
- Les alertes simultanées s'affichent l'une après l'autre, chacune avec le nom de sa recette.
- Arrêt de sécurité de toute sonnerie après X minutes (réglable).

## 6. Réglages
- Choix des 2 sonneries (étape, fin).
- Vibration.
- Durée de la sonnerie en mode automatique.
- Arrêt de sécurité des sonneries.
- Écran toujours allumé.
- Thème clair, sombre ou automatique.
- Langue.

## 7. Premier lancement
Assistant d'autorisations :
- notifications ;
- alarmes exactes ;
- alerte plein écran ;
- exclusion de l'optimisation de batterie, avec des conseils selon la marque du téléphone.

## 8. Sauvegarde
- V1 : sauvegarde automatique Android (Google) activée.
- V2 : export et import manuels des recettes (fichier JSON, fusion sans écrasement).

## 9. Principes techniques
- Alarmes système programmées à l'heure exacte (pas de décompte seconde par seconde).
- Mode automatique : toutes les alarmes de la recette sont programmées au lancement.
- Mode confirmation : l'alarme de l'étape suivante est programmée à l'appui sur « Fait ».
- Reprogrammation des minuteurs après un redémarrage du téléphone.
- Données stockées localement (base locale).
- La couche « alarmes / sons / notifications » est isolée du reste du code, pour une future version iOS.

## 10. Hors V1 (V2 et plus tard)
- Export et import des recettes.
- Rappels au milieu d'une étape.
- Synchronisation des fins de plusieurs recettes.
- Étape « préchauffage » sans durée fixe.
- Lecture vocale des rappels.
- Widget.
- Version iPhone.

## 11. Plan
| Phase | Contenu |
|---|---|
| 0 | Projet Flutter, dépôt GitHub, ajout de ce document |
| 1 | Recettes, stockage, recettes d'exemple, traductions FR/EN |
| 2 | Moteur de minuteurs, choix du mode, écran « En cours » |
| 3 | Alarmes, 2 sonneries, plein écran, notifications (tests critiques) |
| 4 | Réglages, assistant d'autorisations, thème, icône |
| 5 | Fiche Play Store FR/EN, politique de confidentialité, test fermé (12 testeurs × 14 jours), publication |

## 12. Organisation du développement
- **Dépôt :** https://github.com/gflorence/tempopo (public).
- **Identifiant Android :** `com.gflorence.tempopo`.
- **Édition du code :** VS Code (code fourni par Claude, copié-collé), Git pour synchroniser avec GitHub.
- **Pas de Flutter installé localement :** la compilation est faite par GitHub Actions.
  - `.github/workflows/bootstrap.yml` : initialisation du projet (exécutée une seule fois).
  - `.github/workflows/build-apk.yml` : compilation et signature de l'APK à chaque envoi sur `main`, publication dans *Releases*.
- **Signature :** clé stockée dans les secrets GitHub `KEYSTORE_BASE64` et `KEYSTORE_PASSWORD` (jamais dans le code).
- **Tests :** installation de l'APK sur le téléphone depuis https://github.com/gflorence/tempopo/releases/latest.