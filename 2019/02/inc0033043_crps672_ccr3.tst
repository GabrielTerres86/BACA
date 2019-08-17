PL/SQL Developer Test script 3.0
32
-- Created on 14/02/2019 by F0030367 
declare 
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS672';       --> Código do programa
      vr_nmdcampo   VARCHAR2(1000);                                    --> Variável de Retorno Nome do Campo    
      vr_des_erro   VARCHAR2(2000);                                    --> Variável de Retorno Descr Erro                     
      vr_xml        xmltype;                                           --> Variável de Retorno do XML
      vr_xml_def    VARCHAR2(4000);                                    --> XML Default de Entrada

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_tp_excep   VARCHAR2(1000);
begin
 
      vr_xml_def := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root> <Dados> </Dados><params><nmprogra>CCR3</nmprogra>' ||
                    '<nmeacao>CRPS672</nmeacao><cdcooper>3</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>1</idorigem>' ||
                    '<cdoperad>1</cdoperad></params></Root>';                   
      vr_xml := XMLType.createXML(vr_xml_def);                  

      CCRD0003.pc_crps672(pr_xmllog   => ''
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic
                         ,pr_retxml   => vr_xml
                         ,pr_nmdcampo => vr_nmdcampo
                         ,pr_des_erro => vr_des_erro);
             
 -- IF TRIM(vr_dscritic) IS NOT NULL THEN      
    dbms_output.put_line('Erro :'||vr_dscritic);
 -- end if;             
end;
0
0
