CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS545 (pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                              ,pr_dscritic OUT VARCHAR2)  IS
/* .............................................................................

   Programa: PC_CRPS545           Antigo: Fontes/crps545.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jose Dill/Mouts
   Data    : Outubro/2018.                      Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (Batch).

   Objetivo  : Integrar arquivo de transferencia de creditos do software
               Cabine financeira da empresa JD Consultores
   Observações: A tabela genéria gnmvspb agora é populada através das informações geradas 
                nas tabelas de trace (Projeto 475). No progress, estas informações vem do arquivo físico)

   Alteracoes:
                27-12-2018 - Tratar STR0026R2 conforme programa antigo. Sprint D - Jose Dill
                
                19-02-2019 - Tratar contas inválidas com mais de 13 posições  - INC0033070  
   
............................................................................. */

  -- CURSORES
  -- Seleciona as informações das mensagens das operações enviadas
  CURSOR cr_tbmsg_env (pr_dtmvtolt in date
                      ,pr_dtmvtant in date) is
  SELECT tme.nmmensagem
        ,tmx.dsxml_completo
        ,tme.cdcooper
        ,tme.nrdconta
        ,substr(tme.nmmensagem,1,3) dsgrupo
        ,DECODE(tmef.cdfase,10,'Legado','Manual') dsorigem
    FROM tbspb_msg_enviada tme
        ,tbspb_msg_enviada_fase tmef
        ,tbspb_msg_xml tmx
  WHERE (tme.nmmensagem LIKE 'STR%' 
      OR tme.nmmensagem LIKE 'PAG%')
     AND TRUNC(tme.dhmensagem)  = pr_dtmvtolt
     AND tmef.nrseq_mensagem     = tme.nrseq_mensagem
     AND tmef.cdfase             in (10,15) -- 10 Criacao da mensagem no Ailos / 15 Criacao de mensagem na Cabine
     AND EXISTS (Select 1 from tbspb_msg_enviada_fase xx
                          where xx.nrseq_mensagem = tme.nrseq_mensagem
                          and   xx.cdfase = 55 -- Efetivado Camara (Liquidado)
                          and   TRUNC(xx.dhmensagem)  = pr_dtmvtolt) 
     AND (tme.nmmensagem not in ('STR0010','STR0048','PAG0111') 
       OR to_date(sspb0003.fn_busca_conteudo_campo(tmx.dsxml_completo,'DtMovto','D'),'dd-mm-yyyy') = pr_dtmvtolt)
     AND tmx.nrseq_mensagem_xml  = tmef.nrseq_mensagem_xml
  UNION ALL
  SELECT tme.nmmensagem
        ,tmx.dsxml_completo
        ,tme.cdcooper
        ,tme.nrdconta
        ,substr(tme.nmmensagem,1,3) dsgrupo
        ,DECODE(tmef.cdfase,10,'Legado','Manual') dsorigem
    FROM tbspb_msg_enviada tme
        ,tbspb_msg_enviada_fase tmef
        ,tbspb_msg_xml tmx
  WHERE (tme.nmmensagem LIKE 'STR%' 
      OR tme.nmmensagem LIKE 'PAG%')
     AND TRUNC(tme.dhmensagem)  = pr_dtmvtant
     AND tmef.nrseq_mensagem     = tme.nrseq_mensagem
     AND tmef.cdfase             in (10,15) -- 10 Criacao da mensagem no Ailos / 15 Criacao de mensagem na Cabine
     AND tme.nmmensagem in ('STR0010','STR0048','PAG0111') 
     AND to_date(sspb0003.fn_busca_conteudo_campo(tmx.dsxml_completo,'DtMovto','D'),'dd-mm-yyyy') = pr_dtmvtolt
     AND tmx.nrseq_mensagem_xml  = tmef.nrseq_mensagem_xml;     
  
  CURSOR cr_tbmsg_rec (pr_dtmvtolt in date) is   
  SELECT tmr.nmmensagem
        ,tmx.dsxml_completo
        ,tmr.cdcooper
        ,substr(tmr.nmmensagem,1,3) dsgrupo 
        ,tmr.nrdconta       
    FROM tbspb_msg_recebida tmr
        ,tbspb_msg_recebida_fase tmrf
        ,tbspb_msg_xml tmx
  WHERE (tmr.nmmensagem LIKE 'STR%' 
      OR tmr.nmmensagem LIKE 'PAG%')
     AND TRUNC(tmr.dhmensagem)  = pr_dtmvtolt
     AND tmrf.nrseq_mensagem     = tmr.nrseq_mensagem
     AND tmrf.cdfase             = 115
     AND tmx.nrseq_mensagem_xml = tmrf.nrseq_mensagem_xml;     
  
  -- Busca o número da agência de acordo com a cooperativa e conta do associado
  CURSOR cr_agencia (pr_cdcooper in gnmvspb.cdcooper%type
                    ,pr_nrdconta  in crapass.nrdconta%type) is
  Select ass.cdagenci
  From crapass ass
  Where ass.cdcooper = pr_cdcooper
  and   ass.nrdconta = pr_nrdconta;      
  
  rw_cr_agencia cr_agencia%rowtype;      
  
  -- Buscar a cooperativa e o número da conta na tabela enviada
  CURSOR cr_tbspbmsgenv_coop (pr_nrcontrole_if IN tbspb_msg_enviada.nrcontrole_if%type) IS
  SELECT tme.cdcooper
        ,tme.nrdconta
  FROM tbspb_msg_enviada tme
  WHERE tme.nrcontrole_if = pr_nrcontrole_if;
       
  rw_tbspbmsgenv_coop cr_tbspbmsgenv_coop%ROWTYPE;    
         
  -- Buscar a cooperativa e o número da conta na tabela recebida
  CURSOR cr_tbspbmsgrec_coop (pr_nrcontrole_if_env IN tbspb_msg_recebida.nrcontrole_if_env%type) IS
  SELECT tmr.cdcooper
        ,tmr.nrdconta
  FROM tbspb_msg_recebida tmr
  WHERE tmr.nrcontrole_if_env = pr_nrcontrole_if_env;
       
  rw_tbspbmsgrec_coop cr_tbspbmsgrec_coop%ROWTYPE;   
  
  -- Buscar a área de negócio da cooperativa
  CURSOR cr_crapcop (pr_cdcooper in crapcop.cdcooper%type) is  
  Select cop.cdagectl
  From crapcop cop
  Where cop.cdcooper = pr_cdcooper;
  
  rw_crapcop cr_crapcop%rowtype;

  CURSOR cr_crapcco (pr_nrconvenio in number) is  
  select a.cdcooper
  from crapcco a
  where a.nrconven = pr_nrconvenio
  and   a.dsorgarq not in ('INCORPORACAO','MIGRACAO');
  
  rw_crapcco cr_crapcco%rowtype;

  --Tipo de registro de gnmvspb
  TYPE typ_gnmvspb IS
    RECORD ( dtmvtolt      date        
            ,cdcooper      gnmvspb.cdcooper%type 
            ,dsdgrupo      gnmvspb.dsdgrupo%type 
            ,cdagenci      gnmvspb.cdagenci%type 
            ,dsorigem      gnmvspb.dsorigem%type 
            ,dsdebcre      gnmvspb.dsdebcre%type 
            ,dsareneg      gnmvspb.dsareneg%type 
            ,dsmensag      gnmvspb.dsmensag%type 
            ,dtmensag      date      
            ,vllanmto      gnmvspb.vllanmto%type 
            ,dsinstdb      gnmvspb.dsinstdb%type 
            ,nrcnpjdb      gnmvspb.nrcnpjdb%type 
            ,nmcliedb      gnmvspb.nmcliedb%type 
            ,dstpctdb      gnmvspb.dstpctdb%type 
            ,cdagendb      gnmvspb.cdagendb%type 
            ,dscntadb      gnmvspb.dscntadb%type 
            ,dsinstcr      gnmvspb.dsinstcr%type 
            ,nrcnpjcr      gnmvspb.nrcnpjcr%type 
            ,nmcliecr      gnmvspb.nmcliecr%type 
            ,dstpctcr      gnmvspb.dstpctcr%type 
            ,cdagencr      gnmvspb.cdagencr%type 
            ,dscntacr      gnmvspb.dscntacr%type 
            ,dsfinmsg      gnmvspb.dsfinmsg%type 
            ,progress_recid gnmvspb.progress_recid%type); 

  --Tipo de tabela de gnmvspb
  TYPE typ_tab_gnmvspb IS TABLE OF typ_gnmvspb INDEX by pls_integer;  
  vr_tab_gnmvspb           typ_tab_gnmvspb;
  
  --Tipo de registro para devoluções matera
  TYPE typ_devmatera IS
    RECORD ( dtmatera       date        
            ,vlmatera      gnmvspb.vllanmto%type   
            ,ispbmatera    gnmvspb.dsinstdb%type); 

  --Tipo de tabela para devoluções matera
  TYPE typ_tab_devmatera IS TABLE OF typ_devmatera INDEX by VARCHAR2(20);  
  vr_tab_devmatera           typ_tab_devmatera;  

  -- VARIÁVEIS
  -- Código do programa
  vr_cdprogra      VARCHAR2(10);
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  vr_dtmvtoan      crapdat.dtmvtoan%TYPE;

  -- Variáveis para armazenar informações do XML
  vr_cdcooper      gnmvspb.cdcooper%type;
  vr_dsdgrupo      gnmvspb.dsdgrupo%type;
  vr_cdagenci      gnmvspb.cdagenci%type;  
  vr_dsorigem      gnmvspb.dsorigem%type;
  vr_dsdebcre      gnmvspb.dsdebcre%type;
  vr_dsareneg      gnmvspb.dsareneg%type;
  vr_dsmensag      gnmvspb.dsmensag%type;
  vr_dtmensag      date;
  vr_vllanmto      gnmvspb.vllanmto%type;
  vr_dsinstdb      gnmvspb.dsinstdb%type;
  vr_nrcnpjdb      gnmvspb.nrcnpjdb%type;
  vr_nmcliedb      gnmvspb.nmcliedb%type;
  vr_dstpctdb      gnmvspb.dstpctdb%type;
  vr_cdagendb      gnmvspb.cdagendb%type;
  vr_dscntadb      gnmvspb.dscntadb%type;
  vr_dsinstcr      gnmvspb.dsinstcr%type;
  vr_nrcnpjcr      gnmvspb.nrcnpjcr%type;
  vr_nmcliecr      gnmvspb.nmcliecr%type;
  vr_dstpctcr      gnmvspb.dstpctcr%type;
  vr_cdagencr      gnmvspb.cdagencr%type;
  vr_dscntacr      gnmvspb.dscntacr%type;
  vr_dsfinmsg      gnmvspb.dsfinmsg%type; 
  vr_coddevtransf  varchar2(100);
  vr_numctrlpag    tbspb_msg_enviada.nrcontrole_if%type;
  vr_NumCodBarras  varchar2(100);

  --Variavel de Indice da tabela
  vr_index     pls_integer;
  vr_index_matera pls_integer;
      
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;
  vr_dscritic VARCHAR2(4000);
  --
  
  PROCEDURE PC_EMAIL_DEVOLUCAO_MATERA IS

    vr_aux_dsdemail VARCHAR2(4000);
    vr_dscritic     VARCHAR2(4000);
    
  BEGIN
    --
    vr_index_matera:= vr_tab_devmatera.FIRST;
    WHILE vr_index_matera IS NOT NULL LOOP        
     -- Montagem do email
      vr_aux_dsdemail := vr_aux_dsdemail
      || ' <br>'
      || ' Valor: ' || vr_tab_devmatera(vr_index_matera).vlmatera 
      || '  ISPB: ' || vr_tab_devmatera(vr_index_matera).ispbmatera
      || ' Data: ' || vr_tab_devmatera(vr_index_matera).dtmatera || '. <br>';
      --Proximo registro 
      vr_index_matera:= vr_tab_devmatera.NEXT(vr_index_matera);
    END LOOP;
    vr_aux_dsdemail := 'Foram identificadas <b>devoluçoes</b> de TED do legado <b>Matera:</b> '||vr_aux_dsdemail|| ' <br>';
    vr_aux_dsdemail := vr_aux_dsdemail||'Deverá ser efetuado crédito de devoluçao na conta da Cooperativa Filiada (histórico 2218)';
    --   
    gene0003.pc_solicita_email(pr_cdcooper        => 3
                              ,pr_cdprogra        => vr_cdprogra
                              ,pr_des_destino     => gene0001.fn_param_sistema('CRED',0,'GNMVSPB_DEV_MATERA')
                              ,pr_des_assunto     => 'Devoluçoes de TED - MATERA'
                              ,pr_des_corpo       => vr_aux_dsdemail
                              ,pr_des_anexo       => ''
                              ,pr_flg_enviar      => 'S'
                              ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                              ,pr_des_erro        => vr_dscritic);                   

    -- Se ocorreu erro
    IF trim(vr_dscritic) IS NOT NULL THEN
      -- Gerar LOG e continuar o processo normal
      BTCH0001.pc_gera_log_batch(pr_cdcooper      => 3
                                ,pr_ind_tipo_log  => 1
                                ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra ||' --> '
                                                  || 'Erro ao gerar email para matera: ' 
                                                  || ' --> '||vr_dscritic
                                ,pr_nmarqlog      => 'proc_message.log');
       -- Limpar critica
      vr_dscritic := null;
    END IF;                  
  EXCEPTION
    WHEN others THEN
      -- Erro nao tratado
      pr_dscritic := 'Erro nao tratado na rotina pc_email_devolucao_matera --> '||sqlerrm;    
      --  
  END PC_EMAIL_DEVOLUCAO_MATERA;
  --
  --
  BEGIN
  -- Código do programa
  vr_cdprogra := 'CRPS545';

  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CPRS545',
                             pr_action => vr_cdprogra);

  -- Se retornou algum erro
  IF pr_cdcritic <> 0 THEN
    -- Buscar descricão do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Buscar a data do movimento
  OPEN  btch0001.cr_crapdat(3);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;

  -- Se não encontrar o registro de movimento
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- 001 - Sistema sem data de movimento.
    pr_cdcritic := 1;
    -- Buscar descricão do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

    CLOSE btch0001.cr_crapdat;

    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  ELSE
    -- Atribuir os valores as variáveis
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
    vr_dtmvtoan := btch0001.rw_crapdat.dtmvtoan;
  END IF;
  CLOSE btch0001.cr_crapdat;
  --
  vr_index := 0;
  vr_index_matera := 0;
  -- Zerar tabelas temp
  vr_tab_gnmvspb.delete;
  vr_tab_devmatera.delete;
  --  
  -- Ler e armazenar as informações das mensagens enviadas na tabela temporaria
  FOR rr_cr_tbmsg_env IN cr_tbmsg_env (vr_dtmvtolt,vr_dtmvtoan) LOOP
    --
    vr_cdcooper := null;
    vr_dsdgrupo := null;
    vr_cdagenci := 0;
    vr_dsorigem := null;
    vr_dsdebcre := null;
    vr_dsareneg := null;
    vr_dsmensag := null;
    vr_dtmensag := null; 
    vr_vllanmto := null;
    vr_dsinstdb := null;
    vr_nrcnpjdb := null;
    vr_nmcliedb := null;
    vr_dstpctdb := null;
    vr_cdagendb := null;
    vr_dscntadb := null;
    vr_dsinstcr := null;
    vr_nrcnpjcr := null;
    vr_nmcliecr := null;
    vr_dstpctcr := null;
    vr_cdagencr := null;
    vr_dscntacr := null;
    vr_dsfinmsg := null;    
    --
    vr_cdcooper:= rr_cr_tbmsg_env.cdcooper;
    vr_dsdgrupo:= rr_cr_tbmsg_env.dsgrupo;
    vr_dscntadb:= Substr(rr_cr_tbmsg_env.nrdconta,1,13); --INC0033070
    --
    vr_dsorigem:= rr_cr_tbmsg_env.dsorigem;
    -- Manipular XML para buscar as informações
    vr_dsdebcre:= sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'FL_DEB_CRED','S');
    If vr_dsdebcre is null and vr_dsorigem = 'Manual' then
      vr_dsdebcre:= 'D';
    End If;    
    vr_dtmensag:= TO_DATE(sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'DtMovto','D'),'dd-mm-yyyy');
    vr_dsmensag := rr_cr_tbmsg_env.nmmensagem;
    vr_vllanmto := REPLACE(sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'VlrLanc','N'),'.',',');
    vr_dsinstdb := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'ISPBIFDebtd','S');
    --
    vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CNPJ_CPFRemet','S'); -- CNPJ_CPFRemet 
    If vr_nrcnpjdb is null then
       vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CNPJ_CPFCliDebtd','S'); -- CNPJ_CPFCliDebtd 
       If vr_nrcnpjdb is null then
          vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CNPJ_CPFCliDebtd_Remet','S'); -- CNPJ_CPFCliDebtd_Remet 
         If vr_nrcnpjdb is null then
            vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CPFCliDebtd','S'); -- CPFCliDebtd 
           If vr_nrcnpjdb is null then
              vr_nrcnpjdb := Nvl(sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CNPJ_CPFSacd','S'),0); -- CNPJ_CPFSacd 
           End if;          
         End if;          
       End if;
    End if;
    --   
    vr_nmcliedb := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'NomRemet','S'); -- NomRemet
    If vr_nmcliedb is null then
       vr_nmcliedb := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'NomCliDebtd','S'); -- NomCliDebtd
       If vr_nmcliedb is null then
          vr_nmcliedb := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'NomCliDebtd_Remet','S'); -- NomCliDebtd_Remet
       End if;   
    End if;
    --
    vr_dstpctdb := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'TpCtDebtd','S'); -- TpCtDebtd
    vr_cdagendb := Nvl(sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'AgDebtd','S'),0); -- AgDebtd
    If vr_dscntadb is null Then
    vr_dscntadb := Substr(sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CtDebtd','S'),1,13); -- CtDebtd --INC0033070
    End If; 
    --   
    vr_coddevtransf := null;
    vr_coddevtransf := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CodDevTransf','S'); -- CodDevTransf
    --   
    -- Buscar a cooperativa e conta da mensagem original se a mensagem for de DEVOLUÇÃO
    If vr_coddevtransf Is not null Then
      vr_numctrlpag:=  sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'NR_OPERACAO','S'); -- NR_OPERACAO
      If vr_numctrlpag is not null then
        Open cr_tbspbmsgrec_coop(vr_numctrlpag);
        Fetch cr_tbspbmsgrec_coop Into rw_tbspbmsgrec_coop;
        -- Se não encontrar
        If cr_tbspbmsgrec_coop%Notfound Then
           Close cr_tbspbmsgrec_coop;
        Else
           Close cr_tbspbmsgrec_coop;                               
           vr_cdcooper := rw_tbspbmsgrec_coop.cdcooper;
           vr_dscntadb := Substr(rw_tbspbmsgrec_coop.nrdconta,1,13); --INC0033070
           --   
           Open cr_agencia (vr_cdcooper, vr_dscntadb);
           Fetch cr_agencia into rw_cr_agencia;
           Close cr_agencia;
           If rw_cr_agencia.cdagenci is not null then
              vr_cdagenci:= rw_cr_agencia.cdagenci; 
           End if;  
           --
        End if;   
      End If; 
    Else
      If vr_cdagenci = 0 and vr_dscntadb is not null Then
         --   
         rw_cr_agencia.cdagenci:= null;
         Open cr_agencia (vr_cdcooper, vr_dscntadb);
         Fetch cr_agencia into rw_cr_agencia;
         If cr_agencia%found then
            Close cr_agencia;
            vr_cdagenci:= rw_cr_agencia.cdagenci;
         Else
            Close cr_agencia;
         End If;      
         --
      End If;         
    End if;
    --
    Open cr_crapcop(vr_cdcooper);
    Fetch cr_crapcop into rw_crapcop;
    Close cr_crapcop;
    If rw_crapcop.cdagectl is null then
       vr_dsareneg:= sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CD_LEGADO','S'); -- CD_LEGADO
    Else
       vr_dsareneg:= rw_crapcop.cdagectl;   
    End If;
    -- 
    vr_dsinstcr := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'ISPBIFCredtd','S');
    vr_nrcnpjcr := Nvl(sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CNPJ_CPFCliCredtd','S'),0); -- CNPJ_CPFCliCredtd
    If vr_nrcnpjcr = 0 then
       vr_nrcnpjcr:= Nvl(sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CNPJ_CPFDestinatario','S'),0); -- CNPJ_CPFDestinatario    
      If vr_nrcnpjcr = 0 then
         vr_nrcnpjcr:= Nvl(sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CNPJ_CPFCed','S'),0); -- CNPJ_CPFCed    
      End If;   
    End If;   
    vr_nmcliecr := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'NomCliCredtd','S'); -- NomCliCredtd
    If vr_nmcliecr is null then
       vr_nmcliecr := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'NomDestinatario','S'); -- NomDestinatario
    End If;   
    vr_dstpctcr := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'TpCtCredtd','S'); -- TpCtCredtd
    vr_cdagencr := Nvl(sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'AgCredtd','S'),0); -- AgCredtd
    vr_dscntacr := Nvl(Substr(sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'CtCredtd','S'),1,13),0); -- CtCredtd --INC0033070
    vr_dsfinmsg := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'FinlddCli','S'); -- FinlddCli
    If vr_dsfinmsg is null then
      vr_dsfinmsg := sspb0003.fn_busca_conteudo_campo(rr_cr_tbmsg_env.dsxml_completo,'FinlddIF','S'); -- FinlddIF
    End If;
    --Gravar tabela temporaria    
    --Montar indice para acessar tabela
    vr_index:= vr_index + 1;
    --Criar registro tabela lancamentos consolidada
    vr_tab_gnmvspb(vr_index).dtmvtolt := vr_dtmvtolt;
    vr_tab_gnmvspb(vr_index).cdcooper := vr_cdcooper;
    vr_tab_gnmvspb(vr_index).dsdgrupo := vr_dsdgrupo;
    vr_tab_gnmvspb(vr_index).cdagenci := vr_cdagenci;
    vr_tab_gnmvspb(vr_index).dsorigem := vr_dsorigem;
    vr_tab_gnmvspb(vr_index).dsdebcre := vr_dsdebcre;
    vr_tab_gnmvspb(vr_index).dsareneg := vr_dsareneg;
    vr_tab_gnmvspb(vr_index).dsmensag := vr_dsmensag;
    vr_tab_gnmvspb(vr_index).dtmensag := vr_dtmensag;
    vr_tab_gnmvspb(vr_index).vllanmto := vr_vllanmto;
    vr_tab_gnmvspb(vr_index).dsinstdb := vr_dsinstdb;
    vr_tab_gnmvspb(vr_index).nrcnpjdb := vr_nrcnpjdb;
    vr_tab_gnmvspb(vr_index).nmcliedb := vr_nmcliedb;
    vr_tab_gnmvspb(vr_index).dstpctdb := vr_dstpctdb;
    vr_tab_gnmvspb(vr_index).cdagendb := vr_cdagendb;
    vr_tab_gnmvspb(vr_index).dscntadb := vr_dscntadb;
    vr_tab_gnmvspb(vr_index).dsinstcr := vr_dsinstcr;
    vr_tab_gnmvspb(vr_index).nrcnpjcr := vr_nrcnpjcr;
    vr_tab_gnmvspb(vr_index).nmcliecr := vr_nmcliecr;
    vr_tab_gnmvspb(vr_index).dstpctcr := vr_dstpctcr;
    vr_tab_gnmvspb(vr_index).cdagencr := vr_cdagencr;
    vr_tab_gnmvspb(vr_index).dscntacr := vr_dscntacr;
    vr_tab_gnmvspb(vr_index).dsfinmsg := vr_dsfinmsg;
    vr_tab_gnmvspb(vr_index).progress_recid  := null;      
    --
    IF vr_dsmensag IN ('STR0010','PAG0111') THEN   
      --Popula dados da matera de mensagens enviadas
      IF vr_dsareneg = 'MATERA' THEN 
         vr_index_matera                              := NVL(vr_tab_devmatera.Count,0) + 1;
         vr_tab_devmatera(vr_index_matera).dtmatera   := vr_dtmvtolt; -- Gravar a data do movimento ?
         vr_tab_devmatera(vr_index_matera).vlmatera   := vr_vllanmto; 
         vr_tab_devmatera(vr_index_matera).ispbmatera := vr_dsinstdb; -- Quando é msg enviada, pega instituição de debito?
      END IF;
    END IF;
    --
  END LOOP rr_cr_tbmsg_env;
  --
  -- Ler e armazenar as informações das mensagens recebidas na tabela temporaria
  FOR rr_tbmsg_rec IN cr_tbmsg_rec (vr_dtmvtolt) LOOP
    --
    vr_cdcooper := null;
    vr_dsdgrupo := null;
    vr_cdagenci := 0;
    vr_dsorigem := null;
    vr_dsdebcre := null;
    vr_dsareneg := null;
    vr_dsmensag := null;
    vr_dtmensag := null; 
    vr_vllanmto := null;
    vr_dsinstdb := null;
    vr_nrcnpjdb := null;
    vr_nmcliedb := null;
    vr_dstpctdb := null;
    vr_cdagendb := null;
    vr_dscntadb := null;
    vr_dsinstcr := null;
    vr_nrcnpjcr := null;
    vr_nmcliecr := null;
    vr_dstpctcr := null;
    vr_cdagencr := 0;
    vr_dscntacr := null;
    vr_dsfinmsg := null;    
    --
    vr_cdcooper:= rr_tbmsg_rec.cdcooper;
    vr_dscntacr:= Substr(rr_tbmsg_rec.nrdconta,1,13); --INC0033070
    vr_dsdgrupo:= rr_tbmsg_rec.dsgrupo;
    vr_dsorigem := 'SPB';
    -- Manipular XML para buscar as informações
    vr_dsdebcre := 'C';
    --
    vr_dsmensag := rr_tbmsg_rec.nmmensagem;
    vr_vllanmto := REPLACE(sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'VlrLanc','N'),'.',',');    
    vr_dtmensag:= TO_DATE(sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'DtMovto','D'),'dd-mm-yyyy');    
    vr_dsinstdb := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'ISPBIFDebtd','S');
    --    
    vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CNPJ_CPFRemet','S'); -- CNPJ_CPFRemet 
    If vr_nrcnpjdb is null then
       vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CNPJ_CPFCliDebtd','S'); -- CNPJ_CPFCliDebtd 
       If vr_nrcnpjdb is null then
          vr_nrcnpjdb := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CNPJ_CPFCliDebtd_Remet','S'); -- CNPJ_CPFCliDebtd_Remet 
         If vr_nrcnpjdb is null then
            vr_nrcnpjdb := Nvl(sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CPFCliDebtd','S'),0); -- CPFCliDebtd 
           If vr_nrcnpjdb is null then
              vr_nrcnpjdb := Nvl(sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CNPJ_CPFSacd','S'),0); -- CNPJ_CPFSacd 
           End if;   
         End if;          
       End if;
    End if;
    --   
    vr_nmcliedb := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'NomRemet','S'); -- NomRemet
    If vr_nmcliedb is null then
       vr_nmcliedb := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'NomCliDebtd','S'); -- NomCliDebtd
       If vr_nmcliedb is null then
          vr_nmcliedb := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'NomCliDebtd_Remet','S'); -- NomCliDebtd_Remet
       End if;   
    End if;
    --
    vr_dstpctdb := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'TpCtDebtd','S'); -- TpCtDebtd    
    vr_cdagendb := Nvl(sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'AgDebtd','S'),0); -- AgDebtd
    vr_dscntadb := Substr(sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CtDebtd','S'),1,13); -- CtDebtd --INC0033070
    --   
    vr_dsinstcr := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'ISPBIFCredtd','S');
    --
    vr_nrcnpjcr := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CNPJ_CPFCliCredtd','S'); -- CNPJ_CPFCliCredtd
    If vr_nrcnpjcr is null then
       vr_nrcnpjcr:= Nvl(sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CNPJ_CPFDestinatario','S'),0); -- CNPJ_CPFDestinatario
      If vr_nrcnpjcr = 0 then
         vr_nrcnpjcr:= Nvl(sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CNPJ_CPFCed','S'),0); -- CNPJ_CPFCed    
      End If;   
    end if;
    --
    vr_nmcliecr := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'NomCliCredtd','S'); -- NomCliCredtd
    If vr_nmcliecr is null then
       vr_nmcliecr := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'NomDestinatario','S'); -- NomDestinatario
    end if;
    vr_dstpctcr := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'TpCtCredtd','S'); -- TpCtCredtd
    vr_cdagencr := Nvl(sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'AgCredtd','S'),0); -- AgCredtd
    If vr_dscntacr is null then 
    vr_dscntacr := Nvl(Substr(sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CtCredtd','S'),1,13),0); -- CtCredtd --INC0033070
    End If;   
    --
    vr_dsfinmsg := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'FinlddCli','S'); -- FinlddCli
    If vr_dsfinmsg is null then
       vr_dsfinmsg := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'FinlddIF','S'); -- FinlddIF
       If vr_dsfinmsg is null then
          vr_dsfinmsg := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'FinlddIFVarj','S'); -- FinlddIFVarj
       End If;
    End If;
    -- Tratamentos
    If vr_dsmensag IN ('STR0037R2','PAG0137R2') Then
      vr_nrcnpjcr := vr_nrcnpjdb; -- Pega da débito
      vr_nmcliecr := vr_nmcliedb;
    End If;
    --
    vr_coddevtransf := null;
    vr_coddevtransf := sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CodDevTransf','S'); -- CodDevTransf
    -- Buscar a cooperativa e conta da mensagem original se a mensagem for de devolução
    If vr_coddevtransf Is not null Then
      vr_numctrlpag:=  sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'NR_OPERACAO','S'); -- NR_OPERACAO
      If vr_numctrlpag is not null then
        Open cr_tbspbmsgenv_coop(vr_numctrlpag);
        Fetch cr_tbspbmsgenv_coop Into rw_tbspbmsgenv_coop;
        -- Se não encontrar
        If cr_tbspbmsgenv_coop%Notfound Then
           Close cr_tbspbmsgenv_coop;
        Else
           Close cr_tbspbmsgenv_coop;                               
           vr_cdcooper := rw_tbspbmsgenv_coop.cdcooper;
           vr_dscntacr := Substr(rw_tbspbmsgenv_coop.nrdconta,1,13); --INC0033070
           --   
           rw_cr_agencia.cdagenci := null;
           Open cr_agencia (vr_cdcooper, vr_dscntacr);
           Fetch cr_agencia into rw_cr_agencia;
           Close cr_agencia;
           If rw_cr_agencia.cdagenci is not null then
              vr_cdagenci:= rw_cr_agencia.cdagenci; 
           End if;  
           --
        End if;   
      End If; 
    Else
      -- Sprint D - Buscar cooperativa através do código de barras (Ajuste)
      If rr_tbmsg_rec.nmmensagem = 'STR0026R2' Then
         -- Pegar código de barras para encontrar a cooperativa
         vr_NumCodBarras:= null;
         vr_NumCodBarras:= sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'NumCodBarras','S'); 
         If vr_NumCodBarras is not null then 
            --
            Open cr_crapcco (to_number(Substr(vr_NumCodBarras,20,6)));
            Fetch cr_crapcco into rw_crapcco;
            If cr_crapcco%found then
              vr_cdcooper := rw_crapcco.cdcooper;
              Close cr_crapcco;
            Else  
              Close cr_crapcco;
            End if;  
            --
         End If;
      End If;  
      -- Fim Sprint D
      --
      If vr_cdagenci = 0 and vr_dscntacr <> 0 Then
         --   
         rw_cr_agencia.cdagenci := null;
         Open cr_agencia (vr_cdcooper, vr_dscntacr);
         Fetch cr_agencia into rw_cr_agencia;
         Close cr_agencia;
         If rw_cr_agencia.cdagenci is not null then
            vr_cdagenci:= rw_cr_agencia.cdagenci; 
         End if;  
         --
      End If;         
    End if;
    -- 
    Open cr_crapcop(vr_cdcooper);
    Fetch cr_crapcop into rw_crapcop;
    Close cr_crapcop;
    If rw_crapcop.cdagectl is null then
       vr_dsareneg:= sspb0003.fn_busca_conteudo_campo(rr_tbmsg_rec.dsxml_completo,'CD_LEGADO','S'); -- CD_LEGADO
    Else
       vr_dsareneg:= rw_crapcop.cdagectl;   
    End If;
    --     
    
    --Gravar tabela temporaria    
    --Montar indice para acessar tabela
    vr_index:= vr_index + 1;
     
    --Criar registro tabela lancamentos consolidada
    vr_tab_gnmvspb(vr_index).dtmvtolt := vr_dtmvtolt;
    vr_tab_gnmvspb(vr_index).cdcooper := vr_cdcooper;
    vr_tab_gnmvspb(vr_index).dsdgrupo := vr_dsdgrupo;
    vr_tab_gnmvspb(vr_index).cdagenci := vr_cdagenci;
    vr_tab_gnmvspb(vr_index).dsorigem := vr_dsorigem;
    vr_tab_gnmvspb(vr_index).dsdebcre := vr_dsdebcre;
    vr_tab_gnmvspb(vr_index).dsareneg := vr_dsareneg;
    vr_tab_gnmvspb(vr_index).dsmensag := vr_dsmensag;
    vr_tab_gnmvspb(vr_index).dtmensag := vr_dtmensag;
    vr_tab_gnmvspb(vr_index).vllanmto := vr_vllanmto;
    vr_tab_gnmvspb(vr_index).dsinstdb := vr_dsinstdb;
    vr_tab_gnmvspb(vr_index).nrcnpjdb := vr_nrcnpjdb;
    vr_tab_gnmvspb(vr_index).nmcliedb := vr_nmcliedb;
    vr_tab_gnmvspb(vr_index).dstpctdb := vr_dstpctdb;
    vr_tab_gnmvspb(vr_index).cdagendb := vr_cdagendb;
    vr_tab_gnmvspb(vr_index).dscntadb := vr_dscntadb;
    vr_tab_gnmvspb(vr_index).dsinstcr := vr_dsinstcr;
    vr_tab_gnmvspb(vr_index).nrcnpjcr := vr_nrcnpjcr;
    vr_tab_gnmvspb(vr_index).nmcliecr := vr_nmcliecr;
    vr_tab_gnmvspb(vr_index).dstpctcr := vr_dstpctcr;
    vr_tab_gnmvspb(vr_index).cdagencr := vr_cdagencr;
    vr_tab_gnmvspb(vr_index).dscntacr := vr_dscntacr;
    vr_tab_gnmvspb(vr_index).dsfinmsg := vr_dsfinmsg;
    vr_tab_gnmvspb(vr_index).progress_recid  := null;      
    --
    --
    IF vr_dsmensag IN ('STR0010R2','PAG0111R2') THEN 
      --Popula dados da matera de mensagens enviadas
      IF vr_dsareneg = 'MATERA' THEN       
         vr_index_matera                              := NVL(vr_tab_devmatera.Count,0) + 1;
         vr_tab_devmatera(vr_index_matera).dtmatera   := vr_dtmvtolt; -- Gravar a data do movimento ? duvida
         vr_tab_devmatera(vr_index_matera).vlmatera   := vr_vllanmto; 
         vr_tab_devmatera(vr_index_matera).ispbmatera := vr_dsinstdb; -- Quando é msg enviada, pega instituição de debito? duvida
      END IF;
    END IF;
    --    
  END LOOP rr_tbmsg_rec;
  --
  -- Gravar as informações da tabela temporária na GNMVSPB
  --
  IF vr_tab_gnmvspb.COUNT() > 0 THEN
    FOR idx IN vr_tab_gnmvspb.first..vr_tab_gnmvspb.last LOOP
      -- 
      INSERT INTO GNMVSPB 
      (DTMVTOLT, CDCOOPER, DSDGRUPO, CDAGENCI, DSORIGEM, DSDEBCRE, DSARENEG, DSMENSAG,
       DTMENSAG, VLLANMTO, DSINSTDB, NRCNPJDB, NMCLIEDB, DSTPCTDB, CDAGENDB,DSCNTADB, DSINSTCR,
       NRCNPJCR, NMCLIECR, DSTPCTCR, CDAGENCR, DSCNTACR, DSFINMSG, PROGRESS_RECID)
      VALUES
      (vr_tab_gnmvspb(idx).DTMVTOLT, vr_tab_gnmvspb(idx).CDCOOPER, vr_tab_gnmvspb(idx).DSDGRUPO, vr_tab_gnmvspb(idx).CDAGENCI, 
       vr_tab_gnmvspb(idx).DSORIGEM, vr_tab_gnmvspb(idx).DSDEBCRE, vr_tab_gnmvspb(idx).DSARENEG, vr_tab_gnmvspb(idx).DSMENSAG,
       vr_tab_gnmvspb(idx).DTMENSAG, vr_tab_gnmvspb(idx).VLLANMTO, vr_tab_gnmvspb(idx).DSINSTDB, vr_tab_gnmvspb(idx).NRCNPJDB, 
       vr_tab_gnmvspb(idx).NMCLIEDB, vr_tab_gnmvspb(idx).DSTPCTDB, vr_tab_gnmvspb(idx).CDAGENDB, vr_tab_gnmvspb(idx).DSCNTADB, 
       vr_tab_gnmvspb(idx).DSINSTCR, vr_tab_gnmvspb(idx).NRCNPJCR, vr_tab_gnmvspb(idx).NMCLIECR, vr_tab_gnmvspb(idx).DSTPCTCR, 
       vr_tab_gnmvspb(idx).CDAGENCR, vr_tab_gnmvspb(idx).DSCNTACR, vr_tab_gnmvspb(idx).DSFINMSG, NULL);  
    END LOOP;
  END IF;
  --  
  IF vr_tab_devmatera.Count > 0 THEN
    -- Se foram geradas informações na tabela temp de devolução matera, um email de devolução deve ser enviado
    PC_EMAIL_DEVOLUCAO_MATERA;
    --
  END IF;
  --  
  COMMIT; 
  --
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
    cecred.pc_internal_exception(pr_cdcooper => 3);
    
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    BTCH0001.pc_gera_log_batch(pr_cdcooper      => 3
                              ,pr_ind_tipo_log  => 2
                              ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra ||' --> '
                                                || pr_dscritic
                              ,pr_nmarqlog      => 'proc_batch.log');
    ROLLBACK;

END PC_CRPS545;
/
