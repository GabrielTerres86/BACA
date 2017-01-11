CREATE OR REPLACE PROCEDURE CECRED.pc_crps638(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

/*..............................................................................

    Programa: fontes/crps638.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Lunelli
    Data    : Fevereiro/2013                  Ultima Atualizacao : 06/10/2016

    Dados referente ao programa:

    Frequencia : Diario (Batch).
    Objetivo   : Convenios Sicredi - Relatório de Conciliaçao.
                 Chamado Softdesk 43337.

    Alteracoes : 06/05/2013 - Alteraçao para rodar em cada cooperativa (Lucas).

                 24/05/2013 - Tratamento DARFs (Lucas).

                 03/06/2013 - Correçao format vlrs totais (Lucas).

                 11/06/2013 - Somatória de multas e juros ao campo de
                              valor da fatura e melhorias em consultas
                              (Lucas).

                 14/06/2013 - Correçao listagem DARF SIMPLES (Lucas).

                 19/06/2013 - Quebra de listagem de convenios por segmto (Lucas).

                 24/06/2013 - Rel.636 Totalizaçao por Cooperativa (Lucas).

                 15/08/2013 - Incluir procedure tt-totais para totalizar por
                              convenios e ordenar pela quantidade total maior
                              para menor no rel636 (Lucas R.).

                 23/04/2014 - Alterar campo.crapscn.nrdiaflt por dsdianor
                              Softdesk 142529 (Lucas R.)

                 24/04/2014 - Inclusao de FIELDS para os for craplft e crapcop
                              (Lucas R.)

                 28/04/2014 - Inclusao de deb. automatico para os relatorios
                              crrl634,crrl635,crrl636 Softdesk 149911 (Lucas R.)

                 05/05/2014 - Ajustes migracao Oracle (Elton).

                 17/06/2014 - 135941 Correcao de quebra de pagina e inclusao do
                              campo vltardrf nos fields da crapcop, procedure
                              gera-rel-mensal-cecred (Carlos)

                 06/08/2014 - Ajustes de paginacao e espacamentos no relatorio
                              crrl636, nos totais de DEBITO AUTOMATICO e
                              TOTAL POR MEIO DE ARRECADACAO (Carlos)

                 29/12/2014 - #232620 Correcao na busca dos convenios que nao
                              sao de debito automatico com a inclusao da clausula
                              crapscn.dsoparre <> "E" (Carlos)

                 06/01/2015 - #232620 Correcao do totalizador de receita liquida
                              da cooperativa para deb automatico e totalizadores
                              gerais do relatorio 636 (Carlos)

                 24/02/2015 - Correçao na alimentaçao do campo 'tt-rel634.vltrfuni'
                              (Lunelli - SD 249805)

                30/04/2015 - Proj. 186 -> Segregacao receita e tarifa em PF e PJ
                             Criacao do novo arquivo AAMMDD_CONVEN_SIC.txt
                             (Guilherme/SUPERO)

                26/06/2015 - Incluir Format com negativo nos FORMs do rel634 no
                             campo vlrecliq (Lucas Ranghetti #299004)

                06/07/2015 - Alterar calculo no meio de arrecadacao CAIXA no
                             acumulativo do campo tt-rel634.vlrecliq, pois estava
                             calculando a tarifa errada. (Lucas Ranghetti #302607)

                21/09/2015 - Incluindo calculo de pagamentos GPS.
                             (André Santos - SUPERO)

                04/12/2015 - Retirar trecho do codigo onde faz a reversao
                             (Lucas Ranghetti #326987 )

                11/12/2015 - Adicionar sinal negativo nos campos tot_vlrliqpj e
                            vr_deb_vlrliqpj crrl635 (Lucas Ranghetti #371573 )

                06/01/2016 - Retirado o valor referente a taxa de GPS do cabecalho
                             do arquivo que vai para o radar. (Lombardi #378512)

                19/05/2016 - Adicionado negativo no format do f_totais_rel635
                             (Lucas Ranghetti #447067)

                06/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP
                             (Guilherme/SUPERO)
..............................................................................*/

  
  ------------------------------- VARIAVEIS -------------------------------
  
  -- Data de movimento e mês de referencia
  vr_dtmvtolt     DATE;
  vr_nrmesref     NUMBER;
  vr_dsmesref     VARCHAR2(40);
  -- Diretório para geração do relatóriio
  vr_nom_direto   VARCHAR2(100);
  -- Variável para armazenar as informações em XML
  vr_des_xml      CLOB;
  vr_texto_completo varchar2(2000);
  vr_caminho_integra VARCHAR2(1000);
  -- Rolbacks para erros, ignorar o resto do processo e rollback
  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);
  --Variáveis locais
  vr_contador number;
  indice      varchar2(200);

  -- Para relatorio 634 
  TYPE tt_rel634 IS
    RECORD (nmconven VARCHAR2(100),
            qttotgps NUMBER,
            vltotgps NUMBER(15,2),
            qttotfat NUMBER,
            vltotfat NUMBER(15,2),
            vlrecliq NUMBER(15,2),
            vltrfsic NUMBER(15,2),
            vltrfuni NUMBER(15,2),
            dsdianor crapscn.dsdianor%TYPE,
            dsmeiarr VARCHAR2(100),
            cdempres VARCHAR2(100),
            tpmeiarr char(1),
            nrrenorm crapscn.nrrenorm%TYPE);
  -- Definicao do tipo de tabela que armazena
  -- registros do tipo acima detalhado
  TYPE tt_tab_rel634 IS
    TABLE OF tt_rel634
    INDEX BY VARCHAR2(10);
  -- Vetores para armazenar as informacoes de moedas
    vr_tab_rel634 tt_tab_rel634;
    vr_ind_rel634 varchar(200);
 -- Para relatorio 635 
  TYPE tt_rel635 IS
    RECORD (cdempres varchar2(10),
            tpmeiarr char(1),
            nmconven varchar2(100),
            dsmeiarr varchar2(100),
            inpessoa number,
            qtfatura number,
            vltotfat number(15,2),
            vlrecliq number(15,2),
            vlrliqpf number(15,2), -- Divisao PF/PJ
            vlrliqpj number(15,2), -- Divisao PF/PJ
            vltottar number(15,2),
            vltrfsic number(15,2),
            vlrtrfpf number(15,2),-- Divisao PF/PJ
            vlrtrfpj number(15,2),-- Divisao PF/PJ
            dsdianor crapscn.dsdianor%TYPE,
            nrrenorm crapscn.nrrenorm%TYPE);
  -- Definicao do tipo de tabela que armazena
  -- registros do tipo acima detalhado
  TYPE tt_tab_rel635 IS
    TABLE OF tt_rel635
    INDEX BY VARCHAR2(10);
  -- Vetores para armazenar as informacoes de moedas
    vr_tab_rel635 tt_tab_rel635;
  
  TYPE vr_vltrpapf IS VARRAY(999) OF INTEGER; -- define o tipo do vetor  
  TYPE vr_vltrpapj IS VARRAY(999) OF INTEGER; -- define o tipo do vetor  
  -- Vetores Relatorios
  vr_relvltrpapf vr_vltrpapf;
  vr_relvltrpapj vr_vltrpapj;
 -- Para relatorio 636 TOTAIS
  TYPE tt_totais IS
    RECORD (cdempres varchar2(100),
            tpmeiarr char(1),
            dsmeiarr varchar2(100),
            nmconven varchar2(100),
            qtfatura number,
            vltotfat number(15,2),
            vltottar number(15,2),
            vltrfsic NUMBER(15,2),            
            vlrecliq number(15,2));
  -- Definicao do tipo de tabela que armazena
  -- registros do tipo acima detalhado
  TYPE tt_tab_totais IS
    TABLE OF tt_totais
    INDEX BY VARCHAR2(10);
  -- Vetores para armazenar as informacoes de moedas
    vr_tab_totais tt_tab_totais;
