declare
  -- Non-scalar parameters require additional processing 
  pr_retxml xmltype;
    vr_xml_def    VARCHAR2(4000);                                    --> XML Default de Entrada
  
  
  
begin
	  vr_xml_def := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root>  <Dados>    <cdcooper1</cdcooper> <vldcotas>0</vldcotas> <formadev>1</formadev> <qtdparce>0</qtdparce> <datadevo>03/01/2019</datadevo> <mtdemiss>15</mtdemiss> <dtdemiss>03/01/2019</dtdemiss> <nrdconta>9122354</nrdconta>  </Dados><params><nmprogra>MATRIC</nmprogra><nmeacao>DEVOLUCAO_COTAS_MATRIC</nmeacao><cdcooper>1</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>5</idorigem><cdoperad>1</cdoperad></params><Permissao><nmdatela>MATRIC</nmdatela><nmrotina>' '</nmrotina><cddopcao>C</cddopcao><idsistem>1</idsistem><inproces>1</inproces><cdagecxa>0</cdagecxa><nrdcaixa>0</nrdcaixa><cdopecxa>1</cdopecxa><idorigem>5</idorigem></Permissao></Root>';
      pr_retxml := XMLType.createXML(vr_xml_def);  
  -- Call the procedure
  cecred.cada0003.pc_devol_cotas_desligamentos(pr_cdcooper => :pr_cdcooper,
                                              pr_nrdconta => :pr_nrdconta,
                                              pr_vldcotas => :pr_vldcotas,
                                              pr_formadev => :pr_formadev,
                                              pr_qtdparce => :pr_qtdparce,
                                              pr_datadevo => :pr_datadevo,
                                              pr_mtdemiss => :pr_mtdemiss,
                                              pr_dtdemiss => :pr_dtdemiss,                                             
                                              pr_xmllog =>   :pr_xmllog,
                                              pr_cdcritic => :pr_cdcritic,
                                              pr_dscritic => :pr_dscritic,
                                              pr_retxml => pr_retxml,
                                              pr_nmdcampo => :pr_nmdcampo,
                                              pr_des_erro => :pr_des_erro);
end;