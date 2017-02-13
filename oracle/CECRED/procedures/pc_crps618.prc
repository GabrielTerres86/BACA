CREATE OR REPLACE PROCEDURE cecred.pc_crps618(pr_cdcooper  IN craptab.cdcooper%type,
                                              pr_nrdconta  IN crapcob.nrdconta%TYPE,
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

                27/12/2016 - Tratamentos para Nova Plataforma de Cobrança
                             PRJ340 - NPC (Odirlei-AMcom)
  ******************************************************************************/
  -- CONSTANTES
  vr_cdprogra     CONSTANT VARCHAR2(10) := 'crps618';     -- Nome do programa
  vr_dsarqlog     CONSTANT VARCHAR2(12) := 'crps618.log'; -- Nome do arquivo de log
  vr_vllimcab     CONSTANT NUMBER       := 99999999.99;    -- Define o valor limite da cabine
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
     WHERE (pr_cdcooper = 3 AND cop.cdcooper <> 3 AND cop.flgativo = 1) -- batch
        OR (pr_cdcooper <> 3 AND cop.cdcooper = pr_cdcooper);           -- registro online
  
  -- Buscar os títulos a serem registrados na CIP
  CURSOR cr_titulos_carga (pr_cdcooper crapcop.cdcooper%TYPE
                          ,pr_cdbcoctl crapcop.cdbcoctl%TYPE
                          ,pr_vlrollou crapcob.vltitulo%TYPE
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
         , cob.inpagdiv
         , decode(cob.vlminimo,0,NULL,cob.vlminimo) vlminimo
         , cob.dtbloque
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
--       AND cob.insitpro IN (0,1)
       AND cob.inenvcip IN (0,1)
       AND cob.incobran = 0
       AND  cob.dtdpagto is null
       AND cob.dtvencto >= pr_dtmvtolt 
       AND cob.vltitulo >= pr_vlrollou
       AND sab.cdcooper = cob.cdcooper
       AND sab.nrdconta = cob.nrdconta
       AND sab.nrinssac = cob.nrinssac
       AND cco.flgregis = 1 -- TRUE
       AND cco.cdcooper = pr_cdcooper
       AND cco.cddbanco = pr_cdbcoctl       
     ORDER BY cob.nrinssac;
  
  -- Buscar os títulos a serem registrados na CIP
  CURSOR cr_titulos(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_cdbcoctl crapcop.cdbcoctl%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE
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
         , cob.inpagdiv
         , decode(cob.vlminimo,0,NULL,cob.vlminimo) vlminimo
         , cob.dtbloque
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
--       AND cob.insitpro = 1 
       AND cob.inenvcip = 1
       AND cob.dtmvtolt BETWEEN pr_dtmvtoan AND pr_dtmvtolt
       AND cob.incobran = 0
       AND (cob.nrdconta = pr_nrdconta OR NVL(pr_nrdconta,0) = 0)
       AND ((NVL(pr_nrdconta,0) > 0 AND cob.inregcip = 1) OR
            (NVL(pr_nrdconta,0) = 0 ))
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
--       AND cob.flgcbdda = 1 -- TRUE
--       AND cob.insitpro = 2
       AND cob.inenvcip = 2 -- enviado
       AND cob.dtmvtolt >= pr_dtmvtoan
       AND cob.incobran = 0
       AND cco.cdcooper = pr_cdcooper
       AND cco.cddbanco = pr_cdbcoctl
       AND cco.flgregis = 1; -- TRUE
  
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
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

  vr_tpdenvio           INTEGER;
  vr_flgerlog           BOOLEAN;
  vr_cdcooper           crapcop.cdcooper%TYPE;
  
  -- EXCEPTIONS
  vr_exc_saida          EXCEPTION; 
  
  -- Procedure para criacao de titulo
  PROCEDURE pc_cria_titulo(pr_rw_titulos IN OUT cr_titulos%ROWTYPE
                          ,pr_crapdat    IN     BTCH0001.cr_crapdat%ROWTYPE
                          ,pr_cdagectl   IN     crapcop.cdagectl%TYPE
                          ,pr_tpdenvio   IN     INTEGER                   --> Tipo de envio(0-Normal/Batch, 1-Online, 2-Carga inicial)
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
    vr_dscmplog   VARCHAR2(100);
    
  BEGIN 
    
    -- Indicador de execução
    pr_des_erro := 'NOK';
    
    -- Inicializa
    vr_flgdprot := NULL;
    vr_qtdiaprt := NULL;
    vr_indiaprt := NULL;
    
    --Definir complemento do log conforme tipo de envio
    vr_dscmplog := NULL;
    IF pr_tpdenvio = 1 THEN
      vr_dscmplog := ' online';
    ELSIF pr_tpdenvio = 2 THEN
      vr_dscmplog := ' carga NPC';
    END IF;
    
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
                           ,'Obs.: Praca nao executante de protesto'||vr_dscmplog -- dslogtit
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
                     WHEN 1 THEN '2'
                     WHEN 2 THEN '4'
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
      
    vr_tb_remessa_dda(vr_inauxtab).rowidcob := pr_rw_titulos.rowidcob;
      
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
    vr_tb_remessa_dda(vr_inauxtab).tpmodcal := '04'; -- – CIP calcula boletos a vencer e vencido.
    vr_tb_remessa_dda(vr_inauxtab).flavvenc := 'N'; -- Indicador se o valor do boleto pode ser alterado 

    vr_tb_remessa_dda(vr_inauxtab).inpagdiv := pr_rw_titulos.inpagdiv;             
    vr_tb_remessa_dda(vr_inauxtab).vlminimo := pr_rw_titulos.vlminimo; 
    vr_tb_remessa_dda(vr_inauxtab).dtbloque := pr_rw_titulos.dtbloque;        

    --> gravar como envio online
    IF pr_tpdenvio = 1 THEN
      vr_tb_remessa_dda(vr_inauxtab).flonline := 'S';
    ELSE
      vr_tb_remessa_dda(vr_inauxtab).flonline := 'N';
    END IF; 
    
      
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
                   , cob.inenvcip = 4 -- rejeitado
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
                   , cob.inenvcip = 3 -- confirmado
                   , cob.dhenvcip = SYSDATE
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
  
  PROCEDURE pc_atualiza_status_envio_dda(pr_tab_remessa_dda IN OUT DDDA0001.typ_tab_remessa_dda
                                        ,pr_tpdenvio        IN INTEGER  --> tipo de envio(0-Normal/Batch, 1-Online, 2-Carga inicial)    
                                        ,pr_cdcritic       OUT INTEGER
                                        ,pr_dscritic       OUT VARCHAR2) IS
    vr_index     INTEGER;
    vr_exc_saida EXCEPTION;
    vr_cdcooper  crapcob.cdcooper%TYPE;
    vr_nrdconta  crapcob.cdcooper%TYPE;
    vr_nrcnvcob  crapcob.cdcooper%TYPE;
    vr_nrdocmto  crapcob.cdcooper%TYPE;
    vr_dscmplog  VARCHAR2(200);
    
    
  BEGIN
        
    vr_index := pr_tab_remessa_dda.FIRST;
      
    WHILE vr_index IS NOT NULL LOOP      

      -- Verifica se ocorreu erro
      IF TRIM(pr_tab_remessa_dda(vr_index).dscritic) IS NOT NULL THEN
        -- Atualizar CRAPCOB 
        BEGIN
          UPDATE crapcob
             SET flgcbdda = 0 -- FALSE
               , insitpro = 0
               , idtitleg = 0
               , idopeleg = 0
               , inenvcip = 0 -- não enviar
               , dhenvcip = null
           WHERE ROWID = pr_tab_remessa_dda(vr_index).rowidcob;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro[1] ao atualizar CRAPCOB: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE      
        -- Atualizar CRAPCOB 
        BEGIN
          UPDATE crapcob
             SET flgcbdda = 1 -- TRUE
               , insitpro = 2 -- recebido JD
               , inenvcip = 2 -- enviado
               , dhenvcip = SYSDATE
           WHERE ROWID = pr_tab_remessa_dda(vr_index).rowidcob
           RETURNING cdcooper,nrdconta,nrcnvcob,nrdocmto
                INTO vr_cdcooper,vr_nrdconta,vr_nrcnvcob,vr_nrdocmto;           
            
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro[2] ao atualizar CRAPCOB: '||SQLERRM;
            RAISE vr_exc_saida;
        END;      
        
        --Definir complemento do log conforme tipo de envio
        vr_dscmplog := NULL;
        IF pr_tpdenvio = 1 THEN
          vr_dscmplog := ' online';
        ELSIF pr_tpdenvio = 2 THEN
          vr_dscmplog := ' carga NPC';
        END IF;
        
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
                       VALUES(vr_cdcooper   -- cdcooper 
                             ,vr_nrdconta   -- nrdconta 
                             ,vr_nrcnvcob   -- nrcnvcob 
                             ,vr_nrdocmto   -- nrdocmto 
                             ,'Titulo enviado a CIP'||vr_dscmplog   -- dslogtit 
                             ,'1'                      -- cdoperad 
                             ,TRUNC(SYSDATE)           -- dtaltera 
                             ,GENE0002.fn_busca_time); -- hrtransa 
        EXCEPTION 
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao gerar Log do boleto: '||SQLERRM;
            RETURN;
        END;
        
        
            
      END IF; /* fim - return_value */       
          
      vr_index := pr_tab_remessa_dda.NEXT(vr_index);      
    END LOOP;
        
  EXCEPTION 
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel atualizar crapcob status DDA: '||SQLERRM;  
       
  END pc_atualiza_status_envio_dda;  
  
  --> Rotina para controlar geração da carga inicial do NPC
  PROCEDURE pc_carga_inic_npc(pr_cdcooper IN crapcop.cdcooper%TYPE,
                              pr_cdbcoctl IN crapcop.cdbcoctl%TYPE,      
                              pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE,
                              pr_cdagectl   IN crapcop.cdagectl%TYPE,
                              pr_dscritic  OUT VARCHAR2) IS
  
    vr_dstextab     craptab.dstextab%TYPE;  
    vr_tab_campos   gene0002.typ_split;  
    vr_dscritic     VARCHAR2(4000);
  
  
  BEGIN
  
    --> Buscar dados
    vr_dstextab := TABE0001.fn_busca_dstextab
                                     (pr_cdcooper => pr_cdcooper
                                     ,pr_nmsistem => 'CRED'
                                     ,pr_tptabela => 'GENERI'
                                     ,pr_cdempres => 0
                                     ,pr_cdacesso => 'ROLLOUT_CIP_CARGA_INIC'
                                     ,pr_tpregist => 0); 
      
    vr_tab_campos:= gene0002.fn_quebra_string(vr_dstextab,';');
    
    IF vr_tab_campos.count > 0 THEN
    --> Verificar se esta no dia da cargar inicial da faixa de rollout
    --> e se ainda nao rodou a carga
    IF to_date(vr_tab_campos(2),'DD/MM/RRRR') = pr_rw_crapdat.dtmvtolt AND 
       vr_tab_campos(1) = 0 THEN
       
      vr_tb_remessa_dda.DELETE();
      vr_tb_retorno_dda.DELETE(); 
       
      -- Buscar titulos que atendem a regra de rollout da carga inicial
      FOR rw_titulos IN cr_titulos_carga(pr_cdcooper => pr_cdcooper
                                        ,pr_cdbcoctl => pr_cdbcoctl
                                        ,pr_vlrollou => vr_tab_campos(3)
                                        ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt) LOOP        

        -- Tratamento para nao enviar para a cabine pois a cabine existe essa limitaçao de valor 
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


          -- Rotina para criação de titulo
          pc_cria_titulo(pr_rw_titulos => rw_titulos 
                        ,pr_crapdat    => pr_rw_crapdat
                        ,pr_cdagectl   => pr_cdagectl
                        ,pr_tpdenvio   => vr_tpdenvio
                        ,pr_des_erro   => vr_des_erro
                        ,pr_dscritic   => vr_dscritic);
                        
          IF vr_des_erro <> 'OK' THEN
          RAISE vr_exc_saida;
        END IF;                        
                                          
                                            
      END LOOP;  
      
      -- Realizar a remessa de títulos DDA
      DDDA0001.pc_remessa_tit_tab_dda(pr_tab_remessa_dda => vr_tb_remessa_dda
                                     ,pr_tab_retorno_dda => vr_tb_retorno_dda
                                     ,pr_cdcritic        => vr_cdcritic
                                     ,pr_dscritic        => vr_dscritic);
      
      -- Verificar se ocorreu erro
        IF trim(vr_dscritic) IS NOT NULL THEN
        pr_dscritic := 'Erro na rotina PC_REMESSA_TITULOS_DDA[carga NPC]: '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      
        -- Atualizar status da remessa de títulos DDA      
        pc_atualiza_status_envio_dda(pr_tab_remessa_dda => vr_tb_remessa_dda
                                    ,pr_tpdenvio        => 2
                                    ,pr_cdcritic        => vr_cdcritic
                                    ,pr_dscritic        => vr_dscritic);
                                    
        -- Verificar se ocorreu erro
        IF trim(vr_dscritic) IS NOT NULL THEN
          pr_dscritic := 'Erro na rotina PC_ATUALIZA_STATUS_ENVIO_DDA[carga NPC]: '||vr_dscritic;
          RAISE vr_exc_saida;
        END IF;                                  
              
      --> Atualizar tab para informar que ja gerou dados da carga
      BEGIN
        UPDATE craptab tab
           SET tab.dstextab = '1'||SUBSTR(tab.dstextab,2)
         WHERE cdcooper        = pr_cdcooper 
           AND upper(nmsistem) = 'CRED'
           AND upper(tptabela) = 'GENERI'
           AND cdempres        = 0
           AND upper(cdacesso) = 'ROLLOUT_CIP_CARGA_INIC'
           AND tpregist        = 0; 
        
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tab ROLLOUT_CIP_CARGA_INIC: '|| SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- limpar temptables
      vr_tb_remessa_dda.DELETE();
      vr_tb_retorno_dda.DELETE(); 
      
      --> commitar carga
      COMMIT;       
      END IF;     
       
    END IF;
    
  EXCEPTION 
    WHEN vr_exc_saida THEN
      
      -- limpar temptables
      vr_tb_remessa_dda.DELETE();
      vr_tb_retorno_dda.DELETE();       
      
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN

      -- limpar temptables
      vr_tb_remessa_dda.DELETE();
      vr_tb_retorno_dda.DELETE(); 
      
      pr_dscritic := 'Não foi possivel gerar carga inicial: '||SQLERRM;
  END pc_carga_inic_npc;
  
  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    vr_dscritic_aux VARCHAR2(4000);
  BEGIN
  
    --> Apenas gerar log se for processo batch/job ou erro  
    IF nvl(pr_nrdconta,0) = 0 OR  pr_dstiplog = 'E' THEN
    
      vr_dscritic_aux := pr_dscritic;
      
      --> Se é erro e possui conta, concatenar o numero da conta no erro
      IF pr_nrdconta <> 0 THEN
        vr_dscritic_aux := vr_dscritic_aux||' - Conta: '||pr_nrdconta;
      END IF;
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_cdprogra    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => vr_dscritic_aux    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  
    END IF;
  END pc_controla_log_batch;
  
  /**********************************************************/
   
BEGIN
  
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_'||UPPER(vr_cdprogra),
                             pr_action => vr_cdprogra);
     
  
  -- Limpar a tabela de memória
  vr_tb_crapban.DELETE();
  
  -- Carregar o registros de bancos
  FOR rw_crapban IN cr_crapban LOOP
    -- Incluir o registro do banco na tabela de memória
    vr_tb_crapban(rw_crapban.cdbccxlt) := rw_crapban;
  END LOOP;
  
  -- Percorrer as cooperativas
  FOR rw_crapcop IN cr_crapcop LOOP
  
    /* Busca data do sistema */ 
    OPEN  BTCH0001.cr_crapdat(rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
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
    
    --> se ainda estiver rodando o processo batch
    -- nao deve rodar o programa
    IF rw_crapdat.inproces <> 1 THEN
      continue;
    END IF;
    
    -- Log de início da execução
    pc_controla_log_batch(pr_cdcooper  => rw_crapcop.cdcooper,
                          pr_dstiplog  => 'I');
    
    --> variavel apenas para controle do log, caso seja abortado o programa
    vr_cdcooper := rw_crapcop.cdcooper;
    
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
    
    
    --> Marcar processo como chamada online
    --tipo de envio(0-normal/batch, 1-online,2-carga inicial)
    vr_tpdenvio := 0;
    
    IF pr_nrdconta > 0 THEN
      vr_tpdenvio := 1;
    END IF;
    
    IF vr_tpdenvio = 0 THEN
      --> Controlar geração da carga inicial do NPC
      pc_carga_inic_npc(pr_cdcooper   => rw_crapcop.cdcooper,
                        pr_cdbcoctl   => rw_crapcop.cdbcoctl,      
                        pr_rw_crapdat => rw_crapdat,
                        pr_cdagectl   => rw_crapcop.cdagectl,
                        pr_dscritic   => vr_dscritic);

      -- Verifica se ocorreu erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;

    -- Limpar registros de memória
    vr_tb_remessa_dda.DELETE();
    vr_tb_retorno_dda.DELETE();
    
    -- Rotina para registrar os títulos na CIP
    FOR rw_titulos IN cr_titulos(pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
      
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

      -- Se titulo Cooperativa/EE e nao foi enviado ainda para a PG, nao enviar ao DDA 
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
      
      --> Verificar rollout da plataforma de cobrança
      IF 1 = NPCB0001.fn_verifica_rollout 
                                 ( pr_cdcooper     => rw_titulos.cdcooper, --> Codigo da cooperativa
                                   pr_dtmvtolt     => rw_crapdat.dtmvtolt, --> Data de movimento
                                   pr_vltitulo     => rw_titulos.vltitulo, --> Valor do titulo
                                   pr_tpdregra     => 1)    THEN           --> Tipo de regra de rollout(1-registro,2-pagamento)      
        vr_insitpro := 2;
      END IF;

      -- Se sacado for DDA, entao titulo eh DDA 
      IF vr_insitpro = 2 THEN
      
        -- Rotina para criação de titulo
        pc_cria_titulo(pr_rw_titulos => rw_titulos 
                      ,pr_crapdat    => rw_crapdat
                      ,pr_cdagectl   => rw_crapcop.cdagectl
                      ,pr_tpdenvio   => vr_tpdenvio
                      ,pr_des_erro   => vr_des_erro
                      ,pr_dscritic   => vr_dscritic);
                                
        IF vr_des_erro <> 'OK' THEN
            RAISE vr_exc_saida;
        END IF;         
      
      ELSE
        -- Atualizar CRAPCOB 
        BEGIN
          UPDATE crapcob
             SET flgcbdda = 0 -- FALSE
               , insitpro = 0
               , inenvcip = 0 -- não enviar
               , dhenvcip = null
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
    IF trim(vr_dscritic) IS NOT NULL THEN
      pr_dscritic := 'Erro na rotina PC_REMESSA_TITULOS_DDA: '||vr_dscritic;
      RAISE vr_exc_saida;
    END IF;
    
    -- Atualizar status da remessa de títulos DDA      
    pc_atualiza_status_envio_dda(pr_tab_remessa_dda => vr_tb_remessa_dda
                                ,pr_tpdenvio        => vr_tpdenvio
                                ,pr_cdcritic        => vr_cdcritic
                                ,pr_dscritic        => vr_dscritic);
                                  
    -- Verificar se ocorreu erro
    IF trim(vr_dscritic) IS NOT NULL THEN
      pr_dscritic := 'Erro na rotina PC_ATUALIZA_STATUS_ENVIO_DDA: '||vr_dscritic;
      RAISE vr_exc_saida;
    END IF;                                      
    
    -- Rotina para buscar o "OK" da CIP
    vr_tb_remessa_dda.DELETE();
    vr_tb_retorno_dda.DELETE();
    
    -- crps618 só deverá buscar o OK da CIP, quando for executado em modo batch    
    -- se o pr_nrdconta > 0, crps618 foi chamado pelo registro de boletos online
    -- pela b1wnet0001 (IB)
    IF nvl(pr_nrdconta,0) = 0 THEN
    
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
    
    END IF; -- NVL(pr_nrdconta,0) = 0
    
    -- Log de início da execução
    pc_controla_log_batch(pr_cdcooper  => rw_crapcop.cdcooper,
                          pr_dstiplog  => 'F');
    
                                                  
    --> Gravar dados a cada cooperativa
    COMMIT;
  END LOOP; -- Fim loop cooperativas
  
  --> Se nao for ONLINE
  IF nvl(pr_nrdconta,0) = 0 THEN
  
    -- Log de início da execução
    pc_controla_log_batch(pr_cdcooper  => pr_cdcooper,
                          pr_dstiplog  => 'I');
    vr_cdcooper := pr_cdcooper;
                          
    --> Buscar retorno operacao Titulos NPC
    DDDA0001.pc_retorno_operacao_tit_NPC(pr_cdcritic => vr_cdcritic  --Codigo de Erro
                                        ,pr_dscritic => vr_dscritic); --Descricao de Erro
    
    -- Verifica se ocorreu erro
    IF NVL(vr_cdcritic,0) > 0 OR 
       vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
       
    -- Log de início da execução
    pc_controla_log_batch(pr_cdcooper  => pr_cdcooper,
                          pr_dstiplog  => 'F');
    
  END IF;  
  
EXCEPTION
  WHEN vr_exc_saida THEN
    
    -- Rotina para buscar o "OK" da CIP
    vr_tb_remessa_dda.DELETE();
    vr_tb_retorno_dda.DELETE();
  
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    
    -- Log de erro início da execução
    pc_controla_log_batch(pr_cdcooper  => vr_cdcooper,
                          pr_dstiplog  => 'F',
                          pr_dscritic  => pr_dscritic);
    
    
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    
    -- Rotina para buscar o "OK" da CIP
    vr_tb_remessa_dda.DELETE();
    vr_tb_retorno_dda.DELETE();
  
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    
    -- Log de erro início da execução
    pc_controla_log_batch(pr_cdcooper  => vr_cdcooper,
                          pr_dstiplog  => 'F',
                          pr_dscritic  => pr_dscritic);
    
    -- Efetuar rollback
    ROLLBACK;
END pc_crps618;
/
