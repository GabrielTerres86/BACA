CREATE OR REPLACE PROCEDURE CECRED.pc_crps679 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
  /* .............................................................................
  
     Programa: pc_crps679
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Reinert
     Data    : Maio/2014                     Ultima atualizacao: 11/04/2016
  
     Dados referentes ao programa:
  
     Frequencia: Diário (PROCDIA)
           
     Objetivo  : Gerar um arquivo de retorno ao cooperado com os cheques que 
                       foram compensados, devolvidos ou resgatados no período, 
                                   custodiados por arquivo.
  
     Alteracoes: 13/06/2014 - Adicionado variavel de controle de sequencia ao
                              gerar insert na crapdcc. (Rafael)
                              
                 02/07/2014 - Ajuste no cursor que busca os cheques da
                              cooperativa. (Rafael)
  
                 26/06/2015 - Ajuste para filtar os cheques que são gerados na
                              crapdcc com a conta que foi identificada na crapccc
                              (Douglas - Chamado 301650)
                              
                 11/12/2015 - Substituido campo CMC7 da clausula where das querys
                              pela chave composta do cheque com o objetivo de
                              melhorar desempenho. (Rafael)

                 11/04/2016 - Ajuste para nao gerar as informacoes de craphcc e crapdcc
                              quando nao possuir informacoes de custodia 
                              (Douglas - Chamado 397933)
  ............................................................................ */

  DECLARE
  
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS679';
  
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
  
    TYPE typ_crapdcc IS TABLE OF crapdcc%ROWTYPE INDEX BY PLS_INTEGER;
  
    rc_crapdcc typ_crapdcc;
  
    ------------------------------- CURSORES ---------------------------------
  
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop, cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    -- Cursor cheques de fora, superior a 300
    CURSOR cr_chqfora_sup300(pr_cdcooper IN crapcop.cdcooper%TYPE,
                             pr_nrdconta IN crapass.nrdconta%TYPE,
                             pr_nrconven IN craphcc.nrconven%TYPE,
                             pr_dtrefere IN crapdat.dtmvtolt%TYPE,
                             pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                             pr_vlchqmai IN NUMBER) IS
      SELECT dcc.cdfinmvt cdfinmvt,
             dcc.cdentdad cdentdad,
             cst.dsdocmc7 dsdocmc7,
             cst.cdcmpchq cdcmpchq,
             cst.cdbanchq cdbanchq,
             cst.cdagechq cdagechq,
             cst.nrctachq nrctachq,
             cst.nrcheque nrcheque,
             cst.vlcheque vlcheque,
             dcc.cdtipemi cdtipemi,
             dcc.nrinsemi nrinsemi,
             dcc.dtdcaptu dtdcaptu,
             dcc.dtlibera dtlibera,
             dcc.dsusoemp dsusoemp,
             dcc.inconcil inconcil,
             dcc.inchqcop inchqcop,
             lcm.cdpesqbb cdpesqbb,
             lcm.cdhistor cdhistor,
             count(*) over(order by cst.progress_recid) rn,
             count(*) over() as tot
        FROM crapcst cst, craplcm lcm, crapdcc dcc
       WHERE cst.cdcooper = pr_cdcooper -- Cooperativa
         AND cst.nrdconta = pr_nrdconta -- Número da Conta
         AND cst.dtlibera >= pr_dtrefere -- Data com um dia util atras
         AND cst.dtlibera < pr_dtmvtolt -- Data Atual
         AND cst.inchqcop = 0 -- Tipo de cheque recebido (0=Outros bancos, 1=Cooperativa).
         AND cst.insitchq = 2 -- Situacao do cheque: 0=nao processado, 1=resgatado, 2=processado.
         AND cst.vlcheque >= pr_vlchqmai -- Valor do cheque
         AND cst.flcstarq = 1 -- Flag de custodia de arquivo: 1 = Custodiado por arquivo
         AND dcc.cdcooper = cst.cdcooper -- Cooperativa
         AND dcc.nrdconta = cst.nrdconta -- Nr. da conta
            -- chave composta do cheque (retirado DSDOCMC7)
         AND dcc.cdcmpchq = cst.cdcmpchq
         AND dcc.cdbanchq = cst.cdbanchq
         AND dcc.cdagechq = cst.cdagechq
         AND dcc.nrctachq = cst.nrctachq
         AND dcc.nrcheque = cst.nrcheque
            -------------------------------                               
         AND dcc.dtlibera = cst.dtlibera -- Data de liberação
         AND dcc.intipmvt = 2 -- Tipo de movimento: 1 = REMESSA, 2 = RETORNO
         AND dcc.cdtipmvt = 11 -- Codigo para o tipo de movimento.
         AND dcc.nrconven = pr_nrconven
         AND lcm.cdcooper(+) = cst.cdcooper -- Cooperativa
         AND lcm.cdcmpchq(+) = cst.cdcmpchq -- Codigo da compensacao impressa no cheque acolhido.
         AND lcm.nrdocmto(+) = cst.nrcheque -- Nr. do cheque
         AND lcm.cdbanchq(+) = cst.cdbanchq -- Código do banco do cheque
         AND lcm.cdagechq(+) = cst.cdagechq -- Código da agencia do cheque
         AND lcm.nrctachq(+) = cst.nrctachq -- Nr. da conta do cheque
         AND lcm.cdhistor(+) = 351 -- Histórico de lancamento
         AND lcm.dtmvtolt(+) = pr_dtmvtolt; -- Data Atual
    rw_chqfora_sup300 cr_chqfora_sup300%ROWTYPE;
  
    -- Cursor cheques de fora, inferior a 300
    CURSOR cr_chqfora_inf300(pr_cdcooper IN crapcop.cdcooper%TYPE,
                             pr_nrdconta IN crapass.nrdconta%TYPE,
                             pr_nrconven IN craphcc.nrconven%TYPE,
                             pr_dtrefere IN crapdat.dtmvtolt%TYPE, -- 2 dias úteis atrás
                             pr_dtrefern IN crapdat.dtmvtolt%TYPE, -- 1 dia útil atrás
                             pr_dtmvtolt IN crapdat.dtmvtolt%TYPE, -- Data atual
                             pr_vlchqmai IN NUMBER) IS
      SELECT dcc.cdfinmvt cdfinmvt,
             dcc.cdentdad cdentdad,
             cst.dsdocmc7 dsdocmc7,
             cst.cdcmpchq cdcmpchq,
             cst.cdbanchq cdbanchq,
             cst.cdagechq cdagechq,
             cst.nrctachq nrctachq,
             cst.nrcheque nrcheque,
             cst.vlcheque vlcheque,
             dcc.cdtipemi cdtipemi,
             dcc.nrinsemi nrinsemi,
             dcc.dtdcaptu dtdcaptu,
             dcc.dtlibera dtlibera,
             dcc.dsusoemp dsusoemp,
             dcc.inconcil inconcil,
             dcc.inchqcop inchqcop,
             lcm.cdpesqbb cdpesqbb,
             lcm.cdhistor cdhistor,
             count(*) over(order by cst.progress_recid) rn,
             count(*) over() as tot
        FROM crapcst cst, craplcm lcm, crapdcc dcc
       WHERE cst.cdcooper = pr_cdcooper -- Cooperativa
         AND cst.nrdconta = pr_nrdconta -- Número da Conta
         AND cst.dtlibera > pr_dtrefere -- Data com dois dias uteis atras
         AND cst.dtlibera <= pr_dtrefern -- Data com um dia util atras
         AND cst.inchqcop = 0 -- Tipo de cheque recebido (0=Outros bancos, 1=Cooperativa).
         AND cst.insitchq = 2 -- Situacao do cheque: 0=nao processado, 1=resgatado, 2=processado.
         AND cst.vlcheque < pr_vlchqmai -- Valor do cheque
         AND cst.flcstarq = 1 -- Flag de custodia de arquivo: 1 = Custodiado por arquivo
            
         AND dcc.cdcooper = cst.cdcooper -- Cooperativa
         AND dcc.nrdconta = cst.nrdconta -- Nr. da conta
            -- chave composta do cheque (retirado DSDOCMC7)
         AND dcc.cdcmpchq = cst.cdcmpchq
         AND dcc.cdbanchq = cst.cdbanchq
         AND dcc.cdagechq = cst.cdagechq
         AND dcc.nrctachq = cst.nrctachq
         AND dcc.nrcheque = cst.nrcheque
            -------------------------------
         AND dcc.dtlibera = cst.dtlibera -- Data de liberação
         AND dcc.intipmvt = 2 -- Tipo de movimento: 1 = REMESSA, 2 = RETORNO
         AND dcc.cdtipmvt = 11 -- Codigo para o tipo de movimento.
         AND dcc.nrconven = pr_nrconven
         AND lcm.cdcooper(+) = cst.cdcooper -- Cooperativa
         AND lcm.cdcmpchq(+) = cst.cdcmpchq -- Codigo da compensacao impressa no cheque acolhido.
         AND lcm.nrdocmto(+) = cst.nrcheque -- Nr. do cheque
         AND lcm.cdbanchq(+) = cst.cdbanchq -- Código do banco do cheque
         AND lcm.cdagechq(+) = cst.cdagechq -- Código da agencia do cheque
         AND lcm.nrctachq(+) = cst.nrctachq -- Nr. da conta do cheque
         AND lcm.cdhistor(+) = 351 -- Histórico de lancamento
         AND lcm.dtmvtolt(+) = pr_dtmvtolt; -- Data Atual
    rw_chqfora_inf300 cr_chqfora_inf300%ROWTYPE;
  
    -- Cursor cheques da cooperativa
    CURSOR cr_cheqcoop(pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_nrconven craphcc.nrconven%TYPE,
                       pr_dtrefere crapdat.dtmvtolt%TYPE,
                       pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT dcc.cdfinmvt cdfinmvt,
             dcc.cdentdad cdentdad,
             cst.dsdocmc7 dsdocmc7,
             cst.cdcmpchq cdcmpchq,
             cst.cdbanchq cdbanchq,
             cst.cdagechq cdagechq,
             cst.nrctachq nrctachq,
             cst.nrcheque nrcheque,
             cst.vlcheque vlcheque,
             dcc.cdtipemi cdtipemi,
             dcc.nrinsemi nrinsemi,
             dcc.dtdcaptu dtdcaptu,
             dcc.dtlibera dtlibera,
             dcc.dsusoemp dsusoemp,
             dcc.inconcil inconcil,
             dcc.inchqcop inchqcop,
             lcm.cdpesqbb cdpesqbb,
             lcm.cdhistor cdhistor,
             count(*) over(order by cst.progress_recid) rn,
             count(*) over() as tot
        FROM crapcst cst, craplcm lcm, crapdcc dcc
       WHERE cst.cdcooper = pr_cdcooper -- Cooperativa
         AND cst.nrdconta = pr_nrdconta -- Número da Conta
         AND cst.dtlibera > pr_dtrefere -- 1 dia util atra
         AND cst.dtlibera <= pr_dtmvtolt -- glb_dtmvtolt
         AND cst.inchqcop = 1 -- Tipo de cheque recebido (0=Outros bancos, 1=Cooperativa).
         AND cst.insitchq = 2 -- Situacao do cheque: 0=nao processado, 1=resgatado, 2=processado.
         AND cst.flcstarq = 1 -- Flag de custodia de arquivo: 1 = Custodiado por arquivo
            
         AND dcc.cdcooper = cst.cdcooper -- Cooperativa
         AND dcc.nrdconta = cst.nrdconta -- Nr. da conta
            -- chave composta do cheque (retirado DSDOCMC7)
         AND dcc.cdcmpchq = cst.cdcmpchq
         AND dcc.cdbanchq = cst.cdbanchq
         AND dcc.cdagechq = cst.cdagechq
         AND dcc.nrctachq = cst.nrctachq
         AND dcc.nrcheque = cst.nrcheque
            -------------------------------                     
         AND dcc.dtlibera = cst.dtlibera -- Data de liberação
         AND dcc.intipmvt = 2 -- Tipo de movimento: 1 = REMESSA, 2 = RETORNO
         AND dcc.cdtipmvt = 11 -- Codigo para o tipo de movimento.
         AND dcc.nrconven = pr_nrconven
         AND lcm.cdcooper = cst.cdcooper
         AND lcm.nrdconta = cst.nrctachq
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdbanchq = cst.cdbanchq
         AND lcm.cdagechq = cst.cdagechq
         AND lcm.nrctachq = cst.nrctachq
         AND lcm.nrdocmto =
             to_number(to_char(cst.nrcheque) || to_char(cst.nrddigc3));
    rw_cheqcoop cr_cheqcoop%ROWTYPE;
  
    -- Cursor cheques devolvidos da cooperativa(085)
    CURSOR cr_cqdevolu(pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_nrconven craphcc.nrconven%TYPE,
                       pr_dtrefere crapdat.dtmvtolt%TYPE,
                       pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT dcc.cdfinmvt cdfinmvt,
             dcc.cdentdad cdentdad,
             cst.dsdocmc7 dsdocmc7,
             cst.cdcmpchq cdcmpchq,
             cst.cdbanchq cdbanchq,
             cst.cdagechq cdagechq,
             cst.nrctachq nrctachq,
             cst.nrcheque nrcheque,
             cst.vlcheque vlcheque,
             dcc.cdtipemi cdtipemi,
             dcc.nrinsemi nrinsemi,
             dcc.dtdcaptu dtdcaptu,
             dcc.dtlibera dtlibera,
             dcc.dsusoemp dsusoemp,
             dcc.inconcil inconcil,
             dcc.inchqcop inchqcop,
             lcm.cdpesqbb cdpesqbb,
             count(*) over(order by cst.progress_recid) rn,
             count(*) over() as tot
        FROM craplcm lcm, crapcst cst, crapdcc dcc, crapage age
       WHERE lcm.cdcooper = pr_cdcooper -- Cooperativa
         AND lcm.cdhistor = 47 -- Histórico 47 - Cheque devolvido
         AND lcm.dtmvtolt = pr_dtmvtolt -- Data atual
         AND age.cdcooper = lcm.cdcooper -- Cooperativa
         AND age.cdagenci = lcm.cdagenci -- PA
         AND cst.cdcooper = lcm.cdcooper -- Cooperativa
         AND cst.cdcmpchq = age.cdcomchq -- Código da compe do cheque
         AND cst.cdbanchq = lcm.cdbanchq -- Código banco do cheque
         AND cst.cdagechq = lcm.cdagechq -- Código agencia do cheque
         AND cst.nrctachq = lcm.nrdconta -- Nr. da conta
         AND cst.nrdconta = pr_nrdconta -- Número da Conta
         AND to_number(to_char(cst.nrcheque) || to_char(cst.nrddigc3)) =
             lcm.nrdocmto -- Nr. do documento
         AND cst.dtlibera > pr_dtrefere -- Um dia util atras
         AND cst.dtlibera <= pr_dtmvtolt -- Data atual
         AND cst.insitchq = 3 -- Situacao do cheque: 0=nao processado, 1=resgatado, 2=processado, 3=devolvido.
         AND cst.flcstarq = 1 -- Flag de custodia de arquivo: 1 = Custodiado por arquivo
         AND dcc.cdcooper = cst.cdcooper -- Cooperativa
         AND dcc.nrdconta = cst.nrdconta -- Nr. da conta
            -- chave composta do cheque (retirado DSDOCMC7)
         AND dcc.cdcmpchq = cst.cdcmpchq
         AND dcc.cdbanchq = cst.cdbanchq
         AND dcc.cdagechq = cst.cdagechq
         AND dcc.nrctachq = cst.nrctachq
         AND dcc.nrcheque = cst.nrcheque
            -------------------------------           
         AND dcc.dtlibera = cst.dtlibera -- Data de liberação
         AND dcc.intipmvt = 2 -- Tipo de movimento: 1 = REMESSA, 2 = RETORNO
         AND dcc.cdtipmvt = 11 -- Codigo para o tipo de movimento.
            
         AND dcc.nrconven = pr_nrconven;
    rw_cqdevolu cr_cqdevolu%ROWTYPE;
  
    /* Cursor cheques resgatados do dia */
    CURSOR cr_cqresgat(pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_nrconven craphcc.nrconven%TYPE,
                       pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT dcc.cdfinmvt cdfinmvt,
             dcc.cdentdad cdentdad,
             cst.dsdocmc7 dsdocmc7,
             cst.cdcmpchq cdcmpchq,
             cst.cdbanchq cdbanchq,
             cst.cdagechq cdagechq,
             cst.nrctachq nrctachq,
             cst.nrcheque nrcheque,
             cst.vlcheque vlcheque,
             dcc.cdtipemi cdtipemi,
             dcc.nrinsemi nrinsemi,
             dcc.dtdcaptu dtdcaptu,
             dcc.dtlibera dtlibera,
             dcc.dsusoemp dsusoemp,
             dcc.inconcil inconcil,
             dcc.inchqcop inchqcop,
             count(*) over(order by cst.progress_recid) rn,
             count(*) over() as tot
        FROM crapcst cst, crapdcc dcc
       WHERE cst.cdcooper = pr_cdcooper -- Cooperativa
         AND cst.nrdconta = pr_nrdconta -- Número da Conta
         AND cst.dtdevolu = pr_dtmvtolt -- glb_dtmvtolt
         AND cst.insitchq = 1 -- Cheque resgatado
         AND cst.flcstarq = 1 -- Flag de custodia de arquivo: 1 = Custodiado por arquivo
         AND dcc.cdcooper = cst.cdcooper -- Cooperativa
         AND dcc.nrdconta = cst.nrdconta -- Nr. da conta
            -- chave composta do cheque (retirado DSDOCMC7)
         AND dcc.cdcmpchq = cst.cdcmpchq
         AND dcc.cdbanchq = cst.cdbanchq
         AND dcc.cdagechq = cst.cdagechq
         AND dcc.nrctachq = cst.nrctachq
         AND dcc.nrcheque = cst.nrcheque
            -------------------------------
         AND dcc.dtlibera = cst.dtlibera -- Data de liberação
         AND dcc.intipmvt = 2 -- Tipo de movimento: 1 = REMESSA, 2 = RETORNO
         AND dcc.cdtipmvt = 11 -- Codigo para o tipo de movimento.
         AND dcc.nrconven = pr_nrconven;
    rw_cqresgat cr_cqresgat%ROWTYPE;
  
    -- Cursor de convenios de custodia de cheque              
    CURSOR cr_crapccc(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT ccc.cdcooper, ccc.nrdconta, ccc.nrconven
        FROM crapccc ccc
       WHERE ccc.cdcooper = pr_cdcooper -- Cooperativa
         AND ccc.idretorn = 2 -- Convenio do cooperado
         AND ccc.flghomol = 1; -- Sistema homologado
    rw_crapccc cr_crapccc%ROWTYPE;
  
    /* Buscar ultimo numero de retorno utilizado */
    CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE, --> Código da cooperativa
                      pr_nrdconta IN craphcc.nrdconta%TYPE, --> Numero da Conta
                      pr_nrconven IN craphcc.nrconven%TYPE) IS --> Numero do Convenio
      SELECT (NVL(MAX(nrremret), 0) + 1) nrremret
        FROM craphcc
       WHERE craphcc.cdcooper = pr_cdcooper
         AND craphcc.nrdconta = pr_nrdconta
         AND craphcc.nrconven = pr_nrconven
         AND craphcc.intipmvt = 2 -- Retorno 
       ORDER BY craphcc.cdcooper,
                craphcc.nrdconta,
                craphcc.nrconven,
                craphcc.intipmvt;
    rw_craphcc cr_craphcc%ROWTYPE;
  
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  
    ------------------------------- VARIAVEIS -------------------------------
  
    -- Variáveis para busca de cheque superior na tab
    vr_tab_dstextab craptab.dstextab%TYPE;
    vr_tab_vlchqmai NUMBER;
  
    -- Variáveis auxliares
    vr_nrremret craphcc.nrremret%TYPE;
    vr_nmarquiv VARCHAR2(200);
    vr_dtrefere DATE;
    vr_dtrefern DATE;
    vr_nrsequen NUMBER := 0;
    vr_cdtipmvt NUMBER;
    vr_cdalinea crapdcc.cdalinea%TYPE;
    vr_dtcredit DATE;
  
    vr_ix PLS_INTEGER := 0;
    
    -- Controle para gerar craphcc
    vr_criou_craphcc INTEGER;
  
    -- Variáveis de exception
    vr_exc_loop EXCEPTION;
  
    --------------------------- SUBROTINAS INTERNAS --------------------------
  
    PROCEDURE pc_atualiza_dcc IS
    BEGIN
      BEGIN
        FORALL vr_ix IN INDICES OF rc_crapdcc SAVE EXCEPTIONS
          INSERT INTO crapdcc
            (cdcooper,
             nrdconta,
             nrconven,
             intipmvt,
             nrremret,
             nrseqarq,
             cdtipmvt,
             cdfinmvt,
             cdentdad,
             dsdocmc7,
             cdcmpchq,
             cdbanchq,
             cdagechq,
             nrctachq,
             nrcheque,
             vlcheque,
             cdtipemi,
             nrinsemi,
             dtdcaptu,
             dtlibera,
             dtcredit,
             dsusoemp,
             cdagedev,
             nrctadev,
             cdalinea,
             cdocorre,
             inconcil,
             cdagenci,
             cdbccxlt,
             nrdolote,
             inchqcop)
          VALUES
            (rc_crapdcc(vr_ix).cdcooper,
             rc_crapdcc(vr_ix).nrdconta,
             rc_crapdcc(vr_ix).nrconven,
             rc_crapdcc(vr_ix).intipmvt,
             rc_crapdcc(vr_ix).nrremret,
             rc_crapdcc(vr_ix).nrseqarq,
             rc_crapdcc(vr_ix).cdtipmvt,
             rc_crapdcc(vr_ix).cdfinmvt,
             rc_crapdcc(vr_ix).cdentdad,
             rc_crapdcc(vr_ix).dsdocmc7,
             rc_crapdcc(vr_ix).cdcmpchq,
             rc_crapdcc(vr_ix).cdbanchq,
             rc_crapdcc(vr_ix).cdagechq,
             rc_crapdcc(vr_ix).nrctachq,
             rc_crapdcc(vr_ix).nrcheque,
             rc_crapdcc(vr_ix).vlcheque,
             rc_crapdcc(vr_ix).cdtipemi,
             rc_crapdcc(vr_ix).nrinsemi,
             rc_crapdcc(vr_ix).dtdcaptu,
             rc_crapdcc(vr_ix).dtlibera,
             rc_crapdcc(vr_ix).dtcredit,
             rc_crapdcc(vr_ix).dsusoemp,
             rc_crapdcc(vr_ix).cdagedev,
             rc_crapdcc(vr_ix).nrctadev,
             rc_crapdcc(vr_ix).cdalinea,
             rc_crapdcc(vr_ix).cdocorre,
             rc_crapdcc(vr_ix).inconcil,
             rc_crapdcc(vr_ix).cdagenci,
             rc_crapdcc(vr_ix).cdbccxlt,
             rc_crapdcc(vr_ix).nrdolote,
             rc_crapdcc(vr_ix).inchqcop);
      
        rc_crapdcc.delete;
      
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPDCC: ' || SQLERRM;
          --Levantar Excecao
          RAISE vr_exc_loop;
      END;
    END;
  
    -- Função para retornar data útil
    FUNCTION fn_busca_n_dias_uteis_atras(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                         pr_dtrefere IN crapdat.dtmvtolt%TYPE,
                                         pr_qtdddias IN INTEGER) RETURN DATE IS
      -- Declara variaveis locais
      vr_dtrefere DATE;
      vr_qtdddias INTEGER;
    BEGIN
      -- Alimenta variaveis com os parametros de entrada
      vr_dtrefere := pr_dtrefere;
      vr_qtdddias := NVL(pr_qtdddias, 0);
    
      -- Se a quantidade de dias for zero
      IF vr_qtdddias = 0 THEN
        -- Retorna data parametrizada
        RETURN(vr_dtrefere);
      END IF;
    
      -- Enquanto a quantidade de dias não chegar a zero
      LOOP
        -- Decrementa a quantidade de dias
        vr_qtdddias := vr_qtdddias - 1;
        -- Decrementa um dia útil
        vr_dtrefere := vr_dtrefere - 1;
        -- Função para retornar dia útil
        vr_dtrefere := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper, -- Cooperativa
                                                   pr_dtmvtolt  => vr_dtrefere, -- Data de referencia
                                                   pr_tipo      => 'A', -- Se não for dia útil, retorna primeiro dia útil anterior
                                                   pr_feriado   => TRUE, -- considerar feriados,
                                                   pr_excultdia => TRUE); -- considerar 31/12
      
        -- Quando a quantidade de dias chegar a zero, sair do loop                                                                                                       
        EXIT WHEN vr_qtdddias = 0;
      END LOOP;
    
      -- Retorna data com os dias úteis descontados
      RETURN(vr_dtrefere);
    END;
  
    PROCEDURE pc_criar_hcc (pr_cdcooper  IN crapccc.cdcooper%TYPE
                           ,pr_nrdconta  IN crapccc.nrdconta%TYPE
                           ,pr_nrconven  IN crapccc.nrconven%TYPE
                           ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                           ,pr_nrremret  IN craphcc.nrremret%TYPE
                           ,pr_nmarquiv  IN craphcc.nmarquiv%TYPE
                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                           ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
      
    BEGIN
      -- Inicializa as criticas
      pr_cdcritic := 0;
      pr_dscritic := '';
      
      -- Criar Lote de Informações de Retorno (craphcc) 
      BEGIN
        INSERT INTO craphcc
            (cdcooper,
             nrdconta,
             nrconven,
             intipmvt,
             nrremret,
             dtmvtolt,
             nmarquiv,
             idorigem,
             dtdgerac,
             hrdgerac,
             insithcc)
          VALUES
            (pr_cdcooper,
             pr_nrdconta,
             pr_nrconven,
             2, -- Retorno
             pr_nrremret,
             pr_dtmvtolt,
             pr_nmarquiv,
             1,
             SYSDATE,
             to_char(SYSDATE, 'HH24MISS'),
             1); -- Pendente
        
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao inserir CRAPHCC | Conta: ' ||
                         GENE0002.fn_mask_conta(pr_nrdconta) ||
                         ' | Convenio: ' || pr_nrconven ||
                         ' | -> ' || SQLERRM;
      END;
    END;
  
  BEGIN
  
    --------------- VALIDACOES INICIAIS -----------------
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
      INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
  
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
  
    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
  
    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
    -- Buscar parametro maiores cheques
    vr_tab_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper -- Cooperativa
                                                 ,pr_nmsistem => 'CRED' -- Sistema
                                                 ,pr_tptabela => 'USUARI' -- Tipo da tabela
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'MAIORESCHQ' -- Código de acesso
                                                 ,pr_tpregist => 1); -- Tipo de registro
    -- Se não encontrou
    IF TRIM(vr_tab_dstextab) IS NULL THEN
      -- Montar mensagem de crítica
      vr_cdcritic := 55;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      vr_dscritic := vr_dscritic || ' => CRED-USUARI-11-MAIORESCHQ-001';
      RAISE vr_exc_saida;
    ELSE
      -- Valor maior cheque
      vr_tab_vlchqmai := TO_NUMBER(SUBSTR(vr_tab_dstextab, 1, 15));
    END IF;
  
    -- Retorna primeiro dia útil anterior a partir da data atual
    vr_dtrefere := fn_busca_n_dias_uteis_atras(pr_cdcooper => rw_crapccc.cdcooper -- Cooperativa
                                              ,pr_dtrefere => rw_crapdat.dtmvtolt -- Data atual
                                              ,pr_qtdddias => 1); -- Quantidade de dias a serem descontados
    -- Retorna segundo dia útil anterior a partir da data atual                                                                                                  
    vr_dtrefern := fn_busca_n_dias_uteis_atras(pr_cdcooper => rw_crapccc.cdcooper -- Cooperativa
                                              ,pr_dtrefere => rw_crapdat.dtmvtolt -- Data atual
                                              ,pr_qtdddias => 2); -- Quantidade de dias a serem descontados
  
    FOR rw_crapccc IN cr_crapccc(pr_cdcooper => pr_cdcooper) LOOP
    
      BEGIN
        -- Para cada cooperado inicializamos oregistro de geracao da hcc
        vr_criou_craphcc := 0;  
        
        -- Buscar o Último Lote de Retorno do Cooperado
        OPEN cr_craphcc(pr_cdcooper => rw_crapccc.cdcooper,
                        pr_nrdconta => rw_crapccc.nrdconta,
                        pr_nrconven => rw_crapccc.nrconven);
        FETCH cr_craphcc INTO rw_craphcc;
        vr_nrremret := rw_craphcc.nrremret;
        CLOSE cr_craphcc;
          
        -- Montar nome de arquivo de retorno
        vr_nmarquiv := 'CST_' ||
                       TRIM(to_char(rw_crapccc.nrdconta, '00000000')) || '_' ||
                       TRIM(to_char(vr_nrremret, '000000000')) || '.RET';
      
        -- Para cada cheque de fora superior a 300
        FOR rw_chqfora_sup300 IN cr_chqfora_sup300(pr_cdcooper => rw_crapccc.cdcooper   -- Cooperativa
                                                  ,pr_nrdconta => rw_crapccc.nrdconta   -- Número da Conta
                                                  ,pr_nrconven => rw_crapccc.nrconven   -- Numero do convenio
                                                  ,pr_dtrefere => vr_dtrefere           -- Primeiro dia útil da data anterior
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt   -- Data atual
                                                  ,pr_vlchqmai => vr_tab_vlchqmai) LOOP -- Valor do maior cheque
        
          -- Verifica se nao criou o registro da hcc
          IF vr_criou_craphcc = 0 THEN
            -- Criar o registro da hcc
            pc_criar_hcc (pr_cdcooper => rw_crapccc.cdcooper -- Cooperativa
                         ,pr_nrdconta => rw_crapccc.nrdconta -- Conta
                         ,pr_nrconven => rw_crapccc.nrconven -- Numero do Convenio
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data
                         ,pr_nrremret => vr_nrremret         -- Numero da remessa de retorno
                         ,pr_nmarquiv => vr_nmarquiv         -- Nome do arquivo de retorno
                         ,pr_cdcritic => vr_cdcritic         -- Codigo da critica
                         ,pr_dscritic => vr_dscritic);       -- Descricao da critica
                         
            -- Verificar se gerou critica
            IF NVL(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              -- Executa a exception
              RAISE vr_exc_loop;
            END IF;
            -- Atualiza a informacao para CRIOU o registro da HCC
            vr_criou_craphcc := 1;
          END IF;
          
          -- Contador para o numero de sequencia
          vr_nrsequen := vr_nrsequen + 1;
        
          -- Se cdpesqbb for nulo
          IF TRIM(rw_chqfora_sup300.cdpesqbb) IS NOT NULL THEN
            vr_cdtipmvt := 7; -- Cheque devolvido
            vr_cdalinea := TO_NUMBER(TRIM(rw_cqdevolu.cdpesqbb));
            vr_dtcredit := NULL;
          ELSE
            vr_cdtipmvt := 8; -- Cheque compensado
            vr_cdalinea := NULL;
            vr_dtcredit := rw_crapdat.dtmvtolt;
          END IF;
        
          rc_crapdcc(vr_nrsequen).cdcooper := rw_crapccc.cdcooper;
          rc_crapdcc(vr_nrsequen).nrdconta := rw_crapccc.nrdconta;
          rc_crapdcc(vr_nrsequen).nrconven := rw_crapccc.nrconven;
          rc_crapdcc(vr_nrsequen).intipmvt := 2; -- Retorno
          rc_crapdcc(vr_nrsequen).nrremret := vr_nrremret; -- Numero ultimo retorno + 1 do cursor cr_craphcc
          rc_crapdcc(vr_nrsequen).nrseqarq := vr_nrsequen; -- Numero sequencial do registro na tabela
          rc_crapdcc(vr_nrsequen).cdtipmvt := vr_cdtipmvt; -- 7 = cheque devolvido, 8 = cheque liquidado
          rc_crapdcc(vr_nrsequen).cdfinmvt := rw_chqfora_sup300.cdfinmvt;
          rc_crapdcc(vr_nrsequen).cdentdad := rw_chqfora_sup300.cdentdad;
          rc_crapdcc(vr_nrsequen).dsdocmc7 := rw_chqfora_sup300.dsdocmc7;
          rc_crapdcc(vr_nrsequen).cdcmpchq := rw_chqfora_sup300.cdcmpchq;
          rc_crapdcc(vr_nrsequen).cdbanchq := rw_chqfora_sup300.cdbanchq;
          rc_crapdcc(vr_nrsequen).cdagechq := rw_chqfora_sup300.cdagechq;
          rc_crapdcc(vr_nrsequen).nrctachq := rw_chqfora_sup300.nrctachq;
          rc_crapdcc(vr_nrsequen).nrcheque := rw_chqfora_sup300.nrcheque;
          rc_crapdcc(vr_nrsequen).vlcheque := rw_chqfora_sup300.vlcheque;
          rc_crapdcc(vr_nrsequen).cdtipemi := rw_chqfora_sup300.cdtipemi;
          rc_crapdcc(vr_nrsequen).nrinsemi := rw_chqfora_sup300.nrinsemi;
          rc_crapdcc(vr_nrsequen).dtdcaptu := rw_chqfora_sup300.dtdcaptu;
          rc_crapdcc(vr_nrsequen).dtlibera := rw_chqfora_sup300.dtlibera;
          rc_crapdcc(vr_nrsequen).dtcredit := vr_dtcredit; -- Se cheque liquidado, rw_crapdat.dtmvtolt senão NULL;
          rc_crapdcc(vr_nrsequen).dsusoemp := rw_chqfora_sup300.dsusoemp;
          rc_crapdcc(vr_nrsequen).cdagedev := NULL;
          rc_crapdcc(vr_nrsequen).nrctadev := NULL;
          rc_crapdcc(vr_nrsequen).cdalinea := vr_cdalinea;
          rc_crapdcc(vr_nrsequen).cdocorre := vr_cdalinea;
          rc_crapdcc(vr_nrsequen).inconcil := rw_chqfora_sup300.inconcil;
          rc_crapdcc(vr_nrsequen).cdagenci := NULL;
          rc_crapdcc(vr_nrsequen).cdbccxlt := NULL;
          rc_crapdcc(vr_nrsequen).nrdolote := NULL;
          rc_crapdcc(vr_nrsequen).inchqcop := rw_chqfora_sup300.inchqcop;
        
          IF MOD(cr_chqfora_sup300%ROWCOUNT, 1000) = 0 OR
             rw_chqfora_sup300.rn = rw_chqfora_sup300.tot THEN
            pc_atualiza_dcc;
          END IF;
        
        END LOOP;
      
        -- Para cada cheque de fora superior a 300
        FOR rw_chqfora_inf300 IN cr_chqfora_inf300(pr_cdcooper => rw_crapccc.cdcooper -- Cooperativa
                                                  ,pr_nrdconta => rw_crapccc.nrdconta -- Número da Conta
                                                  ,pr_nrconven => rw_crapccc.nrconven -- Numero do convenio                                                   
                                                  ,pr_dtrefere => vr_dtrefern         -- Segundo dia útil da data anterior
                                                  ,pr_dtrefern => vr_dtrefere         -- Primeiro dia útil da data anterior
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data atual
                                                  ,pr_vlchqmai => vr_tab_vlchqmai)    -- Valor do maior cheque
         LOOP
           
          -- Verifica se nao criou o registro da hcc
          IF vr_criou_craphcc = 0 THEN
            -- Criar o registro da hcc
            pc_criar_hcc (pr_cdcooper => rw_crapccc.cdcooper -- Cooperativa
                         ,pr_nrdconta => rw_crapccc.nrdconta -- Conta
                         ,pr_nrconven => rw_crapccc.nrconven -- Numero do Convenio
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data
                         ,pr_nrremret => vr_nrremret         -- Numero da remessa de retorno
                         ,pr_nmarquiv => vr_nmarquiv         -- Nome do arquivo de retorno
                         ,pr_cdcritic => vr_cdcritic         -- Codigo da critica
                         ,pr_dscritic => vr_dscritic);       -- Descricao da critica
                         
            -- Verificar se gerou critica
            IF NVL(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              -- Executa a exception
              RAISE vr_exc_loop;
            END IF;
            -- Atualiza a informacao para CRIOU o registro da HCC
            vr_criou_craphcc := 1;
          END IF;
         
          -- Contador para o numero de sequencia
          vr_nrsequen := vr_nrsequen + 1;
        
          IF TRIM(rw_chqfora_inf300.cdpesqbb) IS NOT NULL THEN
            vr_cdtipmvt := 7;
            vr_cdalinea := TO_NUMBER(TRIM(rw_cqdevolu.cdpesqbb));
            vr_dtcredit := NULL;
          ELSE
            vr_cdtipmvt := 8;
            vr_cdalinea := NULL;
            vr_dtcredit := rw_crapdat.dtmvtolt;
          END IF;
        
          rc_crapdcc(vr_nrsequen).cdcooper := rw_crapccc.cdcooper;
          rc_crapdcc(vr_nrsequen).nrdconta := rw_crapccc.nrdconta;
          rc_crapdcc(vr_nrsequen).nrconven := rw_crapccc.nrconven;
          rc_crapdcc(vr_nrsequen).intipmvt := 2; -- Retorno
          rc_crapdcc(vr_nrsequen).nrremret := vr_nrremret; -- Numero ultimo retorno + 1 do cursor cr_craphcc
          rc_crapdcc(vr_nrsequen).nrseqarq := vr_nrsequen; -- Numero sequencial do registro na tabela
          rc_crapdcc(vr_nrsequen).cdtipmvt := vr_cdtipmvt; -- 7 = cheque devolvido, 8 = cheque liquidado
          rc_crapdcc(vr_nrsequen).cdfinmvt := rw_chqfora_inf300.cdfinmvt;
          rc_crapdcc(vr_nrsequen).cdentdad := rw_chqfora_inf300.cdentdad;
          rc_crapdcc(vr_nrsequen).dsdocmc7 := rw_chqfora_inf300.dsdocmc7;
          rc_crapdcc(vr_nrsequen).cdcmpchq := rw_chqfora_inf300.cdcmpchq;
          rc_crapdcc(vr_nrsequen).cdbanchq := rw_chqfora_inf300.cdbanchq;
          rc_crapdcc(vr_nrsequen).cdagechq := rw_chqfora_inf300.cdagechq;
          rc_crapdcc(vr_nrsequen).nrctachq := rw_chqfora_inf300.nrctachq;
          rc_crapdcc(vr_nrsequen).nrcheque := rw_chqfora_inf300.nrcheque;
          rc_crapdcc(vr_nrsequen).vlcheque := rw_chqfora_inf300.vlcheque;
          rc_crapdcc(vr_nrsequen).cdtipemi := rw_chqfora_inf300.cdtipemi;
          rc_crapdcc(vr_nrsequen).nrinsemi := rw_chqfora_inf300.nrinsemi;
          rc_crapdcc(vr_nrsequen).dtdcaptu := rw_chqfora_inf300.dtdcaptu;
          rc_crapdcc(vr_nrsequen).dtlibera := rw_chqfora_inf300.dtlibera;
          rc_crapdcc(vr_nrsequen).dtcredit := vr_dtcredit; -- Se cheque liquidado, rw_crapdat.dtmvtolt senão NULL;
          rc_crapdcc(vr_nrsequen).dsusoemp := rw_chqfora_inf300.dsusoemp;
          rc_crapdcc(vr_nrsequen).cdagedev := NULL;
          rc_crapdcc(vr_nrsequen).nrctadev := NULL;
          rc_crapdcc(vr_nrsequen).cdalinea := vr_cdalinea;
          rc_crapdcc(vr_nrsequen).cdocorre := vr_cdalinea;
          rc_crapdcc(vr_nrsequen).inconcil := rw_chqfora_inf300.inconcil;
          rc_crapdcc(vr_nrsequen).cdagenci := NULL;
          rc_crapdcc(vr_nrsequen).cdbccxlt := NULL;
          rc_crapdcc(vr_nrsequen).nrdolote := NULL;
          rc_crapdcc(vr_nrsequen).inchqcop := rw_chqfora_inf300.inchqcop;
        
          IF MOD(cr_chqfora_inf300%ROWCOUNT, 1000) = 0 OR
             rw_chqfora_inf300.rn = rw_chqfora_inf300.tot THEN
            pc_atualiza_dcc;
          END IF;
        
        END LOOP;
      
        -- Para cada cheque da cooperativa compensado
        FOR rw_cheqcoop IN cr_cheqcoop(pr_cdcooper => rw_crapccc.cdcooper
                                      ,pr_nrdconta => rw_crapccc.nrdconta -- Número da Conta
                                      ,pr_nrconven => rw_crapccc.nrconven -- Numero do convenio                                       
                                      ,pr_dtrefere => vr_dtrefere
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
        
          -- Verifica se nao criou o registro da hcc
          IF vr_criou_craphcc = 0 THEN
            -- Criar o registro da hcc
            pc_criar_hcc (pr_cdcooper => rw_crapccc.cdcooper -- Cooperativa
                         ,pr_nrdconta => rw_crapccc.nrdconta -- Conta
                         ,pr_nrconven => rw_crapccc.nrconven -- Numero do Convenio
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data
                         ,pr_nrremret => vr_nrremret         -- Numero da remessa de retorno
                         ,pr_nmarquiv => vr_nmarquiv         -- Nome do arquivo de retorno
                         ,pr_cdcritic => vr_cdcritic         -- Codigo da critica
                         ,pr_dscritic => vr_dscritic);       -- Descricao da critica
                         
            -- Verificar se gerou critica
            IF NVL(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              -- Executa a exception
              RAISE vr_exc_loop;
            END IF;
            -- Atualiza a informacao para CRIOU o registro da HCC
            vr_criou_craphcc := 1;
          END IF;
        
          -- Contador para o numero de sequencia
          vr_nrsequen := vr_nrsequen + 1;
        
          rc_crapdcc(vr_nrsequen).cdcooper := rw_crapccc.cdcooper;
          rc_crapdcc(vr_nrsequen).nrdconta := rw_crapccc.nrdconta;
          rc_crapdcc(vr_nrsequen).nrconven := rw_crapccc.nrconven;
          rc_crapdcc(vr_nrsequen).intipmvt := 2; -- Retorno
          rc_crapdcc(vr_nrsequen).nrremret := vr_nrremret; -- Numero ultimo retorno + 1 do cursor cr_craphcc
          rc_crapdcc(vr_nrsequen).nrseqarq := vr_nrsequen; -- Numero sequencial do registro na tabela
          rc_crapdcc(vr_nrsequen).cdtipmvt := 8; -- 7 = cheque devolvido, 8 = cheque liquidado
          rc_crapdcc(vr_nrsequen).cdfinmvt := rw_cheqcoop.cdfinmvt;
          rc_crapdcc(vr_nrsequen).cdentdad := rw_cheqcoop.cdentdad;
          rc_crapdcc(vr_nrsequen).dsdocmc7 := rw_cheqcoop.dsdocmc7;
          rc_crapdcc(vr_nrsequen).cdcmpchq := rw_cheqcoop.cdcmpchq;
          rc_crapdcc(vr_nrsequen).cdbanchq := rw_cheqcoop.cdbanchq;
          rc_crapdcc(vr_nrsequen).cdagechq := rw_cheqcoop.cdagechq;
          rc_crapdcc(vr_nrsequen).nrctachq := rw_cheqcoop.nrctachq;
          rc_crapdcc(vr_nrsequen).nrcheque := rw_cheqcoop.nrcheque;
          rc_crapdcc(vr_nrsequen).vlcheque := rw_cheqcoop.vlcheque;
          rc_crapdcc(vr_nrsequen).cdtipemi := rw_cheqcoop.cdtipemi;
          rc_crapdcc(vr_nrsequen).nrinsemi := rw_cheqcoop.nrinsemi;
          rc_crapdcc(vr_nrsequen).dtdcaptu := rw_cheqcoop.dtdcaptu;
          rc_crapdcc(vr_nrsequen).dtlibera := rw_cheqcoop.dtlibera;
          rc_crapdcc(vr_nrsequen).dtcredit := rw_crapdat.dtmvtolt; -- Se cheque liquidado, rw_crapdat.dtmvtolt senão NULL;
          rc_crapdcc(vr_nrsequen).dsusoemp := rw_cheqcoop.dsusoemp;
          rc_crapdcc(vr_nrsequen).cdagedev := NULL;
          rc_crapdcc(vr_nrsequen).nrctadev := NULL;
          rc_crapdcc(vr_nrsequen).cdalinea := NULL;
          rc_crapdcc(vr_nrsequen).cdocorre := NULL;
          rc_crapdcc(vr_nrsequen).inconcil := rw_cheqcoop.inconcil;
          rc_crapdcc(vr_nrsequen).cdagenci := NULL;
          rc_crapdcc(vr_nrsequen).cdbccxlt := NULL;
          rc_crapdcc(vr_nrsequen).nrdolote := NULL;
          rc_crapdcc(vr_nrsequen).inchqcop := rw_cheqcoop.inchqcop;
        
          IF MOD(cr_cheqcoop%ROWCOUNT, 1000) = 0 OR
             rw_cheqcoop.rn = rw_cheqcoop.tot THEN
            pc_atualiza_dcc;
          END IF;
        
        END LOOP;
      
        -- Para cada cheque da cooperativa devolvido 
        FOR rw_cqdevolu IN cr_cqdevolu(pr_cdcooper => rw_crapccc.cdcooper       -- Coperativa
                                      ,pr_nrdconta => rw_crapccc.nrdconta       -- Número da Conta
                                      ,pr_nrconven => rw_crapccc.nrconven       -- Numero do convenio                                       
                                      ,pr_dtrefere => vr_dtrefere               -- Um dia útil atrás
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP -- Data atual
        
          -- Verifica se nao criou o registro da hcc
          IF vr_criou_craphcc = 0 THEN
            -- Criar o registro da hcc
            pc_criar_hcc (pr_cdcooper => rw_crapccc.cdcooper -- Cooperativa
                         ,pr_nrdconta => rw_crapccc.nrdconta -- Conta
                         ,pr_nrconven => rw_crapccc.nrconven -- Numero do Convenio
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data
                         ,pr_nrremret => vr_nrremret         -- Numero da remessa de retorno
                         ,pr_nmarquiv => vr_nmarquiv         -- Nome do arquivo de retorno
                         ,pr_cdcritic => vr_cdcritic         -- Codigo da critica
                         ,pr_dscritic => vr_dscritic);       -- Descricao da critica
                         
            -- Verificar se gerou critica
            IF NVL(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              -- Executa a exception
              RAISE vr_exc_loop;
            END IF;
            -- Atualiza a informacao para CRIOU o registro da HCC
            vr_criou_craphcc := 1;
          END IF;

          -- Contador para o numero de sequencia
          vr_nrsequen := vr_nrsequen + 1;
        
          rc_crapdcc(vr_nrsequen).cdcooper := rw_crapccc.cdcooper;
          rc_crapdcc(vr_nrsequen).nrdconta := rw_crapccc.nrdconta;
          rc_crapdcc(vr_nrsequen).nrconven := rw_crapccc.nrconven;
          rc_crapdcc(vr_nrsequen).intipmvt := 2; -- Retorno
          rc_crapdcc(vr_nrsequen).nrremret := vr_nrremret; -- Numero ultimo retorno + 1 do cursor cr_craphcc
          rc_crapdcc(vr_nrsequen).nrseqarq := vr_nrsequen; -- Numero sequencial do registro na tabela
          rc_crapdcc(vr_nrsequen).cdtipmvt := 7; -- 7 = cheque devolvido, 8 = cheque liquidado
          rc_crapdcc(vr_nrsequen).cdfinmvt := rw_cqdevolu.cdfinmvt;
          rc_crapdcc(vr_nrsequen).cdentdad := rw_cqdevolu.cdentdad;
          rc_crapdcc(vr_nrsequen).dsdocmc7 := rw_cqdevolu.dsdocmc7;
          rc_crapdcc(vr_nrsequen).cdcmpchq := rw_cqdevolu.cdcmpchq;
          rc_crapdcc(vr_nrsequen).cdbanchq := rw_cqdevolu.cdbanchq;
          rc_crapdcc(vr_nrsequen).cdagechq := rw_cqdevolu.cdagechq;
          rc_crapdcc(vr_nrsequen).nrctachq := rw_cqdevolu.nrctachq;
          rc_crapdcc(vr_nrsequen).nrcheque := rw_cqdevolu.nrcheque;
          rc_crapdcc(vr_nrsequen).vlcheque := rw_cqdevolu.vlcheque;
          rc_crapdcc(vr_nrsequen).cdtipemi := rw_cqdevolu.cdtipemi;
          rc_crapdcc(vr_nrsequen).nrinsemi := rw_cqdevolu.nrinsemi;
          rc_crapdcc(vr_nrsequen).dtdcaptu := rw_cqdevolu.dtdcaptu;
          rc_crapdcc(vr_nrsequen).dtlibera := rw_cqdevolu.dtlibera;
          rc_crapdcc(vr_nrsequen).dtcredit := NULL; -- Se cheque liquidado, rw_crapdat.dtmvtolt senão NULL;
          rc_crapdcc(vr_nrsequen).dsusoemp := rw_cqdevolu.dsusoemp;
          rc_crapdcc(vr_nrsequen).cdagedev := NULL;
          rc_crapdcc(vr_nrsequen).nrctadev := NULL;
          rc_crapdcc(vr_nrsequen).cdalinea := TO_NUMBER(TRIM(rw_cqdevolu.cdpesqbb)); -- cdalinea
          rc_crapdcc(vr_nrsequen).cdocorre := NULL; -- cdocorre
          rc_crapdcc(vr_nrsequen).inconcil := rw_cqdevolu.inconcil;
          rc_crapdcc(vr_nrsequen).cdagenci := NULL;
          rc_crapdcc(vr_nrsequen).cdbccxlt := NULL;
          rc_crapdcc(vr_nrsequen).nrdolote := NULL;
          rc_crapdcc(vr_nrsequen).inchqcop := rw_cqdevolu.inchqcop;
        
          IF MOD(cr_cqdevolu%ROWCOUNT, 1000) = 0 OR
             rw_cqdevolu.rn = rw_cqdevolu.tot THEN
            pc_atualiza_dcc;
          END IF;
        
        END LOOP;
      
        -- Para cada cheque resgatado do dia
        FOR rw_cqresgat IN cr_cqresgat(pr_cdcooper => rw_crapccc.cdcooper       -- Cooperativa
                                      ,pr_nrdconta => rw_crapccc.nrdconta       -- Número da Conta
                                      ,pr_nrconven => rw_crapccc.nrconven       -- Numero do convenio                                      
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP -- Data atual
        
          -- Verifica se nao criou o registro da hcc
          IF vr_criou_craphcc = 0 THEN
            -- Criar o registro da hcc
            pc_criar_hcc (pr_cdcooper => rw_crapccc.cdcooper -- Cooperativa
                         ,pr_nrdconta => rw_crapccc.nrdconta -- Conta
                         ,pr_nrconven => rw_crapccc.nrconven -- Numero do Convenio
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data
                         ,pr_nrremret => vr_nrremret         -- Numero da remessa de retorno
                         ,pr_nmarquiv => vr_nmarquiv         -- Nome do arquivo de retorno
                         ,pr_cdcritic => vr_cdcritic         -- Codigo da critica
                         ,pr_dscritic => vr_dscritic);       -- Descricao da critica
                         
            -- Verificar se gerou critica
            IF NVL(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              -- Executa a exception
              RAISE vr_exc_loop;
            END IF;
            -- Atualiza a informacao para CRIOU o registro da HCC
            vr_criou_craphcc := 1;
          END IF;

          -- Contador para o numero de sequencia
          vr_nrsequen := vr_nrsequen + 1;
        
          rc_crapdcc(vr_nrsequen).cdcooper := rw_crapccc.cdcooper;
          rc_crapdcc(vr_nrsequen).nrdconta := rw_crapccc.nrdconta;
          rc_crapdcc(vr_nrsequen).nrconven := rw_crapccc.nrconven;
          rc_crapdcc(vr_nrsequen).intipmvt := 2; -- Retorno
          rc_crapdcc(vr_nrsequen).nrremret := vr_nrremret; -- Numero ultimo retorno + 1 do cursor cr_craphcc
          rc_crapdcc(vr_nrsequen).nrseqarq := vr_nrsequen; -- Numero sequencial do registro na tabela
          rc_crapdcc(vr_nrsequen).cdtipmvt := 7; -- 7 = cheque devolvido, 8 = cheque liquidado
          rc_crapdcc(vr_nrsequen).cdfinmvt := rw_cqresgat.cdfinmvt;
          rc_crapdcc(vr_nrsequen).cdentdad := rw_cqresgat.cdentdad;
          rc_crapdcc(vr_nrsequen).dsdocmc7 := rw_cqresgat.dsdocmc7;
          rc_crapdcc(vr_nrsequen).cdcmpchq := rw_cqresgat.cdcmpchq;
          rc_crapdcc(vr_nrsequen).cdbanchq := rw_cqresgat.cdbanchq;
          rc_crapdcc(vr_nrsequen).cdagechq := rw_cqresgat.cdagechq;
          rc_crapdcc(vr_nrsequen).nrctachq := rw_cqresgat.nrctachq;
          rc_crapdcc(vr_nrsequen).nrcheque := rw_cqresgat.nrcheque;
          rc_crapdcc(vr_nrsequen).vlcheque := rw_cqresgat.vlcheque;
          rc_crapdcc(vr_nrsequen).cdtipemi := rw_cqresgat.cdtipemi;
          rc_crapdcc(vr_nrsequen).nrinsemi := rw_cqresgat.nrinsemi;
          rc_crapdcc(vr_nrsequen).dtdcaptu := rw_cqresgat.dtdcaptu;
          rc_crapdcc(vr_nrsequen).dtlibera := rw_cqresgat.dtlibera;
          rc_crapdcc(vr_nrsequen).dtcredit := NULL; -- Se cheque liquidado, rw_crapdat.dtmvtolt senão NULL;
          rc_crapdcc(vr_nrsequen).dsusoemp := rw_cqresgat.dsusoemp;
          rc_crapdcc(vr_nrsequen).cdagedev := NULL;
          rc_crapdcc(vr_nrsequen).nrctadev := NULL;
          rc_crapdcc(vr_nrsequen).cdalinea := NULL; -- cdalinea
          rc_crapdcc(vr_nrsequen).cdocorre := NULL; -- cdocorre
          rc_crapdcc(vr_nrsequen).inconcil := rw_cqresgat.inconcil;
          rc_crapdcc(vr_nrsequen).cdagenci := NULL;
          rc_crapdcc(vr_nrsequen).cdbccxlt := NULL;
          rc_crapdcc(vr_nrsequen).nrdolote := NULL;
          rc_crapdcc(vr_nrsequen).inchqcop := rw_cqresgat.inchqcop;
        
          IF MOD(cr_cqresgat%ROWCOUNT, 1000) = 0 OR
             rw_cqresgat.rn = rw_cqresgat.tot THEN
            pc_atualiza_dcc;
          END IF;
        
        END LOOP;
      
        CUST0001.pc_gerar_arquivo_retorno(pr_cdcooper => rw_crapccc.cdcooper -- Cooperativa
                                         ,pr_nrdconta => rw_crapccc.nrdconta -- Nr. da conta
                                         ,pr_nrconven => rw_crapccc.nrconven -- Nr. do convenio
                                         ,pr_nrremret => vr_nrremret         -- Nr. da remessa/retorno
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data atual
                                         ,pr_idorigem => 1                   -- Origem Ayllos Fixo
                                         ,pr_cdoperad => '1'                 -- Operador 1 fixo
                                         ,pr_nmarquiv => vr_nmarquiv         -- Nome do arquivo
                                         ,pr_cdcritic => vr_cdcritic         -- Cód. crítica
                                         ,pr_dscritic => vr_dscritic);       -- Desc. crítica
        -- Se retornou crítica                                                               
        IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          vr_dscritic := vr_dscritic || ' | Conta: ' ||
                         GENE0002.fn_mask_conta(rw_crapccc.nrdconta) ||
                         ' | Convenio: ' || rw_crapccc.nrconven || ' | ';
          RAISE vr_exc_loop;
        ELSE
          -- Informar no log o arquivo gerado
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 1 -- Processo normal
                                    ,
                                     pr_des_log      => to_char(sysdate,
                                                                'hh24:mi:ss') ||
                                                        ' - ' || vr_cdprogra ||
                                                        ' --> Arquivo de retorno gerado: ' ||
                                                        vr_nmarquiv);
        END IF;
      
        -- Devemos commitar por conta processada 
        COMMIT;
      
      EXCEPTION
        WHEN vr_exc_loop THEN
          -- Gera crítica no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 3 -- Erro não tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss') ||
                                                        ' - ' || vr_cdprogra ||
                                                        ' --> ' ||
                                                        vr_dscritic);
          -- Limpa variáveis
          vr_cdcritic := 0;
          vr_dscritic := NULL;
          -- Efetuar rollback
          ROLLBACK;
          -- Pular para próxima conta
          CONTINUE;
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro crapccc | Conta: ' ||
                         GENE0002.fn_mask_conta(rw_crapccc.nrdconta) ||
                         ' | Convenio: ' || rw_crapccc.nrconven || ' | -> ' ||
                         SQLERRM;
        
          -- Gera crítica no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 3 -- Erro não tratato
                                    ,
                                     pr_des_log      => to_char(sysdate,
                                                                'hh24:mi:ss') ||
                                                        ' - ' || vr_cdprogra ||
                                                        ' --> ' ||
                                                        vr_dscritic);
          -- Limpa variáveis
          vr_cdcritic := 0;
          vr_dscritic := NULL;
          ROLLBACK;
          CONTINUE;
      END;
    
    END LOOP;
  
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------
  
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);
  
    -- Salvar informações atualizadas
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2 -- Erro tratato
                                ,
                                 pr_des_log      => to_char(sysdate,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END;

END pc_crps679;
/
