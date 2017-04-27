CREATE OR REPLACE PACKAGE CECRED.TELA_PARLIM AS
/*-------------------------------------------------------------------------------------------------------------
  
    Programa: TELA_PARLIM
    Autor   : Lucas Ranghetti
    Data    : Fevereiro/2017                   Ultima Atualizacao: 

    Dados referentes ao programa:

    Objetivo  : BO ref. a Mensageria da tela PARLIM 

    Alteracoes: 
                         
    
---------------------------------------------------------------------------------------------------------------*/
  
  /* Procedure com as rotinas para a tela PARLIM */
  PROCEDURE pc_manter_rotina( pr_cddopcao  IN VARCHAR2              --> Opcao
                             ,pr_qtdiacor  IN VARCHAR2              --> Número de registros
                             ,pr_vlminchq  IN VARCHAR2              --> Valor minimo cob. chq esp.
                             ,pr_vlminiof  IN VARCHAR2              --> Valor minimo cob. iof
                             ,pr_vlminadp  IN VARCHAR2              --> Valor minimo cob. jur adiantamento dep.
                             ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK                                   
       

END TELA_PARLIM;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARLIM AS
/*-------------------------------------------------------------------------------------------------------------

    Programa: TELA_PARLIM
    Autor   : Lucas Ranghetti
    Data    : Fevereiro/2017                  Ultima Atualizacao: 

    Dados referentes ao programa:

    Objetivo  : BO ref. a Mensageria da tela PARLIM

    Alteracoes: 
                
---------------------------------------------------------------------------------------------------------------*/
    /* Procedure com as rotinas para a tela PARLIM */
  PROCEDURE pc_manter_rotina( pr_cddopcao  IN VARCHAR2           --> Opcao
                             ,pr_qtdiacor  IN VARCHAR2           --> Número de registros
                             ,pr_vlminchq  IN VARCHAR2           --> Valor minimo cob. chq esp.
                             ,pr_vlminiof  IN VARCHAR2           --> Valor minimo cob. iof
                             ,pr_vlminadp  IN VARCHAR2           --> Valor minimo cob. jur adiantamento dep.
                             ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK    
    /* .............................................................................
    Programa: pc_manter_rotina
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Ranghetti
    Data    : Fevereiro/2017                       Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para efetuar as solicitações da tela PARLIM

    Alteracoes: 
                                
    ............................................................................. */
    
     vr_cdcritic crapcri.cdcritic%TYPE;
     vr_dscritic crapcri.dscritic%TYPE;     
    
     vr_clobxml  CLOB;       

     -- Variaveis de log
     vr_cdcooper crapcop.cdcooper%TYPE;
     vr_cdoperad VARCHAR2(100);
     vr_nmdatela VARCHAR2(100);
     vr_nmeacao  VARCHAR2(100);
     vr_cdagenci VARCHAR2(100);
     vr_nrdcaixa VARCHAR2(100);
     vr_idorigem VARCHAR2(100);
     
     vr_cdacesso VARCHAR2(20);
     vr_qtdiacor VARCHAR2(4);
     vr_vlminchq VARCHAR2(50);
     vr_vlminiof VARCHAR2(50);
     vr_vlminadp VARCHAR2(50);
     vr_des_log  VARCHAR2(3000);
     
     -- Variaveis auxiliares
     vr_dstransa VARCHAR2(1000);
     
     --Controle de erro
     vr_exc_erro EXCEPTION;      
     
     CURSOR cr_crapprm (pr_cdcooper IN crapprm.cdcooper%TYPE
                       ,pr_cdacesso IN crapprm.cdacesso%TYPE) IS
       SELECT *
         FROM crapprm m
        WHERE m.cdcooper = pr_cdcooper
          AND m.nmsistem = 'CRED'
          AND m.cdacesso LIKE pr_cdacesso;
      rw_crapprm cr_crapprm%ROWTYPE;
      
    BEGIN  
    
      vr_cdacesso:= '';           
      
      pr_des_erro := 'NOK';
      
      IF pr_cddopcao = 'I' THEN
        vr_dstransa := 'Incluir parametros da cob posterior de jur ch esp,jur AD,IOF';
      ELSIF pr_cddopcao = 'A' THEN
        vr_dstransa := 'Alterar parametros da cob posterior de jur ch esp,jur AD,IOF';
      ELSIF pr_cddopcao = 'C' THEN
        vr_dstransa := 'Consultar parametros da cob posterior de jur ch esp,jur AD,IOF';
      END IF;      
      
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
      GENE0001.pc_informa_acesso(pr_module => 'PARLIM');                              
        
      
      
      -- Verifica se os parametros existem
      OPEN cr_crapprm (pr_cdcooper => vr_cdcooper
                      ,pr_cdacesso => 'PARLIM%');
                        
      FETCH cr_crapprm INTO rw_crapprm;
        
      -- Se nao encontrar
      IF cr_crapprm%NOTFOUND THEN
        CLOSE cr_crapprm;
          
        IF pr_cddopcao IN('C','CA','A') THEN
          vr_dscritic:= 'Os parametros ainda nao foram cadastrados.';
          RAISE vr_exc_erro;
        END IF;
      ELSE
        CLOSE cr_crapprm;
        
        IF pr_cddopcao = 'I' THEN
          vr_dscritic:= 'Ja existem parametros cadastrados para esta coop.';
          RAISE vr_exc_erro;
        END IF;
      END IF;      
      
      -- Buscar dias corridos para a cobrança de juros
      vr_cdacesso:= 'PARLIM_QTDIACOR';
      vr_qtdiacor:= gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                              pr_cdcooper => vr_cdcooper,
                                              pr_cdacesso => vr_cdacesso);
      
      -- Valor minimo para cobrança de cheque especial                                      
      vr_cdacesso:= 'PARLIM_VLMINCHQ';
      vr_vlminchq:= gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                              pr_cdcooper => vr_cdcooper,
                                              pr_cdacesso => vr_cdacesso);
                                                
      -- Valor minimo para cobrança de IOF
      vr_cdacesso:= 'PARLIM_VLMINIOF';
      vr_vlminiof:= gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                              pr_cdcooper => vr_cdcooper,
                                              pr_cdacesso => vr_cdacesso);
                                                
      -- Valor minimo para cobrança de juros de adiantamento a depositante
      vr_cdacesso:= 'PARLIM_VLMINADP';
      vr_vlminadp:= gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                              pr_cdcooper => vr_cdcooper,
                                              pr_cdacesso => vr_cdacesso);
      
      -- Alterar registros
      IF pr_cddopcao = 'A' THEN
   
        BEGIN
          UPDATE crapprm
             SET dsvlrprm = pr_qtdiacor
           WHERE crapprm.nmsistem = 'CRED'
             AND crapprm.cdcooper = vr_cdcooper
             AND crapprm.cdacesso = 'PARLIM_QTDIACOR';
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao atualizar Quantidade de dias corridos: '||SQLERRM;
            RAISE vr_exc_erro;           
        END;
         
        BEGIN
          UPDATE crapprm
             SET dsvlrprm = pr_vlminchq
           WHERE crapprm.nmsistem = 'CRED'
             AND crapprm.cdcooper = vr_cdcooper
             AND crapprm.cdacesso = 'PARLIM_VLMINCHQ';
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao atualizar Valor min. para cobranca de juros de cheque especial: '||SQLERRM;
            RAISE vr_exc_erro;           
        END;
         
        BEGIN
          UPDATE crapprm
             SET dsvlrprm = pr_vlminiof
           WHERE crapprm.nmsistem = 'CRED'
             AND crapprm.cdcooper = vr_cdcooper
             AND crapprm.cdacesso = 'PARLIM_VLMINIOF';
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao atualizar o Valor min. para cobranca de IOF: '||SQLERRM;
            RAISE vr_exc_erro;           
        END;
     
        BEGIN
          UPDATE crapprm
             SET dsvlrprm = pr_vlminadp
           WHERE crapprm.nmsistem = 'CRED'
             AND crapprm.cdcooper = vr_cdcooper
             AND crapprm.cdacesso = 'PARLIM_VLMINADP';
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao atualizar o Valor min. para cobranca de juros de adiantamento a depositante: '||SQLERRM;
            RAISE vr_exc_erro;           
        END;                                   
        
      ELSIF pr_cddopcao = 'I' THEN -- Inclusão
       
         -- Inserir quantidade de dias corridos
         BEGIN 
           INSERT INTO crapprm(nmsistem, 
                               cdcooper, 
                               cdacesso, 
                               dstexprm, 
                               dsvlrprm)
                               VALUES(
                               'CRED'
                              ,vr_cdcooper
                              ,'PARLIM_QTDIACOR'
                              ,'Qtd. Dias corridos para cobrar na LAUTOM'
                              ,to_char(pr_qtdiacor));
         EXCEPTION 
           WHEN OTHERS THEN
             vr_dscritic:= 'Erro ao inserir Quantidade de dias corridos: '||SQLERRM;
             RAISE vr_exc_erro;           
         END;         
                   
         -- Inserir Valor min. para cobrança de juros de cheque especial
         BEGIN 
           INSERT INTO crapprm(nmsistem, 
                               cdcooper, 
                               cdacesso, 
                               dstexprm, 
                               dsvlrprm)
                               VALUES(
                               'CRED'
                              ,vr_cdcooper
                              ,'PARLIM_VLMINCHQ'
                              ,'Valor min. para cobranca de juros de cheque especial'
                              ,to_char(pr_vlminchq));
         EXCEPTION 
           WHEN OTHERS THEN
             vr_dscritic:= 'Erro ao inserir Valor min. para cobranca de juros de cheque especial: '||SQLERRM;
             RAISE vr_exc_erro;           
         END;    
         
         -- Inserir Valor min. para cobrança de IOF
         BEGIN 
           INSERT INTO crapprm(nmsistem, 
                               cdcooper, 
                               cdacesso, 
                               dstexprm, 
                               dsvlrprm)
                               VALUES(
                               'CRED'
                              ,vr_cdcooper
                              ,'PARLIM_VLMINIOF'
                              ,'Valor min. para cobrança de IOF'
                              ,to_char(pr_vlminiof));
         EXCEPTION 
           WHEN OTHERS THEN
             vr_dscritic:= 'Erro ao inserir Valor min. para cobranca de IOF: '||SQLERRM;
             RAISE vr_exc_erro;           
         END;     
                                    
         -- Inserir Valor min. para cobrança de juros de adiantamento a depositante
         BEGIN 
           INSERT INTO crapprm(nmsistem, 
                               cdcooper, 
                               cdacesso, 
                               dstexprm, 
                               dsvlrprm)
                               VALUES(
                               'CRED'
                              ,vr_cdcooper
                              ,'PARLIM_VLMINADP'
                              ,'Valor min. para cobranca de juros de adiantamento a depositante'
                              ,to_char(pr_vlminadp));
         EXCEPTION 
           WHEN OTHERS THEN
             vr_dscritic:= 'Erro ao inserir Valor min. para cobranca de juros de adiantamento a depositante: '||SQLERRM;
             RAISE vr_exc_erro;           
         END;     
      
      END IF;

      -- CA - Consulta da alteração, C - Consulta
      IF pr_cddopcao IN('CA','C') THEN
      
        -- Retorna o nome do cooperado      
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>' ||
                                          '<qtdiacor>' || nvl(vr_qtdiacor,0) || '</qtdiacor>'||
                                          '<vlminchq>' || to_char(vr_vlminchq,'fm999G999G990D00') || '</vlminchq>'||                                        
                                          '<vlminiof>' || to_char(vr_vlminiof,'fm999G999G990D00') || '</vlminiof>'||
                                          '<vlminadp>' || to_char(vr_vlminadp,'fm999G999G990D00') || '</vlminadp>'||
                                       '</Dados></Root>');

      END IF;
      
      IF pr_cddopcao = 'C' THEN
        vr_des_log := vr_dstransa || '.';
      ELSIF pr_cddopcao IN('A','I') THEN
        vr_des_log := vr_dstransa || ' --> ' || 'Qtd. Dias corridos DE: '  || 
                      nvl(vr_qtdiacor,0) || ' PARA: ' ||
                      nvl(pr_qtdiacor,0) || ', Vl. min. cobranca Chq. Esp. DE.: ' ||
                      nvl(vr_vlminchq,0) || ' PARA: ' ||
                      nvl(pr_vlminchq,0) || ', Vl. min. cobranca de IOF. DE.: ' ||
                      nvl(vr_vlminiof,0) || ' PARA: ' ||
                      nvl(pr_vlminiof,0) || ', Vl. min. cob adiantamento a dep. DE.: ' ||
                      nvl(vr_vlminadp,0) || ' PARA: ' ||
                      nvl(pr_vlminadp,0) || '.';
      END IF;
        
      -- Se não for consulta da alteração
      IF pr_cddopcao <> 'CA' THEN
        -- Logar na logtel como PARLIM.log
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_nmarqlog     => 'parlim.log'
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                      ' --> Operador ' || vr_cdoperad || ' - ' ||
                                                      vr_des_log);
      END IF;
      
      pr_des_erro := 'OK';            
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= nvl(vr_cdcritic,0);
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
        -- Logar na logtel como PARLIM.log
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_nmarqlog     => 'parlim.log'
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                      ' --> Operador ' || vr_cdoperad || ' - ' ||
                                                      vr_dstransa || ' --> ' || pr_dscritic);                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na TELA_PARLIM.pc_manter_rotina --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');        
        -- Logar na logtel como PARLIM.log
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_nmarqlog     => 'parlim.log'
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                      ' --> Operador ' || vr_cdoperad || ' - ' ||
                                                      vr_dstransa || ' --> ' || pr_dscritic);
  END pc_manter_rotina;

END TELA_PARLIM;
/
