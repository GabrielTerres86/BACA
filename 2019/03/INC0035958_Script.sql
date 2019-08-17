/*
  INC0035958 - Ajustar código da agência creditada, pois
               quando é um DOC o código é fixo 100 e isso
               impede a conciliação. Haverá uma
               melhoria para ajustar a regra de processamento
               dos DOC na conciliação do protesto eletrônico.
*/
begin
  --
  update tbfin_recursos_movimento tr
  set tr.cdagenci_creditada = 1
  where tr.idlancto = 974;
  --
  commit;
  --
end;
