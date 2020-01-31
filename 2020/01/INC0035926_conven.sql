-- Correcao caracteres especiais

update gnconve set dsidentfatura = ' ' where cdconven in (1,4,9,15,53);
commit;