CREATE OR REPLACE PROCEDURE CECRED.pc_crps635_i( pr_cdcooper    IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                                ,pr_dtrefere    IN crapdat.dtmvtolt%TYPE   --> Data referencia
                                                ,pr_vlr_arrasto IN crapris.vldivida%TYPE   --> Valor da d�vida
                                                ,pr_flgresta    IN PLS_INTEGER             --> Flag padr�o para utiliza��o de restart
                                                ,pr_stprogra    OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                                ,pr_infimsol    OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                                ,pr_cdcritic    OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                                ,pr_dscritic    OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps635_i (Fontes/crps635_i.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Adriano
       Data    : Marco/2013                      Ultima atualizacao: 30/10/2015

       Dados referentes ao programa:

       Frequencia: Diario (crps635)/Mensal (crps627).
       Objetivo  : ATUALIZAR RISCO SISBACEN DE ACORDO COM O GE

       Alteracoes: 08/05/2013 - Desprezar risco em prejuizo "inindris = 10"(Adriano).
       
                   29/04/2014 - Convers�o Progress >> Oracle PLSQL (Tiago Castro - RKAM).
                   
                   11/03/2015 - Ajuste para quando alterar nivel risco, atualizar a data de risco tb.
                                (Jorge/Gielow) - SD 231859
                                
                   06/08/2015 - Realizado corre��o para pegar apenas o primeiro registro da crapgrp,
                                baseado no crapgrp.nrctasoc, pois do jeito que esta far� a atualiza��o do risco 
                                na mesma conta (crapgrp.nrctasoc) v�rias vezes.
                                (Adriano).              
                                
                   30/10/2015 - Ajuste no cr_crapris_last pois pegava contratos em prejuizo
                                indevidamente (Tiago/Gielow #342525).

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- C�digo do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS635_i';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      

      vr_datautil   DATE;       --> Auxiliar para busca da data
      vr_dtrefere   DATE;       --> Data de refer�ncia do processo
      vr_dtdrisco   crapris.dtdrisco%TYPE; -- Data da atualiza��o do risco
      
      ------------------------------- CURSORES ---------------------------------

      
      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      --Cadastro de formacao dos grupos economicos
      CURSOR cr_crapgrp IS
        SELECT * FROM (SELECT crapgrp.nrctasoc
                             ,crapgrp.nrdconta
                             ,crapgrp.innivrge
                             ,crapgrp.nrdgrupo
                             ,row_number() OVER(PARTITION BY crapgrp.cdcooper
                                                            ,crapgrp.nrctasoc 
                                                    ORDER BY crapgrp.nrctasoc
                                                            ,crapgrp.nrdconta 
                                                            ,crapgrp.innivrge
                                                            ,crapgrp.nrdgrupo) seq
                       FROM crapgrp
                      WHERE cdcooper = pr_cdcooper
                      ORDER BY crapgrp.nrctasoc
                              ,crapgrp.nrdconta
                              ,crapgrp.innivrge
                              ,crapgrp.nrdgrupo) grupo
        WHERE grupo.seq = 1;

      -- Cadastro de informacoes de central de riscos
      CURSOR cr_crapris(pr_nrctasoc IN crapgrp.nrctasoc%TYPE) IS
        SELECT  /*+ INDEX(crapris CRAPRIS##CRAPRIS1) */
                 crapris.cdcooper
                ,crapris.dtrefere
                ,crapris.nrdconta
                ,crapris.innivris
                ,crapris.cdmodali
                ,crapris.nrctremp
                ,crapris.nrseqctr
                ,crapris.progress_recid
        FROM    crapris 
        WHERE   crapris.cdcooper = pr_cdcooper     
        AND     crapris.nrdconta = pr_nrctasoc 
        AND     crapris.dtrefere = pr_dtrefere     
        AND     crapris.inddocto = 1                
        AND     crapris.vldivida > pr_vlr_arrasto  
        AND     crapris.inindris < 10;
      
      -- cadastro do vencimento do risco
      CURSOR cr_crapvri( pr_cdcooper IN crapris.cdcooper%TYPE
                        ,pr_dtrefere IN crapris.dtrefere%TYPE
                        ,pr_nrdconta IN crapris.nrdconta%TYPE
                        ,pr_innivris IN crapris.innivris%TYPE
                        ,pr_cdmodali IN crapris.cdmodali%TYPE
                        ,pr_nrctremp IN crapris.nrctremp%TYPE
                        ,pr_nrseqctr IN crapris.nrseqctr%TYPE               
                        ) IS
        SELECT  ROWID
        FROM    crapvri 
        WHERE   crapvri.cdcooper = pr_cdcooper 
        AND     crapvri.dtrefere = pr_dtrefere 
        AND     crapvri.nrdconta = pr_nrdconta 
        AND     crapvri.innivris = pr_innivris 
        AND     crapvri.cdmodali = pr_cdmodali 
        AND     crapvri.nrctremp = pr_nrctremp 
        AND     crapvri.nrseqctr = pr_nrseqctr;
      
      -- Busca dos dados do ultimo risco Doctos 3020/3030
      CURSOR cr_crapris_last(pr_nrdconta IN crapris.nrdconta%TYPE
                            ,pr_dtrefere in crapris.dtrefere%TYPE) IS
        SELECT dtrefere
              ,innivris
              ,dtdrisco
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtrefere < vr_dtrefere
           AND dtrefere <> pr_dtrefere
           AND inddocto = 1 -- 3020 e 3030
           AND innivris < 10
         ORDER BY dtrefere DESC --> Retornar o ultimo gravado
                 ,innivris DESC --> Retornar o ultimo gravado
                 ,dtdrisco DESC; --> Retornar o ultimo gravado
      rw_crapris_last cr_crapris_last%ROWTYPE;

    
    BEGIN
          
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_cdcritic := 1;
        RAISE vr_exc_fimprg;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
    
      -- Fun��o para retornar dia �til anterior a data base
      vr_datautil  := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,                -- Cooperativa
                                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt - 1, -- Data de referencia
                                                  pr_tipo      => 'A',                        -- Se n�o for dia �til, retorna primeiro dia �til anterior
                                                  pr_feriado   => TRUE,                       -- Considerar feriados,
                                                  pr_excultdia => TRUE);                      -- Considerar 31/12
        

      -- Este tratamento esta sendo efetuado como solu��o para
      -- a situa��o do plsql n�o ter como efetuar comparativo <> NULL 
      IF to_char(vr_datautil,'MM') <> to_char(rw_crapdat.dtmvtolt,'MM') THEN  
        vr_datautil := to_date('31/12/9999','DD/MM/RRRR');
      END IF;  
      
      vr_dtrefere := rw_crapdat.dtmvtolt;
         
      FOR rw_crapgrp IN cr_crapgrp -- busca grupos economicos
      LOOP
        EXIT WHEN cr_crapgrp%NOTFOUND;
        FOR rw_crapris IN cr_crapris(rw_crapgrp.nrctasoc) -- busca controle de riscos
        LOOP
          EXIT WHEN cr_crapris%NOTFOUND;          
           --busca vencimento de riscos
          FOR rw_crapvri IN cr_crapvri( rw_crapris.cdcooper
                                       ,rw_crapris.dtrefere
                                       ,rw_crapris.nrdconta
                                       ,rw_crapris.innivris
                                       ,rw_crapris.cdmodali
                                       ,rw_crapris.nrctremp
                                       ,rw_crapris.nrseqctr
                                       )
          LOOP
            EXIT WHEN cr_crapvri%NOTFOUND;
            
            -- Busca dos dados do ultimo risco de origem 1
            OPEN cr_crapris_last(pr_nrdconta => rw_crapris.nrdconta
			                          ,pr_dtrefere => vr_datautil);
            FETCH cr_crapris_last
             INTO rw_crapris_last;
            -- Se encontrou
            IF cr_crapris_last%FOUND THEN
              -- Se a data de ref�ncia � diferente do ultimo dia do m�s anterior
              -- OU o n�vel deste registro � diferente do n�vel do risco no cursor principal
              --    e o n�vel do risco principal seja diferente de HH(10)
              -- ATENCAO: caso seja alterada esta regra, ajustar em crps310_i tb
              IF rw_crapris_last.dtrefere <> rw_crapdat.dtultdma
              OR (rw_crapris_last.innivris <> rw_crapgrp.innivrge AND rw_crapris.innivris <> 10) THEN
                -- Utilizar a data de refer�ncia do processo
                vr_dtdrisco := vr_dtrefere;
              ELSE
                -- Utilizar a data do ultimo risco
                vr_dtdrisco := rw_crapris_last.dtdrisco;
              END IF;
            ELSE
              -- Utilizar a data de refer�ncia do processo
              vr_dtdrisco := vr_dtrefere;
            END IF;
            -- Fechar o cursor
            CLOSE cr_crapris_last;
            
            
            -- atualiza controle de riscos.
            BEGIN
              UPDATE  crapris
              SET     crapris.innivris = rw_crapgrp.innivrge,
                      crapris.dtdrisco = vr_dtdrisco,
                      crapris.nrdgrupo = rw_crapgrp.nrdgrupo                      
              WHERE   cdcooper         = rw_crapris.cdcooper       
              AND     nrdconta         = rw_crapris.nrdconta      
              AND     dtrefere         = rw_crapris.dtrefere      
              AND     innivris         = rw_crapris.innivris      
              AND     progress_recid   = rw_crapris.progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                --gera critica
                vr_dscritic := 'Erro ao atualizar Arquivo para controle das informacoes da central de risco(crapris). '||
                               'Erro: '||SQLERRM;
                RAISE vr_exc_fimprg;
            END;    
            BEGIN -- atualiza vencimento dos riscos
              UPDATE crapvri
              SET     crapvri.innivris = rw_crapgrp.innivrge
              WHERE   ROWID = rw_crapvri.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                --gera critica
                vr_dscritic := 'Erro ao atualizar Vencimento do risco(crapvri). '||
                               'Erro: '||SQLERRM;
                RAISE vr_exc_fimprg;
            END;        
          END LOOP;
        END LOOP;
      END LOOP;
      --gera log de sucesso
      vr_dscritic := 'Atualizacao dos riscos efetuada com sucesso.';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
    EXCEPTION
      WHEN vr_exc_fimprg THEN        
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps635_i;
/

