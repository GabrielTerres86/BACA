PL/SQL Developer Test script 3.0
321
DECLARE

  CURSOR cr_crapcob IS
    SELECT cob.nrdocmto, cob.cdcooper, cob.nrcnvcob, cob.rowid, cob.idtitleg, cob.idopeleg, decode(cob.cdtpinsc,1,'F','J') tppessoa, cob.nrinssac, cob.nrdconta
      FROM crapcob cob, crapret ret
     WHERE cob.cdcooper >= 1
       AND cob.dtmvtolt = '18/02/2020'
       AND cob.idlottck IS NOT NULL
       AND cob.incobran = 0
       AND cob.inenvcip = 2
       AND ret.cdcooper(+) = cob.cdcooper
       AND ret.nrdconta(+) = cob.nrdconta
       AND ret.nrcnvcob(+) = cob.nrcnvcob
       AND ret.nrdocmto(+) = cob.nrdocmto
       AND ret.dtocorre(+) = '18/02/2020'
       AND ret.cdocorre(+) = 2
       AND ret.nrdocmto IS NULL
    UNION
    SELECT cob.nrdocmto, cob.cdcooper, cob.nrcnvcob, cob.rowid, cob.idtitleg, cob.idopeleg, decode(cob.cdtpinsc,1,'F','J') tppessoa, cob.nrinssac, cob.nrdconta
      FROM crapcob cob, crapret ret
     WHERE cob.cdcooper >= 1
       AND cob.dtmvtolt = '21/02/2020'
       AND cob.idlottck IS NOT NULL
       AND cob.incobran = 0
       AND cob.inenvcip = 2
       AND ret.cdcooper(+) = cob.cdcooper
       AND ret.nrdconta(+) = cob.nrdconta
       AND ret.nrcnvcob(+) = cob.nrcnvcob
       AND ret.nrdocmto(+) = cob.nrdocmto
       AND ret.dtocorre(+) = '21/02/2020'
       AND ret.cdocorre(+) = 2
       AND ret.nrdocmto IS NULL;

  CURSOR cr_crapceb(pr_cdcooper crapceb.cdcooper%TYPE
                   ,pr_nrconven crapceb.nrconven%TYPE) IS
    SELECT flceeexp
      FROM crapceb
     WHERE cdcooper = pr_cdcooper
       AND nrconven = pr_nrconven;

  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.cdbcoctl
         , cop.cdagectl
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  CURSOR cr_retnpc (pr_cdlegado IN tbjdnpcdstleg_jd2lg_optit."CdLeg"@jdnpcbisql%type
                   ,pr_nrispbif IN tbjdnpcdstleg_jd2lg_optit."ISPBAdministrado"@jdnpcbisql%TYPE
                   ,pr_idtitleg IN tbjdnpcdstleg_jd2lg_optit."IdTituloLeg"@jdnpcbisql%TYPE
                   ,pr_idopeleg IN tbjdnpcdstleg_jd2lg_optit."IdOpLeg"@jdnpcbisql%TYPE) IS
    SELECT tit."ISPBAdministrado" AS nrispbif
          ,tit."TpOpJD"           AS tpoperac
          ,tit."IdOpJD"           AS idoperac
          ,tit."DtHrOpJD"         AS dhoperac
          ,tit."SitOpJD"          AS cdstiope
          ,tit."IdTituloLeg"      AS idtitleg
          ,tit."NumIdentcTit"     AS idtitnpc
          ,tit."IdOpLeg"          AS idopeleg
          ,tit."IdOpJD"           AS iddopeJD
          ,tit."NumRefAtlCadTit"  AS nratutit
      FROM tbjdnpcdstleg_jd2lg_optit@jdnpcbisql tit
     WHERE tit."CdLeg"            = pr_cdlegado
       AND tit."ISPBAdministrado" = pr_nrispbif
       AND tit."IdTituloLeg"      = pr_idtitleg
       AND tit."IdOpLeg"          = pr_idopeleg
       AND tit."TpOpJD"           = 'RI'
     ORDER BY tit."DtHrOpJD" ASC;
  rw_retnpc cr_retnpc%ROWTYPE;

  vr_cdmotivo VARCHAR2(10);
  vr_flceeexp crapceb.flceeexp%TYPE;
  vr_exc_erro EXCEPTION;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;

  vr_insitpro   crapcob.insitpro%TYPE;
  vr_inenvcip   crapcob.inenvcip%TYPE;
  vr_flgcbdda   crapcob.flgcbdda%TYPE;
  vr_dhenvcip   crapcob.dhenvcip%TYPE;
  vr_dsmensag   crapcol.dslogtit%TYPE;
  vr_inregcip   crapcob.inregcip%TYPE := 1;
  vr_flgsacad   INTEGER := 0;    
  vr_des_erro   VARCHAR2(100);

  PROCEDURE pc_trata_retorno_erro ( pr_idtabcob       IN  ROWID                   --> rowid crapcob
                                   ,pr_tpdopera       IN  VARCHAR2                --> Tipo de operacao
                                   ,pr_idtitleg       IN  crapcob.idtitleg%TYPE   --> Identificador do titulo no legado
                                   ,pr_idopeleg       IN  crapcob.idopeleg%TYPE   --> Identificador da operadao do legado
                                   ,pr_iddopeJD       IN  VARCHAR2) IS            --> Identificador da operadao da JD
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_trata_retorno_erro
    --  Sistema  : DDDA
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2017.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para tratar as criticas no retorno da CIP-NPC
    --
    -- Alteracoes:
    ---------------------------------------------------------------------------------------------------------------

    ---------->>> CURSORES <<<-----------
    --> Listar criticas da operacao
    CURSOR cr_optiterr IS
    SELECT err."CdErro"   codderro,
           err."NmColuna" nmcoluna,
           NVL(dsc1."DESCRICAO",dsc2."DSC_ERRO") dsdoerro
      FROM TBJDNPCDSTLEG_JD2LG_OpTit_ERR@Jdnpcbisql err,
           TBJDMSG_ERROGEN@Jdnpcsql dsc1,
           TBJDNPC_ERRO@Jdnpcsql    dsc2
     WHERE err."CdLeg" = 'LEG'
       AND err."IdTituloLeg" = pr_idtitleg
       AND err."IdOpLeg"     = pr_idopeleg
       AND err."IdOpJD"      = pr_iddopejd
       AND err."CdErro"      = dsc1."CODERRO"(+)
       AND err."CdErro"      = dsc2."CD_ERRO"(+);
    
    ---------->>> VARIAVEIS <<<-----------
    vr_dscritic   VARCHAR2(2000);
    vr_des_erro   VARCHAR2(100);
    
  BEGIN
    
    CASE pr_tpdopera
      WHEN 'I' THEN
        vr_dscritic := 'Inclusao';
      WHEN 'A' THEN
        vr_dscritic := 'Alteracao';
      WHEN 'B' THEN
        vr_dscritic := 'Baixa';
      ELSE
        vr_dscritic := 'Operacao';
    END CASE;

    vr_dscritic := vr_dscritic || ' Rejeitada na CIP';

    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => pr_idtabcob
                                 ,pr_cdoperad => '1'
                                 ,pr_dtmvtolt => SYSDATE
                                 ,pr_dsmensag => vr_dscritic
                                 ,pr_des_erro => vr_des_erro
                                 ,pr_dscritic => vr_dscritic);

    --> Listar criticas por campo
    FOR rw_optiterr IN cr_optiterr LOOP
      vr_dscritic := rw_optiterr.nmcoluna||': '||
                     rw_optiterr.codderro||' - '||rw_optiterr.dsdoerro;
      
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => pr_idtabcob
                                   ,pr_cdoperad => '1'
                                   ,pr_dtmvtolt => SYSDATE
                                   ,pr_dsmensag => trim(substr(vr_dscritic,1,350))
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);

    END LOOP;

  END pc_trata_retorno_erro;

