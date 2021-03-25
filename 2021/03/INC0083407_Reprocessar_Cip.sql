DECLARE
  
  /*INC0083407 - Reprocessar os titulos com problemas na CIP */
  
  CURSOR cr_crapcob (pr_idtitleg IN crapcob.idtitleg%type) IS
    SELECT  cob.rowid rowidcob
      FROM crapcob cob
     WHERE cob.idtitleg = pr_idtitleg;
  rw_crapcob cr_crapcob%ROWTYPE;   
  
  CURSOR cr_crapdne(pr_nrceplog IN crapdne.nrceplog%TYPE) IS
    SELECT dne.cduflogr
      FROM crapdne dne
     WHERE
        dne.nrceplog = pr_nrceplog AND
        rownum = 1
     ORDER BY
      dne.progress_recid ASC;

  rw_crapdne cr_crapdne%ROWTYPE;  

  --Variaveis Erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(100);
  vr_nmufpaga VARCHAR2(02);
  --
  vr_idopelegnovo crapcob.idopeleg%type;
  
BEGIN
  /*Seleciona os t�tulos que necessitam ser reprocessados */ 
  FOR rw_npc_reproc IN (
    SELECT trn.*
    FROM tbcobran_remessa_npc trn
    WHERE (trn.idtitleg, trn.idopeleg) IN
     (SELECT cob.idtitleg
            ,cob.idopeleg
        FROM crapcob cob
       WHERE cob.incobran = 0 -- aberto
         AND cob.inenvcip = 2 -- enviado
         AND cob.dtvencto >= TO_DATE(SYSDATE, 'DD/MM/YYYY')
         AND (cob.idtitleg, cob.idopeleg) IN
            ((50014761, 90293421)
            ,(50314024, 90757427)         
             )  )  )   LOOP
    /* Gera um novo idopeleg e cria o registro na tabela respons�vel pelo processamentos*/                      
    --
    OPEN cr_crapcob(rw_npc_reproc.idtitleg);
    FETCH cr_crapcob INTO rw_crapcob;
    CLOSE cr_crapcob;
    --
    vr_idopelegnovo := seqcob_idopeleg.NEXTVAL;
    --    
  	IF TRIM(rw_npc_reproc.nmufpaga) IS NULL THEN
      --Se n�o tiver UF informada, busca baseado no CEP informado     
      OPEN cr_crapdne(pr_nrceplog => rw_npc_reproc.nrceppag);
      FETCH cr_crapdne INTO rw_crapdne;
      -- 
      IF cr_crapdne%NOTFOUND THEN        
        CLOSE cr_crapdne;
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                     ,pr_cdoperad => '1'
                                     ,pr_dtmvtolt => SYSDATE
                                     ,pr_dsmensag => 'BACA - Cadastro pagador com problemas no UF/CEP'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
        
        CONTINUE;
      ELSE
        CLOSE cr_crapdne;
        vr_nmufpaga:= rw_crapdne.cduflogr;
      END IF;     
    ELSE
      vr_nmufpaga:= rw_npc_reproc.nmufpaga;
    END IF;     
    --
    BEGIN
     INSERT INTO CECRED.TBCOBRAN_REMESSA_NPC
        (CDLEGADO, --> C�digo LEG
        IDTITLEG,  --> Id titulo LEG
        IDOPELEG,  --> Id opera��o LEG
        NRISPBAD,  --> ISPB administrado
        NRISPBPR,  --> ISPB principal
        TPOPERAD,  --> Tipo opera��o
        DHOPERAD,  --> Hor�rio opera��o
        TPPESORI,  --> Benefici�rio original tipo pessoa
        NRDOCORI,  --> Benefici�rio original CNPJ CPF
        NMDOCORI,  --> Benefici�rio original raz�o social
        NMFANORI,  --> Benefici�rio original nome fantasia
        --NMLOGORI,    --> Benefici�rio original logradouro
        --NMCIDORI,    --> Benefici�rio original cidade
        --NMUFORIG,    --> Benefici�rio original UF
        --NRCEPORI,    --> Benefici�rio original CEP
        TPPESFIN,      --> Benefici�rio final tipo pessao
        NRDOCFIN,      --> Benefici�rio final CNPJ CPF
        NMDOCFIN,      --> Benefici�rio final raz�o socail
        NMFANFIN,      --> Benefici�rio final nome fantasia
        TPPESPAG,      --> Pagador tipo pessoa
        NRDOCPAG,      --> Pagador CNPG CPF
        NMDOCPAG,      --> Pagador raz�o social
        NMFANPAG,      --> Pagador nome fantasia
        NMLOGPAG,      --> Pagador logradouro
        NMCIDPAG,      --> Pagador cidade
        NMUFPAGA,      --> Pagador UF
        NRCEPPAG,      --> Pagador CEP
        TPIDESAC,      --> Sacador avalista tipo identificador 
        NRIDESAC,      --> Sacador avalista identifica��o
        NMDOCSAC,      --> Sacador avalista raz�o social
        CDCARTEI,      --> C�digo carteira
        CODMOEDA,      --> C�digo moeda
        NRNOSNUM,      --> Nosso n�mero
        CDCODBAR,      --> C�digo de barras
        NRLINDIG,      --> N�mero linha digit�vel
        DTVENCTO,      --> Data vencimento
        VLVALOR,       --> Valor
        NRNUMDOC,      --> N�mero documento
        CDESPECI,      --> C�digo esp�cie
        DTEMISSA,      --> Data emiss�o
        QTDIAPRO,      --> Qtde dias protesto 
        DTLIMPGTO,     --> Data limite pagamento
        TPPGTO,        --> Tipo pagamento
        --NUMPARCL,    --> N�mero parcela(s)
        --QTTOTPAR,    --> Qtde total parcela(s)
        IDTIPNEG,      --> Tipo negocia��o
        IDBLOQPAG,     --> Bloqueio pagamento
        IDPAGPARC,     --> Pagamento parcial
        --QTPAGPAR,    --> Qtde pagamento parcial
        VLABATIM,      --> Valor abatimento
        DTJUROS,       --> Data juros
        CODJUROS,      --> C�digo juros
        VLPERJUR,      --> Valor percentual juros
        DTMULTA,       --> Data multa       
        CODMULTA,      --> C�digo multa
        VLPERMUL,      --> Valor percentual multa
        DTDESCO1,      --> Data desconto 1
        CDDESCO1,      --> C�digo desconto 1
        VLPERDE1,      --> Valor precentual desconto 1
        --DTDESCO2,    --> Data desconto 2
        --CDDESCO2,    --> C�digo desconto 2
        --VLPERDE2,    --> Valor percentual desconto 2
        --DTDESCO3,    --> Data desconto 3
        --CDDESCO3,    --> C�digo desconto 3
        --VLPERDE3,    --> Valor desconto 3
        NRNOTFIS,      --> Nota fiscal
        TPPEMITT,      --> Tipo valor percent. m�nimo titular
        VLPEMITT,      --> Valor percent. m�nimo titular
        TPPEMATT,      --> Tipo valor percent. m�ximo titular
        VLPEMATT,      --> Valor percent. m�ximo titular
        TPMODCAL,      --> Tipo modelo c�lculo
        TPRECVLD,      --> TPAUTRECEBTVLRDIVEGTE
        IDNRCALC,      --> Identificador c�lculo
        --TXBENEFI,    --> Taxa info. benefici�rio
        NRIDENTI,      --> N�mero identifcador titular
        NRFACATI,      --> N�mero fatura cadastro titular
        --NRSQCATI,    --> N�mero sequencial total. cadastro titular        
        TPBAIXEFT,     --> Tipo baixa efetivado
        NRISPBTE,      --> ISPB parte terceiro
        CDPATTER,      --> C�digo parte terceiro
        DHBAIXEF,      --> Horario processado baixa efetivada
        DTBAIXEF,      --> Data processado baixa efetivada
        VLBAIXEF,      --> Valor baixa efetivado
        CDCANPGT,      --> CanPgto
        CDMEIOPG,      --> Meio pagamento
        --NRIDEBOL,    --> N�mero identificado boleto
        --NRFATBEF,    --> N�mero fatura baixa efetivada
        CDSITUAC,      --> 0 - Pendente 1 - Enviado 2 - Reenviar
        CDCOOPER,      --> Codigo da cooperativa
        FLONLINE,      --> Envio imediato
        DTMVTOLT       --> Data de inser��o
        )
              
      VALUES
        (rw_npc_reproc.CDLEGADO, --> C�digo LEG
        rw_npc_reproc.IDTITLEG,  --> Id titulo LEG
        vr_idopelegnovo,         --> Id opera��o LEG NEW
        rw_npc_reproc.NRISPBAD,  --> ISPB administrado
        rw_npc_reproc.NRISPBPR,  --> ISPB principal
        rw_npc_reproc.TPOPERAD,  --> Tipo opera��o
        rw_npc_reproc.DHOPERAD,  --> Hor�rio opera��o
        rw_npc_reproc.TPPESORI,  --> Benefici�rio original tipo pessoa
        rw_npc_reproc.NRDOCORI,  --> Benefici�rio original CNPJ CPF
        rw_npc_reproc.NMDOCORI,  --> Benefici�rio original raz�o social
        rw_npc_reproc.NMFANORI,  --> Benefici�rio original nome fantasia
        --NMLOGORI,    --> Benefici�rio original logradouro
        --NMCIDORI,    --> Benefici�rio original cidade
        --NMUFORIG,    --> Benefici�rio original UF
        --NRCEPORI,    --> Benefici�rio original CEP
        rw_npc_reproc.TPPESFIN,      --> Benefici�rio final tipo pessao
        rw_npc_reproc.NRDOCFIN,      --> Benefici�rio final CNPJ CPF
        rw_npc_reproc.NMDOCFIN,      --> Benefici�rio final raz�o socail
        rw_npc_reproc.NMFANFIN,      --> Benefici�rio final nome fantasia
        rw_npc_reproc.TPPESPAG,      --> Pagador tipo pessoa
        rw_npc_reproc.NRDOCPAG,      --> Pagador CNPG CPF
        rw_npc_reproc.NMDOCPAG,      --> Pagador raz�o social
        rw_npc_reproc.NMFANPAG,      --> Pagador nome fantasia
        rw_npc_reproc.NMLOGPAG,      --> Pagador logradouro
        rw_npc_reproc.NMCIDPAG,      --> Pagador cidade
        vr_nmufpaga,      --> Pagador UF
        rw_npc_reproc.NRCEPPAG,      --> Pagador CEP
        rw_npc_reproc.TPIDESAC,      --> Sacador avalista tipo identificador 
        rw_npc_reproc.NRIDESAC,      --> Sacador avalista identifica��o
        rw_npc_reproc.NMDOCSAC,      --> Sacador avalista raz�o social
        rw_npc_reproc.CDCARTEI,      --> C�digo carteira
        rw_npc_reproc.CODMOEDA,      --> C�digo moeda
        rw_npc_reproc.NRNOSNUM,      --> Nosso n�mero
        rw_npc_reproc.CDCODBAR,      --> C�digo de barras
        rw_npc_reproc.NRLINDIG,      --> N�mero linha digit�vel
        rw_npc_reproc.DTVENCTO,      --> Data vencimento
        rw_npc_reproc.VLVALOR,       --> Valor
        rw_npc_reproc.NRNUMDOC,      --> N�mero documento
        rw_npc_reproc.CDESPECI,      --> C�digo esp�cie
        rw_npc_reproc.DTEMISSA,      --> Data emiss�o
        rw_npc_reproc.QTDIAPRO,      --> Qtde dias protesto 
        rw_npc_reproc.DTLIMPGTO,     --> Data limite pagamento
        rw_npc_reproc.TPPGTO,        --> Tipo pagamento
        --NUMPARCL,    --> N�mero parcela(s)
        --QTTOTPAR,    --> Qtde total parcela(s)
        rw_npc_reproc.IDTIPNEG,      --> Tipo negocia��o
        rw_npc_reproc.IDBLOQPAG,     --> Bloqueio pagamento
        rw_npc_reproc.IDPAGPARC,     --> Pagamento parcial
        --QTPAGPAR,    --> Qtde pagamento parcial
        rw_npc_reproc.VLABATIM,      --> Valor abatimento
        rw_npc_reproc.DTJUROS,       --> Data juros
        rw_npc_reproc.CODJUROS,      --> C�digo juros
        rw_npc_reproc.VLPERJUR,      --> Valor percentual juros
        rw_npc_reproc.DTMULTA,       --> Data multa       
        rw_npc_reproc.CODMULTA,      --> C�digo multa
        rw_npc_reproc.VLPERMUL,      --> Valor percentual multa
        rw_npc_reproc.DTDESCO1,      --> Data desconto 1
        rw_npc_reproc.CDDESCO1,      --> C�digo desconto 1
        rw_npc_reproc.VLPERDE1,      --> Valor precentual desconto 1
        --DTDESCO2,    --> Data desconto 2
        --CDDESCO2,    --> C�digo desconto 2
        --VLPERDE2,    --> Valor percentual desconto 2
        --DTDESCO3,    --> Data desconto 3
        --CDDESCO3,    --> C�digo desconto 3
        --VLPERDE3,    --> Valor desconto 3
        rw_npc_reproc.NRNOTFIS,      --> Nota fiscal
        rw_npc_reproc.TPPEMITT,      --> Tipo valor percent. m�nimo titular
        rw_npc_reproc.VLPEMITT,      --> Valor percent. m�nimo titular
        rw_npc_reproc.TPPEMATT,      --> Tipo valor percent. m�ximo titular
        rw_npc_reproc.VLPEMATT,      --> Valor percent. m�ximo titular
        rw_npc_reproc.TPMODCAL,      --> Tipo modelo c�lculo
        rw_npc_reproc.TPRECVLD,      --> TPAUTRECEBTVLRDIVEGTE
        rw_npc_reproc.IDNRCALC,      --> Identificador c�lculo
        --TXBENEFI,    --> Taxa info. benefici�rio
        rw_npc_reproc.NRIDENTI,      --> N�mero identifcador titular
        rw_npc_reproc.NRFACATI,      --> N�mero fatura cadastro titular
        --NRSQCATI,    --> N�mero sequencial total. cadastro titular        
        rw_npc_reproc.TPBAIXEFT,     --> Tipo baixa efetivado
        rw_npc_reproc.NRISPBTE,      --> ISPB parte terceiro
        rw_npc_reproc.CDPATTER,      --> C�digo parte terceiro
        rw_npc_reproc.DHBAIXEF,      --> Horario processado baixa efetivada
        rw_npc_reproc.DTBAIXEF,      --> Data processado baixa efetivada
        rw_npc_reproc.VLBAIXEF,      --> Valor baixa efetivado
        rw_npc_reproc.CDCANPGT,      --> CanPgto
        rw_npc_reproc.CDMEIOPG,      --> Meio pagamento
        --NRIDEBOL,    --> N�mero identificado boleto
        --NRFATBEF,    --> N�mero fatura baixa efetivada
        0,             --> 0 - Pendente 1 - Enviado 2 - Reenviar
        rw_npc_reproc.CDCOOPER,      --> Codigo da cooperativa
        rw_npc_reproc.FLONLINE,      --> Envio imediato
        trunc(sysdate)       --> Data de inser��o
        );                        
      --
      /*Atualiza crapcob com o novo idopeleg*/
      UPDATE crapcob cob
      SET cob.idopeleg = vr_idopelegnovo
      WHERE ROWID = rw_crapcob.rowidcob;
      
    EXCEPTION
      WHEN Others THEN

        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao inserir na tabela TBCOBRAN_REMESSA_NPC. ' ||
                       sqlerrm;
                       
        DBMS_OUTPUT.put_line(vr_dscritic);                       

        --> Gerar log para facilitar identifica��o de erros SD#769996
        BEGIN
          NPCB0001.pc_gera_log_npc( pr_cdcooper => rw_npc_reproc.cdcooper,
                                    pr_nmrotina => 'Baca - Insere TBCOBRAN_REMESSA_NPC',
                                    pr_dsdolog  => 'IdTitleg:'||rw_npc_reproc.idtitleg||'-'||vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END; 
        --        
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                     ,pr_cdoperad => '1'
                                     ,pr_dtmvtolt => SYSDATE
                                     ,pr_dsmensag => 'BACA - Erro ao integrar instru��o na cabine JDNPC (OPTIT)'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
    END;
  END LOOP;
  
  --
  COMMIT;
  --
  /*Seleciona os t�tulos que necessitam atualizar somente a situa��o de atualiza��o no legado, pois ja est�o registrados na CIP */ 
  FOR rw_crapcob IN (
                  SELECT cob.rowid
                  ,cob.*
                  FROM crapcob cob
                  WHERE 1=1
                  AND cob.incobran = 0 -- aberto
                  AND cob.inenvcip = 2 -- enviado
                  AND cob.dtvencto >= TO_DATE(SYSDATE, 'DD/MM/YYYY')
                  AND (cob.idtitleg, cob.idopeleg) IN
                  ((50047735, 90333181)
                  ,(50047736, 90333182)
                  ,(50047737, 90333183)
                  ,(50047738, 90333184)
                  ,(50047739, 90333185)
                  ,(50047784, 90333231)
                  ,(50047785, 90333232)
                  ,(50047786, 90333233)
                  ,(50047787, 90333234)
                  ,(50047789, 90333236)
             )  )     LOOP
    --
    BEGIN
      /*Atualiza crapcob com o novo idopeleg*/
      UPDATE crapcob cob
      SET cob.inenvcip = 3
      WHERE ROWID = rw_crapcob.rowid;

    EXCEPTION
      WHEN Others THEN

        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar na tabela CRAPCOB. ' ||
                       sqlerrm;
                       
        DBMS_OUTPUT.put_line(vr_dscritic);                       

        --> Gerar log para facilitar identifica��o de erros SD#769996
        BEGIN
          NPCB0001.pc_gera_log_npc( pr_cdcooper => rw_crapcob.cdcooper,
                                    pr_nmrotina => 'Baca - Update CRAPCOB',
                                    pr_dsdolog  => 'IdTitleg:'||rw_crapcob.idtitleg||'-'||vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END; 
        --        
    END;
  END LOOP;
    
  COMMIT;
  
END;
