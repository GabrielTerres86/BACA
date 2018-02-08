/* .............................................................................

   Programa: Fontes/compel.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson/Margarete
   Data    : Maio/2001                           Ultima alteracao: 07/02/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela COMPEL.

   Alteracoes: 25/05/2001 - Alterado para gerar os arquivos por PAC (Edson).

               07/06/2001 - Alterado para tratar cheques que vao para comp.
                            de terceiros (Edson).

               26/07/2001 - Alterado para tratar apenas cheques processados 
                            insitchq = 0 ou 2 (Edson).
               
               20/09/2001 - Incluir opcao P - consulta de cheques.

               12/08/2003 - Tratar os descontos de cheques (Edson).

               25/08/2003 - Implementacao compe Banco do Brasil (Ze Eduardo).
               
               18/12/2003 - Alterado para NAO gerar arquivo no ultimo dia
                            do ano (31/12) (Edson).
               
               29/01/2004 - Alterado p/ desprezar PAC selecionados
                            Incluidas opcoes E,V,X(Mirtes)

               11/02/2004 - Implementado controle horarios por PAC(Mirtes)
               
               15/04/2004 - Frame de Help para campo opcao (Julio).

               17/11/2004 - Aumentado nro sequencia arquivo.rem(Mirtes).
               
               11/01/2005 - Incluida opcao "D" - "Impressao da Relacao dos
                            Protocolos (B.Brasil)" (Evandro).
                            
               14/01/2005 - Opcao "D" - Retirados os campos de valores dos
                            cheques a pedido de Marcos Paulo Alves (CECRED)
                            e impressao em 80col (Evandro).
                            
               14/01/2005 - Opcao "D" - Incluida a possibilidade de escolher
                            a data de referencia (Evandro).
                            
               26/01/2005 - Mudado o termo "excluir esta Agencia" para
                            "excluir este PAC"; Mudado o COLUMN-LABEL do browse
                            b_agencia de "Agencia" para "PAC" (Evandro).
                                        
               08/03/2005 - Controlar quando a tabela ja esta sendo usada por
                            outro terminal (Evandro).
                            
               14/03/2005 - Se tela em uso por outro operador, solicitar
                            liberacao coordenador(pedesenha.p)(Mirtes)

               20/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               17/11/2005 - Comentada opcao "T" (Diego).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando 

               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada
                            do programa fontes/pedesenha.p - SQLWorks 
                            - Fernando.

               25/09/2006 - Se glb_cdoperad = "1","996","997" pode-se alterar a 
                            situacao dos arquivos (David).

               09/11/2006 - Nao deixar gerar arquivo com data diferente a 
                            data atual (Ze). 

               12/01/2007 - Substituido informacoes da craptab "LOCALIDADE" por
                            dados da crapage.nmcidade (Elton).

               24/01/2007 - Permitir gerar arquivos para o BANCOOB (Evandro).

               30/03/2007 - Atualizar tabela de parametros HRTRCOMPEL se
                            compensacao for rodada com sucesso (David).

               14/05/2007 - Gerar carta de protocolos somente para BB (David).

               06/08/2007 - Criar craptab controle de operador se nao existir
                            (Guilherme).

               01/10/2007 - Permitir que Coordenadores e Gerentes liberem os
                            operadores bloqueados (Evandro).

               31/10/2007 - Efetuado acerto na Procedure p_regera_agencia, 
                            para atribuir demais valores a crawage (Diego).

               04/11/2008 - Inclusao de codigo de barras na opcao "V" 
                            bloqueio da tecla CTRL-C para relatorio (Martin)

                          - Alterado campo nrcheque por nrctachq no frame 
                            f_det_docto (Gabriel).

               11/05/2009 - Alteracao CDOPERAD (Kbase).

               26/08/2009 - Substituicao do campo banco/agencia da COMPE,
                            para o banco/agencia COMPE de CHEQUE (cdagechq e
                            cdbanchq) - (Sidnei - Precise).

               01/10/2009 - Precise - Paulo. Alterado programa para gravar 
                            em tabela generica quando o banco for cecred 
                            e imprimir em saparado dos demais (BB e Bancoob)
                          - Alterado programa para nao se basear no codigo fixo
                            997 para CECRED, mas sim utilizar o campo cdbcoctl
                            da CRAPCOP. (Precise/Guilherme)
                          - Alteracao do nome do arquivo quando CECRED, padrao
                            definido pela ABBC. (Precise/Guilherme)
                          - Inclusao do campo BANCO na tela, processamento de 
                            acordo com a opcao selecionada, gravar valor no
                            campo cdbcoenv na geracao do arquivo e atribuir 0
                            na "atualiza_compel_regerar" (Precise/Guilherme)
                            
                          - Validar banco CECRED para departamentos
                            TI, COMPE e SUPORTE (Guilherme). 
                            
                          - Redefinir a crawage dos programas Titulo, Doctos,
                            Compel, para igualar a da BO b1wgen0012 
                            (Guilherme/Supero).

                          - Remocao da BO b1wgen0012 (Guilherme/Supero)

                          - Nao gerar mais para CECRED na opcao "B". Sera
                            apenas via PRCCTL (Guilherme/Supero)

                          - Mover a opcao de Imprimir Carta para dentro da
                            opcao "R", questionando se deseja imprimir a Carta
                            ou o Relatorio (Guilherme/Supero)
                            
               27/05/2010 - Imprimir carta remessa mesmo com cheques nao 
                            enviados (Guilherme).
                            
               28/10/2010 - Alterado para validar senha atraves do fonte
                            pedesenha.p (Adriano).
                            
               22/11/2010 - Alterada forma de Gerar para Custodia, Desconto e 
                            Caixa (Guilherme/Supero)
                            
               10/01/2011 - Alterado o format de 40 para 50 nmprimtl
                            (Kbase - Gilnei).
                            
               18/01/2011 - Adaptar Custodia e Dsc Chq, Compe Imagem (Guilherme)
               
               03/03/2011 - Criada a opcao X (Gabriel).
               
               11/03/2011 - Alterado nrdolote para nrborder para o desconto de 
                            cheque na opcao B,X (Adriano).
                            
               31/03/2011 - Opcao "C" tirar Bancos, só considerar CECRED e 
                            utilizar o mesmo layout da "B" com Nao enviado e 
                            enviado para Caixa
                          - Mostrar na opcao "B,C" infos da Previa e validar
                            numero do lote/bodero (Guilherme/Ze)
               
               30/06/2011 - Acerto na opcao "L" para Desconto de Cheques 
                            (Elton).
                            
               25/07/2011 - Alterar o layout e incluir o campo Valor do Cheque
                            (Isara - RKAM)
                            
               04/10/2011 - Inclusão do campo "Capturado" (Isara - RKAM)
               
               18/10/2011 - Inclusão de mensagem para avisar ao usuário
                            a inexistência de registros (Isara - RKAM)
                            
               16/04/2012 - Fonte substituido por compelp.p (Tiago).  
               
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).           
                            
               07/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)
                            
               03/01/2014 - Trocar critica 15 Agencia nao cadastrada por 
                            962 PA nao cadastrado 
                          - Trocar Agencia por PA (Reinert)                            
                          
               01/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
                            
               02/01/2017 - Inserir bloqueio da opcoes "B" e "X" para
                            borderos gerados com data posterior a da 
                            liberaçao do projeto 300. (Lombardi)


			   07/02/2018 - Ajustado horario limite para digitacao dos cheques ate 22
							(Adriano - SD 845726).
                            
............................................................................. */