BEGIN

  FOR RW_CRAPCOB IN CR_CRAPCOB LOOP
    BEGIN
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      vr_cdmotivo := NULL;
      -- 1) se inregcip = 1 -> vr_cdmotivo = 'R1' (concatenar);
      IF vr_inregcip = 1 THEN
        vr_cdmotivo := NVL(vr_cdmotivo,'') || 'R1';
      END IF;
      
      OPEN cr_crapceb(pr_cdcooper => rw_crapcob.cdcooper
                     ,pr_nrconven => rw_crapcob.nrcnvcob);
      FETCH cr_crapceb INTO vr_flceeexp;
      CLOSE cr_crapceb;

      -- 2) se pr_infrmems = 3 -> vr_cdmotivo = 'P1' (concatenar);
      IF vr_flceeexp = 1 THEN
        vr_cdmotivo := NVL(vr_cdmotivo,'') || 'P1';
      END IF;
      
      OPEN cr_crapcop(pr_cdcooper => rw_crapcob.cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;

      -- Gerar registro de controle de retorno
      COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.ROWID,
                                         pr_cdocorre => 2, -- Entrada Confirmada
                                         pr_cdmotivo => NVL(vr_cdmotivo,'  '),
                                         pr_vltarifa => 0,
                                         pr_cdbcoctl => rw_crapcop.cdbcoctl,
                                         pr_cdagectl => rw_crapcop.cdagectl,
                                         pr_dtmvtolt => trunc(SYSDATE),
                                         pr_cdoperad => 996,
                                         pr_nrremass => 0,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);

      -- Se retornar erro
      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      OPEN cr_retnpc(pr_cdlegado => 'LEG'
                    ,pr_nrispbif => '5463212'
                    ,pr_idtitleg => rw_crapcob.idtitleg
                    ,pr_idopeleg => rw_crapcob.idopeleg);
      FETCH cr_retnpc INTO rw_retnpc;
      CLOSE cr_retnpc;

      vr_insitpro := NULL;
      vr_inenvcip := NULL;
      vr_flgcbdda := NULL;
      vr_dhenvcip := NULL;
      vr_dsmensag := NULL;
      vr_inregcip := NULL;

      IF rw_retnpc.cdstiope = 'PJ' THEN
        vr_insitpro := 2; --> 2-RecebidoJD
      ELSIF rw_retnpc.cdstiope = 'RC' THEN --Registrado com sucesso
        vr_insitpro := 3; --> 3-RC registro CIP
        vr_inenvcip := 3; -- confirmado
        vr_flgcbdda := 1;
        vr_dhenvcip := SYSDATE;
        vr_dsmensag := 'Boleto registrado no Sistema Financeiro Nacional';
      ELSE
        vr_insitpro := 0; --> Sacado comun
        vr_inenvcip := 4; -- Rejeitadp
        vr_flgcbdda := 0;
        vr_dhenvcip := NULL;
        vr_dsmensag := 'Falha ao registrar boleto no Sistema Financeiro Nacional';
        vr_inregcip := 0; -- sem registro na CIP;
      END IF;

      BEGIN
        UPDATE crapcob cob
           SET cob.insitpro =  nvl(vr_insitpro,cob.insitpro)
             , cob.flgcbdda =  nvl(vr_flgcbdda,cob.flgcbdda)
             , cob.inenvcip =  nvl(vr_inenvcip,cob.inenvcip)
             , cob.dhenvcip =  nvl(vr_dhenvcip,cob.dhenvcip)
             , cob.inregcip =  nvl(vr_inregcip,cob.inregcip)
             , cob.nrdident =  nvl(rw_retnpc.idtitnpc,cob.nrdident)
             , cob.nratutit =  nvl(rw_retnpc.nratutit,cob.nratutit)
         WHERE cob.rowid    = rw_crapcob.rowid;
         
         IF rw_retnpc.cdstiope = 'RC' THEN

           DDDA0001.pc_verifica_sacado_DDA(pr_tppessoa => rw_crapcob.tppessoa
                                          ,pr_nrcpfcgc => rw_crapcob.nrinssac
                                          ,pr_flgsacad => vr_flgsacad
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
           
           IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
           END IF;

           IF vr_flgsacad = 1 THEN
             -- A4 = Pagador DDA
             vr_cdmotivo := 'A4';
           ELSE
             -- PC = Boleto PCR (ou NPC)
             vr_cdmotivo := 'PC';
           END IF;
           
           UPDATE crapret ret
              SET cdmotivo = vr_cdmotivo || cdmotivo
            WHERE ret.cdcooper = rw_crapcob.cdcooper
              AND ret.nrdconta = rw_crapcob.nrdconta
              AND ret.nrcnvcob = rw_crapcob.nrcnvcob
              AND ret.nrdocmto = rw_crapcob.nrdocmto
              AND ret.cdocorre = 2; -- 2=Confirmacao de registro de boleto

          END IF;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      --> Se conter mensagem deve gerar log
      IF trim(vr_dsmensag) IS NOT NULL THEN
        -- Cria o log da cobrança
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                     ,pr_cdoperad => '1'
                                     ,pr_dtmvtolt => SYSDATE
                                     ,pr_dsmensag => vr_dsmensag
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
        
        -- Se ocorrer erro
        IF vr_des_erro <> 'OK' THEN
          RAISE vr_exc_erro;
        END IF;
        
      END IF;
      
      --> Gerar log de rejeicao
      IF rw_retnpc.cdstiope IN ('EJ','EC') THEN
        pc_trata_retorno_erro ( pr_idtabcob   => rw_crapcob.rowid  --> ROWID crapcob
                               ,pr_tpdopera   => 'I'                  --> Tipo de operacao
                               ,pr_idtitleg   => rw_retnpc.idtitleg          --> Identificador do titulo no legado
                               ,pr_idopeleg   => rw_retnpc.idopeleg          --> Identificador da operadao do legado
                               ,pr_iddopeJD   => rw_retnpc.iddopeJD);        --> Identificador da operadao da JD
      END IF;
      
      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_compleme => vr_cdcritic||': '||vr_dscritic);
    END;
  END LOOP;

END;
0
0
