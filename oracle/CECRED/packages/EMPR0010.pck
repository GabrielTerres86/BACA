CREATE OR REPLACE PACKAGE CECRED.EMPR0010 IS

  PROCEDURE pc_solicitar_emprestimo (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Agencia
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE --> Caixa
                                    ,pr_cdoperad  IN craplot.cdoperad%TYPE --> Operador
                                    ,pr_cddcanal  IN tbgen_canal_entrada.cdcanal%TYPE --> Flag Mobile
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta
                                    ,pr_idseqttl  IN crapttl.idseqttl%tYPE --> Titularidade
                                    ,pr_dsdemail  IN VARCHAR2              --> Email
                                    ,pr_qtparcel  IN NUMBER                --> Quantidade de parcelas
                                    ,pr_vlemprst  IN NUMBER                --> Valor do empréstimo
                                    ,pr_dsmensag  IN VARCHAR2              --> Mensagem
                                    ,pr_flgderro OUT VARCHAR2              --> Indicador de erro
                                    ,pr_dsmsgsai OUT VARCHAR2);            --> Mensagem de saída

END EMPR0010;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0010 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0010
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : David Giovanni Kistner
  --  Data     : Abril - 2017                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Solicitação de Empréstimo
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_solicitar_emprestimo (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Agencia
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE --> Caixa
                                    ,pr_cdoperad  IN craplot.cdoperad%TYPE --> Operador
                                    ,pr_cddcanal  IN tbgen_canal_entrada.cdcanal%TYPE --> Flag Mobile
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta
                                    ,pr_idseqttl  IN crapttl.idseqttl%tYPE --> Titularidade
                                    ,pr_dsdemail  IN VARCHAR2              --> Email
                                    ,pr_qtparcel  IN NUMBER                --> Quantidade de parcelas
                                    ,pr_vlemprst  IN NUMBER                --> Valor do empréstimo
                                    ,pr_dsmensag  IN VARCHAR2              --> Mensagem
                                    ,pr_flgderro OUT VARCHAR2              --> Indicador de erro
                                    ,pr_dsmsgsai OUT VARCHAR2) IS          --> Mensagem de saída
  BEGIN
    /* .............................................................................

       Programa: pc_solicitar_credito
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : David Giovanni Kistner
       Data    : Abril/2017                         Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para solicitação de empréstimo.

       Alteracoes:

    ............................................................................. */
    DECLARE
    
      -- Busca dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.nmrescop
          FROM crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;    

      -- Busca dados do cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nmprimtl
              ,crapass.inpessoa
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Busca dados do titular
      CURSOR cr_crapttl(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS
        SELECT crapttl.nmextttl
          FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
           AND crapttl.nrdconta = pr_nrdconta
           AND crapttl.idseqttl = pr_idseqttl;
      rw_crapttl cr_crapttl%ROWTYPE;
      
      -- Busca telefones do cooperado
      CURSOR cr_craptfc (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_idseqttl IN crapttl.idseqttl%TYPE
                        ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
      SELECT tfc.cdseqtfc
            ,'(' || gene0002.fn_mask(tfc.nrdddtfc,'99') || ') ' || DECODE(LENGTH(tfc.nrtelefo),8,SUBSTR(tfc.nrtelefo,1,4),SUBSTR(tfc.nrtelefo,1,5))  || '-' || SUBSTR(tfc.nrtelefo,-4) dstelefo
            ,DECODE(pr_inpessoa,1,DECODE(tfc.tptelefo,2,1,1,2) ,(DECODE(tfc.tptelefo,3,1,2,2,1,3) )) nrordreq
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.idseqttl = pr_idseqttl
         AND tfc.idsittfc = 1 -- ATIVO   
         AND ((pr_inpessoa = 1 AND tfc.tptelefo IN (1,2)) OR 
              (pr_inpessoa > 1 AND tfc.tptelefo IN (1,2,3)))    
        ORDER BY nrordreq  
                ,tfc.cdseqtfc DESC;
      rw_craptfc cr_craptfc%ROWTYPE;

      vr_dscritic VARCHAR2(4000);
      vr_dsconteu VARCHAR2(4000);
      vr_dsdemail VARCHAR2(1000);
      vr_nrtelefo VARCHAR2(500);
      vr_nmprimtl crapass.nmprimtl%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN
      
      -- Busca dados da cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      
      IF cr_crapcop%NOTFOUND THEN
         vr_dscritic := 'Cooperativa não cadastrada.';
         -- Fecha o cursor
         CLOSE cr_crapcop;        
         RAISE vr_exc_saida;
      ELSE
         -- Fecha o cursor
         CLOSE cr_crapcop;
      END IF;     
      
      -- Busca dados do cooperado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
         vr_dscritic := 'Associado não cadastrado.';
         -- Fecha o cursor
         CLOSE cr_crapass;        
         RAISE vr_exc_saida;
      ELSE
         -- Fecha o cursor
         CLOSE cr_crapass;
      END IF;   
      
      vr_nmprimtl := INITCAP(rw_crapass.nmprimtl);
      
      IF rw_crapass.inpessoa = 1 THEN
         -- Busca dados do titular
         OPEN cr_crapttl(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_idseqttl => pr_idseqttl);
         FETCH cr_crapttl INTO rw_crapttl;
         
         IF cr_crapttl%NOTFOUND THEN
            vr_dscritic := 'Titular não cadastrado.';
            -- Fecha o cursor
            CLOSE cr_crapttl;        
            RAISE vr_exc_saida;
         ELSE
            vr_nmprimtl := INITCAP(rw_crapttl.nmextttl);
            -- Fecha o cursor
            CLOSE cr_crapttl;
         END IF; 
      END IF;
        
      -- Busca telefones do cooperado
      vr_nrtelefo := ' ';
      FOR rw_craptfc IN cr_craptfc(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_inpessoa => rw_crapass.inpessoa) LOOP
         IF vr_nrtelefo = ' ' THEN
            vr_nrtelefo := rw_craptfc.dstelefo;
         ELSE
            vr_nrtelefo := vr_nrtelefo || '<br>' || rw_craptfc.dstelefo;
         END IF;
      END LOOP;  
      
      IF NVL(pr_vlemprst,0) <= 0 THEN
         vr_dscritic := 'Valor do empréstimo deve ser informado.';        
         RAISE vr_exc_saida;
      END IF;
        
      IF NVL(pr_qtparcel,0) <= 0 THEN
         vr_dscritic := 'Quantidade de parcelas deve ser informada.';        
         RAISE vr_exc_saida;
      END IF;
      
      IF NVL(pr_dsdemail,' ') = ' ' THEN
         vr_dscritic := 'Email do solicitante deve ser informado.';        
         RAISE vr_exc_saida;
      END IF;
      
      IF NVL(pr_dsmensag,' ') = ' ' THEN
         vr_dscritic := 'Motivo da solicitação deve ser informado.';        
         RAISE vr_exc_saida;
      END IF;                  
      
      vr_dsconteu := '<strong>Solicitação de Empréstimo</strong><br><br>' ||
                     '<strong>Conta</strong><br>' || TO_CHAR(pr_nrdconta) || '<br><br>' ||
                     '<strong>Nome</strong><br>' || vr_nmprimtl || '<br><br>' ||
                     '<strong>Email</strong><br>' || pr_dsdemail || '<br><br>' ||
                     '<strong>Telefone</strong><br>' || vr_nrtelefo || '<br><br>' ||
                     '<strong>Valor do Empréstimo</strong><br>' || TO_CHAR(pr_vlemprst,'fm999g999g999g990d00') || '<br><br>' ||
                     '<strong>Quantidade de Parcelas</strong><br>' || TO_CHAR(pr_qtparcel) || '<br><br>' ||                     
                     '<strong>Motivo da Solicitação</strong><br>' || pr_dsmensag;
                                 
      vr_dsdemail := gene0001.fn_param_sistema('CRED',pr_cdcooper,'EMAIL_SOL_CRED_AUTO');
                   
      IF TRIM(vr_dsdemail) IS NOT NULL THEN       
	      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
	                                ,pr_cdprogra        => 'EMPR0010'
	                                ,pr_des_destino     => vr_dsdemail
	                                ,pr_des_assunto     => 'Solicitação de Empréstimo'
	                                ,pr_des_corpo       => vr_dsconteu
	                                ,pr_des_anexo       => ''
	                                ,pr_des_nome_reply  => vr_nmprimtl
	                                ,pr_des_email_reply => pr_dsdemail
	                                ,pr_flg_log_batch   => 'N'
	                                ,pr_flg_enviar      => 'S'
	                                ,pr_des_erro        => vr_dscritic);
	  END IF;
     
      -- Se houver erro
      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := 'Falha no envio do email.';        
         RAISE vr_exc_saida;
      END IF;         
      
      BEGIN
        INSERT INTO
          tbepr_solicitacao_online(           
             cdcooper
            ,nrdconta
            ,idseqttl
            ,dtsolicitacao
            ,vlemprestimo
            ,nrparcelas
            ,dsemail_solicitante
            ,dsmotivo
            ,cdcanal)
          VALUES(           
             pr_cdcooper
            ,pr_nrdconta
            ,pr_idseqttl
            ,SYSDATE
            ,pr_vlemprst
            ,pr_qtparcel
            ,pr_dsdemail
            ,pr_dsmensag
            ,pr_cddcanal);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao incluir registro tbepr_solicitacao_online. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      pr_flgderro := 'OK';
      pr_dsmsgsai := 'Recebemos a sua solicitação, vamos retornar o contato.' ;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_flgderro := 'NOK';
        pr_dsmsgsai := vr_dscritic;
      WHEN OTHERS THEN
        pr_flgderro := 'NOK';
        pr_dsmsgsai := 'Não foi possível enviar sua solicitação.';        
    END;

  END pc_solicitar_emprestimo;

END EMPR0010;
/
