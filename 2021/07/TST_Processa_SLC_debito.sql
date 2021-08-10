DECLARE 
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(32000);
    vr_dtprocessoexec crapdat.dtmvtolt%TYPE := trunc(SYSDATE);

PROCEDURE processa_arquivo_24_xml(pr_xml_of     IN xmltype
                                    ,pr_xml_dom   IN XMLDOM.DOMDocument
                                    ,pr_dscritic OUT VARCHAR2) IS
  /*
  * Nova procedure para leitura do arquivo SLC em formato XML em vez de temptable. 
  * Refatoração da procedure processa_arquivo_24
  *
  * Guilherme Cervo (Supero) - 03/04/2020
  */       
                                                          
    BEGIN
      DECLARE

        VBLOB BLOB;
        VCLOB CLOB;
        VXML SYS.XMLTYPE;
        vr_dsdiretorio VARCHAR2(500);
        vr_lista_nodo  xmldom.DOMNodeList;
        vr_lista_nodo2 xmldom.DOMNodeList;
        vr_lista_nodo3 xmldom.DOMNodeList;
        vr_lista_nodo4 xmldom.DOMNodeList;
        vr_lista_nodo5 xmldom.DOMNodeList;
        vr_lista_nodo6 xmldom.DOMNodeList;
        vr_lista_nodo7 xmldom.DOMNodeList;
        vr_nodo xmldom.DOMNode;
        vr_nodo_child xmldom.DOMNode;
        vr_nodo_value VARCHAR2(1000);
        vr_dscritic   VARCHAR2(32000);
        vr_idcampo    VARCHAR2(32000);
        vr_elemento   xmldom.DOMElement;
        vr_executado  VARCHAR2(01);
        vr_exec_erro  EXCEPTION;
        vr_cont_tags  NUMBER       := 0; 
        vr_vltotarq   NUMBER(19,2) := 0;
        vr_qtdtotarq  NUMBER       := 0;
       
                 
        -- Variaveis DOM
        vr_xmldoc    XMLDOM.DOMDocument;
        vr_node_list DBMS_XMLDOM.DOMNodelist;
        
        -- VARIAVEIS TAB TBDOMIC_LIQTRANS_ARQUIVO
        vr_nomarq           VARCHAR2(1000);
        vr_numctrlemis      VARCHAR2(80);
        vr_numctrldestor    VARCHAR2(20);
        vr_ispbemissor      VARCHAR2(08);
        vr_ispbdestinatario VARCHAR2(08);
        vr_dthrarq          VARCHAR2(19);
        vr_dtref            VARCHAR2(10);
        
        -- VARIAVEIS TAB TBDOMIC_LIQTRANS_LANCTO
        vr_IdentdPartPrincipal VARCHAR2(8);
        vr_IdentdPartAdmtd     VARCHAR2(8);
        vr_CNPJBaseCreddr      VARCHAR2(8);
        vr_CNPJCreddr          NUMBER(14);
        vr_ISPBIFDevdr         VARCHAR2(8);
        vr_ISPBIFCredr         VARCHAR2(8);
        vr_AgCreddr            NUMBER(4);
        vr_CtCreddr            NUMBER(13);
        vr_NomCreddr           VARCHAR2(80);
        
        -- VARIAVEIS TAB TBDOMIC_LIQTRANS_CENTRALIZA
        vr_TpPessoaCentrlz VARCHAR2(01);
        vr_CNPJ_CPFCentrlz NUMBER(14);
        vr_CodCentrlz      VARCHAR2(25);
        vr_TpCt            VARCHAR2(02);
        vr_CtPgtoCentrlz   NUMBER(20);
        vr_AgCentrlz       NUMBER(13);
        vr_CtCentrlz       NUMBER(13);
        vr_idcentraliza    NUMBER;
        
        -- VARIAVEIS TAB TBDOMIC_LIQTRANS_PDV
        vr_nuliquid               VARCHAR2(21);
        vr_ispbifliquidpontovenda VARCHAR2(08);
        vr_codpontovenda          VARCHAR2(25);
        vr_nomepontovenda         VARCHAR2(80);
        vr_tppessoapontovenda     VARCHAR2(01);
        vr_cnpj_cpfpontovenda     NUMBER(14);
        vr_codinstitdrarrajpgto   VARCHAR2(3);
        vr_tpprodliquiddeb        NUMBER(02) ;
        vr_indrformatransf        VARCHAR2(01);
        vr_codmoeda               NUMBER(03);
        vr_dtpgto                 VARCHAR2(10);
        vr_vlrpgto                NUMBER(19,2);
        vr_dthrmanut              VARCHAR2(19);
        vr_codocorc               VARCHAR2(2) ;
        vr_numctrlifacto          VARCHAR2(20);
        vr_numctrlcipaceito       VARCHAR2(20);
        vr_tppontovenda           VARCHAR2(2);
        vr_tpvlpagamento          VARCHAR2(2);
        
        -- VARIAVEIS
        vr_xml_in  XMLTYpe;
        vr_tag_ant VARCHAR2(100) := NULL; -- Guardar a tag principal anterior ao loop
        
        -- VARIAVEIS CRITICA
        vr_exc_saida EXCEPTION;
        vr_iderro    NUMBER := NULL;
        vr_idarquivo NUMBER; 
        vr_idlancto  NUMBER; 
        vr_idpdv     NUMBER; 
        
        -- FUNCOES
        
        FUNCTION fn_valida_campos_arqliq RETURN INTEGER IS
            vr_fncritic crapcri.dscritic%TYPE;
            vr_fniderro NUMBER;
          BEGIN
              IF vr_NumCtrlEmis IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'NumCtrlEmis';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;

              IF vr_NumCtrlDestOr IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'NumCtrlDestOr';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;              

              IF vr_ISPBEmissor IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'ISPBEmissor';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;              

              IF vr_ISPBDestinatario IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'ISPBDestinatario';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;              
              
              IF vr_DtHrArq IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'DtHrArq';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;

              IF vr_DtRef IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'DtRef';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;
              
              RETURN vr_fniderro;
          END;

        FUNCTION fn_valida_campos_lancto RETURN INTEGER IS
             vr_fncritic crapcri.dscritic%TYPE;
             vr_fniderro NUMBER;
          BEGIN
              IF vr_IdentdPartPrincipal IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'IdentdPartPrincipal';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;
              
              IF vr_IdentdPartAdmtd IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'IdentdPartAdmtd';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;            
              
              IF vr_CNPJBaseCreddr IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'CNPJBaseCreddr';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF; 

              IF vr_CNPJCreddr IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'CNPJCreddr';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;
              
              IF vr_ISPBIFDevdr IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'ISPBIFDevdr';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;
              
              IF vr_ISPBIFCredr IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'ISPBIFCredr';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;
              
              IF vr_AgCreddr IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'AgCreddr';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;
              
              IF vr_CtCreddr IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'CtCreddr';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;
            
              IF vr_NomCreddr IS NULL THEN
                vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                vr_idcampo  := 'NomCreddr';
                ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                pr_idcampo  => vr_idcampo,
                                pr_dscritic => vr_fncritic);
                vr_fniderro := 1;
              END IF;  
              
              RETURN vr_fniderro;                                     
          END; 
      
        FUNCTION fn_valida_campos_trn RETURN INTEGER IS
          vr_fncritic crapcri.dscritic%TYPE;
          vr_fniderro NUMBER;        
          BEGIN
            
              IF vr_TpPessoaCentrlz IS NULL THEN
                 vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                 vr_idcampo  := 'TpPessoaCentrlz';
                 ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                 pr_idcampo  => vr_idcampo,
                                 pr_dscritic => vr_fncritic);
                 vr_fniderro := 1;
              END IF;
            
              IF vr_CNPJ_CPFCentrlz IS NULL THEN
                 vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                 vr_idcampo  := 'CNPJ_CPFCentrlz';
                 ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                 pr_idcampo  => vr_idcampo,
                                 pr_dscritic => vr_fncritic);
                 vr_fniderro := 1;
              END IF;           
            
              IF vr_CodCentrlz IS NULL THEN
                 vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                 vr_idcampo  := 'CodCentrlz';
                 ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                 pr_idcampo  => vr_idcampo,
                                 pr_dscritic => vr_fncritic);
                 vr_fniderro := 1;
              END IF;
            
              IF vr_TpCt IS NULL THEN
                 vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                 vr_idcampo  := 'TpCt';
                 ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                 pr_idcampo  => vr_idcampo,
                                 pr_dscritic => vr_fncritic);
                 vr_fniderro := 1;
              END IF;
            
              IF vr_AgCentrlz IS NULL THEN
                 vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                 vr_idcampo  := 'AgCentrlz';
                 ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                 pr_idcampo  => vr_idcampo,
                                 pr_dscritic => vr_fncritic);
                 vr_fniderro := 1;
              END IF;
            
              IF vr_CtCentrlz IS NULL THEN
                 vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
                 vr_idcampo  := 'CtCentrlz';
                 ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                                 pr_idcampo  => vr_idcampo,
                                 pr_dscritic => vr_fncritic);
                 vr_fniderro := 1;
              END IF;  
              
              RETURN vr_fniderro;        
          END; 
          
        FUNCTION fn_valida_campos_pdv RETURN INTEGER IS
          vr_fncritic crapcri.dscritic%TYPE;
          vr_fniderro NUMBER;
          BEGIN
            IF vr_NULiquid IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'NULiquid';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;          
          
            IF vr_ISPBIFLiquidPontoVenda IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'ISPBIFLiquidPontoVenda';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
            
            IF vr_CodPontoVenda IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'CodPontoVenda';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_NomePontoVenda IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'NomePontoVenda';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_TpPessoaPontoVenda IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'TpPessoaPontoVenda';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_CNPJ_CPFPontoVenda IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'CNPJ_CPFPontoVenda';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_CodInstitdrArrajPgto IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'CodInstitdrArrajPgto';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_TpProdLiquidDeb IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'TpProdLiquidDeb';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_IndrFormaTransf IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'IndrFormaTransf';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_CodMoeda IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'CodMoeda';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_DtPgto IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'DtPgto';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_VlrPgto IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'VlrPgto';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_DtHrManut IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'DtHrManut';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_tppontovenda IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'TpPontoVenda';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;
          
            IF vr_tpvlpagamento IS NULL THEN
               vr_fncritic := vr_nomarq || ' - Campo não encontrado no XML';
               vr_idcampo  := 'TpVlrPgto';
               ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                               pr_idcampo  => vr_idcampo,
                               pr_dscritic => vr_fncritic);
               vr_fniderro := 1;
            END IF;          
            
            RETURN vr_fniderro;           
          END;                  
        
    BEGIN
        vr_xml_in := pr_xml_of;
        
        --Busca os campos do detalhe da consulta    
        ccrd0006.pc_busca_conteudo_campo(vr_xml_in, '//ASLCDOC/BCARQ/NomArq', 'S',vr_nomarq, vr_dscritic);

        IF vr_nomarq IS NULL THEN
            vr_dscritic := vr_nomarq || ' - Campo não encontrado no XML';
            vr_idcampo  := 'NomArq';
            ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                            pr_idcampo  => vr_idcampo,
                            pr_dscritic => vr_dscritic);
            vr_iderro := 1;
        END IF;
                
        -- valida se o arquivo com esse nome já foi processado.
        vr_executado := ccrd0006.valida_arquivo_processado (pr_nomarq => vr_nomarq);
        IF vr_executado = 'S' THEN
           RAISE vr_exc_saida;
        END IF;

        /*########################################################################
        VALIDAR EXISTENCIA DAS TAGS PRINCIPAIS DO ARQUIVO
        ######################################################################## */
        
        --Verificar se existe tag "BCARQ"
        vr_node_list:= xmldom.getElementsByTagName(pr_xml_dom,'BCARQ');  
        
        --Se nao existir a tag "BCARQ"
        IF dbms_xmldom.getlength(vr_node_list) = 0 THEN
           vr_dscritic:= 'Arquivo não contêm a tag BCARQ.';
           vr_idcampo  := '<BCARQ';
           ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                           pr_idcampo  => vr_idcampo,
                           pr_dscritic => vr_dscritic);            
           RAISE vr_exc_saida;
        END IF;  

        --Verificar se existe tag "SISARQ"
        vr_node_list:= xmldom.getElementsByTagName(pr_xml_dom,'SISARQ');

        --Se nao existir a tag "SISARQ"
        IF dbms_xmldom.getlength(vr_node_list) = 0 THEN
           vr_dscritic:= 'Arquivo não contêm a tag SISARQ.';
           vr_idcampo  := '<SISARQ';
           ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                           pr_idcampo  => vr_idcampo,
                           pr_dscritic => vr_dscritic);            
           RAISE vr_exc_saida;
        END IF;
        
        --Verificar se existe tag "ASLC024"
        vr_node_list:= xmldom.getElementsByTagName(pr_xml_dom,'ASLC024');
        
        --Se nao existir a tag "ASLC024"
        IF dbms_xmldom.getlength(vr_node_list) = 0 THEN
           vr_dscritic:= 'Arquivo não contêm a tag ASLC024.';
           vr_idcampo  := '<ASLC024';
           ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                           pr_idcampo  => vr_idcampo,
                           pr_dscritic => vr_dscritic);            
           RAISE vr_exc_saida;
        END IF;     

        --Verificar se existe tag "Grupo_ASLC024_LiquidTranscDeb"
        vr_node_list:= xmldom.getElementsByTagName(pr_xml_dom,'Grupo_ASLC024_LiquidTranscDeb');
        
        --Se nao existir a tag "Grupo_ASLC024_LiquidTranscDeb"
        IF dbms_xmldom.getlength(vr_node_list) = 0 THEN
           vr_dscritic:= 'Arquivo não contêm a tag Grupo_ASLC024_LiquidTranscDeb.'; 
           vr_idcampo  := '<Grupo_ASLC024_LiquidTranscDeb';
           ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                           pr_idcampo  => vr_idcampo,
                           pr_dscritic => vr_dscritic);               
           RAISE vr_exc_saida;
        END IF;       

        --Verificar se existe tag "Grupo_ASLC024_Centrlz"
        vr_node_list:= xmldom.getElementsByTagName(pr_xml_dom,'Grupo_ASLC024_Centrlz');
        
        --Se nao existir a tag "Grupo_ASLC024_Centrlz"
        IF dbms_xmldom.getlength(vr_node_list) = 0 THEN
           vr_dscritic:= 'Arquivo não contêm a tag Grupo_ASLC024_Centrlz.';
           vr_idcampo  := '<Grupo_ASLC024_Centrlz';
           ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                           pr_idcampo  => vr_idcampo,
                           pr_dscritic => vr_dscritic);            
           RAISE vr_exc_saida;
        END IF;
        
        --Verificar se existe tag "Grupo_ASLC024_PontoVenda"
        vr_node_list:= xmldom.getElementsByTagName(pr_xml_dom,'Grupo_ASLC024_PontoVenda');
        
        --Se nao existir a tag "Grupo_ASLC024_PontoVenda"
        IF dbms_xmldom.getlength(vr_node_list) = 0 THEN
           vr_dscritic:= 'Arquivo não contêm a tag Grupo_ASLC024_PontoVenda.';
           vr_idcampo  := '<Grupo_ASLC024_PontoVenda';
           ccrd0006.pc_gera_critica(pr_nomearq  => vr_nomarq,
                           pr_idcampo  => vr_idcampo,
                           pr_dscritic => vr_dscritic);           
           RAISE vr_exc_saida;
        END IF;             

        --Busca o nodo com a tag "ASLCDOC"
        vr_node_list:= xmldom.getElementsByTagName(pr_xml_dom,'ASLCDOC');    

        FOR vr_linha IN 0..(xmldom.getLength(vr_node_list)-1) LOOP
            --Buscar Nodo Corrente
            vr_nodo:= xmldom.item(vr_node_list,vr_linha);
            vr_elemento := xmldom.makeElement(vr_nodo);
            vr_lista_nodo:= xmldom.GETCHILDRENBYTAGNAME(vr_elemento,'*');
            
            FOR vr_linha2 IN 0..(xmldom.getLength(vr_lista_nodo)-1) LOOP
              
                --Buscar Nodo Corrente
                vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha2);
                vr_elemento := xmldom.makeElement(vr_nodo);
                vr_lista_nodo2:= xmldom.GETCHILDRENBYTAGNAME(vr_elemento,'*');
                
                
                vr_tag_ant := xmldom.getNodeName(vr_nodo);
                
                FOR vr_linha3 IN 0..(xmldom.getLength(vr_lista_nodo2)-1) LOOP
                    --Buscar Nodo Corrente
                                        
                    vr_nodo:= xmldom.item(vr_lista_nodo2,vr_linha3);
                    vr_elemento := xmldom.makeElement(vr_nodo);                                                         
                    vr_lista_nodo3:= xmldom.GETCHILDRENBYTAGNAME(vr_elemento,'*');
                    vr_nodo_child:= xmldom.getFirstChild(vr_nodo);
                    vr_nodo_value := xmldom.getNodeValue(vr_nodo_child);
                             
                    IF xmldom.getNodeName(vr_nodo) = 'NumCtrlEmis' THEN
                       vr_NumCtrlEmis := vr_nodo_value;
                    ELSIF xmldom.getNodeName(vr_nodo) = 'NumCtrlDestOr' THEN
                       vr_NumCtrlDestOr := vr_nodo_value;                      
                    ELSIF xmldom.getNodeName(vr_nodo) = 'ISPBEmissor' THEN
                       vr_ISPBEmissor := vr_nodo_value;                      
                    ELSIF xmldom.getNodeName(vr_nodo) = 'ISPBDestinatario' THEN
                       vr_ISPBDestinatario := vr_nodo_value;                      
                    ELSIF xmldom.getNodeName(vr_nodo) = 'DtHrArq' THEN
                       vr_DtHrArq := vr_nodo_value;                      
                    ELSIF xmldom.getNodeName(vr_nodo) = 'DtRef' THEN
                       vr_DtRef := vr_nodo_value;                      
                    END IF;
                    
                    -- Validar se o loop chegou ao fim para fazer inserção
                    IF vr_linha3 = (xmldom.getLength(vr_lista_nodo2)-1) AND vr_tag_ant = 'BCARQ' THEN

                       vr_tag_ant  := NULL;
                       
                       -- Validamos os registros
                       vr_iderro := fn_valida_campos_arqliq;                       
                       
                       -- Inserimos os registros                       
                       BEGIN                         
                           -- Insere na tab TBDOMIC_LIQTRANS_ARQUIVO
                           ccrd0006.insere_arq_liq_transacao(pr_nomarq           => vr_nomarq,
                                                    pr_NumCtrlEmis      => vr_NumCtrlEmis,
                                                    pr_NumCtrlDestOr    => vr_NumCtrlDestOr,
                                                    pr_ISPBEmissor      => vr_ISPBEmissor,
                                                    pr_ISPBDestinatario => vr_ISPBDestinatario,
                                                    pr_DtHrArq          => vr_DtHrArq,
                                                    pr_DtRef            => vr_DtRef,
                                                    pr_idarquivo        => vr_idarquivo,
                                                    pr_iderro           => vr_iderro,
                                                    pr_dscritic         => vr_dscritic);
                                                                          
                           IF vr_dscritic IS NOT NULL THEN
                              RAISE vr_exc_saida;
                           END IF; 
                           -- Reiniciamos os campos
                           vr_NumCtrlEmis      := NULL;
                           vr_NumCtrlDestOr    := NULL;
                           vr_ISPBEmissor      := NULL;
                           vr_ISPBDestinatario := NULL;
                           vr_DtHrArq          := NULL;
                           vr_DtRef            := NULL;
                           vr_iderro           := NULL;                           
                           
                       EXCEPTION
                         WHEN OTHERS THEN
                            vr_dscritic := 'Erro processo TAB24. Arquivo Liquidação Transações de Crédito- Insere Arquivo' || ': ' || SQLERRM;
                            RAISE vr_exc_saida;                         
                       END;
                    END IF;                                                                                             

                    FOR vr_linha4 IN 0..(xmldom.getLength(vr_lista_nodo3)-1) LOOP     
                        --Buscar Nodo Corrente
                        vr_nodo:= xmldom.item(vr_lista_nodo3,vr_linha4);
                        vr_elemento := xmldom.makeElement(vr_nodo);
                        vr_lista_nodo4:= xmldom.GETCHILDRENBYTAGNAME(vr_elemento,'*');
                        vr_nodo_child:= xmldom.getFirstChild(vr_nodo);
                        vr_nodo_value:= xmldom.getNodeValue(vr_nodo_child);
                                                
                        vr_tag_ant := xmldom.getNodeName(vr_nodo);
                        
                        FOR vr_linha5 IN 0..(xmldom.getLength(vr_lista_nodo4)-1) LOOP
                          
                            --Buscar Nodo Corrente
                            vr_nodo:= xmldom.item(vr_lista_nodo4,vr_linha5);
                            vr_elemento := xmldom.makeElement(vr_nodo);
                            vr_lista_nodo5:= xmldom.GETCHILDRENBYTAGNAME(vr_elemento,'*');
                            vr_nodo_child:= xmldom.getFirstChild(vr_nodo);
                            vr_nodo_value := xmldom.getNodeValue(vr_nodo_child); 
                                                        
                            -- Verificamos em qual tag esta o cursor                                              
                            IF xmldom.getNodeName(vr_nodo) = 'IdentdPartPrincipal' THEN
                               vr_IdentdPartPrincipal := vr_nodo_value;
                               vr_cont_tags := vr_cont_tags + 1;
                            ELSIF xmldom.getNodeName(vr_nodo) = 'IdentdPartAdmtd' THEN
                               vr_IdentdPartAdmtd := vr_nodo_value;     
                               vr_cont_tags := vr_cont_tags + 1;                                                
                            ELSIF xmldom.getNodeName(vr_nodo) = 'CNPJBaseCreddr' THEN
                               vr_CNPJBaseCreddr := vr_nodo_value;                      
                               vr_cont_tags := vr_cont_tags + 1;                               
                            ELSIF xmldom.getNodeName(vr_nodo) = 'CNPJCreddr' THEN
                               vr_CNPJCreddr := vr_nodo_value;  
                               vr_cont_tags := vr_cont_tags + 1;                                                   
                            ELSIF xmldom.getNodeName(vr_nodo) = 'ISPBIFDevdr' THEN
                               vr_ISPBIFDevdr := vr_nodo_value; 
                               vr_cont_tags := vr_cont_tags + 1;                                                    
                            ELSIF xmldom.getNodeName(vr_nodo) = 'ISPBIFCredr' THEN
                               vr_ISPBIFCredr := vr_nodo_value; 
                               vr_cont_tags := vr_cont_tags + 1;                                                    
                            ELSIF xmldom.getNodeName(vr_nodo) = 'AgCreddr' THEN
                               vr_AgCreddr := vr_nodo_value;    
                               vr_cont_tags := vr_cont_tags + 1;                                                  
                            ELSIF xmldom.getNodeName(vr_nodo) = 'CtCreddr' THEN
                               vr_CtCreddr := vr_nodo_value;    
                               vr_cont_tags := vr_cont_tags + 1;                                                 
                            ELSIF xmldom.getNodeName(vr_nodo) = 'NomCreddr' THEN
                               vr_NomCreddr := vr_nodo_value;   
                               vr_cont_tags := vr_cont_tags + 1;                                                         
                            END IF;        
                                                  
                            IF vr_cont_tags =  9 THEN
                               vr_cont_tags := 0;
                               
                               -- Verifica se existe dados na consulta
                               IF NVL(vr_IdentdPartPrincipal, 0) = 0 THEN
                                  EXIT;
                               END IF;                  
                                            
                               -- Validamos os registros
                               vr_iderro := fn_valida_campos_lancto;   
                                                         
                               -- Inserimos os registros
                               BEGIN
                                  -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA
                                  ccrd0006.insere_liquidacao_transacao(pr_IdentdPartPrincipal => vr_IdentdPartPrincipal,
                                                              pr_IdentdPartAdmtd     => vr_IdentdPartAdmtd,
                                                              pr_CNPJBaseCreddr      => vr_CNPJBaseCreddr,
                                                              pr_CNPJCreddr          => vr_CNPJCreddr,
                                                              pr_ISPBIFDevdr         => vr_ISPBIFDevdr,
                                                              pr_ISPBIFCredr         => vr_ISPBIFCredr,
                                                              pr_AgCreddr            => vr_AgCreddr,
                                                              pr_CtCreddr            => vr_CtCreddr,
                                                              pr_NomCreddr           => vr_NomCreddr,
                                                              pr_idarquivo           => vr_idarquivo,
                                                              pr_idlancto            => vr_idlancto,
                                                              pr_iderro              => vr_iderro,
                                                              pr_dscritic            => vr_dscritic);
                                                              
                                  IF vr_dscritic IS NOT NULL THEN
                                    RAISE vr_exc_saida;
                                  END IF;     
                                  
                                  vr_IdentdPartPrincipal := NULL;
                                  vr_IdentdPartAdmtd     := NULL;
                                  vr_CNPJBaseCreddr      := NULL;
                                  vr_CNPJCreddr          := NULL;
                                  vr_ISPBIFDevdr         := NULL;
                                  vr_ISPBIFCredr         := NULL;
                                  vr_AgCreddr            := NULL;
                                  vr_CtCreddr            := NULL;
                                  vr_NomCreddr           := NULL;
                                  vr_iderro              := NULL;                                                 
                                                                                                                                 
                               EXCEPTION
                                  WHEN OTHERS THEN
                                    vr_dscritic := 'Erro processo TAB24. Arquivo Liquidação Transações de Crédito- Insere Lancamento' || ': ' || SQLERRM;
                                    RAISE vr_exc_saida;                                  
                               END;
                            END IF;         
                                                                                                             
                            FOR vr_linha6 IN 0..(xmldom.getLength(vr_lista_nodo5)-1) LOOP

                                --Buscar Nodo Corrente
                                vr_nodo:= xmldom.item(vr_lista_nodo5,vr_linha6);
                                vr_elemento := xmldom.makeElement(vr_nodo);
                                vr_lista_nodo6:= xmldom.GETCHILDRENBYTAGNAME(vr_elemento,'*');
                                vr_nodo_child:= xmldom.getFirstChild(vr_nodo);
                                vr_nodo_value := xmldom.getNodeValue(vr_nodo_child);

                                -- Verificamos em qual tag esta o cursor                                              
                                IF xmldom.getNodeName(vr_nodo) = 'TpPessoaCentrlz' THEN
                                   vr_TpPessoaCentrlz := vr_nodo_value;
                                   vr_cont_tags := vr_cont_tags + 1;
                                ELSIF xmldom.getNodeName(vr_nodo) = 'CNPJ_CPFCentrlz' THEN
                                   vr_CNPJ_CPFCentrlz := vr_nodo_value;                      
                                   vr_cont_tags := vr_cont_tags + 1;                                   
                                ELSIF xmldom.getNodeName(vr_nodo) = 'CodCentrlz' THEN
                                   vr_CodCentrlz := vr_nodo_value;  
                                   vr_cont_tags := vr_cont_tags + 1;                                                       
                                ELSIF xmldom.getNodeName(vr_nodo) = 'TpCt' THEN
                                   vr_TpCt := vr_nodo_value;        
                                   vr_cont_tags := vr_cont_tags + 1;                                    
                                ELSIF xmldom.getNodeName(vr_nodo) = 'AgCentrlz' THEN
                                   vr_AgCentrlz := vr_nodo_value;   
                                   vr_cont_tags := vr_cont_tags + 1;                                                      
                                ELSIF xmldom.getNodeName(vr_nodo) = 'CtCentrlz' THEN
                                   vr_CtCentrlz := vr_nodo_value;   
                                   vr_cont_tags := vr_cont_tags + 1;                                                              
                                END IF; 
                                
                                IF vr_cont_tags = 6 THEN
                                   vr_cont_tags := 0;
                                   
                                   -- Verifica se existe dados na consulta
                                   IF nvl(vr_CNPJ_CPFCentrlz, 0) = 0 THEN
                                      EXIT;
                                   END IF;                                    
                                   
                                   vr_iderro := fn_valida_campos_trn;                                      
                                                                      
                                   -- Verifica se algum campo tem problema e atualiza a tabela mãe com situacao = 2 (Erro)
                                   IF NVL(vr_iderro, 0) = 1 THEN
                                      ccrd0006.pc_atualiza_transacao_erro(pr_idlancto => vr_idlancto,
                                                                 pr_dscritic => vr_dscritic);
                                      IF vr_dscritic IS NOT NULL THEN
                                         -- @@ Verificar que ação tomar neste caso, em erro não tratado no sistema
                                         NULL;
                                      END IF;
                                   END IF;
                                                                       
                                   BEGIN
                                     -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA INSERE_LIQ_TRN_CENTRAL
                                     ccrd0006.insere_liq_trn_central(pr_TpPessoaCentrlz => vr_TpPessoaCentrlz,
                                                            pr_CNPJ_CPFCentrlz => vr_CNPJ_CPFCentrlz,
                                                            pr_CodCentrlz      => vr_CodCentrlz,
                                                            pr_TpCt            => vr_TpCt,
                                                            pr_CtPgtoCentrlz   => vr_CtPgtoCentrlz,
                                                            pr_AgCentrlz       => vr_AgCentrlz,
                                                            pr_CtCentrlz       => vr_CtCentrlz,
                                                            pr_idlancto        => vr_idlancto,
                                                            pr_idcentraliza    => vr_idcentraliza,
                                                            pr_dscritic        => vr_dscritic);
                                      
                                     IF vr_dscritic IS NOT NULL THEN
                                        RAISE vr_exc_saida;
                                     END IF;  
                                     
                                     vr_TpPessoaCentrlz := NULL;
                                     vr_CNPJ_CPFCentrlz := NULL;
                                     vr_CodCentrlz      := NULL;
                                     vr_TpCt            := NULL;
                                     vr_CtPgtoCentrlz   := NULL;
                                     vr_AgCentrlz       := NULL;
                                     vr_CtCentrlz       := NULL;
                                     vr_iderro          := 0;                      
                                     
                                   EXCEPTION
                                      WHEN OTHERS THEN
                                        vr_dscritic := 'Erro processo TAB24. Arquivo Liquidação Transações de Crédito- Insere Centralizada' || ': ' || SQLERRM;
                                        RAISE vr_exc_saida;                                      
                                   END;
                                END IF; 
                                                      
                                FOR vr_linha7 IN 0..(xmldom.getLength(vr_lista_nodo6)-1) LOOP  
                                  
                                    --Buscar Nodo Corrente
                                    vr_nodo:= xmldom.item(vr_lista_nodo6,vr_linha7);
                                    vr_elemento := xmldom.makeElement(vr_nodo);
                                    vr_lista_nodo7:= xmldom.GETCHILDRENBYTAGNAME(vr_elemento,'*');
                                    vr_nodo_child:= xmldom.getFirstChild(vr_nodo);
                                    vr_nodo_value := xmldom.getNodeValue(vr_nodo_child);
                                                                                              
                                    -- Verificamos em qual tag esta o cursor                                              
                                    IF xmldom.getNodeName(vr_nodo) = 'NULiquid' THEN
                                          vr_NULiquid := vr_nodo_value;   
                                          vr_cont_tags := + vr_cont_tags + 1;
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'ISPBIFLiquidPontoVenda' THEN
                                          vr_ISPBIFLiquidPontoVenda := vr_nodo_value;
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'CodPontoVenda' THEN
                                          vr_CodPontoVenda := vr_nodo_value; 
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'NomePontoVenda' THEN
                                          vr_NomePontoVenda := vr_nodo_value;
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'TpPessoaPontoVenda' THEN
                                          vr_TpPessoaPontoVenda := vr_nodo_value;
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'CNPJ_CPFPontoVenda' THEN
                                          vr_CNPJ_CPFPontoVenda := vr_nodo_value;
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'CodInstitdrArrajPgto' THEN
                                          vr_CodInstitdrArrajPgto := vr_nodo_value;
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'TpProdLiquidDeb' THEN
                                          vr_TpProdLiquidDeb := vr_nodo_value;
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'IndrFormaTransf' THEN
                                          vr_IndrFormaTransf := vr_nodo_value;
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'CodMoeda' THEN
                                          vr_CodMoeda := vr_nodo_value;      
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'DtPgto' THEN
                                          vr_DtPgto := vr_nodo_value;        
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'VlrPgto' THEN
                                          vr_VlrPgto := to_number(vr_nodo_value, '99999999999.99');       
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'DtHrManut' THEN
                                          vr_DtHrManut := vr_nodo_value;     
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'TpPontoVenda' THEN
                                          vr_tppontovenda := vr_nodo_value;  
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    ELSIF xmldom.getNodeName(vr_nodo) = 'TpVlrPgto' THEN
                                          vr_tpvlpagamento := vr_nodo_value;                                 
                                          vr_cont_tags := + vr_cont_tags + 1;                                          
                                    END IF;  
                                    
                                    IF vr_cont_tags = 15 THEN 
                                       vr_cont_tags := 0;
                                       -- Verifica se existe dados na consulta
                                       IF nvl(vr_NULiquid, 0) = 0 THEN
                                          EXIT;
                                       END IF; 
                                      
                                       vr_iderro := fn_valida_campos_pdv; 
                                                                              
                                       -- Verifica se algum campo tem problema e atualiza a tabela mãe com situacao = 2 (Erro)
                                       IF NVL(vr_iderro, 0) = 1 THEN
                                          ccrd0006.pc_atualiza_transacao_erro(pr_idlancto => vr_idlancto,
                                                                      pr_dscritic => vr_dscritic);
                                          IF vr_dscritic IS NOT NULL THEN
                                             -- @@ Verificar que ação tomar neste caso, em erro não tratado no sistema
                                             NULL;
                                          END IF;
                                       END IF;                                
                                       
                                       BEGIN
                                         -- CHAMA A PROCEDURE DE INSERT DOS REGISTROS DA TABELA
                                         ccrd0006.insere_liq_trn_cen_pve(pr_NULiquid               => vr_NULiquid,
                                                                pr_ISPBIFLiquidPontoVenda => vr_ISPBIFLiquidPontoVenda,
                                                                pr_CodPontoVenda          => vr_CodPontoVenda,
                                                                pr_NomePontoVenda         => vr_NomePontoVenda,
                                                                pr_TpPessoaPontoVenda     => vr_TpPessoaPontoVenda,
                                                                pr_CNPJ_CPFPontoVenda     => vr_CNPJ_CPFPontoVenda,
                                                                pr_CodInstitdrArrajPgto   => vr_CodInstitdrArrajPgto,
                                                                pr_TpProdLiquidCred       => vr_TpProdLiquidDeb,
                                                                pr_IndrFormaTransf        => vr_IndrFormaTransf,
                                                                pr_CodMoeda               => vr_CodMoeda,
                                                                pr_DtPgto                 => vr_DtPgto,
                                                                pr_VlrPgto                => vr_VlrPgto,
                                                                pr_DtHrManut              => vr_DtHrManut,
                                                                pr_codocorc               => vr_codocorc,
                                                                pr_numctrlifacto          => vr_numctrlifacto,
                                                                pr_numctrlcipaceito       => vr_numctrlcipaceito,
                                                                pr_tppontovenda           => vr_tppontovenda,
                                                                pr_tpvlpagamento          => vr_tpvlpagamento,
                                                                pr_idcentraliza           => vr_idcentraliza,
                                                                pr_idpdv                  => vr_idpdv,
                                                                pr_dscritic               => vr_dscritic);
                                              
                                         IF vr_dscritic IS NOT NULL THEN
                                            RAISE vr_exc_saida;
                                         END IF;
                                         
                                         vr_qtdtotarq := vr_qtdtotarq + 1;
                                         vr_vltotarq  := vr_vltotarq + vr_VlrPgto;                                         
                                       
                                         
                                         vr_NULiquid               := NULL ;
                                         vr_TpPontoVenda           := NULL;
                                         vr_CodPontoVenda          := NULL;
                                         vr_NomePontoVenda         := NULL;
                                         vr_TpPessoaPontoVenda     := NULL;
                                         vr_CNPJ_CPFPontoVenda     := NULL;
                                         vr_CodInstitdrArrajPgto   := NULL;
                                         vr_TpProdLiquidDeb        := NULL;
                                         vr_IndrFormaTransf        := NULL;
                                         vr_CodMoeda               := NULL;
                                         vr_DtPgto                 := NULL;
                                         vr_VlrPgto                := NULL;
                                         vr_DtHrManut              := NULL;
                                         vr_codocorc               := NULL;
                                         vr_numctrlifacto          := NULL;
                                         vr_numctrlcipaceito       := NULL;
                                         vr_iderro                 := 0;
                                         vr_dscritic               := NULL;
                                         vr_tppontovenda           := NULL;
                                         vr_tpvlpagamento          := NULL; 
                                       EXCEPTION
                                         WHEN OTHERS THEN
                                             vr_dscritic := 'Erro processo TAB24. Arquivo Liquidação Transações de Crédito- Insere PDV: ' || SQLERRM;
                                             RAISE vr_exc_saida;
                                       END; 
                                                                          
                                    END IF;    
                                        
                                END LOOP;
                            END LOOP;                                                                            
                        END LOOP;                                          
                    END LOOP;                                                                 
                END LOOP;
            END LOOP;
        END LOOP;                 
            
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;          
        RETURN;
      WHEN OTHERS THEN
        pr_dscritic := 'ERRO geral ao gerar o arquivo 24 ' || SQLERRM;                 
        RETURN;
    END;
            
  END processa_arquivo_24_xml;

  PROCEDURE pc_leitura_arquivos_xml(pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                    pr_dscritic OUT VARCHAR2) IS
  
    vr_dsdiretorio           VARCHAR2(100);
    vr_dsdiretorio_recebidos VARCHAR2(100);
    vr_listaarq              VARCHAR2(32000); --> Lista de arquivos
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
  
    -- PL/Table que vai armazenar os nomes de arquivos a serem processados
    vr_tab_arqtmp GENE0002.typ_split;
  
    -- PL/Table que vai armazenar os linhas do arquivo XML
    wpr_table_of GENE0002.typ_tab_tabela;
  
    vr_indice INTEGER;
  
    wpr_retxml      XMLTYPE;
    vr_ok_nok       VARCHAR2(10);
    vr_arquivo      VARCHAR2(1000);
    vr_final        VARCHAR2(100);
    vr_tipo_saida   VARCHAR2(100);
    vr_arquivo_erro NUMBER := 0;
    vr_idcampo      VARCHAR2(1000);
    vr_nmarqtemp    VARCHAR2(1000);
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_dirbin VARCHAR2(200);
    
    vr_arqblob BLOB;
    vr_arqclob CLOB;
    vr_arqxml  xmltype;
    vr_xmldoc  DBMS_XMLDOM.DOMDocument;

    FUNCTION blob_to_clob (blob_in IN BLOB) RETURN CLOB AS
      v_clob CLOB;
      v_varchar VARCHAR2(32767);
      v_start PLS_INTEGER := 1;
      v_buffer PLS_INTEGER := 32767;
    BEGIN
      DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);
      FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(blob_in) / v_buffer)
      LOOP
      --
          v_varchar := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(blob_in, v_buffer, v_start));
          DBMS_LOB.WRITEAPPEND(v_clob, LENGTH(v_varchar), v_varchar);
          v_start := v_start + v_buffer;
      --
      END LOOP;
      --
      RETURN v_clob;
      --
    END blob_to_clob;
       
  BEGIN
  
    -- Busca o diretorio onde estao os arquivos Sicoob
    vr_dsdiretorio := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'ROOT_DOMICILIO_SLC');
                                                
      vr_dsdiretorio_recebidos := vr_dsdiretorio || 'recebidos';
      vr_dsdiretorio           := vr_dsdiretorio || 'INC0099250';
   
  
    -- Listar arquivos
    gene0001.pc_lista_arquivos(pr_path     => vr_dsdiretorio,
                               pr_pesq     => '%.XML',
                               pr_listarq  => vr_listaarq,
                               pr_des_erro => vr_dscritic);
    -- Se ocorreu erro, cancela o programa
    IF vr_dscritic IS NOT NULL THEN
			 raise_application_error(-20001,
												'pc_lista_arquivos ' || sqlerrm);
    END IF;
  
    -- Se possuir arquivos para serem processados
    IF vr_listaarq IS NOT NULL THEN
    
      --Carregar a lista de arquivos txt na pl/table
      vr_tab_arqtmp := GENE0002.fn_quebra_string(pr_string => vr_listaarq);
    
      -- Leitura da PL/Table e processamento dos arquivos
      vr_indice := vr_tab_arqtmp.first;
    
      while vr_indice IS NOT NULL loop
        -- Busca o nome do arquivo a processar
        vr_arquivo := substr(vr_tab_arqtmp(vr_indice), 1, 7);
      
        -- Inserindo quebra de linha no arquivo e gerando arquivo temporario
      
        -- Copia o arquivo XML antes de formatar
        vr_nmarqtemp := to_char(sysdate, 'yyyymmddhh24miss');
        
        -- Converte arquivo para blob
        vr_arqblob := gene0002.fn_arq_para_blob(pr_caminho   => vr_dsdiretorio || '/'
                                                , pr_arquivo => vr_tab_arqtmp(vr_indice));
        -- Converte blob para clob
        vr_arqclob := blob_to_clob(vr_arqblob);        
        
        -- Faz o parse para xml
        vr_arqxml  := xmltype.createXML(vr_arqclob);
        
        vr_xmldoc  := DBMS_XMLDOM.newDOMDocument(vr_arqxml);
        vr_final := upper(substr(vr_tab_arqtmp(vr_indice),
                                 LENGTH(vr_tab_arqtmp(vr_indice)) - 6,
                                 3));
      
        vr_arquivo_erro := instr(vr_tab_arqtmp(vr_indice), '_ERR');
        
                 
        processa_arquivo_24_xml(pr_xml_of   => vr_arqxml,
                                pr_xml_dom  => vr_xmldoc,
                                pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          -- Gera log de arquivo com erro
          vr_idcampo := 'Erro Geral';
          ccrd0006.pc_gera_critica(pr_nomearq  => vr_tab_arqtmp(vr_indice),
                          pr_idcampo  => vr_idcampo,
                          pr_dscritic => vr_dscritic);
          ROLLBACK;
          vr_cdcritic := 0;
          RAISE vr_exc_saida;
        ELSE
          COMMIT;
        END IF;
        
        COMMIT;
          
        -- Vai para o proximo registro
        vr_indice := vr_tab_arqtmp.next(vr_indice);
      END LOOP;
		ELSE
			 raise_application_error(-20001,
									'Nenhum arquivo encontrado. ');
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      pr_cdcritic := vr_cdcritic;
    
      -- Log de erro de execucao
      --pc_controla_log_batch(pr_dstiplog => 'E',
      --                      pr_dscritic => pr_dscritic);
    
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
    
  
  END pc_leitura_arquivos_xml;
		    
  PROCEDURE pc_processa_reg_pendentes(pr_dtprocesso IN DATE,
                                      pr_cdcritic   OUT crapcri.cdcritic%TYPE,
                                      pr_dscritic   OUT VARCHAR2) IS
  
    -- Registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    -- Cursor sobre os registros pendentes
    /* Nesse cursor foi colocada restrição de horário apenas para garantir que a mudança da situação do lançamento para 1
       seja feita após o inicio dos ciclos de envio dos arquivos, evitando com isso que sejam rejeitados lançamentos por falta
       de liquidação financeira antes que as grades de envio sejam abertas
    */
    CURSOR cr_lancamento IS
      SELECT arq.idarquivo,
             arq.nmarquivo_origem,
             lct.nrcnpj_credenciador,
             lct.nrcnpjbase_principal,
             arq.tparquivo,
             to_date(arq.dtreferencia, 'YYYY-MM-DD') dtreferencia,
             lct.dhprocessamento,
             lct.idlancto,
             pdv.tpforma_transf,
             decode(arq.tparquivo, 3, 1, pdv.cdinst_arranjo_pagamento) cdinst_arranjo_pagamento,
             sum(pdv.vlpagamento) vlpagamento
        FROM tbdomic_liqtrans_lancto     lct,
             tbdomic_liqtrans_arquivo    arq,
             tbdomic_liqtrans_centraliza ctz,
             tbdomic_liqtrans_pdv        pdv
       WHERE lct.idarquivo = arq.idarquivo
         AND ctz.idlancto = lct.idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
         AND lct.insituacao = 0 -- Pendente
				 AND arq.nmarquivo_origem = 'ASLC024_05463212_20210723_00011'
       GROUP BY arq.idarquivo,
                arq.nmarquivo_origem,
                lct.nrcnpj_credenciador,
                lct.nrcnpjbase_principal,
                arq.tparquivo,
                to_date(arq.dtreferencia, 'YYYY-MM-DD'),
                lct.dhprocessamento,
                lct.idlancto,
                pdv.tpforma_transf,
                decode(arq.tparquivo, 3, 1, pdv.cdinst_arranjo_pagamento)
       ORDER BY arq.tparquivo,
                lct.nrcnpj_credenciador,
                lct.nrcnpjbase_principal,
                to_date(arq.dtreferencia, 'YYYY-MM-DD');
  
    -- Cursor para informações dos lançamentos
    CURSOR cr_tabela(pr_idlancto       tbdomic_liqtrans_lancto.idlancto%TYPE,
                     pr_tpforma_transf tbdomic_liqtrans_pdv.tpforma_transf%TYPE) IS
      SELECT pdv.nrliquidacao,
             ctz.nrcnpjcpf_centraliza,
             ctz.tppessoa_centraliza,
             ctz.cdagencia_centraliza,
             ctz.nrcta_centraliza,
             pdv.vlpagamento,
             to_date(pdv.dtpagamento, 'YYYY-MM-DD') dtpagamento,
             pdv.idpdv,
             pdv.tpforma_transf
        FROM tbdomic_liqtrans_centraliza ctz, tbdomic_liqtrans_pdv pdv
       WHERE ctz.idlancto = pr_idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
         AND nvl(pdv.cdocorrencia, '00') <> '30' -- 30 = Lancto recusado por falta de transferência financeira
         AND pdv.tpforma_transf = pr_tpforma_transf
       ORDER BY ctz.cdagencia_centraliza,
                ctz.nrcta_centraliza,
                to_date(pdv.dtpagamento, 'YYYY-MM-DD');
  
    -- Cursor sobre as agencias
    CURSOR cr_crapcop IS
      SELECT cdcooper, cdagectl, nmrescop, flgativo FROM crapcop;
  
    -- Cursor sobre os associados
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT nrcpfcgc, decode(inpessoa, 3, 2, inpessoa) inpessoa, dtdemiss
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    CURSOR cr_craptco(pr_cdcopant IN crapcop.cdcooper%TYPE,
                      pr_nrctaant IN craptco.nrctaant%TYPE) IS
      SELECT tco.nrdconta, tco.cdcooper
        FROM craptco tco
       WHERE tco.cdcopant = pr_cdcopant
         AND tco.nrctaant = pr_nrctaant;
    rw_craptco cr_craptco%ROWTYPE;
  
    -- PL/Table para armazenar as agencias
    type typ_crapcop IS RECORD(
      cdcooper crapcop.cdcooper%TYPE,
      nmrescop crapcop.nmrescop%TYPE,
      flgativo crapcop.flgativo%TYPE);
    type typ_tab_crapcop IS TABLE OF typ_crapcop INDEX BY PLS_INTEGER;
    vr_crapcop typ_tab_crapcop;
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(32000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_erro      EXCEPTION;
  
    -- Variaveis gerais
    vr_nrseqdiglcm   craplcm.nrseqdig%TYPE;
    vr_nrseqdiglau   craplau.nrseqdig%TYPE;
    vr_dserro        VARCHAR2(100); --> Variavel de erro
    vr_dserro_arq    VARCHAR2(100); --> Variavel de erro do reg arquivo
    vr_cdocorr       VARCHAR2(2) := NULL; --> Código de ocorrencia do pdv
    vr_cdocorr_arq   VARCHAR2(2) := NULL; --> Código de ocorrencia do reg arquivo
    vr_inpessoa      crapass.inpessoa%TYPE; --> Indicador de tipo de pessoa
    vr_cdcooper      crapcop.cdcooper%TYPE; --> Codigo da cooperativa
    vr_qterros       PLS_INTEGER := 0; --> Quantidade de registros com erro
    vr_qtprocessados PLS_INTEGER := 0; --> Quantidade de registros processados
    vr_inlctfut      VARCHAR2(01); --> Indicador de lancamento futuro
  
    vr_coopdest     crapcop.cdcooper%TYPE; --> coop destino (incorporacao/migracao)
    vr_nrdconta     NUMBER(25);
    vr_cdcooper_lcm craplcm.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
    vr_cdcooper_lau craplau.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
    vr_dtprocesso   crapdat.dtmvtolt%TYPE; --> Data da cooperativa
  
  BEGIN
  
    -- Popula a pl/table de agencia
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_crapcop(rw_crapcop.cdagectl).cdcooper := rw_crapcop.cdcooper;
      vr_crapcop(rw_crapcop.cdagectl).nmrescop := rw_crapcop.nmrescop;
      vr_crapcop(rw_crapcop.cdagectl).flgativo := rw_crapcop.flgativo;
    END LOOP;

    -- Efetua loop sobre os registros pendentes
    FOR rw_lancamento IN cr_lancamento LOOP
			
		  dbms_output.put_line('Cr_lancamento: ' || to_char(cr_lancamento%ROWCOUNT));
      vr_cdcooper_lcm := 0;
      vr_cdcooper_lau := 0;
    
      -- Limpa a variavel de erro
      vr_dserro_arq  := NULL;
      vr_cdocorr_arq := NULL;
      -- Criticar tipo de arquivo.
      IF rw_lancamento.tparquivo NOT in (1, 2, 3) THEN
        vr_dserro_arq  := 'Tipo de arquivo (' || rw_lancamento.tparquivo ||
                          ') nao previsto.';
        vr_cdocorr_arq := '99';
      END IF;
			
      
        FOR rw_tabela IN cr_tabela(rw_lancamento.idlancto,
                                   rw_lancamento.tpforma_transf) LOOP
																	 
          -- Limpa a variavel de erro
          vr_dserro  := NULL;
          vr_cdocorr := NULL;
        
          -- Efetua todas as consistencias dentro deste BEGIN
          BEGIN
            -- se existe erro a nível de arquivo/lancamento jogará para todos os
            -- registros PDV este erro
            IF NVL(vr_cdocorr_arq, '00') <> '00' THEN
              vr_dserro  := vr_dserro_arq;
              vr_cdocorr := vr_cdocorr_arq;
              RAISE vr_erro;
            END IF;
          
            -- Atualiza o indicador de inpessoa
            IF rw_tabela.tppessoa_centraliza = 'F' THEN
              vr_inpessoa := 1;
            ELSIF rw_tabela.tppessoa_centraliza = 'J' THEN
              vr_inpessoa := 2;
            ELSE
              vr_dserro  := 'Indicador de pessoa (' ||
                            rw_tabela.tppessoa_centraliza ||
                            ') nao previsto.';
              vr_cdocorr := '99';
              RAISE vr_erro;
            END IF;
          
            -- Verifica se a agencia informada existe
            IF NOT vr_crapcop.exists(rw_tabela.cdagencia_centraliza) THEN
              vr_dserro  := 'Agencia informada (' ||
                            rw_tabela.cdagencia_centraliza ||
                            ') nao cadastrada.';
              vr_cdocorr := '08';
              RAISE vr_erro;
            END IF;
          
            IF rw_tabela.vlpagamento = 0 OR rw_tabela.vlpagamento < 0 THEN
              vr_dserro  := 'Valor do lancamento zerado ou negativo';
              vr_cdocorr := '99';
              RAISE vr_erro;
            END IF;
          
            IF rw_tabela.tpforma_transf = 4 OR
               (rw_tabela.tpforma_transf = 5 AND
               rw_lancamento.nrcnpj_credenciador not in
               (01027058000191, /* Cielo */ 01425787000104 /* RedeCard */)) THEN
              vr_dserro  := 'Indicador de Forma de Transferência 4 (Débito em conta) ou 5 (STR) não tratado nesse processo';
              vr_cdocorr := '32';
              RAISE vr_erro;
            END IF;
          
            IF vr_crapcop(rw_tabela.cdagencia_centraliza).flgativo = 0 THEN
            
              OPEN cr_craptco(pr_cdcopant => vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper,
                              pr_nrctaant => rw_tabela.nrcta_centraliza);
              FETCH cr_craptco
                INTO rw_craptco;
            
              IF cr_craptco%FOUND THEN
                vr_nrdconta := rw_craptco.nrdconta;
                vr_coopdest := rw_craptco.cdcooper;
              ELSE
                vr_nrdconta := 0;
                vr_coopdest := 0;
              END IF;
            
              CLOSE cr_craptco;
            
            ELSE
              vr_nrdconta := rw_tabela.nrcta_centraliza;
              vr_coopdest := vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper;
            END IF;
          
            -- Busca a data da cooperativa
            -- foi incluido aqui pois pode existir contas transferidas
            OPEN btch0001.cr_crapdat(vr_coopdest);
            FETCH btch0001.cr_crapdat
              INTO rw_crapdat;
            CLOSE btch0001.cr_crapdat;
          
            --Alterado para utilizar a data do parâmetro, se for diferente de NULL
            --IF vr_database_name = 'AYLLOSD' THEN
            IF pr_dtprocesso IS NULL THEN
              IF rw_crapdat.inproces > 1 THEN
                -- Está executando cadeia
                vr_dtprocesso := rw_crapdat.dtmvtopr;
              ELSE
                vr_dtprocesso := rw_crapdat.dtmvtolt;
              END IF;
            ELSE
              vr_dtprocesso := nvl(pr_dtprocesso, trunc(sysdate));
            END IF;
						          
            -- Busca os dados do associado
            OPEN cr_crapass(vr_coopdest, vr_nrdconta);
            FETCH cr_crapass
              INTO rw_crapass;
            IF cr_crapass%NOTFOUND THEN
              -- Se nao encontrar, deve-se gerar inconsistencia
              CLOSE cr_crapass;
              vr_dserro  := 'Conta do associado (' ||
                            GENE0002.fn_mask_conta(rw_tabela.nrcta_centraliza) ||
                            ') inexistente para a cooperativa ' || vr_crapcop(rw_tabela.cdagencia_centraliza).nmrescop || '.';
              vr_cdocorr := '10';
              RAISE vr_erro;
            END IF;
            CLOSE cr_crapass;
          
            -- Efetua consistencia sobre o associado
            IF rw_crapass.inpessoa <> vr_inpessoa THEN
              vr_dserro := 'Associado eh uma pessoa ';
              IF rw_crapass.inpessoa = 1 THEN
                vr_dserro := vr_dserro || 'fisica, porem foi enviado um ';
              ELSE
                vr_dserro := vr_dserro || 'juridica, porem foi enviado um ';
              END IF;
              IF vr_inpessoa = 1 THEN
                vr_dserro := vr_dserro || 'CPF.';
              ELSE
                vr_dserro := vr_dserro || 'CNPJ.';
              END IF;
              vr_cdocorr := '11';
              RAISE vr_erro;
            ELSIF rw_crapass.nrcpfcgc <> rw_tabela.nrcnpjcpf_centraliza AND
                  rw_crapass.inpessoa = 1 THEN
              vr_dserro  := 'CPF informado (' ||
                            GENE0002.fn_mask_cpf_cnpj(rw_tabela.nrcnpjcpf_centraliza,
                                                      vr_inpessoa) ||
                            ') difere do CPF do associado (' ||
                            GENE0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,
                                                      rw_crapass.inpessoa) || ').';
              vr_cdocorr := '11';
              RAISE vr_erro;
            ELSIF substr(lpad(rw_crapass.nrcpfcgc, 14, 0), 1, 8) <>
                  substr(lpad(rw_tabela.nrcnpjcpf_centraliza, 14, 0), 1, 8) AND
                  rw_crapass.inpessoa = 2 then
              vr_dserro  := 'CNPJ informado (' ||
                            substr(lpad(rw_tabela.nrcnpjcpf_centraliza,
                                        14,
                                        0),
                                   1,
                                   8) || ') difere do CNPJ do associado (' ||
                            substr(lpad(rw_crapass.nrcpfcgc, 14, 0), 1, 8) || ').';
              vr_cdocorr := '11';
              RAISE vr_erro;
            END IF;
          
            -- Efetua validacao para conta demitida
            IF rw_crapass.dtdemiss IS NOT NULL THEN
              vr_dserro  := 'Conta demitidade na cooperativa.';
              vr_cdocorr := 11; -- verificar qual o codigo do erro
              RAISE vr_erro;
            END IF;
            
            vr_dscritic := NULL;
          EXCEPTION
            WHEN vr_erro THEN
              NULL;
          END;
        
          IF nvl(vr_cdocorr, '00') <> '00' THEN
            vr_qterros := vr_qterros + 1;
          END IF;
        
          IF nvl(vr_cdocorr, '00') = '00' THEN
            IF rw_tabela.dtpagamento > vr_dtprocesso THEN
              IF rw_lancamento.tparquivo = 1 THEN
                -- crédito
                vr_cdocorr := '01'; -- agendamento de transação efetuado com sucesso --
              END IF;
            END IF;
          END IF;
        
          -- Efetua a atualizacao da tabela de liquidacao pdv
          BEGIN
            UPDATE tbdomic_liqtrans_pdv
               SET cdocorrencia = NVL(vr_cdocorr, '00'), dserro = vr_dserro
             WHERE idpdv = rw_tabela.idpdv;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela tbdomic_liqtrans_pdv: ' ||
                             SQLERRM;
              RAISE vr_exc_saida;
          END;
        
        END LOOP; -- loop cr_tabela 
        
				-- Efetua a atualizacao da situacao na tabela de lancamentos
				BEGIN
					UPDATE tbdomic_liqtrans_lancto
						 SET insituacao      = 1 -- Enviado para CIP/Aguardando Aprovação
								,
								 dhprocessamento = SYSDATE
					 WHERE idlancto = rw_lancamento.idlancto;
				EXCEPTION
					WHEN OTHERS THEN
						vr_dscritic := 'Erro ao atualizar tabela tbdomic_liqtrans_lancto: ' ||
													 SQLERRM;
						RAISE vr_exc_saida;
				END;
      
    END LOOP; 
  
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      pr_cdcritic := vr_cdcritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      raise_application_error(-20001,
                              'pc_processa_reg_pendentes ' || sqlerrm);
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
    
  END; -- pc_processa_reg_pendentes --
	

  PROCEDURE pc_efetiva_reg_pendentes(pr_dtprocesso IN DATE,
                                     pr_cdcritic   OUT crapcri.cdcritic%TYPE,
                                     pr_dscritic   OUT VARCHAR2) IS
  
    /*                                    
                       25/06/2018 - Tratamento de Históricos de Credito/Debito   
                                    José Carvalho  AMcom 
    */
  
    vr_tab_retorno LANC0001.typ_reg_retorno;
    vr_incrineg    INTEGER; --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
  
    -- Registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    -- Cursor sobre os registros pendentes
  
    CURSOR cr_lancamento_reg IS
      SELECT arq.idarquivo,
             arq.nmarquivo_origem,
             lct.nrcnpj_credenciador,
             lct.nrcnpjbase_principal,
             arq.tparquivo,
             to_date(arq.dtreferencia, 'YYYY-MM-DD') dtreferencia,
             lct.dhprocessamento,
             lct.idlancto,
             pdv.dtpagamento,
             pdv.tpforma_transf,
             sum(pdv.vlpagamento) vlpagamento
        FROM tbdomic_liqtrans_lancto     lct,
             tbdomic_liqtrans_arquivo    arq,
             tbdomic_liqtrans_centraliza ctz,
             tbdomic_liqtrans_pdv        pdv
       WHERE lct.idarquivo = arq.idarquivo
         AND ctz.idlancto = lct.idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
				 AND arq.nmarquivo_origem = 'ASLC024_05463212_20210723_00011'
         AND lct.insituacao = 1
         AND (nvl(pdv.cdocorrencia_retorno, '00') = '00' --Só vai atualizar os registros que não tiveram erro no processa_reg_pendentes
             OR (nvl(pdv.cdocorrencia_retorno, '00') = '01' AND
             arq.tparquivo = 1))
         AND pdv.dserro IS NULL --Só vai atualizar os registros que não retornaram com erro da CIP
         AND pdv.dsocorrencia_retorno IS NULL --Só vai atualizar os registros que não retornaram com erro da CIP
				 AND pdv.dtpagamento IS NOT NULL
       GROUP BY arq.idarquivo,
                arq.nmarquivo_origem,
                lct.nrcnpj_credenciador,
                lct.nrcnpjbase_principal,
                arq.tparquivo,
                to_date(arq.dtreferencia, 'YYYY-MM-DD'),
                lct.dhprocessamento,
                lct.idlancto,
                pdv.dtpagamento,
                pdv.tpforma_transf
       ORDER BY arq.tparquivo,
                lct.nrcnpj_credenciador,
                lct.nrcnpjbase_principal,
                to_date(arq.dtreferencia, 'YYYY-MM-DD');
  
    -- Cursor para informações dos lançamentos
    CURSOR cr_tabela_reg(pr_idlancto       tbdomic_liqtrans_lancto.idlancto%TYPE,
                     pr_tpforma_transf tbdomic_liqtrans_pdv.tpforma_transf%TYPE) IS
      SELECT pdv.nrliquidacao,
             ctz.nrcnpjcpf_centraliza,
             ctz.tppessoa_centraliza,
             ctz.cdagencia_centraliza,
             ctz.nrcta_centraliza,
             pdv.vlpagamento,
             to_date(pdv.dtpagamento, 'YYYY-MM-DD') dtpagamento,
             pdv.idpdv,
             pdv.cdocorrencia,
             pdv.cdocorrencia_retorno,
             pdv.dserro,
             pdv.dsocorrencia_retorno
        FROM tbdomic_liqtrans_centraliza ctz,
             tbdomic_liqtrans_pdv        pdv,
             tbdomic_liqtrans_lancto     lct,
             tbdomic_liqtrans_arquivo    arq
       WHERE ctz.idlancto = pr_idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
         AND lct.idarquivo = arq.idarquivo
         AND ctz.idlancto = lct.idlancto
         AND (nvl(pdv.cdocorrencia_retorno, '00') = '00' --Só vai atualizar os registros que não tiveram erro no processa_reg_pendentes
             OR (nvl(pdv.cdocorrencia_retorno, '00') = '01' AND
             arq.tparquivo = 1))
         AND pdv.tpforma_transf = pr_tpforma_transf
         AND pdv.dserro IS NULL --Só vai atualizar os registros que não retornaram com erro da CIP
         AND pdv.dsocorrencia_retorno IS NULL --Só vai atualizar os registros que não retornaram com erro da CIP
       ORDER BY ctz.cdagencia_centraliza,
                ctz.nrcta_centraliza,
                to_date(pdv.dtpagamento, 'YYYY-MM-DD');
  
    -- Cursor sobre as agencias
    CURSOR cr_crapcop IS
      SELECT cdcooper, cdagectl, nmrescop, flgativo FROM crapcop;
  
    CURSOR cr_craptco(pr_cdcopant IN crapcop.cdcooper%TYPE,
                      pr_nrctaant IN craptco.nrctaant%TYPE) IS
      SELECT tco.nrdconta, tco.cdcooper
        FROM craptco tco
       WHERE tco.cdcopant = pr_cdcopant
         AND tco.nrctaant = pr_nrctaant;
    rw_craptco cr_craptco%ROWTYPE;
  
    -- PL/Table para armazenar as agencias
    type typ_crapcop IS RECORD(
      cdcooper crapcop.cdcooper%TYPE,
      nmrescop crapcop.nmrescop%TYPE,
      flgativo crapcop.flgativo%TYPE);
    type typ_tab_crapcop IS TABLE OF typ_crapcop INDEX BY PLS_INTEGER;
    vr_crapcop typ_tab_crapcop;
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(32000);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_erro      EXCEPTION;
  
    -- Variaveis gerais
    vr_nrseqdiglcm   craplcm.nrseqdig%TYPE;
    vr_nrseqdiglau   craplau.nrseqdig%TYPE;
    vr_dserro        VARCHAR2(100); --> Variavel de erro
    vr_dserro_arq    VARCHAR2(100); --> Variavel de erro do reg arquivo
    vr_cdocorr       VARCHAR2(2) := NULL; --> Código de ocorrencia do pdv
    vr_cdocorr_arq   VARCHAR2(2) := NULL; --> Código de ocorrencia do reg arquivo
    vr_inpessoa      crapass.inpessoa%TYPE; --> Indicador de tipo de pessoa
    vr_cdcooper      crapcop.cdcooper%TYPE; --> Codigo da cooperativa
    vr_cdhistor      craphis.cdhistor%TYPE; --> Codigo do historico do lancamento
    vr_nrdolote      craplcm.nrdolote%TYPE; --> Numero do lote
    vr_qterros       PLS_INTEGER := 0; --> Quantidade de registros com erro
    vr_qtprocessados PLS_INTEGER := 0; --> Quantidade de registros processados
    vr_qtfuturos     PLS_INTEGER := 0; --> Quantidade de lancamentos futuros processados
    vr_inlctfut      VARCHAR2(01); --> Indicador de lancamento futuro
  
    vr_coopdest     crapcop.cdcooper%TYPE; --> coop destino (incorporacao/migracao)
    vr_nrdconta     NUMBER(25);
    vr_cdcooper_lcm craplcm.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
    vr_cdcooper_lau craplau.cdcooper%TYPE; --> Variável para controle de quebra na gravacao da craplcm
    vr_dtprocesso   crapdat.dtmvtolt%TYPE; --> Data da cooperativa
    vr_qtproclancto PLS_INTEGER := 0; --> Quantidade de registros lidos do lancamento
  
    -- Variáveis email
    vr_para     varchar2(300);
    vr_assunto  varchar2(300);
    vr_mensagem varchar2(32767);
  BEGIN
  
    -- Popula a pl/table de agencia
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_crapcop(rw_crapcop.cdagectl).cdcooper := rw_crapcop.cdcooper;
      vr_crapcop(rw_crapcop.cdagectl).nmrescop := rw_crapcop.nmrescop;
      vr_crapcop(rw_crapcop.cdagectl).flgativo := rw_crapcop.flgativo;
    END LOOP;
  
    -- Efetua loop sobre os registros pendentes
    FOR rw_lancamento IN cr_lancamento_reg LOOP
    
      -- Limpa variaveis de controle de quebra para gravacao da craplcm e craplau
      -- Como trata-se de um novo tipo de arquivo precisa-se limpar pois o numero
      -- do lote será alterado.
      vr_cdcooper_lcm := 0;
      vr_cdcooper_lau := 0;
    
      -- Limpa a variavel de erro
      vr_dserro_arq  := NULL;
      vr_cdocorr_arq := NULL;
      -- Criticar tipo de arquivo.
      IF rw_lancamento.tparquivo NOT in (1, 2, 3) THEN
        vr_dserro_arq  := 'Tipo de arquivo (' || rw_lancamento.tparquivo ||
                          ') nao previsto.';
        vr_cdocorr_arq := '99';
      END IF;
    
      vr_qtproclancto := 0;
			
      FOR rw_tabela IN cr_tabela_reg(rw_lancamento.idlancto,
                                 rw_lancamento.tpforma_transf) LOOP
        -- Limpa a variavel de erro
        vr_dserro       := NULL;
        vr_cdocorr      := NULL;
        vr_qtproclancto := vr_qtproclancto + 1;
      
        -- Efetua todas as consistencias dentro deste BEGIN
        BEGIN
        
          -- se existe erro a nível de arquivo/lancamento jogará para todos os
          -- registros PDV este erro
          IF NVL(vr_cdocorr_arq, '00') <> '00' THEN
            vr_dserro  := vr_dserro_arq;
            vr_cdocorr := vr_cdocorr_arq;
            RAISE vr_erro;
          END IF;
        
          IF vr_crapcop(rw_tabela.cdagencia_centraliza).flgativo = 0 THEN
          
            OPEN cr_craptco(pr_cdcopant => vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper,
                            pr_nrctaant => rw_tabela.nrcta_centraliza);
            FETCH cr_craptco
              INTO rw_craptco;
          
            IF cr_craptco%FOUND THEN
              vr_nrdconta := rw_craptco.nrdconta;
              vr_coopdest := rw_craptco.cdcooper;
            ELSE
              vr_nrdconta := 0;
              vr_coopdest := 0;
            END IF;
          
            CLOSE cr_craptco;
          
          ELSE
            vr_nrdconta := rw_tabela.nrcta_centraliza;
            vr_coopdest := vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper;
          END IF;
        
          -- Busca a data da cooperativa
          -- foi incluido aqui pois pode existir contas transferidas
          OPEN btch0001.cr_crapdat(vr_coopdest);
          FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
          CLOSE btch0001.cr_crapdat;
        
          --Alterado para utilizar a data do parâmetro, se for diferente de NULL
          --IF vr_database_name = 'AYLLOSD' THEN
          IF pr_dtprocesso IS NULL THEN
            IF rw_crapdat.inproces > 1 THEN
              -- Está executando cadeia
              vr_dtprocesso := rw_crapdat.dtmvtopr;
            ELSE
              vr_dtprocesso := rw_crapdat.dtmvtolt;
            END IF;
          ELSE
            vr_dtprocesso := trunc(nvl(pr_dtprocesso, sysdate));
          END IF;
        
        EXCEPTION
          WHEN vr_erro THEN
            NULL;
        END;
      
        vr_nrdolote := 9666; -- Conforme validado em 22/11/2017
      
        -- Atualiza os historicos de lancamento
        IF rw_lancamento.tparquivo = 1 THEN
          -- crédito
          IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN
            -- BRADESCO
            vr_cdhistor := 2444;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01027058000191 THEN
            -- CIELO
            vr_cdhistor := 2546;
          ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN
            -- SIPAG
            vr_cdhistor := 2443;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN
            -- REDECARD
            vr_cdhistor := 2442;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN
            -- STONE
            vr_cdhistor := 2450;
          ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN
            -- ELAVON
            vr_cdhistor := 2453;
          ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN
            -- VERO
            vr_cdhistor := 2478;
          ELSIF rw_lancamento.nrcnpj_credenciador = 28127603000178 THEN
            -- BANESCARD
            vr_cdhistor := 2484;
          ELSIF rw_lancamento.nrcnpj_credenciador = 60114865000100 THEN
            -- SOROCRED
            vr_cdhistor := 2485;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01722480000167 THEN
            -- VERDECARD
            vr_cdhistor := 2486;
          ELSIF rw_lancamento.nrcnpj_credenciador = 04670195000138 THEN
            -- CREDSYSTEM
            vr_cdhistor := 2487;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08561701000101 THEN
            -- PAGSEGURO
            vr_cdhistor := 2488;
          ELSIF rw_lancamento.nrcnpj_credenciador = 10440482000154 THEN
            -- GETNET
            vr_cdhistor := 2489;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17887874000105 THEN
            -- GLOBAL PAYMENTS
            vr_cdhistor := 2490;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20520298000178 THEN
            -- ADYEN
            vr_cdhistor := 2491;
          ELSIF rw_lancamento.nrcnpj_credenciador = 58160789000128 THEN
            -- SAFRAPAY
            vr_cdhistor := 2492;
            -- Inicio1 RITM0013845
          ELSIF rw_lancamento.nrcnpj_credenciador = 19250003000101 THEN
            --  PAGO  
            vr_cdhistor := 2843;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08965639000113 THEN
            --  PAYU  
            vr_cdhistor := 2844;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17768068000118 THEN
            --  PINPAG  
            vr_cdhistor := 2845;
          ELSIF rw_lancamento.nrcnpj_credenciador = 18577728000146 THEN
            --  ESFERA 5  
            vr_cdhistor := 2846;
          ELSIF rw_lancamento.nrcnpj_credenciador = 22121209000146 THEN
            --  STRIPE BRASIL 
            vr_cdhistor := 2847;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16668076000120 THEN
            --  SUMUP 
            vr_cdhistor := 2848;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20250105000106 THEN
            --  LISTO TECNOLOGIA  
            vr_cdhistor := 2849;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14380200000121 THEN
            --  IFOOD 
            vr_cdhistor := 2850;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14625224000101 THEN
            --  STELO 
            vr_cdhistor := 2851;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20551972000181 THEN
            --  BEBLUE  
            vr_cdhistor := 2852;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787003383 THEN
            --  CREDICARD 
            vr_cdhistor := 2853;
            -- Fim1 RITM0013845
          ELSE
            -- OUTROS CREDENCIADORES
            vr_cdhistor := 2445;
          END IF;
        ELSIF rw_lancamento.tparquivo = 2 THEN
          -- débito
          IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN
            -- BRADESCO
            vr_cdhistor := 2448;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01027058000191 THEN
            -- CIELO
            vr_cdhistor := 2547;
          ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN
            -- SIPAG
            vr_cdhistor := 2447;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN
            -- REDECARD
            vr_cdhistor := 2446;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN
            -- STONE
            vr_cdhistor := 2451;
          ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN
            -- ELAVON
            vr_cdhistor := 2413;
          ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN
            -- BANRISUL
            vr_cdhistor := 2479;
          ELSIF rw_lancamento.nrcnpj_credenciador = 28127603000178 THEN
            -- BANESCARD
            vr_cdhistor := 2493;
          ELSIF rw_lancamento.nrcnpj_credenciador = 60114865000100 THEN
            -- SOROCRED
            vr_cdhistor := 2494;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01722480000167 THEN
            -- VERDECARD
            vr_cdhistor := 2495;
          ELSIF rw_lancamento.nrcnpj_credenciador = 04670195000138 THEN
            -- CREDSYSTEM
            vr_cdhistor := 2496;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08561701000101 THEN
            -- PAGSEGURO
            vr_cdhistor := 2497;
          ELSIF rw_lancamento.nrcnpj_credenciador = 10440482000154 THEN
            -- GETNET
            vr_cdhistor := 2498;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17887874000105 THEN
            -- GLOBAL PAYMENTS
            vr_cdhistor := 2499;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20520298000178 THEN
            -- ADYEN
            vr_cdhistor := 2500;
          ELSIF rw_lancamento.nrcnpj_credenciador = 58160789000128 THEN
            -- ADYEN
            vr_cdhistor := 2501;
            -- Inicio2 RITM0013845
          ELSIF rw_lancamento.nrcnpj_credenciador = 19250003000101 THEN
            --  PAGO  
            vr_cdhistor := 2854;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08965639000113 THEN
            --  PAYU  
            vr_cdhistor := 2855;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17768068000118 THEN
            --  PINPAG  
            vr_cdhistor := 2856;
          ELSIF rw_lancamento.nrcnpj_credenciador = 18577728000146 THEN
            --  ESFERA 5  
            vr_cdhistor := 2857;
          ELSIF rw_lancamento.nrcnpj_credenciador = 22121209000146 THEN
            --  STRIPE BRASIL 
            vr_cdhistor := 2858;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16668076000120 THEN
            --  SUMUP 
            vr_cdhistor := 2859;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20250105000106 THEN
            --  LISTO TECNOLOGIA  
            vr_cdhistor := 2860;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14380200000121 THEN
            --  IFOOD 
            vr_cdhistor := 2861;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14625224000101 THEN
            --  STELO 
            vr_cdhistor := 2862;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20551972000181 THEN
            --  BEBLUE  
            vr_cdhistor := 2863;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787003383 THEN
            --  CREDICARD 
            vr_cdhistor := 2864;
            -- Fim2 RITM0013845
          ELSE
            -- OUTROS CREDENCIADORES
            vr_cdhistor := 2449;
          END IF;
        ELSE
          -- antecipação
          IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN
            -- BRADESCO
            vr_cdhistor := 2456;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01027058000191 THEN
            -- CIELO
            vr_cdhistor := 2548;
          ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN
            -- SIPAG
            vr_cdhistor := 2455;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN
            -- REDECARD
            vr_cdhistor := 2454;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN
            -- STONE
            vr_cdhistor := 2452;
          ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN
            -- ELAVON
            vr_cdhistor := 2414;
          ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN
            -- BANRISUL / VERO
            vr_cdhistor := 2480;
          ELSIF rw_lancamento.nrcnpj_credenciador = 28127603000178 THEN
            -- BANESCARD
            vr_cdhistor := 2502;
          ELSIF rw_lancamento.nrcnpj_credenciador = 60114865000100 THEN
            -- SOROCRED
            vr_cdhistor := 2503;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01722480000167 THEN
            -- VERDECARD
            vr_cdhistor := 2504;
          ELSIF rw_lancamento.nrcnpj_credenciador = 04670195000138 THEN
            -- CREDSYSTEM
            vr_cdhistor := 2505;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08561701000101 THEN
            -- PAGSEGURO
            vr_cdhistor := 2506;
          ELSIF rw_lancamento.nrcnpj_credenciador = 10440482000154 THEN
            -- GETNET
            vr_cdhistor := 2507;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17887874000105 THEN
            -- GLOBAL PAYMENTS
            vr_cdhistor := 2508;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20520298000178 THEN
            -- ADYEN
            vr_cdhistor := 2509;
          ELSIF rw_lancamento.nrcnpj_credenciador = 58160789000128 THEN
            -- ADYEN
            vr_cdhistor := 2510;
            -- Inicio3 RITM0013845
          ELSIF rw_lancamento.nrcnpj_credenciador = 19250003000101 THEN
            --  PAGO  
            vr_cdhistor := 2865;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08965639000113 THEN
            --  PAYU  
            vr_cdhistor := 2866;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17768068000118 THEN
            --  PINPAG  
            vr_cdhistor := 2867;
          ELSIF rw_lancamento.nrcnpj_credenciador = 18577728000146 THEN
            --  ESFERA 5  
            vr_cdhistor := 2868;
          ELSIF rw_lancamento.nrcnpj_credenciador = 22121209000146 THEN
            --  STRIPE BRASIL 
            vr_cdhistor := 2869;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16668076000120 THEN
            --  SUMUP 
            vr_cdhistor := 2870;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20250105000106 THEN
            --  LISTO TECNOLOGIA  
            vr_cdhistor := 2871;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14380200000121 THEN
            --  IFOOD 
            vr_cdhistor := 2872;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14625224000101 THEN
            --  STELO 
            vr_cdhistor := 2873;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20551972000181 THEN
            --  BEBLUE  
            vr_cdhistor := 2874;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787003383 THEN
            --  CREDICARD 
            vr_cdhistor := 2875;
            -- Fim3 RITM0013845
          ELSE
            -- OUTROS CREDENCIADORES
            vr_cdhistor := 2457;
          END IF;
        END IF;
      
        -- Se nao existir erro, insere o lancamento
        IF vr_cdocorr IS NULL AND trunc(rw_tabela.dtpagamento) = to_date('23/07/2021', 'DD/MM/RRRR') THEN
          -- Integrar na craplcm e atualizar
          -- dtdebito se existir na craplau
        
          -- Atualiza a cooperativa
          vr_cdcooper := vr_coopdest;
        
          -- procura ultima sequencia do lote pra jogar em vr_nrseqdiglcm
          pr_cdcritic     := null;
          vr_dscritic     := null;
          vr_cdcooper_lcm := vr_cdcooper; -- salva a nova cooperativa para a quebra
          ccrd0006.pc_procura_ultseq_craplcm(pr_cdcooper    => vr_cdcooper,
                                    pr_dtmvtolt    => vr_dtprocesso,
                                    pr_cdagenci    => 1,
                                    pr_cdbccxlt    => 100,
                                    pr_nrdolote    => vr_nrdolote,
                                    pr_nrseqdiglcm => vr_nrseqdiglcm,
                                    pr_cdcritic    => vr_cdcritic,
                                    pr_dscritic    => vr_dscritic);
        
          IF vr_dscritic is not null then
            RAISE vr_exc_saida;
          END IF;
        
          BEGIN
            -- insere o registro na tabela de lancamentos
            LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt => trunc(vr_dtprocesso) -- dtmvtolt
                                              ,
                                               pr_cdagenci => 1 -- cdagenci
                                              ,
                                               pr_cdbccxlt => 100 -- cdbccxlt
                                              ,
                                               pr_nrdolote => vr_nrdolote -- nrdolote 
                                              ,
                                               pr_nrdconta => vr_nrdconta -- nrdconta 
                                              ,
                                               pr_nrdocmto => vr_nrseqdiglcm -- nrdocmto 
                                              ,
                                               pr_cdhistor => vr_cdhistor -- cdhistor
                                              ,
                                               pr_nrseqdig => vr_nrseqdiglcm -- nrseqdig
                                              ,
                                               pr_vllanmto => rw_tabela.vlpagamento -- vllanmto 
                                              ,
                                               pr_nrdctabb => vr_nrdconta -- nrdctabb
                                              ,
                                               pr_nrdctitg => GENE0002.fn_mask(vr_nrdconta,
                                                                               '99999999') -- nrdctitg 
                                              ,
                                               pr_cdcooper => vr_cdcooper -- cdcooper
                                              ,
                                               pr_dtrefere => rw_tabela.dtpagamento -- dtrefere
                                              ,
                                               pr_cdoperad => 1 -- cdoperad
                                              ,
                                               pr_cdpesqbb => rw_tabela.nrliquidacao -- cdpesqbb                                                                                                
                                               -- OUTPUT --
                                              ,
                                               pr_tab_retorno => vr_tab_retorno,
                                               pr_incrineg    => vr_incrineg,
                                               pr_cdcritic    => vr_cdcritic,
                                               pr_dscritic    => vr_dscritic);
          
            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          EXCEPTION
            WHEN vr_exc_saida THEN
              raise vr_exc_saida; -- Apenas passar a critica 
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir CRAPLCM: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        
          -- Atualiza data de débito na craplau
          BEGIN
            UPDATE craplau
               SET dtdebito = trunc(vr_dtprocesso)
             WHERE cdcooper = vr_cdcooper
               AND dtmvtopg = rw_tabela.dtpagamento
               AND nrdconta = vr_nrdconta
               AND cdseqtel = rw_tabela.nrliquidacao;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela CRAPLAU - dtdebito : ' ||
                             SQLERRM;
              RAISE vr_exc_saida;
          END;
        
          vr_qtprocessados := vr_qtprocessados + 1;

		  vr_dscritic := NULL;        
        END IF;
      
        IF nvl(vr_cdocorr, '00') <> '00' THEN
          vr_qterros := vr_qterros + 1;
   
		  vr_dscritic := NULL;       
        END IF;
      
        IF nvl(vr_cdocorr, '00') = '00' THEN
          IF rw_tabela.dtpagamento > vr_dtprocesso THEN
            IF rw_lancamento.tparquivo = 1 THEN
              -- crédito
              vr_cdocorr := '01'; -- agendamento de transação efetuado com sucesso --
            END IF;
          END IF;
        END IF;
      
      END LOOP; -- loop cr_tabela
    
      -- Efetua a atualizacao da situacao na tabela de lancamentos
      -- Se encontrar algum registro sem erro no lancto, atualiza situação para 2
      -- Com isso, se tiver apenas 1 PDV sem erro dentro de um lançamento considera todo o lançamento como processado
      IF vr_qtproclancto > 0 THEN
        BEGIN
          UPDATE tbdomic_liqtrans_lancto
             SET insituacao      = 2 -- processado
                ,
                 dhprocessamento = SYSDATE
           WHERE idlancto = rw_lancamento.idlancto;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela tbdomic_liqtrans_lancto: ' ||
                           SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;
    
    --END IF;
    END LOOP; -- loop cr_lancamento
  
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      -- Efetuar rollback
      ROLLBACK;
      raise_application_error(-20001,
                              'pc_efetiva_reg_pendentes vr_exc_saida' || ' ' ||
                              pr_cdcritic || ' ' || sqlerrm);
    
    WHEN OTHERS THEN
      raise_application_error(-20001,
                              'pc_efetiva_reg_pendentes ' || sqlerrm);
    
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
    
  END; -- pc_efetiva_reg_pendentes --



