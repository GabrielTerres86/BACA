/* INC0075008 - Retirar caracter especial do endereço */

BEGIN
  --
  UPDATE TBJDNPCRCB_TIT_DADOS@Jdnpcsql
  SET "LogradPagdr" = 'Rua Lauro Muller'
  WHERE "ISPBPrincipal" = 5463212
  AND "ISPBAdministrado" = 5463212
  AND "NumIdentcTit" = 2021010607788997778
  AND "CNPJCPFPagdr"='15299462000129';
  --
  COMMIT;
  --
END;
