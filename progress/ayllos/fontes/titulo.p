/* ............................................................................

   Programa: Fontes/titulo.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Setembro/2000                   Ultima alteracao: 26/05/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela titulo.

   Alteracoes: 16/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
   
               05/01/2001 - Tratar nessa tela somente os lancamentos do tipo
                            de lote 20 (Deborah).
                            
               01/09/2003 - Implementacao titulos do Banco do Brasil 
                            (Ze Eduardo).

               18/12/2003 - Alterado para NAO gerar arquivo no ultimo dia
                            do ano (31/12) (Edson).
                            
               29/01/2004 - Alterado p/ desprezar PAC selecionados
                            (Incluidas opcoes E,V,X) (Mirtes)
               
               11/02/2004 - Implementado controle horarios por PAC(Mirtes)
               
               14/04/2004 - Alteracao no LayOut do Banco do Brasil (Ze Eduardo)
               
               15/04/2004 - Inclusao de um frame help para as opcoes da 
                            tela (Julio).
                            
               27/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).
                            
               14/03/2005 - Se tela em uso por outro operador, solicitar
                            liberacao coordenador(pedesenha.p)(Mirtes)
                            
               24/06/2005 - Criada opcao "D" (Evandro).
               
               14/07/2005 - Mudada opcao "D" para opcao "M" e possibilidade
                            de visualizacao na tela (Evandro).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               17/11/2005 - Comentada opcao "T" (Diego).
               
               02/02/2006 - Unificacao dos Bancos - SQLWorks - Eder

               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada
                            do programa fontes/pedesenha.p - SQLWorks - 
                            Fernando.

               23/02/2006 - Nao selecionar titulos da cooperativa
                            (Desprezar craptit.intitcop = 1)(Mirtes)

               26/09/2006 - Se glb_cdoperad = "1","996","997" pode-se alterar a 
                            situacao dos arquivos (David).
                            
               15/01/2007 - Gerar arquivos BB e BANCOOB (Evandro).
               
               09/04/2007 - Separar os arquivos por Agencia - Bancoob (Ze).
               
               06/08/2007 - Criar craptab controle de operador se nao existir
                            (Guilherme).
               
               09/08/2007 - Somente operador 1 nas opcoes 'A' 'B' 'X';
                          - Opcao B quando '0'(listar todos) nao listar pac 90.
                            (Guilherme).

               15/08/2007 - Indicar titulo pago Internet (Guilherme)
                          - Permitir opcao "B" para PAC 90 separadamente;
                          - Para o PAC 90 nao eh permitida a alteracao do
                            horario (a tela CADPAC faz isso) (Evandro).
                          
               24/09/2007 - Verificar se movimentos nos titulos e faturas
                            conferem com debitos efetuados nas contas
                            (Evandro).

               03/10/2007 - Armazenar horario final para geracao de titulos
                            (utilizado na internet) na craptab (David).

               20/12/2007 - Parametrizacao para pagamentos de titulos efetuados
                            no dia 31/12 (David).

               25/02/2008 - Na opcao de Relatorio ("R"), permitir emitir
                            relatorio de conferencia titulo via internet
                            (Sidnei - Precise).
                            
               02/05/2008 - Contabilizar os estornos dos pagamentos feitos pela
                            internet (Evandro).
                            
               19/06/2008 - Correcao do historico de estornos e nao tratar mais
                            as faturas (Evandro).

               23/06/2008 - Correcao na atualizacao dos paramentros da 
                            HRTRTITULO (David).

               20/08/2008 - Tratar praca de compensacao (Magui).

               29/09/2008 - Alterar tipo de Documento - Circular BB (Ze).
               
               04/11/2008 - Tratamento tecla CTRL-C nos relatorios (Martin).
               
               14/04/2009 - Tratamento para sequencial do lote na geracao do 
                            arquivo para o Bancoob (David).
                            
               25/05/2009 - Alteracao CDOPERAD (Kbase).

               27/07/2009 - Utilizar campo crapage.cdcomchq para definir codigo
                            da Compe nos arquivos de remessa (David).
                            
               28/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de TITULO (cdagetit e
                            cdbantit) - (Sidnei - Precise).
                            
               01/10/2009 - Precise - Paulo. Alterado programa para gravar 
                            em tabela generica quando o banco for cecred (997)
                            e imprimir em saparado dos demais (BB e Bancoob)
                          - Alterado programa para nao se basear no codigo fixo
                            997 para CECRED, mas sim utilizar o campo cdbcoctl
                            da CRAPCOP. (Guilherme/Precise)
                          - Alteracao do nome do arquivo quando CECRED, padrao
                            definido pela ABBC. (Guilherme/Precise)
                          - Inclusao do campo BANCO na tela, processamento de 
                            acordo com a opcao selecionada, gravar valor no
                            campo cdbcoenv na geracao do arquivo e atribuir 0
                            na "atualiza_compel_regerar" (Guilherme/Precise)

                          - Validar operadores para CECRED (Guilherme).

                          - Inclusao da chamada da BO b1wgen0012 nas opcoes
                            "B", "C" e "X". (Guilherme/Supero)
                          - Redefinir a crawage dos programas Titulo, Doctos,
                            Compel, para igualar a da BO b1wgen0012
                            (Guilherme/Supero).

                          - Remocao da BO b1wgen0012 (Guilherme/Supero)

                          - Nao gerar mais para CECRED na opcao "B". Sera
                            apenas via PRCCTL (Guilherme/Supero)

                          - Mover a opcao de Imprimir Carta para dentro da
                            opcao "R", questionando se deseja imprimir a Carta
                            ou o Relatorio (Guilherme/Supero)
                            
               15/06/2010 - Tratamento para PAC 91 - TAA (Elton).    
               
               13/07/2010 - Tratar PAC 91 - TAA na opcao 'R' (Guilherme).
               
               16/04/2012 - Fonte substituido por titulop.p (Tiago).
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               13/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)
                            
               10/01/2014 - Alterada critica "15 - Agencia nao cadastrada" para
                            "962 - PA nao cadastrado".
                          - Adicionado VALIDATE quando PA nao for encontrado
                          - Removida critica 089. (Reinert)
                          
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

		       08/12/2016 - P341-Automatização BACENJUD - Realizar a validação 
			                do departamento pelo código do mesmo (Renato Darosci)

			   07/02/2018 - Ajustado horario limite para digitacao dos titulos ate 22
							(Adriano - SD 845726).

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
                            

............................................................................ */

