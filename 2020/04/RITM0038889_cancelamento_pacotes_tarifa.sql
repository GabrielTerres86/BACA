BEGIN
    UPDATE tbtarif_contas_pacote pacote
       SET pacote.dtcancelamento = trunc(SYSDATE), pacote.cdoperador_cancela = '1', pacote.flgsituacao = 0 -- 0 = Inativo, 1 = Ativo     
     WHERE pacote.cdcooper = 12
       AND pacote.cdpacote IN (73, 74)
       AND pacote.flgsituacao = 1
       AND pacote.dtcancelamento IS NULL
       AND EXISTS (SELECT 1
              FROM crapass s
             WHERE s.cdcooper = pacote.cdcooper
               AND s.nrdconta = pacote.nrdconta);

    UPDATE tbtarif_contas_pacote pacote
       SET pacote.dtcancelamento = trunc(SYSDATE), pacote.cdoperador_cancela = '1', pacote.flgsituacao = 0 -- 0 = Inativo, 1 = Ativo     
     WHERE pacote.cdcooper IN (2, 5, 10, 11, 12, 13)
       AND pacote.cdpacote IN (61, 62)
       AND pacote.flgsituacao = 1
       AND pacote.dtcancelamento IS NULL
       AND EXISTS (SELECT 1
              FROM crapass s
             WHERE s.cdcooper = pacote.cdcooper
               AND s.nrdconta = pacote.nrdconta);
    COMMIT;
END;
