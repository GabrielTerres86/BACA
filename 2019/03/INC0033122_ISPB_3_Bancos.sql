-- Ajustar ISPB cadastros de forma inválida.
-- INC0033122 - Wagner - Sustentação.

update crapban a
   set a.nrispbif = 27842177
 where a.cdbccxlt = 271;
 
update crapban a
   set a.nrispbif = 28650236
 where a.cdbccxlt = 292;

update crapban a
   set a.nrispbif = 43180355
 where a.cdbccxlt = 174;

COMMIT;
