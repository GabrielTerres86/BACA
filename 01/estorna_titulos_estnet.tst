PL/SQL Developer Test script 3.0
72
DECLARE
  /* Tem abaixo 2 opcoes de select, uma buscando pela conta e valor, na data de hoje
     Se for usar a primeira opcao, cuidar se o cooperado nao pagou 2 titulos no mesmo dia e mesmo valor
     Recomendo executar o select antes e garantir que retorne somente um registro

     A segunda opcao utiliza o codigo de barras. So cuidar pois na tela ESTNET acedito que esteja formatado pela linha digitavel.
     Mas a cooperativa tiver o Cod. Barras pra informar pode ser utilizado tambem
  */
  CURSOR c1 IS
    SELECT c.cdcooper
         , c.cdagenci
         , c.dtmvtolt
         , c.nrdconta
         , c.idseqttl
         , c.dscodbar
         , '' dscedent
         , c.vltitulo
         , '1' cdoperad
         , DECODE(c.cdagenci,90,3,4) idorigem
         , c.cdctrbxo
         , c.nrdident
      FROM craptit c
     WHERE c.cdcooper = 1 -- codigo da cooperativa
       AND c.nrdconta = 9201661 -- numero da conta
       AND c.dtmvtolt = '24/01/2019' -- data do pagamento
       AND c.vltitulo = 398.50; -- valor do titulo

    /*
    SELECT c.cdcooper
         , c.cdagenci
         , c.dtmvtolt
         , c.nrdconta
         , c.idseqttl
         , c.dscodbar
         , '' dscedent
         , c.vltitulo
         , '1' cdoperad
         , DECODE(c.cdagenci,90,3,4) idorigem
         , c.cdctrbxo
         , c.nrdident
      FROM craptit c
     WHERE c.cdcooper = 1 -- cooperativa
       AND UPPER(c.dscodbar) = '34191777900000398501094327142858317074758000'  -- codigo de barras
       AND c.dtmvtolt = '24/01/2019'; -- data do pagamento
    */

  vr_dstransa VARCHAR2(4000);
  vr_dscritic VARCHAR2(4000);
  vr_dsprotoc VARCHAR2(4000);
BEGIN
  FOR r1 IN c1 LOOP
    cecred.paga0004_temp.pc_estorna_titulotmp(pr_cdcooper => r1.cdcooper,
                                              pr_cdagenci => r1.cdagenci,
                                              pr_dtmvtolt => r1.dtmvtolt,
                                              pr_nrdconta => r1.nrdconta,
                                              pr_idseqttl => r1.idseqttl,
                                              pr_cdbarras => r1.dscodbar,
                                              pr_dscedent => r1.dscedent,
                                              pr_vlfatura => r1.vltitulo,
                                              pr_cdoperad => r1.cdoperad,
                                              pr_idorigem => r1.idorigem,
                                              pr_cdctrbxo => r1.cdctrbxo,
                                              pr_nrdident => r1.nrdident,
                                              pr_dstransa => vr_dstransa,
                                              pr_dscritic => vr_dscritic,
                                              pr_dsprotoc => vr_dsprotoc);

    dbms_output.put_line(vr_dstransa);
    dbms_output.put_line(vr_dscritic);
    dbms_output.put_line(vr_dsprotoc);
  END LOOP;
END;
0
0
