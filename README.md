# 🗂 DIR /s - Parcours récursif de répertoires en assembleur x86

Ce projet a été réalisé dans le cadre d'un TP d'assembleur x86 à l'ENSIBS.  
L'objectif principal était de créer un programme en assembleur capable de reproduire le comportement de la commande `dir /s` de Windows.

Deux versions ont été développées :
- ✅ Une version **CLI** (console), fonctionnelle avec affichage UTF-8.
- ✅ Une version **GUI** (interface graphique), fonctionnelle avec Win32 API, zones de texte et boutons.

## 🧠 Objectifs pédagogiques

Ce projet m'a permis de :
- Maîtriser l'utilisation de l’API Windows (`FindFirstFile`, `FindNextFile`, `SetConsoleOutputCP`, etc.).
- Comprendre le fonctionnement de la **pile** (`push`, `call`, `esp`, `ebp`) et des **conventions d’appel** (`cdecl`, `stdcall`).
- Gérer des **fonctions récursives** en assembleur.
- Manipuler des **chaînes de caractères dynamiquement** avec `strncpy`, `strncat`, `sprintf` (libc).
- Travailler avec des **zones mémoire locales** sur la pile via des offsets (`[ebp - X]`).
- Construire une **interface graphique** simple avec `CreateWindowExA`, `EDIT`, `BUTTON`, et `STATIC`.

## 🖥 Version Console

La version console du programme :
- Lit un chemin au clavier avec `scanf`.
- Affiche tous les fichiers et dossiers du répertoire, **de manière récursive**.
- Utilise des **emojis** (📁 pour les dossiers, 📄 pour les fichiers) en **UTF-8**, avec `SetConsoleOutputCP(65001)` pour forcer l'encodage.
- Affiche l’arborescence avec une **indentation** basée sur la profondeur des dossiers.
- Tous les appels sont faits sans `invoke` ni macro MASM, en pur `push` + `call`.

## 🪟 Version Graphique

La version GUI du programme reprend la même logique :
- L’utilisateur entre un chemin dans une zone de saisie `EDIT`.
- Il clique sur un bouton `Lister`, qui lance la fonction récursive.
- Les résultats sont affichés dans une zone `EDIT` multi-ligne et scrollable.
- Le format est ASCII (`<DIR>` pour les dossiers, `<FILE>` pour les fichiers), avec indentation par espaces.
- La concaténation de l'affichage est faite manuellement avec `GetWindowTextA` + `lstrcatA` + `SetWindowTextA`.

## 📚 Partie Exercices du TP

En plus du projet principal `DIR /s`, plusieurs **exercices de manipulation bas niveau** ont été réalisés, conformément aux consignes du TP :

- **Appel de fonctions** : Création d'un projet avec un appel à `MessageBox` en assembleur, analyse de la pile via le débogueur.
- **Modes d’adressage** : Routines pour convertir une chaîne en majuscules et compter les caractères d’une chaîne, avec passage d'adresse via la pile.
- **Variables locales** : Réécriture en assembleur d'une fonction de type Fibonacci utilisant des variables locales pour `j`, `k`, `l`.
- **Analyse fonctionnelle** : Identification du comportement de la fonction (succession de Fibonacci), et vérification des résultats.
- **Comptage de caractères dans un mot** sur l'alphabet `{a, b, c}` : utilisation de variables locales pour renvoyer les compteurs dans `eax`, `ebx`, `ecx`.
- **Calculs simples** :
  - Affichage des diviseurs d’un nombre saisi au clavier.
  - Fonction récursive pour calculer la factorielle d’un entier.
- **Lecture d’article externe** sur les appels système Windows, avec résumé et compréhension du fonctionnement des syscalls (`ntdll`, `int 2e`, etc.).

Ces exercices m'ont permis d'approfondir les manipulations de chaînes, les boucles, les appels empilés, ainsi que l'organisation mémoire locale et la récursion.

## ⚠ Limitations

- L’interface graphique **gèle pendant l’exécution** du listing, car tout est fait dans le **thread principal**. Une amélioration possible serait de passer par un **thread secondaire** (`CreateThread`) pour garder l’UI réactive.
- Les **emojis** ne sont pas utilisés dans la GUI à cause des limitations d’encodage du contrôle `EDIT`.