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
    SELECT crapcob_rowid, tppessoa, nrinssac, dhoperac, nrdident, nratutit
  bulk collect into vr_tab_titulo
  FROM (SELECT cob.rowid crapcob_rowid,
               decode(cob.cdtpinsc, 1, 'F', 'J') tppessoa,
               cob.nrinssac,
               to_date(lgjd."DtHrOpJD", 'yyyymmddhh24miss') dhoperac,
               lgjd."NumIdentcTit" nrdident,
               lgjd."NumRefAtlCadTit" nratutit
          FROM crapcob                                  cob,
               tbjdnpcdstleg_jd2lg_optit@jdnpcbisql     lgjd,
               tbjdnpcdstleg_jd2lg_optit_err@jdnpcbisql jdlger
         WHERE cob.incobran = 0
           AND (cob.inenvcip = 4 OR
               (cob.inenvcip = 2 AND cob.dhenvcip < trunc(SYSDATE) - 1))
           AND cob.idopeleg = jdlger."IdOpLeg"
           AND cob.idtitleg = lgjd."IdTituloLeg"
              --
           AND lgjd."TpOpJD" IN ('RI')
           AND lgjd."SitOpJD" = 'RC'
           AND lgjd."CdLeg" = jdlger."CdLeg"
           AND lgjd."IdTituloLeg" = jdlger."IdTituloLeg"
           AND lgjd."IdOpLeg" = jdlger."IdOpLeg"
           AND lgjd."ISPBAdministrado" = jdlger."ISPBAdministrado"
        --
         GROUP BY cob.rowid,
                  decode(cob.cdtpinsc, 1, 'F', 'J'),
                  cob.nrinssac,
                  to_date(lgjd."DtHrOpJD", 'yyyymmddhh24miss'),
                  lgjd."NumIdentcTit",
                  lgjd."NumRefAtlCadTit"
        UNION
        SELECT tit.crapcob_rowid,
               tit.tppessoa,
               tit.nrinssac,
               to_date(lgjd."DtHrOpJD", 'yyyymmddhh24miss') dhoperac,
               lgjd."NumIdentcTit" nrdident,
               lgjd."NumRefAtlCadTit" nratutit
          FROM tbjdnpcdstleg_jd2lg_optit@jdnpcbisql lgjd,
               (SELECT cob.rowid crapcob_rowid,
                       decode(cob.cdtpinsc, 1, 'F', 'J') tppessoa,
                       cob.nrinssac,
                       TRIM(to_char(cob.idopeleg)) idopeleg,
                       TRIM(to_char(cob.idtitleg)) idtitleg
                  FROM crapcco cco, crapcob cob
                 WHERE cob.incobran = 0
                   AND cco.cddbanco = 85
                   AND cco.cddbanco = cob.cdbandoc
                   AND cco.nrdctabb = cob.nrdctabb
                   AND cco.nrconven = cob.nrcnvcob
                   AND cco.cdcooper = cob.cdcooper
                      --
                   AND cob.rowid IN ('AAAS/0ABcAALxEOAAP',
                                     'AAAS/0ABcAALv2LAAZ',
                                     'AAAS/0ABcAALWX3AAE',
                                     'AAAS/0ABcAAKNozAAT',
                                     'AAAS/0ABcAALVm2AAM',
                                     'AAAS/0ABcAALvG8AAf',
                                     'AAAS/0ABcAALv0NAAU',
                                     'AAAS/0ABcAALVm1AAb',
                                     'AAAS/0ABcAALuNBAAS',
                                     'AAAS/0ABcAAJ7TQAAd',
                                     'AAAS/0ABcAAJ7TQAAe',
                                     'AAAS/0ABcAAJ7TQAAf',
                                     'AAAS/0ABcAAJ7ePAAZ',
                                     'AAAS/0ABcAAJ7UQAAa',
                                     'AAAS/0ABcAAJ7UQAAb',
                                     'AAAS/0ABcAAKNUkAAb',
                                     'AAAS/0ABcAAKNUkAAc',
                                     'AAAS/0ABcAAKNUkAAd',
                                     'AAAS/0ABcAAKNUkAAe',
                                     'AAAS/0ABcAAKNUkAAf',
                                     'AAAS/0ABcAAKNVkAAI',
                                     'AAAS/0ABcAAKNVkAAJ',
                                     'AAAS/0ABcAAKNVkAAK',
                                     'AAAS/0ABcAAKNVkAAL',
                                     'AAAS/0ABcAAKNVkAAM',
                                     'AAAS/0ABcAAKNVkAAN',
                                     'AAAS/0ABcAAKNVkAAO',
                                     'AAAS/0ABcAAKNVkAAP',
                                     'AAAS/0ABcAAKNckAAR',
                                     'AAAS/0ABcAAKNckAAS',
                                     'AAAS/0ABcAAKNckAAT',
                                     'AAAS/0ABcAAKNckAAU',
                                     'AAAS/0ABcAAKNckAAV',
                                     'AAAS/0ABcAAKNckAAW',
                                     'AAAS/0ABcAAKNckAAX',
                                     'AAAS/0ABcAAKNckAAY',
                                     'AAAS/0ABcAAKNdkAAP',
                                     'AAAS/0ABcAAKNdkAAQ',
                                     'AAAS/0ABcAAKNdkAAR',
                                     'AAAS/0ABcAAKNdkAAS',
                                     'AAAS/0ABcAAKNdkAAT',
                                     'AAAS/0ABcAAKNdkAAU',
                                     'AAAS/0ABcAAKNdkAAV',
                                     'AAAS/0ABcAAKNekAAC',
                                     'AAAS/0ABcAAKNekAAD',
                                     'AAAS/0ABcAAKNekAAE',
                                     'AAAS/0ABcAAKNekAAF',
                                     'AAAS/0ABcAAKNekAAG',
                                     'AAAS/0ABcAAKNekAAH',
                                     'AAAS/0ABcAAKNekAAI',
                                     'AAAS/0ABcAAKNekAAJ',
                                     'AAAS/0ABcAAKNekAAK',
                                     'AAAS/0ABcAAKNekAAL',
                                     'AAAS/0ABcAAKNekAAM',
                                     'AAAS/0ABcAAKNekAAN',
                                     'AAAS/0ABcAAKNekAAO',
                                     'AAAS/0ABcAAKNekAAP',
                                     'AAAS/0ABcAAKNekAAQ',
                                     'AAAS/0ABcAAKNfkAAC',
                                     'AAAS/0ABcAAKNfkAAD',
                                     'AAAS/0ABcAAKNfkAAE',
                                     'AAAS/0ABcAAKNfkAAF',
                                     'AAAS/0ABcAAKNfkAAG',
                                     'AAAS/0ABcAAKNfkAAH',
                                     'AAAS/0ABcAAKNfkAAI',
                                     'AAAS/0ABcAAKNfkAAJ',
                                     'AAAS/0ABcAAKNfkAAK',
                                     'AAAS/0ABcAAKNfkAAL',
                                     'AAAS/0ABcAAKNfkAAM',
                                     'AAAS/0ABcAAKNfkAAN',
                                     'AAAS/0ABcAAKNfkAAO',
                                     'AAAS/0ABcAAKNfkAAP',
                                     'AAAS/0ABcAAKNfkAAQ',
                                     'AAAS/0ABcAAKNgkAAB',
                                     'AAAS/0ABcAAKNgkAAC',
                                     'AAAS/0ABcAAKNgkAAD',
                                     'AAAS/0ABcAAKNgkAAE',
                                     'AAAS/0ABcAAKNgkAAF',
                                     'AAAS/0ABcAAKNgkAAG',
                                     'AAAS/0ABcAAKNgkAAH',
                                     'AAAS/0ABcAAKNgkAAI',
                                     'AAAS/0ABcAAKNgkAAJ',
                                     'AAAS/0ABcAAKNgkAAK',
                                     'AAAS/0ABcAAKNgkAAL',
                                     'AAAS/0ABcAAKNgkAAM',
                                     'AAAS/0ABcAAKNgkAAN',
                                     'AAAS/0ABcAAKNgkAAO',
                                     'AAAS/0ABcAAKNgkAAP',
                                     'AAAS/0ABcAAKNgkAAQ',
                                     'AAAS/0ABcAAKNhkAAA',
                                     'AAAS/0ABcAAKNhkAAB',
                                     'AAAS/0ABcAAKNhkAAC')
                 GROUP BY cob.rowid,
                          decode(cob.cdtpinsc, 1, 'F', 'J'),
                          cob.nrinssac,
                          cob.idopeleg,
                          cob.idtitleg) tit
         WHERE lgjd."TpOpJD" = 'RI'
           AND lgjd."SitOpJD" = 'RC'
           AND lgjd."CdLeg" = 'LEG'
           AND lgjd."IdOpLeg" = tit.idopeleg
           AND lgjd."IdTituloLeg" = tit.idtitleg
           AND lgjd."ISPBAdministrado" = 5463212
         GROUP BY tit.crapcob_rowid,
                  tit.tppessoa,
                  tit.nrinssac,
                  to_date(lgjd."DtHrOpJD", 'yyyymmddhh24miss'),
                  lgjd."NumIdentcTit",
                  lgjd."NumRefAtlCadTit");
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
