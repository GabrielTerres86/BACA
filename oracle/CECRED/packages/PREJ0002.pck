CREATE OR REPLACE PACKAGE CECRED.PREJ0002 AS

/*..............................................................................

   Programa: PREJ0002                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Calão - Mout´S
   Data    : Agosto/2017                      Ultima atualizacao: 05/08/2017

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Centralizar os procedimentos e funcoes referente aos processos de 
               pagamentos (recuperação) de prejuizos

   Alteracoes:

..............................................................................*/

   TYPE typ_reg_log IS
      RECORD(valor_old crapprm.dsvlrprm%TYPE
            ,valor_new crapprm.dsvlrprm%TYPE);
   
    /* Pl-Table que ira chave e valor dos registros da CRAPPRM */
   TYPE typ_reg_consulta_prm IS
      RECORD(dsvlrprm crapprm.dsvlrprm%TYPE);
   
   TYPE typ_log           IS TABLE OF typ_reg_log          INDEX BY BINARY_INTEGER;         
   TYPE typ_verifica_log  IS TABLE OF typ_log              INDEX BY BINARY_INTEGER;
   TYPE typ_consulta_prm  IS TABLE OF typ_reg_consulta_prm INDEX BY BINARY_INTEGER;
   
    /* Realiza a gravação dos parametros da transferencia para prejuizo informados na tela PARTRP */
        
     /* Rotina para estornar pagamento prejuizo*/
     PROCEDURE pc_estorno_pagamento(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdconta in number
                                          ,pr_nrctremp in number
                                          ,pr_dtmvtolt in date
                                          ,pr_idtipo   in varchar2
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro  );
                                          
     /* rotina executada pela tela Atenda para "forçar" o envio de empréstimos para prejuízo */
     PROCEDURE pc_pagamento_prejuizo_web (pr_nrdconta   IN VARCHAR2     --> Conta corrente
                                         ,pr_nrctremp   IN VARCHAR2     --> Contrato de emprestimo
                                         ,pr_vlpagmto   in varchar2     --> valor do pagamento
                                         ,pr_vldabono   in varchar2     --> valor de abono
                                         ,pr_xmllog     IN VARCHAR2     --> XML com informações de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER  --> Código da crítica
                                         ,pr_dscritic  OUT VARCHAR2     --> Descrição da crítica
                                         ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2     --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);      
     
     /* Rotina chamada pela Atenda para estornar (desfazer) o prejuízo */                                    
     PROCEDURE pc_estorno_pagamento_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_nrctremp   IN VARCHAR2  -- contrato
                                        ,pr_dtmvtolt   in varchar2
                                        ,pr_idtipo     in varchar2
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2)  ;    
     
     /* Rotina chamada pela Atenda para transferir prejuizos de CC */                                   
    /* PROCEDURE pc_pagamento_prejuizo_CC_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);    
     */
     PROCEDURE pc_consulta_pagamento_web(pr_dtpagto in varchar2
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
              						 		 			  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
 				    	          	 		 			  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
						    				         			,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
          			    									,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					              							,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
										              		,pr_des_erro OUT VARCHAR2);                                                                           
                                                              
    PROCEDURE pc_valores_contrato_web(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);  
