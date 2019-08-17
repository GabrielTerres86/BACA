-- Created on 04/01/2019 by F0030248 
-- Projeto 352 - Protesto
-- Baca para atualizar tipo da pessoa debitada - TEDs recebidas para pagto de boletos
declare 
  -- Local variables here
  i integer;
  vr_ok BOOLEAN;
begin
  -- Test statements here
  FOR rw IN (SELECT ROWID rowid_fin, t.* FROM tbfin_recursos_movimento t
              WHERE cdhistor = 2622
                AND dtconciliacao IS NULL) LOOP
                
    gene0005.pc_valida_cpf(pr_nrcalcul => rw.nrcnpj_debitada, 
                           pr_stsnrcal => vr_ok);
                           
    IF vr_ok THEN 
      i := 1;
    ELSE
      i := 2;
    END IF;                           
                           
    UPDATE tbfin_recursos_movimento t SET t.inpessoa_debitada = i
     WHERE ROWID = rw.rowid_fin;
                
  END LOOP;
  
  COMMIT;
end;