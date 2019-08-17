BEGIN

  /* CORRIGIR AS ORIGENS DISPONIBILIZADAS NA TABELA E INCLUIR AS NOVAS */

  -- 
  UPDATE tbgen_canal_entrada t
     SET t.nmcanal = 'AIMARO'
       , t.dscanal = 'AIMARO CARACTER'
   WHERE t.cdcanal = 1;
  --
  UPDATE tbgen_canal_entrada t
     SET t.nmcanal = 'TAA'
       , t.dscanal = 'TAA'
   WHERE t.cdcanal = 4;
  --
  UPDATE tbgen_canal_entrada t
     SET t.nmcanal = 'AIMARO WEB'
       , t.dscanal = 'AIMARO WEB'
   WHERE t.cdcanal = 5;
  --
  INSERT INTO tbgen_canal_entrada
                  (cdcanal
                  ,nmcanal
                  ,dscanal)
            VALUES(20
                  ,'CONSIGNADO'
                  ,'CONSIGNADO');
  --
  INSERT INTO tbgen_canal_entrada
                  (cdcanal
                  ,nmcanal
                  ,dscanal)
            VALUES(21
                  ,'API'
                  ,'PLATAFORMA API');

  COMMIT;

END;
