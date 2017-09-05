CREATE OR REPLACE PROCEDURE CECRED.pc_valida_limite_operador(pr_cdcooper  IN crapopi.cdcooper%TYPE, /* COD COOPERATIVA */
                                                             pr_nrdconta  IN crapopi.nrdconta%TYPE, /* NUMERO DA CONTA */
                                                             pr_nrcpfope  IN crapopi.nrcpfope%TYPE, /* CPF DO OPERADOR */
                                                             pr_idseqttl  IN crapsnh.idseqttl%TYPE, /* IDSEQTTL DO PREPOSTO */
                                                             pr_vllimpgo  IN crapsnh.vllimpgo%TYPE, /* Boleto/Convenio/Tributos */
                                                             pr_vllimtrf  IN crapopi.vllimtrf%TYPE, /* Transferencia */
                                                             pr_vllimted  IN crapopi.vllimted%TYPE, /* TED */
                                                             pr_vllimvrb  IN crapopi.vllimvrb%TYPE, /* VR Boleto */
                                                             pr_vllimflp  IN crapopi.vllimflp%TYPE, /* Folha de Pagamento */
                                                             pr_dscritic  OUT VARCHAR2,             /* RETORNO DA CRITICA DESCRICAO */
                                                             pr_cdcritic  OUT INTEGER) IS           /* RETORNO DA CRITICA CODIGO */

    /*********************************************************************
    **                                                                  **
    ** PROGRAMA: ROTINA PARA VALIDAR LMTS DOS OPERADORES PJ/C.CONJUNTA  **
    ** AUTOR: ANDREY FORMIGARI (MOUTS)                                  **
    ** DATA CRIAÇÃO: 11/07/2017                                         **
    ** DATA MODIFICAÇÃO: 12/07/2017                                     **
    ** SISTEMA: InternetBank - Menu "Operador"                          **
    **                                                                  **
    *********************************************************************/

    CURSOR cr_crapsnh (pr_cdcooper crapsnh.cdcooper%TYPE,
                       pr_nrdconta crapsnh.nrdconta%TYPE,
                       pr_idseqttl crapsnh.idseqttl%TYPE) IS
        SELECT c.vllimtrf,
               c.vllimted,
               c.vllimvrb,
               c.vllimflp,
               c.vllimpgo
        FROM crapsnh c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta AND
              c.tpdsenha = 1 AND
              c.cdsitsnh = 1 AND
              c.idseqttl = pr_idseqttl;
        rw_crapsnh cr_crapsnh%ROWTYPE;

    CURSOR cr_getcpfpre (pr_cdcooper crapopi.cdcooper%TYPE,
                         pr_nrdconta crapopi.nrdconta%TYPE,
                         pr_idseqttl crapsnh.idseqttl%TYPE) IS
        SELECT c.nrcpfcgc
        FROM crapsnh c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta AND
              c.idseqttl = pr_idseqttl AND
              c.tpdsenha = 1 AND
              c.cdsitsnh = 1;
        rw_getcpfpre cr_getcpfpre%ROWTYPE;

    CURSOR cr_crapass (pr_cdcooper crapopi.cdcooper%TYPE,
                       pr_nrdconta crapopi.nrdconta%TYPE) IS
        SELECT c.nrcpfcgc, c.idastcjt, c.nmprimtl, c.inpessoa
        FROM crapass c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;

    /* CURSOR COM OS LIMITES DOS PREPOSTOS */
    CURSOR cr_lmtprep (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_nrcpfpre crapass.nrcpfcgc%TYPE) IS
           SELECT t.vllimite_folha,
                  t.vllimite_pagto,
                  t.vllimite_ted,
                  t.vllimite_transf,
                  t.vllimite_vrboleto
           FROM tbcc_limite_preposto t
           WHERE t.cdcooper = pr_cdcooper AND
                 t.nrdconta = pr_nrdconta AND
                 t.nrcpf = pr_nrcpfpre;
        rr_lmtprep cr_lmtprep%ROWTYPE;

    CURSOR cr_crapemp (pr_cdcooper IN crapemp.cdcooper%TYPE
                      ,pr_nrdconta IN crapemp.nrdconta%TYPE) IS
      SELECT COALESCE(SUM(vllimfol),0) vllimfol
        FROM crapemp
       WHERE crapemp.cdcooper = pr_cdcooper
         AND crapemp.nrdconta = pr_nrdconta;
      rw_crapemp cr_crapemp%ROWTYPE;

    vr_dscritic VARCHAR2(350);
    vr_cdcritic INTEGER := 0;
    vr_exc_erro EXCEPTION;
    vr_nrcpfpre INTEGER;
    vr_flhpgto crapemp.vllimfol%TYPE;

    BEGIN

        OPEN cr_getcpfpre(pr_cdcooper, pr_nrdconta , pr_idseqttl);
        FETCH cr_getcpfpre INTO rw_getcpfpre;
        CLOSE cr_getcpfpre;

        OPEN cr_crapass(pr_cdcooper, pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        /*  Buscar o preposto que está chamando esta rotina.
        **  Busca pela sequencia do titular, cooperativa e numero de conta. */
        vr_nrcpfpre := rw_getcpfpre.nrcpfcgc;

        /*
        ** validar apenas conta PJ e que não seja conta conjunta
        */
        IF rw_crapass.inpessoa = 2 AND rw_crapass.idastcjt = 0 THEN

          OPEN cr_crapemp(pr_cdcooper, pr_nrdconta);
          FETCH cr_crapemp INTO rw_crapemp;
          CLOSE cr_crapemp;

          vr_flhpgto := rw_crapemp.vllimfol;

          FOR rw_crapsnh IN cr_crapsnh(pr_cdcooper, pr_nrdconta, pr_idseqttl) LOOP

              IF rw_crapsnh.vllimpgo < pr_vllimpgo THEN
                 vr_cdcritic := 1028;
                 RAISE vr_exc_erro;
              ELSIF rw_crapsnh.vllimtrf < pr_vllimtrf THEN
                 vr_cdcritic := 1029;
                 RAISE vr_exc_erro;
              ELSIF rw_crapsnh.vllimvrb < pr_vllimvrb THEN
                 vr_cdcritic := 1030;
                 RAISE vr_exc_erro;
              ELSIF vr_flhpgto < pr_vllimflp THEN
                 vr_cdcritic := 1031;
                 RAISE vr_exc_erro;
              ELSIF rw_crapsnh.vllimted < pr_vllimted THEN
                 vr_cdcritic := 1032;
                 RAISE vr_exc_erro;
              END IF;

          END LOOP;

        ELSE /* APENAS CONTA CONJUNTA */

          -- VALIDAR TODOS OS LIMITES DO PREPOSTO QUE ESTÁ
          FOR rw_lmtprep IN cr_lmtprep(pr_cdcooper, pr_nrdconta, vr_nrcpfpre) LOOP

              IF rw_lmtprep.vllimite_pagto < pr_vllimpgo THEN
                 vr_cdcritic := 1028;
                 RAISE vr_exc_erro;
              ELSIF rw_lmtprep.vllimite_transf < pr_vllimtrf THEN
                 vr_cdcritic := 1029;
                 RAISE vr_exc_erro;
              ELSIF rw_lmtprep.vllimite_vrboleto < pr_vllimvrb THEN
                 vr_cdcritic := 1030;
                 RAISE vr_exc_erro;
              ELSIF rw_lmtprep.vllimite_folha < pr_vllimflp THEN
                 vr_cdcritic := 1031;
                 RAISE vr_exc_erro;
              ELSIF rw_lmtprep.vllimite_ted < pr_vllimted THEN
                 vr_cdcritic := 1032;
                 RAISE vr_exc_erro;
              END IF;

          END LOOP;

        END IF;

        /* VALIDAÇÃO ESTPA OK! */
        pr_dscritic := '';
        pr_cdcritic := 0;

    EXCEPTION
      WHEN OTHERS THEN
        /* LEVANTOU ALGUMA EXCEÇÃO */
        pr_dscritic := 'Ocorreu um erro na validacao';
        pr_cdcritic := vr_cdcritic;

END pc_valida_limite_operador;
/
