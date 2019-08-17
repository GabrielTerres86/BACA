PL/SQL Developer Test script 3.0
118
DECLARE
  /* Tem abaixo 2 opcoes de select, uma buscando pela conta e valor, na data de hoje
     Se for usar a primeira opcao, cuidar se o cooperado nao pagou 2 titulos no mesmo dia e mesmo valor
     Recomendo executar o select antes e garantir que retorne somente um registro

     A segunda opcao utiliza o codigo de barras. So cuidar pois na tela ESTNET acedito que esteja formatado pela linha digitavel.
     Mas a cooperativa tiver o Cod. Barras pra informar pode ser utilizado tambem
  */
    -- estorno de titulos
    CURSOR c1 IS
    SELECT c.cdcooper
         , c.cdagenci
         , c.dtmvtolt
         , c.nrdconta
         , c.idseqttl
         , c.dscodbar
         , '' dscedent
         , c.vldpagto
         , '1' cdoperad
         , DECODE(c.cdagenci,90,3,4) idorigem
         , c.cdctrbxo
         , c.nrdident
         , c.rowid
      FROM craptit c
     WHERE (c.cdcooper = 11 -- codigo da cooperativa
       AND c.nrdconta = 1252 -- numero da conta
       AND c.dtmvtolt = '24/01/2019' -- data do pagamento
       AND c.vltitulo = 1414.25) -- valor do titulo
       or (c.cdcooper = 1 -- codigo da cooperativa
       AND c.nrdconta = 87459 -- numero da conta
       AND c.dtmvtolt = '24/01/2019' -- data do pagamento
       AND c.vltitulo = 3200)
       or (c.cdcooper = 1 -- codigo da cooperativa
       AND c.nrdconta = 421774 -- numero da conta
       AND c.dtmvtolt = '24/01/2019' -- data do pagamento
       AND c.vldpagto IN (417, 381))
       OR (c.cdcooper = 1 -- codigo da cooperativa
       AND c.nrdconta = 9715657 -- numero da conta
       AND c.dtmvtolt = '24/01/2019' -- data do pagamento
       AND c.vldpagto IN (166.88, 1307.90, 1000.00))
        OR (c.cdcooper = 1 -- codigo da cooperativa
       AND c.nrdconta = 826693 -- numero da conta
       AND c.dtmvtolt = '24/01/2019' -- data do pagamento
       AND c.vldpagto IN (800, 1186.31));
       
    -- estorno de convenios
    /*CURSOR c2 IS
    SELECT c.cdcooper
         , c.cdagenci
         , c.dtmvtolt
         , c.nrdconta
         , c.idseqttl
         , c.cdbarras
         , '' dscedent
         , c.cdseqfat
         , c.vllanmto
         , '1' cdoperad
         , DECODE(c.cdagenci,90,3,4) idorigem
--         , c.cdctrbxo
--         , c.nrdident
      FROM craplft c
     WHERE c.cdcooper = 1 
       and c.nrdconta = 8102007
       and c.dtmvtolt = '24/01/2019' 
       and c.vllanmto = 202.38;
       */

  vr_dstransa1 VARCHAR2(4000);
  vr_dscritic1 VARCHAR2(4000);
  vr_dsprotoc1 VARCHAR2(4000);
  
  vr_dstransa2 VARCHAR2(4000);
  vr_dscritic2 VARCHAR2(4000);
  vr_dsprotoc2 VARCHAR2(4000);
BEGIN
  FOR r1 IN c1 LOOP
    cecred.paga0004_temp.pc_estorna_titulotmp(pr_cdcooper => r1.cdcooper,
                                              pr_cdagenci => r1.cdagenci,
                                              pr_dtmvtolt => r1.dtmvtolt,
                                              pr_nrdconta => r1.nrdconta,
                                              pr_idseqttl => r1.idseqttl,
                                              pr_cdbarras => r1.dscodbar,
                                              pr_dscedent => r1.dscedent,
                                              pr_vlfatura => r1.vldpagto,
                                              pr_cdoperad => r1.cdoperad,
                                              pr_idorigem => r1.idorigem,
                                              pr_cdctrbxo => r1.cdctrbxo,
                                              pr_nrdident => r1.nrdident,
                                              pr_dstransa => vr_dstransa1,
                                              pr_dscritic => vr_dscritic1,
                                              pr_dsprotoc => vr_dsprotoc1);

    dbms_output.put_line('Titulo: '||r1.rowid);
    dbms_output.put_line('Titulo: '||vr_dstransa1);
    dbms_output.put_line('Titulo: '||vr_dscritic1);
    dbms_output.put_line('Titulo: '||vr_dsprotoc1);
    
    COMMIT;
  END LOOP;

  /*
  FOR r2 IN c2 LOOP
    cecred.paga0004_temp.pc_estorna_conveniotmp(pr_cdcooper => r2.cdcooper,
                                                pr_nrdconta => r2.nrdconta,
                                                pr_idseqttl => r2.idseqttl,
                                                pr_cdbarras => r2.cdbarras,
                                                pr_dscedent => r2.dscedent,
                                                pr_cdseqfat => r2.cdseqfat,
                                                pr_vlfatura => r2.vllanmto,
                                                pr_cdoperad => 1,
                                                pr_idorigem => r2.idorigem,
                                                pr_dstransa => vr_dstransa2,
                                                pr_dscritic => vr_dscritic2,
                                                pr_dsprotoc => vr_dsprotoc2);

    dbms_output.put_line('Convenio: ' || vr_dstransa2);
    dbms_output.put_line('Convenio: ' || vr_dscritic2);
    dbms_output.put_line('Convenio: ' || vr_dsprotoc2);
  END LOOP; 
  */
  
  --commit;
END;

0
0
