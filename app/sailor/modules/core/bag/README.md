# 🎒 Bag App - Inventaire du Profil

Système de gestion d'inventaire pour le profil PowerShell. Le joueur peut stocker, afficher et gérer les items collectés.

## Utilisation

```powershell
Bag       # Affiche le contenu du sac
bd        # Alias court pour Bag

# Ajouter des items (en PowerShell direct)
$item = [Item]::new("Médaille d'or", "Premier prix d'une compétition", 50, @{})
$global:bag.AddItem($item)

# Retirer des items
$global:bag.RemoveItem("Poisson séché", 1)

# Consulter un item
$item = $global:bag.GetItem("Renfort de filet")
$item | Format-List

# Voir la capacité
$global:bag.GetItemCount()   # Total d'items
$global:bag.IsFull()         # true/false selon capacité
```

## Architecture

### Classe Item
Classe générique représentant tout item collectible.

**Propriétés:**
- `name` (string) - Nom de l'item
- `description` (string) - Description courte
- `price` (int) - Valeur monétaire
- `quantity` (int) - Quantité en stock
- `metadata` (Hashtable) - Données custom (type, rareté, etc)

**Méthodes:**
- `IsAvailable()` - Retourne true si quantity > 0

### Classe Bag
Gère l'inventaire du joueur (ajout, suppression, sauvegarde).

**Propriétés:**
- `items` (Item[]) - Liste des items
- `maxCapacity` (int) - Limite de capacité (0 = illimité)
- `SavePath` (string) - Chemin du fichier JSON
- `stats` (Hashtable) - Statistiques (totalAcquired, lastModified)

**Méthodes:**
- `AddItem(Item)` - Ajoute un item (groupe les doublons)
- `RemoveItem(string $name, int $qty)` - Retire des items
- `GetItem(string $name)` - Retourne un item par nom
- `ListItems()` - Retourne tous les items
- `GetItemCount()` - Total d'items en inventaire
- `IsFull()` - Vérifie si sac plein
- `Save()` - Persiste en JSON
- `Load()` - Charge depuis JSON

### Classe BagRenderer
Affiche le sac avec un rendu ASCII coloré.

**Méthodes:**
- `RenderHeader()` - Titre et décoration
- `RenderItems(Item[])` - Affiche la liste
- `RenderItem(Item)` - Affiche un item individuel
- `RenderFooter(int, int)` - Stats et capacité

## Format JSON

```json
{
  "items": [
    {
      "name": "Item Name",
      "description": "Item description",
      "price": 100,
      "quantity": 5,
      "metadata": {
        "type": "upgrade",
        "rarity": "common"
      }
    }
  ],
  "maxCapacity": 0,
  "stats": {
    "totalAcquired": 5,
    "lastModified": "2024-05-20T09:00:00Z"
  }
}
```

## Intégration avec Merchant

Quand un item est acheté au Merchant:
1. Item retiré du Merchant (quantity--)
2. Item ajouté au Bag (quantity++)
3. Wallet décrémenté (balance -= price)

**À implémenter:** Commande `merchant Buy-Item <name>` qui fait cette intégration.

## Futur

- [ ] Capacité maximale et gestion d'espace
- [ ] Catégories d'items (upgrades, consumables, collectibles)
- [ ] Système de tri/filtrage
- [ ] Équipement actif (différence entre inventaire et équipé)
- [ ] Échange/trade entre joueurs (multiplayer future)

---

**Alias:** `bd` → `Bag`

**Fichiers:**
- `app/bag/bag.ps1` - Implémentation
- `home/persistent/bag.json` - État persistant