{ includes/var_online.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF    VAR aut_flgsenha AS LOGICAL                                   NO-UNDO.
DEF    VAR aut_cdoperad AS CHAR                                      NO-UNDO.

DEF    VAR aux_posregis AS RECID                                     NO-UNDO.

DEF TEMP-TABLE crawage                                               NO-UNDO
       FIELD  cdagenci      LIKE crapage.cdagenci
       FIELD  nmresage      LIKE crapage.nmresage
       FIELD  nmcidade      LIKE crapage.nmcidade
       FIELD  cdbandoc      LIKE crapage.cdbandoc
       FIELD  cdbantit      LIKE crapage.cdbantit
       FIELD  cdagecbn      LIKE crapage.cdagecbn
       FIELD  cdbanchq      LIKE crapage.cdbanchq
       FIELD  cdcomchq      LIKE crapage.cdcomchq.

DEF TEMP-TABLE crawprv                                               NO-UNDO
       FIELD  cdagenci      LIKE crapage.cdagenci
       FIELD  dsprodut      AS CHAR 
       FIELD  nrdolote      AS INT
       FIELD  qtcheque      AS INT
       FIELD  vlcheque      AS DECIMAL
       FIELD  dssituac      AS CHAR.


DEF QUERY q_agencia  FOR crawage. 
                                     
DEF BROWSE b_agencia  QUERY q_agencia
      DISP crawage.cdagenci COLUMN-LABEL "PA" 
           crawage.nmresage COLUMN-LABEL "Nome"
           WITH 13 DOWN CENTERED NO-BOX.

DEF BUFFER crabchd FOR crapchd.
DEF BUFFER crabcdb FOR crapcdb.
DEF BUFFER crabcst FOR crapcst.

DEF        VAR tel_nrdhhini AS INT                                   NO-UNDO.
DEF        VAR tel_nrdmmini AS INT                                   NO-UNDO.
DEF        VAR tel_cdagenci AS INT    FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_dssituac AS CHAR   FORMAT "x(17)"                 NO-UNDO.
DEF        VAR tel_cddsenha AS CHAR   FORMAT "x(10)"                 NO-UNDO.
DEF        VAR tel_vlcheque AS DEC    FORMAT "zzz,zzz,zzz,zz9.99"    NO-UNDO.

DEF     VAR tel_situacao AS LOG   FORMAT "NAO PROCESSADO/PROCESSADO" NO-UNDO.

DEF        VAR tel_qtchdcxi AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdcxs AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdcxg AS INT    FORMAT "zzz,zz9"               NO-UNDO.

DEF        VAR tel_qtchdcsi AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdcss AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdcsg AS INT    FORMAT "zzz,zz9"               NO-UNDO.

DEF        VAR tel_qtchddci AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchddcs AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchddcg AS INT    FORMAT "zzz,zz9"               NO-UNDO.

DEF        VAR tel_qtchdtti AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdtts AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdttg AS INT    FORMAT "zzz,zz9"               NO-UNDO.

DEF        VAR tel_vlchdcxi AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdcxs AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdcxg AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.

DEF        VAR tel_vlchdcsi AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdcss AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdcsg AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.

DEF        VAR tel_vlchddci AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchddcs AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchddcg AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.

DEF        VAR tel_vlchdtti AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdtts AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdttg AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.

DEF        VAR tel_dtmvtopg AS DATE   FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_flgenvio AS LOG    FORMAT "Enviados/Nao Enviados" NO-UNDO.

DEF        VAR tel_flggerar AS CHAR   FORMAT "x(16)" VIEW-AS COMBO-BOX 
                                      INNER-LINES 3                  NO-UNDO.

DEF        VAR tel_nrdcaixa AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_nrdolote AS INT    FORMAT "z,zzz,zz9"             NO-UNDO.
DEF        VAR tel_nrborder AS INT    FORMAT "z,zzz,zz9"             NO-UNDO.

DEF        VAR aux_imprimcr AS LOG    FORMAT "Carta/Relatorio"       NO-UNDO.

DEF        VAR aux_cdbcoenv AS CHAR    INIT "0"                      NO-UNDO.
DEF        VAR aux_flggerar AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR aux_dsbcoenv AS CHAR                                  NO-UNDO.
DEF        VAR tel_cddopcao AS CHAR   FORMAT "!(1)"                  NO-UNDO.

DEF        VAR aux_nrdahora AS INT                                   NO-UNDO.
DEF        VAR aux_cdsituac AS INT                                   NO-UNDO.
DEF        VAR aux_qtarquiv AS INT                                   NO-UNDO.
DEF        VAR aux_flgenvio AS LOG                                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR   FORMAT "!"                     NO-UNDO.
DEF        VAR aux_confirm2 AS INT    FORMAT "9"                     NO-UNDO.
DEF        VAR aux_dsmessag AS CHAR                                  NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nrseqarq AS INT                                   NO-UNDO.
DEF        VAR aux_vltotarq AS DECI                                  NO-UNDO.

DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_dtmvtolt AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtmvtopr AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqdat AS CHAR   FORMAT "x(20)"                 NO-UNDO.
DEF        VAR aux_tpdmovto AS CHAR                                  NO-UNDO.
DEF        VAR tot_qtarquiv AS INT                                   NO-UNDO.
DEF        VAR tot_vlcheque AS DECIMAL                               NO-UNDO.
DEF        VAR aux_totqtchq AS INT                                   NO-UNDO.
DEF        VAR aux_totvlchq AS DECIMAL                               NO-UNDO.
DEF        VAR aux_flgerror AS LOGICAL                               NO-UNDO.

DEF        VAR tel_dsdocmc7 AS CHAR   FORMAT "x(34)"                 NO-UNDO.
DEF        VAR aux_lsvalido AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsdigctr AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdagefim LIKE craptvl.cdagenci                    NO-UNDO.
DEF        VAR aux_cdbanchq LIKE crapchd.cdbanchq                    NO-UNDO.

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_cddsenha AS CHAR    FORMAT "x(8)"                 NO-UNDO.
DEF        VAR aux_nrdcaixa AS INT     FORMAT "zzz,zz9"              NO-UNDO.
    
DEF        VAR rel_nmcidade AS CHAR    FORMAT "x(27)"                NO-UNDO.
DEF        VAR rel_qttotmen AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR rel_qttotmai AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR rel_qttotger AS INT     FORMAT "zzz,zz9"              NO-UNDO.

DEF        VAR rel_vltotmen AS DECI    FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR rel_vltotmai AS DECI    FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR rel_vltotger AS DECI    FORMAT "zzz,zzz,zz9.99"       NO-UNDO.

DEF        VAR rel_dsmvtolt AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR rel_mmmvtolt AS CHAR    FORMAT "x(17)"  EXTENT 12 
                                    INIT["DE  JANEIRO  DE","DE FEVEREIRO DE",
                                         "DE   MARCO   DE","DE   ABRIL   DE",
                                         "DE   MAIO    DE","DE   JUNHO   DE",
                                         "DE   JULHO   DE","DE   AGOSTO  DE",
                                         "DE  SETEMBRO DE","DE  OUTUBRO  DE",
                                         "DE  NOVEMBRO DE","DE  DEZEMBRO DE"]
                                                                     NO-UNDO.
/* variaveis para impressao */
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.

/* variaveis da procedure p_divinome */
DEF        VAR aux_qtpalavr AS INTE                                  NO-UNDO.
DEF        VAR rel_nmressbr AS CHAR    EXTENT 2 FORMAT "x(60)"       NO-UNDO.
DEF        VAR aux_contapal AS INTE                                  NO-UNDO.
DEF        VAR aux_nmextcop AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdbccxlt AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmdatela AS CHAR                                  NO-UNDO.

DEF        VAR aux_totregis AS INT                                   NO-UNDO.
DEF        VAR aux_vlrtotal AS DEC                                   NO-UNDO.

DEF        VAR aux_qtcheque AS INT                                   NO-UNDO.
DEF        VAR aux_vlcheque AS DEC                                   NO-UNDO.
DEF        VAR aux_dssituac AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtprevia AS DATE                                  NO-UNDO.

DEF        VAR h-b1wgen0012 AS HANDLE                                NO-UNDO.

DEF        VAR aux_capturad AS CHAR       FORMAT "x(10)"             NO-UNDO.

DEF        TEMP-TABLE crattem                                        NO-UNDO
           FIELD cdseqarq AS INTEGER
           FIELD nrrecchd AS RECID
           INDEX crattem1 cdseqarq.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 3 LABEL "Opcao" AUTO-RETURN
               HELP "Informe a opcao desejada (A, B, C, P, R, V, T ou X)."
               VALIDATE(CAN-DO("A,B,C,L,P,R,V,T,X",glb_cddopcao),
                               "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_compel.

FORM tel_dtmvtopg AT 1 LABEL " Data"
                       HELP "Entre com a data do movimento."
     tel_cdagenci      LABEL " PA"
                       HELP "Entre com o numero do PA"
                       VALIDATE(CAN-FIND(
                           crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                         crapage.cdagenci = INPUT tel_cdagenci),
                                         "962 - PA nao cadastrado.")
     tel_flggerar      LABEL "  Produto"
                       HELP "Selecione o produto"
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.

               
FORM tel_dtmvtopg AT 1 LABEL " Data"
                       HELP "Entre com a data do movimento."
     tel_cdagenci      LABEL " PA"
                       HELP "Entre com o numero do PA"
                       VALIDATE(CAN-FIND(
                           crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                         crapage.cdagenci = INPUT tel_cdagenci),
                                     "962 - PA nao cadastrado.")
     tel_flgenvio AT 39 LABEL " Opcao" 
                      HELP "Informe 'N' para nao enviados ou 'E' para enviados."
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere_v.

FORM tel_vlcheque  AT  3   LABEL "Valor do cheque"
                           HELP "Entre com o valor do cheque."
                           VALIDATE(tel_vlcheque > 0,"269 - Valor errado.")
     WITH ROW 8 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_valor.
     
FORM tel_flgenvio AT 32 LABEL " Opcao" 
                    HELP "Informe 'N' para nao enviados ou 'E' para enviados."
     WITH ROW 7 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere_caixa.

FORM tel_nrdolote AT 34 LABEL "Lote"
                        HELP "Entre com o numero do Lote"
     WITH ROW 7 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere_custodia.

FORM tel_nrborder AT 31 LABEL "Bordero"
                        HELP "Entre com o numero do Bordero"
     WITH ROW 7 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere_desconto.


FORM tel_cdagenci      LABEL " PA  "
                       HELP "Entre com o numero do PA "
     tel_cddsenha BLANK LABEL "         Senha"
                       HELP "Entre com a senha do PA "
     SKIP(3)
     tel_nrdhhini AT  1 LABEL "Limite para digitacao dos cheques" 
                        FORMAT "99" AUTO-RETURN
                        HELP "Entre com a hora limite (12:00 a 22:00)."
     ":"          AT 38 
     tel_nrdmmini AT 39 NO-LABEL FORMAT "99" 
                        HELP "Entre com os minutos (0 a 59)."
     "Horas"
     
     SKIP(1)
     tel_situacao AT 9 LABEL "Situacao do(s) arquivo(s)"
                       HELP "Informe (N)ao processado ou (P)rocessado."
     WITH ROW 11 COLUMN 9 NO-BOX OVERLAY SIDE-LABELS FRAME f_fechamento.

FORM "----- Inferior ----- ----- Superior ----- ------- Total ------" AT 16
     SKIP(1)
     "Caixa:"     AT  9
     tel_qtchdcxi AT 16 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcxi AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdcxs AT 37 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcxs AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdcxg AT 58 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcxg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     "Custodia:"  AT  6
     tel_qtchdcsi AT 16 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcsi AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdcss AT 37 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcss AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdcsg AT 58 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcsg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     "Desconto:"  AT  6
     tel_qtchddci AT 16 FORMAT "zzzz9"          NO-LABEL
     tel_vlchddci AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchddcs AT 37 FORMAT "zzzz9"          NO-LABEL
     tel_vlchddcs AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchddcg AT 58 FORMAT "zzzz9"          NO-LABEL
     tel_vlchddcg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     "TOTAL GERAL:" AT 3
     tel_qtchdtti AT 16 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdtti AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdtts AT 37 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdtts AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdttg AT 58 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdttg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(3)
     WITH ROW 10 COLUMN 2 NO-BOX OVERLAY SIDE-LABELS FRAME f_total.

FORM "----- Inferior ----- ----- Superior ----- ------- Total ------" AT 16
     SKIP(1)
     "Custodia:"  AT  6
     tel_qtchdcsi AT 16 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcsi AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdcss AT 37 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcss AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdcsg AT 58 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcsg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     "Desconto:"  AT  6
     tel_qtchddci AT 16 FORMAT "zzzz9"          NO-LABEL
     tel_vlchddci AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchddcs AT 37 FORMAT "zzzz9"          NO-LABEL
     tel_vlchddcs AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchddcg AT 58 FORMAT "zzzz9"          NO-LABEL
     tel_vlchddcg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     "TOTAL GERAL:" AT 3
     tel_qtchdtti AT 16 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdtti AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdtts AT 37 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdtts AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdttg AT 58 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdttg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     aux_dssituac AT 6  FORMAT "x(11)"
                  LABEL "Situacao"
     aux_dtprevia AT 43 FORMAT "99/99/9999"
                  LABEL "Data que gerou a Previa"
    SKIP(1)
     WITH ROW 10 COLUMN 2 NO-BOX OVERLAY SIDE-LABELS FRAME f_total_2.

FORM tel_dtmvtopg AT 1 LABEL "Listar os lotes do dia"
                       HELP "Entre com a data do movimento."
     tel_cdagenci      LABEL "   PA"
                 HELP "Entre com o numero do PA ou 0 para todos os PA's."
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_movto.

FORM tel_dsdocmc7 AT 1 LABEL "  CMC-7"
                       HELP "Passe o cheque na leitora."
     WITH ROW 6 COLUMN 29 SIDE-LABELS OVERLAY NO-BOX FRAME f_cmc7.

FORM "Comp"                 AT 10
     "Banco"                AT 16
     "Ag."                  AT 23
     "Conta"                AT 36
     "Cheque"               AT 44
     "Valor"                AT 65
     SKIP(1)
     crapchd.cdcmpchq       AT 11   FORMAT "999"
     crapchd.cdbanchq       AT 17   FORMAT "999"
     crapchd.cdagechq       AT 22   FORMAT "9999"
     crapchd.nrctachq       AT 28   FORMAT "zzz,zzz,zzz,9"
     crapchd.nrcheque       AT 43   FORMAT "zzz,zz9"
     crapchd.vlcheque       AT 52   FORMAT "zzz,zzz,zzz,zz9.99"
     SKIP(1)
     "Depositado para:" AT 3
     SKIP(1)
     "Data"                 AT  5
     "Conta"                AT 21
     "Titular"              AT 29
     SKIP(1)
     crapchd.dtmvtolt       AT  3   FORMAT "99/99/9999"
     crapchd.nrdconta       AT 16   FORMAT "zzzz,zzz,9"
     crapass.nmprimtl       AT 29   FORMAT "x(50)"
     SKIP(1)
     WITH ROW 8 COLUMN 2 OVERLAY NO-BOX NO-LABELS FRAME f_dados.

FORM "Aguarde... Pesquisando cheque!"
     WITH ROW 12 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM b_agencia AT 18 
     HELP "Use SETAS p/Navegar e <F4> p/Sair. Pressione <ENTER> p/Excluir!" 
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_agencia.

FORM aux_confirma    AT 1 LABEL "Iniciar Nova Selecao?     " 
                     HELP "Entre com a opcao S/N."
     WITH ROW 12 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_regera.

FORM "(A) - Alterar horario da transmissao de cheques" SKIP
     "(B) - Gerar arquivos" SKIP
     "(C) - Consultar" SKIP
     "(L) - Consultar Previas de Digitalizacao" SKIP
     "(P) - Visualizar os dados do cheque" SKIP
     "(R) - Relatorio" SKIP
     "(V) - Visualizar os lotes" SKIP
     "(X) - Reativar Previa"
     WITH SIZE 63 BY 10 CENTERED OVERLAY ROW 8
     TITLE "Escolha uma das opcoes abaixo:" FRAME f_helpopcao.

FORM crapcop.cdagedbb  LABEL "Agencia (BB)"
     SKIP(1)
     crapcop.nrctadbb  LABEL "C/C (BB)"
     WITH NO-BOX COLUMN 30 ROW 10 SIDE-LABELS OVERLAY FRAME f_opcao_d.

FORM SKIP(1)
     "ATENCAO!  Coloque o papel timbrado na impressora. " AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56 
       TITLE "Impressao da Relacao dos Protocolos (B.Brasil)" FRAME f_atencao.

FORM "CIDADE"                       AT  1
     "AGENCIA"                      AT 30
     "PA"                           AT 43
     "MENORES"                      AT 47 
     "MAIORES"                      AT 56   
     "TOTAL"                        AT 66
     SKIP
     "---------------------------"  AT  1
     "-------"                      AT 30
     "------"                       AT 39
     "-------"                      AT 47
     "-------"                      AT 56
     "-------"                      AT 65
     WITH COLUMN 5 DOWN NO-BOX WIDTH 80 FRAME f_label_protocolos.

FORM rel_nmcidade           NO-LABEL   AT  1
     crawage.cdagecbn       NO-LABEL   AT 30   
     crawage.cdagenci       NO-LABEL   AT 42
     tel_qtchdtti           NO-LABEL   AT 47
     tel_qtchdtts           NO-LABEL   AT 56
     tel_qtchdttg           NO-LABEL   AT 65 
     WITH COLUMN 5 DOWN NO-BOX WIDTH 80 NO-LABELS FRAME f_protocolos.

ON VALUE-CHANGED, ENTRY OF b_agencia
   DO:
       IF  AVAIL crawage THEN
           aux_posregis = RECID(crawage).
   END.

ON RETURN OF b_agencia
   DO:
       IF  AVAIL crawage THEN
           aux_posregis = RECID(crawage).
   END.

ON RETURN OF tel_flggerar DO:

   aux_flggerar = tel_flggerar:SCREEN-VALUE.

   APPLY "GO".
END.


/*---Opcao para Listar Cheques nao Processados ---*/
DEF QUERY q_compel FOR crapchd
                  FIELDS(cdagenci cdbccxlt nrdolote 
                         cdcmpchq cdbanchq cdagechq nrctachq nrcheque
                         vlcheque dsdocmc7),
                      crapope
                  FIELDS(nmoperad).    
                                     
DEF BROWSE b_compel QUERY q_compel 
    DISP  crapchd.cdagenci    COLUMN-LABEL "PA"
          crapchd.cdbccxlt    COLUMN-LABEL "Banco/Caixa"
          crapope.nmoperad    COLUMN-LABEL "Operador"   FORMAT "x(26)"
          crapchd.nrdolote    COLUMN-LABEL "Lote"
          crapchd.nrcheque    COLUMN-LABEL "Cheque"     
          crapchd.vlcheque    COLUMN-LABEL "Valor"               
          WITH 5 DOWN WIDTH 78.

/*---Opcao para Listar Cheques nao Processados ---*/
DEF QUERY q_previa FOR crawprv
          FIELDS(cdagenci dsprodut nrdolote qtcheque vlcheque dssituac).
                                     
DEF BROWSE b_previa QUERY q_previa 
    DISP  crawprv.cdagenci    COLUMN-LABEL "PA"
          crawprv.dsprodut    COLUMN-LABEL "Produto"  FORMAT "x(20)"
          crawprv.nrdolote    COLUMN-LABEL "Lote"     FORMAT "zzz,zz9"
          crawprv.qtcheque    COLUMN-LABEL "Qtdade"   FORMAT "zzz,zz9"
          crawprv.vlcheque    COLUMN-LABEL "Valor"    FORMAT "zzz,zzz,zz9.99"  
          crawprv.dssituac    COLUMN-LABEL "Situacao" FORMAT "x(11)"
          WITH 9 DOWN.

FORM crapchd.cdbanchq  label "Banco"     colon 07
     crapchd.cdagechq  label "Agencia"   colon 60
     skip
     crapchd.cdcmpchq  label "Compe"     colon 07
     crapchd.nrctachq  label "Nr Conta"  colon 60
     crapchd.dsdocmc7  Label "CMC-7"     colon 07
     aux_capturad      Label "Capturado" colon 60
     WITH row 18 width 78 centered no-box side-labels overlay 
          frame f_det_docto.

DEF FRAME f_previa_b  
          SKIP(1)
          b_previa   HELP  "Pressione <F4> ou <END> p/finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

DEF FRAME f_compel_b  
          b_compel   HELP  "Pressione <F4> ou <END> p/finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 9.

ON VALUE-CHANGED, ENTRY OF b_compel 
   DO:
       CASE crapchd.cdbccxlt:
           WHEN 11 THEN
               DO:
                    IF   crapchd.nrdolote > 30000 AND
                         crapchd.nrdolote < 30999 THEN
                         aux_capturad = "LANCHQ".
                    ELSE
                         aux_capturad = "CAIXA".
               END.
               
           WHEN 500 THEN
               aux_capturad = "LANCHQ".

           WHEN 600 THEN
               aux_capturad = "CUSTODIA".

           WHEN 700 THEN
               aux_capturad = "DESCONTO".

           WHEN 100 THEN
               aux_capturad = "LANDPV".
       END CASE.

       DISPLAY crapchd.cdbanchq  crapchd.cdagechq  crapchd.cdcmpchq
               crapchd.nrctachq  crapchd.dsdocmc7  aux_capturad
               WITH FRAME f_det_docto.
   END.

ON LEAVE OF b_compel 
   DO:
       HIDE FRAME f_det_docto.
   END.



/* Busca dados da cooperativa */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.

/*--- Inicializa com todas as agencias --*/
FIND FIRST crawage NO-LOCK NO-ERROR.
IF   NOT AVAIL crawage THEN
     DO:
         FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:
             CREATE crawage.
             ASSIGN crawage.cdagenci = crapage.cdagenci
                    crawage.nmresage = crapage.nmresage
                    crawage.nmcidade = crapage.nmcidade 
                    crawage.cdagecbn = crapage.cdagecbn
                    crawage.cdbanchq = crapage.cdbanchq
                    crawage.cdcomchq = crapage.cdcomchq.
         END. 
     END.      

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtmvtopg = glb_dtmvtolt
       aux_lsvalido = "1,2,3,4,5,6,7,8,9,0,G,<,>,:," +
                      "RETURN,F4,CURSOR-LEFT,CURSOR-RIGHT".

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).
   
DO WHILE TRUE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               PAUSE 2 NO-MESSAGE.
           END.

      RUN proc_limpa.
      VIEW FRAME f_helpopcao.
      PAUSE(0).
      
      UPDATE glb_cddopcao  WITH FRAME f_compel.

      HIDE FRAME f_helpopcao NO-PAUSE.    
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "COMPEL"  THEN
                 DO:
                     RUN proc_limpa.
                     HIDE FRAME f_compel.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN
        DO:
            RUN proc_limpa.
            
            UPDATE tel_cdagenci tel_cddsenha WITH FRAME f_fechamento.
            
            IF   tel_cdagenci = 0 THEN
                 DO:
                     glb_cdcritic = 89.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
            
            FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                               crapage.cdagenci = tel_cdagenci 
                               NO-LOCK NO-ERROR.

            IF   NOT AVAIL crapage THEN
                 DO:
                     glb_cdcritic = 15.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.

            DO TRANSACTION ON ENDKEY UNDO, LEAVE:

               DO aux_contador = 1 TO 10:
                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                     craptab.nmsistem = "CRED"        AND
                                     craptab.tptabela = "GENERI"      AND
                                     craptab.cdempres = 00            AND
                                     craptab.cdacesso = "HRTRCOMPEL"  AND
                                     craptab.tpregist = tel_cdagenci
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                  
                  IF   NOT AVAILABLE craptab   THEN
                       IF   LOCKED craptab   THEN
                            DO:
                                glb_cdcritic = 77.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            DO:
                                glb_cdcritic = 55.
                                LEAVE.
                            END.    
                            
                  ELSE
                       glb_cdcritic = 0.

                  LEAVE.

               END.  /*  Fim do DO .. TO  */

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               ASSIGN aux_cdsituac = INT(SUBSTR(craptab.dstextab,1,1))
                      aux_nrdahora = INT(SUBSTR(craptab.dstextab,3,5))
                      tel_situacao = IF   aux_cdsituac = 0  THEN
                                          TRUE
                                     ELSE
                                          FALSE
                      tel_nrdhhini = INT(SUBSTR(STRING(aux_nrdahora,
                                                       "HH:MM:SS"),1,2))
                      tel_nrdmmini = INT(SUBSTR(STRING(aux_nrdahora,
                                                       "HH:MM:SS"),4,2)).

               DISPLAY  tel_situacao  WITH FRAME f_fechamento.
               
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.
                  
                  IF   glb_cddepart = 20 OR    /* TI                   */
                       glb_cddepart = 18 OR    /* SUPORTE              */
                       glb_cddepart =  8 OR    /* COORD.ADM/FINANCEIRO */
                       glb_cddepart =  4 THEN  /* COMPE                */
                       DO:
                           UPDATE tel_nrdhhini tel_nrdmmini tel_situacao
                                  WITH FRAME f_fechamento.
                       END.
                  ELSE
                       UPDATE tel_nrdhhini tel_nrdmmini WITH FRAME f_fechamento.
                      
                  IF   tel_nrdhhini < 10 OR tel_nrdhhini > 22 THEN
                       DO:
                           glb_cdcritic = 687.
                           NEXT.
                       END.
                  
                  IF   tel_nrdmmini > 59  THEN
                       DO:
                           glb_cdcritic = 687.
                           NEXT.
                       END.
                     
                  IF   tel_nrdhhini < 10   THEN
                       DO:
                           glb_cdcritic = 687.
                           NEXT.
                       END.
                           
                  IF   tel_nrdhhini = 22 AND tel_nrdmmini > 0 THEN
                       DO:
                           glb_cdcritic = 687.
                           NEXT.
                       END.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               RUN fontes/confirma.p(INPUT "",
                                     OUTPUT aux_confirma).

               IF   aux_confirma <> "S" THEN
                    DO:
                        RUN proc_limpa.
                        NEXT.
                    END.

               ASSIGN aux_nrdahora = (tel_nrdhhini * 3600) + (tel_nrdmmini * 60)
                      aux_cdsituac = IF   tel_situacao  THEN  
                                          0  
                                     ELSE 1
                      craptab.dstextab = STRING(aux_cdsituac,"9") + " " + 
                                         STRING(aux_nrdahora,"99999") 
                      glb_cdcritic = 0.

            END. /* Fim da transacao */

            RELEASE craptab.

            CLEAR FRAME f_fechamento NO-PAUSE.
        END.
   ELSE
   IF   glb_cddopcao = "L"   THEN
        DO:
            EMPTY TEMP-TABLE crawprv.
            
            RUN proc_limpa.
            
            ASSIGN tel_dtmvtopg = glb_dtmvtolt
                   tel_cdagenci = 0
                   tel_flggerar:LIST-ITEMS = 
                                "Custodia Cheques,Desconto Cheques".
                   
            DISPLAY tel_dtmvtopg tel_cdagenci tel_flggerar 
                    WITH FRAME f_refere NO-ERROR.

            UPDATE tel_dtmvtopg tel_cdagenci WITH FRAME f_refere.

            UPDATE tel_flggerar WITH FRAME f_refere NO-ERROR.

            IF   aux_flggerar = "Custodia Cheques" THEN
                 DO: 
                     ASSIGN aux_qtcheque = 0
                            aux_vlcheque = 0
                            aux_dssituac = "".
                     
                     FOR EACH crapcst WHERE 
                              crapcst.cdcooper = glb_cdcooper   AND
                              crapcst.dtmvtolt = tel_dtmvtopg   AND
                              crapcst.cdagenci = tel_cdagenci   AND
                             (crapcst.insitchq = 0              OR
                              crapcst.insitchq = 2)
                              NO-LOCK BREAK BY crapcst.nrdolote:

                         IF   FIRST-OF(crapcst.nrdolote) THEN
                              DO:
                                  IF   crapcst.insitprv = 0 THEN
                                       aux_dssituac = "Nao Enviado".
                                  ELSE
                                  IF   crapcst.insitprv = 1 THEN
                                       aux_dssituac = "Gerado".
                                  ELSE
                                  IF   crapcst.insitprv = 2 THEN
                                       aux_dssituac = "Digitalizado".
                                  ELSE
                                  IF   crapcst.insitprv = 3 THEN
                                       aux_dssituac = "Procesado".
                              END.
                              
                         ASSIGN aux_qtcheque = aux_qtcheque + 1
                                aux_vlcheque = aux_vlcheque + crapcst.vlcheque.
                         
                         IF   LAST-OF(crapcst.nrdolote) THEN
                              DO:
                                  CREATE crawprv.
                                  ASSIGN crawprv.cdagenci = crapcst.cdagenci
                                         crawprv.dsprodut = 
                                                  "Custodia de Cheques"
                                         crawprv.nrdolote = crapcst.nrdolote
                                         crawprv.qtcheque = aux_qtcheque
                                         crawprv.vlcheque = aux_vlcheque
                                         crawprv.dssituac = aux_dssituac.
          
                                  ASSIGN aux_qtcheque = 0
                                         aux_vlcheque = 0
                                         aux_dssituac = "".
                              END.           
                     END.
                     
                     OPEN QUERY q_previa FOR EACH crawprv.
                     ENABLE b_previa WITH FRAME f_previa_b.
                                    
                     WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

                     HIDE FRAME f_previa_b. 

                     HIDE MESSAGE NO-PAUSE.
                 END.
            ELSE 
                 DO:      /* Desconto de cheques */
                     ASSIGN aux_qtcheque = 0
                            aux_vlcheque = 0
                            aux_dssituac = "".
                    
                     FOR EACH crapcdb WHERE 
                              crapcdb.cdcooper = glb_cdcooper   AND
                              crapcdb.dtlibbdc = tel_dtmvtopg   AND
                              crapcdb.cdagenci = tel_cdagenci   AND
                             (crapcdb.insitchq = 0              OR
                              crapcdb.insitchq = 2)
                              NO-LOCK BREAK BY crapcdb.nrborder:

                         IF   FIRST-OF(crapcdb.nrborder) THEN
                              DO:
                                  IF   crapcdb.insitprv = 0 THEN
                                       aux_dssituac = "Nao Enviado".
                                  ELSE
                                  IF   crapcdb.insitprv = 1 THEN
                                       aux_dssituac = "Gerado".
                                  ELSE
                                  IF   crapcdb.insitprv = 2 THEN
                                       aux_dssituac = "Digitalizado".
                                  ELSE
                                  IF   crapcdb.insitprv = 3 THEN
                                       aux_dssituac = "Procesado".
                              END.
                                             
                         ASSIGN aux_qtcheque = aux_qtcheque + 1
                                aux_vlcheque = aux_vlcheque + crapcdb.vlcheque.
                         
                         IF   LAST-OF(crapcdb.nrborder) THEN
                              DO:
                                  CREATE crawprv.
                                  ASSIGN crawprv.cdagenci = crapcdb.cdagenci
                                         crawprv.dsprodut = 
                                                  "Desconto de Cheques"
                                         crawprv.nrdolote = crapcdb.nrdolote
                                         crawprv.qtcheque = aux_qtcheque
                                         crawprv.vlcheque = aux_vlcheque
                                         crawprv.dssituac = aux_dssituac.
                                         
                                  ASSIGN aux_qtcheque = 0
                                         aux_vlcheque = 0
                                         aux_dssituac = "".
                              END.           
                     END.
                     
                     OPEN QUERY q_previa FOR EACH crawprv.
                     ENABLE b_previa WITH FRAME f_previa_b.
                                    
                     WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

                     HIDE FRAME f_previa_b. 

                     HIDE MESSAGE NO-PAUSE.
                 END.
        END.   
   ELSE
   IF   glb_cddopcao = "V"   THEN
        DO:
           RUN proc_limpa.

           UPDATE tel_dtmvtopg tel_cdagenci tel_flgenvio WITH FRAME f_refere_v.

           UPDATE tel_vlcheque WITH FRAME f_valor.

           ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN 
                                      9999
                                 ELSE tel_cdagenci.

           OPEN QUERY q_compel 
               FOR EACH crapchd NO-LOCK 
                  WHERE crapchd.cdcooper = glb_cdcooper        AND 
                        crapchd.dtmvtolt = tel_dtmvtopg        AND
                        crapchd.inchqcop = 0                   AND
                        CAN-DO("0,2",STRING(crapchd.insitchq)) AND
                        crapchd.cdagenci >= tel_cdagenci       AND
                        crapchd.cdagenci <= aux_cdagefim       AND 
                        crapchd.flgenvio  = tel_flgenvio       AND
                        crapchd.vlcheque >= tel_vlcheque,
                   FIRST crapope NO-LOCK
                   WHERE crapope.cdcooper = glb_cdcooper       AND
                         crapope.cdoperad = crapchd.cdoperad  
                         BY crapchd.vlcheque.

           IF AVAIL crapchd THEN
               ENABLE b_compel WITH FRAME f_compel_b.
           ELSE
           DO:
               MESSAGE "Nao ha registros com os dados informados.".
               PAUSE(4) no-message.

               MESSAGE "Pressione <F4> ou <END> p/finalizar".
           END.

           WAIT-FOR END-ERROR OF DEFAULT-WINDOW.

           HIDE FRAME f_compel_b. 

           HIDE MESSAGE NO-PAUSE.

           HIDE FRAME f_refere_v.
           HIDE FRAME f_valor.
        END.       
   ELSE                           
   IF   glb_cddopcao = "X"   THEN 
        DO:  
            RUN proc_limpa.
            
            ASSIGN tel_dtmvtopg = glb_dtmvtolt
                   tel_cdagenci = 0
                   tel_flggerar:LIST-ITEMS = 
                                "Custodia Cheques,Desconto Cheques".
                   
            DISPLAY tel_dtmvtopg tel_cdagenci tel_flggerar 
                    WITH FRAME f_refere NO-ERROR.

            UPDATE tel_dtmvtopg tel_cdagenci WITH FRAME f_refere.

            UPDATE tel_flggerar WITH FRAME f_refere NO-ERROR.

            ASSIGN tel_nrdolote = 0
                   tel_nrborder = 0.
            
            IF   aux_flggerar = "Custodia Cheques"  THEN
                 DO:
                     UPDATE tel_nrdolote WITH FRAME f_refere_custodia.

                     ASSIGN aux_cdbccxlt = "600".
        
                     RUN proc_compel_custodia (INPUT "X",
                                               INPUT aux_cdbccxlt).
                 END.
   
           IF   aux_flggerar = "Desconto Cheques"  THEN 
                DO: 
                    UPDATE tel_nrborder WITH FRAME f_refere_desconto.
        
                    ASSIGN aux_cdbccxlt = "700".
        
                    RUN proc_compel_dscchq (INPUT "X",
                                            INPUT aux_cdbccxlt).
                END.
        
           IF   glb_cdcritic <> 0 THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.

            
            RUN fontes/confirma.p(INPUT "",
                                  OUTPUT aux_confirma).

            IF   aux_confirma <> "S"   THEN
                 NEXT.

            IF   aux_flggerar = "Custodia Cheques" THEN
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:
                    FOR EACH crapcst WHERE 
                             crapcst.cdcooper = glb_cdcooper   AND
                             crapcst.dtmvtolt = tel_dtmvtopg   AND
                             crapcst.cdagenci = tel_cdagenci   AND
                             crapcst.insitprv = 1              AND
                             crapcst.nrdolote = tel_nrdolote   AND
                            (crapcst.insitchq = 0              OR
                             crapcst.insitchq = 2)
                             EXCLUSIVE-LOCK:
                     
                        ASSIGN crapcst.insitprv = 0
                               crapcst.dtprevia = ?.
                     
                    END.
                 END.
            ELSE /* Desconto de cheques */
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:
                    FOR EACH crapcdb WHERE 
                             crapcdb.cdcooper = glb_cdcooper   AND
                             crapcdb.dtlibbdc = tel_dtmvtopg   AND
                             crapcdb.cdagenci = tel_cdagenci   AND
                             crapcdb.insitprv = 1              AND
                             crapcdb.nrborder = tel_nrborder   AND
                            (crapcdb.insitchq = 0              OR
                             crapcdb.insitchq = 2)
                             EXCLUSIVE-LOCK:
        
                        ASSIGN crapcdb.insitprv = 0
                               crapcdb.dtprevia = ?.

                    END.
                 END.
                 
            MESSAGE "Movtos atualizados".
            PAUSE(3) NO-MESSAGE.
        END.   ELSE              
   IF   glb_cddopcao = "C"   THEN
        DO:
            ASSIGN tel_flgenvio = TRUE
                   tel_flggerar:SCREEN-VALUE = ""  
                   tel_flggerar:LIST-ITEMS =
                         "Caixa,Custodia Cheques,Desconto Cheques".

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_dtmvtopg   tel_cdagenci   tel_flggerar  
                      WITH FRAME f_refere.

               ASSIGN aux_cdbcoenv = STRING(crapcop.cdbcoctl)
                      aux_dsbcoenv = "CECRED".

               IF   aux_flgenvio THEN /* Enviados */
                    ASSIGN aux_cdbcoenv = "0,1,756," + STRING(crapcop.cdbcoctl).
               ELSE                   /* Nao Enviados */
                    ASSIGN aux_cdbcoenv = "0".

               DO  WHILE TRUE ON ENDKEY UNDO, LEAVE: 
        
                   IF   aux_flggerar = "Caixa"  THEN
                        DO:
                            DISPLAY tel_flgenvio WITH FRAME f_refere_caixa.
                            UPDATE  tel_flgenvio WITH FRAME f_refere_caixa.

                            ASSIGN aux_cdbccxlt = "11,500,600,700"
                                   aux_flgenvio = tel_flgenvio.

                            RUN proc_compel (INPUT aux_cdbccxlt).

                            aux_confirma = "N".

                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                               IF   tel_qtchdttg = 0   THEN
                                    LEAVE.

                               MESSAGE COLOR NORMAL
                                   "Deseja listar os LOTES " + 
                                   "referentes a pesquisa(S/N)?:"
                                   UPDATE aux_confirma.
                               LEAVE.

                            END. /* fim do DO WHILE */

                            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                 aux_confirma <> "S"                  THEN 
                                 .
                            ELSE
                                 RUN fontes/compel_r.p(INPUT tel_dtmvtopg, 
                                                       INPUT tel_cdagenci,
                                                       INPUT 0, 
                                                       INPUT 0, 
                                                       INPUT FALSE,
                                                       INPUT TABLE crawage,
                                                       INPUT tel_flgenvio,
                                                       INPUT tel_flgenvio).

                        END.
                   ELSE
                   IF   aux_flggerar = "Custodia Cheques"  THEN
                        DO:
                            DISPLAY tel_nrdolote WITH FRAME f_refere_custodia.
                            UPDATE  tel_nrdolote WITH FRAME f_refere_custodia.
        
                            ASSIGN aux_cdbccxlt = "600".
        
                            RUN proc_compel_custodia (INPUT "C",
                                                      INPUT aux_cdbccxlt).
                        END.
                   IF   aux_flggerar = "Desconto Cheques"  THEN 
                        DO: 
                            DISPLAY tel_nrborder WITH FRAME f_refere_desconto.
                            UPDATE  tel_nrborder WITH FRAME f_refere_desconto.
        
                            ASSIGN aux_cdbccxlt = "700".
        
                            RUN proc_compel_dscchq (INPUT "C",
                                                    INPUT aux_cdbccxlt).
                        END.
        
                   IF   glb_cdcritic <> 0 THEN
                        DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
        
                   LEAVE.
               END.
        
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    NEXT.
        
               IF   glb_cdcritic <> 0 THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
            END. /*  Fim do DO WHILE TRUE  */
       END.
   ELSE
   IF   glb_cddopcao = "B"   THEN
        DO:
            RUN proc_limpa.
            
            ASSIGN tel_dtmvtopg = glb_dtmvtolt
                   tel_cdagenci = 0
                   tel_flggerar:SCREEN-VALUE = ""  
                   tel_flggerar:LIST-ITEMS =
                         "Custodia Cheques,Desconto Cheques" NO-ERROR.

            DISPLAY tel_dtmvtopg tel_cdagenci tel_flggerar 
                    WITH FRAME f_refere NO-ERROR.

            UPDATE tel_dtmvtopg tel_cdagenci WITH FRAME f_refere.
            UPDATE tel_flggerar WITH FRAME f_refere NO-ERROR.

             /*  Nao deixa gerar arquivo no dia 31/12 - NAO TEM COMPE  */
            
            IF   MONTH(tel_dtmvtopg) = 12   AND
                 DAY(tel_dtmvtopg)   = 31   THEN
                 DO:
                     glb_cdcritic = 13.
                     NEXT.
                 END.

            ASSIGN aux_cdagefim = IF   tel_cdagenci = 0  THEN 
                                       9999
                                  ELSE tel_cdagenci.
                     
            ASSIGN aux_cdsituac = 0
                   glb_cdcritic = 0
                   tel_nrdcaixa = 0
                   tel_nrdolote = 0
                   tel_nrborder = 0.
                   
            FOR EACH crapage WHERE crapage.cdcooper  = glb_cdcooper AND
                                   crapage.cdagenci >= tel_cdagenci AND
                                   crapage.cdagenci <= aux_cdagefim NO-LOCK,
                EACH crawage WHERE crawage.cdagenci  = crapage.cdagenci AND
                                   crawage.cdbanchq <> crapcop.cdbcoctl
                                   NO-LOCK:
            
                FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                   craptab.nmsistem = "CRED"        AND
                                   craptab.tptabela = "GENERI"      AND
                                   craptab.cdempres = 00            AND
                                   craptab.cdacesso = "HRTRCOMPEL"  AND
                                   craptab.tpregist = crapage.cdagenci
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE craptab   THEN
                     DO:
                         glb_cdcritic = 55.
                         NEXT.
                     END.

                ASSIGN aux_nrdahora = INT(SUBSTR(craptab.dstextab,03,05)).
                
                FIND FIRST crapchd WHERE 
                           crapchd.cdcooper  = glb_cdcooper      AND
                           crapchd.dtmvtolt  = tel_dtmvtopg      AND
                           crapchd.inchqcop  = 0                 AND
                           crapchd.cdagenci  = crapage.cdagenci  AND
                           crapchd.cdbanchq <> crapcop.cdbcoctl
                           NO-LOCK NO-ERROR.

                IF   aux_cdsituac = 0 THEN 
                     DO:
                         IF  AVAIL crapchd THEN
                             ASSIGN aux_cdsituac =
                                      INT(SUBSTR(craptab.dstextab,1,1)).
                     END.
            
            END.  /* For each crapage */
            
            ASSIGN aux_flgenvio = NO.

            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE: 

                IF   aux_flggerar = "Custodia Cheques"  THEN
                     DO:
                         DISPLAY tel_nrdolote WITH FRAME f_refere_custodia.
                         UPDATE  tel_nrdolote WITH FRAME f_refere_custodia.

                         ASSIGN aux_cdbccxlt = "600".

                         RUN proc_compel_custodia (INPUT "B",
                                                   INPUT aux_cdbccxlt).
                     END.
                IF   aux_flggerar = "Desconto Cheques"  THEN 
                     DO: 
                         DISPLAY tel_nrborder WITH FRAME f_refere_desconto.
                         UPDATE  tel_nrborder WITH FRAME f_refere_desconto.

                         ASSIGN aux_cdbccxlt = "700".

                         RUN proc_compel_dscchq (INPUT "B",
                                                 INPUT aux_cdbccxlt).
                     END.

                IF   glb_cdcritic <> 0 THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.

                LEAVE.
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                 NEXT.

            IF   glb_cdcritic <> 0 THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.

            ASSIGN aux_confirma = "S".

            IF   aux_cdsituac <> 0   THEN
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    aux_confirma = "N".
                    BELL.
                    MESSAGE COLOR NORMAL 
                           "Os arquivos ja foram gravados."
                           "Deseja regrava-los? (S/N):"
                            UPDATE aux_confirma.
                            glb_cdcritic = 0.
                            LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"                  THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     RUN proc_limpa.
                     NEXT.
                 END.
            
            RUN fontes/confirma.p(INPUT "",
                                  OUTPUT aux_confirma).

            IF   aux_confirma <> "S"   THEN
                 DO:
                     RUN proc_limpa.
                     NEXT.
                 END.

            /*---- Controle de 1 operador utilizando  tela --*/                
            DO TRANSACTION:
               FIND  craptab WHERE
                     craptab.cdcooper = glb_cdcooper      AND       
                     craptab.nmsistem = "CRED"            AND
                     craptab.tptabela = "GENERI"          AND
                     craptab.cdempres = glb_cdcooper      AND         
                     craptab.cdacesso = "COMPEL"          AND
                     craptab.tpregist = 1                 NO-LOCK NO-ERROR.
           
               IF  NOT AVAIL craptab THEN 
                   DO:
                      CREATE craptab.
                      ASSIGN craptab.nmsistem = "CRED"      
                             craptab.tptabela = "GENERI"          
                             craptab.cdempres = glb_cdcooper            
                             craptab.cdacesso = "COMPEL"                
                             craptab.tpregist = 1  
                             craptab.cdcooper = glb_cdcooper.       
                      RELEASE craptab.    
                   END.
            END. /* Fim da Transacao */

            FIND FIRST crapcop WHERE crapcop.cdcooper = glb_cdcooper
                                     NO-LOCK NO-ERROR.
            IF   NOT AVAIL crapcop  THEN 
                 DO:
                     glb_cdcritic = 651.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic "--> SISTEMA CANCELADO!".
                     PAUSE MESSAGE
                         "Tecle <entra> para voltar `a tela de identificacao!".
                     BELL.
                     NEXT.
                 END.

            DO  WHILE TRUE:
                FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                                   craptab.nmsistem = "CRED"            AND
                                   craptab.tptabela = "GENERI"          AND
                                   craptab.cdempres = crapcop.cdcooper  AND
                                   craptab.cdacesso = "COMPEL"          AND
                                   craptab.tpregist = 1 NO-LOCK NO-ERROR.
                                   
                IF   NOT AVAIL craptab THEN 
                     DO:
                         MESSAGE 
                          "Controle nao cad.(Avise Inform) Processo Cancelado!".
                         PAUSE MESSAGE
                          "Tecle <entra> para voltar `a tela de identificacao!".
                         BELL.
                         LEAVE.
                     END.

                IF   craptab.dstextab <> " " THEN
                     DO:
                         MESSAGE
                           "Processo sendo utilizado pelo Operador " +
                           TRIM(SUBSTR(craptab.dstextab,1,20)).
                           PAUSE MESSAGE
                          "Peca liberacao Coordenador/Gerente ou Aguarde......".
                    
                         RUN fontes/pedesenha.p(INPUT glb_cdcooper, 
                                                INPUT 2, 
                                                OUTPUT aut_flgsenha,
                                                OUTPUT aut_cdoperad).
                                                                              
                         IF   aut_flgsenha THEN
                              LEAVE.
                
                         NEXT.
                     END.

                LEAVE.
            END.
            DO TRANSACTION:
               FIND craptab WHERE craptab.cdcooper = glb_cdcooper         AND
                                  craptab.nmsistem = "CRED"               AND
                                  craptab.tptabela = "GENERI"             AND
                                  craptab.cdempres = crapcop.cdcooper     AND
                                  craptab.cdacesso = "COMPEL"             AND
                                  craptab.tpregist = 1  
                                  EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
               IF   AVAIL craptab THEN     
                    DO:
                        ASSIGN craptab.dstextab = glb_cdoperad.
                        RELEASE craptab.
                    END.
            END. /* DO TRANSACTION */  

            /* Instancia a BO 12 */
            RUN sistema/generico/procedures/b1wgen0012.p 
                         PERSISTENT SET h-b1wgen0012.
            
            IF   NOT VALID-HANDLE(h-b1wgen0012)  THEN
                 DO:
                     glb_nmdatela = "COMPEL".
                     BELL.
                     MESSAGE "Handle invalido para BO b1wgen0012.".
                     IF   glb_conta_script = 0 THEN
                          PAUSE 3 NO-MESSAGE.
                          RETURN.
                 END.

            ASSIGN aux_nmdatela = IF   aux_flggerar = "Custodia Cheques" THEN 
                                       "COMPEL_CST"
                                  ELSE
                                       "COMPEL_DSC"
                   aux_nrdcaixa = IF   aux_flggerar = "Custodia Cheques" THEN 
                                       600
                                  ELSE
                                       700.
            
            IF   aux_nmdatela = "COMPEL_DSC" THEN
                 ASSIGN tel_nrdolote = tel_nrborder.

            RUN gerar_arquivos_cecred IN h-b1wgen0012
                                           (INPUT "COMPEL",
                                            INPUT tel_dtmvtopg,
                                            INPUT glb_cdcooper,
                                            INPUT tel_cdagenci,
                                            INPUT aux_cdagefim,
                                            INPUT glb_cdoperad,
                                            INPUT aux_nmdatela,
                                            INPUT tel_nrdolote,        /*Lote*/
                                            INPUT 0,
                                            INPUT STRING(aux_nrdcaixa), /*Cxa*/
                                            OUTPUT glb_cdcritic,
                                            OUTPUT aux_qtarquiv,
                                            OUTPUT aux_totregis,
                                            OUTPUT aux_vlrtotal).

            DELETE PROCEDURE h-b1wgen0012.
                     
            IF   glb_cdcritic > 0  THEN
                 DO:
                     RUN atualiza_controle_operador.
                     NEXT.
                 END.
            
            HIDE MESSAGE NO-PAUSE.

            MESSAGE "Movtos atualizados         ".

            RUN atualiza_controle_operador.

            ASSIGN tot_qtarquiv = aux_qtarquiv
                   tot_vlcheque = aux_vlrtotal.
             
            MESSAGE "Foi(ram) gravado(s) " STRING(tot_qtarquiv, "zzz9") +
                    " arquivo(s) - com o valor total: " + 
                    STRING(tot_vlcheque, "zzz,zzz,zz9.99").

            PAUSE(3) NO-MESSAGE.
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN                              /*  Relatorio  */
        DO:
            RUN proc_limpa.
            
            ASSIGN tel_dtmvtopg = glb_dtmvtolt
                   tel_cdagenci = 0.
        
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_dtmvtopg tel_cdagenci WITH FRAME f_refere.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  MESSAGE COLOR NORMAL
                          "Deseja imprimir Carta ou Relatorio (C/R)?:"
                          UPDATE aux_imprimcr.
                  LEAVE.

               END. /* fim do DO WHILE */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
                    DO:
                        RUN proc_limpa.
                        NEXT.
                    END.

               IF   aux_imprimcr THEN 
                    DO:  /* Escolheu CARTA */
                        IF   tel_cdagenci = 0 THEN 
                             DO:
                                 MESSAGE "Para gerar CARTA deve-se" + 
                                         " selecionar um PA".
                                 NEXT.
                             END.
                        RUN imprimir_carta_remessa.
                    END.
               ELSE  /* Escolheu RELATORIO */
                    RUN fontes/compel_r.p(INPUT tel_dtmvtopg, 
                                          INPUT tel_cdagenci, 
                                          INPUT 0, 
                                          INPUT 0,
                                          INPUT FALSE,
                                          INPUT TABLE crawage,
                                          INPUT NO,
                                          INPUT YES).

            END.  /*  Fim do DO WHILE TRUE  */
         
            HIDE FRAME f_refere.
        END.
   ELSE     
   IF   glb_cddopcao = "P" THEN                            /* Consulta cheque */
        DO:
            RUN proc_limpa.
            
            ASSIGN tel_dsdocmc7 = "".
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               UPDATE tel_dsdocmc7 WITH FRAME f_cmc7

               EDITING:
            
                  READKEY.
        
                  IF   NOT CAN-DO(aux_lsvalido,KEYLABEL(LASTKEY))   THEN
                       DO:
                           glb_cdcritic = 666.
                           NEXT.
                       END.

                  IF   KEYLABEL(LASTKEY) = "G"   THEN
                       APPLY KEYCODE(":").
                  ELSE
                       APPLY LASTKEY.
               
               END.  /*  Fim do EDITING  */
         
               HIDE MESSAGE NO-PAUSE.
           
               IF   TRIM(tel_dsdocmc7) <> ""   THEN
                    DO:
                        IF   LENGTH(tel_dsdocmc7) <> 34            OR
                             SUBSTRING(tel_dsdocmc7,01,1) <> "<"   OR
                             SUBSTRING(tel_dsdocmc7,10,1) <> "<"   OR
                             SUBSTRING(tel_dsdocmc7,21,1) <> ">"   OR
                             SUBSTRING(tel_dsdocmc7,34,1) <> ":"   THEN
                             DO:
                                 glb_cdcritic = 666.
                                 NEXT.
                             END.
        
                        RUN fontes/dig_cmc7.p (INPUT  tel_dsdocmc7,
                                               OUTPUT glb_nrcalcul,
                                               OUTPUT aux_lsdigctr).
                      
                        IF   glb_nrcalcul > 0   THEN
                             DO:
                                 glb_cdcritic = 666.
                                 NEXT.
                             END.

                        IF   glb_cdcritic > 0   THEN
                             NEXT.
                    END.
               ELSE
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                           RUN fontes/cmc7.p (OUTPUT tel_dsdocmc7).
                           
                           IF   LENGTH(tel_dsdocmc7) <> 34   THEN
                                LEAVE.
                         
                           DISPLAY tel_dsdocmc7 WITH FRAME f_cmc7.
                       
                           IF   glb_cdcritic > 0   THEN
                                NEXT.

                           LEAVE.
                   
                        END.  /*  Fim do DO WHILE TRUE  */
                  
                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                             NEXT.
               END.            
            
               VIEW FRAME f_aguarde.
               
               FOR EACH crapchd WHERE 
                        crapchd.cdcooper = glb_cdcooper         AND
                       (crapchd.dtmvtolt > (glb_dtmvtolt - 15)) AND
                        crapchd.dsdocmc7 = tel_dsdocmc7 NO-LOCK
                        BREAK BY crapchd.dtmvtolt DESCENDING:

                   IF   FIRST-OF(crapchd.dtmvtolt) THEN
                        DO:
                            HIDE FRAME f_aguarde NO-PAUSE.
                            
                            DISPLAY crapchd.cdcmpchq crapchd.cdbanchq
                                    crapchd.cdagechq crapchd.nrctachq
                                    crapchd.nrcheque crapchd.vlcheque
                                    WITH FRAME f_dados.
                        END.         
                   
                   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                      crapass.nrdconta = crapchd.nrdconta
                                      NO-LOCK NO-ERROR.
                                      
                   IF   NOT AVAILABLE crapass THEN
                        DO:
                            glb_cdcritic = 9.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                            NEXT.
                        END.
                   ELSE
                        DO:
                            DISPLAY crapchd.dtmvtolt crapchd.nrdconta 
                                    crapass.nmprimtl WITH FRAME f_dados.
                            DOWN.
                        END.
              
               END. /*  Fim do FOR EACH  */
               
               HIDE FRAME f_aguarde NO-PAUSE.
               
               IF   NOT AVAILABLE crapchd THEN
                    DO:
                        CLEAR FRAME f_cmc7.
                        CLEAR FRAME f_dados.
                        glb_cdcritic = 244.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                
            END. /*  Fim do DO WHILE TRUE  */
        
        END.
        
END.  /*  Fim do DO WHILE TRUE  */

/*  ........................................................................  */

PROCEDURE proc_compel:

   DEF INPUT PARAM par_cdbccxlt    AS CHAR           NO-UNDO.

   ASSIGN tel_qtchdcxi = 0
          tel_qtchdcxs = 0
          tel_qtchdcxg = 0
          tel_vlchdcxi = 0
          tel_vlchdcxs = 0
          tel_vlchdcxg = 0
          tel_qtchddci = 0
          tel_qtchddcs = 0
          tel_qtchddcg = 0
          tel_vlchddci = 0
          tel_vlchddcs = 0
          tel_vlchddcg = 0
          tel_qtchdcsi = 0
          tel_qtchdcss = 0
          tel_qtchdcsg = 0
          tel_vlchdcsi = 0
          tel_vlchdcss = 0
          tel_vlchdcsg = 0
          tel_qtchdtti = 0
          tel_qtchdtts = 0
          tel_qtchdttg = 0
          tel_vlchdtti = 0
          tel_vlchdtts = 0
          tel_vlchdttg = 0.
  
   ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN 
                              9999
                         ELSE 
                              tel_cdagenci.
   
   /* Na consulta devera aparecer os dados da CECRED - 085 */
   /* Nas demais operacoes nao devem tratar   CECRED - 085 */
   IF   glb_cddopcao <> "C" THEN
        DO:
            IF   aux_flgenvio THEN /* Enviados */
                 ASSIGN aux_cdbcoenv = "0,1,756," + STRING(crapcop.cdbcoctl).
            ELSE                   /* Nao Enviados */
                 ASSIGN aux_cdbcoenv = "0".
        END.


   FOR EACH crapchd WHERE crapchd.cdcooper  = glb_cdcooper AND
                          crapchd.dtmvtolt  = tel_dtmvtopg AND
                          crapchd.cdagenci >= tel_cdagenci AND
                          crapchd.cdagenci <= aux_cdagefim AND
                          crapchd.inchqcop  = 0            AND
                          crapchd.flgenvio  = aux_flgenvio AND
                          CAN-DO(aux_cdbcoenv,STRING(crapchd.cdbcoenv)) AND
                          CAN-DO(par_cdbccxlt,STRING(crapchd.cdbccxlt))
                          NO-LOCK,
       EACH crawage WHERE crawage.cdagenci  = crapchd.cdagenci 
                          NO-LOCK BREAK BY crawage.cdagenci:

       IF   glb_cddopcao = "B"                   AND
            crawage.cdbanchq = crapcop.cdbcoctl  THEN
            NEXT.

       IF   crapchd.tpdmovto <> 1   AND
            crapchd.tpdmovto <> 2   THEN
            NEXT.
            
       IF   NOT CAN-DO("0,2",STRING(crapchd.insitchq))   THEN  
            NEXT.
       
       IF   CAN-DO("11,500",STRING(crapchd.cdbccxlt))   THEN       /*  CAIXA  */
            DO:
                ASSIGN tel_qtchdcxg = tel_qtchdcxg + 1
                       tel_vlchdcxg = tel_vlchdcxg + crapchd.vlcheque.
               
                IF   crapchd.tpdmovto = 1   THEN       
                     ASSIGN tel_qtchdcxs = tel_qtchdcxs + 1
                            tel_vlchdcxs = tel_vlchdcxs + crapchd.vlcheque
                            
                            tel_qtchdtts = tel_qtchdtts + 1
                            tel_vlchdtts = tel_vlchdtts + crapchd.vlcheque.
                ELSE
                IF   crapchd.tpdmovto = 2   THEN
                     ASSIGN tel_qtchdcxi = tel_qtchdcxi + 1
                            tel_vlchdcxi = tel_vlchdcxi + crapchd.vlcheque

                            tel_qtchdtti = tel_qtchdtti + 1
                            tel_vlchdtti = tel_vlchdtti + crapchd.vlcheque.
            END.
       ELSE
       IF   CAN-DO("600",STRING(crapchd.cdbccxlt))   THEN       /*  CUSTODIA  */
            DO:
                ASSIGN tel_qtchdcsg = tel_qtchdcsg + 1
                       tel_vlchdcsg = tel_vlchdcsg + crapchd.vlcheque.
               
                IF   crapchd.tpdmovto = 1   THEN       
                     ASSIGN tel_qtchdcss = tel_qtchdcss + 1
                            tel_vlchdcss = tel_vlchdcss + crapchd.vlcheque

                            tel_qtchdtts = tel_qtchdtts + 1
                            tel_vlchdtts = tel_vlchdtts + crapchd.vlcheque.
                ELSE
                IF   crapchd.tpdmovto = 2   THEN
                     ASSIGN tel_qtchdcsi = tel_qtchdcsi + 1
                            tel_vlchdcsi = tel_vlchdcsi + crapchd.vlcheque
                            
                            tel_qtchdtti = tel_qtchdtti + 1
                            tel_vlchdtti = tel_vlchdtti + crapchd.vlcheque.
            END.
       ELSE
       IF   CAN-DO("700",STRING(crapchd.cdbccxlt))   THEN      /*  DESC. CHQ  */
            DO:
                ASSIGN tel_qtchddcg = tel_qtchddcg + 1
                       tel_vlchddcg = tel_vlchddcg + crapchd.vlcheque.
               
                IF   crapchd.tpdmovto = 1   THEN       
                     ASSIGN tel_qtchddcs = tel_qtchddcs + 1
                            tel_vlchddcs = tel_vlchddcs + crapchd.vlcheque

                            tel_qtchdtts = tel_qtchdtts + 1
                            tel_vlchdtts = tel_vlchdtts + crapchd.vlcheque.
                ELSE
                IF   crapchd.tpdmovto = 2   THEN
                     ASSIGN tel_qtchddci = tel_qtchddci + 1
                            tel_vlchddci = tel_vlchddci + crapchd.vlcheque
                            
                            tel_qtchdtti = tel_qtchdtti + 1
                            tel_vlchdtti = tel_vlchdtti + crapchd.vlcheque.
            END.
       
       ASSIGN tel_qtchdttg = tel_qtchdttg + 1
              tel_vlchdttg = tel_vlchdttg + crapchd.vlcheque.
                        
   END.  /*  Fim do FOR EACH  --  Leitura do crapchd  */

   IF   tel_qtchdttg <> (tel_qtchdcxg + tel_qtchdcsg + tel_qtchddcg)   OR
        tel_vlchdttg <> (tel_vlchdcxg + tel_vlchdcsg + tel_vlchddcg)   THEN
        DO:
            MESSAGE "ERRO - Informe o CPD ==> Qtd: "
                    STRING(tel_qtchdcxg + tel_qtchdcsg + tel_qtchddcg,
                           "zzz,zz9-")
                    " Valor: " 
                    STRING(tel_vlchdcxg + tel_vlchdcsg + tel_vlchddcg,
                           "zzz,zzz,zz9.99-") .
        END.
   
   DISPLAY tel_qtchdcxi tel_vlchdcxi
           tel_qtchdcxs tel_vlchdcxs
           tel_qtchdcxg tel_vlchdcxg
           
           tel_qtchdcsi tel_vlchdcsi
           tel_qtchdcss tel_vlchdcss
           tel_qtchdcsg tel_vlchdcsg

           tel_qtchddci tel_vlchddci
           tel_qtchddcs tel_vlchddcs
           tel_qtchddcg tel_vlchddcg
           
           tel_qtchdtti tel_vlchdtti
           tel_qtchdtts tel_vlchdtts
           tel_qtchdttg tel_vlchdttg
           WITH FRAME f_total.

END PROCEDURE.

PROCEDURE proc_compel_custodia:

   DEF INPUT PARAM par_cddopcao    AS CHAR           NO-UNDO.
   DEF INPUT PARAM par_cdbccxlt    AS CHAR           NO-UNDO.
   
   DEF VAR tab_vlchqmai            AS DECI           NO-UNDO.
   DEF VAR flg_existe              AS LOGICAL        NO-UNDO.

   ASSIGN tel_qtchddci = 0
          tel_qtchddcs = 0
          tel_qtchddcg = 0
          tel_vlchddci = 0
          tel_vlchddcs = 0
          tel_vlchddcg = 0
          tel_qtchdcsi = 0
          tel_qtchdcss = 0
          tel_qtchdcsg = 0
          tel_vlchdcsi = 0
          tel_vlchdcss = 0
          tel_vlchdcsg = 0
          tel_qtchdtti = 0
          tel_qtchdtts = 0
          tel_qtchdttg = 0
          tel_vlchdtti = 0
          tel_vlchdtts = 0
          tel_vlchdttg = 0
          aux_dtprevia = ?
          aux_dssituac = ""
          flg_existe   = FALSE.


   FIND FIRST craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                            craplot.dtmvtolt = tel_dtmvtopg       AND
                            craplot.cdagenci = tel_cdagenci       AND
                            craplot.cdbccxlt = INTE(par_cdbccxlt) AND
                            craplot.nrdolote = tel_nrdolote 
                            NO-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAIL craplot  THEN
        DO:
            glb_cdcritic = 60.
            RETURN "NOK".
        END.
  
   FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                            craptab.nmsistem = "CRED"           AND
                            craptab.tptabela = "USUARI"         AND
                            craptab.cdempres = 11               AND
                            craptab.cdacesso = "MAIORESCHQ"     AND
                            craptab.tpregist = 1
                            NO-LOCK NO-ERROR.

   IF   NOT AVAIL craptab   THEN
        ASSIGN tab_vlchqmai = 1.
   ELSE
        ASSIGN tab_vlchqmai  = DEC(SUBSTR(craptab.dstextab,1,15)).

   aux_dsmessag = "".
      
   FOR EACH crapcst WHERE crapcst.cdcooper  = glb_cdcooper AND
                          crapcst.dtmvtolt  = tel_dtmvtopg AND
                          crapcst.cdagenci  = tel_cdagenci AND
                          crapcst.nrdolote  = tel_nrdolote AND
                         (crapcst.insitchq  = 0            OR
                          crapcst.insitchq  = 2)
                          NO-LOCK:

       IF   crapcst.cdagenci <> tel_cdagenci THEN
            DO:
                MESSAGE "PA invalido.".
                PAUSE 10 NO-MESSAGE.
                LEAVE.
            END.

       IF   par_cddopcao = "B"    AND
            crapcst.insitprv <> 0 THEN
            DO:
                aux_dsmessag = 
                          "Nao eh possivel gerar a Previa. Previa ja gerada.".
                NEXT.
            END.
       
       IF   par_cddopcao = "X"   AND
            crapcst.insitprv = 0 THEN
            DO:
                aux_dsmessag = "Nao eh possivel reativar a Previa.".
                NEXT.
            END.
                   
       ASSIGN tel_qtchdcsg = tel_qtchdcsg + 1
              tel_vlchdcsg = tel_vlchdcsg + crapcst.vlcheque
              aux_dtprevia = crapcst.dtprevia
              flg_existe   = TRUE.

       CASE crapcst.insitprv:
            WHEN 0 THEN aux_dssituac = "Nao Enviado".
            WHEN 1 THEN aux_dssituac = "Gerado".
            WHEN 2 THEN aux_dssituac = "Digitalizado".
            WHEN 3 THEN aux_dssituac = "Processado".
       END CASE.
       
       IF   crapcst.vlcheque >= tab_vlchqmai   THEN
            ASSIGN tel_qtchdcss = tel_qtchdcss + 1
                   tel_vlchdcss = tel_vlchdcss + crapcst.vlcheque
                   tel_qtchdtts = tel_qtchdtts + 1
                   tel_vlchdtts = tel_vlchdtts + crapcst.vlcheque.
       ELSE
            ASSIGN tel_qtchdcsi = tel_qtchdcsi + 1
                   tel_vlchdcsi = tel_vlchdcsi + crapcst.vlcheque
                   tel_qtchdtti = tel_qtchdtti + 1
                   tel_vlchdtti = tel_vlchdtti + crapcst.vlcheque.
       
       ASSIGN tel_qtchdttg = tel_qtchdttg + 1
              tel_vlchdttg = tel_vlchdttg + crapcst.vlcheque.
                        
   END.  /*  Fim do FOR EACH  --  Leitura do crapchd  */

   
   IF   aux_dsmessag <> "" THEN
        DO:
            MESSAGE aux_dsmessag.
            PAUSE 10 NO-MESSAGE.
        END.

   
   IF   NOT flg_existe  THEN
        DO:
            ASSIGN glb_cdcritic = 301.
            RETURN "NOK".
        END.

   
   DISPLAY tel_qtchdcsi tel_vlchdcsi
           tel_qtchdcss tel_vlchdcss
           tel_qtchdcsg tel_vlchdcsg

           tel_qtchddci tel_vlchddci
           tel_qtchddcs tel_vlchddcs
           tel_qtchddcg tel_vlchddcg
           
           tel_qtchdtti tel_vlchdtti
           tel_qtchdtts tel_vlchdtts
           tel_qtchdttg tel_vlchdttg

           aux_dtprevia aux_dssituac
           WITH FRAME f_total_2.

END PROCEDURE.

PROCEDURE proc_compel_dscchq:

   DEF INPUT PARAM par_cddopcao    AS CHAR           NO-UNDO.
   DEF INPUT PARAM par_cdbccxlt    AS CHAR           NO-UNDO.
   DEF VAR tab_vlchqmai            AS DECI           NO-UNDO.
   DEF VAR flg_existe              AS LOGICAL        NO-UNDO.

   ASSIGN tel_qtchddci = 0
          tel_qtchddcs = 0
          tel_qtchddcg = 0
          tel_vlchddci = 0
          tel_vlchddcs = 0
          tel_vlchddcg = 0
          tel_qtchdcsi = 0
          tel_qtchdcss = 0
          tel_qtchdcsg = 0
          tel_vlchdcsi = 0
          tel_vlchdcss = 0
          tel_vlchdcsg = 0
          tel_qtchdtti = 0
          tel_qtchdtts = 0
          tel_qtchdttg = 0
          tel_vlchdtti = 0
          tel_vlchdtts = 0
          tel_vlchdttg = 0
          aux_dtprevia = ?
          aux_dssituac = "".
   
   ASSIGN flg_existe = FALSE.

   FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper AND
                            craptab.nmsistem = "CRED"           AND
                            craptab.tptabela = "USUARI"         AND
                            craptab.cdempres = 11               AND
                            craptab.cdacesso = "MAIORESCHQ"     AND
                            craptab.tpregist = 1
                            NO-LOCK NO-ERROR.
   
   IF   NOT AVAIL craptab   THEN
        ASSIGN tab_vlchqmai = 1.
   ELSE
        ASSIGN tab_vlchqmai = DEC(SUBSTR(craptab.dstextab,1,15)).

   aux_dsmessag = "".
      
   FOR FIRST crapprm FIELDS(dsvlrprm)
                  WHERE crapprm.nmsistem = 'CRED' AND
                        crapprm.cdcooper = 0      AND
                        crapprm.cdacesso = 'DT_BLOQ_ARQ_DSC_CHQ'
                        NO-LOCK: END.
   IF NOT AVAILABLE crapprm THEN
     DO:
          MESSAGE "Data de bloqueio nao encontrada.".
          PAUSE 10 NO-MESSAGE.
          LEAVE.
     END.
   
   FOR EACH crapcdb WHERE crapcdb.cdcooper  = glb_cdcooper AND
                          crapcdb.nrborder  = tel_nrborder AND
                         (crapcdb.insitchq  = 0            OR
                          crapcdb.insitchq  = 2)
                          NO-LOCK:

       IF   crapcdb.dtmvtolt > DATE(crapprm.dsvlrprm) THEN
            DO:
                MESSAGE 'Opcao nao permitida para borderos gerados apos' crapprm.dsvlrprm '.'.
                PAUSE 10 NO-MESSAGE.
                LEAVE.
            END.
       
       IF   crapcdb.dtlibbdc = ? THEN
            DO:
                MESSAGE "Bordero nao aprovado.".
                PAUSE 10 NO-MESSAGE.
                LEAVE.
            END.
            
       IF   crapcdb.dtlibbdc <> tel_dtmvtopg OR
            crapcdb.cdagenci <> tel_cdagenci THEN
            DO:
                MESSAGE "Data da aprovacao ou PA invalido.".
                PAUSE 10 NO-MESSAGE.
                LEAVE.
            END.
       
       IF   par_cddopcao = "B"    AND
            crapcdb.insitprv <> 0 THEN
            DO:
                aux_dsmessag = 
                        "Nao eh possivel gerar a Previa. Previa ja gerada.".
                NEXT.
            END.
       
       IF   par_cddopcao = "X"    AND
            crapcdb.insitprv = 0  THEN
            DO:
                aux_dsmessag = "Nao eh possivel reativar a Previa.".
                NEXT.
            END.
                   
                   
       ASSIGN tel_qtchddcg = tel_qtchddcg + 1
              tel_vlchddcg = tel_vlchddcg + crapcdb.vlcheque
              flg_existe   = TRUE
              aux_dtprevia = crapcdb.dtprevia.

       CASE crapcdb.insitprv:
              WHEN 0 THEN aux_dssituac = "Nao Enviado".
              WHEN 1 THEN aux_dssituac = "Gerado".
              WHEN 2 THEN aux_dssituac = "Digitalizado".
              WHEN 3 THEN aux_dssituac = "Processado".
       END CASE.

       IF   crapcdb.vlcheque >= tab_vlchqmai THEN
            ASSIGN tel_qtchddcs = tel_qtchddcs + 1
                   tel_vlchddcs = tel_vlchddcs + crapcdb.vlcheque

                   tel_qtchdtts = tel_qtchdtts + 1
                   tel_vlchdtts = tel_vlchdtts + crapcdb.vlcheque.
       ELSE
            ASSIGN tel_qtchddci = tel_qtchddci + 1
                   tel_vlchddci = tel_vlchddci + crapcdb.vlcheque
                   
                   tel_qtchdtti = tel_qtchdtti + 1
                   tel_vlchdtti = tel_vlchdtti + crapcdb.vlcheque.
       
       ASSIGN tel_qtchdttg = tel_qtchdttg + 1
              tel_vlchdttg = tel_vlchdttg + crapcdb.vlcheque.
                        
   END.  /*  Fim do FOR EACH  --  Leitura do crapcdb  */

   IF   aux_dsmessag <> "" THEN
        DO:
            MESSAGE aux_dsmessag.
            PAUSE 10 NO-MESSAGE.
        END.
      
      
   IF   NOT flg_existe  THEN
        DO:
            ASSIGN glb_cdcritic = 301.
            RETURN "NOK".
        END.

   DISPLAY tel_qtchdcsi tel_vlchdcsi
           tel_qtchdcss tel_vlchdcss
           tel_qtchdcsg tel_vlchdcsg

           tel_qtchddci tel_vlchddci
           tel_qtchddcs tel_vlchddcs
           tel_qtchddcg tel_vlchddcg
           
           tel_qtchdtti tel_vlchdtti
           tel_qtchdtts tel_vlchdtts
           tel_qtchdttg tel_vlchdttg

           aux_dtprevia aux_dssituac
           WITH FRAME f_total_2.

END PROCEDURE.


PROCEDURE proc_limpa: /*  Procedure para limpeza da tela  */
    
    HIDE FRAME f_total.
    HIDE FRAME f_total_2.
    HIDE FRAME f_fechamento.
    HIDE FRAME f_refere.
    HIDE FRAME f_refere_caixa.
    HIDE FRAME f_refere_custodia.
    HIDE FRAME f_refere_desconto.
    HIDE FRAME f_cmc7.
    HIDE FRAME f_movto.
    HIDE FRAME f_dados.
    HIDE FRAME f_agencia.
    HIDE FRAME f_regera.
    HIDE FRAME f_opcao_d.
    HIDE FRAME f_atencao.
    HIDE FRAME f_det_docto.
    
    RETURN.

END PROCEDURE.

PROCEDURE p_regera_agencia:

  ASSIGN aux_confirma = "N".
  UPDATE   aux_confirma WITH FRAME f_regera.
  
  IF   aux_confirma <> "N" THEN 
       DO:
           EMPTY TEMP-TABLE crawage.

           FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:
               CREATE crawage.
               ASSIGN crawage.cdagenci = crapage.cdagenci
                      crawage.nmresage = crapage.nmresage
                      crawage.nmcidade = crapage.nmcidade 
                      crawage.cdagecbn = crapage.cdagecbn
                      crawage.cdbanchq = crapage.cdbanchq.
           END.
       END.
  
  HIDE FRAME f_regera NO-PAUSE.
  
END PROCEDURE.


PROCEDURE atualiza_compel:

   HIDE MESSAGE NO-PAUSE.
   
   MESSAGE "Atualizando movtos gerados ...".

   ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN 
                              9999
                         ELSE tel_cdagenci.

   FOR EACH crapchd WHERE crapchd.cdcooper = glb_cdcooper   AND
                          crapchd.dtmvtolt = tel_dtmvtopg   AND
                          crapchd.inchqcop = 0              AND
                          crapchd.cdagenci >= tel_cdagenci  AND
                          crapchd.cdagenci <= aux_cdagefim  AND
                          crapchd.flgenvio = NO NO-LOCK    
                          USE-INDEX crapchd3,
       EACH crawage WHERE crawage.cdagenci  = crapchd.cdagenci AND
                          /*Processamento para cecred eh feito pela PRCCTL*/
                          crawage.cdbanchq <> crapcop.cdbcoctl NO-LOCK:
             
       DO WHILE TRUE:
           
           FIND crabchd WHERE RECID(crabchd) = RECID(crapchd) 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crabchd   THEN
                IF   LOCKED crabchd   THEN
                     DO:
                        glb_cdcritic = 77.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           PAUSE(3) NO-MESSAGE.
                           LEAVE.
                        END.
                        NEXT.
                     END.
           
           ASSIGN crabchd.flgenvio = TRUE
                  crabchd.cdbcoenv = crawage.cdbanchq.
           RELEASE crabchd.
           LEAVE.
       END.
   END.  /* fim do FOR EACH */
   
END PROCEDURE.

PROCEDURE atualiza_compel_regerar:

   HIDE MESSAGE NO-PAUSE.
   
   MESSAGE "Atualizando movtos gerados ...".

   ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN 
                              9999
                         ELSE tel_cdagenci.

   FOR EACH crapchd WHERE crapchd.cdcooper = glb_cdcooper   AND
                          crapchd.dtmvtolt = tel_dtmvtopg   AND
                          crapchd.inchqcop = 0              AND
                          crapchd.cdagenci >= tel_cdagenci  AND
                          crapchd.cdagenci <= aux_cdagefim  AND
                          crapchd.flgenvio = YES NO-LOCK    
                          USE-INDEX crapchd3,
       EACH crawage WHERE crawage.cdagenci  = crapchd.cdagenci AND
                          crawage.cdbanchq <> crapcop.cdbcoctl NO-LOCK:
   
       DO WHILE TRUE:
           
           FIND crabchd WHERE RECID(crabchd) = RECID(crapchd) 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crabchd   THEN
                IF   LOCKED crabchd   THEN
                     DO:
                         glb_cdcritic = 77.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            PAUSE(3) NO-MESSAGE.
                            LEAVE.
                         END.
                         NEXT.
                     END.
           
           ASSIGN crabchd.flgenvio = NO
                  crabchd.cdbcoenv = 0.
           RELEASE crabchd.
           LEAVE.

       END.
   END.  /* fim do FOR EACH */
   
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:
      FOR EACH gncpchq WHERE gncpchq.cdcooper =  glb_cdcooper AND
                             gncpchq.dtmvtolt =  glb_dtmvtolt AND
                             gncpchq.cdtipreg =  1            AND
                             gncpchq.cdagenci >= tel_cdagenci AND
                             gncpchq.cdagenci <= aux_cdagefim 
                             EXCLUSIVE-LOCK:
          DELETE gncpchq.
      END.
   END.   /* TRANSACTION */

   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
            " - " + STRING(glb_dtmvtolt,"99/99/9999") +
            " - CHEQUES REGERADOS - PA de " + 
            STRING(tel_cdagenci) + " ate " + STRING(aux_cdagefim) +
            " - Data: " + STRING(tel_dtmvtopg,"99/99/9999") +
            " >> log/compel.log").
   