BEGIN
	
  BEGIN
    DECLARE
      CURSOR cr_arquivo IS
         SELECT *
           FROM tbdomic_liqtrans_arquivo a
          WHERE a.nmarquivo_origem IN (
                'ASLC024_05463212_20210723_00011'
         );
     rw_arquivo cr_arquivo%ROWTYPE;
    BEGIN
       FOR rw_arquivo IN cr_arquivo LOOP
             DELETE 
               FROM tbdomic_liqtrans_critica c
              WHERE c.idarquivo = rw_arquivo.idarquivo;
              
             DELETE
               FROM tbdomic_liqtrans_pdv p
              WHERE p.idcentraliza IN (
                    SELECT idcentraliza
                      FROM tbdomic_liqtrans_centraliza c,
                           tbdomic_liqtrans_lancto l
                     WHERE c.idlancto = l.idlancto
                       AND l.idarquivo = rw_arquivo.idarquivo
             );


             DELETE
               FROM tbdomic_liqtrans_centraliza c
              WHERE c.idlancto IN (
                    SELECT l.idlancto
                      FROM tbdomic_liqtrans_lancto l
                     WHERE l.idarquivo = rw_arquivo.idarquivo
              );


             DELETE
               FROM tbdomic_liqtrans_lancto l
              WHERE l.idarquivo = rw_arquivo.idarquivo;


             DELETE
               FROM tbdomic_liqtrans_arquivo a
              WHERE a.idarquivo = rw_arquivo.idarquivo;
       END LOOP;
    END;


    COMMIT;
  END;

  -- Test statements here
  pc_leitura_arquivos_xml(pr_cdcritic => vr_cdcritic,
                          pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20001,
                              'pc_leitura_arquivos_xml ' || sqlerrm);
  END IF;
 
 
	pc_processa_reg_pendentes(pr_dtprocesso => vr_dtprocessoexec,
													 pr_cdcritic   => vr_cdcritic,
													 pr_dscritic   => vr_dscritic);
														 
	IF TRIM(vr_dscritic) IS NOT NULL THEN
			 raise_application_error(-20001,
															'pc_processa_reg_pendentes ' || sqlerrm);
	END IF;
 
	pc_efetiva_reg_pendentes(pr_dtprocesso => vr_dtprocessoexec,
																		pr_cdcritic   => vr_cdcritic,
																		pr_dscritic   => vr_dscritic);
	IF vr_dscritic IS NOT NULL THEN
			 raise_application_error(-20001,
															'pc_efetiva_reg_pendentes ' || sqlerrm);
	END IF;
	
	BEGIN
		UPDATE tbdomic_liqtrans_pdv p
			 SET p.dhretorno = SYSDATE
		 WHERE p.dserro IS NULL
			 AND p.idpdv IN (
					 SELECT idpdv
						 FROM tbdomic_liqtrans_pdv pdv
						WHERE pdv.idcentraliza IN (
									SELECT ctz.idcentraliza
										FROM tbdomic_liqtrans_centraliza ctz
									 WHERE ctz.idlancto IN (
												 SELECT lct.idlancto
													 FROM tbdomic_liqtrans_lancto lct
													WHERE lct.idarquivo IN (
																SELECT idarquivo
																	FROM tbdomic_liqtrans_arquivo a
																 WHERE a.nmarquivo_origem = 'ASLC024_05463212_20210723_00011'
													)
									 )
						)
							AND pdv.dserro IS NULL
			 );	
		COMMIT;	
	END;
 
END;
