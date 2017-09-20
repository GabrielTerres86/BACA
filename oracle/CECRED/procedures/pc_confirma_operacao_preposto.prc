CREATE OR REPLACE PROCEDURE CECRED.pc_confirma_operacao_preposto(pr_cdcooper  IN crapopi.cdcooper%TYPE, /* COD COOPERATIVA */
                                                                 pr_nrdconta  IN crapopi.nrdconta%TYPE, /* NUMERO DA CONTA */
                                                                 pr_idseqttl  IN crapsnh.idseqttl%TYPE, /* CPF DO PREPOSTO */
                                                                 pr_nrcpfope  IN VARCHAR2,              /* CPF DOS OPERAD. SEPARADOS POR "," */
                                                                 xml_operador OUT VARCHAR2) IS          /* RETORNO COM ERRO */

    /*********************************************************************
    **                                                                  **
    ** PROGRAMA: ROTINA PARA AUTORIZAR OS LIMITES DOS OPERADORES        **
    ** AUTOR: ANDREY FORMIGARI (MOUTS)                                  **
    ** DATA CRIAÇÃO: 28/06/2017                                         **
    ** DATA MODIFICAÇÃO: 28/06/2017                                     **
    **                                                                  **
    *********************************************************************/

    CURSOR cr_operad_aprov(pr_cdcooper crapass.cdcooper%TYPE,
                           pr_nrdconta crapass.nrdconta%TYPE,
                           pr_nrcpfpre crapass.nrcpfcgc%TYPE,
                           pr_nrcpfope crapass.nrcpfcgc%TYPE) IS
        SELECT t.nrcpf_operador
        FROM CECRED.TBCC_OPERAD_APROV t
        WHERE t.cdcooper = pr_cdcooper AND
              t.nrdconta = pr_nrdconta AND
              t.nrcpf_preposto = pr_nrcpfpre AND
              t.nrcpf_operador = pr_nrcpfope AND
              t.flgaprovado = 0;
        rw_operad_aprov cr_operad_aprov%ROWTYPE;

    CURSOR cr_verifica_seultimo_operador(pr_cdcooper crapass.cdcooper%TYPE,
                                         pr_nrdconta crapass.nrdconta%TYPE,
                                         pr_nrcpfope crapass.nrcpfcgc%TYPE) IS
        SELECT COUNT(1) AS qtd
        FROM CECRED.TBCC_OPERAD_APROV t
        WHERE t.cdcooper = pr_cdcooper AND
              t.nrdconta = pr_nrdconta AND
              t.nrcpf_operador = pr_nrcpfope AND
              t.flgaprovado = 0;
        rw_verifica_seultimo_operador cr_verifica_seultimo_operador%ROWTYPE;

    CURSOR cr_qtd_prep_confirmados(pr_cdcooper crapass.cdcooper%TYPE,
                                   pr_nrdconta crapass.nrdconta%TYPE,
                                   pr_nrcpfope crapass.nrcpfcgc%TYPE) IS
        SELECT COUNT(1) AS qtd
        FROM CECRED.TBCC_OPERAD_APROV t
        WHERE t.cdcooper = pr_cdcooper       AND
              t.nrdconta = pr_nrdconta       AND
              t.nrcpf_operador = pr_nrcpfope AND
              t.flgaprovado = 1;
        rw_qtd_prep_confirmados cr_qtd_prep_confirmados%ROWTYPE;

    CURSOR cr_limites_temp(pr_cdcooper crapass.cdcooper%TYPE,
                           pr_nrdconta crapass.nrdconta%TYPE,
                           pr_nrcpfope crapass.nrcpfcgc%TYPE) IS
        SELECT t.vllimite_folha,
               t.vllimite_pagto,
               t.vllimite_ted,
               t.vllimite_transf,
               t.vllimite_vrboleto
        FROM CECRED.TBCC_OPERAD_APROV t
        WHERE t.cdcooper = pr_cdcooper       AND
              t.nrdconta = pr_nrdconta       AND
              t.nrcpf_operador = pr_nrcpfope AND
              t.flgaprovado = 1              AND
              ROWNUM = 1;
        rw_limites_temp cr_limites_temp%ROWTYPE;

    CURSOR cr_crapopi (pr_cdcooper crapopi.cdcooper%TYPE,
                       pr_nrdconta crapopi.nrdconta%TYPE,
                       pr_nrcpfope crapopi.nrcpfope%TYPE) IS
        SELECT
             c.nmoperad,
             c.nrcpfope,
             c.dsdcargo,
             c.flgsitop,
             c.dsdemail,
             c.vllbolet,
             c.vllimtrf,
             c.vllimted,
             c.vllimvrb,
             c.vllimflp
        FROM crapopi c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta AND
              c.nrcpfope = pr_nrcpfope;
        rw_crapopi cr_crapopi%ROWTYPE;

    CURSOR cr_crapdat (pr_cdcooper crapopi.cdcooper%TYPE) IS
        SELECT
             c.dtmvtolt,
             c.dtmvtocd
        FROM crapdat c
        WHERE c.cdcooper = pr_cdcooper;
        rw_crapdat cr_crapdat%ROWTYPE;

    CURSOR cr_crapsnh (pr_cdcooper crapopi.cdcooper%TYPE,
                       pr_nrdconta crapopi.nrdconta%TYPE,
                       pr_idseqttl crapsnh.idseqttl%TYPE) IS
        SELECT c.nrcpfcgc
        FROM crapsnh c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta AND
              c.idseqttl = pr_idseqttl AND
              ROWNUM = 1;
        rw_crapsnh cr_crapsnh%ROWTYPE;

    CURSOR cr_preposto (pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE,
                        pr_nrcpfope crapass.nrcpfcgc%TYPE) IS
        SELECT
          avt.nmdavali AS nmprepos,
          avt.nrcpfcgc AS nrcpfpre,
          t.dhaprovacao AS dtaprov,
          (SELECT ass.nmprimtl
           FROM crapass ass
           WHERE ass.cdcooper = t.cdcooper AND
                 ass.nrdconta = avt.nrdctato) nmprimtl,
          t.flgaprovado
        FROM
          TBCC_OPERAD_APROV t,
          crapavt avt,
          crapsnh snh
        WHERE
          t.cdcooper = pr_cdcooper          AND
          t.nrdconta = pr_nrdconta          AND
          t.nrcpf_operador = pr_nrcpfope    AND
          avt.cdcooper = t.cdcooper         AND
          avt.nrdconta = t.nrdconta         AND
          avt.nrcpfcgc = t.nrcpf_preposto   AND
          snh.cdcooper = avt.cdcooper       AND
          snh.nrdconta = avt.nrdconta       AND
          snh.nrcpfcgc = avt.nrcpfcgc       AND
          snh.tpdsenha = 1                  AND
          snh.cdsitsnh = 1;
        rw_preposto cr_preposto%ROWTYPE;

    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT c.qtminast
        FROM crapass c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;

    vr_desclob CLOB;
    i_prev_pos INTEGER := 1;
    i_pos INTEGER;
    i_max_pos INTEGER := 0;
    i_delim_length INTEGER := LENGTH(',');
    nrcpf_temp INTEGER;
    is_last BOOLEAN;
    vr_nrcpfpre crapopi.nrcpfope%TYPE;

    vr_dsinfor1 crappro.dsinform##1%TYPE;
    vr_dsinfor2 crappro.dsinform##2%TYPE;
    vr_dsinfor3 crappro.dsinform##3%TYPE;

    vr_dsprotoc crappro.dsprotoc%TYPE;
    vr_dscritic VARCHAR2(350);
    vr_dsretorn VARCHAR2(350);
    pr_des_erro VARCHAR2(350);
    vr_exc_saida INTEGER;
    vr_minprepo INTEGER;
    vr_exc_erro EXCEPTION;
    qtd_cpfs_op INTEGER;
    vr_nrdrowid ROWID;
    vr_dstransa VARCHAR2(500);
    vr_des_erro VARCHAR2(500);

    BEGIN

        OPEN cr_crapsnh(pr_cdcooper, pr_nrdconta , pr_idseqttl);
        FETCH cr_crapsnh INTO rw_crapsnh;
        CLOSE cr_crapsnh;

        vr_nrcpfpre := rw_crapsnh.nrcpfcgc;

        OPEN cr_crapdat(pr_cdcooper);
        FETCH cr_crapdat INTO rw_crapdat;
        CLOSE cr_crapdat;

        OPEN cr_crapass(pr_cdcooper, pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        /* Numero de prepostos Suficientes para Aprovar o Limite */
        vr_minprepo := rw_crapass.qtminast;

        i_max_pos := LENGTH(pr_nrcpfope) + 1;

        /*
        ** Para cada virgula que conter a string, será um loop a ser efetuado
        */
        LOOP
            i_pos := instr(pr_nrcpfope, ',', i_prev_pos);
            IF i_pos = 0 then
               i_pos := i_max_pos;
            END IF;

            /* numero da conta */
            nrcpf_temp := substr(pr_nrcpfope, i_prev_pos, i_pos - i_prev_pos);

            FOR rw_operad_aprov IN cr_operad_aprov (pr_cdcooper => pr_cdcooper,
                                                    pr_nrdconta => pr_nrdconta,
                                                    pr_nrcpfpre => vr_nrcpfpre,
                                                    pr_nrcpfope => nrcpf_temp) LOOP

                OPEN cr_crapopi(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrcpfope => rw_operad_aprov.nrcpf_operador);
                FETCH cr_crapopi INTO rw_crapopi;
                CLOSE cr_crapopi;

                /* VERIFICAR SE É O ÚLTIMO PREPOSTO A APROVAR */
                OPEN cr_verifica_seultimo_operador(pr_cdcooper, pr_nrdconta, nrcpf_temp);
                FETCH cr_verifica_seultimo_operador INTO rw_verifica_seultimo_operador;
                CLOSE cr_verifica_seultimo_operador;

                -- se 1, é o último. então gera protocolo.
                IF rw_verifica_seultimo_operador.qtd = 1 THEN
                    is_last := TRUE;
                ELSE
                    is_last := FALSE;
                END IF;

                BEGIN

                    /* APROVAR OPERADOR */
                    UPDATE CECRED.TBCC_OPERAD_APROV t SET
                    t.flgaprovado = 1, t.dhaprovacao = SYSDATE
                    WHERE t.cdcooper = pr_cdcooper      AND
                          t.nrdconta = pr_nrdconta      AND
                          t.nrcpf_operador = nrcpf_temp AND
                          t.nrcpf_preposto = vr_nrcpfpre;
                EXCEPTION
                  WHEN OTHERS THEN
                    pr_des_erro := 'Erro no UPDATE TBCC_OPERAD_APROV';
                    ROLLBACK;
                    RAISE vr_exc_erro;
                END;

                BEGIN
                    vr_dstransa := 'Confirmacao de Operador';
                    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                        ,pr_cdoperad => 996
                                        ,pr_dscritic => NULL
                                        ,pr_dsorigem => 'INTERNET'
                                        ,pr_dstransa => vr_dstransa
                                        ,pr_dttransa => TRUNC(SYSDATE)
                                        ,pr_flgtrans => 1
                                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_nmdatela => 'INTERNETBANK'
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);

                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'OPERADOR/PREPOSTO'
                                             ,pr_dsdadant => nrcpf_temp
                                             ,pr_dsdadatu => vr_nrcpfpre);
                EXCEPTION
                    WHEN OTHERS THEN
                         xml_operador := 'Erro ao gerar Log';
                END;

                vr_desclob := vr_desclob || '<OPERADOR>';

                vr_desclob := vr_desclob || '<nmoperad>' || rw_crapopi.nmoperad || '</nmoperad>';
                vr_desclob := vr_desclob || '<nrcpfope>' || gene0002.fn_mask_cpf_cnpj(rw_crapopi.nrcpfope, 1) || '</nrcpfope>';
                vr_desclob := vr_desclob || '<dsdcargo>' || rw_crapopi.dsdcargo || '</dsdcargo>';
                vr_desclob := vr_desclob || '<flgsitop>' || rw_crapopi.flgsitop || '</flgsitop>';
                vr_desclob := vr_desclob || '<dsdemail>' || rw_crapopi.dsdemail || '</dsdemail>';

                vr_desclob := vr_desclob || '</OPERADOR>';

                vr_dsinfor1 := '';
                vr_dsinfor2 := '';

                /* Verifica a quantidade de prepostos que aprovaram esse operador */
                OPEN cr_qtd_prep_confirmados(pr_cdcooper, pr_nrdconta, nrcpf_temp);
                FETCH cr_qtd_prep_confirmados INTO rw_qtd_prep_confirmados;
                CLOSE cr_qtd_prep_confirmados;

                /* Verifica se é o último preposto a aprovar "OU"
                   Verifica se o número de Prepostos que aprovaram chega no mínimo Pedido.

                   Após isso, Gera Protocolo. */

                IF is_last = TRUE OR vr_minprepo = rw_qtd_prep_confirmados.qtd THEN

                    OPEN cr_limites_temp(pr_cdcooper, pr_nrdconta, nrcpf_temp);
                    FETCH cr_limites_temp INTO rw_limites_temp;
                    CLOSE cr_limites_temp;

                    vr_dsinfor1 := 'OPERADOR';
                    vr_dsinfor2 := rw_crapopi.nrcpfope||
                                   '#'||rw_crapopi.nmoperad||
                                   '#'||rw_limites_temp.vllimite_pagto||
                                   '#'||rw_limites_temp.vllimite_transf||
                                   '#'||rw_limites_temp.vllimite_ted||
                                   '#'||rw_limites_temp.vllimite_vrboleto||
                                   '#'||rw_limites_temp.vllimite_folha;

                    /* Monta o dsinfor3 com todos os prepostos que aprovaram o operador XX */
                    vr_dsinfor3 := '';
                    FOR rw_preposto IN cr_preposto(pr_cdcooper, pr_nrdconta, rw_crapopi.nrcpfope) LOOP
                        if rw_preposto.flgaprovado = 1 then
                          IF rw_preposto.nmprepos IS NOT NULL THEN
                             vr_dsinfor3 := vr_dsinfor3 || rw_preposto.nmprepos || '#' || TO_CHAR(rw_preposto.dtaprov) || '#';
                          ELSE
                              vr_dsinfor3 := vr_dsinfor3 || rw_preposto.nmprimtl || '#' || TO_CHAR(rw_preposto.dtaprov) || '#';
                          END IF;
                        end if;
                    END LOOP;

                    vr_dsinfor3 := SUBSTR(vr_dsinfor3, 1, LENGTH(vr_dsinfor3) - 1);

                    /* Gerar Protocolo MD5 */
                    GENE0006.pc_gera_protocolo_md5(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                                  ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                                  ,pr_nrdconta => pr_nrdconta
                                                  ,pr_nrdocmto => 0
                                                  ,pr_nrseqaut => 0
                                                  ,pr_vllanmto => 0
                                                  ,pr_nrdcaixa => 0
                                                  ,pr_gravapro => TRUE
                                                  ,pr_cdtippro => 21 /* Identifica como Operador */
                                                  ,pr_dsinfor1 => vr_dsinfor1
                                                  ,pr_dsinfor2 => vr_dsinfor2
                                                  ,pr_dsinfor3 => vr_dsinfor3
                                                  ,pr_dscedent => ''
                                                  ,pr_flgagend => TRUE
                                                  ,pr_nrcpfope => nrcpf_temp
                                                  ,pr_nrcpfpre => vr_nrcpfpre
                                                  ,pr_nmprepos => ''
                                                  ,pr_dsprotoc => vr_dsprotoc
                                                  ,pr_dscritic => vr_dscritic
                                                  ,pr_des_erro => vr_dsretorn);

                    /* Se retornou erro, gera critica */
                    IF vr_dscritic IS NOT NULL THEN
                       pr_des_erro := vr_dscritic;
                       RAISE vr_exc_erro;
                    END IF;

                    /* Apos as validações, atualiza os Limites na tabela crapopi */
                    BEGIN
                        UPDATE crapopi SET
                            crapopi.vllbolet = rw_limites_temp.vllimite_pagto,
                            crapopi.vllimtrf = rw_limites_temp.vllimite_transf,
                            crapopi.vllimted = rw_limites_temp.vllimite_ted,
                            crapopi.vllimvrb = rw_limites_temp.vllimite_vrboleto,
                            crapopi.vllimflp = rw_limites_temp.vllimite_folha,
                            crapopi.flgsitop = 1
                         WHERE
                            crapopi.cdcooper = pr_cdcooper AND
                            crapopi.nrdconta = pr_nrdconta AND
                            crapopi.nrcpfope = nrcpf_temp;

                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'SQLCODE: ' || SQLCODE || ' ,ERROR: ' || SQLERRM;
                        RAISE vr_exc_erro;
                    END;

                    FOR rw_preposto IN cr_preposto(pr_cdcooper, pr_nrdconta, rw_crapopi.nrcpfope) LOOP
                        BEGIN
                            /* DELETAR TODOS OS REGISTROS */
                            DELETE FROM CECRED.TBCC_OPERAD_APROV t
                            WHERE t.cdcooper       = pr_cdcooper      AND
                                  t.nrdconta       = pr_nrdconta      AND
                                  t.nrcpf_operador = nrcpf_temp       AND
                                  t.nrcpf_preposto = rw_preposto.nrcpfpre;
                        EXCEPTION
                          WHEN OTHERS THEN
                            pr_des_erro := 'Erro no DELETE TBCC_OPERAD_APROV';
                            ROLLBACK;
                            RAISE vr_exc_erro;
                        END;
                    END LOOP;

                END IF; -- if vefificacao se é ultimo a aprovar

            END LOOP; -- fim do loop entre os operadores

            exit when i_pos = i_max_pos;

            i_prev_pos := i_pos + i_delim_length;

        END LOOP; -- fim do loop por , entre os cpf's dos operadores

        IF vr_desclob IS NOT NULL THEN
           vr_desclob := '<OPERADORES>' || vr_desclob || '</OPERADORES>';
           xml_operador := vr_desclob;
           COMMIT;
        END IF;

    EXCEPTION
      WHEN OTHERS THEN
          IF pr_des_erro = '' THEN
              vr_des_erro := 'Erro na pc_confirma_operacao_preposto';
          ELSE
              vr_des_erro := pr_des_erro;
          END IF;
        ROLLBACK;

END pc_confirma_operacao_preposto;
/
