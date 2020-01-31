--inc0035854 reenviar títulos abertos que foram rejeitados pela cabine por data errada: EDDA0076
declare
  --
  --types
  --registro de lote de titulos
  type typ_reg_lote_titulo is record (crapcob_rowid rowid);
  type typ_tab_lote_titulo is table of typ_reg_lote_titulo index by pls_integer;
  --
  --registro de sacados já consultados para reaproveitar a consulta
  type t_reg_sab is record (cdidesab varchar2(17)
                           ,flsacdda number(1));
  type t_tab_sab is table of t_reg_sab index by varchar2(17);
  --
  --constantes
  ct_cdprogra constant varchar2(10) := 'npcregtit';   -- Nome do programa
  ct_vllimcab constant number       := 99999999.99; -- Define o valor limite da cabine
  ct_cdoperad constant varchar2(10) := '1';         -- Código do operador - verificar se será fixo ou parametro
  --variaveis
  vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  vr_iderro   varchar2(1) := 'N';
  --
--------------------------------------------------------------
----procedimentos genericos para funcionamento do programa----
--------------------------------------------------------------
  PROCEDURE pc_controla_log_batch(pr_cdcooper_in   IN crapcop.cdcooper%TYPE
                                 ,pr_dstiplog      IN VARCHAR2 -- 'I' início; 'F' fim; 'E' erro
                                 ,pr_dscritic      IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0
                                 ,pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0) IS
    --
    /*procedure que grava log do programa*/
    --
    -- Refeita rotina de log - 10/10/2017 - Ch 758611 
    vr_dscritic_aux VARCHAR2(4000);
    vr_tpocorrencia tbgen_prglog_ocorrencia.tpocorrencia%type;
  BEGIN
    vr_dscritic_aux := pr_dscritic||', cdcooper:'||pr_cdcooper_in;
    IF pr_dstiplog IN ('O', 'I', 'F') THEN
      vr_tpocorrencia := 4; 
    ELSE
      vr_tpocorrencia := 2;       
    END IF;
    --> Controlar geração de log de execução dos jobs 
    CECRED.pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E')
                          ,pr_cdprograma    => ct_cdprogra
                          ,pr_cdcooper      => pr_cdcooper_in
                          ,pr_tpexecucao    => 2 --job
                          ,pr_tpocorrencia  => vr_tpocorrencia
                          ,pr_cdcriticidade => pr_cdcriticidade
                          ,pr_cdmensagem    => pr_cdmensagem
                          ,pr_dsmensagem    => vr_dscritic_aux
                          ,pr_idprglog      => vr_idprglog
                          ,pr_nmarqlog      => NULL);
  EXCEPTION  
    WHEN OTHERS THEN  
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper_in);   
  END pc_controla_log_batch;
  --
  procedure pc_raise_error(pr_dsmensag in varchar2
                          ,pr_cdcritic in crapcri.cdcritic%type
                          ,pr_dscritic in varchar2
                          ,pr_idempilh in boolean) is
    --
    /*recebe a critica como parametro trata a descricao e o código e executa um raise*/
    --
    vr_cdcritic number(5)      := pr_cdcritic;
    vr_dscritic varchar2(4000) := pr_dscritic;
    --
  begin
    --
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      if nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      end if;
      raise_application_error(-20001,pr_dsmensag||vr_dscritic,pr_idempilh);
    end if;
    --
  end pc_raise_error;
  --
  procedure pc_captura_registra_log(pr_cdcooper_in in  craptab.cdcooper%type
                                   ,pr_dsmensag in varchar2) is
    --
    /*captura as informações da exceção e grava o log*/
    --
    vr_dscritic varchar2(4000);
    --
  begin
    --
    vr_dscritic := pr_dsmensag
                 ||dbms_utility.format_error_backtrace
          ||' - '||dbms_utility.format_error_stack;
    --
    pc_controla_log_batch(pr_cdcooper_in   => pr_cdcooper_in
                         ,pr_dstiplog      => 'E'
                         ,pr_dscritic      => vr_dscritic
                         ,pr_cdcriticidade => 1
                         ,pr_cdmensagem    => 0);
    --
  end pc_captura_registra_log;
  --
  function fn_sacado_dda(pr_tppessoa in varchar2 -- Tipo de pessoa
                        ,pr_nrcpfcgc in number   -- Cpf ou CNPJ
                        ,pr_tab_sab  in out nocopy t_tab_sab
                        ) return integer is
    --
    vr_cdidesab varchar2(17);
    vr_flsacdda integer;
    vr_cdcritic number;
    vr_dscritic varchar2(32000);
    --exceptions
    vr_exc_saida exception;
    --
  begin
    --
    vr_cdidesab := pr_tppessoa||to_char(pr_nrcpfcgc,'fm0000000000000000');
    --
    if pr_tab_sab.exists(vr_cdidesab) then
      --
      vr_flsacdda := pr_tab_sab(vr_cdidesab).flsacdda;
      --
    else
      --
      ddda0001.pc_verifica_sacado_dda(pr_tppessoa => pr_tppessoa
                                     ,pr_nrcpfcgc => pr_nrcpfcgc
                                     ,pr_flgsacad => vr_flsacdda
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
      --
      if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
        --
        raise vr_exc_saida;
        --
      end if;
      --
      pr_tab_sab(vr_cdidesab).cdidesab := vr_cdidesab;
      pr_tab_sab(vr_cdidesab).flsacdda := vr_flsacdda;
      --
    end if;
    --
    return (vr_flsacdda);
    --
  exception
    when vr_exc_saida then
      begin
        --
        if nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
          -- buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        end if;
        -- Log de erro da execução
        pc_controla_log_batch(pr_cdcooper_in   => 3
                             ,pr_dstiplog      => 'E'
                             ,pr_dscritic      => vr_dscritic
                             ,pr_cdcriticidade => 1
                             ,pr_cdmensagem    => vr_cdcritic);
        --
        raise_application_error(-20001,'fn_sacado_dda('||pr_tppessoa||'-'||pr_nrcpfcgc||')');
        --
      end;
    when others then
      begin
        --
        pc_captura_registra_log(pr_cdcooper_in => 3
                               ,pr_dsmensag => 'fn_sacado_dda('||pr_tppessoa||'-'||pr_nrcpfcgc||'):');
        --
        raise_application_error(-20001,'fn_sacado_dda',true);
        --
      end;
  end fn_sacado_dda;
  --
  function fn_valida_titulo(pr_cdcooper_in in crapcop.cdcooper%type
                           ,pr_rw_crapdat in btch0001.cr_crapdat%rowtype
                           ,pr_idcrgini number
                           ,pr_crapcob_rowid rowid
                           ,pr_vltitulo number
                           ,pr_tppsssab varchar2
                           ,pr_nrinssac crapsab.nrinssac%type
                           ,pr_tab_sab in out nocopy t_tab_sab) return number is
    --
    /*executa as validações padrão do título*/
    --
    vr_idregdes number(1) := 0;
    vr_flgrollt integer := 0;
    vr_flgsacad number := 0;
    vr_des_erro varchar2(10);
    vr_dscritic varchar2(4000);
    --
  begin
    --
    -- Tratamento para nao enviar para a cabine pois a cabine existe essa limitaçao de valor 
    if pr_vltitulo > ct_vllimcab then
      --
      vr_idregdes := 1;
      -- Cria o log da cobrança
      paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_crapcob_rowid
                                   ,pr_cdoperad => ct_cdoperad
                                   ,pr_dtmvtolt => sysdate
                                   ,pr_dsmensag => 'Falha no envio para a CIP (valor superior ao suportado)'
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
      -- se ocorrer erro
      if vr_des_erro <> 'OK' then
        raise_application_error(-20001,'Cria log valor: '||vr_dscritic);
      end if;
      --
    end if;
    --
    --se não é carga inicial e registro não foi desconsiderado então validar proxima regra
    if pr_idcrgini = 0 and vr_idregdes = 0 then
      --> Verificar rollout da plataforma de cobrança
      vr_flgrollt := NPCB0001.fn_verifica_rollout(pr_cdcooper => pr_cdcooper_in
                                                 ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                                 ,pr_vltitulo => pr_vltitulo
                                                 ,pr_tpdregra => 1);--1-registro
      --
      --se o valor estiver fora da faixa de rollout então verficar se pagador DDA
      if vr_flgrollt = 0 then
        --
        vr_flgsacad := fn_sacado_dda(pr_tppessoa => pr_tppsssab
                                    ,pr_nrcpfcgc => pr_nrinssac
                                    ,pr_tab_sab  => pr_tab_sab);
        --
        --se o pagador não é DDA então deve desconsiderar o registro
        if vr_flgsacad <> 1 then
          --
          vr_idregdes := 1;
          --
        end if;
        --
      end if;
      --
    end if;
    --
    return vr_idregdes;
    --
  end fn_valida_titulo;
  --
  procedure pc_atualiza_status_envio_dda(pr_tab_remessa_dda in out ddda0001.typ_tab_remessa_dda
                                        ,pr_tpdenvio        in integer) is  --> tipo de envio(0-Normal/Batch, 1-Online, 2-Carga inicial)    
    --
    vr_index     integer;
    vr_dscmplog  varchar2(200);
    vr_des_erro  varchar2(10);
    vr_dscritic  varchar2(4000);
    --
  begin
    --
    vr_index := pr_tab_remessa_dda.FIRST;
    --
    while vr_index is not null loop      
      -- Verifica se ocorreu erro
      if trim(pr_tab_remessa_dda(vr_index).dscritic) is not null then
        -- Atualizar CRAPCOB 
        begin
          update crapcob
             set flgcbdda = 0 -- FALSE
                ,insitpro = 0
                ,idtitleg = 0
                ,idopeleg = 0
                ,inenvcip = 0 -- não enviar
                ,dhenvcip = null
           where rowid = pr_tab_remessa_dda(vr_index).rowidcob;
        exception
          when others then
            raise_application_error(-20001,'update crapcob 01',true);
        end;
      else
        -- Atualizar CRAPCOB 
        begin
          update crapcob
             set flgcbdda = 1 -- TRUE
                ,insitpro = 2 -- recebido JD
                ,inenvcip = 2 -- enviado
                ,dhenvcip = sysdate
           where rowid = pr_tab_remessa_dda(vr_index).rowidcob;           
        exception
          when others then
            raise_application_error(-20001,'update crapcob 02',true);
        end;
        --Definir complemento do log conforme tipo de envio
        vr_dscmplog := null;
        if pr_tpdenvio = 1 then
          vr_dscmplog := ' online';
        elsif pr_tpdenvio = 2 then
          vr_dscmplog := ' carga NPC';
        end if;
        -- Incluir o log do boleto
        paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_tab_remessa_dda(vr_index).rowidcob
                                     ,pr_cdoperad => ct_cdoperad
                                     ,pr_dtmvtolt => sysdate
                                     ,pr_dsmensag => 'Titulo enviado a CIP'||vr_dscmplog
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
        -- se ocorrer erro
        if vr_des_erro <> 'OK' then
          raise_application_error(-20001,'Cria log: '||vr_dscritic);
        end if;
        --
      end if;
      --
      vr_index := pr_tab_remessa_dda.next(vr_index);
      --
    end loop;
    --
  exception 
    when others then
      pc_captura_registra_log(pr_cdcooper_in => 3
                             ,pr_dsmensag => 'pc_atualiza_status_envio_dda:');
  end pc_atualiza_status_envio_dda;
  --
  procedure pc_carga_inic_npc(pr_cdcooper_in in crapcop.cdcooper%type
                             ,pr_rw_crapdat in btch0001.cr_crapdat%rowtype
                             ,pr_qtlottit in number
                             ,pr_tab_sab in out nocopy t_tab_sab) is
    --
    procedure pc_processa_carga_inicial(pr_cdcooper_in in craptab.cdcooper%type
                                       ,pr_rw_crapdat in btch0001.cr_crapdat%rowtype
                                       ,pr_dtcrgrol in date
                                       ,pr_vlrollou in number) is
      --
      --cursor que busca somente o rowid do título para formar os lotes
      cursor c_lote_tit(pr_cdcooper_cr in crapcop.cdcooper%type
                       ,pr_dtcrgrol_cr in date
                       ,pr_vlrollou_cr in number) IS
                       
/*chw select cob com mensagens de erro de data: */
SELECT c.rowid crapcob_rowid
  FROM crapcob c, crapcol o
 WHERE c.dtmvtolt >= '20/12/2019'  --20, 24 e 26
--   AND c.inenvcip = 4
   AND o.dslogtit LIKE '%EDDA0076%'
-- AND TRUNC(o.dtaltera) = '26/12/2019'
   AND o.dtaltera >= to_date('21/12/2019','dd/mm/rrrr')
   AND o.cdcooper = c.cdcooper
   AND o.nrdconta = c.nrdconta
   AND o.nrdocmto = c.nrdocmto
   AND o.nrcnvcob = c.nrcnvcob
   AND c.incobran = 0
   AND c.flgregis = 1
   AND c.cdcooper = pr_cdcooper_cr;
                       
--        select /*+index(cop CRAPCOP##CRAPCOP1, cco CRAPCCO##CRAPCCO1, cob CRAPCOB##CRAPCOB9)*/
/*               cob.rowid crapcob_rowid
        from crapcob cob
            ,crapcco cco
            ,crapcop cop
        where 
          --deve existir o pagador na base do cooperado
              exists (
                      select 1
                      from crapsab sab
                      where sab.cdcooper = cob.cdcooper+0
                        and sab.nrdconta = cob.nrdconta+0
                        and sab.nrinssac = cob.nrinssac+0
                     )
          --
          and cob.flgregis = 1 */       /*cobranca registrada*/
/*          and cob.incobran = 0 */     /*aberto*/
/*          and cob.dtdpagto is null */ /*sem data de pagamento*/

/*          and cob.nrcnvcob = cco.nrconven+0  */
--chw          and cob.dtvencto >= trunc(sysdate) /*CIP não aceita título vencido*/
/*          and cob.cdcooper = cco.cdcooper+0 */
          -- 
--chw          AND cob.dhenvcip >= to_date('0308192203', 'ddmmrrhh24mi')          
--chw          AND cob.dhenvcip <= to_date('0308192300', 'ddmmrrhh24mi')
          --
/*          and cco.flgregis = 1 */ /*convenios de cobranca com registro*/
/*          and cco.cddbanco = cop.cdbcoctl+0 */ /*somente do banco controlador da cooperativa singular*/
/*          and cco.cdcooper = cop.cdcooper+0 */
          --
/*          and cop.cdcooper = pr_cdcooper_cr; */
          
          
      --
      --cursor que busca o título com os mesmos critérios do cursor de lote
      --como o sistema é on-line e vários jobs estão executando simultaneamente
      --é importante validar se o título ainda atende às condições para integração
      cursor cr_titulo(pr_crapcob_rowid in rowid
                      ,pr_cdcooper_cr in crapcop.cdcooper%type
                      ,pr_dtcrgrol_cr in date
                      ,pr_vlrollou_cr in number) is
        select /*+index(cop CRAPCOP##CRAPCOP1, cco CRAPCCO##CRAPCCO1)*/
               cob.rowid crapcob_rowid
              ,cob.vltitulo
              ,cob.dtvencto
              ,cob.vldescto
              ,cob.vlabatim
              ,cob.flgdprot
              ,decode(cob.cdtpinsc
                 ,1,'F'
                 ,'J') tppsssab
              ,cob.nrinssac
        from crapcco cco
            ,crapcop cop
            ,crapcob cob
        where cco.flgregis = 1 /*convenios de cobranca com registro*/
          and cco.cddbanco = cop.cdbcoctl+0 /*somente do banco controlador da cooperativa singular*/
          and cco.nrconven = cob.nrcnvcob+0
          and cco.cdcooper = cop.cdcooper+0
          --
          and cop.cdcooper = cob.cdcooper+0
          --
          --deve existir o pagador na base do cooperado
          and exists (
                      select 1
                      from crapsab sab
                      where sab.cdcooper = cob.cdcooper+0
                        and sab.nrdconta = cob.nrdconta+0
                        and sab.nrinssac = cob.nrinssac+0
                     )
          --
          and cob.flgregis = 1 /*cobranca registrada*/
          and cob.incobran = 0 /*aberto*/
          and cob.dtdpagto is null /*sem data de pagamento*/
--chw          and cob.dtvencto+0 >= trunc(sysdate) /*CIP não aceita título vencido*/
          and cob.cdcooper+0 = pr_cdcooper_cr
          and cob.rowid = pr_crapcob_rowid
        order by cob.nrinssac;
      rw_titulo cr_titulo%rowtype;
      --
      vr_tab_lote_titulo typ_tab_lote_titulo;
      vr_tab_remessa_dda ddda0001.typ_tab_remessa_dda;
      vr_tab_retorno_dda ddda0001.typ_tab_retorno_dda;
      --
      vr_crapcob_rowid rowid;
      vr_idregprc number(1);
      vr_idregdes number(1);
      vr_qtregist number(10) := 0;
      vr_cdcritic number;
      vr_dscritic varchar2(32000);
      --
    begin
      --
      --abertura do cursor geral de títulos da cooperativa
      open c_lote_tit(pr_cdcooper_cr => pr_cdcooper_in
                     ,pr_dtcrgrol_cr => pr_dtcrgrol
                     ,pr_vlrollou_cr => pr_vlrollou);
      loop
        --
        vr_tab_lote_titulo.delete;
        vr_tab_remessa_dda.delete;
        vr_tab_retorno_dda.delete;
        --fetch de titulos em lotes
        fetch c_lote_tit bulk collect into vr_tab_lote_titulo limit pr_qtlottit;
        exit when nvl(vr_tab_lote_titulo.count,0) = 0;
        --
        --tratamento do lote de títulos
        for i in vr_tab_lote_titulo.first .. vr_tab_lote_titulo.last
        loop
          --
          begin
            --
            vr_idregprc := 0; --marcar o registro como não processado
            vr_idregdes := 0; --marcar o registro como considerado na integração
            vr_crapcob_rowid := vr_tab_lote_titulo(i).crapcob_rowid;
            --
            open cr_titulo(pr_crapcob_rowid => vr_crapcob_rowid
                          ,pr_cdcooper_cr => pr_cdcooper_in
                          ,pr_dtcrgrol_cr => pr_dtcrgrol
                          ,pr_vlrollou_cr => pr_vlrollou);
            fetch cr_titulo into rw_titulo;
            --se o cursor não retornou nada é porque o registro já foi processado por outro job
            if cr_titulo%notfound then
              --
              vr_idregprc := 1; --marcar o registro como processado
              --
            end if;
            close cr_titulo;
            --
            --se ainda não foi processado proseguir com a validação
            if vr_idregprc = 0 then
              --
              vr_idregdes := fn_valida_titulo(pr_cdcooper_in => pr_cdcooper_in
                                             ,pr_rw_crapdat => pr_rw_crapdat
                                             ,pr_idcrgini => 1 --carga inicial
                                             ,pr_crapcob_rowid => rw_titulo.crapcob_rowid
                                             ,pr_vltitulo => rw_titulo.vltitulo
                                             ,pr_tppsssab => rw_titulo.tppsssab
                                             ,pr_nrinssac => rw_titulo.nrinssac
                                             ,pr_tab_sab => pr_tab_sab);
              --
              --se não deve ser desconsiderado então preparar integração com JDNPC
              if vr_idregdes = 0 then
                --
                ddda0001.pc_cria_remessa_dda(pr_rowid_cob => rw_titulo.crapcob_rowid
                                            ,pr_tpoperad => 'I'
                                            ,pr_tpdbaixa => null
                                            ,pr_dtvencto => rw_titulo.dtvencto
                                            ,pr_vldescto => rw_titulo.vldescto
                                            ,pr_vlabatim => rw_titulo.vlabatim
                                            ,pr_flgdprot => (case rw_titulo.flgdprot when 0 then false else true end)
                                            ,pr_tab_remessa_dda => vr_tab_remessa_dda
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
                --
                pc_raise_error('ddda0001.pc_cria_remessa_dda:',vr_cdcritic,vr_dscritic,false);
                --
                vr_qtregist := vr_qtregist + 1;
                --
              end if;
              --
            end if;
            --
          exception
            when others then
              begin
                --
                vr_iderro := 'S';--ocorreu erro no processamento
                --
                pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                       ,pr_dsmensag => 'Lote titulos(rowid:'||vr_crapcob_rowid||'):');
                --
                --executa rollback do lote, limpa tabelas de memoria e sai do loop deste lote
                rollback;
                vr_tab_lote_titulo.delete;
                vr_tab_remessa_dda.delete;
                vr_tab_retorno_dda.delete;
                exit;
                --
              end;
          end;
          --
        end loop; --loop tab_lote_titulo
        --
        begin
          -- Realizar a remessa de títulos DDA
          if nvl(vr_tab_remessa_dda.count,0) > 0 then
            --
            ddda0001.pc_remessa_tit_tab_dda(pr_tab_remessa_dda => vr_tab_remessa_dda
                                           ,pr_tab_retorno_dda => vr_tab_retorno_dda
                                           ,pr_cdcritic        => vr_cdcritic
                                           ,pr_dscritic        => vr_dscritic);
            -- Verificar se ocorreu erro
            pc_raise_error('ddda0001.pc_remessa_tit_tab_dda:',vr_cdcritic,vr_dscritic,false);
            --
            -- Atualizar status da remessa de títulos DDA      
            pc_atualiza_status_envio_dda(pr_tab_remessa_dda => vr_tab_remessa_dda
                                        ,pr_tpdenvio        => 2);
            --
            --commit para cada lote de títulos integrados com a JDNPC
            commit;
            --
          end if;
          --
        exception
          when others then
            BEGIN
              cecred.pc_internal_exception;
              --
              vr_iderro := 'S';--ocorreu erro no processamento
              --
              pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                     ,pr_dsmensag => 'Remessa titulos JDNPC:');
              --
              --executa rollback do lote, limpa tabelas de memoria e vai para o próximo lote
              rollback;
              vr_tab_lote_titulo.delete;
              vr_tab_remessa_dda.delete;
              vr_tab_retorno_dda.delete;
              --
            end;
        end;
        --
      end loop; --loop c_lote_tit
      close c_lote_tit;
      --
      --antes de encerrar o procedimento limpa as tabelas de memoria
      vr_tab_lote_titulo.delete;
      vr_tab_remessa_dda.delete;
      vr_tab_retorno_dda.delete;
      --
      --commit final do procedimento
      commit;
      npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'baca_npc_registro_titulos_01');
      --
    exception
      when others then
        begin
          --
          vr_iderro := 'S';--ocorreu erro no processamento
          --
          pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                 ,pr_dsmensag => 'pc_processa_carga_inicial(Cooper:'||pr_cdcooper_in||'):');
          --
          rollback;
          npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'baca_npc_registro_titulos_02');
          raise_application_error(-20001,'pc_processa_carga_inicial',true);
          --
        end;
    end pc_processa_carga_inicial;
    --
  begin
    --
        pc_processa_carga_inicial(pr_cdcooper_in => pr_cdcooper_in
                                 ,pr_rw_crapdat => pr_rw_crapdat
                                 ,pr_dtcrgrol => trunc(sysdate)
                                 ,pr_vlrollou => 0);
    --
  end pc_carga_inic_npc;
  --
