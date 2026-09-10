# Monétiser plus tard : ce que ça implique

Relevé le 10/09/2026 sur la documentation de Garmin
([monétisation](https://developer.garmin.com/connect-iq/monetization/),
[vente d'applications](https://developer.garmin.com/connect-iq/monetization/app-sales/),
[compte marchand](https://developer.garmin.com/connect-iq/monetization/merchant-onboarding/)).
Rien n'est à faire aujourd'hui ; ce document existe pour que la décision se
prenne plus tard en connaissance de cause.

**Réponse courte : oui, on peut passer une application gratuite en payante après
coup, et rien dans le code n'est à préparer.** Le store gère l'achat ; une
application payante n'embarque aucun code de paiement. Mais trois choses
méritent d'être sues avant de s'engager.

---

## 1. Cinq des treize modèles ne pourront pas l'acheter

C'est la conséquence la plus lourde, et elle est propre à ce projet. Une
application monétisée n'est proposée que sur une liste d'appareils restreinte,
tirée du niveau d'API. Confrontée à nos treize cibles :

| | Modèles |
|---|---|
| **Vendable** | Edge 540, 550, 840, 850, 1040, 1050, MTB, Explore 2 |
| **Non vendable** | Edge 530, 830, 1030, 1030 Plus, Explore |

Les cinq exclus sont les plus anciens, restés en API 3.x. Ce sont aussi, pour
quatre d'entre eux, ceux où la tape atteint le champ de données sans passer par
la barre de contrôle — autrement dit ceux où l'application est la plus agréable.

Passer l'application en payante reviendrait donc à la rendre **inachetable pour
ces cinq modèles**, sans possibilité de les servir gratuitement dans la même
fiche.

## 2. Les utilisateurs déjà installés devront payer

> « If you are setting a price for an app that has already been approved, the app
> is temporarily removed from the store so it can be reviewed again. After the
> app is approved, users receive a message explaining that they must purchase the
> app before they can use it again. »

La fiche est donc retirée le temps d'une nouvelle revue, et **ceux qui l'avaient
installée gratuitement perdent l'usage** tant qu'ils n'achètent pas. Les codes
promotionnels que Garmin mentionne ne couvrent pas ce cas : ils servent à migrer
des utilisateurs venus d'un *autre* système de monétisation.

La conclusion pratique est qu'il vaut mieux trancher **avant** de laisser une
base d'utilisateurs se constituer, ou accepter de la perdre.

## 3. Le compte marchand coûte 100 dollars par an

- **Frais de programme : 100 USD par an, non remboursables**, payés à
  l'inscription.
- La France fait partie des pays éligibles pour les développeurs.
- Pièces demandées : pièce d'identité, justificatif de domicile, justificatif
  de numéro fiscal, justificatif d'activité — davantage pour une société.
- Vérification de plusieurs jours, avec demandes de compléments possibles.
- **Garmin prélève 15 %** du prix hors taxes. Il ajoute la TVA, prend à sa
  charge les frais de carte, et retient sur les versements les taxes sur les
  services numériques et le coût de conversion de devise.
- Versements le 1er de chaque mois, à partir de 10 USD de solde. Les achats des
  cinq derniers jours du mois basculent souvent sur le mois suivant.

À 15 % de commission et 100 USD de frais fixes, il faut vendre pour environ
120 USD dans l'année avant de rentrer dans ses frais.

---

## Garder une version gratuite : les applications d'essai

Le seul mécanisme prévu pour cela est le **mode essai**
([App Trials](https://developer.garmin.com/connect-iq/core-topics/trial-apps/)),
et ce n'est pas un réglage de la fiche : c'est un chantier.

```xml
<iq:trialMode enable="true">
    <iq:unlockURL>https://…</iq:unlockURL>
</iq:trialMode>
```

Il faut alors :

- un **serveur HTTPS** à soi, qui reçoit la demande de déverrouillage du store
  et rappelle son `callbackUrl` par une requête **signée en OAuth 1** ;
- gérer soi-même le processus de déverrouillage et sa persistance ;
- traiter dans le code `AppBase.isTrial()` et, pour un essai limité dans le
  temps, `getTrialDaysRemaining()`.

Autrement dit : une infrastructure à héberger et à maintenir, pour une
application qui n'a aujourd'hui **aucune permission réseau** — c'est même ce qui
lui évite d'avoir à fournir une politique de confidentialité.

---

## Ce que je recommanderais

Publier en gratuit, et ne rouvrir la question qu'avec des chiffres
d'installation en main. Trois raisons :

1. Les cinq modèles exclus de la vente ne se rattrapent pas.
2. Le protocole est **rétro-conçu** et non documenté par iGPSPORT : une mise à
   jour de firmware de la lampe peut le casser du jour au lendemain. Vendre un
   logiciel dont la compatibilité tient à un tiers qui ne s'est engagé à rien
   crée une obligation qu'on ne peut pas garantir.
3. Un seul modèle de lampe a été essayé sur du matériel. Faire payer avant
   d'avoir des retours sur les autres, c'est vendre une promesse.

Rien de tout cela n'est irréversible : la décision peut se prendre dans six mois
sans qu'une ligne de code d'aujourd'hui ait à changer.
