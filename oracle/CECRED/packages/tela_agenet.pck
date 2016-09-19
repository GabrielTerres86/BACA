CREATE OR REPLACE PACKAGE CECRED.TELA_AGENET AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_AGENET
--    Autor   : Jonathan
--    Data    : Novembro/2015                   Ultima Atualizacao:   /  /    
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da tela AGENET 
--
--    Alteracoes: 
--    
---------------------------------------------------------------------------------------------------------------
  
  --Tipo de Registros de agendamentos
  TYPE typ_reg_agendamentos IS RECORD 
      (cdagenci crapage.cdagenci%TYPE
      ,dsorigem craplau.dsorigem%TYPE
      ,nrdconta craplau.nrdconta%TYPE
      ,dtmvtopg craplau.dtmvtopg%TYPE
      ,dstiptra VARCHAR2(100)
      ,dstransa VARCHAR2(100)
      ,vllanaut craplau.vllanaut%TYPE
      ,insitlau craplau.insitlau%TYPE
      ,dssitlau VARCHAR2(100)
      ,dttransa craplau.dttransa%TYPE
      ,hrtransa craplau.hrtransa%TYPE
      ,cdcoptfn craplau.cdcoptfn%TYPE
      ,cdagetfn craplau.cdagetfn%TYPE
      ,nrterfin craplau.nrterfin%TYPE
      ,dstitdda varchar2(100));
      
  --Tipo de Tabela de Beneficiario
  TYPE typ_tab_agendamentos IS TABLE OF typ_reg_agendamentos INDEX BY PLS_INTEGER;    
  
  /* Procedure para buscar agendamentos */
  PROCEDURE pc_busca_agendamentos(pr_cddopcao  IN crapace.cddopcao%TYPE --> Opcao da tela
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                 ,pr_dtiniper  IN VARCHAR2              --> Data de inicio
                                 ,pr_dtfimper  IN VARCHAR2              --> Data final                                 
                                 ,pr_cdagesel  IN crapage.cdagenci%TYPE --> Agencia 
                                 ,pr_insitlau  IN craplau.insitlau%TYPE --> Situação do lançamento
                                 ,pr_nrregist IN INTEGER                --> Número de registros
                                 ,pr_nriniseq IN INTEGER                --> Número sequencial
                                 ,pr_tipsaida IN INTEGER                --> Tipo de saida do arquivo
                                 ,pr_nmarquiv IN VARCHAR2               --> Nome do arquivo
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK                                   
       

END TELA_AGENET;
/

CREATE OR REPLACE PACKAGE BODY CECRED.TELA_AGENET AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: TELA_AGENET
--    Autor   : Jonathan
--    Data    : Novembro/2015                   Ultima Atualizacao: 07/12/2015
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da tela AGENET
--
--    Alteracoes: 07/12/2015 - Retira chamada da rotina pc_informa_acesso pois estava sendo chamada em 
--                             duplicidade (Adriano).                               
--    
---------------------------------------------------------------------------------------------------------------
  /* Rotina para buscar os agendamentos */
  PROCEDURE pc_busca_agendamentos(pr_cddopcao  IN crapace.cddopcao%TYPE --> Opcao da tela
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                 ,pr_dtiniper  IN VARCHAR2              --> Data de inicio
                                 ,pr_dtfimper  IN VARCHAR2              --> Data final                                 
                                 ,pr_cdagesel  IN crapage.cdagenci%TYPE --> Agencia 
                                 ,pr_insitlau  IN craplau.insitlau%TYPE --> Situação do lançamento
                                 ,pr_nrregist IN INTEGER                --> Número de registros
                                 ,pr_nriniseq IN INTEGER                --> Número sequencial
                                 ,pr_tipsaida IN INTEGER                --> Tipo de saida do arquivo
                                 ,pr_nmarquiv IN VARCHAR2               --> Nome do arquivo
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_agendamentos
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jonathan
    Data    : Novembro/2015                       Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar os agendamentos

    Alteracoes: 07/12/2015 - Retira chamada da rotina pc_informa_acesso pois estava sendo chamada em 
                             duplicidade (Adriano).     
    ............................................................................. */
    
      --Curosor para pegar os agendamentos  
      CURSOR cr_craplau(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtiniper IN craplau.dtmvtopg%TYPE 
                       ,pr_dtfimper IN craplau.dtmvtopg%TYPE
                       ,pr_insitlau IN craplau.insitlau%TYPE
                       ,pr_cdagenci IN craplau.cdagenci%TYPE) IS
      SELECT lau.cdcooper
            ,lau.cdtiptra
            ,lau.cdageban
            ,lau.nrctadst
            ,lau.dsorigem
            ,lau.dslindig
            ,lau.dscodbar
            ,lau.nrdolote
            ,lau.idtitdda
            ,lau.dtmvtopg
            ,lau.vllanaut
            ,lau.insitlau
            ,lau.dttransa
            ,lau.hrtransa
            ,lau.cdcoptfn
            ,lau.cdagetfn
            ,lau.nrterfin
            ,lau.nrdconta
            ,ass.cdagenci
        FROM craplau lau 
            ,crapass ass        
       WHERE((lau.cdcooper = pr_cdcooper
             AND(NVL(pr_nrdconta,0) = 0
             OR  lau.nrdconta = pr_nrdconta)
             AND lau.dtmvtopg >= pr_dtiniper
             AND lau.dtmvtopg <= pr_dtfimper
             AND(NVL(pr_insitlau,0) = 0 
             OR  lau.insitlau = pr_insitlau)
             AND lau.dsorigem = 'INTERNET'
             AND lau.cdagenci = 90 
             AND lau.cdbccxlt = 100
             AND lau.nrdolote = 11900) 
         OR (lau.cdcooper  = pr_cdcooper
             AND(NVL(pr_nrdconta,0) = 0
             OR  lau.nrdconta = pr_nrdconta)
             AND lau.dtmvtopg >= pr_dtiniper
             AND lau.dtmvtopg <= pr_dtfimper
             AND(NVL(pr_insitlau,0) = 0      
             OR  lau.insitlau  = pr_insitlau) 
             AND lau.dsorigem  = 'TAA'   
             AND lau.cdagenci  = 91       
             AND lau.cdbccxlt  = 100      
             AND lau.nrdolote  = 11900)   
         OR (lau.cdcooper  = pr_cdcooper 
             AND(NVL(pr_nrdconta,0) = 0
             OR  lau.nrdconta = pr_nrdconta) 
             AND lau.dtmvtopg >= pr_dtiniper 
             AND lau.dtmvtopg <= pr_dtfimper 
             AND(NVL(pr_insitlau,0)  = 0
             OR  lau.insitlau  = pr_insitlau) 
             AND lau.dsorigem  = 'CAIXA'    
             AND lau.cdbccxlt  = 100        
             AND lau.nrseqagp <> 0)         
         OR (lau.cdcooper  = pr_cdcooper  
             AND(NVL(pr_nrdconta,0) = 0
             OR  lau.nrdconta = pr_nrdconta) 
             AND lau.dtmvtopg >= pr_dtiniper  
             AND lau.dtmvtopg <= pr_dtfimper  
             AND(NVL(pr_insitlau,0)  = 0         
             OR  lau.insitlau  = pr_insitlau)  
             AND lau.dsorigem  = 'CAPTACAO' 
             AND lau.cdagenci  = 1          
             AND lau.cdbccxlt  = 100        
             AND lau.nrdolote  = 32001)     
         OR (lau.cdcooper  = pr_cdcooper  
             AND(NVL(pr_nrdconta,0) = 0
             OR  lau.nrdconta = pr_nrdconta) 
             AND lau.dtmvtopg >= pr_dtiniper  
             AND lau.dtmvtopg <= pr_dtfimper  
             AND(NVL(pr_insitlau,0)  = 0             
             OR  lau.insitlau  = pr_insitlau)
             AND lau.dsorigem  = 'CAPTACAO'  
             AND lau.cdagenci  = 1           
             AND lau.cdbccxlt  = 100         
             AND lau.nrdolote  = 32002))
         AND ass.cdcooper = lau.cdcooper
         AND ass.nrdconta = lau.nrdconta
         AND (NVL(pr_cdagenci,0) = 0 
         OR  ass.cdagenci = pr_cdagenci) 
          ORDER BY ass.cdagenci;
      rw_craplau cr_craplau%ROWTYPE;     
          
      -- Busca dos dados do associado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.cdcooper 
            ,ass.cdagenci           
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Busca dos dados do associado destino
      CURSOR cr_crapass_dst(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.cdcooper   
            ,ass.nmprimtl         
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
      rw_crapass_dst cr_crapass_dst%ROWTYPE;
      
      --Busca cooperativa
      CURSOR cr_crapcop(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdagectl = pr_cdagectl;
     rw_crapcop cr_crapcop%ROWTYPE;
            
     --Tabela de beneficiarios
     vr_tab_agendamentos TELA_AGENET.typ_tab_agendamentos;

     --Tabela de Erros
     vr_tab_erro gene0001.typ_tab_erro;
    
     -- Cursor genérico de calendário
     rw_crapdat btch0001.cr_crapdat%ROWTYPE;
     
     vr_cdcritic crapcri.cdcritic%TYPE;
     vr_dscritic crapcri.dscritic%TYPE;
     
     --Variáveis auxiliares      
     vr_dstiptra VARCHAR2(100);
     vr_dstransa VARCHAR2(100);
     vr_nrregist INTEGER;
     vr_dtiniper DATE := NULL;
     vr_dtfimper DATE := NULL;  
     vr_qtregist INTEGER := 0;
     vr_vltotaut NUMBER := 0;
     vr_nmdireto VARCHAR2(100);
     vr_dstexto  VARCHAR2(32700);      
     vr_clobxml  CLOB;       
     vr_des_reto VARCHAR2(3);      
     vr_nmarqpdf VARCHAR2(200);
     vr_comando  VARCHAR2(1000);
     vr_typ_saida VARCHAR2(3);
     
     -- Variaveis de log
     vr_cdcooper crapcop.cdcooper%TYPE;
     vr_cdoperad VARCHAR2(100);
     vr_nmdatela VARCHAR2(100);
     vr_nmeacao  VARCHAR2(100);
     vr_cdagenci VARCHAR2(100);
     vr_nrdcaixa VARCHAR2(100);
     vr_idorigem VARCHAR2(100);
                
     --Variaveis Arquivo Dados
     vr_auxconta PLS_INTEGER:= 0;
    
     --Variaveis de Indice
     vr_index PLS_INTEGER := 0;
     
     --Controle de erro
     vr_exc_erro EXCEPTION;      
      
    BEGIN
           
      pr_des_erro := 'NOK';
      vr_nrregist := pr_nrregist;
      
      --Limpar tabela dados
      vr_tab_agendamentos.DELETE;
      vr_tab_erro.DELETE;
      
       -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'AGENET'
                                ,pr_action => null);
                              
      BEGIN                                                  
        --Pega a data do periodo inicial
        vr_dtiniper := to_date(pr_dtiniper,'DD/MM/RRRR'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Periodo inicial invalido.';
          pr_nmdcampo := 'dtiniper';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      BEGIN                                                  
        --Pega a data do periodo final
        vr_dtfimper := to_date(pr_dtfimper,'DD/MM/RRRR'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Periodo final invalido.';
          pr_nmdcampo := 'dtfimper';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;                       
  
      IF pr_nrdconta > 0 THEN
        
        -- Verifica se o associado existe
        OPEN cr_crapass (pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
                        
        FETCH cr_crapass INTO rw_crapass;
        
        -- Se nao encontrar
        IF cr_crapass%NOTFOUND THEN
          
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapass;
          
          -- Montar mensagem de critica
          vr_cdcritic := 9;
          
          -- Busca critica
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          
          --Campo com critica
          pr_nmdcampo:= 'nrdconta';
          
          --Levantar Excecao
          RAISE vr_exc_erro;
          
        ELSE
          
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapass;        
        
        END IF;
              
      END IF;
      
      --Se foi escolhido opcao de impressao/arquivo e nao informado o nome do arquivo
      IF pr_cddopcao = 'I'                AND
         NVL(TRIM(pr_nmarquiv),' ') = ' ' THEN
      
         --Monta mensagem de critica
         vr_dscritic := 'Nome do arquivo invalido.';
         pr_nmdcampo := 'nmarquiv';
         
         --Gera exceção
         RAISE vr_exc_erro;
          
      END IF;
      
      -- Leitura do calendario da CENTRAL
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
      FETCH btch0001.cr_crapdat INTO rw_crapdat;    
                                                                            
      --Busca os agendamentos
      FOR rw_craplau IN cr_craplau(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta 
                                  ,pr_dtiniper => vr_dtiniper
                                  ,pr_dtfimper => vr_dtfimper
                                  ,pr_insitlau => pr_insitlau
                                  ,pr_cdagenci => pr_cdagesel) LOOP                                  
                                                                      
        --Incrementar contador
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
        
        -- controles da paginacao 
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
          
          --Proximo
          CONTINUE;  
          
        END IF; 
        
        IF vr_nrregist >= 1 THEN                    
          
          IF rw_craplau.cdtiptra = 1 OR   --Transferencia
             rw_craplau.cdtiptra = 5 OR   --Transferencia intercooperativa
             rw_craplau.cdtiptra = 3 THEN --Credito Salario
             
            IF rw_craplau.cdtiptra = 1 OR   --Transferencia
               rw_craplau.cdtiptra = 5 THEN --Transferencia intercooperativa 
            
              vr_dstiptra := 'TRANSFERENCIA';
              
            ELSE
              
              vr_dstiptra := 'CRED.SALARIO';   
              
            END IF;
            
            vr_dstransa := TRIM(TO_CHAR(rw_craplau.cdageban,'0000')) || '/' ||
                           TRIM(TO_CHAR(TRIM(gene0002.fn_mask(rw_craplau.nrctadst,'zzzz.zzz.z'))));
            
            --Busca a cooperativa              
            OPEN cr_crapcop(pr_cdagectl => rw_craplau.cdageban);
            
            FETCH cr_crapcop INTO rw_crapcop;
            
            IF cr_crapcop%NOTFOUND THEN
              
              --Fechar o cursor
              CLOSE cr_crapcop;
              
            ELSE
              
              --Fechar o cursor
              CLOSE cr_crapcop;
                
            END IF;
            
            --Busca o associado destino           
            OPEN cr_crapass_dst(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_nrdconta => rw_craplau.nrctadst);
            
            FETCH cr_crapass_dst INTO rw_crapass_dst;
            
            IF cr_crapass_dst%NOTFOUND THEN
              
              --Fechar o cursor
              CLOSE cr_crapass_dst;
              
            ELSE
              
              --Fechar o cursor
              CLOSE cr_crapass_dst;
              
              vr_dstransa := vr_dstransa || ' - ' || rw_crapass_dst.nmprimtl;                             
                
            END IF;
           
          ELSIF rw_craplau.cdtiptra = 2 THEN --Pagamentos
            
            vr_dstiptra := 'PAGAMENTO';
            
            IF rw_craplau.dsorigem = 'CAIXA'        AND
               NVL(TRIM(rw_craplau.dslindig),0) = 0 THEN
              
              vr_dstransa := rw_craplau.dscodbar;
              
            ELSE
              
              vr_dstransa := rw_craplau.dslindig;
            
            END IF;
            
          ELSE
            
            IF rw_craplau.cdtiptra = 0 THEN
              
              IF rw_craplau.nrdolote = 32001 THEN
                
                vr_dstiptra := 'APLICACAO';
                vr_dstransa := ' '; 
              
              ELSIF rw_craplau.nrdolote = 32002 THEN
                
                vr_dstiptra := 'RESGATE';
                vr_dstransa := ' '; 
              
              END IF;                           
              
            END IF;  
                                
          END IF;
                  
          IF rw_craplau.dsorigem = 'TAA' THEN
            
            vr_dstiptra := 'TAA-' || vr_dstiptra;
            
          ELSIF rw_craplau.dsorigem = 'CAIXA' THEN
            
            vr_dstiptra := 'CXA-' || vr_dstiptra;
                
          ELSE
            
            vr_dstiptra := 'NET-' || vr_dstiptra;

            IF rw_craplau.idtitdda > 0 THEN
              
              vr_dstiptra := vr_dstiptra || '-DDA';
                        
            END IF;            
          
          END IF;
                          
         --Alimenta  PLTABLE com os agendamentos encontrados                                        
         vr_tab_agendamentos(vr_index).cdagenci:= rw_craplau.cdagenci; 
         vr_tab_agendamentos(vr_index).dsorigem:= rw_craplau.dsorigem;
         vr_tab_agendamentos(vr_index).nrdconta:= rw_craplau.nrdconta;
         vr_tab_agendamentos(vr_index).dtmvtopg:= rw_craplau.dtmvtopg;
         vr_tab_agendamentos(vr_index).dstiptra:= vr_dstiptra;
         vr_tab_agendamentos(vr_index).dstransa:= vr_dstransa;
         vr_tab_agendamentos(vr_index).vllanaut:= rw_craplau.vllanaut;       
         
         IF rw_craplau.insitlau = 1 THEN
           
           vr_tab_agendamentos(vr_index).dssitlau:= 'PENDENTE';
         
         ELSIF rw_craplau.insitlau = 2 THEN 
           
           vr_tab_agendamentos(vr_index).dssitlau:= 'EFETIVADO';
         
         ELSIF rw_craplau.insitlau = 3 THEN
           
           vr_tab_agendamentos(vr_index).dssitlau:= 'CANCELADO'; 
         
         ELSE
           
           vr_tab_agendamentos(vr_index).dssitlau:= 'NAO EFETIVADO'; 
             
         END IF;       
         
         vr_tab_agendamentos(vr_index).dttransa:= rw_craplau.dttransa;
         vr_tab_agendamentos(vr_index).hrtransa:= rw_craplau.hrtransa;
         vr_tab_agendamentos(vr_index).cdcoptfn:= rw_craplau.cdcoptfn;
         vr_tab_agendamentos(vr_index).cdagetfn:= rw_craplau.cdagetfn;
         vr_tab_agendamentos(vr_index).nrterfin:= rw_craplau.nrterfin;
         vr_vltotaut := vr_vltotaut + rw_craplau.vllanaut;
         
         IF rw_craplau.nrterfin > 0 THEN
           
           IF pr_cddopcao = 'T' THEN
             
             vr_tab_agendamentos(vr_index).dstitdda:= 'TAA: ' || 
                                                      TRIM(TO_CHAR(rw_craplau.cdcoptfn,'00'))  || '/' ||
                                                      TRIM(TO_CHAR(rw_craplau.cdagetfn,'000')) || '/' ||
                                                      TRIM(TO_CHAR(rw_craplau.nrterfin,'0000'));
           ELSE 
              
             vr_tab_agendamentos(vr_index).dstitdda:= TRIM(TO_CHAR(rw_craplau.cdcoptfn,'00'))  || '/' ||
                                                      TRIM(TO_CHAR(rw_craplau.cdagetfn,'000')) || '/' ||
                                                      TRIM(TO_CHAR(rw_craplau.nrterfin,'0000'));                                          
                                                      
           END IF;
                             
         END IF;
         
         --Incrementar Contador
         vr_index:= vr_tab_agendamentos.COUNT + 1; 
         
       END IF;
       
       --Diminuir registros
       vr_nrregist:= nvl(vr_nrregist,0) - 1; 
        
      END LOOP;       
           
      IF pr_cddopcao = 'I' THEN             
      
        IF vr_tab_agendamentos.COUNT() = 0 THEN
          
          --Monta mensagem de critica
           vr_dscritic := 'Nenhum registro foi encontrado.';
           pr_nmdcampo := 'nrdconta';
         
           --Gera exceção
           RAISE vr_exc_erro;
           
        END IF;
        
        --Buscar Diretorio da Cooperativa
        vr_nmdireto:= gene0001.fn_diretorio(pr_tpdireto => 'M'
                                           ,pr_cdcooper => vr_cdcooper
                                           ,pr_nmsubdir => NULL);
        
        -- Inicializar as informações do XML de dados para o relatório
        dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);        
       
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                               '<?xml version="1.0" encoding="UTF-8"?><agenet><agendamentos>');                                 
                                            
        --Buscar Primeiro beneficiario
        vr_index:= vr_tab_agendamentos.FIRST;
           
        --Percorrer todos os beneficiarios
        WHILE vr_index IS NOT NULL LOOP          
                 
          --Escrever no XML
          gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                 '<agendamento>'||
                                    '<cdagenci>'||TO_CHAR(vr_tab_agendamentos(vr_index).cdagenci)||'</cdagenci>'||
                                    '<nrdconta>'||TRIM(gene0002.fn_mask(vr_tab_agendamentos(vr_index).nrdconta,'zzzz.zzz.z'))||'</nrdconta>'||
                                    '<dtmvtopg>'||TO_CHAR(vr_tab_agendamentos(vr_index).dtmvtopg,'dd/mm/RRRR')||'</dtmvtopg>'||
                                    '<dstiptra>'||vr_tab_agendamentos(vr_index).dstiptra||'</dstiptra>'||
                                    '<vllanaut>'||vr_tab_agendamentos(vr_index).vllanaut||'</vllanaut>'||
                                    '<dssitlau>'||vr_tab_agendamentos(vr_index).dssitlau||'</dssitlau>'||
                                    '<dstransa>'||vr_tab_agendamentos(vr_index).dstransa||'</dstransa>'||
                                    '<dttransa>'||TO_CHAR(vr_tab_agendamentos(vr_index).dttransa,'dd/mm/RRRR')||'</dttransa>'||
                                    '<dsdahora>'||TO_CHAR(TO_DATE(nvl(vr_tab_agendamentos(vr_index).hrtransa,0),'sssss'),'hh24:mi:ss')||'</dsdahora>'||
                                    '<dstitdda>'||vr_tab_agendamentos(vr_index).dstitdda||'</dstitdda>'||
                                 '</agendamento>'); 
                
          --Proximo Registro
          vr_index:= vr_tab_agendamentos.NEXT(vr_index);
          
        END LOOP;
        
        --Finaliza TAG Rejeitados e Relatorio
        gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</agendamentos></agenet>',TRUE);        
      
        vr_nmarqpdf := vr_nmdireto || '/' || pr_nmarquiv || '.pdf';       
             
        -- Gera relatório crrl657
	      gene0002.pc_solicita_relato(pr_cdcooper    => vr_cdcooper    --> Cooperativa conectada
                                     ,pr_cdprogra  => 'AGENET'--vr_nmdatela         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento atual
                                     ,pr_dsxml     => vr_clobxml          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/agenet/agendamentos/agendamento'          --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'agenet_agendamentos.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                --> Sem parâmetros
                                     ,pr_dsarqsaid => vr_nmarqpdf         --> Arquivo final com o path
                                     ,pr_qtcoluna  => 234                 --> Colunas do relatorio
                                     ,pr_flg_gerar => 'S'                 --> Geraçao na hora
                                     ,pr_cdrelato  => '484'               --> Códigod do relatório
                                     ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p) 
                                     ,pr_nmformul  => '234col'            --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                   --> Número de cópias
                                     ,pr_sqcabrel  => 1                   --> Qual a seq do cabrel                                                                          
                                     ,pr_des_erro  => vr_dscritic);       --> Saída com erro
          
        --Se ocorreu erro no relatorio
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF; 
          
        --Fechar Clob e Liberar Memoria	
        dbms_lob.close(vr_clobxml);
        dbms_lob.freetemporary(vr_clobxml); 

        --Se o tipo de saida for impressao enviar arquivo para o servidor web e elimina o arquivo orginal
        IF pr_tipsaida = 1 THEN
          
          --O ireport já irá gerar o relatório em formato pdf e por isso, iremos apenas
          --envia-lo ao servidor web.           
          gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                      ,pr_cdagenci => vr_cdagenci
                                      ,pr_nrdcaixa => vr_nrdcaixa
                                      ,pr_nmarqpdf => vr_nmarqpdf
                                      ,pr_des_reto => vr_des_reto
                                      ,pr_tab_erro => vr_tab_erro);

          --Se ocorreu erro
          IF vr_des_reto <> 'OK' THEN
              
            --Se tem erro na tabela 
            IF vr_tab_erro.COUNT > 0 THEN
              --Mensagem Erro
              vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_dscritic:= 'Erro ao enviar arquivo para web.';  
            END IF; 
              
            --Sair 
            RAISE vr_exc_erro;
              
          END IF;                 
         
          --Eliminar arquivo impressao
          IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqpdf) THEN 
                                                      
            --Excluir arquivo de impressao
             vr_comando:= 'rm '||vr_nmarqpdf||' 2>/dev/null';

            --Executar o comando no unix
            gene0001.pc_OScommand (pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);
                                  
            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
                            
              -- retornando ao programa chamador
              RAISE vr_exc_erro;
            END IF;
           
          END IF;
          
          --Retornar nome arquivo impressao e pdf
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
            
          -- Insere atributo na tag Dados com o valor total de agendamentos
          gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                                   ,pr_tag   => 'Dados'             --> Nome da TAG XML
                                   ,pr_atrib => 'nmarquiv'          --> Nome do atributo
                                   ,pr_atval => substr(vr_nmarqpdf,instr(vr_nmarqpdf,'/',-1)+1)         --> Valor do atributo
                                   ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                                   ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                   
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;  
            
        END IF;
        
      ELSE
        
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
           
        --Buscar Primeiro beneficiario
        vr_index:= vr_tab_agendamentos.FIRST;
           
        --Percorrer todos os beneficiarios
        WHILE vr_index IS NOT NULL LOOP
                     
          -- Insere as tags dos campos da PLTABLE de aplicações
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'agendamentos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'cdagenci', pr_tag_cont => TO_CHAR(vr_tab_agendamentos(vr_index).cdagenci), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'dsorigem', pr_tag_cont => TO_CHAR(vr_tab_agendamentos(vr_index).dsorigem), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta', pr_tag_cont => TRIM(gene0002.fn_mask(vr_tab_agendamentos(vr_index).nrdconta,'zzzz.zzz.z')), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'dtmvtopg', pr_tag_cont => TO_CHAR(vr_tab_agendamentos(vr_index).dtmvtopg,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'dstiptra', pr_tag_cont => vr_tab_agendamentos(vr_index).dstiptra, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'dstransa', pr_tag_cont => vr_tab_agendamentos(vr_index).dstransa, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'vllanaut', pr_tag_cont => vr_tab_agendamentos(vr_index).vllanaut, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'insitlau', pr_tag_cont => vr_tab_agendamentos(vr_index).insitlau, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'dssitlau', pr_tag_cont => vr_tab_agendamentos(vr_index).dssitlau, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'dttransa', pr_tag_cont => TO_CHAR(vr_tab_agendamentos(vr_index).dttransa,'dd/mm/RRRR'), pr_des_erro => vr_dscritic); 
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'hrtransa', pr_tag_cont => TO_CHAR(TO_DATE(nvl(vr_tab_agendamentos(vr_index).hrtransa,0),'sssss'),'hh24:mi:ss'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'cdcoptfn', pr_tag_cont => vr_tab_agendamentos(vr_index).cdcoptfn,  pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'cdagetfn', pr_tag_cont => vr_tab_agendamentos(vr_index).cdagetfn, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agendamentos', pr_posicao => vr_auxconta, pr_tag_nova => 'dstitdda', pr_tag_cont => vr_tab_agendamentos(vr_index).dstitdda, pr_des_erro => vr_dscritic);
  				            
          -- Incrementa contador p/ posicao no XML
          vr_auxconta := nvl(vr_auxconta,0) + 1;
                
          --Proximo Registro
          vr_index:= vr_tab_agendamentos.NEXT(vr_index);
          
        END LOOP;
        
        -- Insere atributo na tag Dados com a quantidade de registros
        gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                                 ,pr_tag   => 'Dados'             --> Nome da TAG XML
                                 ,pr_atrib => 'qtregist'          --> Nome do atributo
                                 ,pr_atval => vr_qtregist         --> Valor do atributo
                                 ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;  
        
        -- Insere atributo na tag Dados com o valor total de agendamentos
        gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                                 ,pr_tag   => 'Dados'             --> Nome da TAG XML
                                 ,pr_atrib => 'vllanaut'          --> Nome do atributo
                                 ,pr_atval => vr_vltotaut         --> Valor do atributo
                                 ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;          
        
      END IF;
      
      pr_des_erro := 'OK';      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na TELA_AGENET.pc_busca_agendamentos --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');        
        
  END pc_busca_agendamentos;

END TELA_AGENET;
/

