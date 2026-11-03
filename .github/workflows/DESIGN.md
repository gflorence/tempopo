Tempopo — Implémentation de la charte graphique et refonte UI/UX

Tu interviens sur le projet Flutter Tempopo, une application Android de minuteurs de cuisson à étapes.

Ta mission est d'implémenter une identité visuelle complète et cohérente dans l'application, en t'appuyant sur les spécifications ci-dessous.

L'objectif est de donner à Tempopo une personnalité forte, chaleureuse et immédiatement reconnaissable.

Direction artistique
Concept

Tempopo — Cooking has a rhythm.

L'identité visuelle s'inspire de trois univers :

La culture culinaire japonaise et les petits restaurants traditionnels.
Le design éditorial des livres de cuisine et des affiches japonaises rétro.
L'illustration naïve, artisanale et légèrement vintage.
L'application doit être chaleureuse, ludique, élégante et accessible.

Elle ne doit surtout pas ressembler à une application domotique, à un outil industriel ou à une application de suivi nutritionnel.

Le concept graphique central est celui d'une cuisine qui a son propre rythme : les recettes sont des séquences, les étapes sont des mouvements et les minuteurs donnent le tempo.

Palette de couleurs
Utiliser exclusivement cette palette comme base de l'identité graphique.

Nom| Code hexadécimal| Utilisation
Tomato Red| #C94F35| Couleur principale, CTA, accents
Noodle Cream| #F4EBD9| Fond principal
Soy Ink| #292C25| Texte principal, mode sombre
Egg Yolk| #D7A747| Accents, minuteurs, alertes
Shiso Green| #71816A| Actions terminées, confirmations
Sesame Beige| #D8C5A8| Surfaces secondaires, séparateurs

Prévoir des variantes adaptées au mode sombre, tout en conservant l'identité colorimétrique.

Le rouge tomate doit rester la couleur signature de Tempopo.

Éviter les couleurs froides, les bleus technologiques et les dégradés.

Typographie
Utiliser :

Fraunces pour les titres, les messages éditoriaux et les éléments de personnalité.
Manrope pour les textes d'interface, les boutons, les informations et les formulaires.
Les deux polices peuvent être intégrées localement dans les assets Flutter.

Les chiffres des minuteurs doivent utiliser des chiffres tabulaires (tabular figures), afin d'éviter les déplacements visuels pendant le décompte.

Les durées doivent être très lisibles, même à distance.

Illustrations : règle fondamentale
Aucune photographie dans l'application.

Il n'est pas prévu que les utilisateurs ajoutent des photos à leurs recettes.

Toutes les illustrations doivent être prédéfinies et intégrées aux assets de l'application.

Créer un petit système d'illustrations originales dans un style :

Dessin naïf à la main.
Formes simples et légèrement imparfaites.
Couleurs plates issues de la palette Tempopo.
Contours organiques.
Texture subtile évoquant l'impression sur papier.
Inspiration des illustrations de livres de cuisine japonais vintage.
Illustrations à prévoir :

Poulet rôti.
Œuf mollet.
Bol de riz.
Bol de ramen.
Casserole fumante.
Cocotte.
Poisson.
Légumes (ail, oignon, carotte, champignon).
Ustensiles de cuisine.
Minuteur mécanique.
Ces illustrations servent à décorer les écrans et à donner une identité aux recettes d'exemple.

Elles ne doivent pas être générées dynamiquement.

Prévoir un système de correspondance entre les recettes et leurs illustrations prédéfinies. Pour les recettes créées par l'utilisateur, utiliser une illustration générique ou une illustration choisie parmi une petite sélection prédéfinie.

Ne jamais prévoir de fonctionnalité d'import ou d'ajout de photographie.

Motifs décoratifs
Pour éviter les écrans trop vides sans utiliser de photographies, développer quelques motifs graphiques récurrents :

Vapeur stylisée s'échappant d'une casserole.
Petites fleurs naïves.
Vagues japonaises stylisées (inspiration Seigaiha).
Petits soleils et étoiles.
Lignes de mouvement autour des illustrations.
Cercles et cadrans évoquant le temps.
Petits motifs végétaux.
Ces motifs doivent être utilisés avec parcimonie, en arrière-plan ou dans les espaces libres.

Ne pas surcharger les écrans fonctionnels.

Architecture graphique des composants
Créer un système de composants Flutter réutilisables.

