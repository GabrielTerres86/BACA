/*
  INC0035958 - Ajustar c�digo da ag�ncia creditada, pois
               quando � um DOC o c�digo � fixo 100 e isso
               impede a concilia��o. Haver� uma
               melhoria para ajustar a regra de processamento
               dos DOC na concilia��o do protesto eletr�nico.
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
