create or replace procedure cecred.baca_migra_rpp_approg is
  /*
    Suspensão e Criação das Poupanças Programadas para Aplicação Programada
    Apenas as contas com situações Ativas e Suspensas serão criadas como Aplicação Programada, mantendo-se a situação
    As contas da Poupança serão "setadas" como suspensa
    CIS Corporate
  
    -- Serão utilizados cursores implicitos para retorno de apenas 1 linha 
  */

BEGIN
  DECLARE
    -- Local variables here
  
    -- Constantes
    -- Rever valores
    vr_commitfreq pls_integer := 100; --commit a cada 
  
    vr_exc_erro EXCEPTION;
    vr_codproduto        PLS_INTEGER := 0; -- Código da aplicação programada default
    vr_cdcritic          pls_integer;
    vr_dscritic          VARCHAR2(100) := NULL;
    vr_tmp_agora         date;
  
    vr_nrseqdig    craplot.nrseqdig%type;
    vr_tmp_craplot cobr0011.cr_craplot%ROWTYPE;
    vr_nrseqted    crapmat.nrseqted%type; -- Recuperar a sequence da conta "poupanca"
  
    vr_total_procs   PLS_INTEGER := 0;
    vr_total_erros   PLS_INTEGER := 0;
    vr_erro_sit_lock PLS_INTEGER := 0; -- lock na tabela de lotes
    vr_erro_sit_lote PLS_INTEGER := 0; -- inclusao de lote
    vr_erro_sit_insP PLS_INTEGER := 0; -- Inclusao RPP
    vr_erro_sit_altP PLS_INTEGER := 0; -- Alteracao RPP
    vr_erro_outros   PLS_INTEGER := 0; -- Outros
  
    -- Cursores
    -- Cooperativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,dat.dtmvtolt
        FROM crapcop cop,crapdat dat
       WHERE cop.flgativo = 1
         AND cop.cdcooper = dat.cdcooper
         AND cop.cdcooper = 11                                        -- Fix me - Remover esta linha --------------------------------------------------------
       ORDER BY cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    -- Lotes
    CURSOR cr_craplot(pr_cdcooper crapcop.cdcooper%TYPE,
                      pr_cdagenci craplot.cdagenci%TYPE) IS
      Select 1
        From craplot
       where cdcooper = pr_cdcooper
         and dtmvtolt = rw_crapcop.dtmvtolt
         and cdagenci = pr_cdagenci
         and cdbccxlt = 200 -- fixo
         and nrdolote = 1537; -- fixo
    rw_craplot cr_craplot%ROWTYPE;
  
    -- Contas RPP
    CURSOR cr_craprpp(pr_cdcooper crapcop.cdcooper%TYPE) IS
      Select rowid, craprpp.*
        from craprpp
       where cdcooper = pr_cdcooper
         and cdprodut = 0 -- apenas contas não 'migradas' 
         and rownum <= 100                                        -- Fix Me - Remover esta linha --------------------------------------------------------
         and cdsitrpp in (1, 2); -- ativas e suspensas
    rw_craprpp cr_craprpp%ROWTYPE;
  
  BEGIN
    -- Recuperar código da nova aplicação programada
    apli0008.pc_buscar_apl_prog_padrao(pr_cdprodut => vr_codproduto);
  
    OPEN cr_crapcop;
    LOOP
      FETCH cr_crapcop
        INTO rw_crapcop;
      EXIT WHEN cr_crapcop%NOTFOUND;
      -- Poupança
      OPEN cr_craprpp(pr_cdcooper => rw_crapcop.cdcooper);
      LOOP
        FETCH cr_craprpp
          INTO rw_craprpp;
        EXIT WHEN cr_craprpp%NOTFOUND;
      
        BEGIN
          --RPP
          SAVEPOINT RPP_savepoint;
          -- Trata o LOTE  
          -- Leitura do lote se o mesmo estiver em lock, tenta por 10 seg. */
          FOR i IN 1 .. 100 LOOP
            BEGIN
              OPEN cr_craplot(pr_cdcooper => rw_crapcop.cdcooper,
                              pr_cdagenci => rw_craprpp.cdagenci);
              FETCH cr_craplot
                INTO rw_craplot;
              vr_dscritic := NULL;
              EXIT;
            EXCEPTION
              WHEN OTHERS THEN
                IF cr_craplot%ISOPEN THEN
                  CLOSE cr_craplot;
                END IF;
                -- setar critica caso for o ultimo
                IF i = 100 THEN
                  vr_dscritic := 'Registro de lote em uso';
                END IF;
                -- aguardar +- 0,5 seg. antes de tentar novamente
                SELECT SYSDATE INTO vr_tmp_agora FROM DUAL;
                LOOP
                  EXIT WHEN vr_tmp_agora +(1 / 100000) = SYSDATE;
                END LOOP;
              
            END;
          END LOOP;
          IF vr_dscritic = 'Registro de lote em uso' THEN
            raise vr_exc_erro;
          END IF;
          IF cr_craplot%NOTFOUND THEN
            CLOSE cr_craplot;
            -- Criar o lote
            cobr0011.pc_insere_lote(pr_cdcooper => rw_crapcop.cdcooper,
                                    pr_dtmvtolt => rw_crapcop.dtmvtolt,
                                    pr_cdagenci => rw_craprpp.cdagenci,
                                    pr_cdbccxlt => 200,
                                    pr_nrdolote => 1537,
                                    pr_cdoperad => '1',
                                    pr_nrdcaixa => 0,
                                    pr_tplotmov => 14,
                                    pr_cdhistor => 0,
                                    pr_craplot  => vr_tmp_craplot, -- OUT
                                    pr_dscritic => vr_dscritic -- OUT
                                    );
            IF vr_dscritic is not null THEN
              vr_dscritic := 'Erro pc_insere_lote'; -- Mensagem unica e conhecida para este script
              raise vr_exc_erro;
            END IF;
          ELSE
            CLOSE cr_craplot;
          END IF; -- Not found
        
          -- Cursor Implicito
          Select max(nrseqdig) + 1
            into vr_nrseqdig
            from craprpp
           where cdcooper = rw_crapcop.cdcooper
             and dtmvtolt = rw_crapcop.dtmvtolt
             and cdagenci = rw_craprpp.cdagenci
             and cdbccxlt = 200 -- fixo
             and nrdolote = 1537; -- fixo
        
          If vr_nrseqdig is null Then
            vr_nrseqdig := 1;
          End If;
          -- Atualizar Craplote
          Begin
            Update craplot
               Set qtcompln = qtcompln + 1,
                   qtinfoln = qtinfoln + 1,
                   vlcompcr = vlcompcr + rw_craprpp.vlprerpp,
                   vlinfocr = vlinfocr + rw_craprpp.vlprerpp
             Where cdcooper = rw_crapcop.cdcooper
               and dtmvtolt = rw_crapcop.dtmvtolt
               and cdagenci = rw_craprpp.cdagenci
               and cdbccxlt = 200 -- fixo
               and nrdolote = 1537 -- fixo
               and tplotmov = 14; -- fixo
          Exception
            When Others Then
              vr_dscritic := 'Erro atualizacao CRAPLOTE';
              raise vr_exc_erro;
          End;
        
          -- Recuperar próximo número RPP
          vr_nrseqted := cecred.fn_sequence(pr_nmtabela => 'CRAPMAT',
                                            pr_nmdcampo => 'NRRDCAPP',
                                            pr_dsdchave => rw_craprpp.cdcooper,
                                            pr_flgdecre => 'N');
        
          -- Efetuar Inclusao
          Begin
            Insert into craprpp
              (nrctrrpp,
               cdsitrpp,
               cdcooper,
               cdageass,
               cdagenci,
               tpemiext,
               dtcalcul,
               dtvctopp,
               cdopeori,
               cdageori,
               dtinsori,
               dtrnirpp,
               dtfimper,
               dtinirpp,
               dtdebito,
               flgctain,
               nrdolote,
               cdbccxlt,
               cdsecext,
               nrdconta,
               vlprerpp,
               dtimpcrt,
               indebito,
               nrseqdig,
               dtmvtolt,
               dtaltrpp,
               cdprodut)
            Values
              (vr_nrseqted,
               rw_craprpp.cdsitrpp,
               rw_craprpp.cdcooper,
               rw_craprpp.cdagenci,
               rw_craprpp.cdagenci,
               rw_craprpp.tpemiext,
               rw_craprpp.dtcalcul,
               rw_craprpp.dtvctopp,
               rw_craprpp.cdopeori,
               rw_craprpp.cdageori,
               rw_craprpp.dtinsori, -- Mantendo a data original da RPP nao do novo produto
               rw_craprpp.dtrnirpp,
               rw_craprpp.dtfimper,
               rw_craprpp.dtdebito,
               rw_craprpp.dtdebito,
               1,
               1537,
               200,
               rw_craprpp.cdsecext,
               rw_craprpp.nrdconta,
               rw_craprpp.vlprerpp,
               null, -- Contrato não foi impresso da Apl. Prog.
               0,
               vr_nrseqdig,
               rw_crapcop.dtmvtolt,
               rw_crapcop.dtmvtolt, -- Alteracao do Plano
               vr_codproduto -- Produto AP Default
               );
          Exception
            When Others Then
              dbms_output.put_line('Erro ' || SQLCODE || ' - ' || SQLERRM);
              vr_dscritic := 'Erro na inclusao RPP';
              raise vr_exc_erro;
          End;
          -- Atualiza RPP dizendo que foi processada
          -- Não utiliza o cursor 
          Begin
            Update craprpp
               Set cdprodut =
                   (vr_nrseqted * -1) -- Indica que foi processada com sucesso e que possui como novo número de contrato seu valor positivo
                  ,
                   cdsitrpp = 2 -- Coloca a aplicacao como suspensa
                  ,
                   dtrnirpp = null -- Impede que a poupança seja reativada automaticamente
             Where rowid = rw_craprpp.rowid;
          Exception
            When Others Then
              vr_dscritic := 'Erro na atualizacao RPP';
              raise vr_exc_erro;
          end;
          vr_total_procs := vr_total_procs + 1;
          DBMS_OUTPUT.PUT_LINE(rw_craprpp.nrdconta);
        Exception
          -- RPP
          When vr_exc_erro Then
            Case vr_dscritic
              When 'Registro de lote em uso' Then
                vr_erro_sit_lock := vr_erro_sit_lock + 1;
              When 'Erro pc_insere_lote' Then
                vr_erro_sit_lote := vr_erro_sit_lote + 1;
              When 'Erro atualizacao CRAPLOTE' Then
                vr_erro_sit_lote := vr_erro_sit_lote + 1;
              When 'Erro na inclusao RPP' Then
                vr_erro_sit_insP := vr_erro_sit_insP + 1;
              When 'Erro na atualizacao RPP' Then
                vr_erro_sit_altP := vr_erro_sit_altP + 1;
              Else
                DBMS_OUTPUT.PUT_LINE(rw_craprpp.nrdconta || ' ' ||
                                     vr_dscritic);
                vr_erro_outros := vr_erro_outros + 1;
            End Case;
            Rollback TO RPP_savepoint;
            vr_total_erros := vr_total_erros + 1;
          When Others Then
            Rollback TO RPP_savepoint;
            vr_total_erros := vr_total_erros + 1;
        END; -- RPP
        vr_dscritic := NULL;
        If Mod(vr_total_procs, vr_commitfreq) = 0 Then
          Commit;
        End If;
      END LOOP;
      Commit;
      Close cr_craprpp;
    END LOOP; -- Cooperativas
    CLOSE cr_crapcop;
  
    DBMS_OUTPUT.PUT_LINE('Fim do Processamento');
    DBMS_OUTPUT.PUT_LINE('                     Total Processados   :' ||
                         vr_total_procs);
    DBMS_OUTPUT.PUT_LINE('                     Erros Locks         :' ||
                         vr_erro_sit_lock);
    DBMS_OUTPUT.PUT_LINE('                     Erros Lotes         :' ||
                         vr_erro_sit_lote);
    DBMS_OUTPUT.PUT_LINE('                     Erros Inclusao RPP  :' ||
                         vr_erro_sit_insP);
    DBMS_OUTPUT.PUT_LINE('                     Erros Alteracao RPP :' ||
                         vr_erro_sit_altP);
    DBMS_OUTPUT.PUT_LINE('                     Erros Outros        :' ||
                         vr_erro_outros);
    DBMS_OUTPUT.PUT_LINE('                     Total Erros         :' ||
                         vr_total_erros);
  
  END;
end baca_migra_rpp_approg;
/