{ includes/var_online.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF    VAR aut_flgsenha AS LOGICAL                                   NO-UNDO.
DEF    VAR aut_cdoperad AS CHAR                                      NO-UNDO.
DEF    VAR aux_posregis AS RECID                                     NO-UNDO.
DEF    VAR rel_nmempres AS CHAR                                      NO-UNDO.

DEF TEMP-TABLE crawage                                               NO-UNDO
         FIELD  cdagenci      LIKE crapage.cdagenci
         FIELD  nmresage      LIKE crapage.nmresage
         FIELD  nmcidade      LIKE crapage.nmcidade 
         FIELD  cdbandoc      LIKE crapage.cdbandoc
         FIELD  cdbantit      LIKE crapage.cdbantit
         FIELD  cdagecbn      LIKE crapage.cdagecbn
         FIELD  cdbanchq      LIKE crapage.cdbanchq
         FIELD  cdcomchq      LIKE crapage.cdcomchq.

DEFINE TEMP-TABLE cratlot                                            NO-UNDO
       FIELD cdagenci AS INT     FORMAT "zz9"
       FIELD cdbccxlt AS INT     FORMAT "zz9"
       FIELD nrdolote AS INT     FORMAT "zzz,zz9"
       FIELD qttitulo AS INT     FORMAT "zzz,zz9"
       FIELD vltitulo AS DECIMAL FORMAT "zzzz,zzz,zz9.99"
       FIELD nmoperad AS CHAR    FORMAT "x(10)"
       FIELD nmarquiv AS CHAR    FORMAT "x(24)".

DEF QUERY q_agencia  FOR crawage. 
                                     
DEF BROWSE b_agencia  QUERY q_agencia
      DISP crawage.cdagenci COLUMN-LABEL "PA" 
           crawage.nmresage COLUMN-LABEL "Nome"
           WITH 13 DOWN CENTERED NO-BOX.

DEF    BUFFER crabtit  FOR craptit.
DEF    BUFFER crablcm  FOR craplcm.

DEF        VAR tel_nrdhhini AS INT                                   NO-UNDO.
DEF        VAR tel_nrdmmini AS INT                                   NO-UNDO.
DEF        VAR tel_cdagenci AS INT    FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_dssituac AS CHAR   FORMAT "x(30)"                 NO-UNDO.
DEF        VAR tel_cddsenha AS CHAR   FORMAT "x(10)"                 NO-UNDO.
DEF        VAR tel_qttitcxa AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qttitprg AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qttitrec AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qttiterr AS INT    FORMAT "zzz,zz9-"              NO-UNDO.
DEF        VAR tel_qttitrgt AS INT    FORMAT "zzz,zz9-"              NO-UNDO.
DEF        VAR tel_qttitulo AS INT    FORMAT "zzz,zz9"               NO-UNDO.

DEF   VAR tel_situacao AS LOG   FORMAT "NAO PROCESSADO/PROCESSADO"   NO-UNDO.

DEF        VAR tel_vltitcxa AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vltitprg AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vltitrec AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vltiterr AS DECI   FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.
DEF        VAR tel_vltitrgt AS DECI   FORMAT "zzz,zzz,zz9.99-"       NO-UNDO.
DEF        VAR tel_vltitulo AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.

DEF        VAR tel_dtmvtopg AS DATE   FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_flgenvio AS LOG    FORMAT "Enviados/Nao Enviados" NO-UNDO.
DEF        VAR tel_nrdcaixa AS INT    FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_cddopcao AS CHAR   FORMAT "!(1)"                  NO-UNDO.

DEF        VAR tel_tprelati AS LOG    FORMAT "Conferencia/Normal"    NO-UNDO.
DEF        VAR aux_imprimcr AS LOG    FORMAT "Carta/Relatorio"       NO-UNDO.

DEF        VAR tel_cdbcoenv AS CHAR   FORMAT "x(15)" VIEW-AS COMBO-BOX
   LIST-ITEMS
      "TODOS",
      "BANCO DO BRASIL",
      "BANCOOB",
      "AILOS"  INIT "TODOS" NO-UNDO.

DEF        VAR aux_cdbcoenv AS CHAR    INIT "0"                      NO-UNDO.
DEF        VAR aux_dsbcoenv AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrdahora AS INT                                   NO-UNDO.
DEF        VAR aux_cdsituac AS INT                                   NO-UNDO.
DEF        VAR aux_qtarquiv AS INT                                   NO-UNDO.
DEF        VAR aux_qttitarq AS INT                                   NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR   FORMAT "!"                     NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nrseqarq AS INT                                   NO-UNDO.
DEF        VAR aux_vltotarq AS DECI                                  NO-UNDO.
DEF        VAR aux_flgenvio AS LOG                                   NO-UNDO.
DEF        VAR aux_cdagenci AS INT                                   NO-UNDO.

DEF        VAR aux_qttitcxa AS INT                                   NO-UNDO.
DEF        VAR aux_qttitprg AS INT                                   NO-UNDO.
DEF        VAR aux_vltitcxa AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vltitprg AS DECIMAL                               NO-UNDO.
DEF        VAR aux_cdagefim LIKE craptvl.cdagenci                    NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


DEF    TEMP-TABLE crattem                                            NO-UNDO
         FIELD cdseqarq AS INTEGER
         FIELD nrdolote AS INTEGER
         FIELD cddbanco AS INTEGER
         FIELD nrrectit AS RECID
         INDEX crattem1 cdseqarq nrdolote.

DEFINE TEMP-TABLE tt-titulos                                            NO-UNDO
         FIELD qttitrec       AS INT
         FIELD vltitrec       AS DEC
         FIELD qttitrgt       AS INT
         FIELD vltitrgt       AS DEC
         FIELD qttiterr       AS INT
         FIELD vltiterr       AS DEC
         FIELD qttitprg       AS INT
         FIELD vltitprg       AS DEC
         FIELD qttitcxa       AS INT
         FIELD vltitcxa       AS DEC
         FIELD qttitulo       AS INT
         FIELD vltitulo       AS DEC.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 2 LABEL "Opcao" AUTO-RETURN
               HELP "Informe a opcao desejada (A, B, C, E, M, R, V, X  ou T)."
               VALIDATE(CAN-DO("A,B,C,E,M,R,V,X,T",glb_cddopcao),
                               "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_titulo.

FORM tel_dtmvtopg AT 1 LABEL "Referencia" 
                       HELP "Entre com a data de referencia do movimento."
     tel_cdagenci      LABEL "          PA"
                 HELP "Entre com o numero do PA ou 0 para todos os PA's."
                 VALIDATE (CAN-FIND (crapage WHERE 
                                     crapage.cdcooper = glb_cdcooper  AND
                                     crapage.cdagenci = tel_cdagenci) OR
                                     tel_cdagenci = 0
                                     ,"962 - PA nao cadastrado.")
     WITH ROW 6 COLUMN 29 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.

FORM tel_dtmvtopg AT 1 LABEL "  Referencia" 
                       HELP "Entre com a data de referencia do movimento."
     tel_cdagenci      LABEL "  PA  "
                 HELP "Entre com o numero do PA ou 0 para todos os PA's."
     tel_flgenvio      LABEL " Opcao"
                 HELP "Informe 'N' para nao enviados ou 'E' para enviados."           SKIP(1)            
     tel_cdbcoenv AT 7 LABEL " Banco" 
                 HELP "Entre com o banco para gerar o arquivo compensacao"
     SKIP
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere_v.

FORM tel_dtmvtopg AT 1 LABEL "  Referencia" 
                       HELP "Entre com a data de referencia do movimento."
     tel_cdagenci      LABEL "  PA  "
                 HELP "Entre com o numero do PA ou 0 para todos os PA's."
     tel_nrdcaixa      LABEL " Caixa"
                 HELP "Entre com o numero do caixa ou 0 para todos os caixas."
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere_d.


FORM tel_cdagenci      LABEL "  PA  "
                 HELP "Entre com o numero do PA "
     tel_cddsenha BLANK LABEL "         Senha"
                 HELP "Entre com a senha do PA "
     SKIP(3)
     tel_nrdhhini AT  1 LABEL "Limite para digitacao dos titulos" 
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

FORM "Qtd.               Valor" AT 36 
     SKIP(1)
     tel_qttitrec AT 13 FORMAT "zzz,zz9" LABEL "Titulos Recebidos"
     tel_vltitrec AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     tel_qttitrgt AT 12 FORMAT "zzz,zz9-" LABEL "Titulos Resgatados"
     tel_vltitrgt AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
     SKIP
     tel_qttiterr AT 09 FORMAT "zzz,zz9-" LABEL "Titulos com Problemas"
     tel_vltiterr AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
     SKIP(1)
     tel_qttitprg AT 02 FORMAT "zzz,zz9-" LABEL "Total de Titulos Programados"
     tel_vltitprg AT 46 FORMAT "zzz,zzz,zz9.99-" NO-LABEL
     SKIP
     tel_qttitcxa AT 02 FORMAT "zzz,zz9" LABEL "Titulos Arrecadados no Caixa"
     tel_vltitcxa AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     tel_qttitulo AT 06 FORMAT "zzz,zz9" LABEL "Total dos Titulos do Dia"
     tel_vltitulo AT 46 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     WITH ROW 10 COLUMN 10 NO-BOX OVERLAY SIDE-LABELS FRAME f_total.

FORM tel_dtmvtopg AT 1 LABEL "Listar os lotes do dia"
                       HELP "Entre com a data de referencia do movimento."
     tel_cdagenci      LABEL "    PA"
                 HELP "Entre com o numero do PA ou 0 para todos os PA's."
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_movto.

FORM tel_dtmvtopg AT 1 LABEL "Data"
                       HELP "Entre com a data de referencia do movimento."
     tel_cdagenci      LABEL "  PA"
                 HELP "Entre com o numero do PA ou 0 para todos os PA's."
     tel_flgenvio      LABEL "Opcao"
                 HELP "Informe 'N' para nao enviados ou 'E' para enviados."
     tel_tprelati      LABEL "Relat"
                 HELP "Selecione Relatorio (Normal/Conferencia Tit. Internet)"
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_movto_rel.

FORM b_agencia AT 18 
     HELP "Use SETAS p/Navegar e <F4> p/Sair. Pressione <ENTER> p/Excluir!" 
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_agencia.

FORM aux_confirma    AT 1 LABEL "Iniciar Nova Selecao?     " 
                     HELP "Entre com a opcao S/N."
     WITH ROW 12 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_regera.

FORM "(A) - Alterar horario da transmissao de titulos" SKIP
     "(B) - Gerar arquivos"                            SKIP
     "(C) - Consultar"                                 SKIP
     "(E) - Desconsiderar PA's"                        SKIP
     "(M) - Impressao de Lotes"                        SKIP
     "(R) - Relatorio"                                 SKIP
     "(V) - Visualizar os lotes"                       SKIP
     "(X) - Reativar registros"                        SKIP
     "(T) - Tratar arquivo de retorno (Em desenvolvimento)" SKIP
     WITH SIZE 54 BY 11 CENTERED OVERLAY ROW 8 
     TITLE "Escolha uma das opcoes abaixo:" FRAME f_helpopcao.

ON VALUE-CHANGED, ENTRY OF b_agencia
   DO:
       IF  AVAIL crawage THEN
           aux_posregis = RECID(crawage).
   END.

ON RETURN OF b_agencia
   DO:
       IF  AVAIL crawage THEN
           aux_posregis = RECID(crawage).

       IF   glb_cddopcao = "E"   THEN
            DO:
                aux_confirma = "N".
                MESSAGE COLOR NORMAL "Deseja realmente excluir este PA ?"
                        UPDATE aux_confirma.
                                        
                IF   CAPS(aux_confirma) = "S"   THEN
                     DO:
                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE COLOR NORMAL "Aguarde! Excluindo Registro...".
                         
                         FIND crawage WHERE RECID(crawage) = aux_posregis
                                            NO-ERROR.
                         IF  AVAIL crawage THEN
                             DELETE crawage.
                     END.
               
                OPEN QUERY q_agencia FOR EACH crawage BY crawage.cdagenci.
     
                HIDE MESSAGE NO-PAUSE.
                MESSAGE "Pressione <ENTER> p/Excluir!".                    
            END.
   END.

ON RETURN OF tel_cdbcoenv DO:

   IF   SUBSTRING(tel_cdbcoenv:SCREEN-VALUE,1,8) = "BANCO DO" THEN
        ASSIGN aux_cdbcoenv = "1"
               aux_dsbcoenv = "BANCO DO BRASIL".
   ELSE
   IF   SUBSTRING(tel_cdbcoenv:SCREEN-VALUE,1,7) = "BANCOOB" THEN
        ASSIGN aux_cdbcoenv = "756"
               aux_dsbcoenv = "BANCOOB".
   ELSE
   IF   SUBSTRING(tel_cdbcoenv:SCREEN-VALUE,1,6) = "AILOS" THEN
        ASSIGN aux_cdbcoenv = STRING(crapcop.cdbcoctl)
               aux_dsbcoenv = "AILOS".
   ELSE DO:
          IF aux_flgenvio THEN /* Enviados */

        /*OBS: Temporariamente foi incluido o 0 no cdbcoenv pois
           só o campo da tabela so sera alimentado com 1,756,85
           quando for liberado a compe. Apos isso, remover o 0 */
         ASSIGN aux_cdbcoenv = "0,1,756," + STRING(crapcop.cdbcoctl).
      ELSE                /* Nao Enviados */
         ASSIGN aux_cdbcoenv = "0".
   END.

   APPLY "GO".
END.

/*---Opcao para Listar Titulos nao Processados ---*/
DEF QUERY q_titulos FOR craptit
                  FIELDS(cdagenci cdbccxlt nrdolote vltitulo 
                         intitcop vldpagto),
                      crapope
                  FIELDS(nmoperad).    
                                     
DEF BROWSE b_titulos QUERY q_titulos 
    DISP craptit.cdagenci COLUMN-LABEL "PA"
         craptit.cdbccxlt COLUMN-LABEL "Banco/Caixa"
         crapope.nmoperad COLUMN-LABEL "Operador"   FORMAT "x(20)"
         craptit.nrdolote COLUMN-LABEL "Lote"
         craptit.vldpagto COLUMN-LABEL "Vlr.Pago  " FORMAT "zzz,zz9.99"
         WITH 7 DOWN.

DEF FRAME f_titulos  
          SKIP(1)
          b_titulos   HELP  "Pressione <F4> ou <END> p/finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 9.

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
IF  NOT AVAIL crawage THEN
    DO:
        FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:
            CREATE crawage.
            ASSIGN crawage.cdagenci = crapage.cdagenci
                   crawage.nmresage = crapage.nmresage
                   crawage.cdbantit = crapage.cdbantit
                   crawage.cdcomchq = crapage.cdcomchq.
        END. 
    END.      

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtmvtopg = glb_dtmvtolt.

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
           END.

      RUN proc_limpa.
      VIEW FRAME f_helpopcao.
      PAUSE(0).

      UPDATE glb_cddopcao  WITH FRAME f_titulo.

      HIDE FRAME f_helpopcao NO-PAUSE.    
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "TITULO"  THEN
                 DO:
                     HIDE FRAME f_titulo.
                     HIDE FRAME f_total.
                     HIDE FRAME f_fechamento.
                     HIDE FRAME f_refere.
                     HIDE FRAME f_refere_v.
                     HIDE FRAME f_refere_d.
                     HIDE FRAME f_moldura.
                     
                     HIDE FRAME f_agencia.
                     HIDE FRAME f_regera.
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
   
   IF  glb_cddopcao = "A" THEN
        DO:
            HIDE FRAME f_refere.
            HIDE FRAME f_refere_v.
            HIDE FRAME f_total.
            HIDE FRAME f_agencia.
            HIDE FRAME f_regera.
            
            UPDATE tel_cdagenci tel_cddsenha WITH FRAME f_fechamento.
                        
            FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                               crapage.cdagenci = tel_cdagenci NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapage THEN
                DO:
                  glb_cdcritic = 962. /* PA nao cadastrado */
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
                                     craptab.cdacesso = "HRTRTITULO"  AND
                                     craptab.tpregist = tel_cdagenci
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE craptab   THEN
                       IF   LOCKED craptab   THEN
                            DO:
                              
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.

                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                             INPUT "banco",
                                                             INPUT "craptab",
                                                             OUTPUT par_loginusr,
                                                             OUTPUT par_nmusuari,
                                                             OUTPUT par_dsdevice,
                                                             OUTPUT par_dtconnec,
                                                             OUTPUT par_numipusr).
                        
                                DELETE PROCEDURE h-b1wgen9999.
                        
                                ASSIGN aux_dadosusr = 
                                     "077 - Tabela sendo alterada p/ outro terminal.".
                        
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    MESSAGE aux_dadosusr.
                                    PAUSE 3 NO-MESSAGE.
                                    LEAVE.
                                END.
                        
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                                      " - " + par_nmusuari + ".".
                        
                                HIDE MESSAGE NO-PAUSE.
                        
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    MESSAGE aux_dadosusr.
                                    PAUSE 5 NO-MESSAGE.
                                    LEAVE.
                                END.
                        
                                glb_cdcritic = 0.
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
                      tel_situacao = IF  aux_cdsituac = 0 THEN
                                         TRUE
                                     ELSE
                                         FALSE
                      tel_nrdhhini = INT(SUBSTR(STRING(aux_nrdahora,
                                                       "HH:MM:SS"),1,2))
                      tel_nrdmmini = INT(SUBSTR(STRING(aux_nrdahora,
                                                       "HH:MM:SS"),4,2)).

               DISPLAY tel_situacao WITH FRAME f_fechamento.
               
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.
                       
                  IF   tel_cdagenci = 90   OR
                       tel_cdagenci = 91   THEN   
                       UPDATE tel_situacao WITH FRAME f_fechamento.     
                  ELSE
                       DO:
                           IF   glb_cddepart = 20   OR   /* "TI"                   */
                                glb_cddepart = 18   OR   /* "SUPORTE"              */
                                glb_cddepart = 8    OR   /* "COORD.ADM/FINANCEIRO" */
                                glb_cddepart = 4  THEN   /* "COMPE"                */
                                UPDATE tel_nrdhhini tel_nrdmmini tel_situacao
                                       WITH FRAME f_fechamento.
                           ELSE
                                UPDATE tel_nrdhhini tel_nrdmmini
                                       WITH FRAME f_fechamento.
                       END.

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

                  IF   tel_nrdhhini = 22 AND tel_nrdmmini > 0 THEN
                       DO:
                           glb_cdcritic = 687.
                           NEXT.
                       END.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  aux_confirma = "N".

                  glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  glb_cdcritic = 0.
                  LEAVE.

               END.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S" THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        RUN proc_limpa.
                        NEXT.
                    END.

               ASSIGN aux_nrdahora = (tel_nrdhhini * 3600) + (tel_nrdmmini * 60)
                      
                      aux_cdsituac = IF  tel_situacao  THEN  0  ELSE  1
                      
                      craptab.dstextab = STRING(aux_cdsituac,"9") + " " + 
                                         STRING(aux_nrdahora,"99999") + " " +
                                         SUBSTR(craptab.dstextab,9).

                      glb_cdcritic = 0.

            END. /* Fim da transacao */

            RELEASE craptab.

            CLEAR FRAME f_fechamento NO-PAUSE.
        END.
   ELSE
   IF   glb_cddopcao = "V"   THEN
        DO:
           HIDE FRAME f_refere.
           HIDE FRAME f_total.
           HIDE FRAME f_agencia.
           HIDE FRAME f_regera.
  
           UPDATE tel_dtmvtopg tel_cdagenci tel_flgenvio WITH FRAME f_refere_v.

           ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                                 THEN 9999
                                 ELSE tel_cdagenci.

           OPEN QUERY q_titulos 
           
           FOR EACH craptit WHERE craptit.cdcooper = glb_cdcooper         AND
                                  craptit.dtdpagto = tel_dtmvtopg         AND
                                  CAN-DO("2,4",STRING(craptit.insittit))  AND
                                  craptit.tpdocmto = 20                   AND
                                  craptit.cdagenci >= tel_cdagenci        AND
                                  craptit.cdagenci <= aux_cdagefim        AND
                                  craptit.flgenvio  = tel_flgenvio        AND
                                  craptit.intitcop  = 0
                                  NO-LOCK,
              FIRST crapope WHERE crapope.cdcooper = glb_cdcooper         AND
                                  crapope.cdoperad = craptit.cdoperad 
                                  NO-LOCK BY craptit.cdagenci
                                             BY craptit.nrdolote
                                                BY craptit.vldpagto.
                    
               ENABLE b_titulos WITH FRAME f_titulos.
              
               WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                         
               HIDE FRAME f_titulos.
             
               HIDE MESSAGE NO-PAUSE.
           END.
   ELSE              
   IF   glb_cddopcao = "C"   THEN
        DO:
            HIDE FRAME f_fechamento.
            HIDE FRAME f_agencia.
            HIDE FRAME f_refere_v.
            HIDE FRAME f_regera.
            
            ASSIGN tel_cdagenci = 0
                   aux_cdsituac = 0
                   tel_flgenvio = TRUE.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               UPDATE tel_dtmvtopg   tel_cdagenci   tel_flgenvio
                      WITH FRAME f_refere_v.
              
               ASSIGN aux_flgenvio = tel_flgenvio.

               IF  tel_flgenvio  THEN
                   DO  WHILE TRUE:
                        UPDATE tel_cdbcoenv WITH FRAME f_refere_v.
                        LEAVE.
                    END.
               ELSE
                    ASSIGN aux_cdbcoenv = "0".
               
               RUN proc_titulos.
               
               IF   tel_cdagenci = 90   THEN
                    DO:
                        glb_cdcritic = 0.
                        
                        RUN proc_verifica_pac_internet.
                        
                        IF   glb_cdcritic <> 0   THEN
                             NEXT.
                    END.

               aux_confirma = "N".
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                         
                  IF   tel_qttitulo = 0   THEN
                       LEAVE.
               
                  MESSAGE COLOR NORMAL
                          "Deseja listar os LOTES referentes a pesquisa(S/N)?:"
                          UPDATE aux_confirma.
     
                  LEAVE.
                         
               END. /* fim do DO WHILE */
                            
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S"                  THEN .
               ELSE
                   RUN fontes/titulo_r.p (INPUT tel_dtmvtopg, 
                                          INPUT tel_cdagenci,
                                          INPUT 0,
                                          INPUT 0, 
                                          INPUT FALSE,
                                          INPUT TABLE crawage,
                                          INPUT tel_flgenvio,
                                          INPUT tel_flgenvio).

            END. /*  Fim do DO WHILE TRUE  */
       END.
   ELSE
   IF   glb_cddopcao = "X"   THEN     /* Volta Sit.Enviados p/Nao enviados */
        DO:
           HIDE FRAME f_refere.
           HIDE FRAME f_refere_v.
           HIDE FRAME f_total.
           HIDE FRAME f_agencia.
           HIDE FRAME f_regera.
  
           UPDATE tel_dtmvtopg   tel_cdagenci    WITH FRAME f_refere.

           ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                                 THEN 9999
                                 ELSE tel_cdagenci.

           OPEN QUERY q_titulos 
                FOR EACH craptit WHERE 
                         craptit.cdcooper = glb_cdcooper        AND
                         craptit.dtdpagto = tel_dtmvtopg        AND
                         CAN-DO("2,4",STRING(craptit.insittit)) AND
                         craptit.tpdocmto = 20                  AND
                         craptit.cdagenci >= tel_cdagenci       AND
                         craptit.cdagenci <= aux_cdagefim       AND
                         craptit.intitcop  = 0                  AND
                         craptit.flgenvio  = YES                NO-LOCK,
                   FIRST crapope WHERE
                         crapope.cdcooper = glb_cdcooper        AND
                         crapope.cdoperad = craptit.cdoperad    NO-LOCK 
                         BY craptit.cdagenci
                            BY craptit.nrdolote
                               BY craptit.vldpagto.
                         
           ENABLE b_titulos WITH FRAME f_titulos.
           
           WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                         
           HIDE FRAME f_titulos.
              
           HIDE MESSAGE NO-PAUSE.
               
           DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

               aux_confirma = "N".

               glb_cdcritic = 78.
               
               RUN fontes/critic.p.
               BELL.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               glb_cdcritic = 0.
               LEAVE.

           END.

           IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
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

           RUN atualiza_titulos_regerar.
   
           MESSAGE "Movtos atualizados         ".
           MESSAGE "                           ".
        END.
   ELSE              
   IF   glb_cddopcao = "E"   THEN      /*  ELiminar Agencias Processamento */
        DO:
           HIDE FRAME f_total      NO-PAUSE.
           HIDE FRAME f_fechamento NO-PAUSE.
           HIDE FRAME f_refere     NO-PAUSE.
           HIDE FRAME f_refere_v   NO-PAUSE.
           HIDE FRAME f_movo       NO-PAUSE.
           
           HIDE FRAME f_agencia    NO-PAUSE.
           HIDE FRAME f_regera     NO-PAUSE.
           RUN  p_regera_agencia.

           OPEN QUERY q_agencia FOR EACH crawage BY crawage.cdagenci.
  
           ENABLE b_agencia  WITH FRAME  f_agencia.
           SET b_agencia WITH FRAME f_agencia.
       END.     
 
   ELSE

   IF   glb_cddopcao = "B"   THEN           /*  Gera arquivos para BANCO BB  */
        DO:
            HIDE FRAME f_refere.
            HIDE FRAME f_refere_v.
            HIDE FRAME f_fechamento.
            HIDE FRAME f_total.

            HIDE FRAME f_agencia.
            HIDE FRAME f_regera.
            
            ASSIGN tel_dtmvtopg = glb_dtmvtolt
                   tel_cdagenci = 0.

            DISPLAY tel_dtmvtopg tel_cdagenci WITH FRAME f_movto.

            UPDATE tel_dtmvtopg tel_cdagenci WITH FRAME f_movto.

            /*  Nao deixar gerar arquivo no dia 31/12 - NAO TEM COMPE  */
            IF   NOT (tel_cdagenci    = 90) AND
                 NOT (tel_cdagenci    = 91) AND   
                 MONTH(tel_dtmvtopg) = 12   AND
                 DAY(tel_dtmvtopg)   = 31   THEN
                 DO:
                     glb_cdcritic = 13.
                     NEXT.
                 END.

            ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                                  THEN 9999
                                  ELSE tel_cdagenci.
                     
            ASSIGN aux_cdsituac = 0
                   aux_cdagenci = 0
                   glb_cdcritic = 0.
            
                    
            FOR EACH crapage WHERE crapage.cdcooper  = glb_cdcooper    AND
                                (((crapage.cdagenci >= tel_cdagenci    AND
                                   crapage.cdagenci <= aux_cdagefim)   AND
                                   crapage.cdagenci <> 90              AND
                                   crapage.cdagenci <> 91)      OR
                                  (crapage.cdagenci  = 90              AND
                                   tel_cdagenci      = 90)      OR
                                  (crapage.cdagenci  = 91              AND
                                   tel_cdagenci      = 91))            NO-LOCK, 
                EACH crawage WHERE crawage.cdagenci  = crapage.cdagenci AND
                                   crawage.cdbantit <> crapcop.cdbcoctl
                                   NO-LOCK:
            
                /* Verifica se agendamentos foram efetivados */
                FIND FIRST craplau WHERE craplau.cdcooper = glb_cdcooper     AND
                                         craplau.dsorigem = "INTERNET"       AND
                                         craplau.cdagenci = tel_cdagenci     AND
                                         craplau.cdbccxlt = 100              AND
                                         craplau.nrdolote = 11900            AND
                                         craplau.dtmvtopg = tel_dtmvtopg     AND
                                         craplau.cdtiptra = 2 /* PAGTO    */ AND
                                         craplau.insitlau = 1 /* PENDENTE */ 
                                         USE-INDEX craplau5 NO-LOCK NO-ERROR.

                IF   AVAILABLE craplau  THEN
                     DO:
                         ASSIGN aux_cdagenci = crapage.cdagenci
                                glb_cdcritic = 920.
                         NEXT.
                     END.    
                 
                FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                   craptab.nmsistem = "CRED"           AND
                                   craptab.tptabela = "GENERI"         AND
                                   craptab.cdempres = 00               AND
                                   craptab.cdacesso = "HRTRTITULO"     AND
                                   craptab.tpregist = crapage.cdagenci
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE craptab   THEN
                     DO:
                         ASSIGN aux_cdagenci = crapage.cdagenci.
                                glb_cdcritic = 55.
                         NEXT.
                     END.

                ASSIGN aux_nrdahora = INT(SUBSTR(craptab.dstextab,03,05)).
                
                FIND FIRST craptit WHERE
                           craptit.cdcooper = glb_cdcooper        AND
                           craptit.dtdpagto = tel_dtmvtopg        AND          
                           craptit.cdagenci = crapage.cdagenci    AND
                           CAN-DO("2,4",STRING(craptit.insittit)) AND
                           craptit.intitcop = 0 AND
                           craptit.tpdocmto = 20
                           NO-LOCK NO-ERROR.         

                IF  aux_cdsituac = 0 THEN 
                    DO:
                       IF  AVAIL craptit THEN
                           ASSIGN aux_cdsituac = INT(SUBSTR(craptab.dstextab,
                                                            1,1)).
                    END.
                                                                 
            END.  /* For each crapage */
            
            ASSIGN aux_flgenvio  = NO.
            
            RUN proc_titulos.

            IF  glb_cdcritic <> 0 THEN
                DO:
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   MESSAGE "PA = "  aux_cdagenci.                 
                   ASSIGN glb_cdcritic = 0.

                   PAUSE 3 NO-MESSAGE.
                   
                   NEXT.
                END.

            IF   tel_cdagenci = 90   THEN
                 DO:
                     glb_cdcritic = 0.
                       
                     RUN proc_verifica_pac_internet.
                        
                     IF   glb_cdcritic <> 0   THEN
                          NEXT.
                 END.

            ASSIGN aux_confirma = "S".
            IF  aux_cdsituac <> 0   THEN
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
                 aux_confirma <> "S" THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     RUN proc_limpa.
                     NEXT.
                 END.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               aux_confirma = "N".
               glb_cdcritic = 78.
               RUN fontes/critic.p.
               BELL.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               glb_cdcritic = 0.
               LEAVE.
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S" THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     RUN proc_limpa.
                     NEXT.
                 END.

            /*--- Controle de 1 operador utilizando tela --*/  
            DO TRANSACTION:
               FIND  craptab WHERE
                     craptab.cdcooper = glb_cdcooper      AND       
                     craptab.nmsistem = "CRED"            AND
                     craptab.tptabela = "GENERI"          AND
                     craptab.cdempres = glb_cdcooper      AND         
                     craptab.cdacesso = "TITULO"          AND
                     craptab.tpregist = 1                 NO-LOCK NO-ERROR.
           
               IF  NOT AVAIL craptab THEN 
                   DO:
                       CREATE craptab.
                       ASSIGN craptab.nmsistem = "CRED"      
                              craptab.tptabela = "GENERI"          
                              craptab.cdempres = glb_cdcooper            
                              craptab.cdacesso = "TITULO"                
                              craptab.tpregist = 1  
                              craptab.cdcooper = glb_cdcooper.       
                       RELEASE craptab.    
                   END.
            END. /* Fim da Transacao */
            
            FIND FIRST crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                                     NO-LOCK NO-ERROR.
                       
            IF  NOT AVAIL crapcop  THEN 
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
                                   craptab.cdacesso = "TITULO"          AND
                                   craptab.tpregist = 1  
                                   NO-LOCK NO-ERROR.
                                   
                IF  NOT AVAIL craptab THEN 
                    DO:
                       MESSAGE 
                       "Controle nao cad.(Avise Inform) Processo Cancelado!".
                       PAUSE MESSAGE
                       "Tecle <entra> para voltar `a tela de identificacao!".
                       BELL.
                       LEAVE.
                    END.

                IF  craptab.dstextab <> " "  THEN
                    DO:
                        MESSAGE "Processo sendo utilizado pelo Operador " +
                                TRIM(SUBSTR(craptab.dstextab,1,20)).
                      
                        PAUSE MESSAGE
                               "Peca liberacao Coordenador ou Aguarde......".
                    
                        RUN fontes/pedesenha.p (INPUT glb_cdcooper,  
                                                INPUT 2, 
                                                OUTPUT aut_flgsenha,
                                                OUTPUT aut_cdoperad).
                        IF   aut_flgsenha    THEN
                             LEAVE.
                        NEXT.
                    END.

                LEAVE.
            END.
            
            DO TRANSACTION:
               FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                                  craptab.nmsistem = "CRED"             AND
                                  craptab.tptabela = "GENERI"           AND
                                  craptab.cdempres = crapcop.cdcooper   AND
                                  craptab.cdacesso = "TITULO"           AND
                                  craptab.tpregist = 1
                                  EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                                  
               IF  AVAIL craptab THEN     
                   DO:
                      ASSIGN craptab.dstextab = glb_cdoperad.
                      RELEASE craptab.
                   END.
            END. /* DO TRANSACTION */  
                      
            /*  Verifica se os lotes estao fechados  */
            HIDE MESSAGE NO-PAUSE.
   
            MESSAGE "Verificando os lotes do dia (arrecadacao de caixa)...".

            ASSIGN aux_cdagefim = IF   tel_cdagenci = 0  THEN 
                                       9999
                                  ELSE tel_cdagenci.

            FOR EACH craplot WHERE craplot.cdcooper  = glb_cdcooper    AND
                                   craplot.dtmvtolt  = tel_dtmvtopg    AND
                                   craplot.dtmvtopg  = ?               AND
                                   craplot.tplotmov  = 20              AND
                                (((craplot.cdagenci >= tel_cdagenci    AND
                                   craplot.cdagenci <= aux_cdagefim)   AND
                                   craplot.cdagenci <> 90              AND
                                   craplot.cdagenci <> 91)      OR
                                  (craplot.cdagenci  = 90              AND
                                   tel_cdagenci      = 90)      OR
                                  (craplot.cdagenci  = 91              AND
                                   tel_cdagenci      = 91))            NO-LOCK,
                EACH crawage WHERE crawage.cdagenci  = craplot.cdagenci AND
                                   crawage.cdagenci <> crapcop.cdbcoctl NO-LOCK:
                          
                IF   craplot.qtinfoln <> craplot.qtcompln   OR
                     craplot.vlinfocr <> craplot.vlcompcr   THEN
                     DO:
                         MESSAGE "Lote nao batido:" 
                                 STRING(craplot.cdagenci,"999") + "-" +
                                 STRING(craplot.cdbccxlt,"999") + "-" +
                                 STRING(craplot.nrdolote,"999999").

                         glb_cdcritic = 139.
                         NEXT.
                     END.
                          
            END.  /*  Fim do FOR EACH  */

            IF   glb_cdcritic > 0   THEN
                 NEXT.
  
            MESSAGE "Lote(s) do dia fechado(s)! Gerando arquivo(s)...".

            ASSIGN aux_qtarquiv = 0
                   aux_qttitarq = 0.
            
            RUN proc_gera_arquivo_bbrasil.
            RUN proc_gera_arquivo_bancoob.
            
            IF   glb_cdcritic > 0   THEN
                 DO:
                    RUN atualiza_controle_operador.
                    NEXT.
                 END.
      
            DO ON STOP UNDO, LEAVE:
               RUN fontes/titulo_r.p (INPUT tel_dtmvtopg,
                                      INPUT tel_cdagenci,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT TRUE,
                                      INPUT TABLE crawage,
                                      INPUT NO,
                                      INPUT NO).
            END.

            RUN atualiza_titulos.
            
            PAUSE 2 NO-MESSAGE.
            
            HIDE MESSAGE NO-PAUSE.

            MESSAGE "Movtos atualizados         ".

            RUN atualiza_controle_operador.
            
            MESSAGE "Foi(ram) gravado(s)" aux_qtarquiv "arquivo(s)"
                    "-" aux_qttitarq "titulo(s)".
    
            MESSAGE "Transmita-o(s) via INTRANET.".
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN                              /*  Relatorio  */
        DO:
            HIDE FRAME f_refere.
            HIDE FRAME f_refere_v.
            HIDE FRAME f_fechamento.
            HIDE FRAME f_total.

            HIDE FRAME f_agencia.
            HIDE FRAME f_regera.
            HIDE FRAME f_movto.
            HIDE FRAME f_movto_rel.
            
            ASSIGN tel_dtmvtopg = glb_dtmvtolt
                   tel_cdagenci = 0
                   tel_tprelati = no.
        
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               UPDATE tel_dtmvtopg tel_cdagenci  tel_flgenvio
                      WITH FRAME f_movto_rel.

               DISPLAY tel_tprelati WITH FRAME f_movto_rel.


               /** Questiona: Imprimir CARTA ou RELATORIO ? **/
               aux_imprimcr = NO.  /* NO = Relatorio */
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  MESSAGE COLOR NORMAL
                          "Deseja imprimir Carta ou Relatorio (C/R)?:"
                          UPDATE aux_imprimcr.
                  LEAVE.

               END. /* fim do DO WHILE */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN DO:
                    RUN proc_limpa.
                    NEXT.
               END.

               ASSIGN tel_tprelati = NO.
               
               IF aux_imprimcr THEN DO:  /* Escolheu CARTA */
                   IF tel_cdagenci = 0 THEN DO:
                       MESSAGE "Para gerar CARTA deve-se selecionar um PA".
                       NEXT.
                   END.
                   RUN imprimir_carta_remessa.
               END.
               ELSE DO:  /* Escolheu RELATORIO */
                   /* Para PA 90 - Intenet, solicitar tipo relatorio */
                   IF tel_cdagenci = 90 OR
                      tel_cdagenci = 91 THEN
                      UPDATE tel_tprelati 
                              WITH FRAME f_movto_rel.
                   ELSE
                      ASSIGN tel_tprelati = NO.

                   IF   NOT tel_tprelati THEN
                        /* relatorio normal de titulo */
                        DO ON STOP UNDO, LEAVE:
                           RUN fontes/titulo_r.p(INPUT tel_dtmvtopg, 
                                                 INPUT tel_cdagenci, 
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT FALSE,
                                                 INPUT TABLE crawage,
                                                 INPUT tel_flgenvio, 
                                                 INPUT tel_flgenvio).
                        END.                          
                   ELSE
                   DO:
                       IF  tel_cdagenci = 90  THEN
                       /* relato de conferencia titulos via Internet */
                       DO ON STOP UNDO, LEAVE: 
                          RUN fontes/titulo_r1.p(INPUT tel_dtmvtopg, 
                                                 INPUT tel_flgenvio). 
                       END.
                       ELSE
                       /* relato de conferencia titulos via TAA */
                       DO ON STOP UNDO, LEAVE: 
                          RUN fontes/titulo_r2.p(INPUT tel_dtmvtopg, 
                                                 INPUT tel_flgenvio). 
                       END.
                   END.

               END. /* Fim do ELSE DO - Relatorio */

            END.  /*  Fim do DO WHILE TRUE  */

            HIDE FRAME f_movto_rel.
        END.
   ELSE
   IF   glb_cddopcao = "M"   THEN                  /*  Impressao de Lotes  */
        DO:
            HIDE FRAME f_refere.
            HIDE FRAME f_refere_v.
            HIDE FRAME f_fechamento.
            HIDE FRAME f_total.
            HIDE FRAME f_agencia.
            HIDE FRAME f_regera.
            
            ASSIGN tel_dtmvtopg = glb_dtmvtolt
                   tel_cdagenci = 0
                   tel_nrdcaixa = 0.
        
            DO WHILE TRUE ON ENDKEY UNDO, RETURN:
            
               UPDATE tel_dtmvtopg  tel_cdagenci  tel_nrdcaixa 
                      WITH FRAME f_refere_d.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  aux_confirma = "N".
                  glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  glb_cdcritic = 0.
                  LEAVE.
               END. /* fim do DO WHILE */
                            
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S"                  THEN DO:
                    RUN proc_limpa.
                    NEXT.
               END.
               
               LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
            
            RUN imprimir_lotes.
         
            HIDE FRAME f_refere_v.
        END.
     
END.  /*  Fim do DO WHILE TRUE  */

/*  ........................................................................  */

PROCEDURE proc_gera_arquivo_bancoob:
             
   DEF VAR aux_nrdolote AS INTE                                     NO-UNDO.
   DEF VAR aux_nrseqdig AS INTE                                     NO-UNDO.
   DEF VAR aux_tpcaptur AS INTE                                     NO-UNDO.
   DEF VAR aux_tpdocmto AS CHAR                                     NO-UNDO.
   
   /* Remove os arquivos temporarios */
   UNIX SILENT VALUE("rm arq/ti*.CBE 2>/dev/null").

   ASSIGN aux_qttitcxa = 0
          aux_qttitprg = 0
          aux_vltitcxa = 0
          aux_vltitprg = 0.

   FOR EACH craptit WHERE craptit.cdcooper  = glb_cdcooper       AND
                          craptit.dtdpagto  = tel_dtmvtopg       AND
                          CAN-DO("2,4",STRING(craptit.insittit)) AND
                          craptit.tpdocmto  = 20                 AND
                       (((craptit.cdagenci >= tel_cdagenci       AND
                          craptit.cdagenci <= aux_cdagefim)      AND
                          craptit.cdagenci <> 90                 AND
                          craptit.cdagenci <> 91)     OR    
                         (craptit.cdagenci  = 90                 AND
                          tel_cdagenci      = 90)     OR
                         (craptit.cdagenci  = 91                 AND
                          tel_cdagenci      = 91))               AND
                          craptit.intitcop  = 0                  AND
                          craptit.flgenvio  = NO                 NO-lOCK,
       EACH crawage WHERE crawage.cdagenci  = craptit.cdagenci   AND
                          crawage.cdbantit  = 756 /*BANCOOB*/    NO-LOCK
                          BREAK BY craptit.cdagenci
                                BY craptit.cdbccxlt 
                                BY craptit.nrdolote: 
                              
       IF   FIRST-OF(craptit.cdagenci)  THEN
            DO:
                ASSIGN aux_vltotarq = 0 
                       aux_nrseqarq = 1
                       aux_qtarquiv = aux_qtarquiv + 1
                       aux_nmarquiv = "ti"                              +
                                      STRING(crapcop.cdagebcb,"9999")   + 
                                      STRING(MONTH(glb_dtmvtolt),"99")  +
                                      STRING(DAY(glb_dtmvtolt),"99")    + 
                                      STRING(craptit.cdagenci,"999")    +
                                      STRING(TIME,"99999")              +
                                      ".CBE".
                
                IF   SEARCH("arq/" + aux_nmarquiv) <> ?   THEN
                     DO:
                         BELL.
                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE "Arquivo ja existe: arq/" aux_nmarquiv.
                         glb_cdcritic = 459.
                         RETURN.
                     END.
               
                OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarquiv).
            
                PUT STREAM str_1
                    FILL("0",47)        FORMAT "x(47)" /* CONTROLE DO HEADER */
                    "CEL605"                           /* NOME   */
                    crawage.cdcomchq    FORMAT "999"   /* COMPE  */
                    "0001"                             /* VERSAO */
                    "756"                              /* BANCO  */
                    "0"                                /* DV     */
                    "3"                                /* Ind. Remes */
                    YEAR(glb_dtmvtolt)  FORMAT "9999"  /* DATA FORMATO */
                    MONTH(glb_dtmvtolt) FORMAT "99"    /* YYYYMMDD*/
                    DAY(glb_dtmvtolt)   FORMAT "99"
                    FILL(" ",77)        FORMAT "x(77)" /* FILLER */
                    aux_nrseqarq        FORMAT "9999999999"  /* SEQUENCIAL 1 */
                    SKIP.
            END.

       IF  FIRST-OF(craptit.nrdolote)  THEN
           ASSIGN aux_nrdolote = craptit.nrdolote
                  aux_nrseqdig = 1.
       
       ASSIGN aux_nrseqarq = aux_nrseqarq + 1
              aux_qttitarq = aux_qttitarq + 1
              aux_vltotarq = aux_vltotarq + craptit.vldpagto.
                     
       IF   craptit.insittit = 2   THEN           /*  Titulo programado  */
            ASSIGN aux_qttitprg = aux_qttitprg + 1
                   aux_vltitprg = aux_vltitprg + craptit.vldpagto.
       ELSE
            ASSIGN aux_qttitcxa = aux_qttitcxa + 1
                   aux_vltitcxa = aux_vltitcxa + craptit.vldpagto.
                   
       /* Tipo de captura */
       IF   craptit.cdagenci = 90   THEN /* PA INTERNET */
            aux_tpcaptur = 3. /* titulos liquidados via internet  */
       ELSE
       IF   craptit.cdagenci  = 91  THEN  /* PA TAA */ 
            aux_tpcaptur = 2. /* titulos liquidados via TAA */
       ELSE
            aux_tpcaptur = 1. /* titulos liquidados no caixa */
       
       /* Parametros do Bancoob - Utilizacao do campo TDs */ 
       IF   craptit.vldpagto >= 5000   THEN
            aux_tpdocmto = "044".
       ELSE
            aux_tpdocmto = "040".
            
       PUT STREAM str_1
           craptit.cdbandst       FORMAT "999"   /* BANCO DESTINO  */
           craptit.cddmoeda       FORMAT "9"     /* CODIGO MOEDA   */
           craptit.nrdvcdbr       FORMAT "9"     /* DIG. COD.BARRA */
           craptit.vltitulo * 100 FORMAT "99999999999999" /* VL TIT */  
           SUBSTR(craptit.dscodbar,20,25) format "x(25)"  /* LIVRE  */
           "  "   /* Constante igual a 20 - Pq nao está 20 ?*/
           crawage.cdcomchq       FORMAT "999"
           aux_tpcaptur           FORMAT "9"
           "99"
           " "
           "756"
           crapcop.cdagebcb       FORMAT "9999"
           aux_nrdolote           FORMAT "9999999" /* NUMERO LOTE */
           aux_nrseqdig           FORMAT "999"  /* SEQ NO LOTE */
           YEAR(glb_dtmvtolt)     FORMAT "9999" /* DATA FORMATO */
           MONTH(glb_dtmvtolt)    FORMAT "99"   /* YYYYMMDD*/
           DAY(glb_dtmvtolt)      FORMAT "99"
           "      "                          /* CENTRO PROCES */
           craptit.vldpagto * 100 FORMAT "999999999999" /* VL LIQ */
           FILL(" ",51)           FORMAT "x(51)"  /* FILLER */
           aux_tpdocmto           FORMAT "999"    /* BANCOOB */
           aux_nrseqarq           FORMAT "9999999999"
           SKIP.

       ASSIGN aux_nrseqdig = aux_nrseqdig + 1.

       IF  aux_nrseqdig > 999  THEN
           ASSIGN  /* aux_nrdolote = aux_nrdolote + 1*/
                  aux_nrseqdig = 1.

       IF   LAST-OF(craptit.cdagenci) THEN
            DO:
                aux_nrseqarq = aux_nrseqarq + 1.

                PUT STREAM str_1
                    FILL("9",47)            FORMAT "x(47)" /* HEADER */
                    "CEL605"                               /* NOME   */
                    crawage.cdcomchq        FORMAT "999"   /* COMPE  */
                    "0001"
                    "756"
                    "0"
                    "3"
                    YEAR(glb_dtmvtolt)      FORMAT "9999"   /* DATA FORMATO */
                    MONTH(glb_dtmvtolt)     FORMAT "99"    /* YYYYMMDD*/
                    DAY(glb_dtmvtolt)       FORMAT "99"
                    aux_vltotarq * 100      FORMAT "99999999999999999"
                    FILL(" ",60)            FORMAT "x(60)" /* FILLER */
                    aux_nrseqarq            FORMAT "9999999999"  /* SEQUENCIA */
                   SKIP. 
                OUTPUT STREAM str_1 CLOSE.

                /* Copia para o /micros */
                UNIX SILENT VALUE("ux2dos arq/" + aux_nmarquiv + 
                                  ' | tr -d "\032"' + 
                                  " > /micros/" + crapcop.dsdircop +
                                  "/bancoob/"   + aux_nmarquiv +
                                  " 2>/dev/null").
                                  
                /* move para o salvar */
                UNIX SILENT VALUE("mv arq/" + aux_nmarquiv + 
                                  " salvar 2>/dev/null").
            END.
   END.  /*  Fim do FOR EACH -- craptit  */

   IF   glb_cdcritic > 0   THEN
        RETURN.

   ASSIGN aux_cdagefim = IF   tel_cdagenci = 0  THEN 
                              9999
                         ELSE tel_cdagenci.
   
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:

       /* Atualiza se a compensacao foi rodada */
       FOR EACH crapage WHERE crapage.cdcooper  = glb_cdcooper      AND
                           (((crapage.cdagenci >= tel_cdagenci      AND
                              crapage.cdagenci <= aux_cdagefim)     AND
                              crapage.cdagenci <> 90                AND
                              crapage.cdagenci <> 91)     OR    
                             (crapage.cdagenci  = 90                AND
                              tel_cdagenci      = 90)     OR
                             (crapage.cdagenci  = 91                AND
                              tel_cdagenci      = 91))              NO-LOCK,
           EACH crawage WHERE crawage.cdagenci  = crapage.cdagenci  AND
                              crawage.cdbantit <> crapcop.cdbcoctl  NO-LOCK:   
            
           DO aux_contador = 1 TO 10:

              FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                                 craptab.nmsistem = "CRED"            AND
                                 craptab.tptabela = "GENERI"          AND
                                 craptab.cdempres = 00                AND
                                 craptab.cdacesso = "HRTRTITULO"      AND
                                 craptab.tpregist = crapage.cdagenci
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE craptab   THEN
                   IF   LOCKED craptab   THEN
                        DO:
                              RUN sistema/generico/procedures/b1wgen9999.p
                              PERSISTENT SET h-b1wgen9999.

                              RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                             INPUT "banco",
                                                             INPUT "craptab",
                                                             OUTPUT par_loginusr,
                                                             OUTPUT par_nmusuari,
                                                             OUTPUT par_dsdevice,
                                                             OUTPUT par_dtconnec,
                                                             OUTPUT par_numipusr).
                        
                              DELETE PROCEDURE h-b1wgen9999.
                        
                              ASSIGN aux_dadosusr = 
                                     "077 - Tabela sendo alterada p/ outro terminal.".
                        
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    MESSAGE aux_dadosusr.
                                    PAUSE 3 NO-MESSAGE.
                                    LEAVE.
                                END.
                        
                               ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                                      " - " + par_nmusuari + ".".
                        
                                HIDE MESSAGE NO-PAUSE.
                        
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    MESSAGE aux_dadosusr.
                                    PAUSE 5 NO-MESSAGE.
                                    LEAVE.
                                END.
                        
                                glb_cdcritic = 0.
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
               RETURN.

          ASSIGN aux_cdsituac = 1                     
                 aux_nrdahora = INT(SUBSTR(craptab.dstextab,3,5))

                 craptab.dstextab = STRING(aux_cdsituac,"9") + " " + 
                                    STRING(aux_nrdahora,"99999") + " " +
                                    SUBSTR(craptab.dstextab,9).
          RELEASE craptab.
       END.

       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " - Ref.: " + STRING(glb_dtmvtolt,"99/99/9999") +
                         " - Caixa: " + 
                         STRING(aux_qttitcxa,"zzz,zz9") +
                         " " + STRING(aux_vltitcxa,"zzz,zzz,zz9.99") +
                         " - Progr: " + STRING(aux_qttitprg,"zzz,zz9") +
                         " " + STRING(aux_vltitprg,"zzz,zzz,zz9.99") +
                         " >> log/titulos.log").

   END. /* TRANSACTION */