begin
  --
  declare
    --
    vr_tab_sab t_tab_sab;
    vr_cdcritic number;
    vr_dscritic varchar2(32000);
    vr_cdcooper number;
    --exceptions
    vr_exc_saida exception;
    --
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    --
  begin
    --
    vr_tab_sab.delete;
    --
    for r_cop in (
                  select cop.cdcooper
                  from crapcop cop
                  where cop.cdcooper <> 3
                    and cop.flgativo = 1
                  order by cop.cdcooper
                 )
    loop
      --
      vr_idprglog := 0;
      vr_cdcooper := r_cop.cdcooper;
      --
      pc_controla_log_batch(pr_cdcooper_in   => vr_cdcooper
                           ,pr_dstiplog      => 'I');
      --
      --busca a data de processo da cooperativa
      OPEN  BTCH0001.cr_crapdat(r_cop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Verificar se existe informação, e gerar erro caso não exista
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
        -- Gerar exceção
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      END IF;
      -- Fechar 
      CLOSE BTCH0001.cr_crapdat;
      --
      pc_carga_inic_npc(pr_cdcooper_in => vr_cdcooper
                       ,pr_rw_crapdat => rw_crapdat
                       ,pr_qtlottit => 10
                       ,pr_tab_sab => vr_tab_sab);
      --
      pc_controla_log_batch(pr_cdcooper_in   => vr_cdcooper
                           ,pr_dstiplog      => 'F');
      --
    end loop;
    --
    vr_tab_sab.delete;
    --
  exception
    when vr_exc_saida then
      begin
        --
        vr_iderro := 'S';--ocorreu erro no processamento
        -- Se foi retornado apenas código
        if nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
          -- buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        end if;
        -- Log de erro da execução
        pc_controla_log_batch(pr_cdcooper_in   => vr_cdcooper
                             ,pr_dstiplog      => 'E'
                             ,pr_dscritic      => vr_dscritic
                             ,pr_cdcriticidade => 1
                             ,pr_cdmensagem    => vr_cdcritic);
        --
      end;
    when others then
      begin
        --
        vr_iderro := 'S';--ocorreu erro no processamento
        --
        pc_captura_registra_log(pr_cdcooper_in => vr_cdcooper
                               ,pr_dsmensag => 'pc_crps618 Geral(Cooper:'||3||'):');
        --
      end;
  end;
  --commit final quando data de movimento da CIP é diferente de trunc(sysdate)
  commit;
  npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'baca_npc_registro_titulos_03');
  --
end;
