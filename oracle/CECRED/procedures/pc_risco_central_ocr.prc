CREATE OR REPLACE PROCEDURE CECRED.PC_RISCO_CENTRAL_OCR(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa
                                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                                       ,pr_dscritic OUT VARCHAR2) AS           --> Texto de erro/critica encontrada
  BEGIN
    /* ............................................................................
     Programa: RISCO_CENTRAL_OCR
     Sistema : Atenda - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Daniel Silva(AMcom)
     Data    : Março/2018                           Ultima atualizacao: 09/03/2018

     Dados referentes ao programa:

     Frequencia: Diária
     Objetivo  : Gerar base consolidada da Central de Risco
     Alteracoes:
    ..............................................................................*/

  DECLARE
  --*** VARIÁVEIS ***--
    vr_exc_saida exception;
    vr_exc_fimprg exception;
    vr_inrisco_inclusao NUMBER(2) := NULL;
    vr_inrisco_rating   NUMBER(2) := NULL;
    vr_inrisco_atraso   NUMBER(2) := NULL;
    vr_inrisco_agravado NUMBER(2) := NULL;
    vr_inrisco_melhora  NUMBER(2) := NULL;
    vr_inrisco_operacao NUMBER(2) := NULL;
    vr_inrisco_cpf      NUMBER(2) := NULL;
    vr_inrisco_grupo    NUMBER(2) := NULL;
    vr_inrisco_final    NUMBER(2) := NULL;
    vr_inrisco_refin    NUMBER(2) := NULL;

    vr_valor_arrasto    NUMBER;

  --**************************--
  --*** CURSORES GENÉRICOS ***--
  --**************************--
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

    -- Calendário da cooperativa selecionada
    CURSOR cr_dat(pr_cdcooper INTEGER) IS
    SELECT dat.dtmvtolt
         , (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
              THEN dat.dtmvtoan
              ELSE dat.dtultdma END) dtmvtoan
         , dat.dtultdma
         , (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
              THEN dat.dtmvtoan
              ELSE dat.dtultdma END)-5 dtdelreg
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
    rw_dat cr_dat%ROWTYPE;

    -- Parâmetro do arrasto
    CURSOR cr_tab(pr_cdcooper IN crawepr.cdcooper%TYPE) IS
    SELECT t.dstextab
      FROM craptab t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nmsistem = 'CRED'
       AND t.tptabela = 'USUARI'
       AND t.cdempres = 11
       AND t.cdacesso = 'RISCOBACEN'
       AND t.tpregist = 000;
    rw_tab cr_tab%ROWTYPE;

    -- Cursor SEMRISCO - Busca contas que não possuem Central de Risco(CRAPRIS)
    CURSOR cr_semrisco(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT DISTINCT
             ass.cdcooper
           , ass.nrcpfcgc
           , ass.nrdconta
           , nvl(grp.nrdgrupo,0) nrdgrupo
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END innivris_cta
           , 2 innivris
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END innivris_ctl
        FROM crapass ass
           , crapgrp grp
       WHERE ass.cdcooper = pr_cdcooper
         --AND ass.dtdemiss IS NULL ???
         AND ass.cdcooper = grp.cdcooper(+)
         AND ass.nrdconta = grp.nrctasoc(+)
         AND ass.nrcpfcgc = grp.nrcpfcgc(+)
         AND NOT EXISTS (SELECT 1
                           FROM crapris ris
                          WHERE ris.dtrefere = rw_dat.dtmvtoan
                            AND ris.cdcooper = ass.cdcooper
                            AND ris.nrdconta = ass.nrdconta);

    -- Cursor EMP - EMPRESTIMOS
    CURSOR cr_risco_emp(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , ris.nrctremp
           , ris.cdmodali
           , ris.nrdgrupo
           , ris.dtrefere
           , ris.dtdrisco
           , ris.cdorigem
           , ris.inddocto
           , ris.vldivida
           , ris.qtdiaatr
           , ris.innivris
           , ris.innivori
           , NULL /*epr.inrisco_refin*/ inrisco_refin
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END innivris_cta
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END innivris_ctl                 
           , CASE WHEN wpr.dsnivori = 'A'  THEN 2
                  WHEN wpr.dsnivori = 'B'  THEN 3
                  WHEN wpr.dsnivori = 'C'  THEN 4
                  WHEN wpr.dsnivori = 'D'  THEN 5
                  WHEN wpr.dsnivori = 'E'  THEN 6
                  WHEN wpr.dsnivori = 'F'  THEN 7
                  WHEN wpr.dsnivori = 'G'  THEN 8
                  WHEN wpr.dsnivori = 'H'  THEN 9
                  WHEN wpr.dsnivori = 'HH' THEN 10
               ELSE 2 END innivori_ctr
           , CASE WHEN wpr.dsnivris = 'A'  THEN 2
                  WHEN wpr.dsnivris = 'B'  THEN 3
                  WHEN wpr.dsnivris = 'C'  THEN 4
                  WHEN wpr.dsnivris = 'D'  THEN 5
                  WHEN wpr.dsnivris = 'E'  THEN 6
                  WHEN wpr.dsnivris = 'F'  THEN 7
                  WHEN wpr.dsnivris = 'G'  THEN 8
                  WHEN wpr.dsnivris = 'H'  THEN 9
                  WHEN wpr.dsnivris = 'HH' THEN 10
               ELSE 2 END innivris_ctr                
        FROM crapris ris
           , crapass ass
           , crawepr wpr
           , crapepr epr
       WHERE ris.cdcooper = ass.cdcooper
         AND ris.nrdconta = ass.nrdconta
         AND ris.cdcooper = wpr.cdcooper
         AND ris.nrdconta = wpr.nrdconta
         AND ris.nrctremp = wpr.nrctremp
         AND ris.cdcooper = epr.cdcooper
         AND ris.nrdconta = epr.nrdconta
         AND ris.nrctremp = epr.nrctremp         
         AND ris.cdmodali IN(299,499) -- Empréstimos         
        -- AND ris.inddocto = 1
         AND ris.cdorigem = 3
         AND ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = rw_dat.dtmvtoan;

    -- Cursor AL - ADP/LIMITE
    CURSOR cr_riscoAL(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT DISTINCT ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , ris.nrctremp
           , ris.cdmodali
           , ris.nrdgrupo
           , ris.dtrefere
           , ris.dtdrisco
           , ris.cdorigem
           , ris.inddocto           
           , ris.qtdiaatr
           , ris.innivris
           , ris.innivori
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END innivris_cta
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END innivris_ctl                 
        FROM crapris ris
           , crapass ass
       WHERE ris.cdcooper = ass.cdcooper
         AND ris.nrdconta = ass.nrdconta
         AND ((ris.cdmodali IN(101,201) AND ris.inddocto = 1) 
              OR (ris.cdmodali = 1901 AND ris.inddocto = 3     -- ADP/Limite
                  AND NOT EXISTS (SELECT 1
                                    FROM crapris 
                                   WHERE cdcooper = pr_cdcooper
                                     AND dtrefere = rw_dat.dtmvtoan
                                     AND nrdconta = ris.nrdconta
                                     AND nrctremp = ris.nrctremp
                                     AND cdmodali IN(101,201))))
         AND ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = rw_dat.dtmvtoan;

    -- Cursor LD - LIMITE DESCONTO
    CURSOR cr_riscoLD(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT DISTINCT cdcooper
           , nrcpfcgc
           , nrdconta
           , nrctremp
           , cdmodali
           , cdorigem
           , inddocto           
           , nrdgrupo
           , dtrefere
           , min(dtdrisco) dtdrisco
           , qtdiaatr
           , innivris           
           , innivris_cta
           , innivris_ctl
      FROM (           
      SELECT DISTINCT ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , bdt.nrctrlim nrctremp
           , ris.cdmodali
           , ris.cdorigem
           , ris.inddocto           
           , ris.nrdgrupo
           , ris.dtrefere
           , max(ris.dtdrisco) dtdrisco
           , MAX(ris.qtdiaatr) qtdiaatr
           , ris.innivris           
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END innivris_cta
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END innivris_ctl                 
        FROM crapris ris
           , crapass ass
           , crapbdt bdt -- Desconto títulos
       WHERE ris.cdcooper = ass.cdcooper
         AND ris.nrdconta = ass.nrdconta
         AND ris.cdcooper = bdt.cdcooper
         AND ris.nrdconta = bdt.nrdconta               
         AND ris.nrctremp = bdt.nrborder
         --AND ris.inddocto = 1
         AND ris.cdmodali = 301 -- Desconto títulos
         AND ris.vldivida > vr_valor_arrasto -- Materialidade(Arrasto)
         AND ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = rw_dat.dtmvtoan
    GROUP BY ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , bdt.nrctrlim
           , ris.cdmodali
           , ris.cdorigem
           , ris.inddocto           
           , ris.nrdgrupo
           , ris.dtrefere
           , ris.innivris
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END
    UNION
      SELECT DISTINCT ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , bdc.nrctrlim nrctremp
           , ris.cdmodali
           , ris.cdorigem
           , ris.inddocto           
           , ris.nrdgrupo
           , ris.dtrefere
           , max(ris.dtdrisco) dtdrisco
           , MAX(ris.qtdiaatr) qtdiaatr
           , ris.innivris
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END innivris_cta
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END innivris_ctl                 
        FROM crapris ris
           , crapass ass
           , crapbdc bdc -- Desconto cheques
       WHERE ris.cdcooper = ass.cdcooper
         AND ris.nrdconta = ass.nrdconta
         AND ris.cdcooper = bdc.cdcooper
         AND ris.nrdconta = bdc.nrdconta         
         AND ris.nrctremp = bdc.nrborder
         --AND ris.inddocto = 1
         AND ris.cdmodali = 302 -- Desconto cheques
         AND ris.vldivida > vr_valor_arrasto -- Materialidade(Arrasto)
         AND ris.cdcooper = pr_cdcooper
         AND ris.dtrefere = rw_dat.dtmvtoan
    GROUP BY ris.cdcooper
           , ris.nrcpfcgc
           , ris.nrdconta
           , bdc.nrctrlim
           , ris.cdmodali
           , ris.cdorigem
           , ris.inddocto           
           , ris.cdorigem
           , ris.inddocto           
           , ris.nrdgrupo
           , ris.dtrefere
           , ris.innivris
           , CASE WHEN ass.dsnivris = 'A'  THEN 2
                  WHEN ass.dsnivris = 'B'  THEN 3
                  WHEN ass.dsnivris = 'C'  THEN 4
                  WHEN ass.dsnivris = 'D'  THEN 5
                  WHEN ass.dsnivris = 'E'  THEN 6
                  WHEN ass.dsnivris = 'F'  THEN 7
                  WHEN ass.dsnivris = 'G'  THEN 8
                  WHEN ass.dsnivris = 'H'  THEN 9
                  WHEN ass.dsnivris = 'HH' THEN 10
               ELSE NULL END
           , CASE WHEN ass.inrisctl = 'A'  THEN 2
                  WHEN ass.inrisctl = 'B'  THEN 3
                  WHEN ass.inrisctl = 'C'  THEN 4
                  WHEN ass.inrisctl = 'D'  THEN 5
                  WHEN ass.inrisctl = 'E'  THEN 6
                  WHEN ass.inrisctl = 'F'  THEN 7
                  WHEN ass.inrisctl = 'G'  THEN 8
                  WHEN ass.inrisctl = 'H'  THEN 9
                  WHEN ass.inrisctl = 'HH' THEN 10
               ELSE NULL END)
    GROUP BY cdcooper
           , nrcpfcgc
           , nrdconta
           , nrctremp
           , cdmodali
           , cdorigem
           , inddocto           
           , nrdgrupo
           , dtrefere
           , qtdiaatr
           , innivris
           , innivris_cta
           , innivris_ctl;

    -- Cursor contaX
    CURSOR cr_contaX(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT DISTINCT risX.cdcooper
           , risX.nrcpfcgc
           , risX.nrdconta
           , risX.nrdgrupo
           , MAX(risX.qtdiaatr) qtdiaatr
           , MAX(innivris_cta) innivris_cta   
           , MAX(innivris_ctl) innivris_ctl
              -- Emprestimos
        FROM (SELECT ris.cdcooper
                   , ris.nrcpfcgc
                   , ris.nrdconta
                   , ris.nrctremp
                   , ris.cdmodali
                   , ris.nrdgrupo
                   , ris.qtdiaatr
                   , ris.cdorigem
                   , (CASE WHEN ass.dsnivris = 'A'  THEN 2
                          WHEN ass.dsnivris = 'B'  THEN 3
                          WHEN ass.dsnivris = 'C'  THEN 4
                          WHEN ass.dsnivris = 'D'  THEN 5
                          WHEN ass.dsnivris = 'E'  THEN 6
                          WHEN ass.dsnivris = 'F'  THEN 7
                          WHEN ass.dsnivris = 'G'  THEN 8
                          WHEN ass.dsnivris = 'H'  THEN 9
                          WHEN ass.dsnivris = 'HH' THEN 10
                      ELSE NULL END) innivris_cta
                   , CASE WHEN ass.inrisctl = 'A'  THEN 2
                         WHEN ass.inrisctl = 'B'  THEN 3
                         WHEN ass.inrisctl = 'C'  THEN 4
                         WHEN ass.inrisctl = 'D'  THEN 5
                         WHEN ass.inrisctl = 'E'  THEN 6
                         WHEN ass.inrisctl = 'F'  THEN 7
                         WHEN ass.inrisctl = 'G'  THEN 8
                         WHEN ass.inrisctl = 'H'  THEN 9
                         WHEN ass.inrisctl = 'HH' THEN 10
                      ELSE NULL END innivris_ctl
                FROM crapris ris
                   , crapass ass
                   , crawepr wpr
               WHERE ris.cdcooper = ass.cdcooper
                 AND ris.nrdconta = ass.nrdconta
                 AND ris.cdcooper = wpr.cdcooper
                 AND ris.nrdconta = wpr.nrdconta
                 AND ris.nrctremp = wpr.nrctremp
                 AND ris.cdmodali IN(299,499)
                 --AND ris.inddocto = 1
                 AND ris.cdorigem = 3
                 AND ris.cdcooper = pr_cdcooper
                 AND ris.dtrefere = rw_dat.dtmvtoan
            UNION
              -- Limite desconto
              SELECT DISTINCT cdcooper
                            , nrcpfcgc
                            , nrdconta
                            , nrctremp
                            , cdmodali
                            , nrdgrupo
                            , cdorigem
                            , MAX(qtdiaatr) qtdiaatr
                            , MAX(innivris_cta) innivris_cta
                            , MAX(innivris_ctl) innivris_ctl
                       FROM ( SELECT DISTINCT ris.cdcooper
                                            , ris.nrcpfcgc
                                            , ris.nrdconta
                                            , bdt.nrctrlim nrctremp
                                            , ris.cdmodali
                                            , ris.nrdgrupo
                                            , ris.cdorigem
                                            , ris.qtdiaatr
                                            , (CASE WHEN ass.dsnivris = 'A'  THEN 2
                                                    WHEN ass.dsnivris = 'B'  THEN 3
                                                    WHEN ass.dsnivris = 'C'  THEN 4
                                                    WHEN ass.dsnivris = 'D'  THEN 5
                                                    WHEN ass.dsnivris = 'E'  THEN 6
                                                    WHEN ass.dsnivris = 'F'  THEN 7
                                                    WHEN ass.dsnivris = 'G'  THEN 8
                                                    WHEN ass.dsnivris = 'H'  THEN 9
                                                    WHEN ass.dsnivris = 'HH' THEN 10
                                                ELSE NULL END) innivris_cta
                                            , CASE WHEN ass.inrisctl = 'A'  THEN 2
                                                  WHEN ass.inrisctl = 'B'  THEN 3
                                                  WHEN ass.inrisctl = 'C'  THEN 4
                                                  WHEN ass.inrisctl = 'D'  THEN 5
                                                  WHEN ass.inrisctl = 'E'  THEN 6
                                                  WHEN ass.inrisctl = 'F'  THEN 7
                                                  WHEN ass.inrisctl = 'G'  THEN 8
                                                  WHEN ass.inrisctl = 'H'  THEN 9
                                                  WHEN ass.inrisctl = 'HH' THEN 10
                                               ELSE NULL END innivris_ctl                                                  
                                         FROM crapris ris
                                            , crapass ass
                                            , crapbdt bdt -- Desconto títulos
                                        WHERE ris.cdcooper = ass.cdcooper
                                          AND ris.nrdconta = ass.nrdconta
                                          AND ris.cdcooper = bdt.cdcooper
                                          AND ris.nrdconta = bdt.nrdconta               
                                          AND ris.nrctremp = bdt.nrborder
                                          --AND ris.inddocto = 1
                                          AND ris.cdmodali = 301 -- Desconto títulos
                                          AND ris.vldivida > vr_valor_arrasto -- Materialidade(Arrasto)
                                          AND ris.cdcooper = pr_cdcooper
                                          AND ris.dtrefere = rw_dat.dtmvtoan
                                     UNION
                                       SELECT DISTINCT ris.cdcooper
                                                     , ris.nrcpfcgc
                                                     , ris.nrdconta
                                                     , bdc.nrctrlim nrctremp
                                                     , ris.cdmodali
                                                     , ris.nrdgrupo
                                                     , ris.cdorigem
                                                     , ris.qtdiaatr
                                                     , (CASE WHEN ass.dsnivris = 'A'  THEN 2
                                                             WHEN ass.dsnivris = 'B'  THEN 3
                                                             WHEN ass.dsnivris = 'C'  THEN 4
                                                             WHEN ass.dsnivris = 'D'  THEN 5
                                                             WHEN ass.dsnivris = 'E'  THEN 6
                                                             WHEN ass.dsnivris = 'F'  THEN 7
                                                             WHEN ass.dsnivris = 'G'  THEN 8
                                                             WHEN ass.dsnivris = 'H'  THEN 9
                                                             WHEN ass.dsnivris = 'HH' THEN 10
                                                         ELSE NULL END) innivris_cta
                                            , CASE WHEN ass.inrisctl = 'A'  THEN 2
                                                  WHEN ass.inrisctl = 'B'  THEN 3
                                                  WHEN ass.inrisctl = 'C'  THEN 4
                                                  WHEN ass.inrisctl = 'D'  THEN 5
                                                  WHEN ass.inrisctl = 'E'  THEN 6
                                                  WHEN ass.inrisctl = 'F'  THEN 7
                                                  WHEN ass.inrisctl = 'G'  THEN 8
                                                  WHEN ass.inrisctl = 'H'  THEN 9
                                                  WHEN ass.inrisctl = 'HH' THEN 10
                                               ELSE NULL END innivris_ctl                                                           
                                         FROM crapris ris
                                            , crapass ass
                                            , crapbdc bdc -- Desconto cheques
                                        WHERE ris.cdcooper = ass.cdcooper
                                          AND ris.nrdconta = ass.nrdconta
                                          AND ris.cdcooper = bdc.cdcooper
                                          AND ris.nrdconta = bdc.nrdconta         
                                          AND ris.nrctremp = bdc.nrborder
                                          --AND ris.inddocto = 1
                                          AND ris.cdmodali = 302 -- Desconto cheques
                                          AND ris.vldivida > vr_valor_arrasto -- Materialidade(Arrasto)
                                          AND ris.cdcooper = pr_cdcooper
                                          AND ris.dtrefere = rw_dat.dtmvtoan)
                        GROUP BY cdcooper
                            , nrcpfcgc
                            , nrdconta
                            , nrctremp
                            , cdmodali
                            , nrdgrupo
                            , cdorigem
                                          ) risX
       -- Somentes as contasX que não possuem Limite/ ADP
       WHERE NOT EXISTS (SELECT 1
                           FROM crapris r
                          WHERE r.cdcooper = risX.cdcooper
                            AND r.nrdconta = risX.nrdconta
                            AND r.dtrefere = rw_dat.dtmvtoan
                            AND r.cdmodali IN (201,101,1901))
    GROUP BY risX.cdcooper
           , risX.nrcpfcgc
           , risX.nrdconta
           , risX.nrdgrupo;
                            
      vr_cdcritic crapcri.cdcritic%TYPE; -- Codigo da critica
      vr_dscritic VARCHAR2(2000);        -- Descricao da critica

  --***************************--
  --***      FUNCTIONS      ***--
  --***************************--
    -- Busca risco agravado
     FUNCTION fn_busca_risco_agravado(pr_cdcooper NUMBER
                                    ,pr_nrdconta NUMBER
                                    ,pr_dtmvtoan DATE)
      RETURN tbrisco_cadastro_conta.cdnivel_risco%TYPE AS vr_risco_agr tbrisco_cadastro_conta.cdnivel_risco%TYPE;
       CURSOR cr_agravado IS
         SELECT agr.cdnivel_risco
           FROM tbrisco_cadastro_conta agr
          WHERE agr.cdcooper  = pr_cdcooper
            AND agr.nrdconta  = pr_nrdconta
            AND agr.dtmvtolt <= pr_dtmvtoan;
      rw_agravado cr_agravado%ROWTYPE;
    BEGIN
      OPEN cr_agravado;
      FETCH cr_agravado INTO rw_agravado;
      vr_risco_agr := rw_agravado.cdnivel_risco;
      CLOSE cr_agravado;
      RETURN vr_risco_agr;
    END fn_busca_risco_agravado;

    -- Busca risco rating
    FUNCTION fn_busca_rating(pr_cdcooper NUMBER
                            ,pr_nrdconta NUMBER
                            ,pr_nrctremp NUMBER
                            ,pr_cdorigem NUMBER
                            ,pr_dtmvtoan DATE)
      RETURN crapnrc.indrisco%TYPE AS vr_rating crapnrc.indrisco%TYPE;
      CURSOR cr_rating IS
      SELECT CASE WHEN rat.indrisco = 'A'  THEN 2
                  WHEN rat.indrisco = 'B'  THEN 3
                  WHEN rat.indrisco = 'C'  THEN 4
                  WHEN rat.indrisco = 'D'  THEN 5
                  WHEN rat.indrisco = 'E'  THEN 6
                  WHEN rat.indrisco = 'F'  THEN 7
                  WHEN rat.indrisco = 'G'  THEN 8
                  WHEN rat.indrisco = 'H'  THEN 9
                  WHEN rat.indrisco = 'HH' THEN 10
               ELSE 2 END indrisco
         FROM crapnrc rat
        WHERE rat.cdcooper =  pr_cdcooper
          AND rat.nrdconta =  pr_nrdconta
          AND rat.nrctrrat =  pr_nrctremp
          AND rat.dteftrat <= pr_dtmvtoan
          AND rat.tpctrrat =  DECODE(pr_cdorigem
                                    , 1, 1
                                    , 2, 2
                                    , 3, 90
                                    , 4, 3
                                    , 5, 3)
          AND rat.insitrat =  2;
      rw_rating cr_rating%ROWTYPE;
    BEGIN
      OPEN cr_rating;
      FETCH cr_rating INTO rw_rating;

      vr_rating := rw_rating.indrisco;

      CLOSE cr_rating;

      RETURN vr_rating;
    END fn_busca_rating;

    -- Busca risco grupo economico
    FUNCTION fn_busca_grupo_economico(pr_cdcooper     IN NUMBER
                                     ,pr_nrdconta     IN NUMBER
                                     ,pr_nrcpfcgc     IN NUMBER
                                     ,pr_nrdgrupo     IN NUMBER)
      RETURN crapgrp.innivrge%TYPE AS vr_risco_grupo crapgrp.innivrge%TYPE;

      CURSOR cr_grupo IS
      SELECT DISTINCT
             g.innivrge
        FROM crapgrp g
       WHERE g.cdcooper(+) = pr_cdcooper
         AND g.nrctasoc(+) = pr_nrdconta
         AND g.nrcpfcgc(+) = pr_nrcpfcgc
         AND g.nrdgrupo(+) = pr_nrdgrupo;
      rw_grupo cr_grupo%ROWTYPE;
    BEGIN
      OPEN cr_grupo;
      FETCH cr_grupo INTO rw_grupo;

      vr_risco_grupo  := rw_grupo.innivrge;

      CLOSE cr_grupo;

      RETURN vr_risco_grupo;
    END fn_busca_grupo_economico;

    -- Busca risco atraso
    FUNCTION fn_calcula_risco_atraso(qtdiaatr NUMBER)
      RETURN crawepr.dsnivris%TYPE AS risco_atraso crawepr.dsnivris%TYPE;
    BEGIN
      risco_atraso :=  CASE WHEN qtdiaatr IS NULL THEN 2
                            WHEN qtdiaatr <   15  THEN 2
                            WHEN qtdiaatr <=  30  THEN 3
                            WHEN qtdiaatr <=  60  THEN 4
                            WHEN qtdiaatr <=  90  THEN 5
                            WHEN qtdiaatr <= 120  THEN 6
                            WHEN qtdiaatr <= 150  THEN 7
                            WHEN qtdiaatr <= 180  THEN 8
                            ELSE 9 END;
      RETURN risco_atraso;
    END fn_calcula_risco_atraso;

    -- Busca risco atraso ADP
    FUNCTION fn_calcula_risco_atraso_adp(qtdiaatr NUMBER)
      RETURN crawepr.dsnivris%TYPE AS risco_atraso crawepr.dsnivris%TYPE;
    BEGIN
      risco_atraso :=  CASE WHEN qtdiaatr IS NULL THEN 2
                            WHEN qtdiaatr <   15  THEN 2
                            WHEN qtdiaatr <=  30  THEN 3
                            WHEN qtdiaatr <=  60  THEN 5
                            WHEN qtdiaatr <=  90  THEN 7
                            ELSE 9 END;
      RETURN risco_atraso;
    END fn_calcula_risco_atraso_adp;

  --**************************--
  --***     PROCEDURES     ***--
  --**************************--
    -- Processo de limpeza
    PROCEDURE pc_limpa_dados_risco(pr_cdcooper IN NUMBER         -- Cooperativa
                                  ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Efetua limpeza dos registros com referência superior a 5 dias
        DELETE
          FROM tbrisco_central_ocr
         WHERE (dtrefere <= rw_dat.dtdelreg OR dtrefere = rw_dat.dtmvtoan)
           AND cdcooper = pr_cdcooper;
         --
       EXCEPTION
         WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := 'Erro pc_limpa_dados_risco: '||SQLERRM;
           -- Efetuar rollback
           ROLLBACK;
    END pc_limpa_dados_risco;

    -- Insere infomações de EMPRÉSTIMOS
    -- Modalidade 299 e 499
    PROCEDURE pc_insere_dados_risco_emp(pr_cdcooper IN NUMBER         -- Cooperativa
                                       ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                       ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Reset Riscos
        vr_inrisco_inclusao := NULL;
        vr_inrisco_rating   := NULL;
        vr_inrisco_atraso   := NULL;
        vr_inrisco_agravado := NULL;
        vr_inrisco_melhora  := NULL;
        vr_inrisco_operacao := NULL;
        vr_inrisco_cpf      := NULL;
        vr_inrisco_grupo    := NULL;
        vr_inrisco_final    := NULL;
        vr_inrisco_refin    := NULL;

        BEGIN
          FOR rw_risco_emp IN cr_risco_emp(pr_cdcooper) LOOP

            -- Se o valor da dívida é maior que a Materialidade(Arrasto)
            IF rw_risco_emp.vldivida > vr_valor_arrasto THEN
              -- Processa as variáveis de Riscos a serem inseridos
              vr_inrisco_inclusao := rw_risco_emp.innivori_ctr;
              --
              vr_inrisco_rating := fn_busca_rating(rw_risco_emp.cdcooper
                                                  ,rw_risco_emp.nrdconta
                                                  ,rw_risco_emp.nrctremp
                                                  ,3
                                                  ,rw_dat.dtmvtoan);
              --
              vr_inrisco_atraso   := fn_calcula_risco_atraso(rw_risco_emp.qtdiaatr);
              --
              vr_inrisco_agravado := fn_busca_risco_agravado(rw_risco_emp.cdcooper
                                                            ,rw_risco_emp.nrdconta
                                                            ,rw_dat.dtmvtoan);
              --
              -- Só existirá melhora se o nível risco estiver menor que o nível risco inclusão
              vr_inrisco_melhora  := (CASE WHEN rw_risco_emp.innivris_ctr < vr_inrisco_inclusao THEN
                                       rw_risco_emp.innivris_ctr
                                     ELSE NULL END);
              --              
              vr_inrisco_operacao := greatest(nvl(vr_inrisco_rating,2)
                                              ,vr_inrisco_atraso
                                              ,(CASE WHEN rw_risco_emp.innivris_ctr <> rw_risco_emp.innivori_ctr
                                                 AND rw_risco_emp.innivris_ctr = 2 THEN
                                                   rw_risco_emp.innivris_ctr
                                                ELSE rw_risco_emp.innivori_ctr END)
                                               ,nvl(vr_inrisco_agravado, 2));
              --              
              --vr_inrisco_cpf      := rw_risco_emp.innivris; --.innivris_cta;
              vr_inrisco_cpf      := rw_risco_emp.innivris_ctl;
              --              
              vr_inrisco_grupo    := fn_busca_grupo_economico(rw_risco_emp.cdcooper
                                                             ,rw_risco_emp.nrdconta
                                                             ,rw_risco_emp.nrcpfcgc
                                                             ,rw_risco_emp.nrdgrupo);
              --
              vr_inrisco_refin    := rw_risco_emp.inrisco_refin;
              
              vr_inrisco_final    := greatest(nvl(rw_risco_emp.innivris,2)
                                             ,nvl(vr_inrisco_cpf,2)
                                             ,nvl(vr_inrisco_grupo,2));
              --
            INSERT INTO tbrisco_central_ocr( cdcooper
                                           , nrcpfcgc
                                           , nrdconta
                                           , nrctremp
                                           , cdmodali
--                                           , cdorigem
--                                           , inddocto
                                           , nrdgrupo
                                           , dtrefere
                                           , dtdrisco
                                           , inrisco_inclusao
                                           , inrisco_rating
                                           , inrisco_atraso
                                           , inrisco_agravado
                                           , inrisco_melhora
                                           , inrisco_operacao
                                           , inrisco_cpf
                                           , inrisco_grupo
                                           , inrisco_final
                                           /*, inrisco_refin*/)
                                    VALUES ( rw_risco_emp.cdcooper
                                           , rw_risco_emp.nrcpfcgc
                                           , rw_risco_emp.nrdconta
                                           , rw_risco_emp.nrctremp
                                           , rw_risco_emp.cdmodali
--                                           , rw_risco_emp.cdorigem
--                                           , rw_risco_emp.inddocto
                                           , rw_risco_emp.nrdgrupo
                                           , rw_risco_emp.dtrefere
                                           , rw_risco_emp.dtdrisco
                                           , vr_inrisco_inclusao
                                           , vr_inrisco_rating
                                           , vr_inrisco_atraso
                                           , vr_inrisco_agravado
                                           , vr_inrisco_melhora
                                           , vr_inrisco_operacao
                                           , vr_inrisco_cpf
                                           , vr_inrisco_grupo
                                           , vr_inrisco_final
                                           /*, vr_inrisco_refin*/);
            --
            END IF;
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro(EMPRESTIMOS) INSERT TBRISCO_CENTRAL_OCR: '||SQLERRM;
            -- Efetuar rollback
            ROLLBACK;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro pc_insere_dados_risc_emp: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
    END pc_insere_dados_risco_emp;

    -- Insere infomações de ADP ou LIMITE
    -- Modalidade 101, 201 e 1901
    PROCEDURE pc_insere_dados_riscoAL(pr_cdcooper IN NUMBER         -- Cooperativa
                                     ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Reset Riscos
        vr_inrisco_inclusao := NULL;
        vr_inrisco_rating   := NULL;
        vr_inrisco_atraso   := NULL;
        vr_inrisco_agravado := NULL;
        vr_inrisco_melhora  := NULL;
        vr_inrisco_operacao := NULL;
        vr_inrisco_cpf      := NULL;
        vr_inrisco_grupo    := NULL;
        vr_inrisco_final    := NULL;

        BEGIN
          FOR rw_riscoAL IN cr_riscoAL(pr_cdcooper) LOOP

            -- Processa as variáveis de Riscos a serem inseridos
            vr_inrisco_inclusao := 2;
            --
            vr_inrisco_rating := fn_busca_rating(rw_riscoAL.cdcooper
                                                ,rw_riscoAL.nrdconta
                                                ,rw_riscoAL.nrctremp
                                                ,1
                                                ,rw_dat.dtmvtoan);
            --
            vr_inrisco_atraso   := fn_calcula_risco_atraso_adp(rw_riscoAL.qtdiaatr);
            --
            vr_inrisco_agravado := fn_busca_risco_agravado(rw_riscoAL.cdcooper
                                                          ,rw_riscoAL.nrdconta
                                                          ,rw_dat.dtmvtoan);
            --
            vr_inrisco_melhora  := NULL; -- Limite/ ADP não possui Melhora
            --
            vr_inrisco_operacao := greatest(nvl(vr_inrisco_rating, 2)
                                           ,vr_inrisco_inclusao
                                           ,vr_inrisco_atraso
                                           ,nvl(vr_inrisco_agravado, 2));
            --
            --vr_inrisco_cpf      := rw_riscoAL.Innivris; --.innivris_cta;
            vr_inrisco_cpf      := rw_riscoAL.innivris_ctl;
            --
            vr_inrisco_grupo    := fn_busca_grupo_economico(rw_riscoAL.cdcooper
                                                           ,rw_riscoAL.nrdconta
                                                           ,rw_riscoAL.nrcpfcgc
                                                           ,rw_riscoAL.nrdgrupo);
            --
            vr_inrisco_final    := greatest(nvl(rw_riscoAL.innivris,2)
                                           ,nvl(vr_inrisco_cpf,2)
                                           ,nvl(vr_inrisco_grupo,2));
            --                                 

            INSERT INTO tbrisco_central_ocr( cdcooper
                                           , nrcpfcgc
                                           , nrdconta
                                           , nrctremp
                                           , cdmodali
--                                           , cdorigem
--                                           , inddocto                                                                                      
                                           , nrdgrupo
                                           , dtrefere
                                           , dtdrisco
                                           , inrisco_inclusao
                                           , inrisco_rating
                                           , inrisco_atraso
                                           , inrisco_agravado
                                           , inrisco_melhora
                                           , inrisco_operacao
                                           , inrisco_cpf
                                           , inrisco_grupo
                                           , inrisco_final)
                                    VALUES ( rw_riscoAL.cdcooper
                                           , rw_riscoAL.nrcpfcgc
                                           , rw_riscoAL.nrdconta
                                           , rw_riscoAL.nrctremp
                                           , rw_riscoAL.cdmodali
--                                           , rw_riscoAL.cdorigem
--                                           , rw_riscoAL.inddocto
                                           , rw_riscoAL.nrdgrupo
                                           , rw_riscoAL.dtrefere
                                           , rw_riscoAL.dtdrisco
                                           , vr_inrisco_inclusao
                                           , vr_inrisco_rating
                                           , vr_inrisco_atraso
                                           , vr_inrisco_agravado
                                           , vr_inrisco_melhora
                                           , vr_inrisco_operacao
                                           , vr_inrisco_cpf
                                           , vr_inrisco_grupo
                                           , vr_inrisco_final);
            --
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro(ADP LIMITE) INSERT TBRISCO_CENTRAL_OCR: '||SQLERRM;
            -- Efetuar rollback
            ROLLBACK;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro pc_insere_dados_riscoAL: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
    END pc_insere_dados_riscoAL;

    -- Insere infomações de LIMITE DE DESCONTO
    -- Modalidade 301 e 302
    PROCEDURE pc_insere_dados_riscoLD(pr_cdcooper IN NUMBER         -- Cooperativa
                                     ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;

        -- Reset Riscos
        vr_inrisco_inclusao := NULL;
        vr_inrisco_rating   := NULL;
        vr_inrisco_atraso   := NULL;
        vr_inrisco_agravado := NULL;
        vr_inrisco_melhora  := NULL;
        vr_inrisco_operacao := NULL;
        vr_inrisco_cpf      := NULL;
        vr_inrisco_grupo    := NULL;
        vr_inrisco_final    := NULL;

        BEGIN
          FOR rw_riscoLD IN cr_riscoLD(pr_cdcooper) LOOP

            -- Processa as variáveis de Riscos a serem inseridos
            vr_inrisco_inclusao := 2;
            --
            vr_inrisco_rating := fn_busca_rating(rw_riscoLD.cdcooper
                                                ,rw_riscoLD.nrdconta
                                                ,rw_riscoLD.nrctremp
                                                ,rw_riscoLD.cdorigem
                                                ,rw_dat.dtmvtoan);
            --
            vr_inrisco_atraso   := fn_calcula_risco_atraso(rw_riscoLD.qtdiaatr);
            --
            vr_inrisco_agravado := fn_busca_risco_agravado(rw_riscoLD.cdcooper
                                                          ,rw_riscoLD.nrdconta
                                                          ,rw_dat.dtmvtoan);
            vr_inrisco_melhora  := NULL;
            --
            vr_inrisco_operacao := greatest(nvl(vr_inrisco_rating, 2)
                                            ,vr_inrisco_inclusao
                                            ,vr_inrisco_atraso
                                            ,nvl(vr_inrisco_agravado, 2));
            --
            --vr_inrisco_cpf      := rw_riscoLD.Innivris;
            vr_inrisco_cpf      := rw_riscoLD.innivris_ctl;
            --
            vr_inrisco_grupo    := fn_busca_grupo_economico(rw_riscoLD.cdcooper
                                                           ,rw_riscoLD.nrdconta
                                                           ,rw_riscoLD.nrcpfcgc
                                                           ,rw_riscoLD.nrdgrupo);
            --
            vr_inrisco_final    := greatest(nvl(rw_riscoLD.innivris,2)
                                           ,nvl(vr_inrisco_cpf,2)
                                           ,nvl(vr_inrisco_grupo,2));
            --

            INSERT INTO tbrisco_central_ocr( cdcooper
                                           , nrcpfcgc
                                           , nrdconta
                                           , nrctremp
                                           , cdmodali
--                                           , cdorigem
--                                           , inddocto
                                           , nrdgrupo
                                           , dtrefere
                                           , dtdrisco
                                           , inrisco_inclusao
                                           , inrisco_rating
                                           , inrisco_atraso
                                           , inrisco_agravado
                                           , inrisco_melhora
                                           , inrisco_operacao
                                           , inrisco_cpf
                                           , inrisco_grupo
                                           , inrisco_final)
                                    VALUES ( rw_riscoLD.cdcooper
                                           , rw_riscoLD.nrcpfcgc
                                           , rw_riscoLD.nrdconta
                                           , rw_riscoLD.nrctremp
                                           , rw_riscoLD.cdmodali
--                                           , rw_riscoLD.cdorigem
--                                           , rw_riscoLD.inddocto
                                           , rw_riscoLD.nrdgrupo
                                           , rw_riscoLD.dtrefere
                                           , rw_riscoLD.dtdrisco
                                           , vr_inrisco_inclusao
                                           , vr_inrisco_rating
                                           , vr_inrisco_atraso
                                           , vr_inrisco_agravado
                                           , vr_inrisco_melhora
                                           , vr_inrisco_operacao
                                           , vr_inrisco_cpf
                                           , vr_inrisco_grupo
                                           , vr_inrisco_final);
            --
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro(LIMITE DESCONTO) INSERT TBRISCO_CENTRAL_OCR: '||SQLERRM;
            -- Efetuar rollback
            ROLLBACK;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro pc_insere_dados_riscoLD: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
    END pc_insere_dados_riscoLD;

    -- Insere Contas/ Contratos que possuem Empréstimo ou Limite Desconto
    -- e não possuem Contrato Limite e/ ou ADP
    PROCEDURE pc_insere_dados_contaX(pr_cdcooper IN NUMBER         -- Cooperativa
                                    ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                    ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;
        --
        -- Reset Riscos
        vr_inrisco_inclusao := 2;
        vr_inrisco_rating   := NULL;
        vr_inrisco_atraso   := 2;
        vr_inrisco_agravado := NULL;
        vr_inrisco_melhora  := NULL;
        vr_inrisco_operacao := 2;
        vr_inrisco_cpf      := NULL;
        vr_inrisco_grupo    := NULL;
        vr_inrisco_final    := NULL;

        FOR rw_contaX IN cr_contaX(pr_cdcooper) LOOP
          -- Processa as variáveis de Riscos a serem inseridos
          --
          vr_inrisco_agravado := fn_busca_risco_agravado(rw_contaX.cdcooper
                                                        ,rw_contaX.nrdconta
                                                        ,rw_dat.dtmvtoan);
          --
          vr_inrisco_grupo    := fn_busca_grupo_economico(rw_contaX.cdcooper
                                                         ,rw_contaX.nrdconta
                                                         ,rw_contaX.nrcpfcgc
                                                         ,rw_contaX.nrdgrupo);
          --
          vr_inrisco_cpf      := nvl(trim(rw_contaX.innivris_ctl), 2);
          --
          vr_inrisco_operacao := greatest(nvl(vr_inrisco_rating, 2)
                                             ,vr_inrisco_inclusao
                                             ,vr_inrisco_atraso
                                             ,nvl(vr_inrisco_agravado, 2));
          --
          vr_inrisco_final    := greatest(nvl(vr_inrisco_cpf,2)
                                         ,nvl(vr_inrisco_grupo,2));

          INSERT INTO tbrisco_central_ocr( cdcooper
                                         , nrcpfcgc
                                         , nrdconta
                                         , nrctremp
                                         , cdmodali
--                                         , cdorigem
--                                         , inddocto                                         
                                         , nrdgrupo
                                         , dtrefere                                         
                                         , dtdrisco
                                         , inrisco_inclusao
                                         , inrisco_rating
                                         , inrisco_atraso
                                         , inrisco_agravado
                                         , inrisco_melhora
                                         , inrisco_operacao
                                         , inrisco_cpf
                                         , inrisco_grupo
                                         , inrisco_final)
                                  VALUES ( rw_contaX.cdcooper
                                         , rw_contaX.nrcpfcgc
                                         , rw_contaX.nrdconta
                                         , 0 --nrctremp
                                         , 999 --cdcodali
--                                         , NULL
--                                         , NULL
                                         , rw_contaX.nrdgrupo
                                         , rw_dat.dtmvtoan
                                         , NULL --dtdrisco
                                         , vr_inrisco_inclusao
                                         , vr_inrisco_rating
                                         , vr_inrisco_atraso
                                         , vr_inrisco_agravado
                                         , vr_inrisco_melhora
                                         , vr_inrisco_operacao
                                         , vr_inrisco_cpf
                                         , vr_inrisco_grupo
                                         , vr_inrisco_final);
         --
         END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro pc_insere_dados_contaX: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
    END pc_insere_dados_contaX;

    -- Carrega informações(dados crapass inicial)
    -- Insere Contas/ Contratos que não possuem Central de Risco(CRAPRIS)
    PROCEDURE pc_insere_dados_SEMrisco(pr_cdcooper IN NUMBER         -- Cooperativa
                                      ,pr_cdcritic OUT PLS_INTEGER   -- Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS  -- Erros do processo) IS
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;
        --
        -- Reset Riscos
        vr_inrisco_inclusao := 2;
        vr_inrisco_rating   := NULL;
        vr_inrisco_atraso   := 2;
        vr_inrisco_agravado := NULL;
        vr_inrisco_melhora  := NULL;
        vr_inrisco_operacao := NULL;
        vr_inrisco_cpf      := NULL;
        vr_inrisco_grupo    := NULL;
        vr_inrisco_final    := NULL;

        FOR rw_semrisco IN cr_semrisco(pr_cdcooper) LOOP
          -- Processa as variáveis de Riscos a serem inseridos
          vr_inrisco_agravado := fn_busca_risco_agravado(rw_semrisco.cdcooper
                                                        ,rw_semrisco.nrdconta
                                                        ,rw_dat.dtmvtoan);
          --
          vr_inrisco_cpf      := nvl(trim(rw_semrisco.innivris_ctl), 2);
          --
          vr_inrisco_grupo    := fn_busca_grupo_economico(rw_semrisco.cdcooper
                                                         ,rw_semrisco.nrdconta
                                                         ,rw_semrisco.nrcpfcgc
                                                         ,rw_semrisco.nrdgrupo);
          --
          vr_inrisco_operacao := greatest(nvl(vr_inrisco_rating, 2)
                                             ,vr_inrisco_inclusao
                                             ,vr_inrisco_atraso
                                             ,nvl(vr_inrisco_agravado, 2));
          --
          vr_inrisco_final    := greatest(nvl(vr_inrisco_cpf,2)
                                         ,nvl(vr_inrisco_grupo,2));

          INSERT INTO tbrisco_central_ocr( cdcooper
                                         , nrcpfcgc
                                         , nrdconta
                                         , nrctremp
                                         , cdmodali
--                                         , cdorigem
--                                         , inddocto
                                         , nrdgrupo
                                         , dtrefere
                                         , dtdrisco
                                         , inrisco_inclusao
                                         , inrisco_rating
                                         , inrisco_atraso
                                         , inrisco_agravado
                                         , inrisco_melhora
                                         , inrisco_operacao
                                         , inrisco_cpf
                                         , inrisco_grupo
                                         , inrisco_final)
                                  VALUES ( rw_semrisco.cdcooper
                                         , rw_semrisco.nrcpfcgc
                                         , rw_semrisco.nrdconta
                                         , 0 --nrctremp
                                         , 0 --cdcodali
--                                         , NULL
--                                         , NULL
                                         , rw_semrisco.nrdgrupo
                                         , rw_dat.dtmvtoan
                                         , NULL --dtdrisco
                                         , vr_inrisco_inclusao
                                         , vr_inrisco_rating
                                         , vr_inrisco_atraso
                                         , vr_inrisco_agravado
                                         , vr_inrisco_melhora
                                         , vr_inrisco_operacao
                                         , vr_inrisco_cpf
                                         , vr_inrisco_grupo
                                         , vr_inrisco_final);
         --
         END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro pc_insere_dados_SEMrisco: '||SQLERRM;
          -- Efetuar rollback
          ROLLBACK;
    END pc_insere_dados_SEMrisco;

    --************************--
    --   INICIO DO PROGRAMA   --
    --************************--
    BEGIN
      vr_cdcritic := NULL;
      vr_dscritic := NULL;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;

      -- Se não encontrar registro da cooperativa
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Busca calendário para a cooperativa selecionada
      OPEN cr_dat(pr_cdcooper);
      FETCH cr_dat INTO rw_dat;
      -- Se não encontrar calendário
      IF cr_dat%NOTFOUND THEN
        CLOSE cr_dat;
        -- Montar mensagem de critica
        vr_cdcritic  := 794;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_dat;
      END IF;

      -- Recupera parâmetro da TAB089
      OPEN cr_tab(pr_cdcooper);
      FETCH cr_tab INTO rw_tab;
      CLOSE cr_tab;
      -- Materialidade(Arrasto)
      vr_valor_arrasto := TO_NUMBER(replace(substr(rw_tab.dstextab, 3, 9), '.', ','));

      --INICIO
      -- Chama processo de limpeza
      pc_limpa_dados_risco(pr_cdcooper => pr_cdcooper  -- Cooperativa
                          ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                          ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro no DELETE
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        ELSE
          COMMIT;
        END IF;

      -- Insere infomações de EMPRÉSTIMOS
      -- Modalidade 299 e 499
      pc_insere_dados_risco_emp(pr_cdcooper => pr_cdcooper  -- Cooperativa
                               ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                               ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;

      -- Insere infomações de ADP ou LIMITE
      -- Modalidade 101, 201 e 1901
      pc_insere_dados_riscoAL(pr_cdcooper => pr_cdcooper  -- Cooperativa
                                     ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                                     ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;

      -- Insere infomações de LIMITE DE DESCONTO
      -- Modalidade 301 e 302
      pc_insere_dados_riscoLD(pr_cdcooper => pr_cdcooper  -- Cooperativa
                                      ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                                      ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;

      -- Insere Contas/ Contratos que possuem Empréstimo ou Limite Desconto
      -- e não possuem Contrato Limite e/ ou ADP
      pc_insere_dados_contaX(pr_cdcooper => pr_cdcooper  -- Cooperativa
                            ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                            ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;

      -- Carrega informações(dados crapass inicial)
      -- Insere Contas/ Contratos que não possuem Central de Risco(CRAPRIS)
      pc_insere_dados_SEMrisco(pr_cdcooper => pr_cdcooper  -- Cooperativa
                              ,pr_cdcritic => vr_cdcritic  -- Código da crítica
                              ,pr_dscritic => vr_dscritic);-- Erros do processo
        -- Verifica erro
        IF vr_cdcritic = 0 THEN
          RAISE vr_exc_saida;
        END IF;


      -- Efetuar COMMIT FINAL!
      COMMIT;
      --
   EXCEPTION
      WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na rotina PC_RISCO_CENTRAL_OCR. Detalhes: '||vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Retornar o erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na rotina PC_RISCO_CENTRAL_OCR. Detalhes: '||sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
   END;
END PC_RISCO_CENTRAL_OCR;
/