END PROCEDURE.

PROCEDURE proc_gera_arquivo_bbrasil:

   DEFINE VARIABLE aux_hrarquiv AS CHAR                                NO-UNDO.
   DEFINE VARIABLE aux_cddbanco AS INT                                 NO-UNDO.
   DEFINE VARIABLE aux_qtlinarq AS INT                                 NO-UNDO.
   
   DEFINE VARIABLE aux_vlrtotal AS DEC                                 NO-UNDO.
   DEFINE VARIABLE aux_nrconven AS CHAR                                NO-UNDO.
   DEFINE VARIABLE aux_totvltit AS DEC                                 NO-UNDO.
   DEFINE VARIABLE aux_cdseqarq AS INT                                 NO-UNDO.
   DEFINE VARIABLE aux_nrdolote AS INT                                 NO-UNDO.
   DEFINE VARIABLE aux_flgoutro AS LOGICAL                             NO-UNDO.
   DEFINE VARIABLE aux_dtmvtolt AS CHAR                                NO-UNDO.
   DEFINE VARIABLE aux_flgerror AS LOGICAL                             NO-UNDO.
   DEFINE VARIABLE aux_cdsequen AS INT                                 NO-UNDO.
   DEFINE VARIABLE aux_qttitlot AS INT                                 NO-UNDO.
   DEFINE VARIABLE aux_vltotlot AS DECIMAL                             NO-UNDO.
   DEFINE VARIABLE aux_dtvencim AS DATE                                NO-UNDO.
   DEFINE VARIABLE aux_vldmulta AS DECIMAL                             NO-UNDO.
   DEFINE VARIABLE aux_vldescon AS DECIMAL                             NO-UNDO.
   DEFINE VARIABLE aux_vltitulo AS DECIMAL                             NO-UNDO.
   
   EMPTY TEMP-TABLE crattem.
   
   PAUSE(0).  
   
   /* Remove os arquivos temporarios */
   UNIX SILENT VALUE("rm arq/ti*.rem 2>/dev/null").

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                      craptab.nmsistem = "CRED"        AND
                      craptab.tptabela = "CONFIG"      AND
                      craptab.cdempres = 00            AND
                      craptab.cdacesso = "COMPELBBTI"  AND
                      craptab.tpregist = 000           NO-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            glb_cdcritic = 55.
            RETURN.
        END.    
                            
   /*   Valor total na qual o arquivo pode agrupar  */

   ASSIGN aux_vlrtotal = DECIMAL(SUBSTR(craptab.dstextab,01,15))
          aux_nrconven = SUBSTR(craptab.dstextab,17,20)
          aux_cdsequen = INTEGER(SUBSTR(craptab.dstextab,38,06))
          aux_totvltit = 0
          aux_cdseqarq = 0.
    
   FOR EACH craptit WHERE craptit.cdcooper  = glb_cdcooper       AND
                          craptit.dtdpagto  = tel_dtmvtopg       AND
                          CAN-DO("2,4",STRING(craptit.insittit)) AND
                          craptit.tpdocmto  = 20                 AND
                       (((craptit.cdagenci >= tel_cdagenci       AND
                          craptit.cdagenci <= aux_cdagefim)      AND
                          craptit.cdagenci <> 90                 AND 
                          craptit.cdagenci <> 91)                OR
                         (craptit.cdagenci  = 90                 AND
                          tel_cdagenci      = 90)                OR
                         (craptit.cdagenci  = 91                 AND
                          tel_cdagenci      = 91))               AND
                          craptit.intitcop  = 0                  AND
                          craptit.flgenvio  = NO                 NO-LOCK,
       EACH crawage WHERE crawage.cdagenci  = craptit.cdagenci   AND
                          crawage.cdbantit  = 1 /* BB */         NO-LOCK
       BREAK BY craptit.cdagenci
             BY craptit.cdbandst:
       
       aux_totvltit = aux_totvltit + craptit.vldpagto.
       
       IF   FIRST-OF(craptit.cdagenci) THEN
            ASSIGN aux_cdseqarq = aux_cdseqarq + 1
                   aux_nrdolote = 0
                   aux_flgoutro = TRUE.

       IF   FIRST-OF(craptit.cdbandst) THEN
            DO:
                 IF   craptit.cdbandst = 1 THEN
                      ASSIGN aux_totvltit = craptit.vldpagto
                             aux_nrdolote = 1.
                 ELSE
                      IF   aux_flgoutro THEN
                           ASSIGN aux_nrdolote = aux_nrdolote + 1
                                  aux_totvltit = craptit.vldpagto
                                  aux_flgoutro = FALSE.
                      ELSE
                           IF  (aux_totvltit > aux_vlrtotal) THEN
                               ASSIGN aux_nrdolote = 1
                                      aux_cdseqarq = aux_cdseqarq + 1
                                      aux_totvltit = craptit.vldpagto.
            END.
       ELSE 
            IF  (aux_totvltit > aux_vlrtotal) THEN
                ASSIGN aux_nrdolote = 1
                       aux_cdseqarq = aux_cdseqarq + 1
                       aux_totvltit = craptit.vldpagto.
   
       CREATE crattem.
       ASSIGN crattem.cdseqarq = aux_cdseqarq
              crattem.nrdolote = aux_nrdolote
              crattem.cddbanco = IF   craptit.cdbandst <> 1 THEN
                                      999
                                 ELSE 1
              crattem.nrrectit = RECID(craptit).
   END. 
       
   ASSIGN aux_dtmvtolt = STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(YEAR(glb_dtmvtolt),"9999")
          aux_flgerror = FALSE
          aux_qttitcxa = 0
          aux_qttitprg = 0
          aux_vltitcxa = 0
          aux_vltitprg = 0.
                                     

   FOR EACH crattem USE-INDEX crattem1 NO-LOCK 
                    BREAK BY crattem.cdseqarq 
                          BY crattem.nrdolote:

       FIND craptit WHERE RECID(craptit) = crattem.nrrectit NO-LOCK.

       IF   NOT AVAILABLE craptit THEN
            DO:
                ASSIGN glb_cdcritic = 770.
                       aux_flgerror = TRUE.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                                  
            
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                            " - Ref.: " + STRING(glb_dtmvtolt,"99/99/9999") +
                            " " + glb_dscritic +  " " +
                            " Sequencia: " + STRING(crattem.cdseqarq ,"9999") +
                            " >> log/titulos.log").
                LEAVE.
             END.

       
       FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                          crapage.cdagenci = craptit.cdagenci NO-LOCK NO-ERROR.
       
       IF   NOT AVAILABLE crapage THEN
            DO:
                ASSIGN glb_cdcritic = 015.
                       aux_flgerror = TRUE.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                                  
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                            " - Ref.: " + STRING(glb_dtmvtolt,"99/99/9999") +
                            " " + glb_dscritic +  " " +
                            " Sequencia: " + STRING(crattem.cdseqarq ,"9999") +
                            " >> log/titulos.log").
                LEAVE.
            END.

       
       IF   FIRST-OF(crattem.cdseqarq)  THEN
            DO:
                ASSIGN aux_hrarquiv = SUBSTR(STRING(time, "HH:MM:SS"), 1,2) +
                                      SUBSTR(STRING(time, "HH:MM:SS"), 4,2) +
                                      SUBSTR(STRING(time, "HH:MM:SS"), 7,2)
                       aux_qtarquiv = aux_qtarquiv + 1
                       aux_nmarquiv = "ti" +
                                      STRING(crapage.cdagetit,"99999") +
                                      STRING(DAY(glb_dtmvtolt),"99")   + 
                                      STRING(MONTH(glb_dtmvtolt),"99") +
                                      STRING(craptit.cdagenci,"999")    +
                                      STRING(crattem.cdseqarq,"99")    + 
                                      ".rem".

                IF   SEARCH("arq/" + aux_nmarquiv) <> ?   THEN
                     DO:
                         BELL.
                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE "Arquivo ja existe:" aux_nmarquiv.
                         glb_cdcritic = 459.
                         RETURN.
                     END.
                
                OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarquiv).
                
                /*   Header do Arquivo    */
                
                PUT STREAM str_1
                           "00100000"
                           FILL(" ",09)      FORMAT "x(09)"
                           "2"
                           crapcop.nrdocnpj  FORMAT "99999999999999"
                           aux_nrconven      FORMAT "x(20)"
                           crapcop.cdagedbb  FORMAT "999999"
                           crapcop.nrctadbb  FORMAT "9999999999999"
                           "0"
                           crapcop.nmrescop  FORMAT "x(30)"
                           "BANCO DO BRASIL"
                           FILL(" ",25)      FORMAT "x(25)"
                           "1"
                           aux_dtmvtolt      FORMAT "x(08)"
                           aux_hrarquiv      FORMAT "x(06)"
                           aux_cdsequen      FORMAT "999999"
                           "04000000"
                           FILL(" ",54)      FORMAT "x(54)" 
                           "000000000000000" SKIP.
            
                aux_cdsequen = aux_cdsequen + 1.
            END.
       
       IF   FIRST-OF(crattem.nrdolote)  THEN
            DO:
                ASSIGN aux_qttitlot = 0
                       aux_vltotlot = 0
                       aux_cddbanco = IF   crattem.cddbanco = 1 THEN
                                           30
                                      ELSE 31.

                /*   Header do Lote    */
                
                PUT STREAM str_1
                           "001"
                           crattem.nrdolote  FORMAT "9999"
                           "1C98"
                           aux_cddbanco      FORMAT "99"
                           "030 2"
                           crapcop.nrdocnpj  FORMAT "99999999999999"
                           aux_nrconven      FORMAT "x(20)"
                           crapcop.cdagedbb  FORMAT "999999"
                           crapcop.nrctadbb  FORMAT "9999999999999"
                           "0"
                           crapcop.nmrescop  FORMAT "x(30)"
                           FILL(" ",40)      FORMAT "x(40)"
                           crapcop.dsendcop  FORMAT "x(30)"
                           crapcop.nrendcop  FORMAT "zzzz9"
                           FILL(" ",15)      FORMAT "x(15)"
                           crapcop.nmcidade  FORMAT "x(20)"
                           crapcop.nrcepend  FORMAT "99999999" 
                           crapcop.cdufdcop  FORMAT "!(2)"
                           FILL(" ",08)      FORMAT "x(08)" 
                           "0000000000"      SKIP.
            END.

       ASSIGN aux_qttitlot = aux_qttitlot + 1
              aux_vltotlot = aux_vltotlot + craptit.vldpagto
              aux_qttitarq = aux_qttitarq + 1
          
              aux_dtvencim = 10/07/1997 + 
               DECIMAL(SUBSTR(STRING(craptit.dscodbar,"99999999999999"),6,4)).

       IF   aux_dtvencim = 10/07/1997 THEN
            aux_dtvencim = craptit.dtdpagto.
                      
       IF   craptit.insittit = 2   THEN                /*  Titulo programado  */
            ASSIGN aux_qttitprg = aux_qttitprg + 1
                   aux_vltitprg = aux_vltitprg + craptit.vldpagto.
       ELSE
            ASSIGN aux_qttitcxa = aux_qttitcxa + 1
                   aux_vltitcxa = aux_vltitcxa + craptit.vldpagto.
       
       ASSIGN aux_vldescon = 0
              aux_vldmulta = 0
              aux_vltitulo = IF   craptit.vltitulo = 0 THEN
                                  craptit.vldpagto
                             ELSE craptit.vltitulo.
       
       IF  aux_vltitulo > craptit.vldpagto THEN
           ASSIGN aux_vldescon = aux_vltitulo - craptit.vldpagto.
           
       IF  aux_vltitulo < craptit.vldpagto THEN
           ASSIGN aux_vldmulta = craptit.vldpagto - aux_vltitulo.

       PUT STREAM str_1 "001"
                        crattem.nrdolote               FORMAT "9999"
                        "3"
                        aux_qttitlot                   FORMAT "99999"
                        "J000"
                        craptit.dscodbar               FORMAT "x(44)"
                        "COOPERATIVA DE CREDITO"
                        FILL(" ",08)                   FORMAT "x(08)"
                        DAY(aux_dtvencim)              FORMAT "99"
                        MONTH(aux_dtvencim)            FORMAT "99"
                        YEAR(aux_dtvencim)             FORMAT "9999"
                        (aux_vltitulo * 100)           FORMAT "999999999999999"
                        (aux_vldescon * 100)           FORMAT "999999999999999"
                        (aux_vldmulta * 100)           FORMAT "999999999999999"
                        DAY(craptit.dtdpagto)          FORMAT "99"
                        MONTH(craptit.dtdpagto)        FORMAT "99"
                        YEAR(craptit.dtdpagto)         FORMAT "9999"
                        craptit.vldpagto * 100         FORMAT "999999999999999"
                        "000000000000000"
                        FILL(" ",40)                   FORMAT "x(40)"
                        craptit.cddmoeda               FORMAT "99"
                        "      "
                        "0000000000"
                        SKIP.
                
       IF   LAST-OF(crattem.nrdolote) THEN
            DO:
                /*   Trailer do Lote   */

                PUT STREAM str_1 "001"
                                 crattem.nrdolote   FORMAT "9999"
                                 "5         "
                                 (aux_qttitlot + 2) FORMAT "999999"
                                 (aux_vltotlot * 100)  
                                                    FORMAT "999999999999999999"
                                 "000000000000000000000000"
                                 FILL(" ",165)      FORMAT "x(165)"
                                 "0000000000"
                                 SKIP.
            END.

       IF   LAST-OF(crattem.cdseqarq) THEN
            DO:
                aux_qtlinarq = aux_qttitarq + (crattem.nrdolote * 2) + 2.
                
                /*   Trailer do Arquivo   */
                
                PUT STREAM str_1 "00199999         "
                                 crattem.nrdolote    FORMAT "999999"
                                 aux_qtlinarq        FORMAT "999999"
                                 "000000"
                                 FILL(" ",205)       FORMAT "x(205)" 
                                 SKIP.
                
                OUTPUT STREAM str_1 CLOSE.

                UNIX SILENT VALUE("ux2dos arq/" + aux_nmarquiv + 
                                  ' | tr -d "\032"' + 
                                  " > /micros/" + crapcop.dsdircop + 
                                  "/compel/" + aux_nmarquiv + " 2>/dev/null").

                UNIX SILENT VALUE("mv arq/" + aux_nmarquiv + 
                                  " salvar 2>/dev/null").
            END.
       
   END.  /*  Fim do FOR EACH -- crattem  */

   IF   glb_cdcritic > 0   THEN
        RETURN.

   /*  gravar tabela */

   ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                         THEN 9999
                         ELSE tel_cdagenci.

   
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:

      /*  Atualiza se a compensacao foi rodada  */
      
       FOR EACH crapage WHERE crapage.cdcooper  = glb_cdcooper      AND
                           (((crapage.cdagenci >= tel_cdagenci      AND
                              crapage.cdagenci <= aux_cdagefim)     AND
                              crapage.cdagenci <> 90                AND
                              crapage.cdagenci <> 91)       OR    
                             (crapage.cdagenci  = 90                AND
                              tel_cdagenci      = 90)       OR
                             (crapage.cdagenci  = 91                AND
                              tel_cdagenci      = 91))              NO-LOCK,
           EACH crawage WHERE crawage.cdagenci  = crapage.cdagenci  AND
                              crawage.cdbantit <> crapcop.cdbcoctl  NO-LOCK:   
            
           DO aux_contador = 1 TO 10:

              FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                                 craptab.nmsistem = "CRED"            AND
                                 craptab.tptabela = "GENERI"          AND
                                 craptab.cdempres = 00                AND
                                 craptab.cdacesso = "HRTRTITULO"      AND
                                 craptab.tpregist = crapage.cdagenci
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE craptab   THEN
                   IF   LOCKED craptab   THEN
                        DO:
                              RUN sistema/generico/procedures/b1wgen9999.p
                              PERSISTENT SET h-b1wgen9999.
    
                              RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                             INPUT "banco",
                                                             INPUT "craptab",
                                                             OUTPUT par_loginusr,
                                                             OUTPUT par_nmusuari,
                                                             OUTPUT par_dsdevice,
                                                             OUTPUT par_dtconnec,
                                                             OUTPUT par_numipusr).
                        
                              DELETE PROCEDURE h-b1wgen9999.
                        
                              ASSIGN aux_dadosusr = 
                                     "077 - Tabela sendo alterada p/ outro terminal.".
                        
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    MESSAGE aux_dadosusr.
                                    PAUSE 3 NO-MESSAGE.
                                    LEAVE.
                                END.
                        
                               ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                                      " - " + par_nmusuari + ".".
                        
                                HIDE MESSAGE NO-PAUSE.
                        
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    MESSAGE aux_dadosusr.
                                    PAUSE 5 NO-MESSAGE.
                                    LEAVE.
                                END.
                        
                                glb_cdcritic = 0.
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
               RETURN.

          ASSIGN aux_cdsituac = 1
                 aux_nrdahora = INT(SUBSTR(craptab.dstextab,3,5))

                 craptab.dstextab = STRING(aux_cdsituac,"9") + " " + 
                                    STRING(aux_nrdahora,"99999") + " " +
                                    SUBSTR(craptab.dstextab,9).
          RELEASE craptab.
       END.
      
      /*   Atualiza a sequencia da remessa  */
               
      DO aux_contador = 1 TO 10:

         FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                            craptab.nmsistem = "CRED"        AND
                            craptab.tptabela = "CONFIG"      AND
                            craptab.cdempres = 00            AND
                            craptab.cdacesso = "COMPELBBTI"  AND
                            craptab.tpregist = 000
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craptab   THEN
              IF   LOCKED craptab   THEN
                   DO:
                      RUN sistema/generico/procedures/b1wgen9999.p
                      PERSISTENT SET h-b1wgen9999.

                      RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                     INPUT "banco",
                                                     INPUT "craptab",
                                                     OUTPUT par_loginusr,
                                                     OUTPUT par_nmusuari,
                                                     OUTPUT par_dsdevice,
                                                     OUTPUT par_dtconnec,
                                                     OUTPUT par_numipusr).
                
                      DELETE PROCEDURE h-b1wgen9999.
                
                      ASSIGN aux_dadosusr = 
                             "077 - Tabela sendo alterada p/ outro terminal.".
                
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            MESSAGE aux_dadosusr.
                            PAUSE 3 NO-MESSAGE.
                            LEAVE.
                        END.
                
                       ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                              " - " + par_nmusuari + ".".
                
                        HIDE MESSAGE NO-PAUSE.
                
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            MESSAGE aux_dadosusr.
                            PAUSE 5 NO-MESSAGE.
                            LEAVE.
                        END.
                
                        glb_cdcritic = 0.
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
           RETURN.

      craptab.dstextab = SUBSTR(craptab.dstextab,1,37) +
                         STRING(aux_cdsequen,"999999").

      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                        " - Ref.: " + STRING(glb_dtmvtolt,"99/99/9999") +
                        " - Caixa: " + 
                        STRING(aux_qttitcxa,"zzz,zz9") +
                        " " + STRING(aux_vltitcxa,"zzz,zzz,zz9.99") +
                        " - Progr: " + STRING(aux_qttitprg,"zzz,zz9") +
                        " " + STRING(aux_vltitprg,"zzz,zzz,zz9.99") +
                        " >> log/compel.log").

   END. /* TRANSACTION */

