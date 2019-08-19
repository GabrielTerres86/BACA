/*
  SCTASK0050363
  Script para atualizar no Aimaro os títulos que foram rejeitados e reprocessados
  com sucesso diretamente na Cabine JDNPC.
  Além de realizar a atualização esse script também envia o comando de baixa
  que não foi originalmente enviado para a CIP. Sem o envio do comando de baixa para a CIP
  os boletos liquidados continuam aparecendo no DDA dos pagadores.
*/
declare
  --
  type typ_reg_titulo is record
    (crapcob_rowid rowid
    ,tppessoa varchar2(1)
    ,nrinssac crapcob.nrinssac%type
    ,dhenvcip crapcob.dhenvcip%type
    ,nrdident crapcob.nrdident%type
    ,nratutit crapcob.nratutit%type
    ,cdbanpag crapcob.cdbanpag%type
    ,indpagto crapcob.indpagto%type
    ,incobran crapcob.incobran%type
    ,dtvencto crapcob.dtvencto%type
    ,vldescto crapcob.vldescto%type
    ,vlabatim crapcob.vlabatim%type
    ,flgdprot crapcob.flgdprot%type
    );
  type typ_tab_titulo is table of typ_reg_titulo index by pls_integer;
  --
begin
  --
  declare
    --
    vr_tab_titulo typ_tab_titulo;
    vr_qtregistro number(10) := 0;
    vr_qtreg_baixa number(10) := 0;
    vr_qtreg_inter number(10) := 0;
    vr_qtreg_intra number(10) := 0;
    vr_flgsacad integer;
    vr_tpdbaixa varchar2(1) := null;
    vr_cdmotivo varchar2(2);
    vr_cdcritic integer;
    vr_dscritic varchar2(2000);
    vr_des_erro varchar2(200);
    vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
    --
    --Tabelas de Memoria de Remessa
    vr_tab_remessa_dda ddda0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda ddda0001.typ_tab_retorno_dda;
    --
  begin
    --
    --limpa tabela de memória para inicializar processamento
    vr_tab_titulo.delete;
    --
    --carrega tabela de memória com os títulos que devem ser processados
    select cob.rowid crapcob_rowid
          ,decode(cob.cdtpinsc,1,'F','J') tppessoa
          ,cob.nrinssac
          ,to_date(lgjd."DtHrOpJD",'yyyymmddhh24miss') dhoperac
          ,lgjd."NumIdentcTit" nrdident
          ,lgjd."NumRefAtlCadTit" nratutit
          ,cob.cdbanpag
          ,cob.indpagto
          ,cob.incobran
          ,cob.dtvencto
          ,cob.vldescto
          ,cob.vlabatim
          ,cob.flgdprot
    bulk collect into vr_tab_titulo
    from crapceb ceb
        ,crapcob cob
        ,tbjdnpcdstleg_jd2lg_optit@jdnpcbisql lgjd
        ,tbjdnpcdstleg_jd2lg_optit_err@Jdnpcbisql jdlger
    where (cob.dtdpagto is null or cob.dtdpagto < trunc(sysdate)-1)
      and cob.dtvencto > trunc(sysdate)-nvl(ceb.qtdecprz,0)
      and ceb.nrconven = cob.nrcnvcob+0
      and ceb.nrdconta = cob.nrdconta+0
      and ceb.cdcooper = cob.cdcooper+0
      --
      and cob.incobran <> 0
      and (cob.inenvcip = 4 or (cob.inenvcip = 2 and cob.dhenvcip < trunc(sysdate)-5))
      and cob.idopeleg = lgjd."IdOpLeg"
      and cob.idtitleg = lgjd."IdTituloLeg"
      --
      and lgjd."TpOpJD" in ('RI')
      and lgjd."SitOpJD" = 'RC'
      and lgjd."CdLeg" = jdlger."CdLeg"
      and lgjd."IdTituloLeg" = jdlger."IdTituloLeg"
      and lgjd."IdOpLeg" = jdlger."IdOpLeg"
      and lgjd."ISPBAdministrado" = jdlger."ISPBAdministrado"
      --
