DECLARE 
 /* Cursor Registros com problemas */
  CURSOR cr_remessa_registro IS
    SELECT reg.cdstatus_processamento, -- alterar para 4
           rem.flgocorrencia, -- alterar para true
           reg.dsprocessamento, -- alterar para 'Erro processamento FITBANK'
           reg.idremessa,            
           reg.idsicredi,
           reg.rowid AS rowid_reg,
           rem.rowid AS rowid_rem
      FROM tbconv_registro_remessa_pagfor reg
      INNER join tbconv_remessa_pagfor rem on reg.idremessa = rem.idremessa
      where rem.dhenvio_remessa between '15/09/2021' and '31/10/2021'
      and reg.cdstatus_processamento in (1,2)
      AND rem.cdagente_arrecadacao = 3;
  rw_remessa_registro cr_remessa_registro%ROWTYPE;
BEGIN
  FOR rw_remessa_registro IN cr_remessa_registro LOOP
    BEGIN
        UPDATE tbconv_registro_remessa_pagfor reg
           SET reg.cdstatus_processamento = 4
              ,reg.dsprocessamento = 'Erro processamento FITBANK' 
         WHERE reg.rowid = rw_remessa_registro.rowid_reg;
         
         UPDATE tbconv_remessa_pagfor rem
           SET rem.flgocorrencia = 1
         WHERE rem.rowid = rw_remessa_registro.rowid_rem;
    EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
    END;
  END LOOP;
  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
END;