END PROCEDURE.

PROCEDURE proc_titulos:

   ASSIGN tel_qttitrec = 0
          tel_vltitrec = 0
          tel_qttitrgt = 0
          tel_vltitrgt = 0
          tel_qttiterr = 0
          tel_vltiterr = 0
          tel_qttitprg = 0
          tel_vltitprg = 0
          tel_qttitcxa = 0
          tel_vltitcxa = 0
          tel_qttitulo = 0
          tel_vltitulo = 0.

   ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                         THEN 9999
                         ELSE tel_cdagenci.

   IF   glb_cddopcao <> "C" THEN 
        DO:
            IF   aux_flgenvio THEN /* Enviados */

                /*OBS: Temporariamente foi incluido o 0 no cdbcoenv pois
                  só o campo da tabela so sera alimentado com 1,756,85
                  quando for liberado a compe. Apos isso, remover o 0 */
                 ASSIGN aux_cdbcoenv = "0,1,756," + STRING(crapcop.cdbcoctl).
            ELSE                   /* Nao Enviados */
                 ASSIGN aux_cdbcoenv = "0".
        END.

   FOR EACH craptit WHERE craptit.cdcooper  = glb_cdcooper     AND
                          craptit.dtdpagto  = tel_dtmvtopg     AND 
                          craptit.tpdocmto  = 20               AND
                       (((craptit.cdagenci >= tel_cdagenci     AND
                          craptit.cdagenci <= aux_cdagefim)    AND
                          craptit.cdagenci <> 90               AND
                          craptit.cdagenci <> 91)     OR    
                         (craptit.cdagenci  = 90               AND
                          tel_cdagenci      = 90)     OR
                         (craptit.cdagenci  = 91               AND
                          tel_cdagenci      = 91))             AND
                          craptit.intitcop  = 0                AND
                 CAN-DO(aux_cdbcoenv,STRING(craptit.cdbcoenv)) AND
                          craptit.flgenvio  = aux_flgenvio     NO-LOCK, 
       EACH crawage WHERE crawage.cdagenci  = craptit.cdagenci NO-LOCK:

       /*
         Nao processar registro para opcao "B". Na atualiza_titulos foi colocado
         restricao tambem. Para isto sera utilizado a tela PRCCTL
       */
       IF  glb_cddopcao = "B"  AND  
           crawage.cdbantit = crapcop.cdbcoctl THEN
           NEXT.
       
       IF   craptit.insittit = 4   THEN
            DO:
                ASSIGN tel_qttitcxa = tel_qttitcxa + 1
                       tel_vltitcxa = tel_vltitcxa + craptit.vldpagto.
                NEXT.
            END.

       ASSIGN tel_qttitrec = tel_qttitrec + 1
              tel_vltitrec = tel_vltitrec + craptit.vldpagto.
                    
       IF   craptit.insittit = 1   THEN
            ASSIGN tel_qttitrgt = tel_qttitrgt - 1
                   tel_vltitrgt = tel_vltitrgt - craptit.vldpagto.
       ELSE
       IF   CAN-DO("0,2",STRING(craptit.insittit))   THEN
            ASSIGN tel_qttitprg = tel_qttitprg + 1
                   tel_vltitprg = tel_vltitprg + craptit.vldpagto.
       ELSE      
       IF   craptit.insittit = 3   THEN
            ASSIGN tel_qttiterr = tel_qttiterr - 1
                   tel_vltiterr = tel_vltiterr - craptit.vldpagto.
                     
   END.  /*  Fim do FOR EACH  --  Leitura do craptit  */

   IF   tel_qttitprg <> (tel_qttitrec + tel_qttitrgt + tel_qttiterr)   OR
        tel_vltitprg <> (tel_vltitrec + tel_vltitrgt + tel_vltiterr)   THEN
        DO:
            MESSAGE "ERRO - Informe o CPD ==> Qtd: "
                    STRING(tel_qttitrec + tel_qttitrgt + tel_qttiterr,
                           "zzz,zz9-")
                    " Valor: " 
                    STRING(tel_vltitrec + tel_vltitrgt + tel_vltiterr,
                           "zzz,zzz,zz9.99-") .
        END.
  
   ASSIGN tel_qttitulo = tel_qttitprg + tel_qttitcxa
          tel_vltitulo = tel_vltitprg + tel_vltitcxa.
                   
   DISPLAY tel_qttitrec tel_vltitrec
           tel_qttitrgt tel_vltitrgt
           tel_qttiterr tel_vltiterr
           tel_qttitprg tel_vltitprg
           tel_qttitcxa tel_vltitcxa
           tel_qttitulo tel_vltitulo
           WITH FRAME f_total.

