PL/SQL Developer Test script 3.0
312

DECLARE
    ------------------------- PL TABLE ---------------------------------------
    -- Estrutura para PL Table de CRAPRIS
    TYPE typ_reg_crapris IS
      RECORD(nrdconta crapris.nrdconta%TYPE
            ,dtrefere crapris.dtrefere%TYPE
            ,innivris crapris.innivris%TYPE
            ,qtdiaatr crapris.qtdiaatr%TYPE
            ,vldivida crapris.vldivida%TYPE
            ,vlvec180 crapris.vlvec180%TYPE
            ,vlvec360 crapris.vlvec360%TYPE
            ,vlvec999 crapris.vlvec999%TYPE
            ,vldiv060 crapris.vldiv060%TYPE
            ,vldiv180 crapris.vldiv180%TYPE
            ,vldiv360 crapris.vldiv360%TYPE
            ,vldiv999 crapris.vldiv999%TYPE
            ,vlprjano crapris.vlprjano%TYPE
            ,vlprjaan crapris.vlprjaan%TYPE
            ,inpessoa crapris.inpessoa%TYPE
            ,nrcpfcgc crapris.nrcpfcgc%TYPE
            ,vlprjant crapris.vlprjant%TYPE
            ,inddocto crapris.inddocto%TYPE
            ,cdmodali crapris.cdmodali%TYPE
            ,nrctremp crapris.nrctremp%TYPE
            ,nrseqctr crapris.nrseqctr%TYPE
            ,dtinictr crapris.dtinictr%TYPE
            ,cdorigem crapris.cdorigem%TYPE
            ,cdagenci crapris.cdagenci%TYPE
            ,innivori crapris.innivori%TYPE
            ,cdcooper crapris.cdcooper%TYPE
            ,vlprjm60 crapris.vlprjm60%TYPE
            ,dtdrisco crapris.dtdrisco%TYPE
            ,qtdriclq crapris.qtdriclq%TYPE
            ,nrdgrupo crapris.nrdgrupo%TYPE
            ,vljura60 crapris.vljura60%TYPE
            ,inindris crapris.inindris%TYPE
            ,cdinfadi crapris.cdinfadi%TYPE
            ,nrctrnov crapris.nrctrnov%TYPE
            ,flgindiv crapris.flgindiv%TYPE
            ,dtprxpar crapris.dtprxpar%TYPE
            ,vlprxpar crapris.vlprxpar%TYPE
            ,qtparcel crapris.qtparcel%TYPE
            ,dtvencop crapris.dtvencop%TYPE
            ,dsinfaux crapris.dsinfaux%TYPE);
    TYPE typ_tab_crapris    IS TABLE OF typ_reg_crapris INDEX BY VARCHAR2(31);
    TYPE typ_tab_crapris_n  IS TABLE OF typ_reg_crapris INDEX BY PLS_INTEGER;

    -- Estrutura da PL Table CRAPEPR
    TYPE typ_reg_crapepr IS
      RECORD(qtmesdec crapepr.qtmesdec%TYPE
            ,qtpreemp crapepr.qtpreemp%TYPE
            ,inliquid crapepr.inliquid%TYPE);
    TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY VARCHAR2(100);

    -- Estrutura de PL Table CRAWEPR
    TYPE typ_tab_crawepr IS TABLE OF crawepr.nrctremp%TYPE INDEX BY VARCHAR2(100);

    /* Estrutra de PL Table para tabela CRAPTCO */
    TYPE typ_tab_craptco
      IS TABLE OF crapass.nrdconta%TYPE
        INDEX BY VARCHAR2(100);
    vr_tab_craptco typ_tab_craptco;

    /* Estrutura de PLTable para armazenar os Rowids de CRAPRIS para atualiza��o */
    TYPE typ_tab_rowid
      IS TABLE OF ROWID
        INDEX BY PLS_INTEGER;
    vr_tab_rowid typ_tab_rowid;

    -- Estrutura da PL Table CRAPEBN
    TYPE typ_reg_crapebn IS
      RECORD(dtliquid crapebn.dtliquid%TYPE
            ,tpliquid crapebn.tpliquid%TYPE
            ,dtvctpro crapebn.dtvctpro%TYPE);
    TYPE typ_tab_crapebn IS TABLE OF typ_reg_crapebn INDEX BY VARCHAR2(100);


    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- C�digo do programa
    vr_cdprogra       CONSTANT crapprg.cdprogra%TYPE := 'CRPS660'; --> Nome do programa
    vr_nrctrnov       crawepr.nrctremp%TYPE;                       --> N�mero do contrato
    vr_contareg       PLS_INTEGER;                                 --> N�mero da conta
    vr_fltemris       BOOLEAN;                                     --> Flag de risco
    vr_dtrefere       DATE;                                        --> Data de referencia
    vr_tab_craprispl  typ_tab_crapris;                             --> PL Table
    vr_tab_crawepr    typ_tab_crawepr;                             --> Declara��o de PL Table
    vr_ixcrapepr      VARCHAR2(100);                               --> �ndice para PL Table
    vr_indcrapris     VARCHAR2(31);                                --> Indice para Pl Table CRAPRISPL
    vr_tab_crapepr    typ_tab_crapepr;                             --> Declara��o de PL Table
    vr_dsparame       crapsol.dsparame%type;                       --> Par�metro de execu��o
    vr_vlindivi       NUMBER(25,2);                                --> Valor para individualizar as operacoes
    vr_cdcooper       crapcop.cdcooper%TYPE;                       --> Codigo da Cooperativa
    vr_vljuro60       crapris.vljura60%TYPE;

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;                                       --> Controle de sa�da para erros
    vr_exc_fimprg EXCEPTION;                                       --> Controle de sa�da para erros
    vr_cdcritic   PLS_INTEGER;                                     --> C�digo da cr�tica
    vr_dscritic   VARCHAR2(4000);                                  --> Descri��o da cr�tica


    /* Buscar dados das contas transferidas entre cooperativas - Utilizado para cooperativa 1 */
    CURSOR cr_craptco IS
      SELECT ct.nrctaant
            ,ct.nrdconta
      FROM craptco ct
      WHERE cdcooper   = 1
        AND cdcopant   = 2
        AND tpctatrf  <> 3
        AND cdageant IN (2,4,6,7,11);


    /* Buscar dados das contas transferidas entre cooperativas - Utilizado para cooperativa 16*/
    CURSOR cr_craptco_16 IS
      SELECT ct.nrctaant
            ,ct.nrdconta
      FROM craptco ct
      WHERE cdcooper = 16
        AND tpctatrf <> 3;

    /* Buscar dados das contas incorporadas - Concredi >> Via e Credimil >> SCR */
    CURSOR cr_craptco_inc(pr_cdcooper crapcop.cdcooper%TYPE
                         ,pr_cdcopant crapcop.cdcooper%TYPE) IS
      SELECT ct.nrctaant
            ,ct.nrdconta
      FROM craptco ct
      WHERE cdcooper = pr_cdcooper
        AND cdcopant = pr_cdcopant
        AND tpctatrf <> 3;


    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper)
         AND cop.flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Busca cnpjs/cpfs a individualizar
    CURSOR cr_crapris(pr_cdcooper IN crapris.cdcooper%TYPE      --> C�digo da cooperativa
                     ,pr_dtrefere IN crapris.dtrefere%TYPE) IS  --> Data de referencia
      SELECT ci.rowid
            ,ci.cdcooper
            ,ci.vldivida
            ,ci.vljura60
            ,ci.vlsld59d
            ,decode(ci.inpessoa,2,SUBSTR(lpad(ci.nrcpfcgc,14,'0'), 1, 8),ci.nrcpfcgc) nrcpfcgc
            ,ci.nrdconta
            ,ci.nrctremp
            ,ci.cdorigem
            ,ci.innivris
            ,ci.inddocto
            ,ci.cdmodali
            ,ci.cdinfadi
            ,ROW_NUMBER () OVER (PARTITION BY decode(ci.inpessoa,2,SUBSTR(lpad(ci.nrcpfcgc,14,'0'), 1, 8),ci.nrcpfcgc)
                                     ORDER BY decode(ci.inpessoa,2,SUBSTR(lpad(ci.nrcpfcgc,14,'0'), 1, 8),ci.nrcpfcgc)) nrseqctr
            ,COUNT(1)      OVER (PARTITION BY decode(ci.inpessoa,2,SUBSTR(lpad(ci.nrcpfcgc,14,'0'), 1, 8),ci.nrcpfcgc)) qtdcontr
      FROM crapris ci
      WHERE ci.cdcooper = pr_cdcooper
        AND ci.dtrefere = pr_dtrefere
        AND ci.inddocto IN(1,3,4,5)
        AND ci.flgindiv = 0
      ORDER BY decode(ci.inpessoa,2,SUBSTR(lpad(ci.nrcpfcgc,14,'0'), 1, 8),ci.nrcpfcgc);
    vr_vldivida crapris.vldivida%TYPE;


    ------------------------------- PROCEDURES INTERNAS ---------------------------------
    /* Processar conta de migra��o entre cooperativas */
    FUNCTION fn_verifica_conta_migracao(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE) --> N�mero da conta
                                                                               RETURN BOOLEAN IS
    BEGIN
      -- Validamos Apenas Via, AV, SCR e Tranpocred
      IF pr_cdcooper NOT IN(1,13,16,9) THEN
        -- OK
        RETURN TRUE;
      ELSE
        IF vr_tab_craptco.exists(LPAD(pr_cdcooper,03,'0')||LPAD(pr_nrdconta,15,'0')) THEN
          RETURN FALSE;
        ELSE
          -- Tudo OK at� aqui, retornamos true
          RETURN TRUE;
        END IF;
      END IF;
    END fn_verifica_conta_migracao;


