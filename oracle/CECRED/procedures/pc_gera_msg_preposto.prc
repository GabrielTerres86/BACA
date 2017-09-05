CREATE OR REPLACE PROCEDURE CECRED.pc_gera_msg_preposto(pr_cdcooper  IN crapopi.cdcooper%TYPE, /* COD COOPERATIVA */
                                                        pr_nrdconta  IN crapopi.nrdconta%TYPE, /* NUMERO DA CONTA */
                                                        pr_nrcpfope  IN crapopi.nrcpfope%TYPE, /* CPF DO OPERADOR */
                                                        pr_idseqttl  IN crapsnh.idseqttl%TYPE, /* IDSEQTTL DO PREPOSTO */
                                                        pr_vllbolet  IN crapopi.vllbolet%TYPE,
                                                        pr_vllimtrf  IN crapopi.vllimtrf%TYPE,
                                                        pr_vllimted  IN crapopi.vllimted%TYPE,
                                                        pr_vllimvrb  IN crapopi.vllimvrb%TYPE,
                                                        pr_vllimflp  IN crapopi.vllimflp%TYPE,
                                                        pr_dscritic  OUT VARCHAR2) IS          /* RETORNO DA CRITICA */
    
    /*********************************************************************
    **                                                                  **
    ** PROGRAMA: ROTINA PARA GERAR MSG PARA PREPOSTO APROVAR            **
    ** AUTOR: ANDREY FORMIGARI (MOUTS)                                  **
    ** DATA CRIAÇÃO: 28/06/2017                                         **
    ** DATA MODIFICAÇÃO: 06/07/2017                                     **
    ** SISTEMA: InternetBank - Menu "Operador"                          **
    **                                                                  **
    *********************************************************************/
        
    CURSOR cr_crapsnh (pr_cdcooper crapopi.cdcooper%TYPE,
                       pr_nrdconta crapopi.nrdconta%TYPE) IS
        SELECT c.nrcpfcgc
        FROM crapsnh c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta AND
              c.tpdsenha = 1 AND
              c.cdsitsnh = 1;
        rw_crapsnh cr_crapsnh%ROWTYPE;
        
    CURSOR cr_check_msg (pr_cdcooper crapopi.cdcooper%TYPE,
                         pr_nrdconta crapopi.nrdconta%TYPE,
                         pr_nrcpfpre crapopi.nrcpfope%TYPE) IS
        SELECT t.nrcpf_preposto, t.nrcpf_operador qtd
        FROM CECRED.TBCC_OPERAD_APROV t
        WHERE t.cdcooper = pr_cdcooper AND
              t.nrdconta = pr_nrdconta AND
              t.nrcpf_operador = pr_nrcpfope AND
              t.flgaprovado = 0;
        rw_check_msg cr_check_msg%ROWTYPE;
        
    CURSOR cr_getcpfpre (pr_cdcooper crapopi.cdcooper%TYPE,
                         pr_nrdconta crapopi.nrdconta%TYPE,
                         pr_idseqttl crapsnh.idseqttl%TYPE) IS
        SELECT c.nrcpfcgc
        FROM crapsnh c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta AND
              c.idseqttl = pr_idseqttl AND 
              c.tpdsenha = 1;
        rw_getcpfpre cr_getcpfpre%ROWTYPE;
    
    CURSOR cr_crapass (pr_cdcooper crapopi.cdcooper%TYPE,
                       pr_nrdconta crapopi.nrdconta%TYPE) IS
        SELECT c.nrcpfcgc, c.idastcjt, c.nmprimtl, c.qtminast
        FROM crapass c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;
        
    CURSOR cr_crapdat (pr_cdcooper crapopi.cdcooper%TYPE) IS
        SELECT
             c.dtmvtolt,
             c.dtmvtocd
        FROM crapdat c
        WHERE c.cdcooper = pr_cdcooper;
        rw_crapdat cr_crapdat%ROWTYPE;
        
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
        
    CURSOR cr_preposto (pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE,
                        pr_nrcpfope crapass.nrcpfcgc%TYPE) IS
        SELECT
          avt.nmdavali AS nmprepos,
          avt.nrcpfcgc AS nrcpfpre,
          (SELECT ass.nmprimtl 
           FROM crapass ass 
           WHERE ass.cdcooper = avt.cdcooper AND 
                 ass.nrdconta = avt.nrdctato) nmprimtl
        FROM
          crapavt avt,
          crapsnh snh
        WHERE
          avt.cdcooper = pr_cdcooper         AND
          avt.nrdconta = pr_nrdconta         AND
          avt.nrcpfcgc = pr_nrcpfope         AND
          snh.cdcooper = avt.cdcooper       AND
          snh.nrdconta = avt.nrdconta       AND
          snh.nrcpfcgc = avt.nrcpfcgc       AND
          snh.tpdsenha = 1                  AND
          snh.cdsitsnh = 1;
        rw_preposto cr_preposto%ROWTYPE;

    vr_dscritic VARCHAR2(300);
    vr_exc_erro EXCEPTION;
    vr_nrcpfpre INTEGER;
    vr_cpfpjpre INTEGER;
    vr_aprovado INTEGER;
    vr_dataapro DATE;
    
    /* Variaveis do Protocolo */
    vr_dsprotoc crappro.dsprotoc%TYPE;
    vr_dsretorn VARCHAR2(350);
    vr_cpfprepo INTEGER;
    vr_dstransa VARCHAR2(500);
    vr_nrdrowid ROWID;
    
    /* informacoes 1, 2 e 3 para gerar o Protolo */
    vr_dsinfor1 crappro.dsinform##1%TYPE;
    vr_dsinfor2 crappro.dsinform##2%TYPE;
    vr_dsinfor3 crappro.dsinform##3%TYPE;

    BEGIN
        
        OPEN cr_getcpfpre(pr_cdcooper, pr_nrdconta , pr_idseqttl);
        FETCH cr_getcpfpre INTO rw_getcpfpre;
        CLOSE cr_getcpfpre;
        
        OPEN cr_crapass(pr_cdcooper, pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;
        
        OPEN cr_check_msg(pr_cdcooper,
                          pr_nrdconta,
                          pr_nrcpfope);
        FETCH cr_check_msg INTO rw_check_msg;
        
        IF cr_check_msg%NOTFOUND THEN
        
            /*
            **  Buscar o preposto que está chamado esta rotina. 
            **  Busca pela sequencia do titular, cooperativa e numero de conta.
            */
            vr_nrcpfpre := rw_getcpfpre.nrcpfcgc;
            
            /* Se conta conjunta e numero minimo de prepostos maior que zero */
            IF rw_crapass.idastcjt = 1 AND rw_crapass.qtminast > 1 THEN
                
                FOR rw_crapsnh IN cr_crapsnh(pr_cdcooper, pr_nrdconta) LOOP
                    
                    /* Verificar se já existe alterações direcionadoas para este operador */
                    
                        
                        /*
                        **  Se for o mesmo cpf, então aprovar automaticamente a mensagem do mesmo.
                        **  Pois não é preciso o preposto ter que aprovar a propria alteração
                        */
                        IF vr_nrcpfpre = rw_crapsnh.nrcpfcgc THEN
                           vr_dataapro := SYSDATE;
                           vr_aprovado := 1;
                        ELSE
                           vr_dataapro := NULL;
                           vr_aprovado := 0;
                        END IF;
                        
                        BEGIN
                            INSERT INTO CECRED.TBCC_OPERAD_APROV t
                               (t.cdcooper,
                                t.nrdconta,
                                t.nrcpf_preposto,
                                t.nrcpf_operador,
                                t.flgaprovado,
                                t.dhaprovacao,
                                t.VLLIMITE_PAGTO,
                                t.VLLIMITE_TRANSF,
                                t.VLLIMITE_TED,
                                t.VLLIMITE_VRBOLETO,
                                t.VLLIMITE_FOLHA)
                            VALUES
                               (pr_cdcooper,
                                pr_nrdconta,
                                rw_crapsnh.nrcpfcgc, /* CPF DO PREPOSTO */
                                pr_nrcpfope,  /* CPF DO OPERADOR */
                                vr_aprovado,  /* se for o mesmo cpf, já aprova a flag */
                                vr_dataapro,
                                pr_vllbolet,
                                pr_vllimtrf,
                                pr_vllimted,
                                pr_vllimvrb,
                                pr_vllimflp); /* se for o mesmo cpf, já aprova a data */
                                
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_dscritic := 'SQLCODE: ' || SQLCODE || ' ,ERROR: ' || SQLERRM;
                            ROLLBACK;
                            RAISE vr_exc_erro;
                        END;
                END LOOP;
                
            ELSE /* Gerar Protocolo Automaticamente para uma 
                    conta PJ "OU" Conta com numero minimo de 
                    Preposto = Zero */
                
                IF rw_crapass.qtminast < 2 AND rw_crapass.idastcjt = 1 THEN
                    vr_cpfprepo := vr_nrcpfpre;
                ELSE
                    vr_cpfprepo := rw_crapass.nrcpfcgc;
                END IF;
                
                OPEN cr_crapdat(pr_cdcooper);
                FETCH cr_crapdat INTO rw_crapdat;
                CLOSE cr_crapdat;
                
                OPEN cr_crapopi(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrcpfope => pr_nrcpfope);
                FETCH cr_crapopi INTO rw_crapopi;
                CLOSE cr_crapopi;
                
                BEGIN
                    UPDATE crapopi SET
                        crapopi.vllbolet = pr_vllbolet,
                        crapopi.vllimtrf = pr_vllimtrf,
                        crapopi.vllimted = pr_vllimted,
                        crapopi.vllimvrb = pr_vllimvrb,
                        crapopi.vllimflp = pr_vllimflp,
                        crapopi.flgsitop = 1
                     WHERE
                        crapopi.cdcooper = pr_cdcooper AND
                        crapopi.nrdconta = pr_nrdconta AND
                        crapopi.nrcpfope = pr_nrcpfope;
                                
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'SQLCODE: ' || SQLCODE || ' ,ERROR: ' || SQLERRM;
                    ROLLBACK;
                    RAISE vr_exc_erro;
                END;
                
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
                                         ,pr_dsdadant => pr_nrcpfope
                                         ,pr_dsdadatu => vr_cpfprepo);
                
                vr_dsinfor1 := 'OPERADOR';
                vr_dsinfor2 := rw_crapopi.nrcpfope||
                               '#'||rw_crapopi.nmoperad||
                               '#'||rw_crapopi.vllbolet||
                               '#'||rw_crapopi.vllimtrf||
                               '#'||rw_crapopi.vllimted||
                               '#'||rw_crapopi.vllimvrb||
                               '#'||rw_crapopi.vllimflp;
                               
                /* Monta o dsinfor3 com todos os prepostos que aprovaram o operador XX */
                vr_dsinfor3 := '';
                FOR rw_preposto IN cr_preposto(pr_cdcooper, pr_nrdconta, vr_cpfprepo) LOOP
                    IF rw_preposto.nmprepos IS NOT NULL THEN
                       vr_dsinfor3 := vr_dsinfor3 || rw_preposto.nmprepos || '#' || TO_CHAR(SYSDATE);
                    ELSE
                        vr_dsinfor3 := vr_dsinfor3 || rw_preposto.nmprimtl || '#' || TO_CHAR(SYSDATE);
                    END IF;
                END LOOP;
                
                -- Gerar Protocolo MD5
                GENE0006.pc_gera_protocolo_md5(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_nrdocmto => 0
                                              ,pr_nrseqaut => 0
                                              ,pr_vllanmto => 0
                                              ,pr_nrdcaixa => 0
                                              ,pr_gravapro => TRUE
                                              ,pr_cdtippro => 21 -- Identifica como Operador
                                              ,pr_dsinfor1 => vr_dsinfor1
                                              ,pr_dsinfor2 => vr_dsinfor2
                                              ,pr_dsinfor3 => vr_dsinfor3
                                              ,pr_dscedent => ''
                                              ,pr_flgagend => TRUE
                                              ,pr_nrcpfope => pr_nrcpfope
                                              ,pr_nrcpfpre => vr_cpfprepo
                                              ,pr_nmprepos => ''
                                              ,pr_dsprotoc => vr_dsprotoc
                                              ,pr_dscritic => vr_dscritic
                                              ,pr_des_erro => vr_dsretorn);
                
            END IF;
        ELSE
            vr_dscritic := 'Este operador esta pendente de aprovacao, favor aprovar antes para confirmar esta alteracao';
            ROLLBACK;
            RAISE vr_exc_erro;
        END IF;
        CLOSE cr_check_msg;
        
        IF vr_dscritic <> '' THEN
            ROLLBACK;
            RAISE vr_exc_erro;
        END IF;
        
        vr_dscritic := '';
        pr_dscritic := '';
        COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := vr_dscritic;
        ROLLBACK;

END pc_gera_msg_preposto;
/