END PROCEDURE.


PROCEDURE proc_verifica_pac_internet:
    
    /* Verifica se os titulos e faturas pagos tiveram os seus devidos debitos
       efetuados nas contas */
      
    DEF VAR  aux_qtlanmto    AS INTEGER                              NO-UNDO.
    DEF VAR  aux_vllanmto    AS DECIMAL                              NO-UNDO.
    
    DEF VAR  lcm_qtlanmto    AS INTEGER                              NO-UNDO.
    DEF VAR  lcm_vllanmto    AS DECIMAL                              NO-UNDO.
    

    FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                           craplcm.dtmvtolt = tel_dtmvtopg   AND
                           craplcm.cdagenci = 90             AND
                           craplcm.cdbccxlt = 11             AND
                           craplcm.nrdolote = 11000 + 900    AND
                           craplcm.cdhistor = 508            NO-LOCK
                           BREAK BY craplcm.nrdconta
                                   BY SUBSTRING(craplcm.cdpesqbb,1,36):
                                  
        IF   FIRST-OF(SUBSTRING(craplcm.cdpesqbb,1,36))   THEN
             ASSIGN aux_qtlanmto = 0 
                    aux_vllanmto = 0
                    lcm_qtlanmto = 0
                    lcm_vllanmto = 0.
                    
        ASSIGN lcm_qtlanmto = lcm_qtlanmto + 1
               lcm_vllanmto = lcm_vllanmto + craplcm.vllanmto.
               
        IF   LAST-OF(SUBSTRING(craplcm.cdpesqbb,1,36))   THEN
             DO: 
                 /* Titulos */
                 IF   craplcm.cdpesqbb BEGINS
                      "INTERNET - PAGAMENTO ON-LINE - BANCO"   THEN
                      DO:
                          /* Desconsidera estornos */ 
                          FOR EACH crablcm WHERE
                                   crablcm.cdcooper = glb_cdcooper       AND
                                   crablcm.dtmvtolt = tel_dtmvtopg       AND
                                   crablcm.cdagenci = 90                 AND
                                   crablcm.cdbccxlt = 11                 AND
                                   crablcm.nrdolote = 11000 + 900        AND
                                   crablcm.cdhistor = 570                AND
                                   crablcm.nrdconta = craplcm.nrdconta
                                   NO-LOCK:
                          
                              IF   crablcm.cdpesqbb BEGINS
                                   "INTERNET - ESTORNO PAGAMENTO " +
                                   "ON-LINE - BANCO"    THEN
                                   ASSIGN lcm_qtlanmto = lcm_qtlanmto - 1
                                          lcm_vllanmto = lcm_vllanmto -
                                                             crablcm.vllanmto.
                          END.                          
                                                          
                          FOR EACH craptit WHERE
                                   craptit.cdcooper = glb_cdcooper   AND
                                   craptit.dtmvtolt = tel_dtmvtopg   AND
                                   craptit.cdagenci = 90             AND
                                   craptit.cdbccxlt = 11             AND
                                   craptit.nrdolote = 16000 + 900    AND
                                   craptit.nrdconta = craplcm.nrdconta
                                   NO-LOCK:
                          
                              ASSIGN aux_qtlanmto = aux_qtlanmto + 1
                                     aux_vllanmto = aux_vllanmto +
                                                    craptit.vldpagto.
                          END.                            
                          IF   aux_qtlanmto <> lcm_qtlanmto   THEN
                               DO:
                                  MESSAGE "Titulos nao conferem com"
                                           "lancamentos - Conta/DV: "
                                           craplcm.nrdconta.
                                  glb_cdcritic = 139.
                                  RETURN.
                               END.                       
                      
                      END.
             END. /* Fim LAST-OF */    
   END.                          

