DECLARE
  
  /*INC0136469 - Reprocessar os titulos com problemas na baixa efetiva */
  
  CURSOR cr_crapcob (pr_idtitleg IN crapcob.idtitleg%type) IS
    SELECT  cob.rowid rowidcob
      FROM crapcob cob
     WHERE cob.idtitleg = pr_idtitleg;
  rw_crapcob cr_crapcob%ROWTYPE;   

  --Variaveis Erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(100);
  --
  vr_idopelegnovo crapcob.idopeleg%type;
  
BEGIN
  /*Seleciona os títulos que necessitam ser reprocessados */ 
  FOR rw_npc_reproc IN (
 SELECT trn.*
    FROM tbcobran_remessa_npc trn
    WHERE (trn.idtitleg, trn.idopeleg) IN
     ((46220130, 134518994),
(61448886,  134485874),
(61448895,  134485882),
(62149183,  134487820),
(62149186,  134485878),
(62149198,  134487821),
(62149199,  134485879),
(72394169,  134054856),
(73358512,  134054857),
(74012543,  134086591),
(74012545,  134086592),
(74012546,  134086590),
(56095305,  134518995),
(61796193,  134518989),
(61796194,  134518990),
(61796195,  134485872),
(61796196,  134485873),
(66780006,  134518996),
(66780044,  134518999),
(66780121,  134519000),
(66780143,  134519001),
(66780176,  134485880),
(66780229,  134516820),
(66780250,  134485883),
(66780272,  134516821),
(66780295,  134516822),
(66780332,  134518991),
(66780335,  134516823),
(66780349,  134518992),
(66780350,  134516824),
(66780365,  134518993),
(66780367,  134516825),
(66780422,  134485875),
(66780444,  134485876),
(66780459,  134485881),
(66780478,  134516826),
(66780515,  134516827),
(70412121,  134487815),
(71711438,  133729670),
(71711460,  133727960),
(71711461,  133727959),
(71965656,  133745803),
(71969334,  133911769),
(72299453,  134054855),
(72497416,  133745804),
(72497417,  133729669),
(73843234,  133730019),
(59553065,  134487819),
(59553068,  134485877),
(64434005,  134518997),
(66157279,  134516819),
(66901573,  134022955),
(70770745,  134487816),
(70770747,  134487817),
(72278741,  134022956),
(74232388,  134516816),
(60040734,  134487818),
(63771644,  133872263),
(63771645,  133890397),
(64877323,  134359982),
(64877324,  134372816),
(65682579,  134518998),
(66524296,  134241724),
(70845980,  134054854),
(71986302,  133727961),
(72256837,  134347170),
(73575696,  134068769),
(73905588,  133901140),
(74084172,  134347168),
(74084173,  134347169),
(74084214,  134241721))                  )   LOOP
    /* Gera um novo idopeleg e cria o registro na tabela responsavel pelo processamentos*/                      
    --
    vr_idopelegnovo := seqcob_idopeleg.NEXTVAL;
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
        rw_npc_reproc.NMUFPAGA,      --> Pagador UF
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
        TRUNC(SYSDATE)       --> Data de inser��o
        );                        

      --
      OPEN cr_crapcob(rw_npc_reproc.idtitleg);
      FETCH cr_crapcob INTO rw_crapcob;
      CLOSE cr_crapcob;
      --
      /*Atualiza crapcob com o novo idopeleg*/
      UPDATE crapcob cob
      SET cob.idopeleg = vr_idopelegnovo
      WHERE ROWID = rw_crapcob.rowidcob;
      DBMS_OUTPUT.put_line('Sucesso - '||rw_npc_reproc.idtitleg||'  / '||vr_idopelegnovo);
      
    EXCEPTION
      WHEN Others THEN

        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao inserir na tabela TBCOBRAN_REMESSA_NPC. ' ||
                       sqlerrm;
                       
        DBMS_OUTPUT.put_line(vr_dscritic);                       

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
                                     ,pr_dsmensag => 'BACA - Erro ao integrar instrucao na cabine JDNPC (OPTIT)'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
    END;
  END LOOP;
  
  --
  COMMIT;
  
END;
