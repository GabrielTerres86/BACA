DECLARE
 
  vr_exc_erro EXCEPTION;

  CURSOR cr_pagto IS
    SELECT r.rowid
          ,CASE WHEN r.tppagamento = 1 THEN
                  TO_DATE('27/10/2020 16:57:00','DD/MM/RRRR HH24:MI:SS')
                ELSE
                  DECODE(p.dtmovimento,TO_DATE('21/10/2020','DD/MM/RRRR'),TO_DATE('21/10/2020 19:00:00','DD/MM/RRRR HH24:MI:SS'),TO_DATE('23/10/2020 18:30:00','DD/MM/RRRR HH24:MI:SS'))
           END dtretorno
          ,CASE WHEN r.tppagamento = 1 THEN                  
                  '1QTH271016572006.RET'
                ELSE
                  DECODE(p.dtmovimento,TO_DATE('21/10/2020','DD/MM/RRRR'),'1QTH21101900.ret','1QTH23101837.ret') 
           END nmarquivo
          ,DECODE(r.tppagamento,1,3,4) cdstatus
          ,DECODE(r.tppagamento,1,'Aceito para processamento','Rejeitado - Contingência via Sicredi') dsprocessamento
      FROM tbconv_registro_remessa_pagfor r
          ,tbconv_remessa_pagfor p 
    WHERE r.idremessa = p.idremessa 
      AND p.cdagente_arrecadacao = 3
           -- 24 Tributos dos dias 21 e 23/10 para ajustar status de Pendente para Rejeição
      AND (r.idsicredi in (2245316,2246565,2246605,2247105,2247456,2248079,2248081,2248588,2248589,2248590,2248591,2248592,2248593,2248644,2248694,2248834,2249241,2249336,2249548,2249691,2249693,2249700,2257224,2259498) or
           -- 31 Utilities do dia 21/10 que foram rejeitadas e liquidadas posteriormente, com isso ajuste de status de Rejeição para Aceito para processamento
           r.idsicredi in (2249614,2245100,2245101,2245102,2245103,2248091,2245094,2245135,2245167,2245403,2248598,2248648,2245371,2245104,2245440,2245940,2248022,2248023,2248024,2248848,2248849,2245477,2248149,2248187,2248188,2248342,2248343,2248415,2248549,2245372,2245381));
  rw_pagto cr_pagto%ROWTYPE;
   
BEGIN
  
  FOR rw_pagto IN cr_pagto LOOP    
    
    BEGIN
      UPDATE tbconv_registro_remessa_pagfor reg
         SET reg.cdstatus_processamento  = rw_pagto.cdstatus
            ,reg.dhretorno_processamento = rw_pagto.dtretorno
            ,reg.nmarquivo_retorno       = rw_pagto.nmarquivo
            ,reg.dsprocessamento         = rw_pagto.dsprocessamento
       WHERE reg.rowid = rw_pagto.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Erro ao atualizar registro da tbconv_registro_remessa_pagfor. Erro -> '|| SQLERRM);
        RAISE vr_exc_erro;
    END;
    
  END LOOP;
  
  COMMIT;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
    WHEN OTHERS THEN
      dbms_output.put_line('Erro não tratado no script. Erro -> '|| SQLERRM);
      ROLLBACK;
      
END;
