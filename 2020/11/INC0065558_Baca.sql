DECLARE

  /*INC0065558 - Reprocessar os arquivos (dados) rejeitados pela CIP com a crítica "EDDA0588 – O conteúdo do CEP do cliente pagador informado deve ser numérico positivo e diferente de zero.": */

  CURSOR cr_crapcob(pr_idtitleg IN crapcob.idtitleg%type) IS
    SELECT rowid rowidcob, cdcooper, nrdconta, nrinssac
      FROM crapcob
     WHERE idtitleg = pr_idtitleg;

  CURSOR cr_crapsab(pr_cdcooper IN crapcob.cdcooper%type,
                    pr_nrdconta IN crapcob.nrdconta%type,
                    pr_nrinssac IN crapcob.nrinssac%type) IS
    SELECT nrcepsac
      FROM crapsab
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrinssac = pr_nrinssac;

  rw_crapcob cr_crapcob%ROWTYPE;
  rw_crapsab cr_crapsab%ROWTYPE;

  --Variaveis Erro
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(100);
  --
  vr_idopelegnovo crapcob.idopeleg%type;

BEGIN
  /*Seleciona os títulos que necessitam ser reprocessados */
  FOR rw_npc_reproc IN (SELECT trn.*
                          FROM tbcobran_remessa_npc trn
                         WHERE (trn.idtitleg, trn.idopeleg) IN
                               (SELECT idtitleg, idopeleg
                                  FROM crapcob
                                 WHERE incobran = 0
                                   AND dtvencto >=
                                       TO_DATE(SYSDATE, 'DD/MM/YYYY')
                                   AND idtitleg IN (23771897,
                                                    31353806,
                                                    42590884,
                                                    32816286,
                                                    42590883,
                                                    42590888,
                                                    42590869,
                                                    42590890,
                                                    35357218,
                                                    42590882,
                                                    42590885,
                                                    42590886,
                                                    42590887,
                                                    42590870,
                                                    42590893,
                                                    42590894,
                                                    43020382,
                                                    43020383,
                                                    43020385,
                                                    43020386,
                                                    43020387,
                                                    43020388,
                                                    43020389,
                                                    43020390,
                                                    43020391,
                                                    43020384,
                                                    43020297,
                                                    43020298,
                                                    43125583,
                                                    23507325,
                                                    26920963,
                                                    28362698,
                                                    33028334,
                                                    33338433,
                                                    34940440,
                                                    34991143,
                                                    35285803,
                                                    35984861,
                                                    35519131,
                                                    43715283,
                                                    37380245,
                                                    24787316,
                                                    31228475))) LOOP
    /* Gera um novo idopeleg e cria o registro na tabela responsável pelo processamentos*/                      
    --
    vr_idopelegnovo := seqcob_idopeleg.NEXTVAL;
    --

    BEGIN
      --
      OPEN cr_crapcob(rw_npc_reproc.idtitleg);
      FETCH cr_crapcob INTO rw_crapcob;
      CLOSE cr_crapcob;
      --
      OPEN cr_crapsab(rw_crapcob.cdcooper,
                      rw_crapcob.nrdconta,
                      rw_crapcob.nrinssac);
      FETCH cr_crapsab INTO rw_crapsab;
      CLOSE cr_crapsab;
      --
    
      INSERT INTO CECRED.TBCOBRAN_REMESSA_NPC
        (CDLEGADO, --> Código LEG
         IDTITLEG, --> Id titulo LEG
         IDOPELEG, --> Id operação LEG
         NRISPBAD, --> ISPB administrado
         NRISPBPR, --> ISPB principal
         TPOPERAD, --> Tipo operação
         DHOPERAD, --> Horário operação
         TPPESORI, --> Beneficiário original tipo pessoa
         NRDOCORI, --> Beneficiário original CNPJ CPF
         NMDOCORI, --> Beneficiário original razão social
         NMFANORI, --> Beneficiário original nome fantasia
         --NMLOGORI,    --> Beneficiário original logradouro
         --NMCIDORI,    --> Beneficiário original cidade
         --NMUFORIG,    --> Beneficiário original UF
         --NRCEPORI,    --> Beneficiário original CEP
         TPPESFIN, --> Beneficiário final tipo pessao
         NRDOCFIN, --> Beneficiário final CNPJ CPF
         NMDOCFIN, --> Beneficiário final razão socail
         NMFANFIN, --> Beneficiário final nome fantasia
         TPPESPAG, --> Pagador tipo pessoa
         NRDOCPAG, --> Pagador CNPG CPF
         NMDOCPAG, --> Pagador razão social
         NMFANPAG, --> Pagador nome fantasia
         NMLOGPAG, --> Pagador logradouro
         NMCIDPAG, --> Pagador cidade
         NMUFPAGA, --> Pagador UF
         NRCEPPAG, --> Pagador CEP
         TPIDESAC, --> Sacador avalista tipo identificador 
         NRIDESAC, --> Sacador avalista identificação
         NMDOCSAC, --> Sacador avalista razão social
         CDCARTEI, --> Código carteira
         CODMOEDA, --> Código moeda
         NRNOSNUM, --> Nosso número
         CDCODBAR, --> Código de barras
         NRLINDIG, --> Número linha digitável
         DTVENCTO, --> Data vencimento
         VLVALOR, --> Valor
         NRNUMDOC, --> Número documento
         CDESPECI, --> Código espécie
         DTEMISSA, --> Data emissão
         QTDIAPRO, --> Qtde dias protesto 
         DTLIMPGTO, --> Data limite pagamento
         TPPGTO, --> Tipo pagamento
         --NUMPARCL,    --> Número parcela(s)
         --QTTOTPAR,    --> Qtde total parcela(s)
         IDTIPNEG, --> Tipo negociação
         IDBLOQPAG, --> Bloqueio pagamento
         IDPAGPARC, --> Pagamento parcial
         --QTPAGPAR,    --> Qtde pagamento parcial
         VLABATIM, --> Valor abatimento
         DTJUROS, --> Data juros
         CODJUROS, --> Código juros
         VLPERJUR, --> Valor percentual juros
         DTMULTA, --> Data multa       
         CODMULTA, --> Código multa
         VLPERMUL, --> Valor percentual multa
         DTDESCO1, --> Data desconto 1
         CDDESCO1, --> Código desconto 1
         VLPERDE1, --> Valor precentual desconto 1
         --DTDESCO2,    --> Data desconto 2
         --CDDESCO2,    --> Código desconto 2
         --VLPERDE2,    --> Valor percentual desconto 2
         --DTDESCO3,    --> Data desconto 3
         --CDDESCO3,    --> Código desconto 3
         --VLPERDE3,    --> Valor desconto 3
         NRNOTFIS, --> Nota fiscal
         TPPEMITT, --> Tipo valor percent. mínimo titular
         VLPEMITT, --> Valor percent. mínimo titular
         TPPEMATT, --> Tipo valor percent. máximo titular
         VLPEMATT, --> Valor percent. máximo titular
         TPMODCAL, --> Tipo modelo cálculo
         TPRECVLD, --> TPAUTRECEBTVLRDIVEGTE
         IDNRCALC, --> Identificador cálculo
         --TXBENEFI,    --> Taxa info. beneficiário
         NRIDENTI, --> Número identifcador titular
         NRFACATI, --> Número fatura cadastro titular
         --NRSQCATI,    --> Número sequencial total. cadastro titular        
         TPBAIXEFT, --> Tipo baixa efetivado
         NRISPBTE, --> ISPB parte terceiro
         CDPATTER, --> Código parte terceiro
         DHBAIXEF, --> Horario processado baixa efetivada
         DTBAIXEF, --> Data processado baixa efetivada
         VLBAIXEF, --> Valor baixa efetivado
         CDCANPGT, --> CanPgto
         CDMEIOPG, --> Meio pagamento
         --NRIDEBOL,    --> Número identificado boleto
         --NRFATBEF,    --> Número fatura baixa efetivada
         CDSITUAC, --> 0 - Pendente 1 - Enviado 2 - Reenviar
         CDCOOPER, --> Codigo da cooperativa
         FLONLINE, --> Envio imediato
         DTMVTOLT --> Data de inserção
         )
      
      VALUES
        (rw_npc_reproc.CDLEGADO, --> Código LEG
         rw_npc_reproc.IDTITLEG, --> Id titulo LEG
         vr_idopelegnovo, --> Id operação LEG NEW
         rw_npc_reproc.NRISPBAD, --> ISPB administrado
         rw_npc_reproc.NRISPBPR, --> ISPB principal
         rw_npc_reproc.TPOPERAD, --> Tipo operação
         rw_npc_reproc.DHOPERAD, --> Horário operação
         rw_npc_reproc.TPPESORI, --> Beneficiário original tipo pessoa
         rw_npc_reproc.NRDOCORI, --> Beneficiário original CNPJ CPF
         rw_npc_reproc.NMDOCORI, --> Beneficiário original razão social
         rw_npc_reproc.NMFANORI, --> Beneficiário original nome fantasia
         --NMLOGORI,    --> Beneficiário original logradouro
         --NMCIDORI,    --> Beneficiário original cidade
         --NMUFORIG,    --> Beneficiário original UF
         --NRCEPORI,    --> Beneficiário original CEP
         rw_npc_reproc.TPPESFIN, --> Beneficiário final tipo pessao
         rw_npc_reproc.NRDOCFIN, --> Beneficiário final CNPJ CPF
         rw_npc_reproc.NMDOCFIN, --> Beneficiário final razão socail
         rw_npc_reproc.NMFANFIN, --> Beneficiário final nome fantasia
         rw_npc_reproc.TPPESPAG, --> Pagador tipo pessoa
         rw_npc_reproc.NRDOCPAG, --> Pagador CNPG CPF
         rw_npc_reproc.NMDOCPAG, --> Pagador razão social
         rw_npc_reproc.NMFANPAG, --> Pagador nome fantasia
         rw_npc_reproc.NMLOGPAG, --> Pagador logradouro
         rw_npc_reproc.NMCIDPAG, --> Pagador cidade
         rw_npc_reproc.NMUFPAGA, --> Pagador UF
         rw_crapsab.nrcepsac, --> Pagador CEP
         rw_npc_reproc.TPIDESAC, --> Sacador avalista tipo identificador 
         rw_npc_reproc.NRIDESAC, --> Sacador avalista identificação
         rw_npc_reproc.NMDOCSAC, --> Sacador avalista razão social
         rw_npc_reproc.CDCARTEI, --> Código carteira
         rw_npc_reproc.CODMOEDA, --> Código moeda
         rw_npc_reproc.NRNOSNUM, --> Nosso número
         rw_npc_reproc.CDCODBAR, --> Código de barras
         rw_npc_reproc.NRLINDIG, --> Número linha digitável
         rw_npc_reproc.DTVENCTO, --> Data vencimento
         rw_npc_reproc.VLVALOR, --> Valor
         rw_npc_reproc.NRNUMDOC, --> Número documento
         rw_npc_reproc.CDESPECI, --> Código espécie
         rw_npc_reproc.DTEMISSA, --> Data emissão
         rw_npc_reproc.QTDIAPRO, --> Qtde dias protesto 
         rw_npc_reproc.DTLIMPGTO, --> Data limite pagamento
         rw_npc_reproc.TPPGTO, --> Tipo pagamento
         --NUMPARCL,    --> Número parcela(s)
         --QTTOTPAR,    --> Qtde total parcela(s)
         rw_npc_reproc.IDTIPNEG, --> Tipo negociação
         rw_npc_reproc.IDBLOQPAG, --> Bloqueio pagamento
         rw_npc_reproc.IDPAGPARC, --> Pagamento parcial
         --QTPAGPAR,    --> Qtde pagamento parcial
         rw_npc_reproc.VLABATIM, --> Valor abatimento
         rw_npc_reproc.DTJUROS, --> Data juros
         rw_npc_reproc.CODJUROS, --> Código juros
         rw_npc_reproc.VLPERJUR, --> Valor percentual juros
         rw_npc_reproc.DTMULTA, --> Data multa       
         rw_npc_reproc.CODMULTA, --> Código multa
         rw_npc_reproc.VLPERMUL, --> Valor percentual multa
         rw_npc_reproc.DTDESCO1, --> Data desconto 1
         rw_npc_reproc.CDDESCO1, --> Código desconto 1
         rw_npc_reproc.VLPERDE1, --> Valor precentual desconto 1
         --DTDESCO2,    --> Data desconto 2
         --CDDESCO2,    --> Código desconto 2
         --VLPERDE2,    --> Valor percentual desconto 2
         --DTDESCO3,    --> Data desconto 3
         --CDDESCO3,    --> Código desconto 3
         --VLPERDE3,    --> Valor desconto 3
         rw_npc_reproc.NRNOTFIS, --> Nota fiscal
         rw_npc_reproc.TPPEMITT, --> Tipo valor percent. mínimo titular
         rw_npc_reproc.VLPEMITT, --> Valor percent. mínimo titular
         rw_npc_reproc.TPPEMATT, --> Tipo valor percent. máximo titular
         rw_npc_reproc.VLPEMATT, --> Valor percent. máximo titular
         rw_npc_reproc.TPMODCAL, --> Tipo modelo cálculo
         rw_npc_reproc.TPRECVLD, --> TPAUTRECEBTVLRDIVEGTE
         rw_npc_reproc.IDNRCALC, --> Identificador cálculo
         --TXBENEFI,    --> Taxa info. beneficiário
         rw_npc_reproc.NRIDENTI, --> Número identifcador titular
         rw_npc_reproc.NRFACATI, --> Número fatura cadastro titular
         --NRSQCATI,    --> Número sequencial total. cadastro titular        
         rw_npc_reproc.TPBAIXEFT, --> Tipo baixa efetivado
         rw_npc_reproc.NRISPBTE, --> ISPB parte terceiro
         rw_npc_reproc.CDPATTER, --> Código parte terceiro
         rw_npc_reproc.DHBAIXEF, --> Horario processado baixa efetivada
         rw_npc_reproc.DTBAIXEF, --> Data processado baixa efetivada
         rw_npc_reproc.VLBAIXEF, --> Valor baixa efetivado
         rw_npc_reproc.CDCANPGT, --> CanPgto
         rw_npc_reproc.CDMEIOPG, --> Meio pagamento
         --NRIDEBOL,    --> Número identificado boleto
         --NRFATBEF,    --> Número fatura baixa efetivada
         0, --> 0 - Pendente 1 - Enviado 2 - Reenviar
         rw_npc_reproc.CDCOOPER, --> Codigo da cooperativa
         rw_npc_reproc.FLONLINE, --> Envio imediato
         rw_npc_reproc.DTMVTOLT --> Data de inserção
         );
    
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
      
        --> Gerar log para facilitar identificação de erros SD#769996
        BEGIN
          NPCB0001.pc_gera_log_npc(pr_cdcooper => rw_npc_reproc.cdcooper,
                                   pr_nmrotina => 'Baca - Insere TBCOBRAN_REMESSA_NPC',
                                   pr_dsdolog => 'IdTitleg:' ||
                                                 rw_npc_reproc.idtitleg || '-' ||
                                                 vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        --        
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob,
                                      pr_cdoperad => '1',
                                      pr_dtmvtolt => SYSDATE,
                                      pr_dsmensag => 'BACA - Erro ao integrar instrução na cabine JDNPC (OPTIT)',
                                      pr_des_erro => vr_des_erro,
                                      pr_dscritic => vr_dscritic);
    END;
  END LOOP;
  --
  COMMIT;
END;