Prévoir notamment :

Un thème centralisé avec les couleurs et typographies.
Des boutons primaires et secondaires.
Des cartes de recettes.
Des cartes de minuteurs.
Des indicateurs d'étapes.
Des barres de progression.
Des composants de compte à rebours.
Des dialogues et fenêtres de confirmation.
Des composants d'alerte plein écran.
Des éléments décoratifs et illustrations réutilisables.
Les composants doivent s'adapter au thème clair et sombre.

Éviter les interfaces Material Design standard sans personnalisation.

Les boutons doivent avoir des formes douces, avec des coins arrondis, sans adopter un style excessivement moderne ou minimaliste.

Déclinaison sur les écrans
A. Écran d'accueil

Logo Tempopo.
Signature « Cooking has a rhythm ».
Illustration centrale d'une casserole fumante.
Quelques motifs décoratifs.
Bouton principal « Commencer ».
L'écran doit être accueillant et immédiatement identifiable.

B. Bibliothèque de recettes

Titre : « Mes recettes ».

Présenter les recettes sous forme de cartes illustrées.

Chaque carte comprend :

Une petite illustration prédéfinie.
Le nom de la recette.
Le nombre d'étapes.
La durée totale.
Un bouton pour lancer directement la recette.
Les trois recettes initiales doivent avoir leurs propres illustrations :

Œufs mollets : illustration d'un œuf coupé en deux.
Poulet rôti : illustration naïve d'un poulet entier.
Riz basmati : illustration d'un bol de riz.
Prévoir également les actions de modification, duplication et suppression.

Le bouton « Nouvelle recette » doit être facilement accessible.

Ne pas utiliser de photos, même comme placeholders.

C. Détail d'une recette

Afficher :

Une illustration de la recette en partie supérieure.
Son nom.
Le nombre d'étapes.
La durée totale.
La séquence complète des étapes.
Représenter les étapes comme une partition de cuisson verticale.

Chaque étape doit être visuellement identifiable avec :

Un numéro.
Une icône adaptée.
Sa durée.
Sa température éventuelle.
Son nom éventuel.
Les rappels entre étapes doivent être visuellement distincts des étapes chronométrées.

Exemple pour le poulet rôti :

Illustration de flamme : 15 min à 210 °C.
Rappel : « Baisser le four à 190 °C ».
Illustration de flamme : 25 min à 190 °C.
Rappel : « Arroser et retourner le poulet ».
Illustration de flamme : 25 min à 190 °C.
Message de fin : « Laisser reposer 10 min ».
Bouton principal : « Lancer la cuisson ».

D. Choix du mode de fonctionnement

Lorsqu'une recette comporte plusieurs étapes, proposer une fenêtre élégante permettant de choisir :

Mode automatique
Les étapes s'enchaînent automatiquement. Les rappels restent affichés et les alertes sonores prévues sont déclenchées.

Mode confirmation
L'utilisateur valide chaque étape avant de passer à la suivante.

Le dernier choix utilisé doit être présélectionné.

Cette fenêtre doit rester simple et compréhensible.

E. Écran « En cours »

C'est l'un des écrans les plus importants de l'application.

Il doit permettre de surveiller plusieurs recettes simultanément.

Présenter une carte par minuteur actif.

Chaque carte doit afficher :

Le nom de la recette.
L'étape en cours (ex. 2/3).
La température éventuelle.
Le compte à rebours.
Une barre de progression.
L'heure de fin prévue.
L'état du minuteur : actif, en pause ou en attente de confirmation.
Les cartes doivent être triées par prochaine échéance.

Les minuteurs en attente de confirmation doivent être particulièrement visibles.

Prévoir les actions :

Pause / reprise.
+1 minute.
−1 minute.
Étape suivante.
Arrêter (avec confirmation).
F. Écran de minuteur actif

Prévoir un mode sombre particulièrement soigné.

Fond Soy Ink, chiffres Noodle Cream, accents Egg Yolk et Tomato Red.

Le compte à rebours doit occuper une place centrale et être extrêmement lisible.

Afficher :

Nom de la recette.
Étape actuelle.
Temps restant.
Température.
Barre de progression.
Heure de fin prévue.
Aperçu de l'étape suivante.
Les commandes doivent être grandes et facilement accessibles.

Ne pas sacrifier la lisibilité au profit de la décoration.

G. Écran d'alerte

Les alertes sont essentielles à l'expérience utilisateur.

