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

     Alteracoes: 

  ............................................................................ */

  DECLARE
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_saida                  EXCEPTION;
    vr_cdcritic                   PLS_INTEGER;
    vr_dscritic                   VARCHAR2(4000);
    vr_ind_grupo_economico_novo   VARCHAR2(20);
    vr_ind_integrante_grupo       VARCHAR2(30);
    vr_idgrupo                    tbcc_grupo_economico.idgrupo%TYPE;
    vr_idintegrante               tbcc_grupo_economico_integ.idintegrante%TYPE;    
    
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
    CURSOR cr_grupo_economico_novo IS
      SELECT idgrupo
            ,cdcooper
            ,nrdconta             
        FROM tbcc_grupo_economico;

    CURSOR cr_integrante_grupo IS
      SELECT idgrupo
            ,idintegrante
            ,cdcooper
            ,nrdconta
            ,tpcarga
        FROM tbcc_grupo_economico_integ
       WHERE tbcc_grupo_economico_integ.dtexclusao IS NULL;
            
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
           AND crapgrp.dtmvtolt = crapdat.dtmvtoan;
          
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
        
    -- Atualizar o grupo atual
    FOR rw_grupo_economico IN cr_grupo_economico LOOP
      -- Indice do Grupo Economico Novo
      vr_ind_grupo_economico_novo := lpad(rw_grupo_economico.cdcooper,10,'0')||lpad(rw_grupo_economico.nrdconta,10,'0');      
      -- Condicao para verificar se o grupo jah foi criado
      IF NOT vr_tab_grupo_economico_novo.EXISTS(vr_ind_grupo_economico_novo) THEN
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
        
        -- Carrega na Temp-Table o Grupo criado
        vr_tab_grupo_economico_novo(vr_ind_grupo_economico_novo).idgrupo := vr_idgrupo;
      ELSE
        vr_idgrupo := vr_tab_grupo_economico_novo(vr_ind_grupo_economico_novo).idgrupo;
      END IF;

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

    END LOOP; -- cr_grupo_economico

    -- Excluir todos os integrantes que nao fazem mais parte do grupo economico
    IF vr_tab_grupo_economico_inte.COUNT > 0 THEN
      vr_ind_integrante_grupo := vr_tab_grupo_economico_inte.first;
      WHILE vr_ind_integrante_grupo IS NOT NULL LOOP
        -- Condicao para verificar se deve excluir o integrante
        IF vr_tab_grupo_economico_inte(vr_ind_integrante_grupo).flgexcluir THEN
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
          
        END IF;
                  
        -- buscar proximo
        vr_ind_integrante_grupo := vr_tab_grupo_economico_inte.next(vr_ind_integrante_grupo);
      END LOOP;
    END IF;
        
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