END PROCEDURE. /* Fim proc_verifica_pac_internet */


PROCEDURE p_regera_agencia:

   ASSIGN aux_confirma = "N".
   UPDATE aux_confirma WITH FRAME f_regera.
  
   IF  aux_confirma <> "N" THEN 
       DO:
          EMPTY TEMP-TABLE crawage.

          FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:
              CREATE crawage.
              ASSIGN crawage.cdagenci = crapage.cdagenci
                     crawage.nmresage = crapage.nmresage
                     crawage.cdbantit = crapage.cdbantit
                     crawage.cdcomchq = crapage.cdcomchq.
          END.
       END.
  
   HIDE frame f_regera NO-PAUSE.
  
END PROCEDURE.

PROCEDURE atualiza_titulos:

   HIDE MESSAGE NO-PAUSE.
   
   MESSAGE "Atualizando titulos gerados ...".

   ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                         THEN 9999
                         ELSE tel_cdagenci.
           
   FOR EACH craptit WHERE craptit.cdcooper  = glb_cdcooper        AND
                          craptit.dtdpagto  = tel_dtmvtopg        AND
                          CAN-DO("2,4",STRING(craptit.insittit))  AND
                          craptit.tpdocmto  = 20                  AND
                       (((craptit.cdagenci >= tel_cdagenci        AND
                          craptit.cdagenci <= aux_cdagefim)       AND
                          craptit.cdagenci <> 90                  AND
                          craptit.cdagenci <> 91)      OR     
                         (craptit.cdagenci  = 90                  AND
                          tel_cdagenci      = 90)      OR
                         (craptit.cdagenci  = 91                  AND
                          tel_cdagenci      = 91))                AND
                          craptit.intitcop  = 0                   AND
                          craptit.flgenvio  = NO                  NO-LOCK,
       EACH crawage WHERE crawage.cdagenci  = craptit.cdagenci    AND
                          crawage.cdbantit <> crapcop.cdbcoctl NO-LOCK:
            
       FIND crabtit where recid(crabtit) = recid(craptit) 
                          EXCLUSIVE-LOCK NO-ERROR.
       IF  AVAIL crabtit THEN
           DO:
              ASSIGN crabtit.flgenvio = TRUE
                     crabtit.cdbcoenv = crawage.cdbantit.
              RELEASE crabtit.
           END.       
   END.