Créer un écran plein écran avec une hiérarchie visuelle très forte.

Exemple :

Illustration d'un poulet stylisé avec des traits de mouvement.

Titre :
« Time to turn the chicken! »

Instruction :
« Arroser et retourner le poulet avant de poursuivre la cuisson. »

Bouton principal :
« C'est fait ! »

Bouton secondaire :
« +1 minute »

L'alerte doit clairement distinguer les fins d'étape des fins de recette.

Conserver les contraintes fonctionnelles du cahier des charges concernant les sonneries, les notifications et les actions sur écran verrouillé.

H. Écran de fin

Créer une expérience positive et ludique.

Exemple :

Grande illustration d'un plat terminé.
Quelques motifs de vapeur.
Titre : « That's a wrap! »
Message : « Dinner is ready. »
Bouton : « Terminé ».
I. Réglages

Les réglages doivent rester sobres et fonctionnels.

Utiliser des lignes bien espacées, avec de petites icônes illustrées ou personnalisées.

Conserver tous les réglages prévus dans le cahier des charges :

Sonnerie d'étape.
Sonnerie de fin.
Vibration.
Durée de sonnerie.
Arrêt de sécurité.
Écran toujours allumé.
Thème.
Langue.
Expérience utilisateur et contraintes
La cuisine est un environnement particulier.

L'interface doit être conçue pour une utilisation :

À une main.
Avec les mains potentiellement sales ou mouillées.
À distance du téléphone.
Avec une attention limitée, car l'utilisateur cuisine en parallèle.
Par conséquent :

Boutons suffisamment grands.
Zones tactiles généreuses.
Informations importantes immédiatement visibles.
Contrastes élevés.
Peu de texte superflu.
Pas de navigation complexe.
Pas d'animations inutiles.
Respecter les principes d'accessibilité Android.

Les animations doivent être discrètes et fluides.

Contraintes techniques impératives
Le projet existe déjà en Flutter.

Avant de modifier le code :

Examiner l'architecture existante.
Identifier les écrans, widgets, modèles et services déjà implémentés.
Identifier les fonctionnalités opérationnelles.
Proposer un plan d'implémentation cohérent.
Ne pas reconstruire le projet à partir de zéro.

Ne pas modifier :

Le moteur de minuteurs.
La programmation des alarmes Android.
La gestion des notifications.
Les mécanismes de sauvegarde.
La logique des modes automatique et confirmation.
La base de données.
Les permissions Android.
Sauf nécessité technique absolue, la mission porte exclusivement sur la présentation et l'expérience utilisateur.

Ne jamais remplacer une fonctionnalité existante par une simple maquette visuelle.

Toutes les interactions doivent rester opérationnelles.

Conserver la compatibilité Android 8+ (API 26 minimum) et l'architecture permettant une future version iOS.

Conserver la traduction française et anglaise. Tous les nouveaux textes doivent être internationalisés.

Organisation du travail
Procéder progressivement.

Phase 1 — Analyse
Examiner le dépôt et identifier les composants existants.

Phase 2 — Design system
Créer les couleurs, typographies, thèmes, composants communs et illustrations.

Phase 3 — Écrans
Implémenter les écrans en respectant la direction artistique et les fonctionnalités existantes.

Phase 4 — Vérification
Vérifier :

Thème clair et sombre.
Français et anglais.
Différentes tailles d'écran.
Lisibilité des minuteurs.
Navigation.
Fonctionnement réel de tous les boutons.
Absence de régression fonctionnelle.
Phase 5 — Livraison
Fournir un résumé des modifications, les éventuels nouveaux assets, les fichiers modifiés et les éventuels points restant à traiter.

Ne pas publier directement sur GitHub sans validation préalable.

Résultat attendu
Je souhaite une application qui donne l'impression d'un petit carnet de cuisine japonais illustré, modernisé pour Android.

L'identité doit être reconnaissable, cohérente et suffisamment originale pour que Tempopo ait une vraie personnalité.

Trois règles non négociables :

Aucune photographie dans l'application : uniquement des illustrations prédéfinies.
La lisibilité et l'efficacité des minuteurs passent avant la décoration.
La refonte graphique ne doit entraîner aucune régression fonctionnelle.
La référence esthétique est celle d'un livre de cuisine japonais rétro, avec des illustrations naïves, des couleurs chaudes et une interface contemporaine.