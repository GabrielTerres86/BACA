/*
  Alteracoes:
  
  16/01/19 - INC0030735 - Removida pesquisa por preposto para que as informações de operadores 
             com transação pendente fiquem visiveis para todos os prepostos. (Guilherme Kuhnen)
*/

CREATE OR REPLACE PROCEDURE CECRED.pc_retorna_mensagem_preposto(pr_cdcooper IN crapopi.cdcooper%TYPE,
                                                                pr_nrdconta IN crapopi.nrdconta%TYPE,
                                                                pr_idseqttl IN crapsnh.idseqttl%TYPE,
                                                                xml_operador OUT VARCHAR2) IS
    CURSOR cr_operad_aprov(pr_cdcooper crapass.cdcooper%TYPE,
                           pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT t.nrcpf_operador
        FROM TBCC_OPERAD_APROV t
        WHERE t.cdcooper = pr_cdcooper AND
              t.nrdconta = pr_nrdconta AND
              --t.nrcpf_preposto = pr_nrcpfpre AND --INC0030735
              t.flgaprovado = 0;
        rw_operad_aprov cr_operad_aprov%ROWTYPE;

    CURSOR cr_crapopi (pr_cdcooper crapopi.cdcooper%TYPE,
                       pr_nrdconta crapopi.nrdconta%TYPE,
                       pr_nrcpfope crapopi.nrcpfope%TYPE) IS
        SELECT c.nmoperad, c.nrcpfope, c.dsdcargo, c.flgsitop, c.dsdemail
        FROM crapopi c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta AND
              c.nrcpfope = pr_nrcpfope;
        rw_crapopi cr_crapopi%ROWTYPE;
        
    CURSOR cr_crapsnh (pr_cdcooper crapopi.cdcooper%TYPE,
                       pr_nrdconta crapopi.nrdconta%TYPE,
                       pr_idseqttl crapsnh.idseqttl%TYPE) IS
        SELECT c.nrcpfcgc
        FROM crapsnh c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta AND
              c.idseqttl = pr_idseqttl
              AND ROWNUM = 1;
        rw_crapsnh cr_crapsnh%ROWTYPE;

    vr_desclob CLOB;
    vr_nrcpfpre INTEGER;

    BEGIN

        vr_desclob := '<OPERADORES>';
        
        /*
          INC0030735
        --OPEN cr_crapsnh(pr_cdcooper, pr_nrdconta , pr_idseqttl);
        --FETCH cr_crapsnh INTO rw_crapsnh;
        --CLOSE cr_crapsnh;
        
        --vr_nrcpfpre := rw_crapsnh.nrcpfcgc;
        */

        FOR rw_operad_aprov IN cr_operad_aprov (pr_cdcooper => pr_cdcooper,
                                                pr_nrdconta => pr_nrdconta) LOOP

            FOR rw_crapopi IN cr_crapopi(pr_cdcooper => pr_cdcooper,
                                         pr_nrdconta => pr_nrdconta,
                                         pr_nrcpfope => rw_operad_aprov.nrcpf_operador) LOOP

                vr_desclob := vr_desclob || '<OPERADOR>';

                vr_desclob := vr_desclob || '<nmoperad>' || rw_crapopi.nmoperad || '</nmoperad>';
                vr_desclob := vr_desclob || '<nrcpfope>' || gene0002.fn_mask_cpf_cnpj(rw_crapopi.nrcpfope, 1) || '</nrcpfope>';
                vr_desclob := vr_desclob || '<dsdcargo>' || rw_crapopi.dsdcargo || '</dsdcargo>';
                vr_desclob := vr_desclob || '<flgsitop>' || rw_crapopi.flgsitop || '</flgsitop>';
                vr_desclob := vr_desclob || '<dsdemail>' || rw_crapopi.dsdemail || '</dsdemail>';

                vr_desclob := vr_desclob || '</OPERADOR>';

            END LOOP;

        END LOOP;

        vr_desclob := vr_desclob || '</OPERADORES>';
        xml_operador := vr_desclob;

    END pc_retorna_mensagem_preposto;
/
