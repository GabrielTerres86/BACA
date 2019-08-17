/*
  SCTASK0050363  
  Script para atualizar no Aimaro os títulos que foram rejeitados e reprocessados
  com sucesso diretamente na Cabine JDNPC.
  Necessário essa atualização para garantir que a baixa efetiva seja processada
  após o pagamento do título.
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
    );
  type typ_tab_titulo is table of typ_reg_titulo index by pls_integer;
  --
begin
  --
  declare
    --
    vr_tab_titulo typ_tab_titulo;
    vr_qtregistro number(10) := 0;
    vr_flgsacad integer;
    vr_cdmotivo varchar2(2);
    vr_cdcritic integer;
    vr_dscritic varchar2(2000);
    vr_des_erro varchar2(200);
    --
  begin
    --
    --limpa tabela de memória para inicializar processamento
    vr_tab_titulo.delete;
    --
    --carrega tabela de memória com os títulos que devem ser processados
    select crapcob_rowid
          ,tppessoa
          ,nrinssac
          ,dhoperac
          ,nrdident
          ,nratutit
    bulk collect into vr_tab_titulo
    from
    (
    select cob.rowid crapcob_rowid
          ,decode(cob.cdtpinsc,1,'F','J') tppessoa
          ,cob.nrinssac
          ,to_date(lgjd."DtHrOpJD",'yyyymmddhh24miss') dhoperac
          ,lgjd."NumIdentcTit" nrdident
          ,lgjd."NumRefAtlCadTit" nratutit
    from crapcob cob
        ,tbjdnpcdstleg_jd2lg_optit@jdnpcbisql lgjd
        ,tbjdnpcdstleg_jd2lg_optit_err@Jdnpcbisql jdlger
    where cob.incobran = 0
      and (cob.inenvcip = 4 or (cob.inenvcip = 2 and cob.dhenvcip < trunc(sysdate)-1))
      and cob.idopeleg = jdlger."IdOpLeg"
      and cob.idtitleg = lgjd."IdTituloLeg"
      --
      and lgjd."TpOpJD" in ('RI')
      and lgjd."SitOpJD" = 'RC'
      and lgjd."CdLeg" = jdlger."CdLeg"
      and lgjd."IdTituloLeg" = jdlger."IdTituloLeg"
      and lgjd."IdOpLeg" = jdlger."IdOpLeg"
      and lgjd."ISPBAdministrado" = jdlger."ISPBAdministrado"
      --
    group by
           cob.rowid
          ,decode(cob.cdtpinsc,1,'F','J')
          ,cob.nrinssac
          ,to_date(lgjd."DtHrOpJD",'yyyymmddhh24miss')
          ,lgjd."NumIdentcTit"
          ,lgjd."NumRefAtlCadTit"
    union
    select tit.crapcob_rowid
          ,tit.tppessoa
          ,tit.nrinssac
          ,to_date(lgjd."DtHrOpJD",'yyyymmddhh24miss') dhoperac
          ,lgjd."NumIdentcTit" nrdident
          ,lgjd."NumRefAtlCadTit" nratutit
    from tbjdnpcdstleg_jd2lg_optit@jdnpcbisql lgjd
        ,(
          select cob.rowid crapcob_rowid
                ,decode(cob.cdtpinsc,1,'F','J') tppessoa
                ,cob.nrinssac
                ,trim(to_char(cob.idopeleg)) idopeleg
                ,trim(to_char(cob.idtitleg)) idtitleg
          from crapcco cco
              ,crapcob cob
          where cob.incobran = 0
            and cco.cddbanco = 85
            and cco.cddbanco = cob.cdbandoc
            and cco.nrdctabb = cob.nrdctabb
            and cco.nrconven = cob.nrcnvcob
            and cco.cdcooper = cob.cdcooper
            --
            and cob.idtitleg > 0
            and cob.cdbandoc = 85
            and cob.dhenvcip >= to_date('01032019','ddmmyyyy')
            and cob.inregcip in (0,1,2)
            and cob.inenvcip = 2
            and cob.cdcooper >= 1
          group by 
                 cob.rowid
                ,decode(cob.cdtpinsc,1,'F','J')
                ,cob.nrinssac
                ,cob.idopeleg
                ,cob.idtitleg
         ) tit
    where lgjd."TpOpJD" = 'RI'
      and lgjd."SitOpJD" = 'RC'
      and lgjd."CdLeg" = 'LEG'
      and lgjd."IdOpLeg" = tit.idopeleg
      and lgjd."IdTituloLeg" = tit.idtitleg
      and lgjd."ISPBAdministrado" = 5463212
    group by
           tit.crapcob_rowid
          ,tit.tppessoa
          ,tit.nrinssac
          ,to_date(lgjd."DtHrOpJD",'yyyymmddhh24miss')
          ,lgjd."NumIdentcTit"
          ,lgjd."NumRefAtlCadTit"
    );
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
        --commit a cada 50 registros
        if mod(vr_qtregistro,50) = 0 then
          commit;
        end if;
        --
      end loop;
      --
    end if;
    --
    commit;
    --
    dbms_output.put_line('vr_qtregistro:'||vr_qtregistro);
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