-- Para relatorio 636
  TYPE tt_rel636 IS
    RECORD (cdcooper number,
            cdempres varchar2(100),
            tpmeiarr char(1),
            nmrescop crapcop.nmrescop%type,
            nmconven varchar2(100),
            dsmeiarr varchar2(100),
            qtfatura number,
            vltotfat number(15,2),
            vlrecliq number(15,2),
            vltottar number(15,2),
            vltrfsic number(15,2),
            dsdianor crapscn.dsdianor%type,
            nrrenorm crapscn.nrrenorm%type);
  -- Definicao do tipo de tabela que armazena
  -- registros do tipo acima detalhado
  TYPE tt_tab_rel636 IS
    TABLE OF tt_rel636
    INDEX BY VARCHAR2(10);
  -- Vetores para armazenar as informacoes de moedas
    vr_tab_rel636 tt_tab_rel636;
    
    vr_aux_datainic DATE;
    vr_aux_datafina DATE;
    vr_aux_dtmvtolt DATE;
    vr_aux_dtvencto DATE;
    vr_aux_cdcooper NUMBER;
    vr_aux_vltarfat NUMBER(15,2);
    vr_darf         varchar2(2);

    
    
    

    -- Acumuladores 
    vr_tot_qttotfat NUMBER;
    vr_tot_vltrfuni number(15,2);
    vr_tot_vltotfat number(15,2);
    vr_tot_vlrecliq number(15,2);
    vr_tot_vlrtrfpf number(15,2);
    vr_tot_vlrtrfpj number(15,2); 
    vr_tot_trfgpspf number(15,2); 
    vr_tot_trfgpspj number(15,2); 
    vr_tot_vltrfsic number(15,2); 
    
    -- TOTAIS INTERNET 
    vr_int_qttotfat NUMBER;
    vr_int_vltotfat number(15,2);
    vr_int_vlrecliq number(15,2);
    vr_int_vltrfuni number(15,2);
    vr_int_vltrfsic number(15,2);
    -- Divisao PF/PJ
    vr_int_vlrliqpf number(15,2);
    vr_int_vlrliqpj number(15,2);
    vr_int_vlrtrfpf number(15,2);
    vr_int_vlrtrfpj number(15,2);

    -- TOTAIS CAIXA 
    vr_cax_qttotfat NUMBER;
    vr_cax_vltotfat number(15,2);
    vr_cax_vlrecliq number(15,2);
    vr_cax_vltrfuni number(15,2);
    vr_cax_vltrfsic number(15,2);
    -- Divisao PF/PJ
    vr_cax_vlrliqpf number(15,2);
    vr_cax_vlrliqpj number(15,2);
    vr_cax_vlrtrfpf number(15,2);
    vr_cax_vlrtrfpj number(15,2);

    -- TOTAIS TAA 
    vr_taa_qttotfat NUMBER;
    vr_taa_vltotfat number(15,2);
    vr_taa_vlrecliq number(15,2);
    vr_taa_vltrfuni number(15,2);
    vr_taa_vltrfsic number(15,2);
    -- Divisao PF/PJ
    vr_taa_vlrliqpf number(15,2);
    vr_taa_vlrliqpj number(15,2);
    vr_taa_vlrtrfpf number(15,2);
    vr_taa_vlrtrfpj number(15,2);

    -- TOTAIS DEB AUTOMATICO 
    vr_deb_qttotfat NUMBER;
    vr_deb_vltotfat number(15,2);
    vr_deb_vlrecliq number(15,2);
    vr_deb_vltrfuni number(15,2);
    vr_deb_vltrfsic number(15,2);
    -- Divisao PF/PJ
    vr_deb_vlrliqpf number(15,2);
    vr_deb_vlrliqpj number(15,2);
    vr_deb_vlrtrfpf number(15,2);
    vr_deb_vlrtrfpj number(15,2);

    -- INTERNET 
    vr_tot_qtfatint NUMBER;
    vr_tot_vlfatint number(15,2);
    -- TAA 
    vr_tot_qtfattaa NUMBER;
    vr_tot_vlfattaa number(15,2);
    -- CAIXA 
    vr_tot_qtfatcxa NUMBER;
    vr_tot_vlfatcxa number(15,2);
    -- DEB AUTO 
    vr_tot_qtfatdeb NUMBER;
    vr_tot_vlfatdeb number(15,2);
    vr_aux_vltarifa number(15,2);
    -- SICREDI - GPS 
    vr_tot_qtgpsdeb NUMBER;
    vr_tot_vlgpsdeb number(15,2);
    vr_aux_vltfcxcb number(15,2);
    vr_aux_vltfcxsb number(15,2);
    vr_aux_vlrtrfib number(15,2);
    vr_aux_vltargps number(15,2);
    vr_aux_dsempgps VARCHAR2(100);
    vr_aux_dsnomcnv VARCHAR2(100);
    vr_aux_tpmeiarr CHAR(1);
    vr_aux_dsmeiarr VARCHAR2(100);
    
    vr_aux_inpessoa NUMBER;
    vr_aux_nmarqint VARCHAR2(21);

    -- Para arquivo 
    vr_aux_nmarqimp VARCHAR2(21);
    vr_aux_nomedarq VARCHAR2(21);
    vr_aux_dscooper VARCHAR2(21);
    vr_aux_nmarqrel VARCHAR2(21);

    -- variaveis para includes/cabrel132_X.i 
    vr_rel_nmresemp VARCHAR2(15);
    vr_rel_nmrelato VARCHAR2(40);
    vr_rel_nrmodulo NUMBER(9);
    vr_rel_nmempres VARCHAR2(15);
    vr_rel_nmmodulo VARCHAR2(15);
    
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS638';

  ---------------------------------- CURSORES  ----------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop, cop.vltardrf
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  
  CURSOR cr_crapthi(pr_cdcooper crapthi.Cdcooper%type,
                    pr_cdhistor crapthi.cdhistor%type)is
    
    select crapthi.cdcooper,crapthi.vltarifa from crapthi 
           WHERE crapthi.cdcooper = pr_cdcooper    AND
                 crapthi.cdhistor = pr_cdhistor    AND -- SICREDI 
                 crapthi.dsorigem = 'AYLLOS';
            
    rw_crapthi cr_crapthi%ROWtype;
    
  CURSOR cr_crapthi1(pr_cdcooper crapthi.CDCOOPER%type)is
    select crapthi.cdcooper from crapthi 
           WHERE crapthi.cdcooper = pr_cdcooper AND
                 crapthi.cdhistor = 1019        AND -- SICREDI 
                 crapthi.dsorigem = 'AYLLOS';
    rw_crapthi1 cr_crapthi1%rowtype;
   
  cursor cr_craplft(pr_cdcooper crapcop.cdcooper%type,
                    pr_dtmvtolt craplft.dtvencto%type) is                                                
        SELECT cdtribut,
               cdempcon,
               cdsegmto,
               tpfatura,
               vllanmto,
               vlrmulta,
               vlrjuros,
               cdagenci FROM craplft
               WHERE
                 craplft.cdcooper  = pr_cdcooper  AND
                 craplft.dtvencto  = pr_dtmvtolt  AND 
                 craplft.insitfat  = 2            AND
                 craplft.cdhistor  = 1154;  -- SICREDI 
    
    cursor cr_crapscn(pr_cdempcon crapscn.cdempcon%type,
                      pr_cdsegmto crapscn.cdsegmto%type) is            
      select crapscn.cdempres, 
             crapscn.dsnomcnv,
             crapscn.dsdianor,
             crapscn.nrrenorm from crapscn 
        WHERE crapscn.cdempcon = pr_cdempcon AND
              crapscn.cdsegmto = pr_cdsegmto AND
              crapscn.dtencemp is null       AND
              crapscn.dsoparre <> 'E';

    rw_crapscn cr_crapscn%rowtype;

    cursor cr_crapstn(pr_cdempres crapstn.cdempres%type,
                      pr_tpmeiarr crapstn.tpmeiarr%type) is
     select crapstn.tpmeiarr, 
            crapstn.vltrfbru,
            crapstn.vltrfuni, 
            crapstn.vltarifa from crapstn 
       where crapstn.cdempres = pr_cdempres
          and ((crapstn.tpmeiarr = pr_tpmeiarr)
              or ( pr_tpmeiarr = null));

    rw_crapstn  cr_crapstn%rowtype;        
     
    cursor cr_craplcm(pr_cdcooper craplcm.cdcooper%type,
                      pr_dtmvtolt craplcm.dtmvtolt%type) is  
      select cdcooper,
             cdhistor,
             nrdocmto,
             nrdconta,
             cdagenci,
             dtmvtolt,
             nrdolote,
             vllanmto
             from craplcm
                 WHERE craplcm.cdcooper = pr_cdcooper AND
                       craplcm.cdhistor = 1019        AND
                       craplcm.dtmvtolt = pr_dtmvtolt;
      
    cursor cr_craplau(pr_cdcooper  craplau.cdcooper%type,
                      pr_cdhistor  craplau.cdhistor%type,
                      pr_nrdocmto  craplau.nrdocmto%type,
                      pr_nrdconta  craplau.nrdconta%type,
                      pr_cdagenci  craplau.cdagenci%type,
                      pr_dtmvtolt  craplau.dtmvtopg%type)is
      select rowid,
             cdempres 
             from craplau 
                 WHERE craplau.cdcooper = pr_cdcooper AND
                       craplau.cdhistor = pr_cdhistor AND
                       craplau.nrdocmto = pr_nrdocmto AND
                       craplau.nrdconta = pr_nrdconta AND
                       craplau.cdagenci = pr_cdagenci AND
                       craplau.dtmvtopg = pr_dtmvtolt;

      rw_craplau cr_craplau%rowtype;                
                       
      cursor cr_crapscn1(pr_cdempres crapscn.cdempres%type)is
      select * from crapscn
      where crapscn.cdempres = pr_cdempres;

     cursor cr_crapscn2(pr_cdempres crapscn.cdempres%type)is 
       select * from  crapscn WHERE crapscn.dsoparre = 'E'       AND
                            (crapscn.cddmoden = 'A'                OR
                             crapscn.cddmoden = 'C')               AND
                             crapscn.cdempres = pr_cdempres;
      rw_crapscn2 cr_crapscn2%rowtype;
      
      cursor cr_craptab(pr_cdcooper craptab.cdcooper%type,
                        pr_acesso   craptab.cdacesso%type)is
      
       select craptab.nmsistem,
              craptab.tptabela,
              craptab.cdempres,
              craptab.cdacesso,
              craptab.dstextab from craptab 
         WHERE craptab.cdcooper = pr_cdcooper
           AND craptab.nmsistem = 'CRED'
           AND craptab.tptabela = 'GENERI'
           AND craptab.cdempres = 00
           AND craptab.cdacesso = pr_acesso
           AND craptab.tpregist = 0 ;

      rw_craptab cr_craptab%rowtype; 
      cursor cr_craplgp(pr_cdcooper craplgp.cdcooper%type,
                        pr_dtmvtolt craplgp.dtmvtolt%type) is
         select * from  craplgp
           WHERE craplgp.cdcooper = pr_cdcooper
            AND craplgp.dtmvtolt = pr_dtmvtolt 
            AND craplgp.idsicred <> 0
            AND craplgp.flgativo = 1;
       
      cursor cr_craplgp1(pr_dtmvtolt craplgp.dtmvtolt%type) is
         select * from  craplgp
           WHERE craplgp.cdcooper <> 3
             AND craplgp.dtmvtolt = pr_dtmvtolt
             AND craplgp.idsicred <> 0
             AND craplgp.flgativo = 1;
      
    
  ------------------------------- REGISTROS -------------------------------
    rw_crapcop cr_crapcop%ROWTYPE;
     -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  ------------------------- PROCEDIMENTOS INTERNOS -----------------------------
  -- Escrever no arquivo CLOB
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
  BEGIN
    --Escrever no arquivo XML
    dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
  END;
  PROCEDURE  pc_gera_rel_mensal_cecred is

    -- Pega primeiro e último dia do mes 
   cursor cr_crapcop is 
        select 
            cdcooper 
           ,nmrescop 
           ,vltardrf 
           ,vltarcrs from crapcop;
           
   cursor cr_craplft(pr_cdcooper crapcop.cdcooper%type,
                    pr_dtmvtolt craplft.dtvencto%type) is                                                
        SELECT cdtribut,
               cdempcon,
               cdsegmto,
               tpfatura,
               vllanmto,
               vlrmulta,
               vlrjuros,
               cdagenci FROM craplft
               WHERE
                 craplft.cdcooper  = pr_cdcooper  AND
                 craplft.dtvencto  = pr_dtmvtolt  AND 
                 craplft.insitfat  = 2            AND
                 craplft.cdhistor  = 1154;  -- SICREDI 
   -- Tributos Sicredi
   cursor cr_crapscn(pr_cdempcon crapscn.cdempcon%type,
                     pr_cdsegmto craplft.cdsegmto%type)is 
     select 
        crapscn.cdempres,
        crapscn.dsnomcnv,
        crapscn.dsdianor,
        crapscn.nrrenorm
      from crapscn 
      WHERE (crapscn.cdempcon  = pr_cdempcon           or
             crapscn.cdempco2 = pr_cdempcon)          AND
             crapscn.cdsegmto = to_char(pr_cdsegmto)   AND
             crapscn.dtencemp is null                  AND
             crapscn.dsoparre <> 'E';    -- Debaut 
   rw_crapscn cr_crapscn%rowtype;               
   
   CURSOR cr_crapstn(pr_cdempres crapstn.cdempres%type,
                     pr_tpmeiarr crapstn.tpmeiarr%type ) is 
       select * from crapstn 
        WHERE crapstn.cdempres = pr_cdempres           
        and ((crapstn.tpmeiarr = pr_tpmeiarr)
              or ( pr_tpmeiarr = null));
   rw_crapstn cr_crapstn%rowtype;         


    cursor cr_craplcm(pr_cdcooper     craplcm.cdcooper%type,
                      pr_hist         craplcm.cdhistor%type,
                      pr_aux_dtvencto craplcm.dtmvtolt%type)is 
    select cdcooper, 
           cdhistor,
           nrdocmto,
           nrdconta,
           cdagenci,
           dtmvtolt,
           nrdolote,
           vllanmto from craplcm
           WHERE craplcm.cdcooper = pr_cdcooper AND
                 craplcm.cdhistor = pr_hist     AND
                 craplcm.dtmvtolt = pr_aux_dtvencto;
    rw_craplcm cr_craplcm%rowtype;     
 
   cursor  cr_craplau(pr_cdcooper  craplau.cdcooper%type,
                      pr_cdhistor  craplau.cdhistor%type,
                      pr_nrdocmto  craplau.nrdocmto%type,
                      pr_nrdconta  craplau.nrdconta%type,
                      pr_cdagenci  craplau.cdagenci%type,
                      pr_dtmvtolt  craplau.dtmvtopg%type) is 
              select rowid,
                     cdempres 
	              from  craplau WHERE  craplau.cdcooper = pr_cdcooper AND
                                   craplau.cdhistor = pr_cdhistor AND
                                   craplau.nrdocmto = pr_nrdocmto AND
                                   craplau.nrdconta = pr_nrdconta AND
                                   craplau.cdagenci = pr_cdagenci AND
                                   craplau.dtmvtopg = pr_dtmvtolt;
   
   cursor cr_crapscn1(pr_cdempresa crapscn.cdempres%type,
                      pr_dsoparre  crapscn.dsoparre%type,
                      pr_cddmoden  crapscn.cddmoden%type,
                      pr_cddmoden1 crapscn.cddmoden%type
                                             )is
      select * from crapscn
         where crapscn.cdempres = pr_cdempresa
           and ((crapscn.dsoparre = pr_dsoparre)
           or  (pr_dsoparre      = null)) 
           AND ((crapscn.cddmoden = pr_cddmoden OR
                 crapscn.cddmoden = pr_cddmoden1)
            or  (pr_cddmoden = null));
                                               
     rw_crapscn1 cr_crapscn1%rowtype;   
   
   CURSOR cr_crapthi(pr_cdcooper crapthi.Cdcooper%type,
                     pr_cdhistor crapthi.cdhistor%type)is
    
    select crapthi.cdcooper,crapthi.vltarifa from crapthi 
           WHERE crapthi.cdcooper = pr_cdcooper    AND
                 ((crapthi.cdhistor = pr_cdhistor )  or -- SICREDI 
                  (pr_cdhistor      = Null        )) AND
                 crapthi.dsorigem = 'AYLLOS';
  
  cursor cr_craptab(pr_cdcooper craptab.cdcooper%type,
                    pr_acesso   craptab.cdacesso%type)is
      
       select craptab.nmsistem,
              craptab.tptabela,
              craptab.cdempres,
              craptab.cdacesso,
              craptab.dstextab from craptab 
         WHERE craptab.cdcooper = pr_cdcooper
           AND craptab.nmsistem = 'CRED'
           AND craptab.tptabela = 'GENERI'
           AND craptab.cdempres = 00
           AND craptab.cdacesso = pr_acesso
           AND craptab.tpregist = 0 ;

      rw_craptab cr_craptab%rowtype; 
     
   cursor cr_craplgp(pr_cdcooper craplgp.cdcooper%type,
                     pr_dtmvtolt craplgp.dtmvtolt%type) is
         select * from  craplgp
           WHERE craplgp.cdcooper = pr_cdcooper
            AND craplgp.dtmvtolt  = pr_dtmvtolt 
            AND craplgp.idsicred <> 0;  
             
  
   pr_aux_datafina date;
   pr_aux_datainic date;
   pr_aux_dtmvtolt date;
   pr_aux_dtvencto date;
   vr_darf         varchar2(2);
   vr_ind_rel636   varchar2(200);
   vr_ind_rel634   varchar2(200);
   vr_ind_reltot   varchar2(200);   
   begin
      pr_aux_dtmvtolt := rw_crapdat.dtmvtolt; 
      pr_aux_datafina := last_day(rw_crapdat.dtmvtolt);
      pr_aux_datainic := last_day(add_months(rw_crapdat.dtmvtolt,-1)) + 1;
      
      -- Percorre todos os dias
      while pr_aux_datainic <= pr_aux_datafina loop
            pr_aux_dtvencto := pr_aux_datainic;
        -- Leitura para Convios e DARFs para cada cooperativa 
        for rw_crapcop in cr_crapcop loop
            -- Busca dados da Faturas
            for rw_craplft in cr_craplft(pr_cdcooper,pr_aux_dtvencto) loop
                --Zerar totais
                vr_tot_qtfatint := 0;
                vr_tot_vlfatint := 0;
                vr_tot_qtfattaa := 0;
                vr_tot_vlfattaa := 0;
                vr_tot_qtfatcxa := 0;
                vr_tot_vlfatcxa := 0;
                
                if rw_craplft.tpfatura <> 2  OR
                   rw_craplft.cdempcon <> 0  THEN
                      -- Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras 
                       if cr_crapscn%isopen then 
                          close cr_crapscn;
                       end if;   
                       open cr_crapscn(rw_craplft.cdempcon,
                                       rw_craplft.cdsegmto);
                       fetch cr_crapscn into rw_crapscn;
                       if cr_crapscn%notfound then 
                          close cr_crapscn;
                          continue;
                       end if;
                else
                  -- DARF SIMPLES 
                  if rw_craplft.cdtribut = '6106' then 
                     begin          
                       select crapscn.cdempres 
                        into 
                        vr_darf
                        from crapscn
                          where crapscn.cdempres = 'D0';
                     exception 
                       when others then 
                         vr_darf := null; 
                         CONTINUE;          
                     end;            
                  
                  else
                  -- DARF PRETO EUROPA   
                     begin          
                       select crapscn.cdempres 
                        into 
                        vr_darf
                        from crapscn
                          where crapscn.cdempres = 'A0';
                     exception 
                       when others then 
                         vr_darf := null; 
                         CONTINUE;          
                     end;                
                  end if; -- VERIFICA DARF  
                end if;   
                -- Se ler DARF NUMERADO ou DAS assumir tarifa de 0.16 
                IF  rw_craplft.tpfatura >= 1 THEN
                    vr_aux_vltarfat := rw_crapcop.vltardrf; -- 0.16 era o valor antigo 
                ELSE
                    vr_aux_vltarfat := rw_crapthi.vltarifa;
                END IF;    

                IF  rw_craplft.cdagenci = 90 THEN  -- Internet 
                    vr_tot_qtfatint := vr_tot_qtfatint + 1;
                    vr_tot_vlfatint := vr_tot_vlfatint + (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
                
                ELSIF rw_craplft.cdagenci = 91 THEN  -- TAA 
                    vr_tot_qtfattaa := vr_tot_qtfattaa + 1;
                    vr_tot_vlfattaa := vr_tot_vlfattaa + (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
                ELSE  -- Caixa 
                    vr_tot_qtfatcxa := vr_tot_qtfatcxa + 1;
                    vr_tot_vlfatcxa := vr_tot_vlfatcxa + (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
                END IF;
                
                -- INTERNET
                if cr_crapstn%isopen then 
                   close cr_crapstn;
                end if;   
                open cr_crapstn(rw_crapscn.cdempres,
                                'D');
                fetch cr_crapstn into rw_crapstn;
                if cr_crapstn%notfound then 
                   close cr_crapstn;
                end if;   
                
                IF  vr_tot_qtfatint > 0  AND 
                   cr_crapstn%found      and 
                   cr_crapthi%found      THEN
                   vr_ind_rel636 := rw_crapscn.cdempres||rw_crapstn.tpmeiarr;
                   
                   if vr_tab_rel636.exists(vr_ind_rel636) then 

                     -- Incrementa os valores de dias anteriores 
                     vr_tab_rel636(vr_ind_rel636).qtfatura := vr_tab_rel636(vr_ind_rel636).qtfatura + vr_tot_qtfatint;
                     vr_tab_rel636(vr_ind_rel636).vltotfat := vr_tab_rel636(vr_ind_rel636).vltotfat + vr_tot_vlfatint;
                     vr_tab_rel636(vr_ind_rel636).vltottar := (rw_crapstn.vltrfuni * vr_tab_rel636(vr_ind_rel636).qtfatura);
                     -- Recalcula e sobrescreve valores derivados de tarifas 
                     vr_tab_rel636(vr_ind_rel636).vlrecliq := vr_tab_rel636(vr_ind_rel636).vltottar - (vr_tab_rel636(vr_ind_rel636).qtfatura * vr_aux_vltarfat);
                     ---
                     IF vr_tab_rel636(vr_ind_rel636).vlrecliq < 0 THEN    
                        vr_tab_rel636(vr_ind_rel636).vltrfsic := vr_tab_rel636(vr_ind_rel636).vltottar;
                     ELSE 
                        vr_tab_rel636(vr_ind_rel636).vltrfsic := (vr_tab_rel636(vr_ind_rel636).vltottar - vr_tab_rel636(vr_ind_rel636).vlrecliq);
                     END IF;
                     ---   
                   ELSE 
                        vr_tab_rel636(vr_ind_rel636).nmrescop := rw_crapcop.nmrescop;
                        vr_tab_rel636(vr_ind_rel636).nmconven := rw_crapscn.dsnomcnv;
                        vr_tab_rel636(vr_ind_rel636).dsmeiarr := 'INTERNET';
                        vr_tab_rel636(vr_ind_rel636).cdcooper := rw_crapcop.cdcooper;
                        vr_tab_rel636(vr_ind_rel636).cdempres := rw_crapscn.cdempres;
                        vr_tab_rel636(vr_ind_rel636).tpmeiarr := rw_crapstn.tpmeiarr;
                        vr_tab_rel636(vr_ind_rel636).qtfatura := vr_tot_qtfatint;
                        vr_tab_rel636(vr_ind_rel636).vltotfat := vr_tot_vlfatint;
                        vr_tab_rel636(vr_ind_rel636).vltottar := (rw_crapstn.vltrfuni * vr_tot_qtfatint);
                        vr_tab_rel636(vr_ind_rel636).vlrecliq := vr_tab_rel636(vr_ind_rel636).vltottar - (vr_tot_qtfatint * vr_aux_vltarfat);
                        ----
                        IF vr_tab_rel636(vr_ind_rel636).vlrecliq < 0 THEN  
                         vr_tab_rel636(vr_ind_rel636).vltrfsic := vr_tab_rel636(vr_ind_rel636).vltottar; 
                        ELSE 
                         vr_tab_rel636(vr_ind_rel636).vltrfsic := (vr_tab_rel636(vr_ind_rel636).vltottar - vr_tab_rel636(vr_ind_rel636).vlrecliq);
                        end if; 
                        ---- 
                        vr_tab_rel636(vr_ind_rel636).dsdianor := rw_crapscn.dsdianor;
                        vr_tab_rel636(vr_ind_rel636).nrrenorm := rw_crapscn.nrrenorm;
                     
                   END IF;
                END IF;     

                -- TAA 
                if cr_crapstn%isopen then 
                   close cr_crapstn;
                end if;   
                open cr_crapstn(rw_crapscn.cdempres,
                                'A');
                fetch cr_crapstn into rw_crapstn;
                if cr_crapstn%notfound then 
                   close cr_crapstn;
                end if;

                IF  vr_tot_qtfattaa > 0  AND 
                   cr_crapstn%found      and 
                   cr_crapthi%found      THEN
                   vr_ind_rel636 := rw_crapscn.cdempres||rw_crapstn.tpmeiarr;
                   
                   if vr_tab_rel636.exists(vr_ind_rel636) then 
                      
                      vr_tab_rel636(vr_ind_rel636).qtfatura := vr_tab_rel636(vr_ind_rel636).qtfatura + vr_tot_qtfattaa;
                      vr_tab_rel636(vr_ind_rel636).vltotfat := vr_tab_rel636(vr_ind_rel636).vltotfat + vr_tot_vlfattaa;
                      vr_tab_rel636(vr_ind_rel636).vltottar := (rw_crapstn.vltrfuni * vr_tab_rel636(vr_ind_rel636).qtfatura);
                      -- Recalcula e sobrescreve valores derivados de tarifas 
                      vr_tab_rel636(vr_ind_rel636).vlrecliq := vr_tab_rel636(vr_ind_rel636).vltottar - (vr_tab_rel636(vr_ind_rel636).qtfatura * rw_crapthi.vltarifa);
                      
                      IF vr_tab_rel636(vr_ind_rel636).vlrecliq < 0 THEN  
                         vr_tab_rel636(vr_ind_rel636).vltrfsic := vr_tab_rel636(vr_ind_rel636).vltottar; 
                      ELSE 
                         vr_tab_rel636(vr_ind_rel636).vltrfsic := (vr_tab_rel636(vr_ind_rel636).vltottar - vr_tab_rel636(vr_ind_rel636).vlrecliq);
                      end if;   
                  
                   else -- Incrementa os valores de dias anteriores 

                      vr_tab_rel636(vr_ind_rel636).nmrescop := rw_crapcop.nmrescop;
                      vr_tab_rel636(vr_ind_rel636).nmconven := rw_crapscn.dsnomcnv;
                      vr_tab_rel636(vr_ind_rel636).dsmeiarr := 'TAA';
                      vr_tab_rel636(vr_ind_rel636).cdcooper := rw_crapcop.cdcooper;
                      vr_tab_rel636(vr_ind_rel636).cdempres := rw_crapscn.cdempres;
                      vr_tab_rel636(vr_ind_rel636).tpmeiarr := rw_crapstn.tpmeiarr;
                      vr_tab_rel636(vr_ind_rel636).qtfatura := vr_tot_qtfattaa;
                      vr_tab_rel636(vr_ind_rel636).vltotfat := vr_tot_vlfattaa;
                      vr_tab_rel636(vr_ind_rel636).vltottar := (rw_crapstn.vltrfuni * vr_tot_qtfattaa);
                      vr_tab_rel636(vr_ind_rel636).vlrecliq := vr_tab_rel636(vr_ind_rel636).vltottar - (vr_tot_qtfattaa * rw_crapthi.vltarifa);

                      IF vr_tab_rel636(vr_ind_rel636).vlrecliq < 0 THEN  
                        vr_tab_rel636(vr_ind_rel636).vltrfsic := vr_tab_rel636(vr_ind_rel636).vltottar;
                      ELSE 
                        vr_tab_rel636(vr_ind_rel636).vltrfsic := (vr_tab_rel636(vr_ind_rel636).vltottar - vr_tab_rel636(vr_ind_rel636).vlrecliq);
                      END IF;
                      vr_tab_rel636(vr_ind_rel636).dsdianor := rw_crapscn.dsdianor;
                      vr_tab_rel636(vr_ind_rel636).nrrenorm := rw_crapscn.nrrenorm;
                   END IF;    
                END IF;
                -- CAIXA 
                if cr_crapstn%isopen then 
                   close cr_crapstn;
                end if;   
                open cr_crapstn(rw_crapscn.cdempres,
                                'C');
                fetch cr_crapstn into rw_crapstn;
                if cr_crapstn%notfound then 
                   close cr_crapstn;
                end if;

                IF  vr_tot_qtfattaa > 0  AND 
                   cr_crapstn%found      and 
                   cr_crapthi%found      THEN
                   vr_ind_rel636 := rw_crapscn.cdempres||rw_crapstn.tpmeiarr;
                   
                   if vr_tab_rel636.exists(vr_ind_rel636) then 
                     
                      vr_tab_rel636(vr_ind_rel636).qtfatura := vr_tab_rel636(vr_ind_rel636).qtfatura + vr_tot_qtfatcxa;
                      vr_tab_rel636(vr_ind_rel636).vltotfat := vr_tab_rel636(vr_ind_rel636).vltotfat + vr_tot_vlfatcxa;
                      vr_tab_rel636(vr_ind_rel636).vltottar := (rw_crapstn.vltrfuni * vr_tab_rel636(vr_ind_rel636).qtfatura);
                      vr_tab_rel636(vr_ind_rel636).vlrecliq := vr_tab_rel636(vr_ind_rel636).vltottar - (vr_tab_rel636(vr_ind_rel636).qtfatura * vr_aux_vltarfat);
                                            
									 	  IF vr_tab_rel636(vr_ind_rel636).vlrecliq < 0 THEN  
									 		   vr_tab_rel636(vr_ind_rel636).vltrfsic := vr_tab_rel636(vr_ind_rel636).vltottar; 
									 	  ELSE 
									 		   vr_tab_rel636(vr_ind_rel636).vltrfsic := (vr_tab_rel636(vr_ind_rel636).vltottar - vr_tab_rel636(vr_ind_rel636).vlrecliq);
									 	  END IF;
                     
                   
                   ELSE -- Incrementa os valores de dias anteriores 

                      vr_tab_rel636(vr_ind_rel636).nmconven := rw_crapscn.dsnomcnv;
                      vr_tab_rel636(vr_ind_rel636).nmrescop := rw_crapcop.nmrescop;
                      vr_tab_rel636(vr_ind_rel636).dsmeiarr := 'CAIXA';
                      vr_tab_rel636(vr_ind_rel636).cdcooper := rw_crapcop.cdcooper;
                      vr_tab_rel636(vr_ind_rel636).cdempres := rw_crapscn.cdempres;
                      vr_tab_rel636(vr_ind_rel636).tpmeiarr := rw_crapstn.tpmeiarr;
                      vr_tab_rel636(vr_ind_rel636).qtfatura := vr_tot_qtfatcxa;
                      vr_tab_rel636(vr_ind_rel636).vltotfat := vr_tot_vlfatcxa;
                      vr_tab_rel636(vr_ind_rel636).vltottar := (rw_crapstn.vltrfuni * vr_tot_qtfatcxa);
                      vr_tab_rel636(vr_ind_rel636).vlrecliq := vr_tab_rel636(vr_ind_rel636).vltottar - (vr_tot_qtfatcxa * vr_aux_vltarfat);
                      
                      IF vr_tab_rel636(vr_ind_rel636).vlrecliq < 0 THEN  
                         vr_tab_rel636(vr_ind_rel636).vltrfsic := vr_tab_rel636(vr_ind_rel636).vltottar; 
                      ELSE 
                        vr_tab_rel636(vr_ind_rel636).vltrfsic := (vr_tab_rel636(vr_ind_rel636).vltottar - vr_tab_rel636(vr_ind_rel636).vlrecliq);
                      end if;
                      vr_tab_rel636(vr_ind_rel636).dsdianor := rw_crapscn.dsdianor;
                      vr_tab_rel636(vr_ind_rel636).nrrenorm := rw_crapscn.nrrenorm;                      
									 	  
                   END IF;
                END IF;      
                
            end loop;--fim do for each craplft 
            if cr_craplcm%isopen then
               close cr_craplcm;
            end if;   
            
            -- Para debito aumatico SICREDI 
            for rw_craplcm in cr_craplcm(rw_crapcop.cdcooper,
                                         1019,  
                                         pr_aux_dtvencto) loop
                  if cr_craplau%isopen then 
   	                 close cr_craplau;
                  end if;	
                  open cr_craplau(rw_craplcm.cdcooper,
                                  rw_craplcm.cdhistor,
                                  rw_craplcm.nrdocmto,
                                  rw_craplcm.nrdconta,
                                  rw_craplcm.cdagenci,
                                  rw_craplcm.dtmvtolt);
                  fetch cr_craplau into rw_craplau;
                  
                  if cr_craplau%notfound then 
                     close cr_craplau;
                     continue;
                  end if;   
                  
                  vr_tot_qtfatdeb := 0;
                  vr_tot_vlfatdeb := 0;
                  
                  -- somatoria por empresa 
                  for rw_crapscn1 in cr_crapscn1(rw_craplau.cdempres,
                                                 null,
                                                 null,
                                                 null) loop
                      vr_tot_qtfatdeb := vr_tot_qtfatdeb + 1;
                      vr_tot_vlfatdeb := vr_tot_vlfatdeb + rw_craplcm.vllanmto;
                  end loop;  
                  
                  -- Se nao for debito automatico nao faz
                  if cr_crapscn1%isopen then 
                     close cr_crapscn1;
                  end if;    
                  open cr_crapscn1(rw_craplau.cdempres,
                                   'E',
                                   'A',
                                   'C');
                  fetch cr_crapscn1 into rw_crapscn1;                 
                               
                  IF  cr_crapscn1%notfound THEN
                    continue;
                  end if;    
                  
                  if cr_crapstn%isopen then
                     close cr_crapstn;
                  end if;   
                  open cr_crapstn(rw_crapscn1.cdempres,
                                  'E');
                  if cr_crapstn%notfound then 
                     close cr_crapstn;
                  end if;                            
                  if cr_crapstn%found then 
                    
                     vr_ind_rel636 := rw_crapscn.cdempres||rw_crapstn.tpmeiarr;
                     
                     if vr_tab_rel636.exists(vr_ind_rel636) then 
                      
                       vr_tab_rel636(vr_ind_rel636).qtfatura := vr_tab_rel636(vr_ind_rel636).qtfatura + vr_tot_qtfatdeb;
                       vr_tab_rel636(vr_ind_rel636).vltotfat := vr_tab_rel636(vr_ind_rel636).vltotfat + vr_tot_vlfatdeb;
                       vr_tab_rel636(vr_ind_rel636).vltottar := vr_tab_rel636(vr_ind_rel636).vltottar + (vr_tot_qtfatdeb * rw_crapstn.vltrfuni);
                       vr_tab_rel636(vr_ind_rel636).vlrecliq := vr_tab_rel636(vr_ind_rel636).vlrecliq + ((vr_tot_qtfatdeb * rw_crapstn.vltrfuni) - (vr_tot_qtfatdeb * vr_aux_vltarifa));
                       
                       IF vr_tab_rel636(vr_ind_rel636).vlrecliq < 0 THEN  
                         vr_tab_rel636(vr_ind_rel636).vltrfsic := vr_tab_rel636(vr_ind_rel636).vltottar;
                       ELSE 
                         vr_tab_rel636(vr_ind_rel636).vltrfsic := (vr_tab_rel636(vr_ind_rel636).vltottar - vr_tab_rel636(vr_ind_rel636).vlrecliq);
                       END IF;    
                       
                     else 
                       vr_tab_rel636(vr_ind_rel636).nmconven := rw_crapscn.dsnomcnv;
                       vr_tab_rel636(vr_ind_rel636).cdempres := rw_crapscn.cdempres;
                       vr_tab_rel636(vr_ind_rel636).tpmeiarr := 'E';
                       vr_tab_rel636(vr_ind_rel636).qtfatura := vr_tot_qtfatdeb;
                       vr_tab_rel636(vr_ind_rel636).vltotfat := vr_tot_vlfatdeb;
                       vr_tab_rel636(vr_ind_rel636).vltottar := (rw_crapstn.vltrfuni * vr_tot_qtfatdeb);
                       vr_tab_rel636(vr_ind_rel636).vlrecliq := vr_tab_rel636(vr_ind_rel636).vltottar - (vr_tot_qtfatdeb * vr_aux_vltarifa);
                       
                       IF vr_tab_rel636(vr_ind_rel636).vlrecliq < 0 THEN  
                          vr_tab_rel636(vr_ind_rel636).vltrfsic := vr_tab_rel636(vr_ind_rel636).vltottar;
                       ELSE 
                          vr_tab_rel636(vr_ind_rel636).vltrfsic := (vr_tab_rel636(vr_ind_rel636).vltottar - vr_tab_rel636(vr_ind_rel636).vlrecliq);
                       END IF;   
                       vr_tab_rel636(vr_ind_rel636).dsdianor := rw_crapscn.dsdianor;
                       vr_tab_rel636(vr_ind_rel636).nrrenorm := rw_crapscn.nrrenorm;
                       vr_tab_rel636(vr_ind_rel636).dsmeiarr := 'DEB.AUTOM.';
                     end if;  
                     
                  end if; 
            end loop;
            --
            IF pr_cdcooper <> 3 THEN
              -- GUIA DA PREVIDENVIA SOCIAL - SICREDI 

              -- Tarifa a ser paga ao SICREDI
              if cr_crapthi%isopen then 
                 close cr_crapthi;
              end if;   
              
              open cr_crapthi(pr_cdcooper,
                              1414);
              fetch cr_crapthi into rw_crapthi;
              
              if cr_crapthi%notfound then 
                 close cr_crapthi;
              end if;
                                 
              
              -- Localizar a tarifa da base 
              if cr_craptab%isopen then 
                close cr_craptab;
              end if;
              
              open cr_craptab(pr_cdcooper,
                              'GPSCXASCOD');
              fetch cr_craptab into rw_craptab;
              
              if cr_craptab%notfound then 
                 vr_aux_vltfcxsb := 0;
                 close cr_craptab;
              else 
                 vr_aux_vltfcxsb := rw_craptab.dstextab;  -- Valor Tarifa Caixa Com Sem.Barra
              end if;    
              
              -- Localizar a tarifa da base 
              if cr_craptab%isopen then 
                close cr_craptab;
              end if;
              
              open cr_craptab(pr_cdcooper,
                              'GPSCXACCOD');
              fetch cr_craptab into rw_craptab;
              
              if cr_craptab%notfound then 
                 vr_aux_vltfcxcb := 0;
                 close cr_craptab;
              else 
                 vr_aux_vltfcxcb := rw_craptab.dstextab;  -- Valor Tarifa Caixa Com Sem.Barra
              end if;    
              
              -- Localizar a tarifa da base 
              if cr_craptab%isopen then 
                close cr_craptab;
              end if;
              
              open cr_craptab(pr_cdcooper,
                              'GPSINTBANK');
              fetch cr_craptab into rw_craptab;
              
              if cr_craptab%notfound then 
                 vr_aux_vlrtrfib := 0;
                 close cr_craptab;
              else 
                 vr_aux_vlrtrfib := rw_craptab.dstextab;  -- Valor Tarifa IB
              end if;    
              --  Para todos os lancamentos ja pagos 
              for rw_craplgp in  cr_craplgp(pr_cdcooper,     
                             	              rw_crapdat.dtmvtolt) loop
                  -- Inicializa Variaveis 
                  vr_aux_dsempgps := null;
                  vr_aux_dsnomcnv := null;
                  vr_aux_tpmeiarr := null;
                  vr_aux_dsmeiarr := null;
                  vr_aux_vltargps := 0;
                  
                  if rw_craplgp.cdagenci <> 90 THEN -- CAIXA
                     vr_aux_tpmeiarr := 'C';
                     vr_aux_dsmeiarr := 'CAIXA';
                     
                     IF rw_craplgp.tpdpagto = 1 THEN -- Com Cod.Barras
                        vr_aux_vltargps :=  vr_aux_vltfcxcb;
                     ELSE -- Sem Cod.Barras
                        vr_aux_vltargps := vr_aux_vltfcxsb;
                     end if;
                  ELSE -- INTERNET 
                     vr_aux_tpmeiarr := 'D';
                     vr_aux_dsmeiarr := 'INTERNET';
                     vr_aux_vltargps := vr_aux_vlrtrfib;
                     
                     IF  rw_craplgp.tpdpagto = 1 THEN -- Com Cod.Barras
                         vr_aux_dsempgps := 'GP1';
                         vr_aux_dsnomcnv := 'GPS - COM COD.BARRAS';
                     ELSE -- Sem Cod.Barras
                         vr_aux_dsempgps := 'GP2';
                         vr_aux_dsnomcnv := 'GPS - SEM COD.BARRAS';
                     end if;    
                  
                  end if;   
                 
                  vr_ind_rel636 := vr_aux_dsempgps||vr_aux_tpmeiarr;
                  if vr_tab_rel636.exists(vr_ind_rel636) then 
                     -- Incrementa os valores anteriores 
                     vr_tab_rel636(vr_ind_rel636).qtfatura := vr_tab_rel636(vr_ind_rel636).qtfatura + 1;
                     vr_tab_rel636(vr_ind_rel636).vltotfat := vr_tab_rel636(vr_ind_rel636).vltotfat + rw_craplgp.vlrtotal;
                     vr_tab_rel636(vr_ind_rel636).vltottar := vr_tab_rel636(vr_ind_rel636).vltottar + vr_aux_vltargps;
                     vr_tab_rel636(vr_ind_rel636).vlrecliq := vr_tab_rel636(vr_ind_rel636).vlrecliq + (vr_aux_vltargps - rw_crapthi.vltarifa);
                     IF vr_tab_rel636(vr_ind_rel636).vlrecliq < 0 THEN  
                        vr_tab_rel636(vr_ind_rel636).vltrfsic := vr_tab_rel636(vr_ind_rel636).vltottar;
                     ELSE 
                        vr_tab_rel636(vr_ind_rel636).vltrfsic := (vr_tab_rel636(vr_ind_rel636).vltottar - vr_tab_rel636(vr_ind_rel636).vlrecliq);
                     end if;   
                  else
                     vr_tab_rel636(vr_ind_rel636).nmconven := vr_aux_dsnomcnv;
                     vr_tab_rel636(vr_ind_rel636).cdempres := vr_aux_dsempgps;
                     vr_tab_rel636(vr_ind_rel636).tpmeiarr := vr_aux_tpmeiarr;
                     vr_tab_rel636(vr_ind_rel636).qtfatura := 1;
                     vr_tab_rel636(vr_ind_rel636).vltotfat := rw_craplgp.vlrtotal;
                     vr_tab_rel636(vr_ind_rel636).vltottar := vr_aux_vltargps;
                     vr_tab_rel636(vr_ind_rel636).vlrecliq := vr_tab_rel636(vr_ind_rel636).vltottar - rw_crapthi.vltarifa;

                     IF vr_tab_rel636(vr_ind_rel636).vlrecliq < 0 THEN  
                        vr_tab_rel636(vr_ind_rel636).vltrfsic := vr_tab_rel636(vr_ind_rel636).vltottar; 
                     ELSE 
                        vr_tab_rel636(vr_ind_rel636).vltrfsic := (vr_tab_rel636(vr_ind_rel636).vltottar - vr_tab_rel636(vr_ind_rel636).vlrecliq);
                     end if;
                     vr_tab_rel636(vr_ind_rel636).dsdianor := '';
                     vr_tab_rel636(vr_ind_rel636).nrrenorm := 0;
                     vr_tab_rel636(vr_ind_rel636).dsmeiarr := vr_aux_dsmeiarr;
                     
                     
                  end if;        
            
              end loop; -- Fim do FOR - CRAPLGP 
            end if;  
        end loop; -- FOR EACH crapcop 
      end loop;
      
      -- Faz o calculo dos totais por convenio 
      FOR i IN vr_tab_rel636.FIRST .. vr_tab_rel636.LAST LOOP
        
       
       vr_ind_reltot := vr_tab_rel636(i).cdempres ||vr_tab_rel636(I).tpmeiarr; 
        
       if vr_tab_totais.exists(vr_ind_reltot) then 
          
          vr_tab_totais(vr_ind_reltot).qtfatura := vr_tab_totais(vr_ind_reltot).qtfatura + vr_tab_rel636(I).qtfatura;
          vr_tab_totais(vr_ind_reltot).vltotfat := vr_tab_totais(vr_ind_reltot).vltotfat + vr_tab_rel636(I).vltotfat;
          vr_tab_totais(vr_ind_reltot).vltottar := vr_tab_totais(vr_ind_reltot).vltottar + vr_tab_rel636(I).vltottar;
          vr_tab_totais(vr_ind_reltot).vltrfsic := vr_tab_totais(vr_ind_reltot).vltrfsic + vr_tab_rel636(I).vltrfsic;
          vr_tab_totais(vr_ind_reltot).vlrecliq := vr_tab_totais(vr_ind_reltot).vlrecliq + vr_tab_rel636(I).vlrecliq;
       else
          vr_tab_totais(vr_ind_reltot).cdempres := vr_tab_rel636(i).cdempres;
          vr_tab_totais(vr_ind_reltot).tpmeiarr := vr_tab_rel636(i).tpmeiarr;
          vr_tab_totais(vr_ind_reltot).dsmeiarr := vr_tab_rel636(i).dsmeiarr;
          vr_tab_totais(vr_ind_reltot).nmconven := vr_tab_rel636(i).nmconven;
       end if;
              
       IF vr_tab_totais(vr_ind_reltot).vlrecliq < 0 THEN
          vr_tab_totais(vr_ind_reltot).vlrecliq := 0;
       end if;  
       
       IF vr_tab_totais(vr_ind_reltot).vltottar < 0 THEN
          vr_tab_totais(vr_ind_reltot).vltottar := 0;
       end if;    
       
       IF vr_tab_totais(vr_ind_reltot).vltotfat < 0 THEN
          vr_tab_totais(vr_ind_reltot).vltotfat := 0;
       end if;   
      
       IF vr_tab_totais(vr_ind_reltot).vltrfsic < 0 THEN
          vr_tab_totais(vr_ind_reltot).vltrfsic := 0;
       end if;          
      end loop;
      
      FOR i IN vr_tab_totais.FIRST .. vr_tab_totais.LAST LOOP
         
         if vr_tab_totais(i).tpmeiarr <> 'E' then 
            for i in vr_tab_rel636.first .. vr_tab_rel636.last loop
                if vr_tab_rel636(i).cdempres = vr_tab_totais(i).cdempres then 
                   
                    IF vr_tab_rel636(i).tpmeiarr = 'D' THEN
                        -- TOTAIS INTERNET 
                        vr_int_vltrfuni := vr_int_vltrfuni + vr_tab_rel636(i).vltottar;
                        vr_int_vltrfsic := vr_int_vltrfsic + vr_tab_rel636(i).vltrfsic;
                        vr_int_vltotfat := vr_int_vltotfat + vr_tab_rel636(i).vltotfat;
                        vr_int_qttotfat := vr_int_qttotfat + vr_tab_rel636(i).qtfatura;
                        vr_int_vlrecliq := vr_int_vlrecliq + vr_tab_rel636(i).vlrecliq;
                    end if;    

                    IF  vr_tab_rel636(i).tpmeiarr = 'C' THEN
                        -- TOTAIS CAIXA 
                        vr_cax_vltrfuni := vr_cax_vltrfuni + vr_tab_rel636(i).vltottar;
                        vr_cax_vltrfsic := vr_cax_vltrfsic + vr_tab_rel636(i).vltrfsic;
                        vr_cax_vltotfat := vr_cax_vltotfat + vr_tab_rel636(i).vltotfat;
                        vr_cax_qttotfat := vr_cax_qttotfat + vr_tab_rel636(i).qtfatura;
                        vr_cax_vlrecliq := vr_cax_vlrecliq + vr_tab_rel636(i).vlrecliq;
                    END if;
                    
                    IF  vr_tab_rel636(i).tpmeiarr = 'A' THEN
                        -- TOTAIS TAA 
                       vr_taa_vltrfuni := vr_taa_vltrfuni + vr_tab_rel636(i).vltottar;
                       vr_taa_vltrfsic := vr_taa_vltrfsic + vr_tab_rel636(i).vltrfsic;
                       vr_taa_vltotfat := vr_taa_vltotfat + vr_tab_rel636(i).vltotfat;
                       vr_taa_qttotfat := vr_taa_qttotfat + vr_tab_rel636(i).qtfatura;
                       vr_taa_vlrecliq := vr_taa_vlrecliq + vr_tab_rel636(i).vlrecliq;
                    end if;

                    -- TOTAIS GERAL 
                    vr_tot_vltrfuni := vr_tot_vltrfuni + vr_tab_rel636(i).vltottar;
                    vr_tot_vltrfsic := vr_tot_vltrfsic + vr_tab_rel636(i).vltrfsic;
                    vr_tot_vltotfat := vr_tot_vltotfat + vr_tab_rel636(i).vltotfat;
                    vr_tot_qttotfat := vr_tot_qttotfat + vr_tab_rel636(i).qtfatura;
                    vr_tot_vlrecliq := vr_tot_vlrecliq + vr_tab_rel636(i).vlrecliq;

                    -- Corrige valores negativos 
                    IF  vr_tab_rel636(i).vltotfat < 0 THEN
                        vr_tab_rel636(i).vltotfat := 0;
                    end if;    

                    IF  vr_tab_rel636(i).vlrecliq < 0 THEN
                        vr_tab_rel636(i).vlrecliq := 0;
                    end if;    
                    IF  vr_tab_rel636(i).vltottar < 0 THEN
                        vr_tab_rel636(i).vltottar := 0;
                    end if;    
                    IF  vr_tab_rel636(i).vltrfsic < 0 THEN
                        vr_tab_rel636(i).vltrfsic := 0;
                    end if;      
                else 
                  continue;
                end if;
            end loop;           
            
         elsif vr_tab_totais(i).tpmeiarr = 'E' then 
            for i in vr_tab_rel636.first .. vr_tab_rel636.last loop
                if vr_tab_rel636(i).cdempres = vr_tab_totais(i).cdempres then 
                   -- TOTAIS DEB AUTOMATICO 
                   vr_deb_vltrfuni := vr_deb_vltrfuni + vr_tab_rel636(i).vltottar;
                   vr_deb_vltrfsic := vr_deb_vltrfsic + vr_tab_rel636(i).vltrfsic;
                   vr_deb_vltotfat := vr_deb_vltotfat + vr_tab_rel636(i).vltotfat;
                   vr_deb_qttotfat := vr_deb_qttotfat + vr_tab_rel636(i).qtfatura;
                   vr_deb_vlrecliq := vr_deb_vlrecliq + vr_tab_rel636(i).vlrecliq;
                   --TOTAIS GERAL
                   vr_tot_vltrfuni := vr_tot_vltrfuni + vr_tab_rel636(i).vltottar;
                   vr_tot_vltrfsic := vr_tot_vltrfsic + vr_tab_rel636(i).vltrfsic;
                   vr_tot_vltotfat := vr_tot_vltotfat + vr_tab_rel636(i).vltotfat;
                   vr_tot_qttotfat := vr_tot_qttotfat + vr_tab_rel636(i).qtfatura;
                   vr_tot_vlrecliq := vr_tot_vlrecliq + vr_tab_rel636(i).vlrecliq;

                    -- Corrige valores negativos 
                    IF  vr_tab_rel636(i).vltotfat < 0 THEN
                        vr_tab_rel636(i).vltotfat := 0;
                    end if;    

                    IF  vr_tab_rel636(i).vlrecliq < 0 THEN
                        vr_tab_rel636(i).vlrecliq := 0;
                    end if;
                    IF  vr_tab_rel636(i).vltottar < 0 THEN
                        vr_tab_rel636(i).vltottar := 0;
                    end if;

                    IF  vr_tab_rel636(i).vltrfsic < 0 THEN
                        vr_tab_rel636(i).vltrfsic := 0;
                    end if;
                end if;    
            end loop;    
         end if;  
     end loop;
     
     for i in vr_tab_rel636.first .. vr_tab_rel636.last loop
         if vr_tab_totais.count = 1 then 
          -- Gerar Relatorio
          -- Inicializar o CLOB
          vr_des_xml := NULL;
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          -- Inicilizar as informações do XML
          vr_texto_completo := NULL;
          pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl636>'); 
         end if; 
         -- Exibe Totais por Coluna 
         pc_escreve_xml(
                   '<coluna>' ||
                   '<nmconven>'||vr_tab_rel636(i).nmconven   ||'</nmconven>'||
                   '<dsmeiarr>'||vr_tab_rel636(i).dsmeiarr   ||'</dsmeiarr>'||
                   '<qtfatura>'||vr_tab_rel636(i).qtfatura   ||'</qtfatura>'||
                   '<vltotfat>'||to_char(vr_tab_rel636(i).vltotfat,'fm999G999G999G999G990d00') ||'</vltotfat>'||
                   '<vltrfsic>'||to_char(vr_tab_rel636(i).vltrfsic,'fm999G999G999G999G990d00') ||'</vltrfsic>'||
                   '<vltottar>'||to_char(vr_tab_rel636(i).vltottar,'fm999G999G999G999G990d00') ||'</vltottar>'||
                   '<nrrenorm>'||vr_tab_rel636(i).nrrenorm   ||'</nrrenorm>'||
                   '<dsdianor>'||vr_tab_rel636(i).dsdianor   ||'</dsdianor>'||
                   '</coluna>');
 
     end loop;
    for i in vr_tab_totais.first .. vr_tab_totais.last loop
         
                pc_escreve_xml(
                   '<totais>' ||
                   '<totfatura>'||vr_tab_totais(i).qtfatura   ||'</totfatura>'||
                   '<vltotfat>'||to_char(vr_tab_totais(i).vltotfat,'fm999G999G999G999G990d00') ||'</vltotfat>'||
                   '<vltrfsic>'||to_char(vr_tab_totais(i).vltrfsic,'fm999G999G999G999G990d00') ||'</vltrfsic>'||
                   '<vlrecliq>'||to_char(vr_tab_totais(i).vlrecliq,'fm999G999G999G999G990d00') ||'</vlrecliq>'||
                   '<vltottar>'||to_char(vr_tab_totais(i).vltottar,'fm999G999G999G999G990d00') ||'</vltottar>'||
                   '</totais>');
           pc_escreve_xml('</crrl636>');
      END loop; 
      
      ----------------- gerar relatório -----------------
           -- Busca do diretório base da cooperativa para PDF
           vr_caminho_integra := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                      ,pr_cdcooper => pr_cdcooper
                                                      ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

           -- Efetuar solicitação de geração de relatório --

            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                      ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                      ,pr_dsxmlnode => '/crrl636/'          --> Nó base do XML para leitura dos dados
                                      ,pr_dsjasper  => 'crrl636.jasper'    --> Arquivo de layout do iReport
                                      ,pr_dsparams  => NULL                --> Sem parametros
                                      ,pr_dsarqsaid => vr_caminho_integra||'/crrl636.lst' --> Arquivo final com código da agência
                                      ,pr_qtcoluna  => 132                 --> 132 colunas
                                      ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                      ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                      ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                      ,pr_nrcopias  => 1                   --> Número de cópias
                                      ,pr_flg_gerar => 'S'                 --> gerar PDF
                                       ,pr_des_erro  => vr_dscritic);       --> Saída com erro


 -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;
     -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
     
           
/*
    PUT STREAM str_3 "TOTAL GERAL: " AT 01
               tot_qttotfat AT 46  FORMAT "zzzzzz9"
               tot_vltotfat AT 54  FORMAT "zzz,zzz,zzz,zz9.99"
               tot_vlrecliq AT 73  FORMAT "zzz,zzz,zzz,zz9.99"
               tot_vltrfuni AT 92  FORMAT "zz,zzz,zz9.99"
               tot_vltrfsic AT 107 FORMAT "zz,zzz,zz9.99"
               SKIP(1).
*/

    /*** Impressao dos registros de debito automatico que deverao ir
         depois que listou todos os outros convenios ***//*
    VIEW STREAM str_3 FRAME f_cabrel132_3.
    PUT  STREAM str_3 SKIP(2) "DEBITO AUTOMATICO " SKIP.
    VIEW STREAM str_3 FRAME f_titulo_rel636.

    FOR EACH tt-totais NO-LOCK WHERE tt-totais.tpmeiarr = "E",
        EACH tt-rel636 WHERE tt-rel636.cdempres = tt-totais.cdempres NO-LOCK
                       BREAK BY tt-totais.qtfatura DESC
                             BY tt-rel636.cdempres
                             BY tt-rel636.qtfatura DESC.

        IF  LINE-COUNTER(str_3) > PAGE-SIZE(str_3) THEN
            DO:
                PAGE STREAM str_3.
                VIEW STREAM str_3 FRAME f_cabrel132_3.
                VIEW STREAM str_3 FRAME f_titulo_rel636.
            END.

        -- TOTAIS DEB AUTOMATICO 
        ASSIGN deb_vltrfuni = deb_vltrfuni + tt-rel636.vltottar
               deb_vltrfsic = deb_vltrfsic + tt-rel636.vltrfsic
               deb_vltotfat = deb_vltotfat + tt-rel636.vltotfat
               deb_qttotfat = deb_qttotfat + tt-rel636.qtfatura
               deb_vlrecliq = deb_vlrecliq + tt-rel636.vlrecliq.

         --TOTAIS GERAL
        ASSIGN tot_vltrfuni = tot_vltrfuni + tt-rel636.vltottar
               tot_vltrfsic = tot_vltrfsic + tt-rel636.vltrfsic
               tot_vltotfat = tot_vltotfat + tt-rel636.vltotfat
               tot_qttotfat = tot_qttotfat + tt-rel636.qtfatura
               tot_vlrecliq = tot_vlrecliq + tt-rel636.vlrecliq.

         -- Corrige valores negativos 
        IF  tt-rel636.vltotfat < 0 THEN
            ASSIGN tt-rel636.vltotfat = 0.

        IF  tt-rel636.vlrecliq < 0 THEN
            ASSIGN tt-rel636.vlrecliq = 0.

        IF  tt-rel636.vltottar < 0 THEN
            ASSIGN tt-rel636.vltottar = 0.

        IF  tt-rel636.vltrfsic < 0 THEN
            ASSIGN tt-rel636.vltrfsic = 0.

        DISPLAY STREAM str_3 tt-rel636.nmconven
                             tt-rel636.dsmeiarr
                             tt-rel636.qtfatura
                             tt-rel636.vltotfat
                             tt-rel636.vlrecliq
                             tt-rel636.vltottar
                             tt-rel636.vltrfsic
                             tt-rel636.nrrenorm
                             tt-rel636.dsdianor
                             WITH FRAME f_rel636.
        DOWN STREAM str_3 WITH FRAME f_rel636.

    END.

    PUT STREAM str_3 SKIP(1)
               "TOTAL GERAL: " AT 01
               deb_qttotfat    AT 46  FORMAT "zzzzzz9"
               deb_vltotfat    AT 54  FORMAT "zzz,zzz,zzz,zz9.99"
               deb_vlrecliq    AT 73  FORMAT "zzz,zzz,zzz,zz9.99"
               deb_vltrfuni    AT 92  FORMAT "zz,zzz,zz9.99"
               deb_vltrfsic    AT 107 FORMAT "zz,zzz,zz9.99"               
               SKIP.


    PUT STREAM str_3
    SKIP(3)
    "TOTAL POR MEIO DE ARRECADACAO"
    SKIP(1)
    "MEIO ARRECADACAO QTD.FATURAS      VALOR FATURAS "
    "RECEITA LIQUIDA COOP.  VALOR TARIFA TARIFA SICREDI"
    SKIP
    "---------------- ----------- ------------------ "
    "--------------------- ------------- --------------".

    -- Exibe Totais por Coluna 
    DISPLAY STREAM str_3 --internet
                         int_qttotfat
                         int_vltotfat
                         int_vlrecliq
                         int_vltrfuni
                         int_vltrfsic
                         --  caixa
                         cax_qttotfat
                         cax_vltotfat
                         cax_vlrecliq
                         cax_vltrfuni
                         cax_vltrfsic
                         -- taa 
                         taa_qttotfat
                         taa_vltotfat
                         taa_vlrecliq
                         taa_vltrfuni
                         taa_vltrfsic
                         --Deb Auto
                         deb_qttotfat
                         deb_vltotfat
                         deb_vlrecliq
                         deb_vltrfuni
                         deb_vltrfsic
                        --total geral
                         tot_qttotfat
                         tot_vltotfat
                         tot_vlrecliq
                         tot_vltrfuni
                         tot_vltrfsic
                         WITH FRAME f_totais_rel636.

    OUTPUT STREAM str_3 CLOSE.

    IF  NOT TEMP-TABLE tt-rel636:HAS-RECORDS THEN
        UNIX SILENT VALUE ("rm " + aux_nmarqimp + "* 2>/dev/null").
    ELSE
        RUN fontes/imprim.p.
*/
END pc_gera_rel_mensal_cecred;
    
  PROCEDURE pc_gera_conciliacao_conven(pr_tot_vlrtrfpf in number,
                                       pr_tot_vlrtrfpj in number,
                                       pr_tot_trfgpspf in number,
                                       pr_tot_trfgpspj in number,
                                       pr_ger_vltrpapf in vr_vltrpapf,
                                       pr_ger_vltrpapj in vr_vltrpapj) is

    TYPE vr_cdccuage IS VARRAY(999) OF INTEGER; -- define o tipo do vetor  
    vr_aux_dtmvtolt       DATE;
    vr_aux_dtmvtopr       DATE;
    vr_con_dtmvtolt       VARCHAR2(100);
    vr_con_dtmvtopr       VARCHAR2(100);
    vr_aux_nrmaxpas       NUMBER(15,2);
    vr_aux_linhadet       VARCHAR2(150);
    vr_aux_dtmovime       DATE;
    vr_con_dtmovime       VARCHAR2(100);
    vr_aux_contador       NUMBER;
    vr_aux_nmarqdat       varchar(100);
    vr_aux_cdccuage       vr_cdccuage;


/* MODELO
    70141128,281114,7255,7367,692.36,1434,"TARIFAS CONVENIO SICREDI  - COOPERADOS PESSOA FISICA"
    001,482.44
    002,64.19
    090,120.27
    091,25.46
    70141201,011214,7367,7255,692.36,1434,"TARIFAS CONVENIO SICREDI  - COOPERADOS PESSOA FISICA"
    001,482.44
    002,64.19
    090,120.27
    091,25.46
    70141128,281114,7255,7368,863.26,1434,"TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA JURIDICA"
    001,441.43
    002,80.77
    090,320.95
    091,20.11
    70141201,011214,7368,7255,863.26,1434,"TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA JURIDICA"
    001,441.43
    002,80.77
    090,320.95
    091,20.11
*/
   CURSOR cr_crapage(vr_cdcooper crapage.cdcooper%type) is 
     select cdagenci,cdccuage
           from crapage 
           where crapage.cdcooper = vr_cdcooper;
     rw_crapage cr_crapage%rowtype;      

    BEGIN
     
     if cr_crapage%isopen then 
        close cr_crapage;
     end if;   
        	
     open cr_crapage(pr_cdcooper);
     fetch cr_crapage
     into rw_crapage;
     
     if cr_crapage%notfound then 
        close cr_crapage;
     else 
        vr_aux_nrmaxpas := rw_crapage.cdagenci;
     end if;
     --  Procura pela proxima data de movimento 
     vr_aux_dtmvtopr := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                    pr_dtmvtolt => rw_crapdat.dtmvtolt + 1,
                                                    pr_tipo => 'P',
                                                    pr_feriado => TRUE,
                                                    pr_excultdia => TRUE);
    
    --  Procura pela proxima data de movimento 
     vr_aux_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                    pr_tipo => 'A',
                                                    pr_feriado => TRUE,
                                                    pr_excultdia => TRUE);
    
    vr_con_dtmvtolt := '70'||substr(to_char(vr_aux_dtmvtolt,'YYYY'),3,2)
                           ||to_char(vr_aux_dtmvtolt,'MM')  
                           ||to_char(vr_aux_dtmvtolt,'DD');

    vr_con_dtmvtopr := '70'||substr(to_char(vr_aux_dtmvtopr,'YYYY'),3,2)
                           ||to_char(vr_aux_dtmvtopr,'MM')  
                           ||to_char(vr_aux_dtmvtopr,'DD');                          
    
    vr_aux_nmarqdat := 'contab/'||SUBSTR(vr_con_dtmvtolt,3,6)||'_CONVEN_SIC.txt'; 
    
    if cr_crapage%isopen then 
      close cr_crapage;
    end if;
    
    for rw_crapage in cr_crapage(pr_cdcooper) loop
      
        vr_aux_cdccuage(rw_crapage.cdagenci) := rw_crapage.cdccuage;
    end loop;    
    
    
    vr_aux_dtmovime := rw_crapdat.dtultdia;
    
    if vr_aux_dtmovime is null then 
       
       -- Montar mensagem de critica
           vr_cdcritic:= 1;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '||vr_dscritic
                                                       || ' - Arquivo: integra/'||vr_aux_nmarqdat );
    else
      
      vr_con_dtmovime := '70'||substr(to_char(vr_aux_dtmovime,'YYYY'),3,2)
                             ||to_char(vr_aux_dtmovime,'MM')  
                             ||to_char(vr_aux_dtmovime,'DD');  
    end if;
    
    -- Valor Tarifa Pessoa Fisica 
    IF  pr_tot_vlrtrfpf <> 0  THEN 
        vr_aux_linhadet :=  TRIM(vr_con_dtmvtolt) || ',' ||
                            TRIM(TO_CHAR(vr_aux_dtmvtolt,'DDMMYY'))||
                            ',7268,7376,'||
                            TRIM(TO_CHAR(((pr_tot_vlrtrfpf - pr_tot_trfgpspf)* 100),'999999999999999G00'))||
                            ',1434,'|| '"' ||'TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA FISICA'||'"';
    

        for aux_contador in 1..vr_aux_nrmaxpas loop
          if pr_ger_vltrpapf(aux_contador) <> 0 then 
            vr_aux_linhadet := vr_aux_cdccuage(aux_contador)||','||
                               TRIM(TO_CHAR((pr_ger_vltrpapf(aux_contador) * 100),'999999999999999G00'));
          end if;  
        end loop;
     end if;   
     --  Valor Tarifa Pessoa Juridica
     IF  pr_tot_vlrtrfpj <> 0  THEN
         vr_aux_linhadet :=  TRIM(vr_con_dtmvtolt) || ',' ||
                            TRIM(TO_CHAR(vr_aux_dtmvtolt,'DDMMYY'))||
                            ',7268,7377,'||
                            TRIM(TO_CHAR(((pr_tot_vlrtrfpj - pr_tot_trfgpspj)* 100),'999999999999999G00'))||
                            ',1434,'|| '"' ||'TARIFAS CONVENIO SICREDI - COOPERADOS PESSOA JURIDICA'||'"';
         for aux_contador in 1..vr_aux_nrmaxpas loop
          if pr_ger_vltrpapj(aux_contador) <> 0 then 
            vr_aux_linhadet := vr_aux_cdccuage(aux_contador)||','||
                               TRIM(TO_CHAR((pr_ger_vltrpapj(aux_contador) * 100),'999999999999999G00'));
          end if;  
        end loop; 
         
     end if;    
  
  end pc_gera_conciliacao_conven;   
  PROCEDURE pc_executa_rel_mensais(pr_dtmvtolt in date,
                                   pr_tot_vlrtrfpf out number,
                                   pr_tot_vlrtrfpj out number,
                                   pr_tot_trfgpspf out number,
                                   pr_tot_trfgpspj out number,
                                   vr_ger_vltrpapf out vr_vltrpapf,
                                   vr_ger_vltrpapj out vr_vltrpapj) is 
    
    vr_aux_dtmvtolt date;                               
    vr_aux_datafina date;
    vr_aux_datainic date;
    --acumuladores
    vr_tot_vltotfat number(15,2);
    vr_tot_vlrecliq number(15,2);
    vr_tot_vltrfuni number(15,2);
    vr_tot_vlrtrfpf number(15,2);
    vr_tot_vlrliqpf number(15,2);
    vr_tot_vlrliqpj number(15,2);
    vr_tot_vlrtrfpj number(15,2);
    vr_tot_trfgpspf number(15,2);
    vr_tot_trfgpspj number(15,2);
    --TYPE vr_vltrpapf IS VARRAY(999) OF INTEGER; -- define o tipo do vetor  
    --TYPE vr_vltrpapj IS VARRAY(999) OF INTEGER; -- define o tipo do vetor  
    --vr_ger_vltrpapf vr_vltrpapf; -- Vl Tarif PA PF 
    --vr_ger_vltrpapj vr_vltrpapj;     -- Vl Tarif PA PJ 
    vr_aux_qttotfat NUMBER;
    vr_aux_vltotfat number(15,2);
    vr_aux_vltottar number(15,2);
    vr_glb_cdcritic varchar2(100);
    vr_num          number(9);
    vr_darf635      varchar2(2);    
    vr_ind_rel635   varchar(200);
    vr_deb_aut      varchar(10);
    vr_aux_vltfcxsb number(15,2);
    
    -- cursores
    
  CURSOR cr_crapthi(pr_cdcooper crapthi.Cdcooper%type,
                    pr_cdhistor crapthi.cdhistor%type)is
    
    select crapthi.cdcooper,crapthi.vltarifa from crapthi 
           WHERE crapthi.cdcooper = pr_cdcooper    AND
                 crapthi.cdhistor = pr_cdhistor    AND -- SICREDI 
                 crapthi.dsorigem = 'AYLLOS';

     rw_crapthi1 cr_crapthi%rowtype;            
    
    cursor cr_craplft(pr_cdcooper       crapcop.cdcooper%TYPE,
                      pr_aux_dtvencto   craplft.dtvencto%type)is  

          select cdcooper, cdtribut, cdempcon, cdsegmto, tpfatura,
                 vllanmto, vlrmulta, vlrjuros, cdagenci,nrdconta 
                 from craplft
                   WHERE craplft.cdcooper  = pr_cdcooper         AND
                         craplft.dtvencto  = pr_aux_dtvencto     AND
                         craplft.insitfat  = 2                   AND
                         craplft.cdhistor  = 1154;   -- SICREDI
  
    -- Divisao PF/PJ - Verificar Tipo Pessoa 
    cursor cr_crapass(pr_cdcooper craplft.cdcooper%type,
                      pr_nrdconta craplft.nrdconta%type ) is 
       select crapass.inpessoa from crapass
                 WHERE crapass.cdcooper = pr_cdcooper
                   AND crapass.nrdconta = pr_nrdconta;
          rw_crapass cr_crapass%rowtype;  
  
    -- Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras 
    cursor cr_crapscn(pr_cdempcon crapscn.cdempcon%type,
                      pr_cdsegmto craplft.cdsegmto%type) is
        select * from crapscn 
        WHERE (crapscn.cdempcon = pr_cdempcon          or 
               crapscn.cdempco2 = pr_cdempcon)         AND
               crapscn.cdsegmto = to_char(pr_cdsegmto) AND
               crapscn.dtencemp is null                AND
               crapscn.dsoparre <> 'E'; 
         rw_crapscn cr_crapscn%rowtype;            
         
    cursor cr_crapstn(pr_cdempres crapstn.cdempres%type,
                      pr_tpmeiarr crapstn.tpmeiarr%type) is 
          select * from crapstn 
            WHERE crapstn.cdempres = pr_cdempres AND
                  crapstn.tpmeiarr = pr_tpmeiarr;
         rw_crapstn cr_crapstn%rowtype;

    cursor cr_craplcm(pr_cdcooper     craplcm.cdcooper%type,
                      pr_hist         craplcm.cdhistor%type,
                      pr_aux_dtvencto craplcm.dtmvtolt%type)is 
    select cdcooper, 
           cdhistor, 
           nrdocmto,
           nrdconta,
           cdagenci,
           dtmvtolt, 
           nrdolote, 
           vllanmto
             from craplcm
               WHERE 
                  craplcm.cdcooper = pr_cdcooper AND
                  craplcm.cdhistor = pr_hist     AND
                  craplcm.dtmvtolt = pr_aux_dtvencto;
    
    cursor cr_craplau(pr_cdcooper    craplau.cdcooper%type,  
                      pr_cdhistor    craplau.cdhistor%type,  
                      pr_nrdocmto    craplau.nrdocmto%type,  
                      pr_nrdconta    craplau.nrdconta%type,  
                      pr_cdagenci    craplau.cdagenci%type,  
                      pr_dtmvtolt    craplau.dtmvtopg%type )is 
       select * from craplau 
         WHERE craplau.cdcooper = pr_cdcooper AND
               craplau.cdhistor = pr_cdhistor AND
               craplau.nrdocmto = pr_nrdocmto AND
               craplau.nrdconta = pr_nrdconta AND
               craplau.cdagenci = pr_cdagenci AND
               craplau.dtmvtopg = pr_dtmvtolt;

       rw_craplau  cr_craplau%rowtype;
       
       
    cursor cr_crapscn1(pr_cdempres crapscn.cdempres%type)is 
      select rowid, crapscn.cdempres from crapscn
       where crapscn.cdempres = pr_cdempres;
    
    cursor cr_craptab(pr_cdcooper craptab.cdcooper%type,
                        pr_acesso   craptab.cdacesso%type)is
      
       select craptab.nmsistem,
              craptab.tptabela,
              craptab.cdempres,
              craptab.cdacesso,
              craptab.dstextab from craptab 
         WHERE craptab.cdcooper = pr_cdcooper
           AND craptab.nmsistem = 'CRED'
           AND craptab.tptabela = 'GENERI'
           AND craptab.cdempres = 00
           AND craptab.cdacesso = pr_acesso
           AND craptab.tpregist = 0 ;

      rw_craptab cr_craptab%rowtype; 
      
      cursor cr_craplgp(pr_cdcooper craplgp.cdcooper%type,
                        pr_dtmvtolt craplgp.dtmvtolt%type) is
         select * from  craplgp
           WHERE craplgp.cdcooper = pr_cdcooper
            AND craplgp.dtmvtolt = pr_dtmvtolt 
            AND craplgp.idsicred <> 0
            AND craplgp.flgativo = 'YES';
          
     
    begin 
      -- Pega primeiro e último dia do mes 
      vr_aux_dtmvtolt := pr_dtmvtolt;
    
      IF (to_char(vr_aux_dtmvtolt,'mm') + 1 = 13) THEN
          vr_aux_datafina := '21/01/'||(to_char(vr_aux_dtmvtolt,'yyyy') + 1);
      ELSE
          vr_aux_datafina := '21/'||(to_char(vr_aux_dtmvtolt,'mm') + 1)||'/'||to_char(vr_aux_dtmvtolt,'yyyy');
      end if;
      
       vr_aux_datafina := to_date(vr_aux_datafina,'dd/mm/yyyy') - 21;
       vr_aux_datainic := last_day(add_months(vr_aux_datafina,-1)) + 1;

      vr_tot_vltotfat   := 0;
      vr_tot_vlrecliq   := 0;
      vr_tot_vltrfuni   := 0;
      vr_tot_vlrliqpf   := 0;
      vr_tot_vlrliqpj   := 0;
      vr_tot_vlrtrfpf   := 0;
      vr_tot_vlrtrfpj   := 0;
      vr_tot_trfgpspf   := 0;
      vr_tot_trfgpspj   := 0;
      vr_ger_vltrpapf.EXTEND;
      vr_ger_vltrpapj.EXTEND;
      vr_aux_qttotfat   := 0;
      vr_aux_vltotfat   := 0;
      vr_aux_vltottar   := 0;
      vr_glb_cdcritic   := 0;

   -- vr_aux_dscooper   := '/usr/coop/' + crapcop.dsdircop + '/';
   -- vr_aux_nmarqrel   := vr_aux_dscooper + 'rl/crrl635.lst';
   -- vr_glb_nmarqimp   := vr_aux_nmarqrel;

    -- Percorre todos os dias 
    WHILE vr_aux_datainic <= vr_aux_datafina LOOP
         vr_aux_dtvencto := vr_aux_datainic;
         vr_num := 1;

      -- Leitura para Convenios e DARFs 
      for rw_craplft in cr_craplft(pr_cdcooper,
                                   vr_aux_dtvencto)loop
          if vr_num = 1 then 
             vr_tot_qtfatint := 0;
             vr_tot_vlfatint := 0;
             vr_tot_qtfattaa := 0;
             vr_tot_vlfattaa := 0;
             vr_tot_qtfatcxa := 0;
             vr_tot_vlfatcxa := 0;
          end if;
        
          -- Divisao PF/PJ - Verificar Tipo Pessoa 
          open cr_crapass(rw_craplft.cdcooper,
                          rw_craplft.nrdconta);                 
          fetch cr_crapass into rw_crapass;
          
          if cr_crapass%notfound then 
            vr_aux_inpessoa := 1; -- Se por acaso nao encontrar ASS ... 
            close cr_crapass;
          else 
            IF  rw_crapass.inpessoa = 1 THEN
                vr_aux_inpessoa := rw_crapass.inpessoa;
            ELSE
                vr_aux_inpessoa := 2;
            end if;           
          end if; 
          
          IF  rw_craplft.tpfatura <> 2  OR
              rw_craplft.cdempcon <> 0  THEN
              -- Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras 
              open cr_crapscn(rw_craplft.cdempcon,
                              rw_craplft.cdsegmto);
              fetch cr_crapscn into rw_crapscn;
              
              if cr_crapscn%notfound then
                 continue; 
              end if;                
                 
          ELSE
             IF  rw_craplft.cdtribut = '6106' THEN -- DARF SIMPLES 
                 begin          
                   select crapscn.cdempres 
                    into 
                    vr_darf635 from crapscn
                      where crapscn.cdempres = 'D0';
                 exception 
                   when others then 
                     vr_darf635 := null;           
                 end;            
                 
             ELSE -- DARF PRETO EUROPA 
               begin          
                   select crapscn.cdempres 
                    into 
                    vr_darf635 from crapscn
                      where crapscn.cdempres = 'A0';
                 exception 
                   when others then 
                     vr_darf635 := null;           
               end;
             END IF;              
          END IF;   
          
          -- Se ler DARF NUMERADO ou DAS assumir tarifa de 0.16 
          IF rw_craplft.tpfatura >= 1 THEN
             vr_aux_vltarfat := rw_crapcop.vltardrf; -- 0.16 era o valor antigo 
          ELSE
             vr_aux_vltarfat := rw_crapthi.vltarifa;
          end if;
          
          IF  rw_craplft.cdagenci = 90 THEN  -- Internet
              vr_tot_qtfatint := vr_tot_qtfatint + 1;
              vr_tot_vlfatint := vr_tot_vlfatint + (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
          
          ELSIF rw_craplft.cdagenci = 91 THEN  -- TAA
                vr_tot_qtfattaa := vr_tot_qtfattaa + 1;
                vr_tot_vlfattaa := vr_tot_vlfattaa + (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
         
          ELSE -- Caixa 
               vr_tot_qtfatcxa := vr_tot_qtfatcxa + 1;
               vr_tot_vlfatcxa := vr_tot_vlfatcxa + (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
          end if;      
         -- INTERNET 
           if cr_crapstn%isopen then 
              close cr_crapstn;
           end if;              
           open cr_crapstn(rw_crapscn.cdempres,
                           'D'); 
           fetch cr_crapstn into rw_crapstn;
           
           if cr_crapstn%notfound then
              close cr_crapstn;
           end if;
           
             IF  vr_tot_qtfatint > 0 then
          
                 vr_ind_rel635 := rw_crapscn.cdempres||rw_crapstn.tpmeiarr;
                 if vr_tab_rel635.exists(vr_ind_rel635) then 
                  -- Incrementa os valores de dias anteriores 
                    vr_tab_rel635(vr_ind_rel635).qtfatura := vr_tab_rel635(vr_ind_rel635).qtfatura + vr_tot_qtfatint;
                    vr_tab_rel635(vr_ind_rel635).vltotfat := vr_tab_rel635(vr_ind_rel635).vltotfat + vr_tot_vlfatint;
                    vr_tab_rel635(vr_ind_rel635).vltottar := vr_tab_rel635(vr_ind_rel635).vltottar + (rw_crapstn.vltrfuni * vr_tot_qtfatint);
                    vr_tab_rel635(vr_ind_rel635).vlrecliq := vr_tab_rel635(vr_ind_rel635).vlrecliq + ((rw_crapstn.vltrfuni * vr_tot_qtfatint) - (vr_tot_qtfatint * rw_crapthi.vltarifa));

                   -- Divisao PF/PJ 
                   IF  vr_aux_inpessoa = 1 THEN
                       vr_tab_rel635(vr_ind_rel635).vlrtrfpf := vr_tab_rel635(vr_ind_rel635).vlrtrfpf + (rw_crapstn.vltrfuni * vr_tot_qtfatint);
                       vr_tab_rel635(vr_ind_rel635).vlrliqpf := vr_tab_rel635(vr_ind_rel635).vlrliqpf + ((rw_crapstn.vltrfuni * vr_tot_qtfatint) - (vr_tot_qtfatint * rw_crapthi.vltarifa));
                   ELSE
                      vr_tab_rel635(vr_ind_rel635).vlrtrfpj := vr_tab_rel635(vr_ind_rel635).vlrtrfpj + (rw_crapstn.vltrfuni * vr_tot_qtfatint);
                      vr_tab_rel635(vr_ind_rel635).vlrliqpj := vr_tab_rel635(vr_ind_rel635).vlrliqpj + ((rw_crapstn.vltrfuni * vr_tot_qtfatint) - (vr_tot_qtfatint * rw_crapthi.vltarifa));
                   end if;
             else 
               vr_tab_rel635(vr_ind_rel635).nmconven := rw_crapscn.dsnomcnv;
               vr_tab_rel635(vr_ind_rel635).dsmeiarr := 'INTERNET';
               vr_tab_rel635(vr_ind_rel635).cdempres := rw_crapscn.cdempres;
               vr_tab_rel635(vr_ind_rel635).tpmeiarr := rw_crapstn.tpmeiarr;
               vr_tab_rel635(vr_ind_rel635).qtfatura := vr_tot_qtfatint;
               vr_tab_rel635(vr_ind_rel635).vltotfat := vr_tot_vlfatint;
               vr_tab_rel635(vr_ind_rel635).vltottar := (rw_crapstn.vltrfuni * vr_tot_qtfatint);
               vr_tab_rel635(vr_ind_rel635).vlrecliq := vr_tab_rel635(vr_ind_rel635).vltottar - (vr_tot_qtfatint * rw_crapthi.vltarifa);
               vr_tab_rel635(vr_ind_rel635).dsdianor := rw_crapscn.dsdianor;
               vr_tab_rel635(vr_ind_rel635).nrrenorm := rw_crapscn.nrrenorm;
               vr_tab_rel635(vr_ind_rel635).inpessoa := vr_aux_inpessoa;
               -- Divisao PF/PJ
               IF  vr_aux_inpessoa = 1 THEN
                   vr_tab_rel635(vr_ind_rel635).vlrtrfpf := vr_tab_rel635(vr_ind_rel635).vltottar;
                   vr_tab_rel635(vr_ind_rel635).vlrliqpf := vr_tab_rel635(vr_ind_rel635).vlrecliq;
               ELSE
                   vr_tab_rel635(vr_ind_rel635).vlrtrfpj := vr_tab_rel635(vr_ind_rel635).vltottar;
                   vr_tab_rel635(vr_ind_rel635).vlrliqpj := vr_tab_rel635(vr_ind_rel635).vlrecliq;  
               end if;  
             
             end if;
           IF  vr_aux_inpessoa = 1 THEN
               vr_ger_vltrpapf(rw_craplft.cdagenci) := vr_ger_vltrpapf(rw_craplft.Cdagenci) || (rw_crapstn.vltrfuni * vr_tot_qtfatint);
           ELSE
               vr_ger_vltrpapj(rw_craplft.Cdagenci) := vr_ger_vltrpapj(rw_craplft.Cdagenci) || (rw_crapstn.vltrfuni * vr_tot_qtfatint);
           end if;
         end if;       

         --TAA
         if cr_crapstn%isopen then 
            close cr_crapstn;
         end if;
         open cr_crapstn(rw_crapscn.cdempres,
                         'A'); 
         fetch cr_crapstn into rw_crapstn;
         
         if cr_crapstn%notfound then
            close cr_crapstn;
         end if;
         
         IF  vr_tot_qtfattaa > 0 then
             vr_ind_rel635 := rw_crapscn.cdempres||rw_crapstn.tpmeiarr;
           
           if vr_tab_rel635.exists(vr_ind_rel635) then 
            -- Incrementa os valores de dias anteriores 
              vr_tab_rel635(vr_ind_rel635).qtfatura := vr_tab_rel635(vr_ind_rel635).qtfatura + vr_tot_qtfattaa;
              vr_tab_rel635(vr_ind_rel635).vltotfat := vr_tab_rel635(vr_ind_rel635).vltotfat + vr_tot_vlfattaa;
              vr_tab_rel635(vr_ind_rel635).vltottar := vr_tab_rel635(vr_ind_rel635).vltottar + (rw_crapstn.vltrfuni * vr_tot_qtfattaa);
              vr_tab_rel635(vr_ind_rel635).vlrecliq := vr_tab_rel635(vr_ind_rel635).vlrecliq + ((rw_crapstn.vltrfuni * vr_tot_qtfattaa) - (vr_tot_qtfattaa * rw_crapthi.vltarifa));

             -- Divisao PF/PJ 
             IF  vr_aux_inpessoa = 1 THEN
                 vr_tab_rel635(vr_ind_rel635).vlrtrfpf := vr_tab_rel635(vr_ind_rel635).vlrtrfpf + (rw_crapstn.vltrfuni * vr_tot_qtfattaa);
                 vr_tab_rel635(vr_ind_rel635).vlrliqpf := vr_tab_rel635(vr_ind_rel635).vlrliqpf + ((rw_crapstn.vltrfuni * vr_tot_qtfattaa) - (vr_tot_qtfattaa * rw_crapthi.vltarifa));
             ELSE
                vr_tab_rel635(vr_ind_rel635).vlrtrfpj := vr_tab_rel635(vr_ind_rel635).vlrtrfpj + (rw_crapstn.vltrfuni * vr_tot_qtfattaa);
                vr_tab_rel635(vr_ind_rel635).vlrliqpj := vr_tab_rel635(vr_ind_rel635).vlrliqpj + ((rw_crapstn.vltrfuni * vr_tot_qtfattaa) - (vr_tot_qtfattaa * rw_crapthi.vltarifa));
             end if;
           else 
             vr_tab_rel635(vr_ind_rel635).nmconven := rw_crapscn.dsnomcnv;
             vr_tab_rel635(vr_ind_rel635).dsmeiarr := 'TAA';
             vr_tab_rel635(vr_ind_rel635).cdempres := rw_crapscn.cdempres;
             vr_tab_rel635(vr_ind_rel635).tpmeiarr := rw_crapstn.tpmeiarr;
             vr_tab_rel635(vr_ind_rel635).qtfatura := vr_tot_qtfattaa;
             vr_tab_rel635(vr_ind_rel635).vltotfat := vr_tot_vlfattaa;
             vr_tab_rel635(vr_ind_rel635).vltottar := (rw_crapstn.vltrfuni * vr_tot_qtfattaa);
             vr_tab_rel635(vr_ind_rel635).vlrecliq := vr_tab_rel635(vr_ind_rel635).vltottar - (vr_tot_qtfattaa * rw_crapthi.vltarifa);
             vr_tab_rel635(vr_ind_rel635).dsdianor := rw_crapscn.dsdianor;
             vr_tab_rel635(vr_ind_rel635).nrrenorm := rw_crapscn.nrrenorm;
             vr_tab_rel635(vr_ind_rel635).inpessoa := vr_aux_inpessoa;
             -- Divisao PF/PJ
             IF  vr_aux_inpessoa = 1 THEN
                 vr_tab_rel635(vr_ind_rel635).vlrtrfpf := vr_tab_rel635(vr_ind_rel635).vltottar;
                 vr_tab_rel635(vr_ind_rel635).vlrliqpf := vr_tab_rel635(vr_ind_rel635).vlrecliq;
             ELSE
                 vr_tab_rel635(vr_ind_rel635).vlrtrfpj := vr_tab_rel635(vr_ind_rel635).vltottar;
                 vr_tab_rel635(vr_ind_rel635).vlrliqpj := vr_tab_rel635(vr_ind_rel635).vlrecliq;  
             end if;  
           
           end if;
           IF  vr_aux_inpessoa = 1 THEN
               vr_ger_vltrpapf(rw_craplft.cdagenci) := vr_ger_vltrpapf(rw_craplft.cdagenci) + (rw_crapstn.vltrfuni * vr_tot_qtfattaa);
           ELSE
               vr_ger_vltrpapj(rw_craplft.cdagenci) := vr_ger_vltrpapj(rw_craplft.cdagenci) + (rw_crapstn.vltrfuni * vr_tot_qtfattaa);
           end if;
         end if;       
         --CAIXA 
         if cr_crapstn%isopen then 
            close cr_crapstn;
         end if;       
         open cr_crapstn(rw_crapscn.cdempres,
                         'C'); 
         fetch cr_crapstn into rw_crapstn;
         
         if cr_crapstn%notfound then
            close cr_crapstn;
         end if;
         
         IF  vr_tot_qtfatcxa > 0 then
             vr_ind_rel635 := rw_crapscn.cdempres||rw_crapstn.tpmeiarr;
           
           if vr_tab_rel635.exists(vr_ind_rel635) then 
            -- Incrementa os valores de dias anteriores 
              vr_tab_rel635(vr_ind_rel635).qtfatura := vr_tab_rel635(vr_ind_rel635).qtfatura + vr_tot_qtfatcxa;
              vr_tab_rel635(vr_ind_rel635).vltotfat := vr_tab_rel635(vr_ind_rel635).vltotfat + vr_tot_vlfatcxa;
              vr_tab_rel635(vr_ind_rel635).vltottar := vr_tab_rel635(vr_ind_rel635).vltottar + (rw_crapstn.vltrfuni * vr_tot_qtfatcxa);
              vr_tab_rel635(vr_ind_rel635).vlrecliq := vr_tab_rel635(vr_ind_rel635).vlrecliq + ((rw_crapstn.vltrfuni * vr_tot_qtfatcxa) - (vr_tot_qtfatcxa * rw_crapthi.vltarifa));

             -- Divisao PF/PJ 
             IF  vr_aux_inpessoa = 1 THEN
                 vr_tab_rel635(vr_ind_rel635).vlrtrfpf := vr_tab_rel635(vr_ind_rel635).vlrtrfpf + (rw_crapstn.vltrfuni * vr_tot_qtfatcxa);
                 vr_tab_rel635(vr_ind_rel635).vlrliqpf := vr_tab_rel635(vr_ind_rel635).vlrliqpf + ((rw_crapstn.vltrfuni * vr_tot_qtfatcxa) - (vr_tot_qtfatcxa * rw_crapthi.vltarifa));
             ELSE
                vr_tab_rel635(vr_ind_rel635).vlrtrfpj := vr_tab_rel635(vr_ind_rel635).vlrtrfpj + (rw_crapstn.vltrfuni * vr_tot_qtfatcxa);
                vr_tab_rel635(vr_ind_rel635).vlrliqpj := vr_tab_rel635(vr_ind_rel635).vlrliqpj + ((rw_crapstn.vltrfuni * vr_tot_qtfatcxa) - (vr_tot_qtfatcxa * rw_crapthi.vltarifa));
             end if;
           else 
             vr_tab_rel635(vr_ind_rel635).nmconven := rw_crapscn.dsnomcnv;
             vr_tab_rel635(vr_ind_rel635).dsmeiarr := 'CAIXA';
             vr_tab_rel635(vr_ind_rel635).cdempres := rw_crapscn.cdempres;
             vr_tab_rel635(vr_ind_rel635).tpmeiarr := rw_crapstn.tpmeiarr;
             vr_tab_rel635(vr_ind_rel635).qtfatura := vr_tot_qtfatcxa;
             vr_tab_rel635(vr_ind_rel635).vltotfat := vr_tot_vlfatcxa;
             vr_tab_rel635(vr_ind_rel635).vltottar := (rw_crapstn.vltrfuni * vr_tot_qtfatcxa);
             vr_tab_rel635(vr_ind_rel635).vlrecliq := vr_tab_rel635(vr_ind_rel635).vltottar - (vr_tot_qtfatcxa * rw_crapthi.vltarifa);
             vr_tab_rel635(vr_ind_rel635).dsdianor := rw_crapscn.dsdianor;
             vr_tab_rel635(vr_ind_rel635).nrrenorm := rw_crapscn.nrrenorm;
             vr_tab_rel635(vr_ind_rel635).inpessoa := vr_aux_inpessoa;
             -- Divisao PF/PJ
             IF  vr_aux_inpessoa = 1 THEN
                 vr_tab_rel635(vr_ind_rel635).vlrtrfpf := vr_tab_rel635(vr_ind_rel635).vltottar;
                 vr_tab_rel635(vr_ind_rel635).vlrliqpf := vr_tab_rel635(vr_ind_rel635).vlrecliq;
             ELSE
                 vr_tab_rel635(vr_ind_rel635).vlrtrfpj := vr_tab_rel635(vr_ind_rel635).vltottar;
                 vr_tab_rel635(vr_ind_rel635).vlrliqpj := vr_tab_rel635(vr_ind_rel635).vlrecliq;  
             end if;  
           
           end if;
           IF  vr_aux_inpessoa = 1 THEN
               vr_ger_vltrpapf(rw_craplft.cdagenci) := vr_ger_vltrpapf(rw_craplft.cdagenci) + (rw_crapstn.vltrfuni * vr_tot_qtfatcxa);
           ELSE
               vr_ger_vltrpapj(rw_craplft.cdagenci) := vr_ger_vltrpapj(rw_craplft.cdagenci) + (rw_crapstn.vltrfuni * vr_tot_qtfatcxa);
           end if;
         end if;         
            
      vr_num := vr_num +1;
      end loop; -- rw_craplft 
      
      -- Para debito aumatico SICREDI 
       for rw_craplcm in  cr_craplcm(pr_cdcooper,
                                     1019,
                                     vr_aux_datainic) loop
       if cr_craplau%isopen then 
          close cr_craplau;
       end if;  
       
       open cr_craplau(rw_craplcm.cdcooper ,
                       rw_craplcm.cdhistor ,
                       rw_craplcm.nrdocmto ,
                       rw_craplcm.nrdconta ,
                       rw_craplcm.cdagenci ,
                       rw_craplcm.dtmvtolt );
       fetch cr_craplau into rw_craplau;
       
         if cr_craplau%notfound then 
            vr_tot_qtfatdeb := 0;
            vr_tot_vlfatdeb := 0;
          close cr_craplau;
          continue;
         end if;
         -- somatoria por empresa 
         FOR rw_crapscn1 IN cr_crapscn1(rw_craplau.cdempres) loop
             vr_tot_qtfatdeb := vr_tot_qtfatdeb + 1;
             vr_tot_vlfatdeb := vr_tot_vlfatdeb + rw_craplcm.vllanmto;
         end loop;
         -- Se nao for debito automatico nao faz 
          begin 
            select  
             crapscn.cdempres
             into
             vr_deb_aut
              from crapscn
                WHERE crapscn.dsoparre = 'E'                AND
                     (crapscn.cddmoden = 'A'                OR
                      crapscn.cddmoden = 'C')               AND
                      crapscn.cdempres = rw_craplau.cdempres;
           exception
             when others then 
              vr_deb_aut := 'N';
          end;
          
          if vr_deb_aut = 'N' then 
             continue;
          else
             if cr_crapstn%isopen then 
                close cr_crapstn;
             end if;              
             open cr_crapstn(vr_deb_aut,
                             'E'); 
             fetch cr_crapstn into rw_crapstn;
             
             if cr_crapstn%notfound then
                close cr_crapstn;
             else
                -- Divisao PF/PJ - Verificar Tipo Pessoa 
                if cr_crapass%isopen then 
                   close cr_crapass;
                end if;
                open cr_crapass(rw_craplcm.cdcooper,
                                rw_craplcm.nrdconta);
                fetch cr_crapass into rw_crapass;
                
                if cr_crapass%notfound then 
                  vr_aux_inpessoa := 1; -- Se por acaso nao encontrar ASS ... *
                  close cr_crapass;
                else 
                
                  if rw_crapass.inpessoa = 1 THEN
                      vr_aux_inpessoa := rw_crapass.inpessoa;
                  ELSE
                      vr_aux_inpessoa := 2;
                  end if;
                end if;  
             -----
             vr_ind_rel635 := rw_crapscn.cdempres||rw_crapstn.tpmeiarr;
              
              if vr_tab_rel635.exists(vr_ind_rel635) then 
                 
                 -- Incrementa os valores anteriores 
                 vr_tab_rel635(vr_ind_rel635).qtfatura := vr_tab_rel635(vr_ind_rel635).qtfatura + vr_tot_qtfatdeb;
                 vr_tab_rel635(vr_ind_rel635).vltotfat := vr_tab_rel635(vr_ind_rel635).vltotfat + vr_tot_vlfatdeb;
                 vr_tab_rel635(vr_ind_rel635).vltottar := vr_tab_rel635(vr_ind_rel635).vltottar + (rw_crapstn.vltrfuni * vr_tot_qtfatdeb);
                 vr_tab_rel635(vr_ind_rel635).vlrecliq := vr_tab_rel635(vr_ind_rel635).vlrecliq + ((rw_crapstn.vltrfuni * vr_tot_qtfatdeb) - (vr_tot_qtfatdeb * vr_aux_vltarifa));

                    -- Divisao PF/PJ 
                    IF  vr_aux_inpessoa = 1 THEN
                        vr_tab_rel635(vr_ind_rel635).vlrtrfpf := vr_tab_rel635(vr_ind_rel635).vlrtrfpf + (rw_crapstn.vltrfuni * vr_tot_qtfatdeb);
                        vr_tab_rel635(vr_ind_rel635).vlrliqpf := vr_tab_rel635(vr_ind_rel635).vlrliqpf + ((rw_crapstn.vltrfuni * vr_tot_qtfatdeb) - (vr_tot_qtfatdeb * vr_aux_vltarifa));
                    ELSE
                        vr_tab_rel635(vr_ind_rel635).vlrtrfpj := vr_tab_rel635(vr_ind_rel635).vlrtrfpj + (rw_crapstn.vltrfuni * vr_tot_qtfatdeb);
                        vr_tab_rel635(vr_ind_rel635).vlrliqpj := vr_tab_rel635(vr_ind_rel635).vlrliqpj + ((rw_crapstn.vltrfuni * vr_tot_qtfatdeb) - (vr_tot_qtfatdeb * vr_aux_vltarifa));
                    end if;

              else                
                        vr_tab_rel635(vr_ind_rel635).nmconven := rw_crapscn.dsnomcnv;
                        vr_tab_rel635(vr_ind_rel635).dsmeiarr := 'DEB. AUTOMATICO';
                        vr_tab_rel635(vr_ind_rel635).cdempres := rw_crapscn.cdempres;
                        vr_tab_rel635(vr_ind_rel635).tpmeiarr := 'E';
                        vr_tab_rel635(vr_ind_rel635).qtfatura := vr_tot_qtfatdeb;
                        vr_tab_rel635(vr_ind_rel635).vltotfat := vr_tot_vlfatdeb;
                        vr_tab_rel635(vr_ind_rel635).vltottar := (rw_crapstn.vltrfuni * vr_tot_qtfatdeb);
                        vr_tab_rel635(vr_ind_rel635).vlrecliq := vr_tab_rel635(vr_ind_rel635).vltottar - (vr_tot_qtfatdeb * vr_aux_vltarifa);
                        vr_tab_rel635(vr_ind_rel635).dsdianor := rw_crapscn.dsdianor;
                        vr_tab_rel635(vr_ind_rel635).nrrenorm := rw_crapscn.nrrenorm;
                        vr_tab_rel635(vr_ind_rel635).inpessoa := vr_aux_inpessoa;
                        -- Divisao PF/PJ 
                        IF  vr_aux_inpessoa = 1 THEN
                           vr_tab_rel635(vr_ind_rel635).vlrtrfpf := vr_tab_rel635(vr_ind_rel635).vltottar;
                           vr_tab_rel635(vr_ind_rel635).vlrliqpf := vr_tab_rel635(vr_ind_rel635).vlrecliq;
                        ELSE
                           vr_tab_rel635(vr_ind_rel635).vlrtrfpj := vr_tab_rel635(vr_ind_rel635).vltottar;
                           vr_tab_rel635(vr_ind_rel635).vlrliqpj := vr_tab_rel635(vr_ind_rel635).vlrecliq;
                        end if;
                
              end if;
              IF  vr_aux_inpessoa = 1 THEN
                  vr_ger_vltrpapf(rw_craplcm.cdagenci) := vr_ger_vltrpapf(rw_craplcm.cdagenci) + (rw_crapstn.vltrfuni * vr_tot_qtfatdeb);
              ELSE
                  vr_ger_vltrpapj(rw_craplcm.cdagenci)  := vr_ger_vltrpapj(rw_craplcm.cdagenci) + (rw_crapstn.vltrfuni * vr_tot_qtfatdeb);
              end if;
            
          end if;
      -- GUIA DA PREVIDENVIA SOCIAL - SICREDI 
      -- Tarifa a ser paga ao SICREDI
      if cr_crapthi%isopen then 
         close cr_crapthi;
      end if;   
      open cr_crapthi(pr_cdcooper,
                      1414);
      fetch cr_crapthi into rw_crapthi1;
       
      if cr_crapthi%notfound then 
        close cr_crapthi;
      end if;
       
      if cr_craptab%isopen then 
        close cr_craptab;
      end if;
      -- Localizar a tarifa da base 
      open cr_craptab(pr_cdcooper,
                     'GPSCXASCOD');
      fetch cr_craptab into rw_craptab;
      
       if cr_craptab%isopen then 
         vr_aux_vltfcxsb := 0;
         close cr_craptab;
       else
         vr_aux_vltfcxsb := rw_craptab.dstextab;  -- Valor Tarifa Caixa Com Sem.Barra 
       end if;   
       
       if cr_craptab%isopen then 
        close cr_craptab;
       end if;
        -- Localizar a tarifa da base 
      open cr_craptab(pr_cdcooper,
                     'GPSCXACCOD');
      fetch cr_craptab into rw_craptab;
       if cr_craptab%isopen then 
           vr_aux_vltfcxsb := 0;
           close cr_craptab;
       else
         vr_aux_vltfcxsb := rw_craptab.dstextab;  -- Valor Tarifa Caixa Com Sem.Barra 
       end if; 
        -- Localizar a tarifa da base 
      open cr_craptab(pr_cdcooper,
                     'GPSINTBANK');
      fetch cr_craptab into rw_craptab;
       
       if cr_craptab%isopen then 
           vr_aux_vltfcxsb := 0;
           close cr_craptab;
       else
         vr_aux_vltfcxsb := rw_craptab.dstextab;  -- Valor Tarifa Caixa Com Sem.Barra 
       end if; 
  end if;  
 end loop;
        -- Para todos os lancamentos ja pagos 
       for rw_craplgp in cr_craplgp(pr_cdcooper,
                                    rw_crapdat.dtmvtolt) loop
            vr_aux_dsempgps := '';
            vr_aux_dsnomcnv := '';
            vr_aux_tpmeiarr := '';
            vr_aux_dsmeiarr := '';
            vr_aux_vltargps := 0;
       
            IF  rw_craplgp.cdagenci <> 90 THEN -- CAIXA
                vr_aux_tpmeiarr := 'C';
                vr_aux_dsmeiarr := 'CAIXA';
            
                IF rw_craplgp.tpdpagto = 1 THEN -- Com Cod.Barras
                   vr_aux_vltargps := vr_aux_vltfcxcb;
                ELSE -- Sem Cod.Barras
                   vr_aux_vltargps := vr_aux_vltfcxsb;
                end if;
            ELSE -- INTERNET 
                vr_aux_tpmeiarr := 'D';
                vr_aux_dsmeiarr := 'INTERNET';
                vr_aux_vltargps := vr_aux_vlrtrfib;
                IF  rw_craplgp.tpdpagto = 1 THEN -- Com Cod.Barras
                    vr_aux_dsempgps := 'GP1';
                    vr_aux_dsnomcnv := 'GPS - COM COD.BARRAS';
                      
                ELSE -- Sem Cod.Barras
                    vr_aux_dsempgps := 'GP2';
                    vr_aux_dsnomcnv := 'GPS - SEM COD.BARRAS';
                end if;  
            end if;  
      
           vr_ind_rel635 := rw_crapscn.cdempres||vr_aux_tpmeiarr;
           if vr_tab_rel635.exists(vr_ind_rel635) then 
              -- Incrementa os valores anteriores 
              vr_tab_rel635(vr_ind_rel635).qtfatura := vr_tab_rel635(vr_ind_rel635).qtfatura + 1;
              vr_tab_rel635(vr_ind_rel635).vltotfat := vr_tab_rel635(vr_ind_rel635).vltotfat + rw_craplgp.vlrtotal;
              vr_tab_rel635(vr_ind_rel635).vltottar := vr_tab_rel635(vr_ind_rel635).vltottar + vr_aux_vltargps;
              vr_tab_rel635(vr_ind_rel635).vlrecliq := vr_tab_rel635(vr_ind_rel635).vlrecliq + (vr_aux_vltargps - rw_crapthi.vltarifa);
              --Divisao PF/PJ 
                 IF  rw_craplgp.inpesgps = 1 THEN
                     vr_tab_rel635(vr_ind_rel635).vlrtrfpf := vr_tab_rel635(vr_ind_rel635).vlrtrfpf + vr_aux_vltargps;
                     vr_tab_rel635(vr_ind_rel635).vlrliqpf := vr_tab_rel635(vr_ind_rel635).vlrliqpf + (vr_aux_vltargps - rw_crapthi.vltarifa);
                     vr_tot_trfgpspf        := vr_tot_trfgpspf + vr_aux_vltargps;
                 ELSE   
                     vr_tab_rel635(vr_ind_rel635).vlrtrfpj := vr_tab_rel635(vr_ind_rel635).vlrtrfpj + vr_aux_vltargps;
                     vr_tab_rel635(vr_ind_rel635).vlrliqpj := vr_tab_rel635(vr_ind_rel635).vlrliqpj + (vr_aux_vltargps - rw_crapthi.vltarifa);
                     vr_tot_trfgpspj        := vr_tot_trfgpspj + vr_aux_vltargps;
                END if;
           else     
                vr_tab_rel635(vr_ind_rel635).nmconven := vr_aux_dsnomcnv;
                vr_tab_rel635(vr_ind_rel635).dsmeiarr := vr_aux_dsmeiarr;
                vr_tab_rel635(vr_ind_rel635).cdempres := vr_aux_dsempgps;
                vr_tab_rel635(vr_ind_rel635).tpmeiarr := vr_aux_tpmeiarr;
                vr_tab_rel635(vr_ind_rel635).qtfatura := 1;
                vr_tab_rel635(vr_ind_rel635).vltotfat := rw_craplgp.vlrtotal;
                vr_tab_rel635(vr_ind_rel635).vltottar := vr_aux_vltargps;
                vr_tab_rel635(vr_ind_rel635).vlrecliq := vr_tab_rel635(vr_ind_rel635).vltottar - rw_crapthi.vltarifa;
                vr_tab_rel635(vr_ind_rel635).dsdianor := '';
                vr_tab_rel635(vr_ind_rel635).nrrenorm := 0;
                vr_tab_rel635(vr_ind_rel635).inpessoa := rw_craplgp.inpesgps;

                -- Divisao PF/PJ 
                IF  rw_craplgp.inpesgps = 1 THEN
                    vr_tab_rel635(vr_ind_rel635).vlrtrfpf := vr_tab_rel635(vr_ind_rel635).vltottar;
                    vr_tab_rel635(vr_ind_rel635).vlrliqpf := vr_tab_rel635(vr_ind_rel635).vlrecliq;
                    vr_tot_trfgpspf        := vr_tot_trfgpspf + vr_aux_vltargps;
                ELSE
                    vr_tab_rel635(vr_ind_rel635).vlrtrfpj := vr_tab_rel635(vr_ind_rel635).vltottar;
                    vr_tab_rel635(vr_ind_rel635).vlrliqpj := vr_tab_rel635(vr_ind_rel635).vlrecliq;
                    vr_tot_trfgpspj        := vr_tot_trfgpspj + vr_aux_vltargps;
                end if;
                    
                   
           end if;

    end loop; -- Fim do FOR - CRAPLGP 
    -- DO... TO *


    -- zerar variaveis dos totais
    -- internet 
           vr_int_qttotfat := 0;
           vr_int_vltotfat := 0;
           vr_int_vlrecliq := 0;
           vr_int_vltrfuni := 0;
           vr_int_vlrliqpf := 0;
           vr_int_vlrliqpj := 0;
           vr_int_vlrtrfpf := 0;
           vr_int_vlrtrfpj := 0;
            -- caixa 
          vr_cax_qttotfat := 0;
          vr_cax_vltotfat := 0;
          vr_cax_vlrecliq := 0;
          vr_cax_vltrfuni := 0;
          vr_cax_vlrliqpf := 0;
          vr_cax_vlrliqpj := 0;
          vr_cax_vlrtrfpf := 0;
          vr_cax_vlrtrfpj := 0;
           -- taa 
          vr_taa_qttotfat := 0;
          vr_taa_vltotfat := 0;
          vr_taa_vlrecliq := 0;
          vr_taa_vltrfuni := 0;
          vr_taa_vlrliqpf := 0;
          vr_taa_vlrliqpj := 0;
          vr_taa_vlrtrfpf := 0;
          vr_taa_vlrtrfpj := 0;
           -- deb automatico 
          vr_deb_qttotfat := 0;
          vr_deb_vltotfat := 0;
          vr_deb_vlrecliq := 0;
          vr_deb_vltrfuni := 0;
          vr_deb_vlrliqpf := 0;
          vr_deb_vlrliqpj := 0;
          vr_deb_vlrtrfpf := 0;
          vr_deb_vlrtrfpj := 0;

  FOR i IN vr_tab_rel635.FIRST .. vr_tab_rel635.LAST 
      LOOP
        if vr_tab_rel635.count = 1 then 
          -- Gerar Relatorio
          -- Inicializar o CLOB
          vr_des_xml := NULL;
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          -- Inicilizar as informações do XML
          vr_texto_completo := NULL;
          pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl635>'); 
        end if;
       IF  vr_tab_rel635(i).tpmeiarr = 'D' THEN
            -- TOTAIS INTERNET 
                vr_int_vltotfat := vr_int_vltotfat + vr_tab_rel635(i).vltotfat;
                vr_int_qttotfat := vr_int_qttotfat + vr_tab_rel635(i).qtfatura;
                vr_int_vltrfuni := vr_int_vltrfuni + vr_tab_rel635(i).vltottar;
                vr_int_vlrecliq := vr_int_vlrecliq + vr_tab_rel635(i).vlrecliq;

                -- Divisao PF/PJ 
                vr_int_vlrtrfpf := vr_int_vlrtrfpf + vr_tab_rel635(i).vlrtrfpf; 
                vr_int_vlrliqpf := vr_int_vlrliqpf + vr_tab_rel635(i).vlrliqpf;
                vr_int_vlrtrfpj := vr_int_vlrtrfpj + vr_tab_rel635(i).vlrtrfpj; 
                vr_int_vlrliqpj := vr_int_vlrliqpj + vr_tab_rel635(i).vlrliqpj;
       END IF;
       IF  vr_tab_rel635(i).tpmeiarr = 'C' THEN
            -- TOTAIS CAIXA 
               vr_cax_vltrfuni := vr_cax_vltrfuni + vr_tab_rel635(i).vltottar;
               vr_cax_vltotfat := vr_cax_vltotfat + vr_tab_rel635(i).vltotfat;
               vr_cax_qttotfat := vr_cax_qttotfat + vr_tab_rel635(i).qtfatura;
               vr_cax_vlrecliq := vr_cax_vlrecliq + vr_tab_rel635(i).vlrecliq;

            -- Divisao PF/PJ 
                vr_cax_vlrtrfpf := vr_cax_vlrtrfpf + vr_tab_rel635(i).vlrtrfpf; 
                vr_cax_vlrliqpf := vr_cax_vlrliqpf + vr_tab_rel635(i).vlrliqpf;
                vr_cax_vlrtrfpj := vr_cax_vlrtrfpj + vr_tab_rel635(i).vlrtrfpj; 
                vr_cax_vlrliqpj := vr_cax_vlrliqpj + vr_tab_rel635(i).vlrliqpj;
       END IF;
       IF  vr_tab_rel635(i).tpmeiarr = 'A' THEN
            -- TOTAIS TAA
            vr_taa_vltrfuni := vr_taa_vltrfuni + vr_tab_rel635(i).vltottar;
            vr_taa_vltotfat := vr_taa_vltotfat + vr_tab_rel635(i).vltotfat;
            vr_taa_qttotfat := vr_taa_qttotfat + vr_tab_rel635(i).qtfatura;
            vr_taa_vlrecliq := vr_taa_vlrecliq + vr_tab_rel635(i).vlrecliq;
            -- Divisao PF/PJ 
            vr_taa_vlrtrfpf := vr_taa_vlrtrfpf + vr_tab_rel635(i).vlrtrfpf; 
            vr_taa_vlrliqpf := vr_taa_vlrliqpf + vr_tab_rel635(i).vlrliqpf;
            vr_taa_vlrtrfpj := vr_taa_vlrtrfpj + vr_tab_rel635(i).vlrtrfpj; 
            vr_taa_vlrliqpj := vr_taa_vlrliqpj + vr_tab_rel635(i).vlrliqpj;
       END IF;
       IF  vr_tab_rel635(i).tpmeiarr = 'E' THEN
             -- TOTAIS DEB AUTOMATICO 
            vr_deb_vltrfuni := vr_deb_vltrfuni + vr_tab_rel635(i).vltottar;
            vr_deb_vltotfat := vr_deb_vltotfat + vr_tab_rel635(i).vltotfat;
            vr_deb_qttotfat := vr_deb_qttotfat + vr_tab_rel635(i).qtfatura;
            vr_deb_vlrecliq := vr_deb_vlrecliq + vr_tab_rel635(i).vlrecliq;

            -- Divisao PF/PJ 
            vr_deb_vlrtrfpf := vr_deb_vlrtrfpf + vr_tab_rel635(i).vlrtrfpf;
            vr_deb_vlrliqpf := vr_deb_vlrliqpf + vr_tab_rel635(i).vlrliqpf;
            vr_deb_vlrtrfpj := vr_deb_vlrtrfpj + vr_tab_rel635(i).vlrtrfpj;
            vr_deb_vlrliqpj := vr_deb_vlrliqpj + vr_tab_rel635(i).vlrliqpj;
       END IF;
       
           -- TOTAL GERAL 
           vr_tot_vltotfat := vr_tot_vltotfat + vr_tab_rel635(i).vltotfat;
           vr_tot_qttotfat := vr_tot_qttotfat + vr_tab_rel635(i).qtfatura;
           vr_tot_vltrfuni := vr_tot_vltrfuni + vr_tab_rel635(i).vltottar;
           vr_tot_vlrecliq := vr_tot_vlrecliq + vr_tab_rel635(i).vlrecliq;

           -- Divisao PF/PJ 
           vr_tot_vlrtrfpf := vr_tot_vlrtrfpf + vr_tab_rel635(i).vlrtrfpf;
           vr_tot_vlrliqpf := vr_tot_vlrliqpf + vr_tab_rel635(i).vlrliqpf;
           vr_tot_vlrtrfpj := vr_tot_vlrtrfpj + vr_tab_rel635(i).vlrtrfpj;
           vr_tot_vlrliqpj := vr_tot_vlrliqpj + vr_tab_rel635(i).vlrliqpj;

          -- Corrige valores negativos 
          IF  vr_tab_rel635(i).vltotfat < 0 THEN
              vr_tab_rel635(i).vltotfat := 0;
          END IF;
          IF  vr_tab_rel635(i).vlrecliq < 0 THEN
              vr_tab_rel635(i).vlrecliq := 0;
          END IF;    
          IF  vr_tab_rel635(i).vltottar < 0 THEN
              vr_tab_rel635(i).vltottar := 0;
          END IF;    
          IF  vr_tab_rel635(i).vlrtrfpf < 0 THEN
              vr_tab_rel635(i).vlrtrfpf := 0;
          END IF;    
          IF  vr_tab_rel635(i).vlrliqpf < 0 THEN
              vr_tab_rel635(i).vlrliqpf := 0;
          END IF;    
          IF  vr_tab_rel635(i).vlrtrfpj < 0 THEN
              vr_tab_rel635(i).vlrtrfpj := 0;
          END IF;    
          IF  vr_tab_rel635(i).vlrliqpj < 0 THEN
              vr_tab_rel635(i).vlrliqpj := 0;
          END IF;    
         -- Exibe Totais por Coluna 
         pc_escreve_xml(
                   '<coluna>' ||
                   '<dsmeiarr>'||vr_tab_rel635(i).dsmeiarr   ||'</dsmeiarr>'||
                   '<qtfatura>'||vr_tab_rel635(i).qtfatura   ||'</qtfatura>'||
                   '<vltotfat>'||to_char(vr_tab_rel635(i).vltotfat,'fm999G999G999G999G990d00') ||'</vltotfat>'||
                   '<vlrecliq>'||to_char(vr_tab_rel635(i).vlrecliq,'fm999G999G999G999G990d00') ||'</vlrecliq>'||
                   '<vltottar>'||to_char(vr_tab_rel635(i).vltottar,'fm999G999G999G999G990d00') ||'</vltottar>'||
                   '<vlrtrfpf>'||to_char(vr_tab_rel635(i).vlrtrfpf,'fm999G999G999G999G990d00') ||'</vlrtrfpf>'||
                   '<vlrliqpf>'||to_char(vr_tab_rel635(i).vlrliqpf,'fm999G999G999G999G990d00') ||'</vlrliqpf>'||
                   '<vlrtrfpj>'||to_char(vr_tab_rel635(i).vlrtrfpj,'fm999G999G999G999G990d00') ||'</vlrtrfpj>'||
                   '<vlrliqpj>'||to_char(vr_tab_rel635(i).vlrliqpj,'fm999G999G999G999G990d00') ||'</vlrliqpj>'||
                   '<nrrenorm>'||vr_tab_rel635(i).nrrenorm   ||'</nrrenorm>'||
                   '<dsdianor>'||vr_tab_rel635(i).qtfatura   ||'</dsdianor>'||
                   '</coluna>');

                
      
      END LOOP;
        
         -- Exibe Totais por Coluna 
         pc_escreve_xml(
                   '<totais>' ||
                   --internet
                   '<int_qttotfat>'||vr_int_qttotfat   ||'</int_qttotfat>'||
                   '<int_vltotfat>'||to_char(vr_int_vltotfat,'fm999G999G999G999G990d00')||'</int_vltotfat>'||
                   '<int_vlrecliq>'||to_char(vr_int_vlrecliq,'fm999G999G999G999G990d00')||'</int_vlrecliq>'||
                   '<int_vltrfuni>'||to_char(vr_int_vltrfuni,'fm999G999G999G999G990d00')||'</int_vltrfuni>'||
                   '<int_vlrtrfpf>'||to_char(vr_int_vlrtrfpf,'fm999G999G999G999G990d00')||'</int_vlrtrfpf>'||
                   '<int_vlrliqpf>'||to_char(vr_int_vlrliqpf,'fm999G999G999G999G990d00') ||'</int_vlrliqpf>'||
                   '<int_vlrliqpj>'||to_char(vr_int_vlrliqpj,'fm999G999G999G999G990d00') ||'</int_vlrliqpj>'||
                   -- caixa 
                   '<cax_qttotfat>'||vr_cax_qttotfat ||'</cax_qttotfat>'||
                   '<cax_vltotfat>'||to_char(vr_cax_vltotfat,'fm999G999G999G999G990d00') ||'</cax_vltotfat>'||
                   '<cax_vlrecliq>'||to_char(vr_cax_vlrecliq,'fm999G999G999G999G990d00') ||'</cax_vlrecliq>'||
                   '<cax_vltrfuni>'||to_char(vr_cax_vltrfuni,'fm999G999G999G999G990d00') ||'</cax_vltrfuni>'||
                   '<cax_vlrtrfpf>'||to_char(vr_cax_vlrtrfpf,'fm999G999G999G999G990d00') ||'</cax_vlrtrfpf>'||
                   '<cax_vlrtrfpj>'||to_char(vr_cax_vlrtrfpj,'fm999G999G999G999G990d00') ||'</cax_vlrtrfpj>'||
                   '<cax_vlrliqpf>'||to_char(vr_cax_vlrliqpf,'fm999G999G999G999G990d00') ||'</cax_vlrliqpf>'||
                   '<cax_vlrliqpj>'||to_char(vr_cax_vlrliqpj,'fm999G999G999G999G990d00') ||'</cax_vlrliqpj>'||
                   -- taa 
                   '<taa_qttotfat>'||vr_taa_qttotfat ||'</taa_qttotfat>'||
                   '<taa_vltotfat>'||to_char(vr_taa_vltotfat,'fm999G999G999G999G990d00') ||'</taa_vltotfat>'||
                   '<taa_vlrecliq>'||to_char(vr_taa_vlrecliq,'fm999G999G999G999G990d00') ||'</taa_vlrecliq>'||
                   '<taa_vltrfuni>'||to_char(vr_taa_vltrfuni,'fm999G999G999G999G990d00') ||'</taa_vltrfuni>'||
                   '<taa_vlrtrfpf>'||to_char(vr_taa_vlrtrfpf,'fm999G999G999G999G990d00') ||'</taa_vlrtrfpf>'||
                   '<taa_vlrtrfpj>'||to_char(vr_taa_vlrtrfpj,'fm999G999G999G999G990d00') ||'</taa_vlrtrfpj>'||
                   '<taa_vlrliqpf>'||to_char(vr_taa_vlrliqpf,'fm999G999G999G999G990d00') ||'</taa_vlrliqpf>'||
                   '<taa_vlrliqpj>'||to_char(vr_taa_vlrliqpj,'fm999G999G999G999G990d00') ||'</taa_vlrliqpj>'||
                   --Deb Auto
                   '<deb_qttotfat>'||vr_deb_qttotfat ||'</deb_qttotfat>'||
                   '<deb_vltotfat>'||to_char(vr_deb_vltotfat,'fm999G999G999G999G990d00') ||'</deb_vltotfat>'||
                   '<deb_vlrecliq>'||to_char(vr_deb_vlrecliq,'fm999G999G999G999G990d00') ||'</deb_vlrecliq>'||
                   '<deb_vltrfuni>'||to_char(vr_deb_vltrfuni,'fm999G999G999G999G990d00') ||'</deb_vltrfuni>'||
                   '<deb_vlrtrfpf>'||to_char(vr_deb_vlrtrfpf,'fm999G999G999G999G990d00') ||'</deb_vlrtrfpf>'||
                   '<deb_vlrtrfpj>'||to_char(vr_deb_vlrtrfpj,'fm999G999G999G999G990d00') ||'</deb_vlrtrfpj>'||
                   '<deb_vlrliqpf>'||to_char(vr_deb_vlrliqpf,'fm999G999G999G999G990d00') ||'</deb_vlrliqpf>'||
                   '<deb_vlrliqpj>'||to_char(vr_deb_vlrliqpj,'fm999G999G999G999G990d00') ||'</deb_vlrliqpj>'||
                   -- total geral 
                   '<tot_vltrfuni>'||to_char(vr_tot_vltrfuni,'fm999G999G999G999G990d00') ||'</tot_vltrfuni>'||
                   '<tot_vltotfat>'||to_char(vr_tot_vltotfat,'fm999G999G999G999G990d00') ||'</tot_vltotfat>'||
                   '<tot_vlrecliq>'||to_char(vr_tot_vlrecliq,'fm999G999G999G999G990d00') ||'</tot_vlrecliq>'||
                   '<tot_qttotfat>'||vr_tot_qttotfat ||'</tot_qttotfat>'||
                   '<tot_vlrtrfpf>'||to_char(vr_tot_vlrtrfpf,'fm999G999G999G999G990d00') ||'</tot_vlrtrfpf>'||
                   '<tot_vlrtrfpj>'||to_char(vr_tot_vlrtrfpj,'fm999G999G999G999G990d00') ||'</tot_vlrtrfpj>'||
                   '<tot_vlrliqpf>'||to_char(vr_tot_vlrliqpf,'fm999G999G999G999G990d00') ||'</tot_vlrliqpf>'||
                   '<tot_vlrliqpj>'||to_char(vr_tot_vlrliqpj,'fm999G999G999G999G990d00') ||'</tot_vlrliqpj>'||
                   '</totais>');
           pc_escreve_xml('</crrl635>');
           
           pr_tot_vlrtrfpf := vr_tot_vlrliqpf;
           pr_tot_vlrtrfpj := vr_tot_vlrliqpj;
           ----------------- gerar relatório -----------------
           -- Busca do diretório base da cooperativa para PDF
           vr_caminho_integra := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                      ,pr_cdcooper => pr_cdcooper
                                                      ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

           -- Efetuar solicitação de geração de relatório --

            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                      ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                      ,pr_dsxmlnode => '/crrl635'          --> Nó base do XML para leitura dos dados
                                      ,pr_dsjasper  => 'crrl635.jasper'    --> Arquivo de layout do iReport
                                      ,pr_dsparams  => NULL                --> Sem parametros
                                      ,pr_dsarqsaid => vr_caminho_integra||'/crrl635.lst' --> Arquivo final com código da agência
                                      ,pr_qtcoluna  => 132                 --> 132 colunas
                                      ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                      ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                      ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                      ,pr_nrcopias  => 1                   --> Número de cópias
                                      ,pr_flg_gerar => 'S'                 --> gerar PDF
                                       ,pr_des_erro  => vr_dscritic);       --> Saída com erro


 -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;
     -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
     
                  

end loop;
   
  end pc_executa_rel_mensais;

BEGIN
--------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
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
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF nvl(vr_cdcritic,0) <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
------------------------- REGRAS DO PROGRAMA ------------------------- 
  /* Tipos de Arrecadaçao SICREDI
   A - ATM
   B - Correspondente Bancário
   C - Caixa
   D - Internet Banking
   E - Debito Auto
   F - Arquivo de Pagamento (CNAB 240)  */
 
    OPEN cr_crapthi(pr_cdcooper,
                    1154);
    FETCH cr_crapthi INTO rw_crapthi;
    
    IF cr_crapthi%NOTFOUND THEN
      CLOSE cr_crapthi;
    END IF;
    
    OPEN cr_crapthi1(pr_cdcooper);
    FETCH cr_crapthi1 INTO rw_crapthi1;
    
    IF cr_crapthi1%NOTFOUND THEN
      CLOSE cr_crapthi1;
      
    END IF;
    -- Leitura para Convenios e DARFs 
    FOR RW_craplft IN cr_craplft(pr_cdcooper,
                                 rw_crapdat.dtmvtolt) loop
     vr_tot_qtfatint := 0;
     vr_tot_vlfatint := 0;
     vr_tot_qtfattaa := 0;
     vr_tot_vlfattaa := 0;
     vr_tot_qtfatcxa := 0;
     vr_tot_vlfatcxa := 0;

    IF  rw_craplft.tpfatura <> 2  OR
        rw_craplft.cdempcon <> 0  THEN
                 -- Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras            
                 if cr_crapscn%isopen then 
                    close cr_crapscn;
                 end if;
                 open cr_crapscn(rw_craplft.cdempcon,
                                 TO_CHAR(rw_craplft.cdsegmto));
                 FETCH cr_crapscn 
                 into rw_crapscn;
                 if cr_crapscn%notfound then
                    exit;
                    close cr_crapscn;
                 end if;  
 
    ELSE
      if rw_craplft.cdtribut = '6106' THEN -- DARF SIMPLES 
           begin          
              select crapscn.cdempres 
                    into 
                    vr_darf from crapscn
                       where crapscn.cdempres = 'D0';
            exception 
             when others then 
                vr_darf := null;           
           end;            
      ELSE
            -- DARF PRETO EUROPA 
            begin          
              select crapscn.cdempres 
                    into 
                    vr_darf from crapscn
                       where crapscn.cdempres = 'A0';
            exception 
             when others then 
                vr_darf := null;           
           end;
      end if;
    -- Se ler DARF NUMERADO ou DAS assumir tarifa de 0.16 
    IF  rw_craplft.tpfatura >= 1 THEN
        vr_aux_vltarfat := rw_crapcop.vltardrf; -- 0.16 era o valor antigo
    ELSE
        vr_aux_vltarfat := rw_crapthi.vltarifa;
    END IF;
    
    IF  rw_craplft.cdagenci = 90 THEN  -- Internet 
            vr_tot_qtfatint := vr_tot_qtfatint + 1;
            vr_tot_vlfatint := vr_tot_vlfatint + (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
    ELSE
      IF rw_craplft.cdagenci = 91 THEN  -- TAA 
            vr_tot_qtfattaa := vr_tot_qtfattaa + 1;
            vr_tot_vlfattaa := vr_tot_vlfattaa + (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
      ELSE                               -- Caixa 
         vr_tot_qtfatcxa := vr_tot_qtfatcxa + 1;
         vr_tot_vlfatcxa := vr_tot_vlfatcxa + (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
	    END IF;
    END IF;
    -- INTERNET 
           if cr_crapstn%isopen then 
                   close cr_crapstn;
           end if;   
                
           Open cr_crapstn(rw_crapscn.cdempres,
                           null);
           fetch cr_crapstn into rw_crapstn;
           
           if cr_crapstn%notfound then 
              close cr_crapstn;
           end if;   
           
              vr_ind_rel634 := rw_crapscn.cdempres||rw_crapstn.tpmeiarr;
               --Internet  
               if vr_tot_qtfatint > 0 and
                  rw_crapstn.tpmeiarr = 'D' then  
                
                 if vr_tab_rel634.exists(vr_ind_rel634) then 
                   
                     vr_tab_rel634(vr_ind_rel634).qttotfat := vr_tab_rel634(vr_ind_rel634).qttotfat + vr_tot_qtfatint;
                     vr_tab_rel634(vr_ind_rel634).vltotfat := vr_tab_rel634(vr_ind_rel634).vltotfat + vr_tot_vlfatint;
                     vr_tab_rel634(vr_ind_rel634).vltrfuni := vr_tab_rel634(vr_ind_rel634).vltrfuni + (rw_crapstn.vltrfuni * vr_tot_qtfatint);
                     vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vlrecliq + (vr_tab_rel634(vr_ind_rel634).vltrfuni - (vr_tot_qtfatint * rw_crapthi.vltarifa));
                                
                 else
                   -- Criar um registro no vetor de Rel634
                     vr_tab_rel634(vr_ind_rel634).nmconven := rw_crapscn.dsnomcnv;
                     vr_tab_rel634(vr_ind_rel634).cdempres := rw_crapscn.cdempres;
                     vr_tab_rel634(vr_ind_rel634).tpmeiarr := rw_crapstn.tpmeiarr;
                     vr_tab_rel634(vr_ind_rel634).dsdianor := rw_crapscn.dsdianor;
                     vr_tab_rel634(vr_ind_rel634).nrrenorm := rw_crapscn.nrrenorm;
                     vr_tab_rel634(vr_ind_rel634).qttotfat := vr_tot_qtfatint;
                     vr_tab_rel634(vr_ind_rel634).vltotfat := vr_tot_vlfatint;
                     vr_tab_rel634(vr_ind_rel634).vltrfuni := (rw_crapstn.vltrfuni * vr_tot_qtfatint);
                     vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vltrfuni - (vr_tot_qtfatint * rw_crapthi.vltarifa);
                     vr_tab_rel634(vr_ind_rel634).dsmeiarr := 'INTERNET'; 
                 end if;   
               --TAA  
               elsif vr_tot_qtfattaa > 0 and
                  rw_crapstn.tpmeiarr = 'A' then  
                  if vr_tab_rel634.exists(vr_ind_rel634) then 
                     
                     vr_tab_rel634(vr_ind_rel634).qttotfat := vr_tab_rel634(vr_ind_rel634).qttotfat + vr_tot_qtfattaa;
                     vr_tab_rel634(vr_ind_rel634).vltotfat := vr_tab_rel634(vr_ind_rel634).vltotfat + vr_tot_vlfattaa;
                     vr_tab_rel634(vr_ind_rel634).vltrfuni := vr_tab_rel634(vr_ind_rel634).vltrfuni + (rw_crapstn.vltrfuni * vr_tot_qtfattaa);
                     vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vlrecliq + (vr_tab_rel634(vr_ind_rel634).vltrfuni - (vr_tot_qtfattaa * rw_crapthi.vltarifa));
                  
                  else   
                     vr_tab_rel634(vr_ind_rel634).nmconven := rw_crapscn.dsnomcnv;
                     vr_tab_rel634(vr_ind_rel634).cdempres := rw_crapscn.cdempres;
                     vr_tab_rel634(vr_ind_rel634).tpmeiarr := rw_crapstn.tpmeiarr;
                     vr_tab_rel634(vr_ind_rel634).dsdianor := rw_crapscn.dsdianor;
                     vr_tab_rel634(vr_ind_rel634).nrrenorm := rw_crapscn.nrrenorm;
                     vr_tab_rel634(vr_ind_rel634).qttotfat := vr_tot_qtfattaa;
                     vr_tab_rel634(vr_ind_rel634).vltotfat := vr_tot_vlfattaa;
                     vr_tab_rel634(vr_ind_rel634).vltrfuni := (rw_crapstn.vltrfuni * vr_tot_qtfattaa);
                     vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vltrfuni - (vr_tot_qtfattaa * rw_crapthi.vltarifa);
                     vr_tab_rel634(vr_ind_rel634).dsmeiarr := 'TAA'; 
                  end if;  
               --Caixa
               elsif vr_tot_qtfatcxa > 0 and
                  rw_crapstn.tpmeiarr = 'C' then  
                  if vr_tab_rel634.exists(vr_ind_rel634) then 
                  
                     vr_tab_rel634(vr_ind_rel634).qttotfat := vr_tab_rel634(vr_ind_rel634).qttotfat + vr_tot_qtfatcxa;
                     vr_tab_rel634(vr_ind_rel634).vltotfat := vr_tab_rel634(vr_ind_rel634).vltotfat + vr_tot_vlfatcxa;
                     vr_tab_rel634(vr_ind_rel634).vltrfuni := vr_tab_rel634(vr_ind_rel634).vltrfuni + (rw_crapstn.vltrfuni * vr_tot_qtfatcxa);
                     vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vlrecliq + (vr_tab_rel634(vr_ind_rel634).vltrfuni - (vr_tot_qtfatcxa * rw_crapthi.vltarifa));
               
                  else   
                     vr_tab_rel634(vr_ind_rel634).nmconven := rw_crapscn.dsnomcnv;
                     vr_tab_rel634(vr_ind_rel634).cdempres := rw_crapscn.cdempres;
                     vr_tab_rel634(vr_ind_rel634).tpmeiarr := rw_crapstn.tpmeiarr;
                     vr_tab_rel634(vr_ind_rel634).dsdianor := rw_crapscn.dsdianor;
                     vr_tab_rel634(vr_ind_rel634).nrrenorm := rw_crapscn.nrrenorm;
                     vr_tab_rel634(vr_ind_rel634).qttotfat := vr_tot_qtfatcxa;
                     vr_tab_rel634(vr_ind_rel634).vltotfat := vr_tot_vlfatcxa;
                     vr_tab_rel634(vr_ind_rel634).vltrfuni := (rw_crapstn.vltrfuni * vr_tot_qtfatcxa);
                     vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vltrfuni - (vr_tot_qtfatcxa * rw_crapthi.vltarifa);
                     vr_tab_rel634(vr_ind_rel634).dsmeiarr := 'CAIXA';
                  end if;     
               end if;              
               
     end if;
    end loop; -- FOR EACH craplft 
    for rw_craplcm in cr_craplcm(pr_cdcooper,
                                 rw_crapdat.dtmvtolt) loop
        if cr_craplau%isopen then 
           close cr_craplau;
        end if;                           
       
        Open cr_craplau(rw_craplcm.cdcooper,
                        rw_craplcm.cdhistor,
                        rw_craplcm.nrdocmto,
                        rw_craplcm.nrdconta,
                        rw_craplcm.cdagenci,
                        rw_craplcm.dtmvtolt);
        fetch cr_craplau into rw_craplau;
           
           if cr_craplau%notfound then
              continue; 
              close cr_craplau;
           end if;
           
         vr_tot_qtfatdeb := 0;
         vr_tot_vlfatdeb := 0;
         -- somatoria por empresa 
         for rw_crapscn1 in cr_crapscn1(rw_craplau.cdempres) loop
           
            vr_tot_qtfatdeb := vr_tot_qtfatdeb + 1;
            vr_tot_vlfatdeb := vr_tot_vlfatdeb + rw_craplcm.vllanmto;
            
         end loop;
         
         -- Se nao for debito automatico nao faz 
         if cr_crapscn2%isopen then 
            close cr_crapscn2;
         end if;
         open cr_crapscn2(rw_craplau.cdempres);
         fetch cr_crapscn2 into rw_crapscn2;
         if cr_crapscn2%notfound then
            continue;
            close cr_crapscn2;
         else 
          if cr_crapstn%isopen then 
             close cr_crapstn;
          end if;   
                 
          Open cr_crapstn(rw_crapscn.cdempres,
                          'E');
           fetch cr_crapstn into rw_crapstn;
           
           if cr_crapstn%notfound then 
              close cr_crapstn;
           else
             vr_ind_rel634 := rw_crapscn.cdempres||rw_crapstn.tpmeiarr;
             
                  if vr_tab_rel634.exists(vr_ind_rel634) then 
                     
                     vr_tab_rel634(vr_ind_rel634).qttotfat := vr_tab_rel634(vr_ind_rel634).qttotfat + vr_tot_qtfatdeb;
                     vr_tab_rel634(vr_ind_rel634).vltotfat := vr_tab_rel634(vr_ind_rel634).vltotfat + vr_tot_vlfatdeb;
                     vr_tab_rel634(vr_ind_rel634).vltrfuni := vr_tab_rel634(vr_ind_rel634).vltrfuni + (rw_crapstn.vltrfuni * vr_tot_qtfatdeb);
                     vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vlrecliq + (vr_tab_rel634(vr_ind_rel634).vltrfuni - (vr_tot_qtfatdeb * rw_crapthi.vltarifa));
                  
                  else   
                     vr_tab_rel634(vr_ind_rel634).nmconven := rw_crapscn.dsnomcnv;
                     vr_tab_rel634(vr_ind_rel634).cdempres := rw_crapscn.cdempres;
                     vr_tab_rel634(vr_ind_rel634).tpmeiarr := 'E';
                     vr_tab_rel634(vr_ind_rel634).dsdianor := rw_crapscn.dsdianor;
                     vr_tab_rel634(vr_ind_rel634).nrrenorm := rw_crapscn.nrrenorm;
                     vr_tab_rel634(vr_ind_rel634).qttotfat := vr_tot_qtfatdeb;
                     vr_tab_rel634(vr_ind_rel634).vltotfat := vr_tot_vlfatdeb;
                     vr_tab_rel634(vr_ind_rel634).vltrfuni := (rw_crapstn.vltrfuni * vr_tot_qtfatdeb);
                     vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vltrfuni - (vr_tot_qtfatdeb * rw_crapthi.vltarifa);
                     vr_tab_rel634(vr_ind_rel634).dsmeiarr := 'DEB. AUTOMATICO';
                  end if;      
           end if; 
         end if;
    end loop;

 IF pr_cdcooper <> 3 THEN

    -- GUIA DA PREVIDENVIA SOCIAL - SICREDI 

    -- Tarifa a ser paga ao SICREDI 
    if cr_crapthi%isopen then 
       close cr_crapthi;
    end if;
    OPEN cr_crapthi(pr_cdcooper,
                    1414);
    FETCH cr_crapthi INTO rw_crapthi;
    
    IF cr_crapthi%NOTFOUND THEN
      CLOSE cr_crapthi;
    END IF;
    
    IF cr_craptab%ISOPEN THEN 
         CLOSE cr_craptab;
    END IF;   
    -- Localizar a tarifa da base 
    open cr_craptab(pr_cdcooper,
                    'GPSCXASCOD');
    FETCH cr_craptab INTO rw_craptab;
    
    IF cr_craptab%NOTFOUND THEN
      CLOSE cr_craptab;
    END IF;

    
    IF rw_craptab.dstextab IS NOT NULL THEN
         vr_aux_vltfcxsb := rw_craptab.dstextab;  -- Valor Tarifa Caixa Com Sem.Barra 
    ELSE
         vr_aux_vltfcxsb := 0;
    END IF;     
    
      IF cr_craptab%ISOPEN THEN 
         CLOSE cr_craptab;
      END IF;   
      -- Localizar a tarifa da base 
      open cr_craptab(pr_cdcooper,
                      'GPSCXACCOD');
      FETCH cr_craptab INTO rw_craptab;
        
      IF cr_craptab%NOTFOUND THEN
        CLOSE cr_craptab;
      END IF;
      
      IF rw_craptab.dstextab IS NOT NULL THEN
           vr_aux_vltfcxsb := rw_craptab.dstextab;  -- Valor Tarifa Caixa Com Com.Barra
      ELSE
           vr_aux_vltfcxsb := 0;
      END IF;     
    
    -- Localizar a tarifa da base 
    IF cr_craptab%ISOPEN THEN 
      CLOSE cr_craptab;
    END IF;  
      -- Localizar a tarifa da base 
      open cr_craptab(pr_cdcooper,
                      'GPSINTBANK');
      FETCH cr_craptab INTO rw_craptab;
        
      IF cr_craptab%NOTFOUND THEN
        CLOSE cr_craptab;
      END IF;
      
      IF rw_craptab.dstextab IS NOT NULL THEN
           vr_aux_vltfcxsb := rw_craptab.dstextab;  -- Valor Tarifa IB
      ELSE
           vr_aux_vltfcxsb := 0;
      END IF;     
    
    
    -- Para todos os lancamentos ja pagos 
    for rw_craplgp in cr_craplgp(pr_cdcooper,
                                 rw_crapdat.dtmvtolt) loop

        -- Inicializa Variaveis 
               vr_aux_dsempgps := null;
               vr_aux_dsnomcnv := null;
               vr_aux_tpmeiarr := null;
               vr_aux_dsmeiarr := null;
               vr_aux_vltargps := 0;

        IF  rw_craplgp.cdagenci <> 90 THEN -- CAIXA
             vr_aux_tpmeiarr := 'C';
             vr_aux_dsmeiarr := 'CAIXA';
              IF rw_craplgp.tpdpagto = 1 THEN -- Com Cod.Barras
                 vr_aux_vltargps := vr_aux_vltfcxcb;
              ELSE -- Sem Cod.Barras
                 vr_aux_vltargps := vr_aux_vltfcxsb;
              end if;
        ELSE -- INTERNET 
            vr_aux_tpmeiarr := 'D';
            vr_aux_dsmeiarr := 'INTERNET';
            vr_aux_vltargps := vr_aux_vlrtrfib;
            IF  rw_craplgp.tpdpagto = 1 THEN -- Com Cod.Barras
                vr_aux_dsempgps := 'GP1';
                vr_aux_dsnomcnv := 'GPS - COM COD.BARRAS';
                
            ELSE -- Sem Cod.Barras
                vr_aux_dsempgps := 'GP2';
                vr_aux_dsnomcnv := 'GPS - SEM COD.BARRAS';
            end if;  
        end if;    
            vr_ind_rel634 := rw_crapscn.cdempres||vr_aux_tpmeiarr;
             
                  if vr_tab_rel634.exists(vr_ind_rel634) then 
                    
                     vr_tab_rel634(vr_ind_rel634).qttotfat := vr_tab_rel634(vr_ind_rel634).qttotfat + 1;
                     vr_tab_rel634(vr_ind_rel634).vltotfat := vr_tab_rel634(vr_ind_rel634).vltotfat + rw_craplgp.vlrtotal;
                     vr_tab_rel634(vr_ind_rel634).vltrfuni := vr_tab_rel634(vr_ind_rel634).vltrfuni + vr_aux_vltargps;
                     vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vlrecliq + (vr_aux_vltargps - rw_crapthi.vltarifa);
                  else   
                     vr_tab_rel634(vr_ind_rel634).nmconven := rw_crapscn.dsnomcnv;
                     vr_tab_rel634(vr_ind_rel634).cdempres := vr_aux_dsempgps;
                     vr_tab_rel634(vr_ind_rel634).tpmeiarr := vr_aux_tpmeiarr;
                     vr_tab_rel634(vr_ind_rel634).dsdianor := '';
                     vr_tab_rel634(vr_ind_rel634).nrrenorm := 0;
                     vr_tab_rel634(vr_ind_rel634).qttotfat := 1;
                     vr_tab_rel634(vr_ind_rel634).vltotfat := rw_craplgp.vlrtotal;
                     vr_tab_rel634(vr_ind_rel634).vltrfuni := vr_aux_vltargps;
                     vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vltrfuni - rw_crapthi.vltarifa;
                     vr_tab_rel634(vr_ind_rel634).dsmeiarr := vr_aux_dsmeiarr;
                  end if;      
      
    END LOOP; -- Fim do FOR - CRAPLGP 
 ELSE
    -- GUIA DA PREVIDENVIA SOCIAL - SICREDI - TODAS COOP'S 

    -- Tarifa a ser paga ao SICREDI 
    FOR RW_craplgp1 IN CR_craplgp1(rw_crapdat.Dtmvtolt) LOOP
          
          OPEN cr_crapthi(pr_cdcooper,
                          1414);
          FETCH cr_crapthi INTO rw_crapthi;
          
          IF cr_crapthi%NOTFOUND THEN
            CLOSE cr_crapthi;
          END IF;
            
            IF cr_craptab%ISOPEN THEN 
               CLOSE cr_craptab;
            END IF;   
            -- Localizar a tarifa da base 
            open cr_craptab(pr_cdcooper,
                            'GPSCXASCOD');
            FETCH cr_craptab INTO rw_craptab;
            
            IF cr_craptab%NOTFOUND THEN
              CLOSE cr_craptab;
            END IF;
            IF rw_craptab.dstextab IS NOT NULL THEN
                 vr_aux_vltfcxsb := rw_craptab.dstextab;  -- Valor Tarifa Caixa Com Sem.Barra 
            ELSE
                 vr_aux_vltfcxsb := 0;
            END IF;     
            
            -- Localizar a tarifa da base 
            IF cr_craptab%ISOPEN THEN 
               CLOSE cr_craptab;
            END IF;
            -- Localizar a tarifa da base 
            open cr_craptab(pr_cdcooper,
                            'GPSCXACCOD');
            FETCH cr_craptab INTO rw_craptab;
              
            IF cr_craptab%NOTFOUND THEN
              CLOSE cr_craptab;
            END IF;
          	
            IF rw_craptab.dstextab IS NOT NULL THEN
                 vr_aux_vltfcxsb := rw_craptab.dstextab;  -- Valor Tarifa Caixa Com Com.Barra 
            ELSE
                 vr_aux_vltfcxsb := 0;
            END IF;     
            
            -- Localizar a tarifa da base 
            IF cr_craptab%ISOPEN THEN 
               CLOSE cr_craptab;
            END IF;
            -- Localizar a tarifa da base 
            open cr_craptab(pr_cdcooper,
                            'GPSINTBANK');
            FETCH cr_craptab INTO rw_craptab;
              
            IF cr_craptab%NOTFOUND THEN
              CLOSE cr_craptab;
            END IF;
            
            IF rw_craptab.dstextab IS NOT NULL THEN
                 vr_aux_vltfcxsb := rw_craptab.dstextab;  -- Valor Tarifa IB
            ELSE
                 vr_aux_vltfcxsb := 0;
            END IF;     

            -- Inicializa Variaveis 
            vr_aux_dsempgps := NULL;
            vr_aux_dsnomcnv := null;
            vr_aux_tpmeiarr := null;
            vr_aux_dsmeiarr := null;
            vr_aux_vltargps := 0;

            IF  rw_craplgp1.cdagenci <> 90 THEN -- CAIXA
                vr_aux_tpmeiarr := 'C';
                vr_aux_dsmeiarr := 'CAIXA';
                 IF rw_craplgp1.tpdpagto = 1 THEN -- Com Cod.Barras
                    vr_aux_vltargps := vr_aux_vltfcxcb;
                 ELSE -- Sem Cod.Barras
                    vr_aux_vltargps := vr_aux_vltfcxsb;
                 end if;   
                
            ELSE -- INTERNET 
                vr_aux_tpmeiarr := 'D';
                vr_aux_dsmeiarr := 'INTERNET';
                vr_aux_vltargps := vr_aux_vlrtrfib;
                
                IF rw_craplgp1.tpdpagto = 1 THEN -- Com Cod.Barras
                   vr_aux_dsempgps := 'GP1';
                   vr_aux_dsnomcnv := 'GPS - COM COD.BARRAS';
                ELSE -- Sem Cod.Barras
                   vr_aux_dsempgps := 'GP2';
                   vr_aux_dsnomcnv := 'GPS - SEM COD.BARRAS';
                end if;   
            END IF;
            
             vr_ind_rel634 := rw_crapscn.cdempres||vr_aux_tpmeiarr;
                 if vr_tab_rel634.exists(vr_ind_rel634) then 
  
                    vr_tab_rel634(vr_ind_rel634).qttotfat := vr_tab_rel634(vr_ind_rel634).qttotfat + 1;
                    vr_tab_rel634(vr_ind_rel634).vltotfat := vr_tab_rel634(vr_ind_rel634).vltotfat + rw_craplgp1.vlrtotal;
                    vr_tab_rel634(vr_ind_rel634).vltrfuni := vr_tab_rel634(vr_ind_rel634).vltrfuni + vr_aux_vltargps;
                    vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vlrecliq + (vr_aux_vltargps - rw_crapthi.vltarifa);

                  else   
                     vr_tab_rel634(vr_ind_rel634).nmconven := rw_crapscn.dsnomcnv;
                     vr_tab_rel634(vr_ind_rel634).cdempres := vr_aux_dsempgps;
                     vr_tab_rel634(vr_ind_rel634).tpmeiarr := vr_aux_tpmeiarr;
                     vr_tab_rel634(vr_ind_rel634).dsdianor := '';
                     vr_tab_rel634(vr_ind_rel634).nrrenorm := 0;
                     vr_tab_rel634(vr_ind_rel634).qttotfat := 1;
                     vr_tab_rel634(vr_ind_rel634).vltotfat := rw_craplgp1.vlrtotal;
                     vr_tab_rel634(vr_ind_rel634).vltrfuni := vr_aux_vltargps;
                     vr_tab_rel634(vr_ind_rel634).vlrecliq := vr_tab_rel634(vr_ind_rel634).vltrfuni - rw_crapthi.vltarifa;
                     vr_tab_rel634(vr_ind_rel634).dsmeiarr := vr_aux_dsmeiarr;
                  end if;      
        
       
        
    END LOOP; -- Fim do FOR - CRAPLGP 

 END IF; -- Fim do IF glb_cdcooper <> 3 

-- zerar variaveis dos totais 
   	   -- internet 
        vr_int_qttotfat := 0;
        vr_int_vltotfat := 0;
        vr_int_vlrecliq := 0;
        vr_int_vltrfuni := 0;
       -- caixa
        vr_cax_qttotfat := 0;
        vr_cax_vltotfat := 0;
        vr_cax_vlrecliq := 0;
        vr_cax_vltrfuni := 0;
        -- taa              
        vr_taa_qttotfat := 0;
        vr_taa_vltotfat := 0;
        vr_taa_vlrecliq := 0;
        vr_taa_vltrfuni := 0;
        -- deb automatico   
        vr_deb_qttotfat := 0;
        vr_deb_vltotfat := 0;
        vr_deb_vlrecliq := 0;
        vr_deb_vltrfuni := 0;
   
   indice := vr_tab_rel634.first;
   -- Percorrer os rel634
    FOR vr_contador IN 1..vr_tab_rel634.count LOOP
         
        if vr_contador = 1 then 
            -- Gerar Relatorio
            -- Inicializar o CLOB
            vr_des_xml := NULL;
            dbms_lob.createtemporary(vr_des_xml, TRUE);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

            -- Inicilizar as informações do XML
            vr_texto_completo := NULL;
            pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl634>');
        end if;    
      
      IF vr_tab_rel634(indice).tpmeiarr = 'D' THEN 
          -- TOTAIS INTERNET 
         vr_int_vltrfuni := vr_int_vltrfuni + vr_tab_rel634(indice).vltrfuni;
         vr_int_vltotfat := vr_int_vltotfat + vr_tab_rel634(indice).vltotfat;
         vr_int_qttotfat := vr_int_qttotfat + vr_tab_rel634(indice).qttotfat;
         vr_int_vlrecliq := vr_int_vlrecliq + vr_tab_rel634(indice).vlrecliq;
      END IF;  
      
      IF vr_tab_rel634(indice).tpmeiarr = 'C' THEN 
          -- TOTAIS CAIXA
         vr_cax_vltrfuni := vr_cax_vltrfuni + vr_tab_rel634(indice).vltrfuni;
         vr_cax_vltotfat := vr_cax_vltotfat + vr_tab_rel634(indice).vltotfat;
         vr_cax_qttotfat := vr_cax_qttotfat + vr_tab_rel634(indice).qttotfat;
         vr_cax_vlrecliq := vr_cax_vlrecliq + vr_tab_rel634(indice).vlrecliq;
      END IF;  
      
      IF vr_tab_rel634(indice).tpmeiarr = 'A' THEN 
          -- TOTAIS TAA
         vr_taa_vltrfuni := vr_taa_vltrfuni + vr_tab_rel634(indice).vltrfuni;
         vr_taa_vltotfat := vr_taa_vltotfat + vr_tab_rel634(indice).vltotfat;
         vr_taa_qttotfat := vr_taa_qttotfat + vr_tab_rel634(indice).qttotfat;
         vr_taa_vlrecliq := vr_taa_vlrecliq + vr_tab_rel634(indice).vlrecliq;
      END IF;  

      IF vr_tab_rel634(indice).tpmeiarr = 'E' THEN 
          -- TOTAIS DEB AUTOMATICO
         vr_deb_vltrfuni := vr_deb_vltrfuni + vr_tab_rel634(indice).vltrfuni;
         vr_deb_vltotfat := vr_deb_vltotfat + vr_tab_rel634(indice).vltotfat;
         vr_deb_qttotfat := vr_deb_qttotfat + vr_tab_rel634(indice).qttotfat;
         vr_deb_vlrecliq := vr_deb_vlrecliq + vr_tab_rel634(indice).vlrecliq;
      END IF; 
      
      -- Corrige valores negativos 
      IF  vr_tab_rel634(indice).vltotfat < 0 THEN
          vr_tab_rel634(indice).vltotfat := 0;
      END IF;    
      
      IF  vr_tab_rel634(indice).vlrecliq < 0 THEN
          vr_tab_rel634(indice).vlrecliq := 0;
      END IF; 
      
      IF  vr_tab_rel634(indice).vltrfuni < 0 THEN
          vr_tab_rel634(indice).vltrfuni := 0;
      END IF; 
    
        pc_escreve_xml(
               '<coluna>' ||
                 '<nmconven>'||  vr_tab_rel634(indice).nmconven                                   ||'</nmconven>'||
                 '<dsmeiarr>'||  vr_tab_rel634(indice).dsmeiarr                                   ||'</dsmeiarr>'||
                 '<qttotfat>'||  nvl(vr_tab_rel634(indice).qttotfat,0)                                  ||'</qttotfat>'||
                 '<vltotfat>'||to_char(nvl(vr_tab_rel634(indice).vltotfat,0),'fm999G999G999G999G990d00') ||'</vltotfat>'|| 
                 '<vlrecliq>'||to_char(nvl(vr_tab_rel634(indice).vlrecliq,0),'fm999G999G999G999G990d00') ||'</vlrecliq>'|| 
                 '<vltrfuni>'||to_char(nvl(vr_tab_rel634(indice).vltrfuni,0),'fm999G999G999G999G990d00') ||'</vltrfuni>'|| 
                 '<vltrfsic>'||to_char(nvl(vr_tab_rel634(indice).vltrfsic,0),'fm999G999G999G999G990d00') ||'</vltrfsic>'|| 
                 '<nrrenorm>'||  nvl(vr_tab_rel634(indice).nrrenorm,0)                                   ||'</nrrenorm>'||
                 '<dsdianor>'||  vr_tab_rel634(indice).dsdianor                                   ||'</dsdianor>'||
               '</coluna>');
       indice := vr_tab_rel634.next(indice); 

    END LOOP;
    -- TOTAL GERAL
      vr_tot_vltotfat := vr_taa_vltotfat + vr_deb_vltotfat + vr_cax_vltotfat + vr_int_vltotfat;
      vr_tot_vltrfuni := vr_taa_vltrfuni + vr_deb_vltrfuni + vr_cax_vltrfuni + vr_int_vltrfuni;
      vr_tot_qttotfat := vr_taa_qttotfat + vr_deb_qttotfat + vr_cax_qttotfat + vr_int_qttotfat;
      vr_tot_vlrecliq := vr_taa_vlrecliq + vr_deb_vlrecliq + vr_cax_vlrecliq + vr_int_vlrecliq;
      
 -- Exibe Totais por Coluna 
    pc_escreve_xml(
               '<totais>' ||
                 '<int_vltrfuni>'||  to_char(nvl(vr_int_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</int_vltrfuni>'||
                 '<int_vltotfat>'||  to_char(nvl(vr_int_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</int_vltotfat>'||
                 '<int_qttotfat>'||  nvl(vr_int_qttotfat,0)                                                                                  ||'</int_qttotfat>'||
                 '<int_vlrecliq>'||  to_char(nvl(vr_int_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</int_vlrecliq>'||
                 '<cax_vltrfuni>'||  to_char(nvl(vr_cax_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</cax_vltrfuni>'||
                 '<cax_vltotfat>'||  to_char(nvl(vr_cax_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</cax_vltotfat>'||
                 '<cax_qttotfat>'||  nvl(vr_cax_qttotfat,0)                                                                                  ||'</cax_qttotfat>'||
                 '<cax_vlrecliq>'||  to_char(nvl(vr_cax_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</cax_vlrecliq>'||
                 '<taa_vltrfuni>'||  to_char(nvl(vr_taa_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</taa_vltrfuni>'||
                 '<taa_vltotfat>'||  to_char(nvl(vr_taa_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</taa_vltotfat>'||
                 '<taa_qttotfat>'||  nvl(vr_taa_qttotfat,0)                                                                                  ||'</taa_qttotfat>'||
                 '<taa_vlrecliq>'||  to_char(nvl(vr_taa_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</taa_vlrecliq>'||
                 '<deb_vltrfuni>'||  to_char(nvl(vr_deb_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</deb_vltrfuni>'||
                 '<deb_vltotfat>'||  to_char(nvl(vr_deb_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</deb_vltotfat>'||
                 '<deb_qttotfat>'||  nvl(vr_deb_qttotfat,0)                                                                                  ||'</deb_qttotfat>'||
                 '<deb_vlrecliq>'||  to_char(nvl(vr_deb_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</deb_vlrecliq>'||
                 '<tot_vltrfuni>'||  to_char(nvl(vr_tot_vltrfuni,0),'fm999G999G999G999G990d00')                                              ||'</tot_vltrfuni>'||
                 '<tot_vltotfat>'||  to_char(nvl(vr_tot_vltotfat,0),'fm999G999G999G999G990d00')                                              ||'</tot_vltotfat>'|| 
                 '<tot_qttotfat>'||  nvl(vr_tot_qttotfat,0)                                                                                  ||'</tot_qttotfat>'||
                 '<tot_vlrecliq>'||  to_char(nvl(vr_tot_vlrecliq,0),'fm999G999G999G999G990d00')                                              ||'</tot_vlrecliq>'||
               '</totais>');
            pc_escreve_xml('</crrl634>');               
               ----------------- gerar relatório -----------------
           -- Busca do diretório base da cooperativa para PDF
           vr_caminho_integra := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                                      ,pr_cdcooper => pr_cdcooper
                                                      ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

           -- Efetuar solicitação de geração de relatório --

            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                      ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                      ,pr_dsxmlnode => '/crrl634/coluna'          --> Nó base do XML para leitura dos dados
                                      ,pr_dsjasper  => 'crrl634.jasper'    --> Arquivo de layout do iReport
                                      ,pr_dsparams  => NULL                --> Sem parametros
                                      ,pr_dsarqsaid => vr_caminho_integra||'/crrl634.lst' --> Arquivo final com código da agência
                                      ,pr_qtcoluna  => 132                 --> 132 colunas
                                      ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                      ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                      ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                      ,pr_nrcopias  => 1                   --> Número de cópias
                                      ,pr_flg_gerar => 'S'                 --> gerar PDF
                                       ,pr_des_erro  => vr_dscritic);       --> Saída com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar excecao
          raise vr_exc_saida;
        END IF;
                                 

               
                -- Realiza verificaçao para gerar relatórios mensais  
                IF  to_char(rw_crapdat.dtmvtolt,'mm') <> to_char(rw_crapdat.dtmvtopr,'mm') THEN
                  -- Gera relatorios mensais para as Coop. 
                     pc_executa_rel_mensais(rw_crapdat.dtmvtolt,
                                            vr_tot_vlrtrfpf,
                                            vr_tot_vlrtrfpj,
                                            vr_tot_trfgpspf,
                                            vr_tot_trfgpspj,
                                            vr_relvltrpapf,
                                            vr_relvltrpapj);

                  -- Gera arquivo conciliacao Convenios "AAMMDD_CONVEN_SIC.txt" 
                     pc_gera_conciliacao_conven(vr_tot_vlrtrfpf,
                                                vr_tot_vlrtrfpj,
                                                vr_tot_trfgpspf,
                                                vr_tot_trfgpspj,
                                                vr_relvltrpapf,
                                                vr_relvltrpapj);
                  
                  -- Salva cod da Coop. 
                 -- aux_cdcooper = crapcop.cdcooper.

                  -- Gera o rel636 apenas na cecred 
                  IF  pr_cdcooper = 3 THEN
                      pc_gera_rel_mensal_cecred;
                  end if; --
                end if;

End pc_crps638;
/
