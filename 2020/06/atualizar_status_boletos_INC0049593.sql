DECLARE
  --
  CURSOR cr_boletos_npc IS
    SELECT tit."ISPBAdministrado" AS nrispbif
          ,tit."TpOpJD"           AS tpoperac
          ,tit."IdOpJD"           AS idoperac
          ,tit."DtHrOpJD"         AS dhoperac
          ,tit."SitOpJD"          AS cdstiope
          ,tit."IdTituloLeg"      AS idtitleg
          ,tit."NumIdentcTit"     AS idtitnpc
          ,tit."IdOpLeg"          AS idopeleg
          ,tit."IdOpJD"           AS iddopejd
          ,tit."NumRefAtlCadTit"  AS nratutit
          ,npc.cdcodbar
     FROM tbcobran_remessa_npc npc
         ,tbjdnpcdstleg_jd2lg_optit@jdnpcbisql tit
    WHERE npc.idtitleg = tit."IdTituloLeg"
      AND npc.idopeleg = tit."IdOpLeg"
      AND npc.dhoperad = 20200602172131
      AND tit."DtHrOpJD" = 20200602173519
      AND npc.tpoperad = 'I'
      AND tit."CdLeg" = 'LEG'
      AND tit."ISPBAdministrado" = '5463212'
      AND tit."TpOpJD" = 'RI'
      AND tit."SitOpJD" = 'RC';
  --
  CURSOR cr_quebra_barra(pr_cdcodbar tbcobran_remessa_npc.cdcodbar%TYPE) IS
    SELECT (SELECT ceb.cdcooper FROM crapceb ceb WHERE ceb.nrconven = to_number(substr(tt.dscodbarra,20,6)) AND ceb.nrdconta = to_number(substr(tt.dscodbarra,26,8))) cdcooper
          ,to_number(substr(tt.dscodbarra,20,6)) nrcnvcob
          ,to_number(substr(tt.dscodbarra,26,8)) nrdconta
          ,to_number(substr(tt.dscodbarra,34,9)) nrdocmto
          ,substr(tt.dscodbarra,26,17) nrnosnum
      FROM (SELECT pr_cdcodbar dscodbarra FROM dual) tt;
  rw_quebra_barra cr_quebra_barra%ROWTYPE;
  --
  CURSOR cr_crapcob(pr_cdcooper crapcob.cdcooper%TYPE
                   ,pr_nrdconta crapcob.nrdconta%TYPE
                   ,pr_nrcnvcob crapcob.nrcnvcob%TYPE
                   ,pr_nrdocmto crapcob.nrdocmto%TYPE) IS
    SELECT DECODE(cob.cdtpinsc,1,'F','J') tppessoa
          ,cob.ROWID rowidcob
          ,cob.*
      FROM crapcob cob
     WHERE cob.cdcooper = pr_cdcooper
       AND cob.nrdconta = pr_nrdconta
       AND cob.nrcnvcob = pr_nrcnvcob
       AND cob.nrdocmto = pr_nrdocmto;
  rw_crapcob cr_crapcob%ROWTYPE;
  --
  vr_insitpro   crapcob.insitpro%TYPE;
  vr_inenvcip   crapcob.inenvcip%TYPE;
  vr_flgcbdda   crapcob.flgcbdda%TYPE;
  vr_dhenvcip   crapcob.dhenvcip%TYPE;
  vr_dsmensag   crapcol.dslogtit%TYPE;
  vr_inregcip   crapcob.inregcip%TYPE;
  --
  vr_dscritic   VARCHAR2(2000);
  vr_des_erro   VARCHAR2(200);
  --
BEGIN
  --
  FOR rw_boletos_npc IN cr_boletos_npc LOOP
    --
    OPEN cr_quebra_barra(pr_cdcodbar => rw_boletos_npc.cdcodbar);
    FETCH cr_quebra_barra INTO rw_quebra_barra;
    IF cr_quebra_barra%FOUND THEN
      --
      CLOSE cr_quebra_barra;
      OPEN cr_crapcob(pr_cdcooper => rw_quebra_barra.cdcooper
                     ,pr_nrdconta => rw_quebra_barra.nrdconta
                     ,pr_nrcnvcob => rw_quebra_barra.nrcnvcob
                     ,pr_nrdocmto => rw_quebra_barra.nrdocmto);
      FETCH cr_crapcob INTO rw_crapcob;
      IF cr_crapcob%FOUND THEN
        --
        CLOSE cr_crapcob;
        vr_insitpro := NULL;
        vr_inenvcip := NULL;
        vr_flgcbdda := NULL;
        vr_dhenvcip := NULL;
        vr_dsmensag := NULL;
        vr_inregcip := NULL;
        --
        IF rw_crapcob.incobran IN (0, 3) THEN
          --
          vr_insitpro := 3;
          vr_inenvcip := 3;
          vr_flgcbdda := 1;
          vr_dhenvcip := SYSDATE;
          vr_dsmensag := 'Boleto registrado no Sistema Financeiro Nacional';
          vr_inregcip := 1;
          --
          BEGIN
            --
            UPDATE crapcob cob
               SET cob.incobran = 0
                  ,cob.dtdbaixa = NULL
                  ,cob.insitpro = NVL(vr_insitpro,cob.insitpro)
                  ,cob.flgcbdda = NVL(vr_flgcbdda,cob.flgcbdda)
                  ,cob.inenvcip = NVL(vr_inenvcip,cob.inenvcip)
                  ,cob.dhenvcip = NVL(vr_dhenvcip,cob.dhenvcip)
                  ,cob.inregcip = NVL(vr_inregcip,cob.inregcip)
                  ,cob.idtitleg = NVL(rw_boletos_npc.idtitleg,cob.idtitleg)
                  ,cob.idopeleg = NVL(rw_boletos_npc.idopeleg,cob.idopeleg)
                  ,cob.nrdident = NVL(rw_boletos_npc.idtitnpc,cob.nrdident)
                  ,cob.nratutit = NVL(rw_boletos_npc.nratutit,cob.nratutit)
             WHERE cob.rowid    = rw_crapcob.rowidcob;
            --
            PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                         ,pr_cdoperad => '1'
                                         ,pr_dtmvtolt => SYSDATE
                                         ,pr_dsmensag => vr_dsmensag
                                         ,pr_des_erro => vr_des_erro
                                         ,pr_dscritic => vr_dscritic);
            --
          EXCEPTION
            WHEN OTHERS THEN
              pc_internal_exception(pr_compleme => 'INC0049593');
            NULL;
          END;
          --
        END IF;
        --
        EXECUTE IMMEDIATE 'DELETE FROM CRAPRET RET'
                        ||' WHERE RET.CDCOOPER = '||rw_crapcob.cdcooper
                        ||' AND RET.NRDCONTA = '||rw_crapcob.nrdconta
                        ||' AND RET.NRCNVCOB = '||rw_crapcob.nrcnvcob
                        ||' AND RET.NRDOCMTO = '||rw_crapcob.nrdocmto
                        ||' AND RET.CDOCORRE = 2'
                        ||q'[ AND RET.DTREFATU = '02/06/2020']'
                        ||';';
        --
      ELSE
        CLOSE cr_crapcob;
        dbms_output.put_line( 'KO' );
      END IF;
    ELSE
      CLOSE cr_quebra_barra;
      dbms_output.put_line( 'KO' );
    END IF;
    --
  END LOOP;
  --
  COMMIT;
  --
END;
