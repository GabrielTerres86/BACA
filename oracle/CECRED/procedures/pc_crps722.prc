CREATE OR REPLACE PROCEDURE CECRED.pc_crps722 (pr_cdcritic  OUT PLS_INTEGER   -- Codigo da Critica
                                              ,pr_dscritic  OUT VARCHAR2) IS  -- Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps722
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Mauro (MOUTS)
     Data    : Julho/2017                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Geracao do Grupo Economico Novo

     Alteracoes: 20/08/2018 - Correção para não duplicar contas/cpfcgc em grupos economicos;
                            - Criar integrantes a partir do cadastro de associados de contas não cadastradas em grupos;
                            - Excluir grupos que não possuem integrante. 
                            PRJ450 - Regulatorio (AMcom - Mario/Odirlei)

                 20/09/2018 - Ajuste para garantir que não inclua cooperado de outra cooperativa no grupo.
                              PRJ450 - Regulatorio(Odirlei-AMcom)           

  ............................................................................ */

  DECLARE
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_saida                  EXCEPTION;
    vr_exc_erro                   EXCEPTION;
    vr_cdcritic                   PLS_INTEGER;
    vr_dscritic                   VARCHAR2(4000);
    vr_ind_grupo_economico_novo   VARCHAR2(20);
    vr_ind_grupo_ori              VARCHAR2(20);
    vr_ind_integrante_grupo       VARCHAR2(30);
    vr_ind_integrante_outro       VARCHAR2(30);
    vr_ind_integrante_ori         VARCHAR2(30);
    vr_ind_integrante_dst         VARCHAR2(30);
    vr_idgrupo                    tbcc_grupo_economico.idgrupo%TYPE;
    vr_idintegrante               tbcc_grupo_economico_integ.idintegrante%TYPE;    
    vr_flginteg                   BOOLEAN;
    vr_flginteg_outro             BOOLEAN;
    vr_achou                      INTEGER := 0;
    vr_nrdgrupo_ant               crapgrp.nrdgrupo%TYPE := 0;
    vr_idgrupo_ant                tbcc_grupo_economico.idgrupo%TYPE := 0;
    vr_flggravo                   BOOLEAN;
    vr_cdcooper_ant               NUMBER;
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    -- Definicao do tipo da tabela do Grupo Economico
    TYPE typ_reg_grupo_economico_novo IS
     RECORD(idgrupo  tbcc_grupo_economico_integ.idgrupo%TYPE);
     	
    TYPE typ_tab_grupo_economico_novo IS
      TABLE OF typ_reg_grupo_economico_novo
        INDEX BY VARCHAR2(20); -- Codigo da Cooperativa + Numero da Conta
    -- Vetor para armazenar os dados do Grupo Economico
    vr_tab_grupo_economico_novo typ_tab_grupo_economico_novo;    

    -- Definicao do tipo da tabela do Grupo Economico
    TYPE typ_reg_grupo_economico_inte IS
     RECORD(idintegrante  tbcc_grupo_economico_integ.idintegrante%TYPE
           ,tpcarga       tbcc_grupo_economico_integ.tpcarga%TYPE
           ,flgexcluir    BOOLEAN);
     
    TYPE typ_tab_grupo_economico_inte IS
      TABLE OF typ_reg_grupo_economico_inte
        INDEX BY VARCHAR2(30); -- Codigo do Grupo + Codigo da Cooperativa + Numero da Conta
    -- Vetor para armazenar os dados do Grupo Economico
    vr_tab_grupo_economico_inte typ_tab_grupo_economico_inte;
    
    ------------------------------- CURSORES ---------------------------------
    -- Relacionar Cooperativas
    CURSOR cr_crapcop IS
      select cop.cdcooper
        from crapcop cop
       where cop.flgativo = 1
         and cop.cdcooper <> 3         
       order by cop.cdcooper;
       
    CURSOR cr_grupo_economico_novo IS
      SELECT idgrupo
            ,cdcooper
            ,nrdconta             
        FROM tbcc_grupo_economico g
       --> grupos ativos
       WHERE EXISTS ( SELECT 1
                        FROM tbcc_grupo_economico_integ i
                       WHERE g.cdcooper = i.cdcooper
                         AND g.idgrupo  = i.idgrupo
                         AND i.dtexclusao IS NULL);

    CURSOR cr_integrante_grupo IS
      SELECT idgrupo
            ,idintegrante
            ,cdcooper
            ,nrdconta
            ,tpcarga
        FROM tbcc_grupo_economico_integ
       WHERE tbcc_grupo_economico_integ.dtexclusao IS NULL;
            
    --> Verificar se cooperado é integrante em outro grupo   
    CURSOR cr_integrante ( pr_cdcooper IN crapcop.cdcooper%TYPE,
                           pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT idgrupo
            ,idintegrante
            ,cdcooper
            ,nrdconta
            ,tpcarga
        FROM tbcc_grupo_economico_integ itg
       WHERE itg.dtexclusao IS NULL
         AND itg.cdcooper = pr_cdcooper
         AND itg.nrdconta = pr_nrdconta;
    rw_integrante cr_integrante%ROWTYPE;   
    
    --> Verificar se cooperado é integrante em outro grupo   
    CURSOR cr_integrante_outro ( pr_cdcooper IN crapcop.cdcooper%TYPE,
                                 pr_idgrupo  IN NUMBER,
                                 pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT idgrupo
            ,cdcooper
            ,nrdconta
            ,tpcarga
        FROM tbcc_grupo_economico_integ itg
       WHERE itg.dtexclusao IS NULL
         AND itg.cdcooper = pr_cdcooper
         AND itg.nrdconta = pr_nrdconta
         AND itg.idgrupo  <> pr_idgrupo
      UNION
      SELECT idgrupo
            ,cdcooper
            ,nrdconta             
        FROM tbcc_grupo_economico g
       --> grupos ativos
       WHERE g.cdcooper = pr_cdcooper
         AND g.nrdconta = pr_nrdconta
         AND g.idgrupo  <> pr_idgrupo
         AND EXISTS ( SELECT 1
                        FROM tbcc_grupo_economico_integ i
                       WHERE g.cdcooper = i.cdcooper
                         AND g.idgrupo  = i.idgrupo
                         AND i.dtexclusao IS NULL);
        
    rw_integrante_outro cr_integrante_outro%ROWTYPE;   
    
    --> Verificar se cooperado é o formador do grupo   
    CURSOR cr_grupo_conta ( pr_cdcooper IN crapcop.cdcooper%TYPE,
                            pr_idgrupo  IN tbcc_grupo_economico.idgrupo%TYPE,
                            pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT 1
        FROM tbcc_grupo_economico grp
       WHERE grp.cdcooper = pr_cdcooper
         AND grp.idgrupo  = pr_idgrupo
         AND grp.nrdconta = pr_nrdconta;
    rw_grupo_conta cr_grupo_conta%ROWTYPE;  
    
    --> Verificar se a conta formadora ainda pertence ao grupo na grp     
    CURSOR cr_grupo_2(pr_idgrupo   NUMBER,
                      pr_nrdgrupo  NUMBER,
                      pr_cdcooper  crapcop.cdcooper%TYPE,
                      pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT gre.idgrupo
        FROM tbcc_grupo_economico gre,
             crapass ass_ge,
             crapgrp grp1,
             crapass ass_gr1,
             crapass ass_gr2
       WHERE gre.cdcooper  = ass_ge.cdcooper
         AND gre.nrdconta  = ass_ge.nrdconta
         AND gre.idgrupo   = pr_idgrupo
         AND grp1.cdcooper = pr_cdcooper
         AND grp1.nrdgrupo = pr_nrdgrupo
         AND grp1.cdcooper = ass_gr1.cdcooper      
         AND grp1.nrdconta = ass_gr1.nrdconta
         AND ass_ge.nrcpfcnpj_base = ass_gr1.nrcpfcnpj_base
         
         AND grp1.cdcooper = ass_gr2.cdcooper      
         AND grp1.nrctasoc = ass_gr2.nrdconta
         AND ass_ge.nrcpfcnpj_base = ass_gr2.nrcpfcnpj_base
         
      UNION
      --> Ou se algum integrante do grupo foi adicionado manualmente no grupo novo
      SELECT gre.idgrupo
        FROM tbcc_grupo_economico_integ gre
            ,crapass                    ass_ge
            ,crapgrp                    grp1
            ,crapass                    ass_gr1
            ,crapass                    ass_gr2
       WHERE gre.cdcooper = ass_ge.cdcooper
         AND gre.nrdconta = ass_ge.nrdconta
         AND gre.idgrupo = pr_idgrupo
         AND gre.dtexclusao IS NULL      
         AND gre.tpcarga = 3
         AND grp1.cdcooper = pr_cdcooper
         AND grp1.nrdgrupo = pr_nrdgrupo
         AND grp1.cdcooper = ass_gr1.cdcooper
         AND grp1.nrdconta = ass_gr1.nrdconta
         AND ass_ge.nrcpfcnpj_base = ass_gr1.nrcpfcnpj_base
            
         AND grp1.cdcooper = ass_gr2.cdcooper
         AND grp1.nrctasoc = ass_gr2.nrdconta
         AND ass_ge.nrcpfcnpj_base = ass_gr2.nrcpfcnpj_base
      UNION
      
      --> Verificar se o formador do grupo novo pertence a um mesmo grupo no grupo antigo
      --> a essa conta, justificando permanecerem no mesmo grupo novo
      SELECT gre.idgrupo
        FROM tbcc_grupo_economico gre,
             crapass ass_ge,
             crapgrp grp1,
             crapass ass_gr1,
             crapass ass_gr2           
       WHERE gre.cdcooper  = ass_ge.cdcooper
         AND gre.nrdconta  = ass_ge.nrdconta
         AND gre.idgrupo   = pr_idgrupo
         AND grp1.cdcooper = pr_cdcooper
         AND grp1.nrdgrupo <> pr_nrdgrupo
         AND grp1.cdcooper = ass_gr1.cdcooper      
         AND grp1.nrdconta = ass_gr1.nrdconta
         AND ass_ge.cdcooper = ass_gr1.cdcooper
         AND ass_ge.nrcpfcnpj_base = ass_gr1.nrcpfcnpj_base
               
         AND grp1.cdcooper = ass_gr2.cdcooper      
         AND grp1.nrctasoc = ass_gr2.nrdconta
         AND ass_ge.cdcooper = ass_gr2.cdcooper
         AND ass_ge.nrcpfcnpj_base = ass_gr2.nrcpfcnpj_base
         AND EXISTS ( SELECT * 
                        FROM crapgrp grp2,
                             crapass ass_gr21,
                             crapass ass_gr22,
                             crapass ass2
                      WHERE grp2.nrdgrupo = grp1.nrdgrupo
                        AND grp2.cdcooper = pr_cdcooper
                        AND ass2.cdcooper = pr_cdcooper
                        AND ass2.nrdconta = pr_nrdconta
                          
                        AND grp2.cdcooper = ass_gr21.cdcooper      
                        AND grp2.nrdconta = ass_gr21.nrdconta
                        AND ass2.cdcooper = ass_gr21.cdcooper
                        AND ass2.nrcpfcnpj_base = ass_gr21.nrcpfcnpj_base
                                       
                        AND grp2.cdcooper = ass_gr22.cdcooper      
                        AND grp2.nrctasoc = ass_gr22.nrdconta
                        AND ass2.cdcooper = ass_gr22.cdcooper
                        AND ass2.nrcpfcnpj_base = ass_gr22.nrcpfcnpj_base) ;
    rw_grupo_2 cr_grupo_2%ROWTYPE;        
            
    -- Busca os contratos
    CURSOR cr_grupo_economico IS
        SELECT crapgrp.cdcooper
              ,crapgrp.nrdconta
              ,crapgrp.nrdgrupo          
              ,crapgrp.nrctasoc
              ,crapgrp.nrcpfcgc
              ,crapgrp.inpessoa
              ,crapavt.persocio
              ,CASE WHEN upper(crapavt.dsproftl) LIKE '%SOCIO%' THEN 2
                    ELSE 7 
               END AS tpvinculo
              ,crapass.nmprimtl
          FROM crapgrp
          JOIN crapdat
            ON crapdat.cdcooper = crapgrp.cdcooper
     left join crapavt                  
            on crapavt.cdcooper = crapgrp.cdcooper
           and crapavt.nrdconta = crapgrp.nrdconta
           and crapavt.nrdctato = crapgrp.nrctasoc
           AND crapavt.tpctrato = 6
          join crapass
            on crapass.cdcooper = crapgrp.cdcooper
           and crapass.nrdconta = crapgrp.nrctasoc     
         WHERE crapgrp.nrdconta <> crapgrp.nrctasoc
          -- AND crapgrp.dtmvtolt = crapdat.dtmvtoan Remover validação, pois existe apenas uma grp ativa, caso estiver com outra data continua sendo a ativa
         ORDER BY crapgrp.cdcooper,
                  crapgrp.nrdgrupo, 
                  crapgrp.idseqttl DESC
           ;
          
    --> Buscar cooperados da mesa base CPF/CNPJ     
    CURSOR cr_crapass (pr_cdcooper IN INTEGER,
                       pr_nrdconta IN NUMBER)IS
      SELECT ass.nrcpfcnpj_base,ass.nrcpfcgc,nvl(ass2.nrdconta,ass.nrdconta) nrdconta 
        FROM crapass ass,
             crapass ass2
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND ass.cdcooper = ass2.cdcooper
         AND ass.nrcpfcnpj_base = ass2.nrcpfcnpj_base;
         
    -- Incluir Grupo Economico Integrante a partir do cadastro de Associados
    CURSOR cr_grupo_associado(pr_cdcooper crapcop.cdcooper%TYPE) is
        SELECT DISTINCT ge.cdcooper
                       ,a2.nrdconta
                       ,a2.nmprimtl
                       ,gi.idgrupo
                       ,a2.nrcpfcgc
                       ,gi.tppessoa tppessoa
          FROM tbcc_grupo_economico       ge
              ,tbcc_grupo_economico_integ gi
              ,crapass                    a
              ,crapass                    a2
         WHERE ge.cdcooper = pr_cdcooper
           --> grupos ativos
           AND EXISTS ( SELECT 1
                          FROM tbcc_grupo_economico_integ i
                         WHERE ge.cdcooper = i.cdcooper
                           AND ge.idgrupo  = i.idgrupo
                           AND i.dtexclusao IS NULL)
           AND gi.cdcooper = ge.cdcooper
           AND gi.idgrupo = ge.idgrupo
           AND gi.dtexclusao IS NULL
           --
           AND a.cdcooper = ge.cdcooper
           AND a.inpessoa = gi.tppessoa
           AND a.nrdconta = gi.nrdconta
           --AND a.dtelimin IS NULL
           --
           AND a.cdcooper = a2.cdcooper
           AND a.nrcpfcnpj_base = a2.nrcpfcnpj_base
           AND a2.nrdconta <> gi.nrdconta
           --AND a2.dtdemiss IS NULL
               
            --
        UNION
        SELECT ge.cdcooper
              ,a2.nrdconta
              ,a2.nmprimtl
              ,ge.idgrupo
              ,a2.nrcpfcgc
              ,a.inpessoa tppessoa
          FROM tbcc_grupo_economico ge
              ,crapass              a
              ,crapass              a2
         WHERE ge.cdcooper = pr_cdcooper
           --> grupos ativos
           AND EXISTS ( SELECT 1
                          FROM tbcc_grupo_economico_integ i
                         WHERE ge.cdcooper = i.cdcooper
                           AND ge.idgrupo  = i.idgrupo
                           AND i.dtexclusao IS NULL)
           AND a.cdcooper = ge.cdcooper
           AND a.nrdconta = ge.nrdconta
           --AND a.dtelimin IS NULL
           AND a.cdcooper = a2.cdcooper
           AND a.nrcpfcnpj_base = a2.nrcpfcnpj_base
           AND a2.nrdconta <> ge.nrdconta
           --AND a2.dtdemiss IS NULL
          order by  1, 4, 2, 3;   
     
    --> buscar dados da conta     
    CURSOR cr_crapass_2 (pr_cdcooper crapass.cdcooper%TYPE,
                         pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nrcpfcgc,
             ass.inpessoa,
             ass.nmprimtl
        FROM crapass ass 
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;                           
    rw_crapass_2 cr_crapass_2%ROWTYPE;     
    
    --> Verificar se existe o registro devido alguma conta incluida manualmente
    CURSOR cr_tbintegrante_exc (pr_idintegrante IN tbcc_grupo_economico_integ.idintegrante%TYPE) IS
      SELECT 1
        FROM tbcc_grupo_economico_integ it,
             crapass ass       
       WHERE it.idintegrante = pr_idintegrante 
         AND it.cdcooper = ass.cdcooper
         AND it.nrdconta = ass.nrdconta
         AND EXISTS (SELECT 1 
                       FROM tbcc_grupo_economico_integ it2,
                            crapass ass2
                      WHERE it2.cdcooper = ass2.cdcooper
                         AND it2.nrdconta = ass2.nrdconta
                         AND it2.dtexclusao IS NULL
                         AND it2.tpcarga = 3
                         AND ass.nrcpfcnpj_base = ass2.nrcpfcnpj_base);                
    rw_tbintegrante_exc cr_tbintegrante_exc%ROWTYPE;
    
    --> Verificar se o integrante foi excluido hoje pelo processo automatico
    CURSOR cr_tbintegrante_exc2 (pr_idgrupo    tbcc_grupo_economico_integ.idgrupo%TYPE,  
                                 pr_cdcooper   tbcc_grupo_economico_integ.cdcooper%TYPE, 
                                 pr_nrdconta   tbcc_grupo_economico_integ.nrdconta%TYPE)IS
      SELECT it.rowid
        FROM tbcc_grupo_economico_integ it
       WHERE it.idgrupo  = pr_idgrupo
         AND it.cdcooper = pr_cdcooper
         AND it.nrdconta = pr_nrdconta
         AND trunc(it.dtexclusao) = trunc(SYSDATE) 
         AND it.cdoperad_exclusao = 1;
    rw_tbintegrante_exc2 cr_tbintegrante_exc2%ROWTYPE;
    
    --> INCORPORAR GRUPO
    PROCEDURE pc_incorpora_grupo(pr_cdcooper      IN tbcc_grupo_economico.cdcooper%TYPE,
                                 pr_idgrupo_ori   IN tbcc_grupo_economico.idgrupo%TYPE,
                                 pr_idgrupo_dst   IN tbcc_grupo_economico.idgrupo%TYPE,
                                 pr_dscritic     OUT VARCHAR2)IS

      --> Buscar dados do grupo para incorpora-lo a outro
      CURSOR cr_grupo_old (pr_cdcooper     tbcc_grupo_economico.cdcooper%TYPE,
                           pr_idgrupo_ori  tbcc_grupo_economico.idgrupo%TYPE,
                           pr_idgrupo_dst  tbcc_grupo_economico.idgrupo%TYPE
                          )IS
        SELECT g.*,
               ass.nrcpfcgc,
               ass.nmprimtl,
               ass.inpessoa
          FROM tbcc_grupo_economico g,
               crapass ass
         WHERE g.cdcooper = ass.cdcooper
           AND g.nrdconta = ass.nrdconta
           AND g.cdcooper = pr_cdcooper
           AND g.idgrupo  = pr_idgrupo_ori
           --> incorporar todos os integrantes que ainda não estejam
           AND NOT EXISTS(  SELECT *
                              FROM tbcc_grupo_economico_integ g2
                             WHERE g2.cdcooper = g.cdcooper
                               AND g2.nrdconta = g.nrdconta
                               AND g2.idgrupo  = pr_idgrupo_dst
                               AND g2.dtexclusao IS NULL)

           --> e se não for já o principal
           AND NOT EXISTS(  SELECT *
                              FROM tbcc_grupo_economico g2
                             WHERE g2.cdcooper = g.cdcooper
                               AND g2.nrdconta = g.nrdconta
                               AND g2.idgrupo  = pr_idgrupo_dst);

      --> Buscar Dados dos Integrantes para incorpora-los 
      CURSOR cr_grupo_int_old (pr_cdcooper     tbcc_grupo_economico.cdcooper%TYPE,
                               pr_idgrupo_ori  tbcc_grupo_economico.idgrupo%TYPE,
                               pr_idgrupo_dst  tbcc_grupo_economico.idgrupo%TYPE
                             )IS
        SELECT g.*,
               g.rowid
          FROM tbcc_grupo_economico_integ g
         WHERE g.cdcooper = pr_cdcooper
           AND g.idgrupo  = pr_idgrupo_ori
           AND g.dtexclusao IS NULL;
                               
      CURSOR cr_grupo_int_old_2 (pr_cdcooper     tbcc_grupo_economico.cdcooper%TYPE,
                                 pr_idgrupo_ori  tbcc_grupo_economico.idgrupo%TYPE,
                                 pr_idgrupo_dst  tbcc_grupo_economico.idgrupo%TYPE,
                                 pr_nrdconta     crapass.nrdconta%TYPE
                                )IS
        SELECT g.*,
               g.rowid
          FROM tbcc_grupo_economico_integ g
         WHERE g.cdcooper = pr_cdcooper
           AND g.idgrupo  = pr_idgrupo_ori
           AND g.nrdconta = pr_nrdconta
           AND g.dtexclusao IS NULL
           --> incorporar todos os integrantes que ainda não estejam
           AND NOT EXISTS(  SELECT *
                              FROM tbcc_grupo_economico_integ g2
                             WHERE g2.cdcooper = g.cdcooper
                               AND g2.nrdconta = g.nrdconta
                               AND g2.idgrupo  = pr_idgrupo_dst
                               AND g2.dtexclusao IS NULL)

           --> e se não for já o principal
           AND NOT EXISTS(  SELECT *
                              FROM tbcc_grupo_economico g2
                             WHERE g2.cdcooper = g.cdcooper
                               AND g2.nrdconta = g.nrdconta
                               AND g2.idgrupo  = pr_idgrupo_dst);  
      rw_grupo_int_old_2 cr_grupo_int_old_2%ROWTYPE;    
      
      vr_flggrupo BOOLEAN;                                              

  BEGIN

      --> Incorporar formador
      FOR rw_grupo_old IN cr_grupo_old (pr_cdcooper     => pr_cdcooper,
                                        pr_idgrupo_ori  => pr_idgrupo_ori,
                                        pr_idgrupo_dst  => pr_idgrupo_dst) LOOP
        
        
        BEGIN
          INSERT INTO tbcc_grupo_economico_integ
                      ( idintegrante,
                        idgrupo,
                        nrcpfcgc,
                        cdcooper,
                        nrdconta,
                        tppessoa,
                        tpcarga,
                        tpvinculo,
                        peparticipacao,
                        dtinclusao,
                        cdoperad_inclusao,
                        dtexclusao,
                        cdoperad_exclusao,
                        nmintegrante)
              VALUES  ( NULL,                        --> idintegrante,
                        pr_idgrupo_dst,              --> idgrupo,
                        rw_grupo_old.nrcpfcgc,       --> nrcpfcgc,
                        rw_grupo_old.cdcooper,       --> cdcooper,
                        rw_grupo_old.nrdconta,       --> nrdconta,
                        rw_grupo_old.inpessoa,       --> tppessoa,
                        2,                           --> tpcarga,
                        7,                           --> tpvinculo,
                        0,                           --> peparticipacao,
                        trunc(SYSDATE),              --> dtinclusao,
                        1,                           --> cdoperad_inclusao,
                        NULL,                        --> dtexclusao,
                        NULL,                        --> cdoperad_exclusao,
                        rw_grupo_old.nmprimtl)      --> nmintegrante)
                        RETURNING tbcc_grupo_economico_integ.idintegrante INTO vr_idintegrante;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao incluir integrante:'||SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        -- Chave do Integrante do Grupo Economico
        vr_ind_integrante_ori := lpad(pr_idgrupo_ori,10,'0')||lpad(pr_cdcooper,10,'0')||lpad(rw_grupo_old.nrdconta,10,'0');
        vr_ind_integrante_dst := lpad(pr_idgrupo_dst,10,'0')||lpad(pr_cdcooper,10,'0')||lpad(rw_grupo_old.nrdconta,10,'0');
          
        IF vr_tab_grupo_economico_inte.exists(vr_ind_integrante_ori) THEN
          vr_tab_grupo_economico_inte(vr_ind_integrante_dst) := vr_tab_grupo_economico_inte(vr_ind_integrante_ori);
          vr_tab_grupo_economico_inte(vr_ind_integrante_dst).flgexcluir   := TRUE;
          
          --> Marcar o origem para excluir
          vr_tab_grupo_economico_inte(vr_ind_integrante_ori).flgexcluir   := TRUE;
            
        ELSE
          vr_tab_grupo_economico_inte(vr_ind_integrante_dst).idintegrante := vr_idintegrante;
          vr_tab_grupo_economico_inte(vr_ind_integrante_dst).tpcarga      := 2;
          --> marcar para não excluir, pois foi adicionado o formador
          vr_tab_grupo_economico_inte(vr_ind_integrante_dst).flgexcluir   := FALSE;
        END IF;
        
        -- Indice do Grupo Economico Novo
        vr_ind_grupo_ori := lpad(pr_cdcooper,10,'0')||lpad(rw_grupo_old.nrdconta,10,'0');             
        IF vr_tab_grupo_economico_novo.EXISTS(vr_ind_grupo_ori) THEN
          vr_tab_grupo_economico_novo.delete(vr_ind_grupo_ori); 
        END IF;
        
      END LOOP;

      --> Incorporar integrantes
      FOR rw_grupo_old IN cr_grupo_int_old (pr_cdcooper     => pr_cdcooper,
                                            pr_idgrupo_ori  => pr_idgrupo_ori,
                                            pr_idgrupo_dst  => pr_idgrupo_dst) LOOP
        
        OPEN cr_grupo_int_old_2 (pr_cdcooper     => pr_cdcooper,
                                 pr_idgrupo_ori  => pr_idgrupo_ori,
                                 pr_idgrupo_dst  => pr_idgrupo_dst,
                                 pr_nrdconta     => rw_grupo_old.nrdconta);
        FETCH  cr_grupo_int_old_2 INTO rw_grupo_int_old_2;
        vr_flggrupo := cr_grupo_int_old_2%NOTFOUND;
        CLOSE cr_grupo_int_old_2;
        
        IF vr_flggrupo = FALSE THEN
        
          BEGIN
            INSERT INTO tbcc_grupo_economico_integ
                        ( idintegrante,
                          idgrupo,
                          nrcpfcgc,
                          cdcooper,
                          nrdconta,
                          tppessoa,
                          tpcarga,
                          tpvinculo,
                          peparticipacao,
                          dtinclusao,
                          cdoperad_inclusao,
                          dtexclusao,
                          cdoperad_exclusao,
                          nmintegrante)
                VALUES  ( rw_grupo_old.idintegrante,        --> idintegrante,
                          pr_idgrupo_dst,                   --> idgrupo,
                          rw_grupo_old.nrcpfcgc,            --> nrcpfcgc,
                          rw_grupo_old.cdcooper,            --> cdcooper,
                          rw_grupo_old.nrdconta,            --> nrdconta,
                          rw_grupo_old.tppessoa,            --> tppessoa,
                          rw_grupo_old.tpcarga,             --> tpcarga,
                          rw_grupo_old.tpvinculo,           --> tpvinculo,
                          rw_grupo_old.peparticipacao,      --> peparticipacao,
                          rw_grupo_old.dtinclusao,          --> dtinclusao,
                          rw_grupo_old.cdoperad_inclusao,   --> cdoperad_inclusao,
                          rw_grupo_old.dtexclusao,          --> dtexclusao,
                          rw_grupo_old.cdoperad_exclusao,   --> cdoperad_exclusao,
                          rw_grupo_old.nmintegrante)        --> nmintegrante
                          RETURNING tbcc_grupo_economico_integ.idintegrante INTO vr_idintegrante;

          EXCEPTION
            WHEN OTHERS THEN 
              vr_dscritic := 'Erro ao incluir integrante:'||SQLERRM;
              RAISE vr_exc_erro;
              
          END;
          
          
          -- Chave do Integrante do Grupo Economico
          vr_ind_integrante_ori := lpad(pr_idgrupo_ori,10,'0')||lpad(pr_cdcooper,10,'0')||lpad(rw_grupo_old.nrdconta,10,'0');
          vr_ind_integrante_dst := lpad(pr_idgrupo_dst,10,'0')||lpad(pr_cdcooper,10,'0')||lpad(rw_grupo_old.nrdconta,10,'0');
          
          IF vr_tab_grupo_economico_inte.exists(vr_ind_integrante_ori) THEN
            vr_tab_grupo_economico_inte(vr_ind_integrante_dst) := vr_tab_grupo_economico_inte(vr_ind_integrante_ori);
            vr_tab_grupo_economico_inte(vr_ind_integrante_dst).idintegrante := vr_idintegrante;
            -- Nao marcar como ok(nao excluir), pois deve validar conforme a validação do grupo crapgrp
            --vr_tab_grupo_economico_inte(vr_ind_integrante_dst).flgexcluir   := TRUE;
            
            --> Marcar o origem para excluir
            vr_tab_grupo_economico_inte(vr_ind_integrante_ori).flgexcluir   := TRUE;
          ELSE
            vr_tab_grupo_economico_inte(vr_ind_integrante_dst).idintegrante := vr_idintegrante;
            vr_tab_grupo_economico_inte(vr_ind_integrante_dst).tpcarga      := 2;
            vr_tab_grupo_economico_inte(vr_ind_integrante_dst).flgexcluir   := FALSE;
          END IF;
          
          
        END IF;
        
        
      END LOOP;


    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao incorporar cooperados do grupo '||pr_idgrupo_ori||
                       ' para '||pr_idgrupo_dst||': '||SQLERRM;           
    END pc_incorpora_grupo;     
                
  BEGIN
    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    vr_tab_grupo_economico_novo.DELETE;
    vr_tab_grupo_economico_inte.DELETE;
    
    -- Buscar todos os grupos economico novo
    FOR rw_grupo_economico_novo IN cr_grupo_economico_novo LOOP
      vr_tab_grupo_economico_novo(lpad(rw_grupo_economico_novo.cdcooper,10,'0')||lpad(rw_grupo_economico_novo.nrdconta,10,'0')).idgrupo := rw_grupo_economico_novo.idgrupo;
    END LOOP;

    -- Buscar todos os integrantes do grupo economico
    FOR rw_integrante_grupo IN cr_integrante_grupo LOOP
      vr_ind_integrante_grupo := lpad(rw_integrante_grupo.idgrupo,10,'0')||lpad(rw_integrante_grupo.cdcooper,10,'0')||lpad(rw_integrante_grupo.nrdconta,10,'0');
      vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).idintegrante := rw_integrante_grupo.idintegrante;
      vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).tpcarga      := rw_integrante_grupo.tpcarga;
      vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).flgexcluir   := FALSE;
      -- Carga Inicial/Manutencao
      IF rw_integrante_grupo.tpcarga IN (1,2) THEN
        vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).flgexcluir := TRUE;
      END IF;
    END LOOP;
        
    vr_cdcooper_ant := -1;    
    
    -- Atualizar o grupo atual
    FOR rw_grupo_economico IN cr_grupo_economico LOOP
    
      IF vr_cdcooper_ant <> rw_grupo_economico.cdcooper THEN
        vr_idgrupo_ant  := -1;  
        vr_nrdgrupo_ant := -1;      
        vr_cdcooper_ant := rw_grupo_economico.cdcooper;
      END IF;
    
      -- Indice do Grupo Economico Novo
      vr_ind_grupo_economico_novo := lpad(rw_grupo_economico.cdcooper,10,'0')||lpad(rw_grupo_economico.nrdconta,10,'0');      
      -- Condicao para verificar se o grupo jah foi criado
      IF NOT vr_tab_grupo_economico_novo.EXISTS(vr_ind_grupo_economico_novo) OR
         --> Verificar se é o mesmo grupo do registro anterior, pois pode haver no grupo dois formadores no grupo novo,
         -- assim configurando a junção de dois grupos
         (vr_nrdgrupo_ant = rw_grupo_economico.nrdgrupo AND
          vr_tab_grupo_economico_novo(vr_ind_grupo_economico_novo).idgrupo <> vr_idgrupo_ant) THEN
        
        vr_flginteg := FALSE;
        vr_flggravo := FALSE;
        
        --> Verificar se cooperado é integrante em outro grupo   
        OPEN cr_integrante ( pr_cdcooper => rw_grupo_economico.cdcooper,
                             pr_nrdconta => rw_grupo_economico.nrdconta);
        FETCH cr_integrante INTO rw_integrante;
        vr_flginteg := cr_integrante%FOUND;
        CLOSE cr_integrante;
        
        --> caso localizou conta como alguns integrante
        IF vr_flginteg = TRUE AND 
           --> E se nao for carga manual, pois os manuais pode não estarem no grupo antigo
           rw_integrante.tpcarga <> 3 THEN
          --> Verificar se a conta formadora ainda pertence ao grupo na grp     
          OPEN cr_grupo_2(pr_idgrupo   => rw_integrante.idgrupo,
                          pr_nrdgrupo  => rw_grupo_economico.nrdgrupo,
                          pr_cdcooper  => rw_grupo_economico.cdcooper,
                          pr_nrdconta  => rw_grupo_economico.nrdconta);
          FETCH cr_grupo_2 INTO rw_grupo_2;
          --> caso o formador do grupo não faz parte do grupo na tabela crapgrp, é sinal que foi reformulado o grupo
          --> sendo necessario criar novo grupo 
          IF cr_grupo_2%NOTFOUND THEN
            vr_flginteg := FALSE;
            CLOSE cr_grupo_2;
          ELSE
            CLOSE cr_grupo_2;
          END IF;
        
        END IF;
        
        IF vr_flginteg = FALSE THEN
        
          --> Verificar se é o mesmo grupo do registro anterior
          IF vr_nrdgrupo_ant = rw_grupo_economico.nrdgrupo THEN
          
            -- Chave do Integrante do Grupo Economico
            vr_ind_integrante_dst := lpad(vr_idgrupo_ant,10,'0')||lpad(rw_grupo_economico.cdcooper,10,'0')||lpad(rw_grupo_economico.nrdconta,10,'0');
            
            -- Condicao para verificar se o integrante jah esta criado
            IF NOT vr_tab_grupo_economico_inte.EXISTS(vr_ind_integrante_dst) THEN
            
              --> buscar dados da conta     
              OPEN cr_crapass_2 (pr_cdcooper => rw_grupo_economico.cdcooper,
                                 pr_nrdconta => rw_grupo_economico.nrdconta);
              FETCH cr_crapass_2 INTO rw_crapass_2;
              CLOSE cr_crapass_2;                   
            
              --> caso for o mesmo grupo, e nao tenha localizado a conta nem como formador, e nem como integrante
              --> deve colocar como integrante no grupo atual
              BEGIN
                INSERT INTO tbcc_grupo_economico_integ
                            ( idintegrante,
                              idgrupo,
                              nrcpfcgc,
                              cdcooper,
                              nrdconta,
                              tppessoa,
                              tpcarga,
                              tpvinculo,
                              peparticipacao,
                              dtinclusao,
                              cdoperad_inclusao,
                              dtexclusao,
                              cdoperad_exclusao,
                              nmintegrante)
                    VALUES  ( NULL,                        --> idintegrante,
                              vr_idgrupo_ant,              --> idgrupo,
                              rw_crapass_2.nrcpfcgc,       --> nrcpfcgc,
                              rw_grupo_economico.cdcooper, --> cdcooper,
                              rw_grupo_economico.nrdconta, --> nrdconta,
                              rw_crapass_2.inpessoa,       --> tppessoa,
                              2,                           --> tpcarga,
                              7,                           --> tpvinculo,
                              0,                           --> peparticipacao,
                              trunc(SYSDATE),              --> dtinclusao,
                              1,                           --> cdoperad_inclusao,
                              NULL,                        --> dtexclusao,
                              NULL,                        --> cdoperad_exclusao,
                              rw_crapass_2.nmprimtl)      --> nmintegrante)
                              RETURNING tbcc_grupo_economico_integ.idintegrante INTO vr_idintegrante;

                -- Chave do Integrante do Grupo Economico
                vr_ind_integrante_grupo := lpad(vr_idgrupo_ant,10,'0')||lpad(rw_grupo_economico.cdcooper,10,'0')||lpad(rw_grupo_economico.nrdconta,10,'0');
                               
                vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).idintegrante := vr_idintegrante;
                vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).tpcarga      := 2;
                --> marcar para não excluir, pois foi adicionado o formador
                vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).flgexcluir   := FALSE;
                
              
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao incluir integrante:'||SQLERRM;
                  RAISE vr_exc_erro;
              
              END;
            END IF;
            vr_flginteg := TRUE;
            vr_flggravo := TRUE;
          
          END IF; --> IF vr_nrdgrupo_ant = rw_grupo_economico.nrdgrupo
        
        END IF;
        
      
        IF vr_flginteg = FALSE THEN
          BEGIN
            INSERT INTO tbcc_grupo_economico
                        (cdcooper
                        ,nrdconta
                        ,nmgrupo
                        ,dtinclusao)
                 VALUES (rw_grupo_economico.cdcooper
                        ,rw_grupo_economico.nrdconta
                        ,'Grupo Carga Manutencao'
                        ,TRUNC(SYSDATE))
                        RETURNING tbcc_grupo_economico.idgrupo INTO vr_idgrupo;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao gravar o grupo economico: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        
        --> caso ja tenha gravado como integrante  
        ELSIF vr_flggravo = TRUE THEN
        
          vr_idgrupo := vr_idgrupo_ant;
        
        ELSE
        
          --> definir grupo localizado como o grupo atual
          vr_idgrupo := rw_integrante.idgrupo;
          -- Chave do Integrante do Grupo Economico
          vr_ind_integrante_grupo := lpad(vr_idgrupo,10,'0')||lpad(rw_grupo_economico.cdcooper,10,'0')||lpad(rw_grupo_economico.nrdconta,10,'0');
          -- Condicao para verificar se o integrante jah esta criado
          IF vr_tab_grupo_economico_inte.EXISTS(vr_ind_integrante_grupo) THEN
            
            vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).flgexcluir := FALSE;
          
          END IF;
          
        END IF;
        
        -- Carrega na Temp-Table o Grupo criado
        vr_tab_grupo_economico_novo(vr_ind_grupo_economico_novo).idgrupo := vr_idgrupo;
      ELSE
        vr_idgrupo := vr_tab_grupo_economico_novo(vr_ind_grupo_economico_novo).idgrupo;
      END IF;

      --> armazenar grupo anterior
      vr_idgrupo_ant  := vr_idgrupo;
      vr_nrdgrupo_ant := rw_grupo_economico.nrdgrupo;
      
      -- Chave do Integrante do Grupo Economico
      vr_ind_integrante_grupo := lpad(vr_idgrupo,10,'0')||lpad(rw_grupo_economico.cdcooper,10,'0')||lpad(rw_grupo_economico.nrctasoc,10,'0');
      -- Condicao para verificar se o integrante jah esta criado
      IF vr_tab_grupo_economico_inte.EXISTS(vr_ind_integrante_grupo) THEN
        -- Somente atualizar caso o tipo de carga seja Carga Inicial/Manutencao
        IF vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).tpcarga NOT IN (1,2) THEN
          CONTINUE;          
        END IF;
        
        -- Atualizar os dados do Integrante
        BEGIN
          UPDATE tbcc_grupo_economico_integ SET
                 tbcc_grupo_economico_integ.peparticipacao = rw_grupo_economico.persocio
           WHERE idintegrante = vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).idintegrante;          
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar o integrante do grupo economico: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).flgexcluir := FALSE;
      ELSE
      
        --> Verificar se cooperado é o formador do grupo   
        OPEN cr_grupo_conta ( pr_cdcooper => rw_grupo_economico.cdcooper,
                              pr_idgrupo  => vr_idgrupo,
                              pr_nrdconta => rw_grupo_economico.nrctasoc);
        FETCH cr_grupo_conta INTO rw_grupo_conta;
        IF cr_grupo_conta%FOUND THEN
          CLOSE cr_grupo_conta;
        ELSE
          CLOSE cr_grupo_conta;
          
          --> Verificar se cooperado é integrante em outro grupo   
          OPEN cr_integrante_outro ( pr_cdcooper => rw_grupo_economico.cdcooper,
                                     pr_idgrupo  => vr_idgrupo,
                                     pr_nrdconta => rw_grupo_economico.nrctasoc);
          FETCH cr_integrante_outro INTO rw_integrante_outro;
          vr_flginteg_outro := cr_integrante_outro%FOUND;
          CLOSE cr_integrante_outro;
          
          --> Se localizou, verificar se 
          IF vr_flginteg_outro THEN
            --> Verificar se a conta formadora ainda pertence ao grupo na grp     
            OPEN cr_grupo_2(pr_idgrupo   => rw_integrante_outro.idgrupo,
                            pr_nrdgrupo  => rw_grupo_economico.nrdgrupo,
                            pr_cdcooper  => rw_grupo_economico.cdcooper,
                            pr_nrdconta  => rw_grupo_economico.nrdconta);
            FETCH cr_grupo_2 INTO rw_grupo_2;
            --> caso o formador do grupo não faz parte do grupo na tabela crapgrp, é sinal que foi reformulado o grupo
            --> sendo necessario criar 
            IF cr_grupo_2%NOTFOUND THEN
              vr_flginteg_outro := FALSE;
              CLOSE cr_grupo_2;
            ELSE
              CLOSE cr_grupo_2;
            END IF;
          
          END IF;
          
          --> caso ja exista em outro grupo e o formador deste grupo consta no grupo na crapgrp
          IF vr_flginteg_outro = TRUE THEN       
            --> INCORPORAR GRUPO
            pc_incorpora_grupo(pr_cdcooper     => rw_grupo_economico.cdcooper,
                               pr_idgrupo_ori  => vr_idgrupo,
                               pr_idgrupo_dst  => rw_integrante_outro.idgrupo,
                               pr_dscritic     => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;                   
            
            --> Atualilzar variaveis de controle
            vr_idgrupo := rw_integrante_outro.idgrupo;
            vr_idgrupo_ant := rw_integrante_outro.idgrupo;
            
          ELSIF vr_flginteg_outro = FALSE THEN            
            -- Cadastro de Integrante
            BEGIN
              INSERT INTO tbcc_grupo_economico_integ
                          (idgrupo
                          ,nrcpfcgc
                          ,cdcooper
                          ,nrdconta
                          ,tppessoa
                          ,tpcarga
                          ,tpvinculo
                          ,peparticipacao
                          ,dtinclusao
                          ,cdoperad_inclusao
                          ,nmintegrante)
                   VALUES (vr_idgrupo
                          ,rw_grupo_economico.nrcpfcgc
                          ,rw_grupo_economico.cdcooper
                          ,rw_grupo_economico.nrctasoc
                          ,rw_grupo_economico.inpessoa
                          ,2 -- Carga JOB
                          ,rw_grupo_economico.tpvinculo
                          ,rw_grupo_economico.persocio
                          ,TRUNC(SYSDATE)
                          ,1
                          ,rw_grupo_economico.nmprimtl)
                          RETURNING tbcc_grupo_economico_integ.idintegrante INTO vr_idintegrante;
		    
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao gravar o integrante do grupo economico: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
        
            vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).idintegrante := vr_idintegrante;
            vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).tpcarga      := 2;
            vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).flgexcluir   := FALSE;
          END IF;     

          
        END IF;
        --> Verificar se o cooperado adicionado pertencia a outro grupo
        FOR rw_integrante IN cr_integrante(pr_cdcooper => rw_grupo_economico.cdcooper,
                                           pr_nrdconta => rw_grupo_economico.nrctasoc) LOOP
                                           
          IF rw_integrante.idgrupo = '45795' THEN
            NULL;
          END IF;
          
          IF rw_integrante.idgrupo <> vr_idgrupo THEN
            -- Chave do Integrante do Grupo Economico
            vr_ind_integrante_outro := lpad(rw_integrante.idgrupo,10,'0')||
                                       lpad(rw_integrante.cdcooper,10,'0')||
                                       lpad(rw_integrante.nrdconta,10,'0');
            
            IF vr_tab_grupo_economico_inte.EXISTS(vr_ind_integrante_outro) THEN
              --> Marcar para excluir caso foi incluido manual em outro grupo
              IF vr_tab_grupo_economico_inte(vr_ind_integrante_outro).tpcarga = 3 THEN
                vr_tab_grupo_economico_inte(vr_ind_integrante_outro).flgexcluir   := TRUE;  
              END IF;
            END IF;
          
          END IF;                                    
        END LOOP;
        
        
      END IF;
      
      --> Listar todas as contas desse base CPF/CNPJ para verificar se ja estao no grupo para nao exclui-lo
      FOR rw_crapass IN cr_crapass(pr_cdcooper => rw_grupo_economico.cdcooper,
                                   pr_nrdconta => rw_grupo_economico.nrctasoc) LOOP
                                   
        
        -- Chave do Integrante do Grupo Economico
        vr_ind_integrante_grupo := lpad(vr_idgrupo,10,'0')||lpad(rw_grupo_economico.cdcooper,10,'0')||lpad(rw_crapass.nrdconta,10,'0');
        -- Condicao para verificar se o integrante jah esta criado
        IF vr_tab_grupo_economico_inte.EXISTS(vr_ind_integrante_grupo) THEN          
          vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).flgexcluir   := FALSE;
        END IF;
      
      END LOOP;  
      
      --> Listar todas as contas desse base CPF/CNPJ para verificar se ja estao no grupo para nao exclui-lo
      FOR rw_crapass IN cr_crapass(pr_cdcooper => rw_grupo_economico.cdcooper,
                                   pr_nrdconta => rw_grupo_economico.nrdconta) LOOP
                                   
       
        -- Chave do Integrante do Grupo Economico
        vr_ind_integrante_grupo := lpad(vr_idgrupo,10,'0')||lpad(rw_grupo_economico.cdcooper,10,'0')||lpad(rw_crapass.nrdconta,10,'0');
        -- Condicao para verificar se o integrante jah esta criado
        IF vr_tab_grupo_economico_inte.EXISTS(vr_ind_integrante_grupo) THEN          
          vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).flgexcluir   := FALSE;
        END IF;
      
      END LOOP;
      

    END LOOP; -- cr_grupo_economico

    -- Excluir todos os integrantes que nao fazem mais parte do grupo economico
    IF vr_tab_grupo_economico_inte.COUNT > 0 THEN
      vr_ind_integrante_grupo := vr_tab_grupo_economico_inte.first;
      WHILE vr_ind_integrante_grupo IS NOT NULL LOOP
        -- Condicao para verificar se deve excluir o integrante
        IF vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).flgexcluir THEN
          --> Verificar se existe o registro devido alguma conta incluida manualmente
          OPEN cr_tbintegrante_exc (pr_idintegrante => vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).idintegrante);
          FETCH cr_tbintegrante_exc INTO rw_tbintegrante_exc;
          --> caso nao tenha, deve excluir
          IF cr_tbintegrante_exc%NOTFOUND THEN
            CLOSE cr_tbintegrante_exc;
          
          
            BEGIN
              UPDATE tbcc_grupo_economico_integ SET
                     dtexclusao        = TRUNC(SYSDATE)
                    ,cdoperad_exclusao = '1'
               WHERE idintegrante = vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).idintegrante;          
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar o integrante do grupo economico: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          ELSE
            CLOSE cr_tbintegrante_exc;
          END IF;
          
        END IF;
                  
        -- buscar proximo
        vr_ind_integrante_grupo := vr_tab_grupo_economico_inte.next(vr_ind_integrante_grupo);
      END LOOP;
    END IF;
        
    COMMIT;
        
    -- Processar Cooperativas e incluir contas com o mesmo CPF ou base CNPJ
    FOR rw_crapcop IN cr_crapcop LOOP
      -- Atualizar o Grupo Economico - incluir Integrante a partir da tabela de associados (CRAPASS)
      FOR rw_grupo_associado IN cr_grupo_associado(pr_cdcooper => rw_crapcop.cdcooper) LOOP
        
        vr_achou := 0;
        begin
          select 1
            into vr_achou
            from tbcc_grupo_economico_integ gi1
           where gi1.cdcooper = rw_grupo_associado.cdcooper
             and gi1.nrdconta = rw_grupo_associado.nrdconta
             and gi1.nrcpfcgc = rw_grupo_associado.nrcpfcgc
             and gi1.tppessoa = rw_grupo_associado.tppessoa
             --Se for integrante ativo
             AND gi1.dtexclusao IS NULL
             and rownum = 1;
        exception
          when no_data_found then
            vr_achou := 0;
          when others then
            vr_dscritic := 'Erro ao obter integrante do grupo economico. '||
                           'Coop.='||rw_crapcop.cdcooper||', Grupo='||rw_grupo_associado.idgrupo||': '|| SQLERRM;
            RAISE vr_exc_saida;
        end;

        if vr_achou = 0 then
          begin
            select 1
              into vr_achou
              from tbcc_grupo_economico ge1
                  ,crapass ass
             where ge1.cdcooper = rw_grupo_associado.cdcooper
               and ge1.nrdconta = rw_grupo_associado.nrdconta
               and ass.cdcooper = ge1.cdcooper
               and ass.nrdconta = ge1.nrdconta
               --> grupo ativo
               AND EXISTS ( SELECT 1
                              FROM tbcc_grupo_economico_integ i
                             WHERE ge1.cdcooper = i.cdcooper
                               AND ge1.idgrupo  = i.idgrupo
                               AND i.dtexclusao IS NULL);
          exception
            when no_data_found then
              vr_achou := 0;
            when others then
              vr_dscritic := 'Erro ao obter grupo economico. '||
                             'Coop.='||rw_crapcop.cdcooper||', Grupo='||rw_grupo_associado.idgrupo||': '|| SQLERRM;
              RAISE vr_exc_saida;
          end;
        end if;

        IF vr_achou = 0 THEN
          --> Verificar se o integrante foi excluido hoje pelo processo automatico
          --> pois quando como o processo inclui contas que não sao da formação do grupo antifo
          --> é necessario deixar excluir para apos validar se deve manter
          OPEN cr_tbintegrante_exc2 (pr_idgrupo  => rw_grupo_associado.idgrupo ,
                                     pr_cdcooper => rw_grupo_associado.cdcooper, 
                                     pr_nrdconta => rw_grupo_associado.nrdconta);
          FETCH cr_tbintegrante_exc2 INTO rw_tbintegrante_exc2;
          IF cr_tbintegrante_exc2%NOTFOUND THEN
            CLOSE cr_tbintegrante_exc2;
          ELSE
            CLOSE cr_tbintegrante_exc2;
          
            BEGIN
              UPDATE tbcc_grupo_economico_integ itg
                 SET itg.dtexclusao = NULL,
                     itg.cdoperad_exclusao = NULL
               WHERE itg.rowid = rw_tbintegrante_exc2.rowid;      
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro atualizar integrante do grupo economico. '||
                             'Coop.='||rw_crapcop.cdcooper||', Grupo='||rw_grupo_associado.idgrupo||': '|| SQLERRM;
                RAISE vr_exc_saida;  
            END;
          
            --> Marcar para nao incluir
            vr_achou := 1;
          
          END IF;                           
        
        END IF;
        

        if vr_achou = 0 then
          begin
            -- Insere Integrante
            insert into tbcc_grupo_economico_integ
                     (IDINTEGRANTE
                     ,IDGRUPO
                     ,NRCPFCGC
                     ,CDCOOPER
                     ,NRDCONTA
                     ,TPPESSOA
                     ,TPCARGA
                     ,TPVINCULO
                     ,PEPARTICIPACAO
                     ,DTINCLUSAO
                     ,CDOPERAD_INCLUSAO
                     ,DTEXCLUSAO
                     ,CDOPERAD_EXCLUSAO
                     ,NMINTEGRANTE)
              values (null                          --IDINTEGRANTE
                     ,rw_grupo_associado.idgrupo    --IDGRUPO
                     ,rw_grupo_associado.nrcpfcgc   --NRCPFCGC
                     ,rw_grupo_associado.cdcooper   --CDCOOPER
                     ,rw_grupo_associado.nrdconta   --NRDCONTA
                     ,rw_grupo_associado.tppessoa   --TPPESSOA
                     ,2     -- Carga JOB            --TPCARGA
                     ,7                             --TPVINCULO
                     ,0                             --PEPARTICIPACAO
                     ,trunc(sysdate)                --DTINCLUSAO
                     ,1                             --CDOPERAD_INCLUSAO
                     ,null                          --DTEXCLUSAO
                     ,null                          --CDOPERAD_EXCLUSAO
                     ,rw_grupo_associado.nmprimtl   --NMINTEGRANTE)
                      );


          exception
            when others then
              vr_dscritic := 'Erro ao inserir integrante do grupo economico. '||
                             'Coop.='||rw_crapcop.cdcooper||', Grupo='||rw_grupo_associado.idgrupo||': '|| SQLERRM;
              RAISE vr_exc_saida;
          end;
        end if;
      End LOOP; -- cr_grupo_associado

      -- Excluir Grupos Formadores que não tem Integrantes
      BEGIN
        DELETE TBCC_GRUPO_ECONOMICO GE
         WHERE GE.CDCOOPER = rw_crapcop.cdcooper
           AND NOT EXISTS ( SELECT 1
                              FROM TBCC_GRUPO_ECONOMICO_INTEG GI
                             WHERE GI.CDCOOPER = GE.CDCOOPER
                               AND GI.IDGRUPO = GE.IDGRUPO);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir do grupo economico. ' || 'Coop.=' ||
                         rw_crapcop.cdcooper || ': ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    
    END LOOP;
        
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Efetuar rollback
      ROLLBACK;
      -- Retornar a Critica
      vr_cdcritic := NVL(vr_cdcritic, 0);
      IF vr_cdcritic > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      -- Efetuar rollback
      ROLLBACK;
      -- Retornar a Critica
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
  END;

END pc_crps722;
/