end PREJ0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0002 AS
/*..............................................................................

   Programa: PREJ0002                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Calão - Mout´S
   Data    : Maio/2017                      Ultima atualizacao: 28/05/2017

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Centralizar os procedimentos e funcoes referente aos processos de 
               transferência para prejuízo

   Alteracoes:

..............................................................................*/

    vr_cdcritic             number(3);
    vr_dscritic             varchar2(1000);
    vr_des_reto             varchar2(10);
    vr_tab_erro             gene0001.typ_tab_erro ;
    
    gl_nrdolote             number;
   
    rw_crapdat              btch0001.cr_crapdat%rowtype;                                                
      
   CURSOR C_CRAPEPR(pr_cdcooper in number
                   ,pr_nrdconta in number
                   ,pr_nrctremp in number) IS
               SELECT * FROM crapepr
               WHERE crapepr.cdcooper = pr_cdcooper
                 AND crapepr.nrdconta = pr_nrdconta
                 AND crapepr.nrctremp = pr_nrctremp;

             R_crapepr C_CRAPEPR%ROWTYPE;      
                       
        
     /* Rotina para estornar pagamento de  prejuizo PP, TR e CC */
    PROCEDURE pc_estorno_pagamento(pr_cdcooper in number
                                  ,pr_cdagenci in number
                                  ,pr_nrdconta in number
                                  ,pr_nrctremp in number
                                  ,pr_dtmvtolt in date
                                  ,pr_idtipo in varchar2
                                  ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                  ,pr_tab_erro OUT gene0001.typ_tab_erro) IS
        
          rw_crapdat btch0001.cr_crapdat%rowtype;
          vr_vlsdprej NUMBER;
          vr_vlttmupr NUMBER;
          vr_vlttjmpr NUMBER;
          vr_erro     exception;
          vr_dscritic varchar2(1000);
          vr_cdcritic integer;
          vr_nrdrowid rowid;
          vr_dstransa varchar2(2000);
          vr_cdhistor number(4);
         
          cursor c_busca_prx_lote(pr_dtmvtolt date
                         ,pr_cdcooper number
                         ,pr_cdagenci number) is
        select max(nrdolote) nrdolote
          from craplot
         where craplot.dtmvtolt = pr_dtmvtolt
           and craplot.cdcooper = pr_cdcooper
           and craplot.cdagenci = pr_cdagenci
           --and craplot.cdbccxlt = 100 -- rmm
           --and craplot.tplotmov = 1 -- rmm
           ;

          
          vr_nrdolote number;
     
     cursor c_craplem (pr_cdcooper craplem.cdcooper%type
                      ,pr_nrdconta craplem.nrdconta%type
                      ,pr_nrctremp craplem.nrctremp%type) is
          select * 
            from craplem lem
           where lem.cdcooper = pr_cdcooper
             and lem.nrdconta = pr_nrdconta
             and lem.nrctremp = pr_nrctremp
             and lem.dtmvtolt = pr_dtmvtolt -- somente pode estonar dentro do mes
             and lem.cdhistor = decode(pr_idtipo, 'PP',2388,'TR',2388,'CC',2388,2391)
            ; -- Recuperacao de prejuizo  
             
     cursor c_craplem2 (pr_cdcooper craplem.cdcooper%type
                      ,pr_nrdconta craplem.nrdconta%type
                      ,pr_nrctremp craplem.nrctremp%type) is
          select * 
            from craplem lem
           where lem.cdcooper = pr_cdcooper
             and lem.nrdconta = pr_nrdconta
             and lem.nrctremp = pr_nrctremp
             and lem.dtmvtolt >= trunc(rw_crapdat.dtmvtolt,'MM') -- somente pode estonar dentro do mes
             and lem.cdhistor = 2392; -- Estorno de pagamento
         
         r_craplem2 c_craplem2%rowtype;
         
     begin
          
          open btch0001.cr_crapdat(pr_cdcooper);
          fetch btch0001.cr_crapdat into rw_crapdat;
          close btch0001.cr_crapdat;
          
          open c_crapepr(pr_cdcooper, pr_nrdconta, pr_nrctremp);
          fetch c_crapepr into r_crapepr;
          close c_crapepr;
          
          if nvl(r_crapepr.inprejuz,0) = 0 then
              vr_dscritic := 'Não é permitido estorno, conta corrente não está em prejuízo: ' || pr_nrdconta;
                raise vr_erro;
          end if;
          
          /*\* Verifica se já foi realizado estorno *\
          open c_craplem2(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctremp => pr_nrctremp);
          fetch c_craplem2 into r_craplem2;
          if c_craplem2%found then
             vr_dscritic := 'Estorno já efetuado para a conta: ' || pr_nrdconta;
             raise vr_erro;          
          end if;
          close c_craplem2;*/
          
          FOR r_craplem in c_craplem(pr_cdcooper => pr_cdcooper
                                    , pr_nrdconta => pr_nrdconta
                                    , pr_nrctremp => pr_nrctremp) LOOP
              
                                            
            IF r_craplem.dtmvtolt = rw_crapdat.dtmvtolt THEN
              /* 1) Excluir Lancamento LEM */
              BEGIN
                delete from craplem t
                where t.cdcooper = pr_cdcooper
                and   t.nrdconta = pr_nrdconta
                and   t.nrctremp = pr_nrctremp
                and   t.cdhistor in (2388, 2473, 2390, 2475,2391) --decode(pr_idtipo, 'PP',2388,'TR',2388,'CC',2388,2391) --Recuperacao de prejuizo
                and   t.dtmvtolt = pr_dtmvtolt;
              EXCEPTION
                When others then
                    vr_dscritic := 'Erro na exclusao CRAPLEM, cooper: ' || pr_cdcooper || 
                                   ', conta: ' || pr_nrdconta;
                    raise vr_erro;               
              END;
              /* excluir lancamento LCM */
              BEGIN
                delete from craplcm t
                where t.cdcooper = pr_cdcooper
                and   t.nrdconta = pr_nrdconta
                and   t.cdhistor = 2386
                and   t.cdbccxlt = 100
                and   t.dtmvtolt = rw_crapdat.dtmvtolt;
              EXCEPTION
                When others then
                    vr_dscritic := 'Erro na exclusao CRAPLCM, cooper: ' || pr_cdcooper || 
                                   ', conta: ' || pr_nrdconta;
                    raise vr_erro ;              
              END;

            ELSE
              IF pr_idtipo in ('PP','TR','CC') THEN
                 vr_cdhistor := 2392;
              ELSE
                 vr_cdhistor := 2395;
              END IF;
                  
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => r_craplem.cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => '1'
                                             ,pr_cdpactra => r_craplem.cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => r_craplem.vllanmto
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => r_craplem.nrdocmto
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                                               
                  IF vr_dscritic is not null THEN
                    vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor principal): ' || vr_dscritic;
                    pr_des_reto := 'NOK';
                    raise vr_erro;
                  END IF;
                      
                  -- atualiza lote
                  begin     
                     update craplot 
                       set  craplot.nrseqdig = craplot.nrseqdig + 1
                           ,craplot.vlcompcr = craplot.vlcompcr + r_craplem.vllanmto
                           ,craplot.vlcompdb = craplot.vlcompdb + r_craplem.vllanmto
                      where craplot.cdcooper = pr_cdcooper
                      and   craplot.cdbccxlt = 100
                      and   craplot.dtmvtolt = rw_crapdat.dtmvtolt
                      and   craplot.cdagenci = r_craplem.cdagenci
                      and   craplot.nrdolote = 600029
                      and   craplot.tplotmov = 5;
                  exception
                     when others then
                         vr_dscritic := 'Erro ao atualizar lote: ' || sqlerrm;
                         pr_des_reto := 'NOK';
                  end;
              -- cria lancamento LCM
                   if gl_nrdolote is null then 
                      open  c_busca_prx_lote(pr_dtmvtolt => RW_CRAPDAT.DTMVTOLT
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdagenci => r_craplem.cdagenci);
                      fetch c_busca_prx_lote into vr_nrdolote;
                      close c_busca_prx_lote;
                                          
                      vr_nrdolote := nvl(vr_nrdolote,0) + 1;
                      gl_nrdolote := vr_nrdolote;
                    else
                      vr_nrdolote := gl_nrdolote;
                    end if;     
                    
              if r_craplem.cdhistor= 2388 then          
                 empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper 
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => r_craplem.cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => user
                                             ,pr_cdpactra => r_craplem.cdagenci
                                             ,pr_nrdolote => vr_nrdolote
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => 2387
                                             ,pr_vllanmto => r_craplem.vllanmto
                                             ,pr_nrparepr => 1
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_nrseqava => 0
                                             ,pr_idlautom => 0 
                                             ,pr_des_reto => vr_des_reto
                                             ,pr_tab_erro => vr_tab_erro );
                                                           
                IF vr_des_reto <> 'OK' THEN
                  IF vr_tab_erro.count() > 0 THEN -- RMM
                    -- Atribui críticas às variaveis
                    vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                    vr_dscritic := 'Erro estorno Pagamento '||vr_tab_erro(vr_tab_erro.first).dscritic;
                    RAISE vr_erro;
                  ELSE
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao Estornar Pagamento '||sqlerrm;
                    raise vr_erro;
                  END IF;                      
                END IF;
              end if;
            END IF;
            -- inicio rmm
            FOR rw_crapepr IN c_crapepr(pr_cdcooper, pr_nrdconta, pr_nrctremp) LOOP
             
              rw_crapepr.vlsdprej := r_craplem.vllanmto + rw_crapepr.vlsdprej;
              
              IF (rw_crapepr.vlprejuz + 
                  rw_crapepr.vlttmupr + 
                  rw_crapepr.vlttjmpr) = rw_crapepr.vlsdprej THEN
                 rw_crapepr.vlsdprej := rw_crapepr.vlsdprej - rw_crapepr.vlttmupr - rw_crapepr.vlttjmpr;
                 vr_vlttmupr := 0;
                 vr_vlttjmpr := 0;
              ELSE
                vr_vlttmupr := rw_crapepr.vlpgmupr;
                vr_vlttjmpr := rw_crapepr.vlpgjmpr;                 
              END IF;
                 
              /* Atualiza CRAPEPR com o valor do lançamento */
              BEGIN
                UPDATE crapepr c
                   --SET vlsdprej = vlsdprej + r_craplem.vllanmto
                   SET c.vlsdprej = nvl(rw_crapepr.vlsdprej,0)  --vlsdprej - vr_vldescto - nvl(pr_vldabono,0)
                      ,c.vlpgjmpr = vr_vlttjmpr --abs(nvl(c.vlpgjmpr,0) - nvl(vr_vlttjmpr,0))
                      ,c.vlpgmupr = vr_vlttmupr --abs(nvl(c.vlpgmupr,0) - nvl(vr_vlttmupr,0))
                 WHERE c.nrdconta = pr_nrdconta
                   AND c.nrctremp = pr_nrctremp
                   AND c.cdcooper = pr_cdcooper;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'erro ao atualizar emprestimo para estorno: ' || sqlerrm;
                  pr_des_reto := 'NOK';
                  RAISE vr_erro;
              END;
            END LOOP;
             -- fim rmm
          END LOOP;
          COMMIT;
    exception
       when vr_erro then
                     -- Desfazer alterações
           ROLLBACK;
           if vr_dscritic is null then
              vr_dscritic := 'Erro na rotina pc_estorno_pagamento: '; 
           end if;
           
           -- Retorno não OK
           GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                               ,pr_cdoperad => 'PROCESSO'
                               ,pr_dscritic => vr_dscritic
                               ,pr_dsorigem => 'INTRANET'
                               ,pr_dstransa => 'PREJ0002-Estorno pagamento.'
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 0 --> ERRO/FALSE
                               ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                               ,pr_idseqttl => 1
                               ,pr_nmdatela => 'crps780'
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrdrowid => vr_nrdrowid);
          -- Commit do LOG
          COMMIT;
       when others then
          ROLLBACK;
           if vr_dscritic is null then
              vr_dscritic := 'Erro geral rotina pc_estorno_pagamento: ' || sqlerrm; 
           end if;
           
           -- Retorno não OK
           GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                               ,pr_cdoperad => 'PROCESSO'
                               ,pr_dscritic => vr_dscritic
                               ,pr_dsorigem => 'INTRANET'
                               ,pr_dstransa => 'PREJ0002-Estorno pagamento.'
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 0 --> ERRO/FALSE
                               ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                               ,pr_idseqttl => 1
                               ,pr_nmdatela => 'crps780'
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrdrowid => vr_nrdrowid);
          -- Commit do LOG
          COMMIT;
    end pc_estorno_pagamento;
    
    
    PROCEDURE pc_pagamento_prejuizo_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_nrctremp   IN VARCHAR2  -- contrato
                                        ,pr_vlpagmto   in varchar2 -- valor do pagamento
                                        ,pr_vldabono   in varchar2 -- valor do abono
                                        ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic   OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2) IS         --> Erros do processo

     /* .............................................................................

      Programa: pc_transfere_prejuizo_web
      Sistema : AyllosWeb
      Sigla   : PREJ
      Autor   : Jean Calão - Mout´S
      Data    : Agosto/2017.                  Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua o pagamento de prejuizos de contratos PP e TR (força o pagamento envio)
      Observacao: Rotina chamada pela tela PAGPRJ opçao "Forçar pagamento prejuizo emprestimo"

      Alteracoes:

     ..............................................................................*/
     -- Variáveis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_nmeacao          VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);
     
     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(500);
     vr_cddepart    number(3);
     vr_tpemprst    integer;
     vr_inprejuz    integer;
     vr_vlsdprej    number;
     
     -- Excessões
     vr_exc_erro         EXCEPTION;
     
     cursor cr_crapope is
        select t.cddepart
        from   crapope t
        where  t.cdoperad = vr_cdoperad;
     --
     CURSOR cr_crapace(pr_cdcooper IN crapace.cdcooper%TYPE
                      ,pr_cdoperad IN crapace.cdoperad%TYPE
                      ,pr_nmdatela IN crapace.nmdatela%TYPE
                      ,pr_nmrotina IN crapace.nmrotina%TYPE
                      ,pr_cddopcao IN crapace.cddopcao%TYPE) IS
       SELECT ce.nmdatela
         FROM crapace ce
        WHERE ce.cdcooper        = pr_cdcooper
          AND UPPER(ce.cdoperad) = UPPER(pr_cdoperad)
          AND UPPER(ce.nmdatela) = UPPER(pr_nmdatela)
          --AND UPPER(ce.nmrotina) = UPPER(pr_nmrotina)
          AND UPPER(ce.cddopcao) = UPPER(pr_cddopcao)
          AND ce.idambace        = 2;        
         
   BEGIN
      
     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

      -- Validar permissao do operador para inserir valor de abono
      IF NVL(pr_vldabono,0) > 0 THEN
        -- Verifica as permissões de execução no cadastro
        OPEN cr_crapace(vr_cdcooper, --pr_cdcooper, 
                        vr_cdoperad, --pr_cdoperad, 
                        'PAGPRJ',--pr_nmdatela, 
                        NULL, --pr_nmrotina, 
                        'A' --pr_cddopcao -- OPCAO ABONO
                        );
        FETCH cr_crapace INTO vr_nmdatela;
        -- Verifica se foi encontrada permissão para Pagamento de Abono
        IF cr_crapace%NOTFOUND THEN
          CLOSE cr_crapace;
          -- 036 - Operacao nao autorizada.
          pr_cdcritic := 36;
          pr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)||' Operador não possui privilégio para inserir abono';
          raise vr_exc_erro;
        ELSE
          CLOSE cr_crapace; 
        END IF;
      END IF;

      open cr_crapope;
      fetch cr_crapope into vr_cddepart;
      close cr_crapope;
          
      --if vr_cddepart not in (3,9,20) then
      --   pr_des_erro := 'Acesso não permitido ao usuário!';
      --   raise vr_exc_erro;
      --end if;
      
      /* Busca data de movimento */
      open btch0001.cr_crapdat(vr_cdcooper);
      fetch btch0001.cr_crapdat into rw_crapdat;
      close btch0001.cr_crapdat;
      
      /*Busca informações do emprestimo */
      open c_crapepr(pr_cdcooper => vr_cdcooper
                       , pr_nrdconta => pr_nrdconta
                       , pr_nrctremp => pr_nrctremp);
      
      fetch c_crapepr into r_crapepr;
      if c_crapepr%found then
         vr_tpemprst := r_crapepr.tpemprst;
         vr_inprejuz := r_crapepr.inprejuz;
         vr_vlsdprej := nvl(r_crapepr.vlsdprej,0) + nvl(r_crapepr.vlttmupr,0) + nvl(r_crapepr.vlttjmpr,0);
      else   
         vr_tpemprst := null;
      end if;
      close c_crapepr;
      
      /* Gerando Log de Consulta */
      vr_dstransa := 'PREJ0002-Realizando pagamento de contrato de prejuizo, Cooper: ' || vr_cdcooper || 
                      ' Conta: ' || pr_nrdconta || ', Contrato: ' || pr_nrctremp || ' Tipo: '
                       || r_crapepr.tpemprst || ' Data: ' || to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY') ||
                       ', Vlr Pagto: ' || pr_vlpagmto || ', Vlr abono: ' || pr_vldabono;
      
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      
      
      if nvl(vr_inprejuz,2) = 1 then
         
         if vr_vlsdprej > 0 then   
             pc_crps780_1(pr_cdcooper => vr_cdcooper,
                          pr_nrdconta => pr_nrdconta,
                          pr_nrctremp => pr_nrctremp,
                          pr_vlpagmto => pr_vlpagmto,
                          pr_vldabono => pr_vldabono,
                          pr_cdagenci => 1,
                          pr_cdoperad => vr_cdoperad,
                          pr_cdcritic => vr_cdcritic,
                          pr_dscritic => vr_dscritic);   
             if vr_dscritic is not null then    
               pr_des_erro := 'Erro no pagamento: ' || vr_dscritic;
               raise vr_exc_erro;
             end if;
         else
            pr_des_erro := 'Não existe saldo de prejuízo à pagar!';
            raise vr_exc_erro;
         end if;                        
         
      else
         pr_des_erro := 'Contrato não está em prejuízo!';
         raise vr_exc_erro;
      end if;
       
      if vr_des_reto <> 'OK' then
         pr_des_erro := 'Erro no pagamento do prejuizo: ' || sqlerrm;
         raise vr_exc_erro;
      end if;
 
      vr_dstransa := 'PREJ0002-Pagamento de prejuizo, referente contrato: ' || pr_nrctremp ||
                     ', realizado com sucesso.'; 
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
   EXCEPTION
     WHEN vr_exc_erro THEN
       -- Desfazer alterações
       ROLLBACK;
       if pr_des_erro is null then
          pr_des_erro := 'Erro na rotina pc_transfere_prejuizo: '; 
       end if;
       pr_dscritic := pr_des_erro;
       -- Retorno não OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => 'INTRANET'
                           ,pr_dstransa => 'PREJ0002-Pagamento forçado de prejuizo.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' || 
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN OTHERS THEN
       -- Desfazer alterações
       ROLLBACK;
       pr_des_erro := 'Erro geral na rotina pc_transfere_prejuizo: '|| SQLERRM;
       pr_dscritic := pr_des_erro;
       pr_cdcritic := 0;
       pr_nmdcampo := '';
       -- Retorno não OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'PREJ0002-Transferência Prejuízo.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
       -- Commit do LOG
       COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' || 
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
      
   END pc_pagamento_prejuizo_web;

   PROCEDURE pc_estorno_pagamento_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_nrctremp   IN VARCHAR2  -- contrato
                                        ,pr_dtmvtolt   in varchar2
                                        ,pr_idtipo     in varchar2
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

     /* .............................................................................

      Programa: pc_estorno_prejuizo_web
      Sistema : AyllosWeb
      Sigla   : PREJ
      Autor   : Jean Calão - Mout´S
      Data    : Maio/2017.                  Ultima atualizacao: 29/05/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua o estorno de transferencias de contratos PP e TR para prejuízo 
      Observacao: Rotina chamada pela tela Atenda / Prestações, botão "Desfazer Prejuízo"
                  Também é chamada pela tela ESTPRJ (Estorno de prejuízos).

      Alteracoes:

     ..............................................................................*/
     -- Variáveis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_nmeacao          VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);
     
     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(500);
     vr_cddepart    number(3);
     vr_tpemprst    integer;
     vr_inprejuz    integer;
     
     -- Excessões
     vr_exc_erro         EXCEPTION;
     
     cursor cr_crapope is
        select t.cddepart
        from   crapope t
        where  t.cdoperad = vr_cdoperad;
        
     cursor c_busca_abono is
        select 1
        from   craplem lem
        where  lem.cdcooper = vr_cdcooper
        and    lem.nrdconta = pr_nrdconta
        and    lem.nrctremp = pr_nrctremp
        and    lem.dtmvtolt > rw_crapdat.dtultdma
        and    lem.dtmvtolt <= rw_crapdat.dtultdia
        and    lem.cdhistor = 2391
        and not exists (select 1 from craplem t
                           where t.dtmvtolt > lem.dtmvtolt
                             and t.cdcooper = lem.cdcooper
                             and t.nrdconta = lem.nrdconta
                             and t.nrctremp = lem.nrctremp
                             and t.nrparepr = lem.nrdocmto
                             and t.cdhistor = 2395); -- abono
        
        
        vr_existe_abono integer := 0;
         
   BEGIN
      
     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);
      open cr_crapope;
      fetch cr_crapope into vr_cddepart;
      close cr_crapope;
      
      --if vr_cddepart not in (3,9,20) then
      --   pr_des_erro := 'Acesso não permitido ao usuário!';
      --   raise vr_exc_erro;
      --end if;
      /* Busca data de movimento */
      open btch0001.cr_crapdat(vr_cdcooper);
      fetch btch0001.cr_crapdat into rw_crapdat;
      close btch0001.cr_crapdat;
      
      /*Busca informações do emprestimo */
      open c_crapepr(pr_cdcooper => vr_cdcooper
                       , pr_nrdconta => pr_nrdconta
                       , pr_nrctremp => pr_nrctremp);
      
      fetch c_crapepr into r_crapepr;
      if c_crapepr%found then
         vr_tpemprst := r_crapepr.tpemprst;
         vr_inprejuz := r_crapepr.inprejuz;
      else   
         vr_tpemprst := null;
      end if;
      close c_crapepr;
      
      if to_char(to_date(pr_dtmvtolt,'dd/mm/yyyy'),'yyyymm') < to_char(rw_crapdat.dtmvtolt,'yyyymm') then
         pr_des_erro := 'Impossivel fazer estorno do contrato, pois este pagamento/abono foi feito antes do mes vigente';
         raise vr_exc_erro;
      end if;
      
      /* Verifica se possui abono ativo, não pode efetuar o estorno do pagamento */
      open c_busca_abono;
      fetch c_busca_abono into vr_existe_abono;
      close c_busca_abono;
      
      if nvl(vr_existe_abono,0) = 1 then
         if pr_idtipo not in ('PA','TA','CA') then
             pr_des_erro := 'Não é permitido efetuar o estorno do pagamento pois existe um lançamento de abono.';
             raise vr_exc_erro;
         end if;  
      end if;
      
      /* Gerando Log de Consulta */
      vr_dstransa := 'PREJ0002-Efetuando estorno da transferencia para prejuizo, Cooper: ' || vr_cdcooper || 
                      ' Conta: ' || pr_nrdconta || ', Contrato: ' || pr_nrctremp || ' Tipo: '
                       || r_crapepr.tpemprst || ', Data: ' || pr_dtmvtolt || ', indicador: ' || pr_idtipo ;
                     
      
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      
      if nvl(vr_inprejuz,2) = 1 then
         pc_estorno_pagamento(pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_dtmvtolt => to_date(pr_dtmvtolt,'dd/mm/yyyy')
                                ,pr_idtipo => pr_idtipo
                                ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                ,pr_tab_erro => vr_tab_erro);
      else
         pr_des_erro := 'Contrato não está em prejuízo !';
         raise vr_exc_erro;
      end if;
       
      if vr_des_reto <> 'OK' then
         pr_des_erro := 'Erro no estorno da transferencia de prejuizo: ' || vr_des_reto;
         raise vr_exc_erro;
      end if;
 
      vr_dstransa := 'PREJ0002-Estorno da transferência para prejuizo, referente contrato: ' || pr_nrctremp ||
                     ', realizada com sucesso.'; 
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
   EXCEPTION
     WHEN vr_exc_erro THEN
       -- Desfazer alterações
       ROLLBACK;
       if pr_des_erro is null then
          pr_des_erro := 'Erro na rotina pc_estorno_prejuizo: '; 
       end if;
       pr_dscritic := pr_des_erro;
       -- Retorno não OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => 'INTRANET'
                           ,pr_dstransa => 'PREJ0002-Estorno transferencia para prejuizo.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' || 
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     WHEN OTHERS THEN
       -- Desfazer alterações
       ROLLBACK;
       pr_des_erro := 'Erro geral na rotina pc_estorno_prejuizo: '|| SQLERRM;
       pr_dscritic := pr_des_erro;
       pr_cdcritic := 0;
       pr_nmdcampo := '';
       -- Retorno não OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'PREJ0002-Estorno da Transferência Prejuízo.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
       -- Commit do LOG
       COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' || 
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
      
   END pc_estorno_pagamento_web;
   
   PROCEDURE pc_consulta_pagamento_web(pr_dtpagto  in varchar2
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
              						 		 			  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
 				    	          	 		 			  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
						    				         			,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
          			    									,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					              							,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
										              		,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_consulta_pagamento_web
     Sistema : Rotinas referentes a pagamento de transferencia para prejuizo
     Sigla   : PREJ
     Autor   : Jean Calão (Mout´S)
     Data    : Ago/2017.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para consultar os estornos

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor dos pagamentos
      CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_dtpagto  craplem.dtmvtolt%type 
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crapepr.nrctremp%type) IS
     -- RMM
       SELECT epr.tpemprst, epr.cdcooper, epr.nrdconta, epr.nrctremp, epr.cdlcremp, lem.dtmvtolt, lem.vllanmto, lem.cdhistor
         FROM crapepr epr, 
              craplem lem
        WHERE lem.cdcooper = epr.cdcooper
          and lem.nrdconta = epr.nrdconta
          and lem.nrctremp = epr.nrctremp
          and lem.dtmvtolt = nvl(pr_dtpagto, lem.dtmvtolt)
          and lem.cdhistor = 2388 --pagamento prejuizo
          and epr.cdcooper = pr_cdcooper
          --AND epr.dtprejuz = nvl(pr_dtprejuz, epr.dtprejuz)
          and epr.nrdconta = decode(pr_nrdconta, 0, epr.nrdconta, pr_nrdconta)
          and epr.nrctremp = decode(pr_nrctremp, 0, epr.nrctremp, pr_nrctremp)
          and not exists (select 1 from craplem t
                           where t.dtmvtolt > lem.dtmvtolt
                             and t.cdcooper = lem.cdcooper
                             and t.nrdconta = lem.nrdconta
                             and t.nrctremp = lem.nrctremp
                             and t.nrparepr = lem.nrdocmto
                             and t.cdhistor = 2392 ) -- estorno pgto
          and epr.inprejuz = 1
          UNION
       SELECT epr.tpemprst, epr.cdcooper, epr.nrdconta, epr.nrctremp, epr.cdlcremp, lem.dtmvtolt, lem.vllanmto, lem.cdhistor
         FROM crapepr epr, 
              craplem lem
        WHERE lem.cdcooper = epr.cdcooper
          and lem.nrdconta = epr.nrdconta
          and lem.nrctremp = epr.nrctremp
          and lem.dtmvtolt = nvl(pr_dtpagto, lem.dtmvtolt)
          and lem.cdhistor = 2391 --abono
          and epr.cdcooper = pr_cdcooper
          --AND epr.dtprejuz = nvl(pr_dtprejuz, epr.dtprejuz)
          and epr.nrdconta = decode(pr_nrdconta, 0, epr.nrdconta, pr_nrdconta)
          and epr.nrctremp = decode(pr_nrctremp, 0, epr.nrctremp, pr_nrctremp)
          and not exists (select 1 from craplem t
                           where t.dtmvtolt > lem.dtmvtolt
                             and t.cdcooper = lem.cdcooper
                             and t.nrdconta = lem.nrdconta
                             and t.nrctremp = lem.nrctremp
                             and t.nrparepr = lem.nrdocmto
                             and t.cdhistor = 2395) -- estorno abono
          and epr.inprejuz = 1          
          
          ;     
  /*     SELECT epr.tpemprst, epr.cdcooper, epr.nrdconta, epr.nrctremp, epr.cdlcremp, lem.dtmvtolt, lem.vllanmto, lem.cdhistor
         FROM crapepr epr, craplem lem
        WHERE lem.cdcooper = epr.cdcooper
          and lem.nrdconta = epr.nrdconta
          and lem.nrctremp = epr.nrctremp
          and lem.dtmvtolt = nvl(pr_dtpagto, lem.dtmvtolt)
          and lem.cdhistor in ( 2388, 2391) -- pagamento prejuizo / abono
          and epr.cdcooper = pr_cdcooper
          --AND epr.dtprejuz = nvl(pr_dtprejuz, epr.dtprejuz)
          and epr.nrdconta = decode(pr_nrdconta, 0, epr.nrdconta, pr_nrdconta)
          and epr.nrctremp = decode(pr_nrctremp, 0, epr.nrctremp, pr_nrctremp)
          and not exists (select 1 from craplem t
                           where t.dtmvtolt > lem.dtmvtolt
                             and t.cdcooper = lem.cdcooper
                             and t.nrdconta = lem.nrdconta
                             and t.nrctremp = lem.nrctremp
                             and t.cdhistor in ( 2392, 2395)) -- estorno pgto, estorno abono
          and epr.inprejuz = 1;*/
          
        rw_crapepr cr_crapepr%rowtype;
        
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_contador      PLS_INTEGER := 0;
      vr_idtipo        varchar2(2);
      vr_dstipo        varchar2(25);
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_dstransa        varchar2(200);
      vr_dsorigem    VARCHAR2(100);
      vr_nrdrowid    ROWID;
    BEGIN
      
     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);


  
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => vr_cdcooper,
                                   pr_dtpagto =>  to_date(pr_dtpagto,'dd/mm/yyyy'),
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp) LOOP
        
         if rw_crapepr.tpemprst = 1 then
             if rw_crapepr.cdhistor = 2388 then -- pagamento
                vr_idtipo := 'PP';            
                vr_dstipo := 'Pgto-Empréstimo PP';
             else
                vr_idtipo := 'PA';            
                vr_dstipo := 'Abono-Empréstimo PP'; 
             end if;
          end if;   
          
          if rw_crapepr.tpemprst = 0 then
             if rw_crapepr.cdhistor = 2388 then -- pagamento
                vr_idtipo := 'TR';
                vr_dstipo := 'Pgto-Empréstimo TR';
             else
                vr_idtipo := 'TA';
                vr_dstipo := 'Abono-Empréstimo TR';
             end if;
          end if;   
          
          if  rw_crapepr.nrdconta = rw_crapepr.nrctremp
          and rw_crapepr.cdlcremp = 100 then
              if rw_crapepr.cdhistor = 2388 then
                 vr_idtipo := 'CC';
                 vr_dstipo := 'Pgto-Conta corrente';
              else
                 vr_idtipo := 'CA';
                 vr_dstipo := 'Abono-Conta corrente';
              end if;
          end if;     
          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtpagto', pr_tag_cont => to_char(rw_crapepr.dtmvtolt,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapepr.nrdconta, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => rw_crapepr.nrctremp, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlemprst', pr_tag_cont => rw_crapepr.vllanmto, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idtipo', pr_tag_cont => vr_idtipo, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstipo', pr_tag_cont => vr_dstipo, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;

      END LOOP; /* END FOR rw_tbepr_estorno */

      IF vr_contador <= 0 THEN
        vr_dscritic := 'Não existem pagamentos gerados para a conta / contrato informado.';
        RAISE vr_exc_saida;

      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PREJ0002.pc_consulta_pagamentos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                       
         -- gravar LOG de teste
      
     vr_dstransa := 'Consulta pagamentos: ' || pr_dtpagto || ', conta: ' ||
                     pr_nrdconta || ', contrato: ' || pr_nrctremp;
                     
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => PR_NRDCONTA
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
     
    END;

  END pc_consulta_pagamento_web;
  
    PROCEDURE pc_valores_contrato_web(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_consulta_pagamento_web
     Sistema : Rotinas referentes a pagamento de transferencia para prejuizo
     Sigla   : PREJ
     Autor   : Jean Calão (Mout´S)
     Data    : Ago/2017.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para consultar os estornos

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor dos pagamentos
      CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crapepr.nrctremp%type) IS
       SELECT epr.tpemprst,
              epr.cdcooper,
              epr.nrdconta,
              epr.nrctremp,
              epr.cdlcremp,
              epr.vlsdprej,
              epr.vlpgmupr,
              epr.vlpgjmpr,
              epr.vlttmupr,
              epr.vlttjmpr
         FROM crapepr epr
        WHERE epr.cdcooper = pr_cdcooper
          and epr.nrdconta = pr_nrdconta
          and epr.nrctremp = pr_nrctremp
          and epr.inprejuz = 1;
        rw_crapepr cr_crapepr%rowtype;
        
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_contador      PLS_INTEGER := 0;
      vr_idtipo        varchar2(2);
      vr_dstipo        varchar2(25);
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_dstransa        varchar2(200);
      vr_dsorigem    VARCHAR2(100);
      vr_nrdrowid    ROWID;
    BEGIN
      
     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);


  
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      

      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => vr_cdcooper, -- alterar apos teste                                 
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp) LOOP
          rw_crapepr.vlttmupr := rw_crapepr.vlttmupr - nvl(rw_crapepr.vlpgmupr,0);
          rw_crapepr.vlttjmpr := rw_crapepr.vlttjmpr - nvl(rw_crapepr.vlpgjmpr,0);
          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapepr.nrdconta, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => rw_crapepr.nrctremp, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlsdprej', pr_tag_cont => replace(rw_crapepr.vlsdprej,'.',','), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlttmupr', pr_tag_cont => replace(rw_crapepr.vlttmupr,'.',','), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlttjmpr', pr_tag_cont => replace(rw_crapepr.vlttjmpr,'.',','), pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;

      END LOOP; /* END FOR rw_tbepr_estorno */

      IF vr_contador <= 0 THEN
        vr_dscritic := 'Nao existe pagamentos gerado para a conta informada.';
        RAISE vr_exc_saida;

      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PREJ0002.pc_valores_contrato: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                       
         -- gravar LOG de teste
      
  /*   vr_dstransa := 'Consulta pagamentos: ' || pr_dtpagto || ', conta: ' ||
                     pr_nrdconta || ', contrato: ' || pr_nrctremp;
                     
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => PR_NRDCONTA
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;*/
     
    END;

  END pc_valores_contrato_web;
  
END PREJ0002;
/