END PROCEDURE.

PROCEDURE atualiza_controle_operador.

  FIND craptab WHERE craptab.cdcooper = glb_cdcooper         AND
                     craptab.nmsistem = "CRED"               AND       
                     craptab.tptabela = "GENERI"             AND
                     craptab.cdempres = crapcop.cdcooper     AND       
                     craptab.cdacesso = "COMPEL"             AND
                     craptab.tpregist = 1  
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  IF   AVAIL craptab THEN      
       DO:
           ASSIGN craptab.dstextab = " ".
           RELEASE craptab.
       END.

END PROCEDURE.

PROCEDURE p_divinome:
/******* Divide o campo aux_nmextcop em duas Strings *******/
  ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(aux_nmextcop)," ") / 2
                        rel_nmressbr = "".

  DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(aux_nmextcop)," "):
     IF   aux_contapal <= aux_qtpalavr   THEN
          rel_nmressbr[1] = rel_nmressbr[1] +   
                      (IF TRIM(rel_nmressbr[1]) = "" THEN "" ELSE " ") 
                           + ENTRY(aux_contapal,aux_nmextcop," ").
     ELSE
          rel_nmressbr[2] = rel_nmressbr[2] +
                      (IF TRIM(rel_nmressbr[2]) = "" THEN "" ELSE " ")
                           + ENTRY(aux_contapal,aux_nmextcop," ").
  END.  /*  Fim DO .. TO  */ 
           