END PROCEDURE.

PROCEDURE atualiza_titulos_regerar:

   HIDE MESSAGE NO-PAUSE.
   
   MESSAGE "Atualizando titulos gerados ...".

   ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                         THEN 9999
                         ELSE tel_cdagenci.
           
   FOR EACH craptit WHERE craptit.cdcooper  = glb_cdcooper        AND
                          craptit.dtdpagto  = tel_dtmvtopg        AND
                          CAN-DO("2,4",STRING(craptit.insittit))  AND
                          craptit.tpdocmto  = 20                  AND
                          craptit.cdagenci >= tel_cdagenci        AND
                          craptit.cdagenci <= aux_cdagefim        AND
                          craptit.intitcop  = 0                   AND
                          craptit.flgenvio  = YES                 NO-LOCK,
       EACH crawage WHERE crawage.cdagenci  = craptit.cdagenci    AND
                          crawage.cdbantit <> crapcop.cdbcoctl NO-LOCK:
            
       FIND crabtit where recid(crabtit) = recid(craptit) 
                          EXCLUSIVE-LOCK NO-ERROR.
                          
       IF  AVAIL crabtit THEN
           DO:
               ASSIGN crabtit.flgenvio = FALSE
                      crabtit.cdbcoenv = 0.
               RELEASE crabtit.
           END.
   END.

   DO TRANSACTION ON ENDKEY UNDO, LEAVE:
      FOR EACH gncptit WHERE gncptit.cdcooper =  glb_cdcooper AND
                             gncptit.dtmvtolt =  glb_dtmvtolt AND
                             gncptit.cdtipreg =  1            AND
                             gncptit.cdagenci >= tel_cdagenci AND
                             gncptit.cdagenci <= aux_cdagefim 
                             EXCLUSIVE-LOCK:
          DELETE gncptit.
      END.
   END.   /* TRANSACTION */
   
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
               " - " + STRING(glb_dtmvtolt,"99/99/9999") +
               " - TITULOS REGERADOS - PA de " + 
               STRING(tel_cdagenci) +
               " ate " + STRING(aux_cdagefim) +
               " - Dt Pgto: " + STRING(tel_dtmvtopg,"99/99/9999") +
               " >> log/titulos.log").

END PROCEDURE.

PROCEDURE atualiza_controle_operador:

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                      craptab.nmsistem = "CRED"            AND       
                      craptab.tptabela = "GENERI"          AND
                      craptab.cdempres = crapcop.cdcooper  AND       
                      craptab.cdacesso = "TITULO"          AND
                      craptab.tpregist = 1             
                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                     
   IF  AVAIL craptab THEN      
       DO:
          ASSIGN craptab.dstextab = " ".
          RELEASE craptab.
       END.

END PROCEDURE.

