declare

  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt FROM crapdat dat WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;

  pr_retxml   xmltype;
  vr_xml_def  VARCHAR2(4000); --> XML Default de Entrada    
  pr_cdcritic PLS_INTEGER; --> Código da crítica
  pr_dscritic VARCHAR2(4000);
  pr_nmdcampo VARCHAR2(4000);
  pr_des_erro VARCHAR2(4000);

  vr_cdcooper  NUMBER(5) := 1;
  vr_nrddconta NUMBER(10) := 9122354;

  vr_tpdevolucao      NUMBER(1);
  vr_vlcapital        NUMBER(15, 2);
  vr_qtparcelas       NUMBER(2);
  vr_dtinicio_credito DATE;
  vr_vlpago           NUMBER(15, 2);

  vr_vldcotas number;
begin
  select t.vldcotas
    into vr_vldcotas
    from crapcot t
   where t.nrdconta = vr_nrddconta
     and t.cdcooper = vr_cdcooper;

  delete from tbcotas_devolucao t
   where t.nrdconta = vr_nrddconta
     and t.cdcooper = vr_cdcooper;

  OPEN cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH cr_crapdat
    INTO rw_crapdat;
  CLOSE cr_crapdat;

  vr_xml_def := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root>  <Dados>    <cdcooper>1</cdcooper> <vldcotas>0</vldcotas> <formadev>1</formadev> <qtdparce>0</qtdparce> <datadevo>03/01/2019</datadevo> <mtdemiss>15</mtdemiss> <dtdemiss>03/01/2019</dtdemiss> <nrdconta>9122354</nrdconta>  </Dados><params><nmprogra>MATRIC</nmprogra><nmeacao>DEVOLUCAO_COTAS_MATRIC</nmeacao><cdcooper>1</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>5</idorigem><cdoperad>1</cdoperad></params><Permissao><nmdatela>MATRIC</nmdatela><cddopcao>C</cddopcao><idsistem>1</idsistem><inproces>1</inproces><cdagecxa>0</cdagecxa><nrdcaixa>0</nrdcaixa><cdopecxa>1</cdopecxa><idorigem>5</idorigem></Permissao></Root>';
  pr_retxml  := XMLType.createXML(vr_xml_def);
  -- Call the procedure
 	 cecred.cada0003.pc_devol_cotas_desligamentos(pr_nrdconta => vr_nrddconta,
                                               pr_vldcotas  => vr_vldcotas,
                                               pr_formadev  => 1,
                                               pr_qtdparce  => 0,
                                               pr_datadevo  => rw_crapdat.dtmvtolt,
                                               pr_mtdemiss  => 15,
                                               pr_dtdemiss  => '28/08/2018',
                                               pr_xmllog    => '',
                                               pr_cdcritic  => pr_cdcritic,
                                               pr_dscritic  => pr_dscritic,
                                               pr_retxml    => pr_retxml,
                                               pr_nmdcampo  => pr_nmdcampo,
                                               pr_des_erro  => pr_des_erro);
                                              
                                               
  IF NVL(PR_CDCRITIC, 0) > 0 THEN
    DBMS_OUTPUT.put_line('CDCRITIC = ' || PR_CDCRITIC);
  END IF;
  IF pr_dscritic IS NOT NULL THEN
    DBMS_OUTPUT.put_line('DSCRITIC = ' || pr_dscritic);
  END IF;
  IF pr_nmdcampo IS NOT NULL THEN
    DBMS_OUTPUT.put_line('NMDCAMPO = ' || pr_nmdcampo);
  END IF;
  IF pr_des_erro IS NOT NULL THEN
    DBMS_OUTPUT.put_line('DESERRO = ' || pr_des_erro);
  END IF;

end;
