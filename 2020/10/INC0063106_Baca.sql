DECLARE
  
  /*INC0063106 - Reprocessar os arquivos (dados) rejeitados pela CIP com a cr�tica "EDDA0076-A data informada � diferente da data de refer�ncia do sistema": */
  
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
  /*Seleciona os t�tulos que necessitam ser reprocessados */ 
  FOR rw_npc_reproc IN (  select trn.*
                          from tbcobran_remessa_npc trn
                          where (trn.idtitleg,trn.idopeleg) in
                          (
                          select cob.idtitleg
                                ,cob.idopeleg
                          from crapcob cob
                          where cob.incobran = 0 --0-Aberto
                            and cob.ininscip = 1 --1-pendente de processamento
                            and trunc(cob.dhinscip) = to_date('01102020','ddmmyyyy')
                            and (cob.idtitleg,cob.idopeleg) in
                          ((13236896,75218361)
                          ,(23094589,75218364)
                          ,(25528932,75218396)
                          ,(26620534,75218365)
                          ,(30998734,75218335)
                          ,(31142241,75218546)
                          ,(31646925,75218538)
                          ,(31668090,75218156)
                          ,(32257731,75218186)
                          ,(32325303,75218556)
                          ,(32406682,75218618)
                          ,(32513021,75218113)
                          ,(32606632,75218299)
                          ,(33418153,75218148)
                          ,(33441260,75218252)
                          ,(33518534,75218363)
                          ,(33775088,75218560)
                          ,(33940526,75218341)
                          ,(34341838,75218415)
                          ,(34732885,75218765)
                          ,(35466383,75218416)
                          ,(35812346,75218300)
                          ,(35833993,75218763)
                          ,(35836705,75218292)
                          ,(35955668,75218554)
                          ,(35956224,75218419)
                          ,(36484411,75218559)
                          ,(36639025,75218253)
                          ,(36650021,75218540)
                          ,(36695632,75218555)
                          ,(36861664,75218257)
                          ,(36923099,75218557)
                          ,(36971651,75218258)
                          ,(37036570,75218362)
                          ,(37056352,75218553)
                          ,(37090021,75218764)
                          ,(37217314,75218319)
                          ,(37673842,75218367)
                          ,(37755235,75218543)
                          ,(37869762,75218794)
                          ,(38090560,75218193)
                          ,(38119646,75218333)
                          ,(38199955,75218562)
                          ,(38350862,75218120)
                          ,(38473203,75218188)
                          ,(38473227,75218189)
                          ,(38483184,75218447)
                          ,(39063481,75218298)
                          ,(39239457,75218262)
                          ,(39245052,75218297)
                          ,(39288280,75218334)
                          ,(39497722,75218482)
                          ,(39583746,75218762)
                          ,(39735495,75220055)
                          ,(39747217,75218436)
                          ,(39757360,75218615)
                          ,(39813720,75218614)
                          ,(39820293,75218459)
                          ,(39832728,75218116)
                          ,(40054937,75218271)
                          ,(40184717,75218561)
                          ,(40253543,75218549)
                          ,(40301402,75218616)
                          ,(40453002,75220344)
                          ,(40641041,75220345)
                          ,(40662860,75218761)
                          ,(40670983,75218552)
                          ,(40712047,75218541)
                          ,(40750253,75218119)
                          ,(40756563,75218322)
                          ,(40859107,75218118)
                          ,(40892865,75218545)
                          ,(40895449,75218551)
                          ,(40906577,75218255)
                          ,(40959409,75218547)
                          ,(41050319,75218418)
                          ,(41065603,75218548)
                          ,(41079201,75218293)
                          ,(41081007,75218137)
                          ,(41082277,75218138)
                          ,(41185903,75218449)
                          ,(41187637,75218450)
                          ,(41256487,75218288)
                          ,(41256727,75218289)
                          ,(41258219,75218290)
                          ,(41258224,75218291)
                          ,(41279504,75218234)
                          ,(41301863,75218558)
                          ,(41307658,75218758)
                          ,(41435587,75220346)
                          ,(41435623,75220347)
                          ,(41458222,75218296)
                          ,(41498713,75218406)
                          ,(41500417,75218285)
                          ,(41504318,75218563)
                          ,(41518360,75218324)
                          ,(41564669,75218542)
                          ,(41575372,75218330)
                          ,(41591547,75218295)
                          ,(41638934,75218795)
                          ,(41678792,75218323)
                          ,(41737176,75218480)
                          ,(41738695,75218481)
                          ,(41768648,75218117)
                          ,(41768674,75218550)
                          ,(41850605,75218407)
                          ,(41854685,75218760)
                          ,(41894518,75220977)
                          ,(41914373,75218405)
                          ,(41984367,75218275)
                          ,(41988900,75219931)
                          ,(42028720,75218544)
                          ,(42054124,75218759)
                          ,(42082456,75220900)
                          ,(42360204,75219930)
                          ,(42360212,75219898)
                          ,(42360213,75219874)
                          ,(42360221,75219899))
                          )) LOOP
    /* Gera um novo idopeleg e cria o registro na tabela respons�vel pelo processamentos*/                      
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
        rw_npc_reproc.DTMVTOLT       --> Data de inser��o
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

        --> Gerar log para facilitar identifica��o de erros SD#769996
        BEGIN
          NPCB0001.pc_gera_log_npc( pr_cdcooper => rw_npc_reproc.cdcooper,
                                    pr_nmrotina => 'Baca - Insere TBCOBRAN_REMESSA_NPC',
                                    --pr_dsdolog  => 'CodBar:'||rw_npc_reproc.dscodbar||'-'||vr_dscritic);
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
  
END;