--      and lgjd."IdTituloLeg" = '11903776'
--      and rownum < 11
--      and jdlger."CdErro" = 'EDDA0076'
    group by
           cob.rowid
          ,decode(cob.cdtpinsc,1,'F','J')
          ,cob.nrinssac
          ,to_date(lgjd."DtHrOpJD",'yyyymmddhh24miss')
          ,lgjd."NumIdentcTit"
          ,lgjd."NumRefAtlCadTit"
          ,cob.cdbanpag
          ,cob.indpagto
          ,cob.incobran
          ,cob.dtvencto
          ,cob.vldescto
          ,cob.vlabatim
          ,cob.flgdprot;
    --
    --commit para baixar as operações pendentes abertas pelo select no SQL Server
    commit;
    --
    --processar somente se existirem registros na tabela de memória
    if nvl(vr_tab_titulo.count,0) > 0 then
      --
      for i in vr_tab_titulo.first .. vr_tab_titulo.last
      loop
        --
        vr_qtregistro := vr_qtregistro + 1;
        --
        update crapcob cob
        set cob.insitpro = 3 -- 3-RC registro CIP
           ,cob.flgcbdda = 1
           ,cob.inenvcip = 3 -- confirmado
           ,cob.dhenvcip = nvl(vr_tab_titulo(i).dhenvcip,cob.dhenvcip)
           ,cob.nrdident = nvl(vr_tab_titulo(i).nrdident,cob.nrdident)
           ,cob.nratutit = nvl(vr_tab_titulo(i).nratutit,cob.nratutit)
        where cob.rowid = vr_tab_titulo(i).crapcob_rowid;
        --
        vr_flgsacad := 0;
        -- verificar se o pagador eh DDA         
        ddda0001.pc_verifica_sacado_dda(pr_tppessoa => vr_tab_titulo(i).tppessoa
                                       ,pr_nrcpfcgc => vr_tab_titulo(i).nrinssac
                                       ,pr_flgsacad => vr_flgsacad
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
        --
        if vr_flgsacad = 1 THEN
          -- A4 = Pagador DDA
          vr_cdmotivo := 'A4';
          --
          --atualiza o retorno do cooperado
          update crapret ret
          set cdmotivo = vr_cdmotivo || cdmotivo
          where ret.cdocorre = 2 -- 2=Confirmacao de registro de boleto
            and (ret.cdcooper
                ,ret.nrdconta
                ,ret.nrcnvcob
                ,ret.nrdocmto)
             in (
                 select cob.cdcooper
                       ,cob.nrdconta
                       ,cob.nrcnvcob
                       ,cob.nrdocmto
                 from crapcob cob
                 where cob.rowid = vr_tab_titulo(i).crapcob_rowid
                );
          --
        end if;
        --
        --gera log indicando que o titulo está registrado
        paga0001.pc_cria_log_cobranca(pr_idtabcob => vr_tab_titulo(i).crapcob_rowid
                                     ,pr_cdoperad => '1'
                                     ,pr_dtmvtolt => sysdate
                                     ,pr_dsmensag => 'Titulo Registrado - CIP '||to_char(vr_tab_titulo(i).dhenvcip,'dd/mm/yyyy hh24:mi:ss')
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
        --
        -- (0)Liq Interbancaria
        -- (1)Liq Intrabancaria
        -- (2)Solicitacao Cedente
        -- (3)Envio p/ Protesto
        -- (4)Baixa por Decurso de Prazo
        if vr_tab_titulo(i).incobran = 5 then
          if (vr_tab_titulo(i).cdbanpag = 85) or (vr_tab_titulo(i).cdbanpag = 11 and vr_tab_titulo(i).indpagto <> 0) then
            vr_tpdbaixa := '1';
            vr_qtreg_intra := vr_qtreg_intra + 1;
          else 
            vr_tpdbaixa := '0';
            vr_qtreg_inter := vr_qtreg_inter + 1;
          end if;
        else
          vr_tpdbaixa := '2';
          vr_qtreg_baixa := vr_qtreg_baixa + 1;
        end if;
        --
        vr_tab_remessa_dda.delete;
        vr_tab_retorno_dda.delete;
        --
        ddda0001.pc_procedimentos_dda_jd(pr_rowid_cob => vr_tab_titulo(i).crapcob_rowid --ROWID da Cobranca
                                        ,pr_tpoperad => 'B' --Tipo Operacao
                                        ,pr_tpdbaixa => vr_tpdbaixa --Tipo de Baixa
                                        ,pr_dtvencto => vr_tab_titulo(i).dtvencto --Data Vencimento
                                        ,pr_vldescto => vr_tab_titulo(i).vldescto --Valor Desconto
                                        ,pr_vlabatim => vr_tab_titulo(i).vlabatim --Valor Abatimento
                                        ,pr_flgdprot => vr_tab_titulo(i).flgdprot --Flag Protesto
                                        ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa DDA
                                        ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela retorno DDA
                                        ,pr_cdcritic => vr_cdcritic --Codigo Critica
                                        ,pr_dscritic => vr_dscritic); --Descricao Critica
        --
        if nvl(vr_cdcritic,0) > 0 or vr_dscritic is not null then
          CECRED.pc_log_programa(pr_dstiplog      => 'O'
                                ,pr_cdprograma    => 'REP_BXO_REJ_NPC'
                                ,pr_cdcooper      => 3
                                ,pr_tpexecucao    => 2 --job
                                ,pr_tpocorrencia  => 4
                                ,pr_cdcriticidade => 0
                                ,pr_cdmensagem    => 0
                                ,pr_dsmensagem    => vr_tab_titulo(i).crapcob_rowid||'-'||nvl(vr_cdcritic,0)||':'||vr_dscritic
                                ,pr_idprglog      => vr_idprglog
                                ,pr_nmarqlog      => NULL);
          rollback;
        else
          commit;
        end if;
        --
      end loop;
      --
    end if;
    --
    commit;
    --
    dbms_output.put_line('vr_qtregistro :'||vr_qtregistro);
    dbms_output.put_line('vr_qtreg_baixa:'||vr_qtreg_baixa);
    dbms_output.put_line('vr_qtreg_inter:'||vr_qtreg_inter);
    dbms_output.put_line('vr_qtreg_intra:'||vr_qtreg_intra);
    --
  end;
  --
exception
  when others then
    declare
      vr_dscritic varchar2(2000);
    begin
      vr_dscritic := 'Falha geral:'
                   ||dbms_utility.format_error_backtrace
            ||' - '||dbms_utility.format_error_stack;
      rollback;
      raise_application_error(-20001,vr_dscritic,true);
    end;
end;