END PROCEDURE.


/*  ........................................................................  */

PROCEDURE imprimir_carta_remessa:

   /* variaveis para impressao */
   DEF VAR aux_dsbcoctl AS CHAR                                  NO-UNDO.
   DEF VAR aux_dscooper AS CHAR                                  NO-UNDO.
   DEF VAR aux_cdagectl AS INT                                   NO-UNDO.
   DEF VAR aux_dsagenci AS CHAR                                  NO-UNDO.
   DEF VAR aux_dtrefere AS DATE                                  NO-UNDO.

   /* variaveis para impressao */
   DEF VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
   DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
   DEF VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
   DEF VAR aux_flgescra AS LOGICAL                               NO-UNDO.
   DEF VAR aux_dscomand AS CHAR                                  NO-UNDO.
   DEF VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
   DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
   DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
   DEF VAR par_flgcance AS LOGICAL                               NO-UNDO.
   
   /* variaveis para o cabecalho */
   DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
   DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
   DEF VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.

   FORM aux_dsbcoctl   LABEL "INSTITUICAO FINANCEIRA." FORMAT "x(40)" SKIP
        aux_dscooper   LABEL "COOPERATIVA............" FORMAT "x(40)" SKIP
        aux_cdagectl   LABEL "CODIGO DA COOPERATIVA.." FORMAT "9999"  SKIP
        aux_dsagenci   LABEL "PA....................." FORMAT "x(40)" SKIP
        tel_dtmvtopg   LABEL "DATA..................." SKIP(3)
        "CARTA REMESSA DE CHEQUES"               AT 28
        "PROCESSAMENTO ELETRONICO"               AT 28
        SKIP(3)
        "CHEQUES SUPERIORES"                     SKIP
        "------------------"                     SKIP
        tel_qtchdtts   LABEL "QUANT. DE DOCUMENTOS..."  SKIP
        tel_vlchdtts   LABEL "VALOR TOTAL DA REMESSA."
        SKIP(2)
        "CHEQUES INFERIORES"                     SKIP
        "------------------"                     SKIP
        tel_qtchdtti   LABEL "QUANT. DE DOCUMENTOS..."  SKIP
        tel_vlchdtti   LABEL "VALOR TOTAL DA REMESSA."
        SKIP(2)
        "TOTAL GERAL"                            SKIP
        "-----------"                            SKIP
        tel_qtchdttg   LABEL "QUANT. DE DOCUMENTOS..."  SKIP
        tel_vlchdttg   LABEL "VALOR TOTAL DA REMESSA."
        SKIP(5)
        "___________________________________"    AT 1
        "___________________________________"    AT 46 SKIP
        "CARIMBO E ASSINATURA DA COOPERATIVA"    AT 1
        "CARIMBO E ASSINATURA DA ABBC"           AT 50 SKIP
        WITH SIDE-LABELS NO-BOX WIDTH 84 FRAME f_carta.
    
   ASSIGN tel_qtchdtti = 0
          tel_qtchdtts = 0
          tel_qtchdttg = 0
          tel_vlchdtti = 0
          tel_vlchdtts = 0
          tel_vlchdttg = 0.

   UNIX SILENT VALUE("rm rl/crrl555_" + STRING(tel_cdagenci,"9999") + 
                     "* 2> /dev/null").

   FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                      crapage.cdagenci = tel_cdagenci  NO-LOCK NO-ERROR.

   IF  NOT AVAIL crapage  THEN
       DO:
           MESSAGE "PA inexistente.".
           RETURN.
       END.
   
   ASSIGN aux_nmarqimp = "rl/crrl555_" + STRING(tel_cdagenci,"9999") + ".lst"
          glb_cdempres = 11
          glb_nrdevias = 1
          glb_nmformul = "80col"           
          glb_cdrelato = 555
          aux_cdbcoenv = STRING(crapcop.cdbcoctl)
          aux_dsbcoenv = "CECRED"
          aux_dsbcoctl = STRING(INT(aux_cdbcoenv),"999") + " - " + aux_dsbcoenv
          aux_dscooper = crapcop.nmextcop /*crapcop.nmrescop*/
          aux_cdagectl = crapcop.cdagectl
          aux_dsagenci = STRING(crapage.cdagenci,"999") + " - " + 
                         crapage.nmresage.

   /* Buscar cheques tanto enviados quanto nao enviados */
   FOR EACH crapchd WHERE crapchd.cdcooper = glb_cdcooper AND
                          crapchd.dtmvtolt = tel_dtmvtopg AND
                          crapchd.cdagenci = tel_cdagenci AND
                          crapchd.inchqcop = 0           
                          NO-LOCK,
       EACH crawage WHERE crawage.cdagenci = crapchd.cdagenci AND
                          crawage.cdbanchq = crapcop.cdbcoctl NO-LOCK
                          BREAK BY crawage.cdagenci:

       IF   crapchd.tpdmovto <> 1   AND
            crapchd.tpdmovto <> 2   THEN
            NEXT.
            
       IF   NOT CAN-DO("0,2",STRING(crapchd.insitchq))   THEN  
            NEXT.
       
       IF   crapchd.tpdmovto = 1   THEN       
            ASSIGN tel_qtchdtts = tel_qtchdtts + 1
                   tel_vlchdtts = tel_vlchdtts + crapchd.vlcheque.
       ELSE
       IF   crapchd.tpdmovto = 2   THEN
            ASSIGN tel_qtchdtti = tel_qtchdtti + 1
                   tel_vlchdtti = tel_vlchdtti + crapchd.vlcheque.

       ASSIGN tel_qtchdttg = tel_qtchdttg + 1
              tel_vlchdttg = tel_vlchdttg + crapchd.vlcheque.
                     
   END.  /*  Fim do FOR EACH  --  Leitura do craptit  */


   OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.
    
   { includes/cabrel080_2.i }
    
   VIEW STREAM str_2 FRAME f_cabrel080_2.

   DISPLAY STREAM str_2 aux_dsbcoctl  aux_dscooper   aux_cdagectl
                        aux_dsagenci  tel_dtmvtopg   tel_qtchdtti
                        tel_qtchdtts  tel_qtchdttg   tel_vlchdtti
                        tel_vlchdtts  tel_vlchdttg   WITH FRAME f_carta.

   OUTPUT STREAM str_2 CLOSE.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 

      MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.

      IF   tel_cddopcao = "I" THEN
           DO:
               /* somente para a includes/impressao.i */
               FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                                        NO-LOCK NO-ERROR.
                 
               { includes/impressao.i }
           END.    
      ELSE
          IF   tel_cddopcao = "T" THEN
               RUN fontes/visrel.p (INPUT aux_nmarqimp).
          ELSE
               NEXT.
           
      LEAVE.           
   END.

END PROCEDURE.

/* .......................................................................... */