PROCEDURE imprimir_lotes:

   DEF VAR lot_nmoperad AS CHAR                                  NO-UNDO.
    
   DEF VAR pac_qtdlotes AS INT     FORMAT "zzz,zz9"              NO-UNDO.
   DEF VAR pac_qttitulo AS INT     FORMAT "zzz,zz9"              NO-UNDO.
   DEF VAR pac_vltitulo AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.

   DEF VAR tel_dscodbar AS CHAR    FORMAT "x(44)"                NO-UNDO.
   DEF VAR tel_nrcampo1 AS DECIMAL FORMAT "9999999999"           NO-UNDO.
   DEF VAR tel_nrcampo2 AS DECIMAL FORMAT "99999999999"          NO-UNDO.
   DEF VAR tel_nrcampo3 AS DECIMAL FORMAT "99999999999"          NO-UNDO.
   DEF VAR tel_nrcampo4 AS INT     FORMAT "9"                    NO-UNDO.
   DEF VAR tel_nrcampo5 AS DECIMAL FORMAT "zzzzzzzzzzz999"       NO-UNDO.
   DEF VAR tel_dsdlinha AS CHAR                                  NO-UNDO.

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

   FORM tel_dtmvtopg  AT   1   LABEL "REFERENCIA"   FORMAT "99/99/9999"
        SKIP(1)
        "PA CXA    LOTE"           AT  2
        "   QTD.           VALOR"        
        "OPERADOR      ARQUIVO" 
        SKIP(1)
        WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_cab.    

   FORM cratlot.cdagenci AT  1              
        cratlot.cdbccxlt AT  5               
        cratlot.nrdolote AT  9 
        cratlot.qttitulo AT 17               
        cratlot.vltitulo AT 25             
        cratlot.nmoperad AT 41           
        cratlot.nmarquiv AT 55 
        WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_lotes.
    
   FORM tel_dsdlinha     FORMAT "x(56)"          LABEL "Linha digitavel"
        craptit.vldpagto FORMAT "zzzzzz,zz9.99"  LABEL "Valor Pago"
        craptit.nrautdoc FORMAT "zzz,zz9"        LABEL "Aut."
        WITH COLUMN 2 NO-LABEL NO-BOX DOWN FRAME f_lanctos.
    
   FORM SKIP(1) WITH NO-BOX FRAME f_linha.

   INPUT THROUGH basename `tty` NO-ECHO.

   SET aux_nmendter WITH FRAME f_terminal.

   INPUT CLOSE.
   
   aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                         aux_nmendter.

   UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

   ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex"
          glb_cdempres = 11
          glb_nrdevias = 1
          glb_nmformul = "80col"           
          glb_cdrelato = 424.

   OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.
    
   { includes/cabrel080_2.i }
    
   VIEW STREAM str_2 FRAME f_cabrel080_2.
    
   /* busca dados da cooperativa */
   FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
   EMPTY TEMP-TABLE cratlot.
    
   FOR EACH craplot WHERE 
            craplot.cdcooper = glb_cdcooper                       AND
           (craplot.cdagenci = tel_cdagenci OR tel_cdagenci = 0)  AND
           (craplot.nrdcaixa = tel_nrdcaixa OR tel_nrdcaixa = 0)  AND
          ((craplot.dtmvtolt = tel_dtmvtopg                       AND
            craplot.cdbccxlt = 11)                                OR
           (craplot.dtmvtopg = tel_dtmvtopg))                     AND 
            craplot.tplotmov = 20                                 NO-LOCK
            BREAK BY craplot.cdagenci
                     BY craplot.cdbccxlt
                        BY craplot.nrdolote:

       FIND crapope WHERE crapope.cdcooper = glb_cdcooper     AND
                          crapope.cdoperad = craplot.cdoperad NO-LOCK NO-ERROR.
    
       IF   NOT AVAILABLE crapope   THEN
            lot_nmoperad = craplot.cdoperad.
       ELSE
            lot_nmoperad = ENTRY(1,crapope.nmoperad," ").

       CREATE cratlot.
       ASSIGN cratlot.cdagenci = craplot.cdagenci
              cratlot.cdbccxlt = craplot.cdbccxlt
              cratlot.nrdolote = craplot.nrdolote
              cratlot.qttitulo = craplot.qtinfoln
              cratlot.vltitulo = craplot.vlcompcr              
              cratlot.nmoperad = lot_nmoperad
              cratlot.nmarquiv = STRING(crapcop.cdagebcb,"9999") +
                                 STRING(MONTH(tel_dtmvtopg),"99") +
                                 STRING(DAY(tel_dtmvtopg),"99") +
                                 STRING(craplot.cdagenci,"999") +
                                 STRING(craplot.nrdolote,"999999") + ".CBE".

       /* Restages */
       FOR EACH craptit WHERE craptit.cdcooper  = glb_cdcooper       AND
                              craptit.dtmvtolt  = craplot.dtmvtolt   AND
                              craptit.cdagenci  = craplot.cdagenci   AND
                              craptit.cdbccxlt  = craplot.cdbccxlt   AND
                              craptit.nrdolote  = craplot.nrdolote   AND
                              craptit.intitcop  = 0                  AND
                              craptit.dtdevolu <> ?                  NO-LOCK:
    
            ASSIGN cratlot.qttitulo = cratlot.qttitulo - 1
                   cratlot.vltitulo = cratlot.vltitulo - craptit.vldpagto.
    
       END.  /*  for each craptit */
   
   END.  /*  for each craplot */

   DISPLAY STREAM str_2 tel_dtmvtopg WITH FRAME f_cab.

   /* lista os lotes */
   FOR EACH cratlot BREAK BY cratlot.cdagenci
                             BY cratlot.cdbccxlt 
                                BY cratlot.nrdolote:
       
       IF   FIRST-OF(cratlot.cdagenci)   THEN
            DO:
               IF   LINE-COUNTER(str_2) > 80  THEN
                    DO:
                       PAGE STREAM str_2.
                       
                       DISPLAY STREAM str_2 tel_dtmvtopg WITH FRAME f_cab.
                    END.
            END.
   
       CLEAR FRAME f_lotes.
       
       DISPLAY STREAM str_2 SKIP WITH FRAME f_linha2.
       
       DISPLAY STREAM str_2  
               cratlot.cdagenci   cratlot.cdbccxlt  
               cratlot.nrdolote   cratlot.qttitulo
               cratlot.vltitulo   cratlot.nmoperad
               cratlot.nmarquiv   WITH FRAME f_lotes.

       ASSIGN pac_qtdlotes = pac_qtdlotes + 1
              pac_qttitulo = pac_qttitulo + cratlot.qttitulo
              pac_vltitulo = pac_vltitulo + cratlot.vltitulo.

       DOWN STREAM str_2 WITH FRAME f_lotes.                     

       /* lista os titulos do lote */
       VIEW STREAM str_2 FRAME f_linha.
    
       FOR EACH craptit WHERE craptit.cdcooper = glb_cdcooper       AND
                              craptit.dtmvtolt = tel_dtmvtopg       AND
                              craptit.cdagenci = cratlot.cdagenci   AND
                              craptit.cdbccxlt = cratlot.cdbccxlt   AND
                              craptit.nrdolote = cratlot.nrdolote   AND       
                              craptit.intitcop = 0                  NO-LOCK
                              USE-INDEX craptit2 BY craptit.nrautdoc:
                            
           ASSIGN tel_dscodbar = craptit.dscodbar.
        
           /*  Compoe a linha digitavel atraves do codigo de barras  */
           ASSIGN tel_nrcampo1 = DECIMAL(SUBSTRING(tel_dscodbar,01,04) +
                                         SUBSTRING(tel_dscodbar,20,01) +
                                         SUBSTRING(tel_dscodbar,21,04) + "0")
                                  
                  tel_nrcampo2 = DECIMAL(SUBSTRING(tel_dscodbar,25,10) + "0")
                  tel_nrcampo3 = DECIMAL(SUBSTRING(tel_dscodbar,35,10) + "0")
                  tel_nrcampo4 = INTEGER(SUBSTRING(tel_dscodbar,05,01))
                  tel_nrcampo5 = DECIMAL(SUBSTRING(tel_dscodbar,06,14))

                  tel_dsdlinha = STRING(tel_nrcampo1,"99999,99999")  + " " +
                                 STRING(tel_nrcampo2,"99999,999999") + " " +
                                 STRING(tel_nrcampo3,"99999,999999") + " " +
                                 STRING(tel_nrcampo4,"9")            + " " +
                                 STRING(tel_nrcampo5,"zzzzzzzzzzz999"). 
                  

           DISPLAY STREAM str_2 
                   tel_dsdlinha       COLUMN-LABEL "Codigo"
                   craptit.vldpagto 
                   craptit.nrautdoc
                   WITH FRAME f_lanctos.

           DOWN STREAM str_2 WITH FRAME f_lanctos.

           IF   LINE-COUNTER(str_2) > 80  THEN
                DO:
                    PAGE STREAM str_2.
                    DISPLAY STREAM str_2 tel_dtmvtopg WITH FRAME f_cab.
                
                    DISPLAY STREAM str_2  
                            cratlot.cdagenci 
                            cratlot.cdbccxlt  
                            cratlot.nrdolote 
                            cratlot.qttitulo
                            cratlot.vltitulo
                            cratlot.nmoperad
                            cratlot.nmarquiv
                            WITH FRAME f_lotes. 

                    VIEW STREAM str_2 FRAME f_linha.
                END.

       END.  /*  for each craptit  */
    
       ASSIGN tel_dscodbar = "".

       VIEW STREAM str_2 FRAME f_linha.
   
   END.  /* FOR EACH cratlot */

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

PROCEDURE proc_limpa: /*  Procedure para limpeza da tela  */

    HIDE FRAME f_total.
    HIDE FRAME f_fechamento.
    HIDE FRAME f_refere.
    HIDE FRAME f_refere_v.
    HIDE FRAME f_refere_d.

    HIDE FRAME f_agencia.
    HIDE FRAME f_regera.
    RETURN.

END PROCEDURE.

/*  ........................................................................  */

PROCEDURE imprimir_carta_remessa:
/* GERA APENAS PARA CECRED */

   ASSIGN tel_qttitprg = 0
          tel_vltitprg = 0
          tel_qttitcxa = 0
          tel_vltitcxa = 0
          tel_qttitulo = 0
          tel_vltitulo = 0.

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
        tel_dtmvtopg   LABEL "REFERENCIA............." SKIP(3)
        "CARTA REMESSA COBRANCA"                 AT 29
        "PROCESSAMENTO ELETRONICO"               AT 28
        SKIP(3)
        "TOTAL GERAL"                            SKIP
        "-----------"                            SKIP
        tel_qttitulo   LABEL "QUANT. DE DOCUMENTOS..."  SKIP
        tel_vltitulo   LABEL "VALOR TOTAL DA REMESSA." 
        SKIP(5)
        "___________________________________"    AT 1
        "___________________________________"    AT 46 SKIP
        "CARIMBO E ASSINATURA DA COOPERATIVA"    AT 1
        "CARIMBO E ASSINATURA DA ABBC"           AT 50 SKIP
        WITH SIDE-LABELS NO-BOX WIDTH 84 FRAME f_carta.
    
   
   UNIX SILENT VALUE("rm rl/crrl554_" + STRING(tel_cdagenci,"9999") + 
                     "* 2> /dev/null").

   FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                      crapage.cdagenci = tel_cdagenci  NO-LOCK NO-ERROR.

   ASSIGN aux_nmarqimp = "rl/crrl554_" + STRING(tel_cdagenci,"9999") + ".lst"
          glb_cdempres = 11
          glb_nrdevias = 1
          glb_nmformul = "80col"           
          glb_cdrelato = 554
          aux_cdbcoenv = STRING(crapcop.cdbcoctl)
          aux_dsbcoenv = "AILOS"
          aux_dsbcoctl = STRING(INT(aux_cdbcoenv),"999") + " - " + aux_dsbcoenv
          aux_dscooper = crapcop.nmextcop /*crapcop.nmrescop*/
          aux_cdagectl = crapcop.cdagectl
          aux_dsagenci = STRING(crapage.cdagenci,"999") + " - " + 
                         crapage.nmresage.
                         
    FOR EACH craptit WHERE craptit.cdcooper  = glb_cdcooper     AND
                           craptit.dtdpagto  = tel_dtmvtopg     AND 
                           craptit.tpdocmto  = 20               AND
                           craptit.cdagenci  = tel_cdagenci     AND
                           craptit.intitcop  = 0                AND
                           CAN-DO(aux_cdbcoenv,STRING(craptit.cdbcoenv))
                           NO-LOCK, 
        EACH crawage WHERE crawage.cdagenci = craptit.cdagenci  NO-LOCK:   

       ASSIGN tel_qttitulo = tel_qttitulo + 1
              tel_vltitulo = tel_vltitulo + craptit.vldpagto.

   END.  /*  Fim do FOR EACH  --  Leitura do craptit  */
  
   OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.
    
   { includes/cabrel080_2.i }

   VIEW STREAM str_2 FRAME f_cabrel080_2.

   DISPLAY STREAM str_2 aux_dsbcoctl  aux_dscooper  aux_cdagectl 
                        aux_dsagenci  tel_dtmvtopg  tel_qttitulo
                        tel_vltitulo  WITH FRAME f_carta.

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