BEGIN
    vr_cdcooper := 0; -- deve ser 0, outro numero so para testes
    vr_dtrefere := to_date('31/05/2019','dd/mm/YYYY');
    
    -- Valor para individualizar as operacoes
    vr_vlindivi := TO_NUMBER(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                      ,pr_cdcooper => 0
                                                      ,pr_cdacesso => 'VLR_INDIVIDUALIZAR_3040'));

    -- Carrega as tabelas de contas transferidas da Viacredi e do AltoVale e SCRCred
    FOR rw_crapcop IN cr_crapcop(vr_cdcooper) LOOP
      IF rw_crapcop.cdcooper = 1 THEN
        -- Vindas da Acredicoop
        IF vr_dtrefere <= TO_DATE('31/12/2013', 'DD/MM/RRRR') THEN
          FOR regs IN cr_craptco LOOP
            vr_tab_craptco(lpad(rw_crapcop.cdcooper,3,'0')||LPAD(regs.nrdconta, 15, '0')) := regs.nrctaant;
          END LOOP;
        END IF;
        -- Incorpora��o da Concredi
        IF vr_dtrefere <= TO_DATE('30/11/2014', 'DD/MM/RRRR') THEN
          FOR regs IN cr_craptco_inc(rw_crapcop.cdcooper,4) LOOP
            vr_tab_craptco(lpad(rw_crapcop.cdcooper,3,'0')||LPAD(regs.nrdconta, 15, '0')) := regs.nrctaant;
          END LOOP;
        END IF;
      -- Migra��o Via >> Altovale
      ELSIF rw_crapcop.cdcooper = 16 AND vr_dtrefere <= TO_DATE('31/12/2012', 'DD/MM/RRRR') THEN
        -- Vindas da Via
        FOR regs IN cr_craptco_16 LOOP
          vr_tab_craptco(lpad(rw_crapcop.cdcooper,3,'0')||LPAD(regs.nrdconta, 15, '0')) := regs.nrctaant;
        END LOOP;
      -- Incorpora��o da Credimil >> SCR
      ELSIF rw_crapcop.cdcooper = 13 AND vr_dtrefere <= TO_DATE('30/11/2014', 'DD/MM/RRRR') THEN
        -- Vindas da Credimil
        FOR regs IN cr_craptco_inc(rw_crapcop.cdcooper,15) LOOP
          vr_tab_craptco(lpad(rw_crapcop.cdcooper,3,'0')||LPAD(regs.nrdconta, 15, '0')) := regs.nrctaant;
        END LOOP;
      -- Incorpora��o da Transulcred >> Transpocred
      ELSIF rw_crapcop.cdcooper = 9 AND vr_dtrefere <= TO_DATE('31/12/2016', 'DD/MM/RRRR') THEN
        -- Vindas da Transulcred
        FOR regs IN cr_craptco_inc(rw_crapcop.cdcooper,17) LOOP
          vr_tab_craptco(lpad(rw_crapcop.cdcooper,3,'0')||LPAD(regs.nrdconta, 15, '0')) := regs.nrctaant;
        END LOOP;
      END IF;
    END LOOP;
  
  
  FOR rw_crapcop IN cr_crapcop(vr_cdcooper) LOOP
    vr_contareg := 0;  
  
    -- Acumular d�vida por CPF
    FOR rw_crapris IN cr_crapris(rw_crapcop.cdcooper, vr_dtrefere) LOOP

      -- Verifica migra��o/incorpora��o
      IF NOT fn_verifica_conta_migracao(pr_cdcooper => rw_crapris.cdcooper
                                       ,pr_nrdconta => rw_crapris.nrdconta) THEN
        CONTINUE;
      END IF;
      -- Reinicializar valor e pltable no primeiro registro do CPF/CNPJ
      IF rw_crapris.nrseqctr = 1 THEN
        vr_vldivida := 0;
        vr_tab_rowid.delete;
      END IF;
      
      vr_contareg := vr_contareg + 1;

      -- Acumular o valor da d�vida (Somente para inddocto = 1, 4 e 5[desde que n�o tenha cdinfadi])
      IF rw_crapris.inddocto IN (1,3,4,5) AND nvl(rw_crapris.cdinfadi,' ') <> '0301'  THEN
        IF rw_crapris.cdmodali = 101 THEN -- ADP  -- Alterado para verificar pela modalidade de n�o pelo inddocto (Reginaldo/AMcom)
          vr_vldivida := vr_vldivida + rw_crapris.vlsld59d;
        ELSE
          vr_vldivida := vr_vldivida + (rw_crapris.vldivida - rw_crapris.vljura60);
        END IF;
      END IF;


      -- ***
      -- Subtrair os Juros + 60 do valor total da d�vida nos casos de empr�stimos/ financiamentos (cdorigem = 3)
      -- estejam em Preju�zo (innivris = 10)
      vr_vljuro60 := 0;
      IF rw_crapris.cdorigem = 3 AND rw_crapris.innivris = 10 THEN

        vr_vljuro60 := PREJ0001.fn_juros60_emprej(pr_cdcooper => rw_crapris.cdcooper
                                                 ,pr_nrdconta => rw_crapris.nrdconta
                                                 ,pr_nrctremp => rw_crapris.nrctremp);
        -- Se o valor da divida for maior que juros60
        IF vr_vldivida > vr_vljuro60 THEN
           vr_vldivida := vr_vldivida - vr_vljuro60;
        END IF;
      END IF;


      -- Adicionar este rowid a pltable
      vr_tab_rowid(vr_tab_rowid.count()+1) := rw_crapris.rowid;
      -- Para o ultimo registro (J� acumulou todos os contratos do CPF)
      IF rw_crapris.nrseqctr = rw_crapris.qtdcontr THEN
        -- Individualizar caso valor acumulado >= a R$ 200,00
        IF vr_vldivida >= vr_vlindivi THEN
/*          dbms_output.put_line(rw_crapris.cdcooper || ' - ' ||
                               rw_crapris.nrcpfcgc || ': R$ ' ||
                               vr_vldivida || ' - R$ ' ||
                               vr_vlindivi);*/

          FOR vr_idx IN 1..vr_tab_rowid.count LOOP
            BEGIN
              UPDATE crapris cr
                 SET cr.flgindiv = 1
              WHERE ROWID = vr_tab_rowid(vr_idx);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar CRAPRIS: ' ||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END LOOP;
        END IF;
      END IF;

    END LOOP;
    dbms_output.put_line(rw_crapcop.cdcooper || ' - QTDE: ' ||
                         vr_contareg);
    COMMIT;
    
  END LOOP; -- CRAPCOP
end;
0
0
