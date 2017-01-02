CREATE OR REPLACE PROCEDURE cecred.pc_crps618(pr_cdcooper  IN craptab.cdcooper%type,
                                              pr_nrdconta  IN crapcob.nrdconta%TYPE,
                                              pr_flgresta  IN PLS_INTEGER,            --> Flag padrão para utilização de restart
                                              pr_stprogra OUT PLS_INTEGER,            --> Saída de termino da execução
                                              pr_infimsol OUT PLS_INTEGER,            --> Saída de termino da solicitação,
                                              pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                              pr_dscritic OUT VARCHAR2) AS

  /******************************************************************************
    Programa: pc_crps618 (Antigo: fontes/crps618.p) 
    Sistema : Cobranca - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Rafael
    Data    : janeiro/2012.                     Ultima atualizacao: 14/11/2016
 
    Dados referentes ao programa:
 
    Frequencia: Diario.
    Objetivo  : Buscar confirmacao de registro dos titulos na CIP.
                Registrar titulos na CIP a partir de novembro/2013.
    
    Observacoes: O script /usr/local/cecred/bin/crps618.pl executa este 
                 programa para verificar o registro/rejeicao dos titulos 
                 na CIP enviados no dia.
                 
                 Horario de execucao: todos os dias, das 6:00h as 22:00h
                                      a cada 15 minutos.
                                      
    Alteracoes: 27/08/2013 - Alterado busca de registros de titulos utilizando
                             a data do movimento anterior (Rafael).
                             
                21/10/2013 - Incluido parametro novo na prep-retorno-cooperado
                             ref. ao numero de remessa do arquivo (Rafael).
                             
                15/11/2013 - Mudanças no processo de registro dos titulos na 
                             CIP: a partir da liberaçăo de novembro/2013, os
                             titulos gerados serăo registrados por este 
                             programa definidos pela CRON. O campo 
                             "crapcob.insitpro" irá utilizar os seguintes 
                             valores:
                             0 -> sacado comum (nao DDA);
                             1 -> sacado a verificar se é DDA;
                             2 -> Enviado a CIP;
                             3 -> Sacado DDA OK;
                             4 -> năo haverá mais -> retornar a "zero";
                             
                03/12/2013 - Incluido nome da temp-table tt-remessa-dda nos 
                             campos onde faltavam o nome da tabela. (Rafael)
                             
                30/12/2013 - Ajuste na leitura/gravacao das informacoes dos
                             titulos ref. ao DDA. (Rafael)     
                
                14/01/2014 - Alteracao referente a integracao Progress X 
                             Dataserver Oracle 
                             Inclusao do VALIDATE ( Andre Euzebio / SUPERO)  
                             
                03/02/2014 - Ajuste Projeto Novo Fator de Vencimento (Daniel).
                
                27/05/2014 - Aumentado o tempo para decurso de prazo de titulos 
                             DDA de 22 para 59 dias (Tiago SD138818).
                             
                17/07/2014 - Alterado forma de gravacao do tipo de multa para
                             garantir a confirmacao do registro na CIP. (Rafael)
                             
                12/02/2014 - Incluido restriçăo para năo enviar cobrança para a cabine 
                             no qual o valor ultrapasse 9.999.999,99, pois a cabine
                             existe essa limitaçăo de valor e apresentará falha năo 
                             tratada SD-250064 (Odirlei-AMcom)
                             
                28/04/2015 - Ajustar indicador de alt de valor ref a boletos
                             vencidos DDA para "N" -> Sacado năo pode alterar
                             o valor de boleto vencido. (SD 279793 - Rafael)
                             
                29/05/2015 - Concatenar motivo "A4" para titulos DDA no registro
                             de confirmacao de retorno na crapret.
                           - Enviar titulo Cooperativa/EE ao DDA quando já
                             enviado para a PG. (Projeto 219 - Rafael)
                                                         
                31/07/2015 - Ajuste para retirar o caminho absoluto na chamada
                             de fontes
                             (Adriano - SD 314469).
                                                                         
                18/08/2015 - Ajuste na data limite de pagto para boletos do 
                             convenio "EMPRESTIMO" - Projeto 210 (Rafael).
                             
                14/11/2016 - CONVERSÃO PROGRESS >> ORACLE (Renato Darosci - Supero)
                
                01/12/2016 - Alterado para enviar como texto informativo o conteudo do campo
                             dsinform, ao inves do campo dsdinstr
                             Heitor (Mouts) - Chamado 564818
  ******************************************************************************/
  -- CONSTANTES
  vr_cdprogra     CONSTANT VARCHAR2(10) := 'crps618';     -- Nome do programa
  vr_dsarqlog     CONSTANT VARCHAR2(12) := 'crps618.log'; -- Nome do arquivo de log
  vr_vllimcab     CONSTANT NUMBER       := 9999999.99;    -- Define o valor limite da cabine
  vr_cdoperad     CONSTANT VARCHAR2(10) := '1';           -- Código do operador - verificar se será fixo ou parametro

  -- CURSORES 
  -- Buscar as cooperativas para processamento
  -- Quanto a cooperativa do parametro for 3, ira processar todas as coops 
  -- exceto CECRED, quando outra cooperativa for informada, gerar para a propria
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
         , cop.cdbcoctl
         , cop.cdagectl
      FROM crapcop cop
     WHERE (pr_cdcooper = 3 AND cop.cdcooper <> 3) 
        OR (pr_cdcooper <> 3 AND cop.cdcooper = pr_cdcooper);
  
  -- Buscar os títulos a serem registrados na CIP
  CURSOR cr_titulos(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_cdbcoctl crapcop.cdbcoctl%TYPE
                   ,pr_dtmvtoan crapcob.dtmvtolt%TYPE
                   ,pr_dtmvtolt crapcob.dtmvtolt%TYPE) IS 
    SELECT COUNT(1)     OVER (PARTITION BY cob.nrinssac) nrqtdreg
         , ROW_NUMBER() OVER (PARTITION BY cob.nrinssac
                                  ORDER BY cob.nrinssac) nrseqreg
         -- CRAPCOB
         , cob.rowid    rowidcob
         , cob.cdcooper
         , cob.nrdconta
         , cob.cdtpinsc
         , cob.inemiten
         , cob.inemiexp
         , cob.vltitulo
         , cob.nrcnvcob
         , cob.nrdocmto
         , cob.idopeleg
         , cob.idtitleg 
         , cob.dtvencto
         , cob.cdbandoc
         , cob.cdcartei
         , cob.tpjurmor
         , cob.cddespec 
         , cob.nrnosnum
         , cob.cdtpinav
         , cob.nrinsava
         , cob.nmdavali
         , cob.dsdoccop
         , cob.flgdprot
         , cob.qtdiaprt
         , cob.vlabatim
         , cob.vljurdia
         , cob.tpdmulta
         , cob.vlrmulta
         , cob.vldescto
         , cob.dsinform
         , cob.flgaceit
         -- CRAPCCO
         , cco.cddbanco
         , cco.dsorgarq
         -- CRAPSAB
         , sab.nrinssac
         , sab.nmdsacad
         , sab.dsendsac
         , sab.nmcidsac
         , sab.cdufsaca
         , sab.nrcepsac
         -- CRAPASS
         , ass.inpessoa
         , ass.nrcpfcgc
         , ass.nmprimtl
      FROM crapcco cco
         , crapceb ceb
         , crapass ass
         , crapcob cob
         , crapsab sab
     WHERE ceb.cdcooper = cco.cdcooper
       AND ceb.nrconven = cco.nrconven
       AND ass.cdcooper = ceb.cdcooper
       AND ass.nrdconta = ceb.nrdconta
       AND cob.cdcooper = ceb.cdcooper
       AND cob.nrcnvcob = ceb.nrconven
       AND cob.nrdconta = ceb.nrdconta
       AND cob.flgregis = 1 -- TRUE 
       AND cob.insitpro = 1 
       AND cob.dtmvtolt BETWEEN pr_dtmvtoan AND pr_dtmvtolt
       AND cob.incobran = 0
       AND (cob.nrdconta = pr_nrdconta OR NVL(pr_nrdconta,0) = 0)
       AND sab.cdcooper = cob.cdcooper
       AND sab.nrdconta = cob.nrdconta
       AND sab.nrinssac = cob.nrinssac
       AND cco.flgregis = 1 -- TRUE
       AND cco.cdcooper = pr_cdcooper
       AND cco.cddbanco = pr_cdbcoctl
     ORDER BY cob.nrinssac;
  
  -- Buscar os registros dos bancos
  CURSOR cr_crapban IS
    SELECT ban.cdbccxlt
         , ban.nrispbif 
      FROM crapban  ban;
  
  -- Buscar os títulos que receberam "OK" da CIP
  CURSOR cr_ok_cip(pr_cdcooper crapcop.cdcooper%TYPE
                  ,pr_cdbcoctl crapcop.cdbcoctl%TYPE
                  ,pr_dtmvtoan crapcob.dtmvtolt%TYPE) IS 
    SELECT cob.cdbandoc
         , cob.idtitleg
         , cob.idopeleg 
         , cob.insitpro 
      FROM crapcco   cco
         , crapceb   ceb
         , crapcob   cob
     WHERE ceb.cdcooper = cco.cdcooper
       AND ceb.nrconven = cco.nrconven
       AND cob.cdcooper = ceb.cdcooper
       AND cob.nrcnvcob = ceb.nrconven
       AND cob.nrdconta = ceb.nrdconta
       AND cob.flgregis = 1 -- TRUE 
       AND cob.flgcbdda = 1 -- TRUE
       AND cob.insitpro = 2
       AND cob.dtmvtolt >= pr_dtmvtoan
       AND cob.incobran = 0
       AND cco.cdcooper = pr_cdcooper
       AND cco.cddbanco = pr_cdbcoctl
       AND cco.flgregis = 1 -- TRUE
       AND (cob.nrdconta = pr_nrdconta OR NVL(pr_nrdconta,0) = 0);
  
  -- TIPOS
  TYPE tp_tab_crapban IS TABLE OF cr_crapban%ROWTYPE INDEX BY BINARY_INTEGER;
  
  -- VARIÁVEIS
  vr_tb_remessa_dda     DDDA0001.typ_tab_remessa_dda;
  vr_tb_retorno_dda     DDDA0001.typ_tab_retorno_dda;
  vr_tb_crapban         tp_tab_crapban;
  
  vr_inauxtab           NUMBER;
  vr_tppessoa           VARCHAR2(1);
  vr_flgsacad           NUMBER;
  vr_cdcritic           NUMBER;
  vr_dscritic           VARCHAR2(1000);
  vr_des_erro           VARCHAR2(10);
  vr_insitpro           NUMBER;
  vr_inregist           NUMBER;
  
  -- EXCEPTIONS
  vr_exc_saida          EXCEPTION; 
  
  -- Procedure para criacao de titulo
  PROCEDURE pc_cria_titulo(pr_rw_titulos IN OUT cr_titulos%ROWTYPE
                          ,pr_crapdat    IN     BTCH0001.cr_crapdat%ROWTYPE
                          ,pr_cdagectl   IN     crapcop.cdagectl%TYPE
                          ,pr_des_erro      OUT VARCHAR2
                          ,pr_dscritic      OUT VARCHAR2) IS 
    
    -- CONSTANTES
    vr_dtinicio   CONSTANT DATE := to_date('10/07/1997', 'DD/MM/RRRR');
    
    -- CURSORES
    -- Buscar praça não executante de protesto
    CURSOR cr_crappnp(pr_nmextcid  crappnp.nmextcid%TYPE
                     ,pr_cduflogr  crappnp.cduflogr%TYPE) IS
      SELECT 1
        FROM crappnp  pnp
       WHERE pnp.nmextcid = pr_nmextcid  
         AND pnp.cduflogr = pr_cduflogr;
  
    -- VARIÁVEIS     
    vr_flgdprot   crapcob.flgdprot%TYPE;
    vr_qtdiaprt   crapcob.qtdiaprt%TYPE;
    vr_indiaprt   crapcob.indiaprt%TYPE;
    vr_cdbarras   VARCHAR2(50);
    vr_dsdjuros   VARCHAR2(500);
    vr_cddespec   VARCHAR2(50);
    vr_dtemissa   DATE;
    vr_ftvencto   NUMBER;
    vr_inauxreg   NUMBER;
    vr_fldigito   BOOLEAN;
    
  BEGIN 
    
    -- Indicador de execução
    pr_des_erro := 'NOK';
    
    -- Inicializa
    vr_flgdprot := NULL;
    vr_qtdiaprt := NULL;
    vr_indiaprt := NULL;
    
    -- Buscar praça não executante de protesto
    OPEN  cr_crappnp(pr_rw_titulos.nmcidsac
                    ,pr_rw_titulos.cdufsaca);
    FETCH cr_crappnp INTO vr_inauxreg;

    -- Se encontrar registro    
    IF cr_crappnp%FOUND THEN
      -- Atribuir o valor as variáveis para atualizar os campos no update
      vr_flgdprot := 0; -- FALSE
      vr_qtdiaprt := 0;
      vr_indiaprt := 3;
    
      -- Inserir o cadastro de log do boleto
      BEGIN
        INSERT INTO crapcol(cdcooper
                           ,nrdconta
                           ,nrdocmto
                           ,nrcnvcob
                           ,dslogtit
                           ,cdoperad
                           ,dtaltera
                           ,hrtransa)
                     VALUES(pr_rw_titulos.cdcooper     -- cdcooper
                           ,pr_rw_titulos.nrdconta     -- nrdconta
                           ,pr_rw_titulos.nrdocmto     -- nrdocmto
                           ,pr_rw_titulos.nrcnvcob     -- nrcnvcob
                           ,'Obs.: Praca nao executante de protesto' -- dslogtit
                           ,'1'                        -- cdoperad
                           ,TRUNC(SYSDATE)             -- dtaltera
                           ,GENE0002.fn_busca_time()); -- hrtransa
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'PC_CRIA_TITULO: Erro ao inserir CRAPCOL: '||SQLERRM;
          RETURN;
      END;
    END IF;
    
    -- Atualizar informações de cobrança
    BEGIN
      UPDATE crapcob cob
         SET cob.flgdprot = NVL(vr_flgdprot,cob.flgdprot)
           , cob.qtdiaprt = NVL(vr_qtdiaprt,cob.qtdiaprt)
           , cob.indiaprt = NVL(vr_indiaprt,cob.indiaprt)
           , cob.idopeleg = seqcob_idopeleg.NEXTVAL
           , cob.idtitleg = seqcob_idtitleg.NEXTVAL
       WHERE ROWID = pr_rw_titulos.rowidcob
       RETURNING cob.idopeleg
               , cob.idtitleg 
            INTO pr_rw_titulos.idopeleg
               , pr_rw_titulos.idtitleg;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'PC_CRIA_TITULO: Erro ao atualizar CRAPCOB: '||SQLERRM;
        RETURN;
    END; 
    
    --##-- CALCULAR E MONTAR O CÓDIGO DE BARRAS --##--
      
    -- Se a data de vencimento é superior a 22/02/2025
    IF pr_rw_titulos.dtvencto >= TO_DATE('22/02/2025','DD/MM/RRRR') THEN
      vr_ftvencto := (pr_rw_titulos.dtvencto - TO_DATE('22/02/2025','DD/MM/RRRR') ) + 1000;
    ELSE
      vr_ftvencto := (pr_rw_titulos.dtvencto - vr_dtinicio);
    END IF;

    -- Agrupar os valores para formar o código de barras
    vr_cdbarras := LPAD(pr_rw_titulos.cdbandoc, 3, '0') -- BANCO
                || '9'                                  -- MOEDA 
                || '1'                                  -- NAO ALTERAR - DÍGITO CONSTANTE - Será calculado abaixo
                || LPAD(vr_ftvencto, 4, '0')            -- FATOR DE VENCIMENTO
                || TO_CHAR(pr_rw_titulos.vltitulo * 100, 'FM0000000000') -- VALOR DO TÍTULO
                || LPAD(pr_rw_titulos.nrcnvcob, 6, '0') -- NÚMERO DO CONVENIO DE COBRANCA
                || LPAD(pr_rw_titulos.nrnosnum, 17, '0')-- NOSSO NÚMERO 
                || LPAD(pr_rw_titulos.cdcartei, 2, '0');-- CODIGO DA CARTEIRA DO BLOQUETO

    -- Verificar / calcular o dígito verificador
    CXON0000.pc_calc_digito_titulo(pr_valor   => vr_cdbarras
                                  ,pr_retorno => vr_fldigito);
               
    --##-- ------------------------------------ --##--
      
    -- Verifica o tipo dos juros
    vr_dsdjuros := CASE pr_rw_titulos.tpjurmor  
                     WHEN 1 THEN '1'
                     WHEN 2 THEN '3'
                     WHEN 3 THEN '5'
                   END;
      
    -- Código da espécie do bloqueto
    vr_cddespec := CASE pr_rw_titulos.cddespec
                     WHEN 1 THEN '02'
                     WHEN 2 THEN '04'
                     WHEN 3 THEN '12'
                     WHEN 4 THEN '21'
                     WHEN 5 THEN '23'
                     WHEN 6 THEN '17'
                     WHEN 7 THEN '99'
                   END;
      
    -- Se não encontrar o banco
    IF NOT vr_tb_crapban.EXISTS(pr_rw_titulos.cdbandoc) THEN
      pr_dscritic := 'Banco nao encontrado.';
      RETURN;  -- NOK;
    END IF;

    -- Se foi passado data
    IF pr_crapdat.rowid IS NOT NULL THEN
      -- Se a data de hoje for menor que a data de movimento
      IF TRUNC(SYSDATE) < pr_crapdat.dtmvtolt THEN
        vr_dtemissa := pr_crapdat.dtmvtoan;
      ELSE
        vr_dtemissa := pr_crapdat.dtmvtolt;
      END IF;
    ELSE
      -- Define a data atual como data de emissão
      vr_dtemissa := TRUNC(SYSDATE);
    END IF;
      
    -- Definir o índice
    vr_inauxtab := vr_tb_remessa_dda.COUNT() + 1;
      
    vr_tb_remessa_dda(vr_inauxtab).cdlegado := 'LEG';
    vr_tb_remessa_dda(vr_inauxtab).nrispbif := vr_tb_crapban(pr_rw_titulos.cdbandoc).nrispbif;
    vr_tb_remessa_dda(vr_inauxtab).idopeleg := pr_rw_titulos.idopeleg;
    vr_tb_remessa_dda(vr_inauxtab).idtitleg := pr_rw_titulos.idtitleg;
    vr_tb_remessa_dda(vr_inauxtab).tpoperad := 'I'; 
    vr_tb_remessa_dda(vr_inauxtab).cdifdced := 085; 
    -- Verifica se é pessoa física ou Jurídica
    IF pr_rw_titulos.inpessoa = 1 THEN
      vr_tb_remessa_dda(vr_inauxtab).tppesced := 'F';
    ELSE
      vr_tb_remessa_dda(vr_inauxtab).tppesced := 'J';
    END IF;
    vr_tb_remessa_dda(vr_inauxtab).nrdocced := pr_rw_titulos.nrcpfcgc;
    vr_tb_remessa_dda(vr_inauxtab).nmdocede := REPLACE(pr_rw_titulos.nmprimtl,'&','%26');
    vr_tb_remessa_dda(vr_inauxtab).cdageced := pr_cdagectl;
    vr_tb_remessa_dda(vr_inauxtab).nrctaced := pr_rw_titulos.nrdconta;
    -- Pessoa física ou jurídica conforme verificado anteriormente
    vr_tb_remessa_dda(vr_inauxtab).tppesori := vr_tb_remessa_dda(vr_inauxtab).tppesced;
    vr_tb_remessa_dda(vr_inauxtab).nrdocori := pr_rw_titulos.nrcpfcgc;
    vr_tb_remessa_dda(vr_inauxtab).nmdoorig := REPLACE(pr_rw_titulos.nmprimtl,'&','%26');
      
    IF pr_rw_titulos.cdtpinsc = 1 THEN 
      vr_tb_remessa_dda(vr_inauxtab).tppessac := 'F';
    ELSE
      vr_tb_remessa_dda(vr_inauxtab).tppessac := 'J';
    END IF;
      
    vr_tb_remessa_dda(vr_inauxtab).nrdocsac := pr_rw_titulos.nrinssac;
    vr_tb_remessa_dda(vr_inauxtab).nmdosaca := pr_rw_titulos.nmdsacad;
    vr_tb_remessa_dda(vr_inauxtab).dsendsac := pr_rw_titulos.dsendsac;
    vr_tb_remessa_dda(vr_inauxtab).dscidsac := pr_rw_titulos.nmcidsac;
    vr_tb_remessa_dda(vr_inauxtab).dsufsaca := pr_rw_titulos.cdufsaca;
    vr_tb_remessa_dda(vr_inauxtab).nrcepsac := pr_rw_titulos.nrcepsac;
    vr_tb_remessa_dda(vr_inauxtab).tpdocava := pr_rw_titulos.cdtpinav; 
      
    -- Se o tipo de inscricao do avalista for diferente de zero
    IF pr_rw_titulos.cdtpinav <> 0 THEN
      vr_tb_remessa_dda(vr_inauxtab).nrdocava := pr_rw_titulos.nrinsava;
    END IF;
      
    vr_tb_remessa_dda(vr_inauxtab).nmdoaval := TRIM(pr_rw_titulos.nmdavali);

    vr_tb_remessa_dda(vr_inauxtab).cdcartei := '1'; -- Cobranca simples 
    vr_tb_remessa_dda(vr_inauxtab).cddmoeda := '09'; -- 9 = Real 
    vr_tb_remessa_dda(vr_inauxtab).dsnosnum := pr_rw_titulos.nrnosnum;
    vr_tb_remessa_dda(vr_inauxtab).dscodbar := vr_cdbarras;
    vr_tb_remessa_dda(vr_inauxtab).dtvencto := TO_NUMBER(TO_CHAR(pr_rw_titulos.dtvencto,'RRRRMMDD'));
    vr_tb_remessa_dda(vr_inauxtab).vlrtitul := pr_rw_titulos.vltitulo;
    vr_tb_remessa_dda(vr_inauxtab).nrddocto := pr_rw_titulos.dsdoccop;
    vr_tb_remessa_dda(vr_inauxtab).cdespeci := vr_cddespec;
    vr_tb_remessa_dda(vr_inauxtab).dtemissa := TO_NUMBER(TO_CHAR(vr_dtemissa,'RRRRMMDD'));
      
    -- Se o flag for TRUE
    IF pr_rw_titulos.flgdprot = 1 THEN 
      vr_tb_remessa_dda(vr_inauxtab).nrdiapro := pr_rw_titulos.qtdiaprt;
      vr_tb_remessa_dda(vr_inauxtab).dtlipgto := 
                                       TO_NUMBER(TO_CHAR(pr_rw_titulos.dtvencto + pr_rw_titulos.qtdiaprt,'RRRRMMDD'));
    ELSE 
      -- Se for emprestimo
      IF pr_rw_titulos.dsorgarq = 'EMPRESTIMO' THEN
        vr_tb_remessa_dda(vr_inauxtab).dtlipgto := TO_NUMBER(TO_CHAR(pr_rw_titulos.dtvencto,'RRRRMMDD'));
      ELSE
        vr_tb_remessa_dda(vr_inauxtab).dtlipgto := TO_NUMBER(TO_CHAR(pr_rw_titulos.dtvencto + 52,'RRRRMMDD'));
      END IF;
    END IF;
      
    vr_tb_remessa_dda(vr_inauxtab).tpdepgto := 3; -- vencto indeterminado 
    vr_tb_remessa_dda(vr_inauxtab).indnegoc := 'N';
    vr_tb_remessa_dda(vr_inauxtab).vlrabati := pr_rw_titulos.vlabatim;
      
    -- Se o valor de juros diário
    IF pr_rw_titulos.vljurdia > 0 THEN 
      vr_tb_remessa_dda(vr_inauxtab).dtdjuros := TO_NUMBER(TO_CHAR(pr_rw_titulos.dtvencto + 1,'RRRRMMDD'));
    END IF;
      
    vr_tb_remessa_dda(vr_inauxtab).dsdjuros := vr_dsdjuros;
    vr_tb_remessa_dda(vr_inauxtab).vlrjuros := NVL(pr_rw_titulos.vljurdia,0);
      
    -- Verificar multa
    IF pr_rw_titulos.tpdmulta NOT IN ('1','2') THEN
      vr_tb_remessa_dda(vr_inauxtab).dtdmulta := NULL; 
      vr_tb_remessa_dda(vr_inauxtab).cddmulta := 3; 
      vr_tb_remessa_dda(vr_inauxtab).vlrmulta := 0; 
    ELSE 
      vr_tb_remessa_dda(vr_inauxtab).dtdmulta := TO_NUMBER(TO_CHAR(pr_rw_titulos.dtvencto + 1,'RRRRMMDD'));
      vr_tb_remessa_dda(vr_inauxtab).cddmulta := pr_rw_titulos.tpdmulta;
      vr_tb_remessa_dda(vr_inauxtab).vlrmulta := pr_rw_titulos.vlrmulta;
    END IF;
      
    -- Se flag esta marcado como 1 - SIM
    IF pr_rw_titulos.flgaceit = 1 THEN
      vr_tb_remessa_dda(vr_inauxtab).flgaceit := 'S';
    ELSE 
      vr_tb_remessa_dda(vr_inauxtab).flgaceit := 'N';
    END IF;
      
    -- Se o valor de desconto é maior que zero
    IF pr_rw_titulos.vldescto > 0 THEN 
      vr_tb_remessa_dda(vr_inauxtab).dtddesct := TO_NUMBER(TO_CHAR(pr_rw_titulos.dtvencto,'RRRRMMDD'));
      vr_tb_remessa_dda(vr_inauxtab).cdddesct := 1;
      vr_tb_remessa_dda(vr_inauxtab).vlrdesct := pr_rw_titulos.vldescto;
    ELSE 
      vr_tb_remessa_dda(vr_inauxtab).dtddesct := NULL;
      vr_tb_remessa_dda(vr_inauxtab).cdddesct := 0;
      vr_tb_remessa_dda(vr_inauxtab).vlrdesct := 0; 
    END IF;
      
    vr_tb_remessa_dda(vr_inauxtab).dsinstru := TRIM(pr_rw_titulos.dsinform);
    vr_tb_remessa_dda(vr_inauxtab).tpmodcal := '01';
    vr_tb_remessa_dda(vr_inauxtab).flavvenc := 'N'; -- Indicador se o valor do boleto pode ser alterado 

    -- Incluir o log do boleto
    BEGIN 
      INSERT INTO crapcol(cdcooper
                         ,nrdconta
                         ,nrcnvcob
                         ,nrdocmto
                         ,dslogtit
                         ,cdoperad
                         ,dtaltera
                         ,hrtransa)
                   VALUES(pr_rw_titulos.cdcooper   -- cdcooper 
                         ,pr_rw_titulos.nrdconta   -- nrdconta 
                         ,pr_rw_titulos.nrcnvcob   -- nrcnvcob 
                         ,pr_rw_titulos.nrdocmto   -- nrdocmto 
                         ,'Titulo enviado a CIP'   -- dslogtit 
                         ,'1'                      -- cdoperad 
                         ,TRUNC(SYSDATE)           -- dtaltera 
                         ,GENE0002.fn_busca_time); -- hrtransa 
    EXCEPTION 
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gerar Log do boleto: '||SQLERRM;
        RETURN;
    END;
      
    -- Indicador de execução
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_dscritic := 'Erro na PC_CRIA_TITULO: '||SQLERRM;
  END pc_cria_titulo;
  
  /* Rotina para verificar titulos confirmados/rejeitados na CIP */
  PROCEDURE pc_verifica_titulos_dda(pr_cdcooper       IN NUMBER
                                   ,pr_des_erro      OUT VARCHAR2
                                   ,pr_dscritic      OUT VARCHAR2) IS 

    -- CURSORES
    -- Buscar dados da cobrança
    CURSOR cr_crapcob(pr_idtitleg IN crapcob.idtitleg%TYPE) IS 
      SELECT cob.rowid   rowidcob
           , cob.cdcooper
           , cob.nrdconta
           , cob.nrcnvcob
           , cob.nrdocmto
        FROM crapcob cob 
       WHERE cob.idtitleg = pr_idtitleg;
    rw_crapcob  cr_crapcob%ROWTYPE;

    -- VARIÁVEIS
    vr_qttitreg    NUMBER;
    vr_qttitrej    NUMBER := 0;
    vr_dscritic    VARCHAR2(1000);
    vr_des_erro    VARCHAR2(10);

  BEGIN
    
    -- Inicializa
    pr_des_erro := 'NOK';
  
    -- Procedure para Executar retorno operacao Titulos DDA
    DDDA0001.pc_retorno_tit_tab_DDA(pr_tab_remessa_dda => vr_tb_remessa_dda
                                   ,pr_tab_retorno_dda => vr_tb_retorno_dda
                                   ,pr_cdcritic        => vr_cdcritic
                                   ,pr_dscritic        => vr_dscritic);
    
    -- Se houver retorno de erro
    IF vr_dscritic IS NOT NULL THEN
      pr_dscritic := vr_dscritic;
      RETURN; -- Retorno com NOK
    END IF;
    
    -- Zerar os contatores
    vr_qttitreg := 0;
    vr_qttitrej := 0;
    
    -- Se NÃO houve retorno 
    IF vr_tb_retorno_dda.COUNT() > 0 THEN
      -- Percorrer os registros com INSITPRO = 4 -- EJ/EC erro
      FOR ind IN vr_tb_retorno_dda.FIRST..vr_tb_retorno_dda.LAST LOOP
        
        -- Verifica o insitpro -- EJ/EC erro
        IF vr_tb_retorno_dda(ind).insitpro = 4 THEN
        
          -- Buscar dados da cobrança
          OPEN  cr_crapcob(vr_tb_retorno_dda(ind).idtitleg);
          FETCH cr_crapcob INTO rw_crapcob;
          
          -- Se encontrar registros
          IF cr_crapcob%FOUND THEN
            BEGIN
              UPDATE crapcob cob
                 SET cob.insitpro = 0 -- sacado comum
                   , cob.flgcbdda = 0 -- FALSE
               WHERE cob.rowid    = rw_crapcob.rowidcob;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'PC_VERIFICA_TITULOS_DDA: Erro ao atualizar CRAPCOB: '||SQLERRM;
                RETURN; -- Retorno com NOK
            END;
            
            -- Cria o log da cobrança
            PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_dtmvtolt => SYSDATE
                                         ,pr_dsmensag => 'Titulo Rejeitado na CIP'
                                         ,pr_des_erro => vr_des_erro
                                         ,pr_dscritic => vr_dscritic);
          
            -- Se ocorrer erro
            IF vr_des_erro <> 'OK' THEN
              pr_dscritic := vr_dscritic;
              RETURN; -- Retorno com NOK
            END IF;
            
            -- Sumarizar a quantidade de registros
            vr_qttitrej := NVL(vr_qttitrej,0) + 1;
          END IF;
        
          -- Fecha o cursor
          CLOSE cr_crapcob;
        
        END IF; -- vr_tb_retorno_dda(ind).insitpro = 4
      END LOOP;
      
      -- Percorrer os registros com INSITPRO = 3 -- RC - Registro CIP
      FOR ind IN vr_tb_retorno_dda.FIRST..vr_tb_retorno_dda.LAST LOOP
        -- Verifica o insitpro -- RC - Registro CIP
        IF vr_tb_retorno_dda(ind).insitpro = 3 THEN
          -- Sumarizar a quantidade de registros
          vr_qttitreg := NVL(vr_qttitreg,0) + 1;

          -- Buscar dados da cobrança
          OPEN  cr_crapcob(vr_tb_retorno_dda(ind).idtitleg);
          FETCH cr_crapcob INTO rw_crapcob;
          
          -- Se encontrar registros
          IF cr_crapcob%FOUND THEN
            BEGIN
              UPDATE crapcob cob
                 SET cob.insitpro = vr_tb_retorno_dda(ind).insitpro
                   , cob.flgcbdda = 1 -- TRUE
               WHERE cob.rowid    = rw_crapcob.rowidcob;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'PC_VERIFICA_TITULOS_DDA: Erro ao atualizar CRAPCOB: '||SQLERRM;
                RETURN; -- Retorno com NOK
            END;
            
            -- Cria o log da cobrança
            PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_dtmvtolt => SYSDATE
                                         ,pr_dsmensag => 'Titulo Registrado - CIP'
                                         ,pr_des_erro => vr_des_erro
                                         ,pr_dscritic => vr_dscritic);
          
            -- Se ocorrer erro
            IF vr_des_erro <> 'OK' THEN
              pr_dscritic := vr_dscritic;
              RETURN; -- Retorno com NOK
            END IF;
            
            -- Atualizar a CRAPRET
            BEGIN
              UPDATE crapret ret
                 SET ret.cdmotivo = 'A4'
               WHERE ret.cdcooper = rw_crapcob.cdcooper 
                 AND ret.nrdconta = rw_crapcob.nrdconta 
                 AND ret.nrcnvcob = rw_crapcob.nrcnvcob 
                 AND ret.nrdocmto = rw_crapcob.nrdocmto 
                 AND ret.cdocorre = 2
                 AND TRIM(ret.cdmotivo) IS NULL;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'PC_VERIFICA_TITULOS_DDA: Erro ao atualizar CRAPRET: '||SQLERRM;
                RETURN; -- Retorno com NOK
            END;
          END IF; -- cr_crapcob%FOUND 
        END IF; -- vr_tb_retorno_dda(ind).insitpro = 3
      END LOOP; -- vr_tb_retorno_dda
    END IF;
    
    -- Se houveram titulos registrados
    IF NVL(vr_qttitreg,0) > 0 THEN
      -- Gerar log no arquivo do CRPS618
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Processo Normal
                                ,pr_nmarqlog     => vr_dsarqlog 
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '||vr_cdprogra||' --> Titulos registrados: '||vr_qttitreg);
    ELSE
      -- Gerar log no arquivo do CRPS618
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Processo Normal
                                ,pr_nmarqlog     => vr_dsarqlog 
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '||vr_cdprogra||' --> Nenhum titulo registrado');

    END IF;

    -- Se houveram titulos rejeitados
    IF NVL(vr_qttitrej,0) > 0 THEN
      -- Gerar log no arquivo do CRPS618
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Processo Normal
                                ,pr_nmarqlog     => vr_dsarqlog 
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '||vr_cdprogra||' --> Titulos rejeitados: '||vr_qttitrej);
    END IF;

    -- RETORNAR SITUAÇÃO DE OK PARA A EXECUÇÃO
    pr_des_erro := 'OK';

  END pc_verifica_titulos_dda;
  
  
  /**********************************************************/
   
