# Nastavení přihlášení správce

Web používá Supabase jako sdílené úložiště. Anonymní návštěvníci mohou výsledky pouze číst; oprávnění k úpravám ověřuje databáze, ne samotný web.

## 1. Vytvořte Supabase projekt

Vytvořte projekt na [supabase.com](https://supabase.com) a v SQL Editoru spusťte celý soubor `supabase-setup.sql`.

## 2. Založte účet správce

V Supabase otevřete **Authentication → Users** a vytvořte uživatele s e-mailem a heslem. Veřejnou registraci ponechte vypnutou. Zkopírujte UUID tohoto uživatele a v SQL Editoru spusťte:

```sql
insert into public.tournament_admins (user_id)
values ('SEM-VLOZTE-UUID-UZIVATELE');
```

Pouze UUID vložené do této tabulky získá právo zapisovat výsledky. Dalšího správce přidáte stejným způsobem; odebráním řádku mu přístup zrušíte.

## 3. Propojte web s projektem

V nastavení projektu otevřete **Project Settings → API** a zkopírujte Project URL a veřejný `anon`/publishable klíč do `supabase-config.js`:

```js
window.TOURNAMENT_SUPABASE = {
  url: "https://vas-projekt.supabase.co",
  anonKey: "vas-verejny-anon-nebo-publishable-klic"
};
```

Tento klíč je určený pro webový frontend a může být ve veřejném GitHub repozitáři. **Nikdy sem nevkládejte `service_role` ani jiný secret key.** Přístup chrání pravidla Row Level Security vytvořená v SQL souboru.

## 4. Nahrajte web na GitHub Pages

Nahrajte `index.html`, `supabase-config.js` a `supabase-setup.sql` do repozitáře a publikujte stránku přes GitHub Pages. Přihlášení správce se objeví po nastavení URL a klíče. Přihlašovací heslo se zadává pouze do formuláře a není součástí souborů.

Po přihlášení správce se týmy a výsledky ukládají do Supabase. Ostatní návštěvníci vidí aktualizace automaticky, nejpozději při obnovení dat stránky. Změny v databázi mají povolené pouze účty uvedené v `tournament_admins`.

## Důležité

- Nevkládejte heslo správce ani `service_role` klíč do GitHubu.
- Veřejné výsledky může kdokoli zobrazit; veřejné úpravy databáze jsou zakázané pomocí RLS.
- Supabase projekt je samostatná služba, kterou je nutné vytvořit a nakonfigurovat; samotné zapnutí GitHub Pages databázi nezřídí.
