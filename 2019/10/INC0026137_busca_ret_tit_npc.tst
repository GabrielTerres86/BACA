PL/SQL Developer Test script 3.0
306
/*
  INC0026137  
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
  CURSOR cr_crapcob (pr_rowid IN ROWID) IS
  SELECT cob.insitpro,
         cob.flgcbdda,
         cob.inenvcip,
         cob.dhenvcip,
         cob.nrdident,
         cob.nratutit 
    FROM crapcob cob
   WHERE rowid = pr_rowid;
   rw_crapcob cr_crapcob%ROWTYPE;
  
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
    
    vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
    vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0026137';
    vr_nmarqimp        VARCHAR2(100)  := 'INC0026137-rollback.sql';  
    vr_ind_arquiv      utl_file.file_type;
    vr_cobrowid ROWID;
    --
  begin

    --Criar arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                            ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                            ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);      --> erro
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN        
      dbms_output.put_line('Erro ao criar arquivo');
    END IF;
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
                   AND cob.rowid IN ('AAAS/0ABeAAC1G2AAF',
                                     'AAAS/0ABkAADB3RAAS',
                                     'AAAS/0ABdAAEhbZAAt',
                                     'AAAS/0ABkAADE6TAAL',
                                     'AAAS/0ABdAADCiLAAL',
                                     'AAAS/0ABfAAEErQAAY',
                                     'AAAS/0ABkAADB3RAAV',
                                     'AAAS/0ABkAADC/wAAK',
                                     'AAAS/0ABdAAEgoNAAA',
                                     'AAAS/0ABdAAEgoNAAB',
                                     'AAAS/0ABfAAEF6LAAP',
                                     'AAAS/0ABfAAEF6LAAQ',
                                     'AAAS/0ABfAAEF7LAAJ',
                                     'AAAS/0ABfAAEF7LAAK',
                                     'AAAS/0ABfAAEF7LAAL',
                                     'AAAS/0ABfAAEF8LAAI',
                                     'AAAS/0ABfAAEF8LAAO',
                                     'AAAS/0ABfAAEF8LAAP',
                                     'AAAS/0ABfAAEF8LAAQ',
                                     'AAAS/0ABfAAEF8LAAR',
                                     'AAAS/0ABfAAEF9LAAD',
                                     'AAAS/0ABfAAEF9LAAE',
                                     'AAAS/0ABeAAEK/QAAV',
                                     'AAAS/0ABkAADDpXAAS',
                                     'AAAS/0ABcAAEhptAAL',
                                     'AAAS/0ABbAADpKtAAF',
                                     'AAAS/0ABkAADFC5AAe',
                                     'AAAS/0ABfAAEF1JAAO',
                                     'AAAS/0ABkAADC/wAAJ',
                                     'AAAS/0ABkAADE7DAAe',
                                     'AAAS/0ABfAAEFW2AAY',
                                     'AAAS/0ABkAADC0fAAb',
                                     'AAAS/0ABkAADCJ1AAj',
                                     'AAAS/0ABkAADE2yAAu',
                                     'AAAS/0ABkAADCpkAAQ',
                                     'AAAS/0ABkAADCpkAAR',
                                     'AAAS/0ABkAADCpkAAS',
                                     'AAAS/0ABkAADCpkAAT',
                                     'AAAS/0ABkAADCpkAAU',
                                     'AAAS/0ABkAADCpkAAV',
                                     'AAAS/0ABkAADCpkAAW',
                                     'AAAS/0ABkAADCokAAS',
                                     'AAAS/0ABkAADCokAAT',
                                     'AAAS/0ABkAADCokAAU',
                                     'AAAS/0ABkAADCokAAV',
                                     'AAAS/0ABkAADCokAAW',
                                     'AAAS/0ABkAADCtSAAM',
                                     'AAAS/0ABeAAC1gjAAj',
                                     'AAAS/0ABeAAELVuAAG',
                                     'AAAS/0ABeAAELVuAAH',
                                     'AAAS/0ABcAAEhtdAAb',
                                     'AAAS/0ABcAAEhtdAAc',
                                     'AAAS/0ABcAAEhtdAAd',
                                     'AAAS/0ABeAAC1F2AAX',
                                     'AAAS/0ABeAAC1F2AAY',
                                     'AAAS/0ABeAAC1G2AAB',
                                     'AAAS/0ABeAAC1G2AAC',
                                     'AAAS/0ABeAAC1G2AAD',
                                     'AAAS/0ABeAAC1G2AAE',
                                     'AAAS/0ABfAAEEluAAg',
                                     'AAAS/0ABfAAEEnuAAB')
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

        OPEN cr_crapcob(vr_tab_titulo(i).crapcob_rowid);
        FETCH cr_crapcob INTO rw_crapcob;
        
        IF cr_crapcob%FOUND THEN
          CLOSE cr_crapcob;
           -- Gerar linha de rollback
           gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 
                                          'update crapcob cob '||
                                              'set cob.insitpro = '''||rw_crapcob.insitpro||''''||
                                                ' ,cob.flgcbdda = '''||rw_crapcob.flgcbdda||''''||
                                                ' ,cob.inenvcip = '''||rw_crapcob.inenvcip||''''||
                                                ' ,cob.dhenvcip = '''||rw_crapcob.dhenvcip||''''||
                                                ' ,cob.nrdident = '''||null||''''||
                                                ' ,cob.nratutit = '''||null||''''||
                                               'where cob.rowid = '''||vr_tab_titulo(i).crapcob_rowid||
                                               ''';' ||chr(13));
        ELSE
          CLOSE cr_crapcob;
        END IF;       
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
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'commit;'); 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;        
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
      dbms_output.put_line(vr_dscritic||' - '||SQLERRM);
    end;
end;
0
0