BEGIN
  
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_'||UPPER(vr_cdprogra),
                             pr_action => vr_cdprogra);
     
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);

  -- Se ocorreu erro
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;
  
  -- Limpar a tabela de memória
  vr_tb_crapban.DELETE();
  
  -- Carregar o registros de bancos
  FOR rw_crapban IN cr_crapban LOOP
    -- Incluir o registro do banco na tabela de memória
    vr_tb_crapban(rw_crapban.cdbccxlt) := rw_crapban;
  END LOOP;
  
  -- Percorrer as cooperativas
  FOR rw_crapcop IN cr_crapcop LOOP
  
    -- Gerar log no arquivo do CRPS618
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                              ,pr_ind_tipo_log => 1 -- Processo Normal
                              ,pr_nmarqlog     => vr_dsarqlog 
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' - '||vr_cdprogra||' --> Programa iniciado');
    
    /* DESNECESSÁRIO POIS O LOOP JÁ EH POR COOPERATIVA
    -- Verifica se a cooperativa esta cadastrada 
    OPEN  cr_crapcop(vr_cdcooper);
    FETCH cr_crapcop INTO vr_inregist;
    
    -- Verificar se existe informação, e gerar erro caso não exista
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapcop;
      -- Gerar exceção
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcop; */
    
    /* Busca data do sistema */ 
    OPEN  BTCH0001.cr_crapdat(rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO BTCH0001.rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    -- Fechar 
    CLOSE BTCH0001.cr_crapdat;

    -- Limpar registros de memória
    vr_tb_remessa_dda.DELETE();
    vr_tb_retorno_dda.DELETE();
    
    -- Rotina para registrar os títulos na CIP
    FOR rw_titulos IN cr_titulos(rw_crapcop.cdcooper
                                ,rw_crapcop.cdbcoctl
                                ,BTCH0001.rw_crapdat.dtmvtoan
                                ,BTCH0001.rw_crapdat.dtmvtolt) LOOP
      
      -- Se for o primeiro NRINSSAC
      IF rw_titulos.nrseqreg = 1 THEN
          
        -- Verificar o tipo da inscrição
        IF rw_titulos.cdtpinsc = 1 THEN
          vr_tppessoa := 'F'; /*Fisica*/
        ELSE
          vr_tppessoa := 'J'; /*Juridica*/
        END IF;

        -- Chamar rotina para realizar as verificações do SAcado
        DDDA0001.pc_verifica_sacado_dda(pr_tppessoa => vr_tppessoa
                                       ,pr_nrcpfcgc => rw_titulos.nrinssac
                                       ,pr_flgsacad => vr_flgsacad
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

        -- Verifica se ocorreu erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
          
        -- Verifica sacado - Se TRUE
        IF vr_flgsacad = 1 THEN
          vr_insitpro := 2;   -- enviar/enviado p/ CIP
        ELSE
          vr_insitpro := 0;   -- nao eh sacado DDA 
        END IF;
          
      END IF; -- FIM: rw_titulos.nrseqreg = 1

      -- Se titulo Cooperativa/EE e nao foi enviado ainda para a PG, năo enviar ao DDA 
      IF rw_titulos.inemiten  = 3   AND 
         rw_titulos.inemiexp <> 2   THEN 
        CONTINUE; -- Passar para o próximo registro
      END IF;

      -- Tratamento para năo enviar para a cabine pois a cabine existe essa limitaçăo de valor 
      IF rw_titulos.vltitulo > vr_vllimcab THEN 
        -- Devido a limitação da cabine, indica como não sendo sacado DDA
        vr_insitpro := 0;
         
        -- Cria o log da cobrança
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_titulos.rowidcob
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dtmvtolt => SYSDATE
                                     ,pr_dsmensag => 'Falha no envio para a CIP (valor superior ao suportado)'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
      
        -- Se ocorrer erro
        IF vr_des_erro <> 'OK' THEN
          RAISE vr_exc_saida;
        END IF;
      END IF; -- FIM: rw_titulos.vltitulo > vr_vllimcab

      -- Se sacado for DDA, entao titulo eh DDA 
      IF vr_insitpro = 2 THEN
        -- Atualizar CRAPCOP 
        BEGIN
          UPDATE crapcob
             SET flgcbdda = 1 -- TRUE
               , insitpro = 2 -- enviar p/ CIP 
           WHERE ROWID = rw_titulos.rowidcob;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro[1] ao atualizar CRAPCOB: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
          
        -- Rotina para criação de titulo
        pc_cria_titulo(pr_rw_titulos => rw_titulos 
                      ,pr_crapdat    => BTCH0001.rw_crapdat
                      ,pr_cdagectl   => rw_crapcop.cdagectl
                      ,pr_des_erro   => vr_des_erro
                      ,pr_dscritic   => vr_dscritic);
          
        -- Verifica se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          -- Atualizar CRAPCOP 
          BEGIN
            UPDATE crapcob
               SET flgcbdda = 0 -- FALSE
                 , insitpro = 0
                 , idtitleg = 0
                 , idopeleg = 0
             WHERE ROWID = rw_titulos.rowidcob;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro[2] ao atualizar CRAPCOB: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF; /* fim - return_value */
      
      ELSE
        -- Atualizar CRAPCOP 
        BEGIN
          UPDATE crapcob
             SET flgcbdda = 0 -- FALSE
               , insitpro = 0
           WHERE ROWID = rw_titulos.rowidcob;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro[3] ao atualizar CRAPCOB: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;
    END LOOP;  
    
    -- Realizar a remessa de títulos DDA
    DDDA0001.pc_remessa_tit_tab_dda(pr_tab_remessa_dda => vr_tb_remessa_dda
                                   ,pr_tab_retorno_dda => vr_tb_retorno_dda
                                   ,pr_cdcritic        => vr_cdcritic
                                   ,pr_dscritic        => vr_dscritic);
    
    -- Verificar se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      pr_dscritic := 'Erro na rotina PC_REMESSA_TITULOS_DDA: '||vr_dscritic;
      RAISE vr_exc_saida;
    END IF;
    
    -- Rotina para buscar o "OK" da CIP
    vr_tb_remessa_dda.DELETE();
    vr_tb_retorno_dda.DELETE();
    
    -- Percorrer os registros que tiveram retorno Ok da CIP
    FOR rw_ok_cip IN cr_ok_cip(rw_crapcop.cdcooper
                              ,rw_crapcop.cdbcoctl
                              ,BTCH0001.rw_crapdat.dtmvtoan) LOOP
    
       -- Definir o índice
      vr_inauxtab := vr_tb_remessa_dda.COUNT() + 1;
      
          -- Carrega temp remessa-dda para verificacao       
      vr_tb_remessa_dda(vr_inauxtab).nrispbif := vr_tb_crapban(rw_ok_cip.cdbandoc).nrispbif;
      vr_tb_remessa_dda(vr_inauxtab).cdlegado := 'LEG';
      vr_tb_remessa_dda(vr_inauxtab).idtitleg := rw_ok_cip.idtitleg;
      vr_tb_remessa_dda(vr_inauxtab).idopeleg := rw_ok_cip.idopeleg;
      vr_tb_remessa_dda(vr_inauxtab).insitpro := rw_ok_cip.insitpro;
    END LOOP;

    -- Se encontrar registros na tabela
    IF vr_tb_remessa_dda.COUNT() > 0 THEN
      pc_verifica_titulos_dda(pr_cdcooper   => rw_crapcop.cdcooper
                             ,pr_des_erro   => vr_des_erro
                             ,pr_dscritic   => vr_dscritic);
      
      -- Se houve o retorno de erro
      IF vr_des_erro <> 'OK' THEN
        RAISE vr_exc_saida;
      END IF;
    ELSE
      -- Gerar log no arquivo do CRPS618
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                                ,pr_ind_tipo_log => 1 -- Processo Normal
                                ,pr_nmarqlog     => vr_dsarqlog 
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> Nenhum titulo registrado');

    END IF;
    
    -- Gerar log no arquivo do CRPS618
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper
                              ,pr_ind_tipo_log => 1 -- Processo Normal
                              ,pr_nmarqlog     => vr_dsarqlog 
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' - '||vr_cdprogra||' --> Programa finalizado');

  END LOOP; -- Fim loop cooperativas
  
  
EXCEPTION
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END pc_crps618;
/
