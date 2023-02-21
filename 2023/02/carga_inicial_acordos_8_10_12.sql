BEGIN

  INSERT INTO GESTAODERISCO.tbrisco_operacao_acordo(cdcooper
                                                   ,nrdconta
                                                   ,nrctremp
                                                   ,nracordo
                                                   ,cdproduto
                                                   ,dsnivel_acordo
                                                   ,tpmanutencao
                                                   ,dtpagamento_entrada)
    SELECT cdcooper
          ,nrdconta
          ,decode(cdproduto, 4, nrborder, nrctremp) nrctremp
          ,nracordo
          ,cdproduto
          ,RISC0004.fn_traduz_risco(inrisco_acordo) dsnivel_acordo
          ,tpmanutencao
          ,dtpagamento_entrada
      FROM (SELECT a.nracordo
                  ,a.cdcooper
                  ,a.nrdconta
                  ,CASE c.cdorigem
                     WHEN 1 THEN 10 
                     WHEN 2 THEN 90 
                     WHEN 3 THEN 90 
                     WHEN 4 THEN 3  
                     ELSE 0
                   END cdproduto
                  ,c.nrctremp
                  ,c.inrisco_acordo
                  ,a.cdsituacao
                  ,1 AS tpmanutencao
                  ,c.dtpagamento_entrada
                  ,(SELECT tc.nrborder
                      FROM tbdsct_titulo_cyber tc
                     WHERE tc.cdcooper = a.cdcooper
                       AND tc.nrdconta = a.nrdconta
                       AND tc.nrctrdsc = c.nrctremp) nrborder
              FROM cecred.tbrecup_acordo          a
                  ,cecred.tbrecup_acordo_contrato c
             WHERE a.nracordo = c.nracordo
               AND a.cdcooper IN (8, 10, 12)
               AND c.cdmodelo = 2
               AND a.cdsituacao = 1);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20010, 'Erro ao inserir tbrisco_operacao_acordo: '||SQLERRM);
END;
