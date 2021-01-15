declare

      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS671';       --> Código do programa
      vr_nmdcampo   VARCHAR2(1000);                                    --> Variável de Retorno Nome do Campo
      vr_des_erro   VARCHAR2(2000);                                    --> Variável de Retorno Descr Erro
      vr_xml        xmltype;                                           --> Variável de Retorno do XML
      vr_xml_def    VARCHAR2(4000);                                    --> XML Default de Entr
      
 	-- Tratamento de erros

      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
	
     
begin
  vr_xml_def := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root> <Dados> </Dados><params><nmprogra>ARQBCB</nmprogra>' ||
                    '<nmeacao>CRPS671</nmeacao><cdcooper>3</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>1</idorigem>' ||
                    '<cdoperad>1</cdoperad></params></Root>';
   vr_xml := XMLType.createXML(vr_xml_def);
                    
  -- Call the procedure
  gerarArquivoCrps671(pr_xmllog   => ''
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic
                         ,pr_retxml   => vr_xml
                         ,pr_nmdcampo => vr_nmdcampo
                         ,pr_des_erro => vr_des_erro);
end;
