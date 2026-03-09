# Base de datos (MySQL)

El proyecto usa estos datos de conexion en Java:

- BD: `CartasPokemon`
- Host: `localhost`
- Puerto: `3306`
- Usuario: `pokemon_user`
- Password: `12345678`

## 1) Crear schema + usuario + tablas

Desde la raiz del repo:

```powershell
.\scripts\setup_db.ps1 -RootUser root
```

Si tu usuario `root` tiene password:

```powershell
.\scripts\setup_db.ps1 -RootUser root -RootPassword "TU_PASSWORD"
```

Tambien puedes ejecutar manualmente:

```powershell
mysql -u root -p < .\database\init.sql
```

## 2) Comprobar que hay conexion

```sql
SHOW DATABASES LIKE 'CartasPokemon';
USE CartasPokemon;
SHOW TABLES;
SELECT COUNT(*) FROM Carta;
SELECT COUNT(*) FROM Solicitud;
```

Si esto responde bien, la app ya puede leer/escribir cartas.
