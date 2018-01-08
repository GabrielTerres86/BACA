/* .............................................................................

   Programa: Fontes/operad.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/99.                     Ultima atualizacao: 08/08/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela operad.

   Alteracoes: 25/06/2004 - Inclusao da opcao "D" (Evandro).

               06/04/2005 - Permitir solicitacao de cartao apenas para as
                            cooperativas que tem cash dispenser (Edson).

               05/07/2005 - Alimentado campo cdcooper das tabelas crapcrm,
                            crapope, crapace e do buffer b-crapace (Diego).
                            
               03/08/2005 - Criada opcao "S" - senha  (Diego). 
                           
               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapace (Diego).

               22/12/2005 - Incluido tipo de operador PROGRID (Edson).
               
               22/02/2006 - Incluido o campo PAC do operador (Rosangela).

               16/03/2006 - Incluidos campos tel_flgdopgd e tel_flgacres,
                            referentes Acesso Sistema de Relacionamento (Diego).
  
               29/03/2006 - Incluido parametro codigo da cooperativa no
                            fontes/zomm_pac.p (Diego).

               07/04/2006 - Incluido parametro codigo da cooperativa no
                            fontes/zoom_operador.p(Mirtes)

               07/06/2006 - Alimentado campo cdcooper das tabelas:
                            crapope, crapcrm, crapmat, craptel (David).

               12/09/2006 - Excluidas opcoes "TAB" (Diego).

               17/10/2006 - Incluido campo "valor de limite" e browse na
                            consulta (Elton).

               29/03/2007 - Incluido tipo de operador na leitura da
                            tabela crapcrm(Mirtes)

               27/04/2007 - Retirada a chamada do fontes/zomm_pac.p pois o
                            fonte nao existia (Evandro).

               17/05/2007 - Permitir opcao de alteracao (alguns campos)

               09/06/2008 - Incluir parametro inpessoa na chamada do 
                            fontes/carmag.p (Guilherme).

               07/08/2008 - Includo campo crapope.flgdonet. Gerar log em
                            log/operad.log e critica para alteracao por parte
                            das filiadas nos operadores 1,799,996,997
                            (Gabriel).
                          - Nao permitir filiadas alterarem o campo 'Acessar
                            Sistema ayllos INTRANET' (Gabriel).

               23/01/2009 - Retirar permiissao do operador 799 e
                            liberar ao 979 (Gabriel).

               25/05/2009 - Alteracao CDOPERAD (Kbase).

               10/09/2009 - Implementacao de alteracao do campo 
                            "Alcada de Credito" do Operador (GATI - Eder)

               20/10/2009 - Na alteracao se departamento for "SISCAIXA" e na
                            inclusao se operador for "888", somente permite
                            nivel de operador "OPERADOR" (Elton).

               26/11/2009 - Incluir campo crapope.flgcomit que indica o comite
                            de credito que o operador participa (David).

               11/05/2010 - Incluir campo DSDEPART na tela e permitir alteracao
                            somente quando GLB_DSDEPART = TI             
                            (Guilherme/Supero)
                            
               09/09/2010 - Gerar log do campo crapope.vlpagchq (Vitor).
               
               10/11/2010 - Acerto na opcao "I" p/ campo tel_dsdepart (Vitor)   
               
               
               11/02/2011 - Efetuado controle de registro em locked na opcao
                            S (Adriano).           
                            
               29/06/2011 - Permitir alterar o nivel do operador 
                            independentemente do cartao magnetico (Gabriel).
                                         
               08/08/2011 - Liberar atualizacao do campo flgdonet (Magui).
               
               15/09/2011 - Inclusao do Requisito "OPERAD - Alcada de Estorno" 
                            (Vitor - GATI)
                            
               05/10/2011 - Alterado label do campo tel_flgdonet de "Acessar
                            sistema Ayllos intranet" para "Acessar sistema
                            Ayllos WEB", e tambem alterado o HELP
                            (GATI - Oliver)
                            
               23/12/2011 - Retirar warnings (Gabriel).
               
               27/12/2011 - Esconder outros frames na opcao "Z" (Tiago).  
                                        
               19/01/2012 - Alterado nrsencar para dssencar (Guilherme).

               23/01/2012 - Incluido campo PAC de Trabalho (Tiago). 
               
               08/06/2012 - Incluido opção "X" para replicar o registro do
                            operador para as outras cooperativas.(David Kruger).
                            
               05/07/2012 - Tratamento do tel_cdoperad na opcao "M", para que o
                            número de caracteres seja superior a 8 e não aceite
                            characteres, apenas numeros inteiros (Lucas R.).
                            
               25/07/2012 - Alterado para deixar o campo "Acessa Sistema Ayllos WEB" 
                            na opção "I" com valor default "SIM". (Lucas R.).
                            
               15/02/2013 - Incluido o campo "permissao de acesso" (Daniele).
               
               08/04/2013 - Alteradas opcoes "I", "D" e "X".
                            "I" alterada criacao de permissao default.
                            "D" duplicar acesso para ambientes web e caracter.
                            "X" ajustes das opcoes "I" e "X". (Jorge)
                            
               18/06/2013 - Correção no Lock da crapope (Lucas).
               
               23/04/2014 - Ajuste para buscar a proxima sequencia
                            crapmat.nrseqcar do banco Oracle. (James)
                            
               09/10/2014 - (Chamado 150561) Utilizar a teclar F7 para listar 
                            e aceitar somenters departamentos ja cadastrados.
                            (Tiago Castro - RKAM).

               19/01/2015 - Permitir o operador Suporte alterar os 
                            departamentos (Jonata-RKAM).
                            
               13/04/2015 - Adicionado campo valor limite TED (Tiago). 
               
               15/05/2015 - Adicionado campo alcada resgate operador (Tiago).
               
               02/06/2015 - Aumentado format do campo valor limite ted (Tiago).
               
               14/07/2015 - Incluído o departamento controle para alterar o departamento
                            conforme solicitado pelo Guilherme Gielow (Kelvin).
               
               23/07/2015 - Ajuste na criacao do cartao magnetico. (James)
               
               05/08/2015 - Removido opcao "Z". (Reinert)
               
               16/10/2015 - #346541 Retirados os codigos que envolviam a craptab
			                com o cdacesso PGOPERADOR pois a tab, alem de nao ser
							mais utilizada, estava excedendo o limite de
							caracteres em dstextab (Carlos)
               
               27/11/2015 - Substituido a chamada da fn_sequence pelo
                            procedure do oracle devido a problemas de cursores
                            abertos (Tiago/Rodrigo SD347440).
                            
               24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
               
               05/05/2016 - Ajuste para gerar log da opçao "T" na "LOGTEL", conforme solicitado
                            no chamado 422419. (Kelvin)
                            
               16/09/2016 - Permitir alterar o campo flgacres, para resolver o problema relatado
                            no chamado 512411. (Kelvin)
                            
               05/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)   
						
			   22/12/2016 - Ajustar bloqueio dos departamentos para VIACREDI e CECRED, conforme
			                solicitação feita no chamado 549118 (Renato Darosci - Supero)
                      
               08/08/2017 - Incluido o campo "Habilitar Acesso CRM". (Reinert - Projeto 339)
               
               24/11/2017 - Melhoria 458, Adicionado campo tel_insaqesp "Libera Saque Especie" - (Antonio R Junior - Mouts)
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR tel_cdoperad AS CHAR    FORMAT "X(10)"                NO-UNDO.
DEF        VAR tel_nmoperad AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_nvoperad AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR tel_tpoperad AS CHAR    FORMAT "x(17)"                NO-UNDO.
DEF        VAR tel_dssitope AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR tel_dsdepart AS CHAR    FORMAT "x(25)"                NO-UNDO.
DEF        VAR tel_cddepart AS INTE    FORMAT "ZZZ9"                 NO-UNDO.
DEF        VAR tel_nmdatela AS CHAR    FORMAT "x(6)"                 NO-UNDO.
DEF        VAR tel_cddopcao AS CHAR    FORMAT "x(1)"                 NO-UNDO.
DEF        VAR tel_tldatela AS CHAR                                  NO-UNDO.

DEF        VAR tel_cdagenci AS INTE                                  NO-UNDO.
DEF        VAR tel_cdpactra AS INTE                                  NO-UNDO.
DEF        VAR tel_cdcomite AS INTE    FORMAT "9"                    NO-UNDO.
DEF        VAR tel_dscomite AS CHAR    FORMAT "x(15)"                NO-UNDO.


DEF        VAR tel_flgperac AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR tel_flgdopgd AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR tel_flgacres AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR tel_flgdonet AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR tel_insaqesp AS LOGICAL INITIAL FALSE FORMAT "Sim/Nao" NO-UNDO.
DEF        VAR tel_flgutcrm AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR tel_flgcarta AS LOGICAL                               NO-UNDO.

DEF        VAR tel_vlpagchq LIKE crapope.vlpagchq                    NO-UNDO.
DEF        VAR tel_vlalccre LIKE crapope.vlapvcre                    NO-UNDO.

DEF        VAR tel_vlalcest LIKE crapope.vlestor1                    NO-UNDO.
DEF        VAR tel_vlalcesp LIKE crapope.vlestor2                    NO-UNDO.

DEF        VAR tel_vlapvcap LIKE crapope.vlapvcap                    NO-UNDO.
DEF        VAR tel_vllimted LIKE crapope.vllimted FORMAT "zzz,zzz,zz9.99" NO-UNDO.

           /* Variaveis para log */
DEF        VAR log_nmoperad AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR log_nvoperad AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR log_tpoperad AS CHAR    FORMAT "x(17)"                NO-UNDO.
DEF        VAR log_flgcarta AS LOGICAL                               NO-UNDO.
DEF        VAR log_cdagenci AS INTE                                  NO-UNDO.
DEF        VAR log_cdcomite AS INTE                                  NO-UNDO.
DEF        VAR log_dscomite AS CHAR                                  NO-UNDO.
DEF        VAR log_flgdonet AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR log_insaqesp AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR log_flgdopgd AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR log_flgacres AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR log_flgperac AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR log_flgutcrm AS LOGICAL FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR log_vlalccre AS DECIMAL                               NO-UNDO.
DEF        VAR log_vlalcest AS DECIMAL                               NO-UNDO.
DEF        VAR log_vlalcesp AS DECIMAL                               NO-UNDO.
DEF        VAR log_vlapvcap AS DECIMAL                               NO-UNDO.
DEF        VAR log_vlpagchq AS DECIMAL                               NO-UNDO.
DEF        VAR log_vllimted LIKE crapope.vllimted                    NO-UNDO.


DEF        VAR aux_inposniv AS INT                                   NO-UNDO.
DEF        VAR aux_inpostip AS INT                                   NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR ant_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dssitope AS CHAR    INIT "ATIVO,BLOQUEADO"        NO-UNDO.

DEF        VAR aux_tpoperad AS CHAR  
  INIT "TERMINAL,CAIXA,TERMINAL + CAIXA,RETAGUARDA,CASH + RETAGUARDA,PROGRID"
                                                                     NO-UNDO.
DEF        VAR aux_nvoperad AS CHAR    INIT "OPERADOR,SUPERVISOR,GERENTE"
                                                                     NO-UNDO.

DEF        VAR aux_inestlan AS CHAR    INIT "Menor ou igual a 30 dias,                                             Maior que 30 dias"
                                                                     NO-UNDO.

DEF        VAR aux_deoperad AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_paraoper AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR aux_nmdeoper AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR aux_nmparaop AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR aux_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR aux_dstextab AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR flg_altdepto AS LOG                                   NO-UNDO.
DEF        VAR aux_cdoperad AS INTE                                  NO-UNDO.
DEF        VAR aux_ponteiro AS INTE                                  NO-UNDO.
DEF        VAR aux_nrseqcar LIKE crapmat.nrseqcar                    NO-UNDO.

DEF        VAR aux_vlapvcap LIKE crapope.vlapvcap                    NO-UNDO.

DEF        BUFFER b-crapace FOR crapace.
DEF        BUFFER b-crapcop FOR crapcop.
DEF        BUFFER b-crapope FOR crapope.

DEF TEMP-TABLE cratope                                               NO-UNDO
    FIELD cdoperad AS CHAR FORMAT "x(10)"
    FIELD nmoperad AS CHAR
    FIELD cdagenci AS INT    
    FIELD dscomite AS CHAR
    FIELD flgperac AS LOGICAL 
    INDEX bloqueio AS PRIMARY nmoperad cdoperad.

DEF TEMP-TABLE cratoes                                               NO-UNDO
    FIELD cdoperad AS CHAR FORMAT "x(10)"
    FIELD nmoperad AS CHAR FORMAT "x(28)"
    FIELD cdagenci LIKE crapope.cdagenci
    FIELD vlestorn LIKE crapope.vlestor1
    FIELD vlestor2 LIKE crapope.vlestor2
    INDEX operador AS PRIMARY UNIQUE cdoperad.
 

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                   TITLE COLOR MESSAGE glb_tldatela
                   FRAME f_moldura.

FORM SKIP
     glb_cddopcao AT 24 LABEL "Opcao" AUTO-RETURN
     SKIP(1)
     tel_cdoperad AT 11 LABEL "Codigo do Operador" AUTO-RETURN
         HELP "Informe o codigo ou tecle <F7> para listar os operadores."
         VALIDATE(tel_cdoperad <> "",
                  "087 - Codigo do operador deve ser informado.")
     SKIP
     tel_nmoperad AT 16 LABEL "Nome Completo" AUTO-RETURN
         HELP "Informe o nome do operador (nome completo)."
         VALIDATE(tel_nmoperad <> "","016 - Nome deve ser informado.")
     tel_nvoperad AT 12 LABEL "Nivel do Operador"
         HELP "Escolha o nivel do operador."
     tel_flgperac AT 46 LABEL "Permissao de Acesso" 
         HELP "Informe SIM para liberar acesso as contas restritas"
         
     SKIP 
     tel_tpoperad AT 13 LABEL "Tipo de Operador" 
         HELP "Escolha o tipo de operador."
     SKIP
     tel_flgcarta AT 7 LABEL "Gerar Cartao Magnetico" FORMAT "SIM/NAO"
     SKIP
     tel_cdagenci FORMAT "zzz9" AT 15 LABEL "PA do operador"
         HELP "Informe o PA do operador."
         VALIDATE(CAN-FIND(crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                         crapage.cdagenci = INPUT tel_cdagenci),
                                         "016 - PA informado nao eh valido.")
     tel_cdpactra FORMAT "zzz9" AT 46 LABEL "PA de Trabalho"
     
     tel_flgdonet AT  3 LABEL "Acessar Sistema Ayllos WEB"
         HELP "Informe SIM para liberar a tela Ayllos WEB."
     
     tel_insaqesp AT  40 LABEL "Libera Saque Especie"
         HELP "Informe SIM para liberar saque especie."

     tel_flgdopgd AT  8 LABEL "Aces. Sist. de Relac." 
         HELP "Informe SIM para liberar acesso ao Sistema de Relacionamento"
     SKIP     
     tel_flgacres AT 8 LABEL "Acesso Restrito ao PA"
         HELP "SIM - acesso a unico PA / NAO - acesso a todos PA'S"
     tel_dssitope AT 46 LABEL "Situacao"
     SKIP
     tel_cddepart AT 17 LABEL "Departamento"    
        HELP "Tecle <F7> para listar os departamentos."
     tel_dsdepart AT 36 NO-LABELS 
     SKIP 
     tel_vlpagchq AT 14 LABEL "Valor de Limite" 
         HELP "Informe o valor maximo de liberacao."
     tel_vllimted FORMAT "zzz,zzz,zz9.99" AT 46 LABEL "Valor Limite TED"
       HELP "Informe o valor maximo de limite de TED do operador."
     SKIP
     "Participa do Comite:" AT 10
     tel_cdcomite AT 34 NO-LABEL
         VALIDATE(tel_cdcomite <= 2,"014 - Opcao errada.")
         HELP "Selecione o comite: 0-Nao Participa/1-Local/2-Sede."
     tel_dscomite AT 38 NO-LABEL
     SKIP
     tel_vlalccre AT 03 LABEL "Valor da Alcada de Credito"
         HELP "Informe o valor da alcada de credito."
     SKIP
     tel_vlapvcap AT 02 LABEL "Valor da Alcada de Captacao"
         HELP "Informe o valor da alcada de captacao."
     tel_flgutcrm AT 46 LABEL "Habilitar acesso CRM" HELP "Informe SIM para liberar o acesso ao CRM."        
     WITH ROW 5 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_operad.

FORM SKIP(1)
     aux_deoperad       AT  5        LABEL "DE"
                        HELP "Entre com o codigo do operador DE"
     "-"             
     aux_nmdeoper                    NO-LABEL
     SKIP(1)
     aux_paraoper       AT  3        LABEL "PARA"
                        HELP "Enter com o codigo do operador PARA"
     "-"              
     aux_nmparaop                    NO-LABEL
     SKIP(1)
     WITH ROW 9 CENTERED SIDE-LABELS OVERLAY TITLE "DUPLICAR PERMISSOES"
     FRAME f_duplica.

FORM SKIP(1)
     tel_cdoperad   AT 8 LABEL "SENHA"
     WITH ROW 9 CENTERED NO-LABEL SIDE-LABELS OVERLAY TITLE "NOVA SENHA"
     FRAME f_senha.
     
DEF QUERY q_oper_cred_cmtlocal FOR cratope.
DEF QUERY q_oper_cred_alcada   FOR crapope.
DEF QUERY q_oper_esto_alcada   FOR cratoes.

DEF BROWSE b_oper_cred_alcada QUERY q_oper_cred_alcada
    DISP crapope.cdoperad COLUMN-LABEL "Codigo"
         crapope.nmoperad COLUMN-LABEL "Nome"    FORMAT "x(37)"
         crapope.cdagenci COLUMN-LABEL "PA"
         crapope.vlapvcre COLUMN-LABEL "Alcada Credito"
         
    WITH 6 DOWN OVERLAY TITLE " Selecione os Operadores " MULTIPLE.    

DEF BROWSE b_oper_cred_cmtlocal QUERY q_oper_cred_cmtlocal
    DISP cratope.cdoperad COLUMN-LABEL "Codigo"
         cratope.nmoperad COLUMN-LABEL "Nome"    FORMAT "x(30)"
         cratope.cdagenci COLUMN-LABEL "PA"
         cratope.dscomite COLUMN-LABEL "Comite"  FORMAT "x(13)"
    WITH 6 DOWN OVERLAY TITLE " Selecione os Operadores " MULTIPLE.    

DEF BROWSE b_oper_esto_alcada QUERY q_oper_esto_alcada
    DISP cratoes.cdoperad COLUMN-LABEL "Codigo"
         cratoes.nmoperad COLUMN-LABEL "Nome"  
         cratoes.cdagenci COLUMN-LABEL "PA"
         cratoes.vlestorn COLUMN-LABEL "Alcada Normal"
         cratoes.vlestor2 COLUMN-LABEL "Alcada Especial"
    WITH 6 DOWN WIDTH 78 OVERLAY TITLE " Selecione os Operadores " MULTIPLE .    

FORM tel_cdcomite AT 12 LABEL "Participa do Comite"
         VALIDATE(tel_cdcomite <= 2,"014 - Opcao errada.")
         HELP "Selecione o comite: 0-Nao Participa/1-Local/2-Sede."
     tel_dscomite AT 35 NO-LABEL
     SKIP
     tel_vlalccre AT 05 LABEL "Valor da Alcada de Credito" 
         HELP "Informe o novo valor da Alcada de Credito" 
     "                         "
     WITH NO-BOX OVERLAY ROW 8 COLUMN 5 FRAME f_oper_cred SIDE-LABELS.

FORM SKIP
     tel_vlalcest AT 05 LABEL "Valor da Alcada Normal  "
        HELP  
     "                         " SKIP
     tel_vlalcesp AT 05 LABEL "Valor da Alcada Especial"
     WITH NO-BOX OVERLAY ROW 8 COLUMN 5 FRAME f_oper_esto SIDE-LABELS.

FORM SKIP(1)
     b_oper_cred_alcada AT 01   
     HELP "<ESPACO> Marcar/Desmarcar <F4> Retornar"
     WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_oper_cred_alcada SIDE-LABELS.

FORM SKIP(1)
     b_oper_cred_cmtlocal AT 01   
     HELP "<ESPACO> Marcar/Desmarcar <F4> Retornar"
     WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_oper_cred_cmtlocal SIDE-LABELS.

FORM SKIP(1)
     b_oper_esto_alcada AT 01  
     HELP "<ESPACO> Marcar/Desmarcar <F4> Retornar"
     WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_oper_esto_alcada SIDE-LABELS.

       
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  glb_cdcooper = 3 THEN
    ASSIGN glb_cddopcao:HELP = "Informe a opcao desejada (A, B, C, D, I, L, M, N, S, T, V ou X)".

ELSE
    ASSIGN glb_cddopcao:HELP = "Informe a opcao desejada (A, B, C, D, I, L, M, N, S, T ou V)".
                      
ASSIGN glb_cddopcao = "C"
       ant_cddopcao = glb_cddopcao.

VIEW FRAME f_moldura.

PAUSE(0).
               
DO WHILE TRUE:
                 
   RUN fontes/inicia.p.

   IF   glb_cdcooper <> 1 AND 
        glb_cdcooper <> 3 THEN DO:

       IF glb_cddepart = 18  OR   /* SUPORTE  */
          glb_cddepart =  7  OR   /* CONTROLE */
          glb_cddepart =  1  OR   /* CANAIS   */
          glb_cddepart = 20  THEN /* TI       */
        ASSIGN flg_altdepto = YES.
   ELSE 
        ASSIGN flg_altdepto = NO.
   END.
   ELSE DO:
       IF glb_cddepart = 18  OR   /* SUPORTE  */
          glb_cddepart = 20  THEN /* TI       */
           ASSIGN flg_altdepto = YES.
       ELSE 
           ASSIGN flg_altdepto = NO.
   END.
           
   NEXT-PROMPT tel_cdoperad WITH FRAME f_operad.

   glb_cddopcao = ant_cddopcao.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      HIDE FRAME f_oper_cred.
           
      UPDATE glb_cddopcao WITH FRAME f_operad.
      
      IF   glb_cdcooper = 3  THEN
           DO:
              IF   NOT CAN-DO("A,B,C,D,I,L,M,N,S,T,V,X",glb_cddopcao)  THEN
                   DO:
                       ASSIGN glb_cdcritic = 014.
                       RUN fontes/critic.p.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                       NEXT.  
                   END.
           END.
      ELSE
           DO:
               IF  NOT CAN-DO("A,B,C,D,I,L,M,N,S,T,V",glb_cddopcao)    THEN
                   DO: 
                       ASSIGN glb_cdcritic = 014.
                       RUN fontes/critic.p.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0. 
                       NEXT.
                   END.
           END.
      
      IF   glb_cddopcao <> "D"   AND
           glb_cddopcao <> "N" THEN
           UPDATE tel_cdoperad WITH FRAME f_operad
          
           EDITING:

              READKEY.
          
              IF   LASTKEY = KEYCODE("F7") THEN
                   DO:
                       IF   FRAME-FIELD = "tel_cdoperad" THEN
                            DO:
                                RUN fontes/zoom_operador.p 
                                                (INPUT glb_cdcooper,
                                                 OUTPUT tel_cdoperad).
                                DISPLAY tel_cdoperad WITH FRAME f_operad.
                            END.
              
                   END.
              ELSE
                   APPLY LASTKEY.
           
           END.  /*  Fim do EDITING  */

      ant_cddopcao = glb_cddopcao.
      
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */
   
   PAUSE 0.
      
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "OPERAD"   THEN
                 DO:
                     HIDE FRAME f_operad.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.
        
   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   glb_cdcritic = 0.

   FIND FIRST b-crapope WHERE b-crapope.cdcooper = glb_cdcooper
                        AND   b-crapope.cdoperad = glb_cdoperad
                        NO-LOCK NO-ERROR.

   IF  AVAIL b-crapope THEN
       ASSIGN glb_cddepart = b-crapope.cddepart.


   /*alteracao de registro */
   IF   glb_cddopcao = "A"   THEN
        Opcao_A:
        DO WHILE TRUE:

           FIND crapope WHERE crapope.cdcooper = glb_cdcooper  AND
                              crapope.cdoperad = tel_cdoperad
                              NO-LOCK NO-ERROR.

           IF   NOT AVAILABLE crapope   THEN
                DO:
                    glb_cdcritic = 67.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    LEAVE.
                END.
                          
		   /* Se não for cooperativa 1, nem 3 ... */
		   IF   glb_cdcooper <> 1 AND 
                glb_cdcooper <> 3 THEN DO:
		                  
           /* Nao permitir filiadas alterar operadores cecred */
           IF   glb_cddepart <> 20  AND   /* TI                  */
                glb_cddepart <> 18  AND   /* SUPORTE             */
                glb_cddepart <>  1  AND   /* CANAIS              */
                glb_cddepart <>  8  AND   /* COORD.ADM/FINANCEIRO*/
                glb_cddepart <>  9  THEN  /* COORD.PRODUTOS      */
                DO:
                    IF   AVAIL crapope THEN                
                         IF   crapope.cddepart = 20 OR    /* TI                  */
                              crapope.cddepart = 18 OR    /* SUPORTE             */
                              crapope.cddepart =  1 OR    /* CANAIS              */
                              crapope.cddepart =  8 OR    /* COORD.ADM/FINANCEIRO*/
                              crapope.cddepart =  9 THEN  /* COORD.PRODUTOS      */
                              DO:
                                  ASSIGN glb_cdcritic = 527.
                                  RUN fontes/critic.p.
                                  MESSAGE glb_dscritic.
                                  glb_cdcritic = 0.
                                  LEAVE.
                              END.
                END.
		   END.
		   ELSE DO:
		       /* Nao permitir filiadas alterar operadores cecred */
               IF   glb_cddepart <> 20  AND   /* TI                  */
                    glb_cddepart <> 18  THEN  /* SUPORTE             */
                DO:
                    IF   AVAIL crapope THEN                
                             IF   crapope.cddepart = 20 OR    /* TI                  */
                                  crapope.cddepart = 18 THEN  /* SUPORTE             */
                              DO:
                                  ASSIGN glb_cdcritic = 527.
                                  RUN fontes/critic.p.
                                  MESSAGE glb_dscritic.
                                  glb_cdcritic = 0.
                                  LEAVE.
                              END.
                END.
		   END.
                         
           /* Buscar descriçao do departamento */
           FIND FIRST crapdpo 
                WHERE crapdpo.cdcooper = glb_cdcooper 
                  AND crapdpo.cddepart = crapope.cddepart
                  NO-LOCK NO-ERROR.
                         
           ASSIGN tel_nmoperad = crapope.nmoperad
                  tel_nvoperad = ENTRY(crapope.nvoperad,aux_nvoperad)
                  tel_flgperac = crapope.flgperac
                  tel_tpoperad = ENTRY(crapope.tpoperad,aux_tpoperad)
                  tel_dssitope = ENTRY(crapope.cdsitope,aux_dssitope)
                  tel_dsdepart = IF avail crapdpo THEN 
                                   crapdpo.dsdepart 
                                 ELSE "" 
                  tel_cddepart = crapope.cddepart
                  tel_cdagenci = crapope.cdagenci
                  tel_cdpactra = crapope.cdpactra
                  tel_flgdopgd = crapope.flgdopgd
                  tel_flgacres = crapope.flgacres
                  tel_vlpagchq = crapope.vlpagchq
                  tel_flgdonet = crapope.flgdonet
                  tel_insaqesp = crapope.insaqesp
                  tel_cdcomite = crapope.cdcomite
                  tel_vlalccre = crapope.vlapvcre
                  tel_vlapvcap = crapope.vlapvcap
                  tel_flgutcrm = crapope.flgutcrm

                  log_nmoperad = tel_nmoperad
                  log_nvoperad = tel_nvoperad
                  log_flgperac = tel_flgperac
                  log_tpoperad = tel_tpoperad
                  log_cdagenci = tel_cdagenci
                  log_flgdopgd = tel_flgdopgd
                  log_flgdonet = tel_flgdonet
                  log_insaqesp = tel_insaqesp
                  log_flgcarta = tel_flgcarta     
                  log_flgacres = tel_flgacres
                  log_vlapvcap = tel_vlapvcap
                  log_flgutcrm = tel_flgutcrm
                                               
                  aux_inposniv = crapope.nvoperad
                  aux_inpostip = crapope.tpoperad.
 
           FIND FIRST crapcrm WHERE crapcrm.cdcooper = glb_cdcooper      AND
                                    crapcrm.nrdconta = INT(tel_cdoperad) AND
                                    crapcrm.tptitcar = 9
                                    NO-LOCK NO-ERROR.
           
           /* Para nao confundir na tela caso valor da Flag alterado 
              anteriormente */
           
           RUN atualiza_dscomite.
           
           DISPLAY tel_nmoperad tel_nvoperad tel_flgperac tel_tpoperad 
                   tel_flgcarta tel_flgacres tel_dssitope tel_cddepart
                   tel_dsdepart tel_cdagenci tel_cdpactra
                   tel_flgdonet tel_flgdopgd tel_vlpagchq tel_insaqesp
                   tel_cdcomite WHEN crapcop.flgcmtlc
                   tel_dscomite WHEN crapcop.flgcmtlc
                   tel_vlalccre tel_vlapvcap tel_flgutcrm
                   WITH FRAME f_operad.

           UPDATE tel_nmoperad                     
                  tel_nvoperad 
                  tel_tpoperad WHEN NOT AVAIL crapcrm
                  tel_flgcarta WHEN NOT AVAIL crapcrm
                  tel_cdagenci  /*Somente op. CEDRED alteram este campo*/
                  tel_flgdonet 
                  tel_insaqesp
                  tel_flgdopgd
                  tel_flgacres WHEN tel_flgdopgd = TRUE
                  WITH FRAME f_operad   
          
           EDITING:
           
              READKEY.
                            
              IF   FRAME-FIELD = "tel_nvoperad"   THEN
                   DO:
                       IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"      OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
                            DO:
                                IF aux_inposniv > NUM-ENTRIES(aux_nvoperad) THEN
                                   aux_inposniv = NUM-ENTRIES(aux_nvoperad).
                    
                                aux_inposniv = aux_inposniv - 1.

                                IF   aux_inposniv = 0   THEN
                                     aux_inposniv = NUM-ENTRIES(aux_nvoperad).
                        
                                tel_nvoperad = ENTRY(aux_inposniv,aux_nvoperad).
                      
                                DISPLAY tel_nvoperad WITH FRAME f_operad.
                            END.
                       ELSE
                       IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
                            DO:
                                aux_inposniv = aux_inposniv + 1.

                                IF aux_inposniv > NUM-ENTRIES(aux_nvoperad) THEN
                                   aux_inposniv = 1.

                                tel_nvoperad = ENTRY(aux_inposniv,aux_nvoperad).
 
                                DISPLAY tel_nvoperad WITH FRAME f_operad.
                            END.
                       ELSE
                       IF   KEYFUNCTION(LASTKEY) = "RETURN"   OR
                            KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                            KEYFUNCTION(LASTKEY) = "GO"       THEN
                            DO:
                                APPLY LASTKEY.
                            END.
                       ELSE
                       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                            APPLY LASTKEY.
                   END.
              ELSE
              IF   FRAME-FIELD = "tel_tpoperad"   THEN
                   DO:
                       IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"      OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
                            DO:
                                IF aux_inpostip > NUM-ENTRIES(aux_tpoperad) THEN
                                   aux_inpostip = NUM-ENTRIES(aux_tpoperad).
                    
                                aux_inpostip = aux_inpostip - 1.

                                IF   aux_inpostip = 0   THEN
                                     aux_inpostip = NUM-ENTRIES(aux_tpoperad).
                        
                                tel_tpoperad = ENTRY(aux_inpostip,aux_tpoperad).
                      
                                DISPLAY tel_tpoperad WITH FRAME f_operad.
                            END.
                       ELSE
                       IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                            KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
                            DO:
                                aux_inpostip = aux_inpostip + 1.

                                IF aux_inpostip > NUM-ENTRIES(aux_tpoperad) THEN
                                   aux_inpostip = 1.

                                tel_tpoperad = ENTRY(aux_inpostip,aux_tpoperad).
 
                                DISPLAY tel_tpoperad WITH FRAME f_operad.
                            END.
                       ELSE
                       IF   KEYFUNCTION(LASTKEY) = "RETURN"   OR
                            KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                            KEYFUNCTION(LASTKEY) = "GO"       THEN
                            DO:
                                APPLY LASTKEY.
                            END.
                       ELSE
                       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                            APPLY LASTKEY.
                   END.
              ELSE
                   APPLY LASTKEY.
           
           END.  /*  Fim do EDITING  */

           IF  flg_altdepto  THEN
           DO:
            DO WHILE TRUE:
            
              UPDATE tel_cddepart WITH FRAME f_operad
              EDITING:
                READKEY.
                  IF  LASTKEY = KEYCODE("F7") THEN
                      DO:
                          IF  FRAME-FIELD = "tel_cddepart" THEN
                              DO:
                                  RUN fontes/zoom_departamento.p 
                                                  (INPUT glb_cdcooper,
                                                   OUTPUT tel_dsdepart,
                                                   OUTPUT tel_cddepart
                                                   ).
                                  DISPLAY tel_dsdepart
                                          tel_cddepart 
                                          WITH FRAME f_operad.
                              END.
                      END.
                  ELSE
                      APPLY LASTKEY.

              END.  /*  Fim do EDITING  */  
              IF tel_cddepart <> 0 THEN
              DO:
                FIND crapdpo WHERE crapdpo.cdcooper = glb_cdcooper AND 
                                   crapdpo.cddepart = tel_cddepart AND 
                                   crapdpo.insitdpo = 1 NO-LOCK NO-ERROR.
                                   
                IF AVAILABLE crapdpo THEN
                DO:
                  
                  ASSIGN tel_dsdepart = crapdpo.dsdepart.
                  
                  DISPLAY tel_dsdepart
                          tel_cddepart 
                          WITH FRAME f_operad.
                  LEAVE.
                END.  
                ELSE
                DO:
                  MESSAGE "DEPARTAMENTO NAO CADASTRADO OU INATIVO.".   
                  NEXT.
                END.                
              END.
              ELSE
                LEAVE.
            END. /* fim do while*/ 
           END.

           IF  crapope.cddepart = 17 AND /* SISCAIXA */
               tel_nvoperad     <> "OPERADOR"  THEN
               DO:
                    MESSAGE 'Nivel do Operador deve ser "OPERADOR".'.
                    BELL.
                    ASSIGN tel_nvoperad =  ENTRY(crapope.nvoperad,aux_nvoperad).
                    DISPLAY tel_nvoperad WITH FRAME f_operad.
                    PAUSE 3 NO-MESSAGE.
                    LEAVE.
               END. 
           
           DO TRANSACTION ON ENDKEY UNDO, LEAVE
                          ON ERROR  UNDO, LEAVE:
              
               FIND crapope WHERE crapope.cdcooper = glb_cdcooper  AND
                                  crapope.cdoperad = tel_cdoperad
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   NOT AVAILABLE crapope   THEN
                    IF   LOCKED crapope   THEN
                         DO:
                             MESSAGE "Operador ja esta sendo alterado.".
                             PAUSE 3 NO-MESSAGE.
                             UNDO, LEAVE Opcao_A.
                         END.
               
               ASSIGN crapope.nmoperad = CAPS(tel_nmoperad)
                      crapope.nvoperad = aux_inposniv
                      crapope.flgperac = tel_flgperac
                      crapope.tpoperad = aux_inpostip
                      crapope.cdagenci = tel_cdagenci
                      crapope.flgdonet = tel_flgdonet
                      crapope.insaqesp = tel_insaqesp
                      crapope.cddepart = tel_cddepart.
               
               IF   log_nmoperad <> tel_nmoperad   THEN
                    RUN gera_log ("Nome Completo",log_nmoperad,tel_nmoperad).
               
               IF   log_nvoperad <> tel_nvoperad   THEN
                    RUN gera_log ("Nivel do Operador",log_nvoperad,tel_nvoperad).
               
               IF   log_tpoperad <> tel_tpoperad   THEN
                    RUN gera_log ("Tipo de Operador",log_tpoperad,tel_tpoperad).
               
               IF   log_cdagenci <> tel_cdagenci   THEN
                    RUN gera_log ("PA do operador",log_cdagenci,tel_cdagenci).
               
               IF   log_flgdonet <> tel_flgdonet   THEN
                    RUN gera_log ("Acessar Sistema Ayllos INTRANET",
                                  STRING(log_flgdonet,"Sim/Nao"),
                                  STRING(tel_flgdonet,"Sim/Nao")).
               
               IF   log_insaqesp <> tel_insaqesp   THEN
                    RUN gera_log ("Libera Saque Especie",
                                  STRING(log_insaqesp,"Sim/Nao"),
                                  STRING(tel_insaqesp,"Sim/Nao")).
               
               IF   log_flgperac <> tel_flgperac  THEN
                    RUN gera_log ("Acessar contas restritas",
                                  STRING(log_flgperac,"Sim/Nao"),
                                  STRING(tel_flgperac,"Sim/Nao")).
                  
               IF   aux_inpostip = 1 AND tel_flgcarta   THEN
                    DO:
                        MESSAGE "Emissao nao permitida para tipo TERMINAL".
                        UNDO, LEAVE Opcao_A.
                    END.
                  
               IF   tel_flgcarta AND glb_cdcooper < 3   THEN
                    DO:
                        CREATE crapcrm. 
               
                        RUN fontes/abreviar.p 
                             (INPUT tel_nmoperad, 28, OUTPUT crapcrm.nmtitcrd).
                        
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
                        /* Busca a proxima sequencia do campo crapldt.nrsequen */
                        RUN STORED-PROCEDURE pc_sequence_progress
                        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                                            ,INPUT "NRSEQCAR"
                                                            ,INPUT STRING(glb_cdcooper)
                                                            ,INPUT "N"
                                                            ,"").
            
                        CLOSE STORED-PROC pc_sequence_progress
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
                        ASSIGN aux_nrseqcar = INTE(pc_sequence_progress.pr_sequence)
                                              WHEN pc_sequence_progress.pr_sequence <> ?.

                        ASSIGN crapcrm.nrseqcar = aux_nrseqcar
                               crapcrm.nmtitcrd = CAPS(crapcrm.nmtitcrd)
                               crapcrm.cdsitcar = 1
                               crapcrm.dtcancel = ?
                               crapcrm.dtemscar = ?
                               crapcrm.tpusucar = 1                               
                   
                               crapcrm.nrdconta = INT(crapope.cdoperad)
                               crapcrm.dtvalcar = DATE(MONTH(glb_dtmvtolt),
                                                       28, YEAR(glb_dtmvtolt) +
                                                       3) + 5
               
                               crapcrm.dtvalcar = crapcrm.dtvalcar - 
                                                  DAY(crapcrm.dtvalcar)
               
                               crapcrm.nrcartao = DECIMAL("9" + 
                                              STRING(crapcrm.nrseqcar,"999999") +
                                              STRING(crapcrm.nrdconta,"99999999") +
                                              STRING(crapcrm.tpusucar,"9"))
               
                               crapcrm.nrviacar = 1
                               crapcrm.tpcarcta = 9
                               crapcrm.tptitcar = 9
                               crapcrm.dssencar = "NAOTARIFA"
               
                               crapcrm.dttransa = glb_dtmvtolt
                               crapcrm.hrtransa = TIME
                               crapcrm.cdoperad = glb_cdoperad
                               crapcrm.cdcooper = glb_cdcooper.
                    END.
              
               UPDATE tel_vlapvcap WITH FRAME f_operad.

               UPDATE tel_flgutcrm WITH FRAME f_operad.

               ASSIGN crapope.flgdopgd = tel_flgdopgd
                      crapope.flgacres = tel_flgacres
                      crapope.vlapvcap = tel_vlapvcap
                      crapope.flgutcrm = tel_flgutcrm.       
                      
               IF   log_flgdopgd <> tel_flgdopgd   THEN
                    RUN gera_log ("Acessar Sistema de Relacionamento",
                                   STRING(log_flgdopgd,"Sim/Nao"),
                                   STRING(tel_flgdopgd,"Sim/Nao")).
               
               IF   log_flgacres <> tel_flgacres   THEN
                    RUN gera_log ("Acesso Restrito ao PA",
                                   STRING(log_flgacres,"Sim/Nao"),
                                   STRING(tel_flgacres,"Sim/Nao")).
               
               IF   log_flgcarta <> tel_flgcarta   THEN
                    RUN gera_log ("Gerar Cartao Magnetico",
                                   STRING(log_flgcarta,"Sim/Nao"),
                                   STRING(tel_flgcarta,"Sim/Nao")).
               
               IF   log_vlapvcap <> tel_vlapvcap THEN
                    RUN gera_log ("Vlr da Alcada de Captacao",
                                   STRING(log_vlapvcap),
                                   STRING(tel_vlapvcap)).

               IF   log_flgutcrm <> tel_flgutcrm THEN
                    RUN gera_log ("Acesso CRM",
                                   STRING(log_flgutcrm,"Sim/Nao"),
                                   STRING(tel_flgutcrm,"Sim/Nao")).

               RUN limpa.
              
               FIND CURRENT crapope NO-LOCK NO-ERROR.
               RELEASE crapope.

               FIND CURRENT craptab NO-LOCK NO-ERROR.
               RELEASE craptab.

           END. /*  Fim da transacao  */

           LEAVE.

        END.  /* Do While */
   ELSE
   IF   glb_cddopcao = "B"   OR
        glb_cddopcao = "L"   THEN
        Opcao_BL:
        DO WHILE TRUE:
          
           FIND crapope WHERE crapope.cdcooper = glb_cdcooper         AND
                              crapope.cdoperad = tel_cdoperad
                              NO-LOCK NO-ERROR.
                              
           IF   NOT AVAILABLE crapope   THEN
                DO:
                    glb_cdcritic = 67.
                    RUN fontes/critic.p.
                    RUN limpa.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    LEAVE.
                END.
 
           /* Buscar descriçao do departamento */
           FIND FIRST crapdpo
                WHERE crapdpo.cdcooper = glb_cdcooper 
                  AND crapdpo.cddepart = crapope.cddepart
                  NO-LOCK NO-ERROR.
                      
           
           ASSIGN tel_nmoperad = crapope.nmoperad
                  tel_nvoperad = ENTRY(crapope.nvoperad,aux_nvoperad)
                  tel_flgperac = crapope.flgperac
                  tel_tpoperad = ENTRY(crapope.tpoperad,aux_tpoperad)
                  tel_dssitope = ENTRY(crapope.cdsitope,aux_dssitope)
                  tel_cddepart = crapope.cddepart
                  tel_dsdepart = IF avail crapdpo THEN 
                                     crapdpo.dsdepart 
                                   ELSE "" 
                  tel_cdagenci = crapope.cdagenci
                  tel_cdpactra = crapope.cdpactra
                  tel_flgcarta = FALSE
                  tel_flgdopgd = crapope.flgdopgd
                  tel_flgacres = crapope.flgacres
                  tel_vlpagchq = crapope.vlpagchq
                  tel_flgdonet = crapope.flgdonet
                  tel_insaqesp = crapope.insaqesp
                  tel_cdcomite = crapope.cdcomite
                  tel_vlalccre = crapope.vlapvcre
                  tel_vlapvcap = crapope.vlapvcap       
                  tel_flgutcrm = crapope.flgutcrm.       

           RUN atualiza_dscomite.
           
           DISPLAY tel_nmoperad tel_nvoperad tel_flgperac tel_tpoperad 
                   tel_dssitope tel_flgcarta tel_cdagenci tel_cdpactra
                   tel_flgdopgd tel_flgacres tel_vlpagchq
                   tel_flgdonet tel_insaqesp tel_cdcomite WHEN crapcop.flgcmtlc
                   tel_dscomite WHEN crapcop.flgcmtlc
                   tel_vlalccre tel_vlapvcap tel_flgutcrm
                   WITH FRAME f_operad.
 
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              ASSIGN aux_confirma = "N"
                     glb_cdcritic = 78.
       
              RUN fontes/critic.p.
              glb_cdcritic = 0.
              BELL.
              MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */
           
           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                aux_confirma <> "S" THEN
                DO:
                    glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    glb_cdcritic = 0.
                    BELL.
                    MESSAGE glb_dscritic.
                    LEAVE Opcao_BL.
                END.

           DO TRANSACTION ON ENDKEY UNDO, LEAVE
                          ON ERROR  UNDO, LEAVE:
          
              FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                 crapope.cdoperad = tel_cdoperad
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE crapope   THEN
                   IF   LOCKED crapope   THEN
                        DO:
                            MESSAGE "Operador ja esta sendo alterado.".
                            PAUSE 3 NO-MESSAGE.
                            UNDO, LEAVE Opcao_BL.
                        END.
              
              IF   glb_cddopcao = "B"   THEN
                   ASSIGN crapope.cdsitope = 2
                          tel_dssitope = ENTRY(crapope.cdsitope,aux_dssitope).
              ELSE
              IF   glb_cddopcao = "L"   THEN
                   ASSIGN crapope.cdsitope = 1
                          tel_dssitope = ENTRY(crapope.cdsitope,aux_dssitope).

              FIND CURRENT crapope NO-LOCK NO-ERROR.

              RELEASE crapope.
              
           END. /*  Fim da transacao  */
              
           DISPLAY tel_dssitope WITH FRAME f_operad.

           LEAVE.

        END.  /* Do While */
   ELSE
   IF   glb_cddopcao = "C"   THEN
        DO:
            FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                               crapope.cdoperad = tel_cdoperad NO-LOCK NO-ERROR.
 
            IF   NOT AVAILABLE crapope   THEN
                 DO:
                     glb_cdcritic = 67.
                     RUN fontes/critic.p.
                     RUN limpa.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.

            /* Buscar descriçao do departamento */
            FIND FIRST crapdpo 
                WHERE crapdpo.cdcooper = glb_cdcooper 
                  AND crapdpo.cddepart = crapope.cddepart
                   NO-LOCK NO-ERROR.
            
            ASSIGN tel_nmoperad = crapope.nmoperad
                   tel_nvoperad = ENTRY(crapope.nvoperad,aux_nvoperad)
                   tel_flgperac = crapope.flgperac
                   tel_tpoperad = ENTRY(crapope.tpoperad,aux_tpoperad)
                   tel_dssitope = ENTRY(crapope.cdsitope,aux_dssitope)
                   tel_cddepart = crapope.cddepart
                   tel_dsdepart = IF avail crapdpo THEN 
                                     crapdpo.dsdepart 
                                   ELSE "" 
                   tel_cdagenci = crapope.cdagenci
                   tel_cdpactra = crapope.cdpactra
                   tel_flgdopgd = crapope.flgdopgd
                   tel_flgacres = crapope.flgacres
                   tel_vlpagchq = crapope.vlpagchq
                   tel_vllimted = crapope.vllimted
                   tel_flgdonet = crapope.flgdonet
                   tel_insaqesp = crapope.insaqesp
                   tel_cdcomite = crapope.cdcomite
                   tel_vlalccre = crapope.vlapvcre
                   tel_vlapvcap = crapope.vlapvcap
                   tel_flgutcrm = crapope.flgutcrm.
                   
            RUN atualiza_dscomite.
            
            DISPLAY tel_nmoperad tel_nvoperad tel_flgperac tel_tpoperad 
                    tel_dssitope tel_cddepart tel_dsdepart tel_cdagenci 
                    tel_cdpactra tel_flgdopgd tel_flgacres
                    tel_vlpagchq tel_vllimted
                    tel_flgdonet tel_insaqesp
                    tel_cdcomite WHEN crapcop.flgcmtlc
                    tel_dscomite WHEN crapcop.flgcmtlc
                    tel_vlalccre tel_vlapvcap tel_flgutcrm
                    WITH FRAME f_operad.
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:                 
            FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                               crapope.cdoperad = tel_cdoperad
                               NO-LOCK NO-ERROR.
                              
            IF   AVAILABLE crapope   THEN
                 DO:
                     RUN limpa.
                     MESSAGE "Operador ja cadastrado".
                     PAUSE 3.
                     LEAVE.
                 END.
            
            ASSIGN tel_nmoperad = ""
                   tel_nvoperad = ENTRY(1,aux_nvoperad)
                   tel_flgperac = FALSE
                   tel_tpoperad = ENTRY(1,aux_tpoperad)
                   tel_dssitope = ENTRY(1,aux_dssitope)
                   tel_cdagenci = 0
                   tel_cdpactra = 0
                   tel_flgdopgd = FALSE
                   tel_flgacres = FALSE
                   tel_flgdonet = TRUE
                   tel_insaqesp = FALSE
                   tel_cddepart = 0
                   tel_dsdepart = ""
                   tel_vlapvcap = 0
                   tel_flgutcrm = FALSE
                   aux_inposniv = 1
                   aux_inpostip = 1.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_nmoperad 
                      tel_nvoperad 
                      tel_tpoperad 
                      tel_flgcarta
                      tel_cdagenci /*Somente op.CECRED podem alterar o campo*/
                      tel_flgdonet
                      tel_insaqesp
                      WITH FRAME f_operad
                  
               EDITING:
           
                  READKEY.
                                    
                  IF   FRAME-FIELD = "tel_nvoperad"   THEN
                       DO:
                           IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"      OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
                                DO:
                                    IF   aux_inposniv > 
                                         NUM-ENTRIES(aux_nvoperad) THEN
                                         aux_inposniv = 
                                             NUM-ENTRIES(aux_nvoperad).
                    
                                    aux_inposniv = aux_inposniv - 1.

                                    IF   aux_inposniv = 0   THEN
                                         aux_inposniv =
                                             NUM-ENTRIES(aux_nvoperad).
                        
                                    tel_nvoperad = 
                                        ENTRY(aux_inposniv,aux_nvoperad).
                      
                                    DISPLAY tel_nvoperad WITH FRAME f_operad.
                                END.
                           ELSE
                           IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
                                DO:
                                     aux_inposniv = aux_inposniv + 1.

                                     IF   aux_inposniv > 
                                          NUM-ENTRIES(aux_nvoperad) THEN
                                          aux_inposniv = 1.

                                     tel_nvoperad = 
                                         ENTRY(aux_inposniv,aux_nvoperad).
 
                                     DISPLAY tel_nvoperad WITH FRAME f_operad.
                                END.
                           ELSE
                           IF   KEYFUNCTION(LASTKEY) = "RETURN"   OR
                                KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                                KEYFUNCTION(LASTKEY) = "GO"       THEN
                                DO:
                                    APPLY LASTKEY.
                                END.
                           ELSE
                           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                APPLY LASTKEY.
                       END.
                  ELSE
                  IF   FRAME-FIELD = "tel_tpoperad"   THEN
                       DO:
                           IF   KEYFUNCTION(LASTKEY) = "CURSOR-UP"      OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
                                DO:
                                    IF   aux_inpostip > 
                                         NUM-ENTRIES(aux_tpoperad) THEN
                                         aux_inpostip = 
                                             NUM-ENTRIES(aux_tpoperad).
                    
                                    aux_inpostip = aux_inpostip - 1.

                                    IF   aux_inpostip = 0   THEN
                                         aux_inpostip = 
                                             NUM-ENTRIES(aux_tpoperad).
                        
                                    tel_tpoperad = 
                                        ENTRY(aux_inpostip,aux_tpoperad).
                      
                                    DISPLAY tel_tpoperad WITH FRAME f_operad.
                                END.
                           ELSE
                           IF   KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                                KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
                                DO:
                                    aux_inpostip = aux_inpostip + 1.
                             
                                    IF   aux_inpostip > 
                                         NUM-ENTRIES(aux_tpoperad) THEN
                                         aux_inpostip = 1.

                                    tel_tpoperad = 
                                        ENTRY(aux_inpostip,aux_tpoperad).
 
                                    DISPLAY tel_tpoperad WITH FRAME f_operad.
                                END.
                           ELSE
                           IF   KEYFUNCTION(LASTKEY) = "RETURN"   OR
                                KEYFUNCTION(LASTKEY) = "BACK-TAB" OR
                                KEYFUNCTION(LASTKEY) = "GO"       THEN
                                DO:
                                    APPLY LASTKEY.
                                END.
                           ELSE
                           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                APPLY LASTKEY.
                       END.
                  ELSE
                       APPLY LASTKEY.
           
               END.  /*  Fim do EDITING  */

               UPDATE tel_flgdopgd WITH FRAME f_operad.
               
               IF   tel_flgdopgd = TRUE  THEN
                    UPDATE tel_flgacres WITH FRAME f_operad.

               DO  WHILE TRUE:
                  UPDATE tel_cddepart WITH FRAME f_operad
                  EDITING:
                    READKEY.
                      IF  LASTKEY = KEYCODE("F7") THEN
                          DO:
                              IF  FRAME-FIELD = "tel_cddepart" THEN
                                  DO:
                                      RUN fontes/zoom_departamento.p 
                                                      (INPUT glb_cdcooper,
                                                       OUTPUT tel_dsdepart,
                                                       OUTPUT tel_cddepart).
                                      DISPLAY tel_dsdepart 
                                              tel_cddepart  
                                              WITH FRAME f_operad.
                                  END.
                          END.
                      ELSE
                          APPLY LASTKEY.

                  END.  /*  Fim do EDITING  */    
                  IF tel_cddepart <> 0 THEN
                  DO:
                    FIND crapdpo WHERE crapdpo.cdcooper = glb_cdcooper AND 
                                       crapdpo.cddepart = tel_cddepart AND 
                                       crapdpo.insitdpo = 1 NO-LOCK NO-ERROR.
                    IF AVAILABLE crapdpo THEN
                    DO:
                  
                      ASSIGN tel_dsdepart = crapdpo.dsdepart.
                      
                      DISPLAY tel_dsdepart
                              tel_cddepart 
                              WITH FRAME f_operad.
                      LEAVE.
                    END. 
                    ELSE
                    DO:
                      MESSAGE "DEPARTAMENTO NAO CADASTRADO OU INATIVO.".   
                      NEXT.
                    END.                
                  END.
                  ELSE
                    LEAVE.
               END. /* fim do while*/ 

               IF   aux_inpostip = 1   AND   tel_flgcarta   THEN
                    DO:
                        MESSAGE "Emissao nao permitida para tipo TERMINAL".
                        NEXT.
                    END.

               IF  tel_cdoperad =  "888"        AND 
                   tel_nvoperad <> "OPERADOR"   THEN
                   DO:
                        MESSAGE 'Nivel do Operador deve ser "OPERADOR".'.
                        BELL.
                        NEXT.
                   END. 
               
               UPDATE tel_vlapvcap WITH FRAME f_operad.

               UPDATE tel_flgutcrm WITH FRAME f_operad.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.
       
                  RUN fontes/critic.p.
                  glb_cdcritic = 0.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */
           
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S" THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        glb_cdcritic = 0.
                        BELL.
                        MESSAGE glb_dscritic.
                        NEXT.
                    END.

               MESSAGE "Aguarde...".

               DO TRANSACTION ON ERROR UNDO, LEAVE:
           
                  CREATE crapope.

                  ASSIGN crapope.cdoperad = tel_cdoperad
                         crapope.cddsenha = tel_cdoperad
                         crapope.cdsitope = 1
                         crapope.dtaltsnh = glb_dtmvtolt - 60
                         crapope.nmoperad = CAPS(tel_nmoperad)
                         crapope.nrdedias = 30
                         crapope.nvoperad = aux_inposniv
                         crapope.flgperac = tel_flgperac
                         crapope.tpoperad = aux_inpostip
                         crapope.cdcooper = glb_cdcooper
                         crapope.cdagenci = tel_cdagenci
                         crapope.cdpactra = tel_cdagenci
                         crapope.flgdopgd = tel_flgdopgd
                         crapope.flgacres = tel_flgacres
                         crapope.flgdonet = tel_flgdonet
                         crapope.insaqesp = tel_insaqesp
                         crapope.cddepart = tel_cddepart
                         crapope.vlapvcap = tel_vlapvcap
                         crapope.flgutcrm = tel_flgutcrm.

                  IF   CAN-DO("1,3",STRING(crapope.tpoperad))   THEN 
                       FOR EACH craptel WHERE 
                                craptel.cdcooper = glb_cdcooper   AND
                                craptel.flgtelbl = TRUE           AND
                                craptel.flgteldf = TRUE           NO-LOCK:

                           /* Permissao Progrid */
                           IF  craptel.idsistem = 2  THEN 
                           DO:
                               IF NOT CAN-FIND(
                                  FIRST b-crapace WHERE 
                                  b-crapace.cdcooper = craptel.cdcooper AND
                                  b-crapace.nmdatela = craptel.nmdatela AND
                                  b-crapace.nmrotina = craptel.nmrotina AND
                                  b-crapace.cddopcao = "C"              AND
                                  b-crapace.cdoperad = crapope.cdoperad AND
                                  b-crapace.idambace = 3 NO-LOCK) THEN
                                  DO:
                                     CREATE crapace.
                                     ASSIGN crapace.nmdatela = craptel.nmdatela
                                            crapace.cddopcao = "C"
                                            crapace.cdoperad = crapope.cdoperad
                                            crapace.cdcooper = craptel.cdcooper 
                                            crapace.nmrotina = craptel.nmrotina
                                            crapace.idambace = 3.
                                  END.
                                NEXT. 
                           END.
                           
                           /* Permissao Ayllos - 0 Todos, 1 Caracter, 2 Web */

                           /* cria caracter */
                           IF craptel.idambtel = 0 OR 
                              craptel.idambtel = 1 THEN
                           DO:
                               IF NOT CAN-FIND(
                                  FIRST b-crapace WHERE 
                                  b-crapace.cdcooper = craptel.cdcooper AND
                                  b-crapace.nmdatela = craptel.nmdatela AND
                                  b-crapace.nmrotina = craptel.nmrotina AND
                                  b-crapace.cddopcao = "C"              AND
                                  b-crapace.cdoperad = crapope.cdoperad AND
                                  b-crapace.idambace = 1 NO-LOCK) THEN
                                  DO:
                                      CREATE crapace.
                                      ASSIGN crapace.nmdatela = craptel.nmdatela
                                             crapace.cddopcao = "C"
                                             crapace.cdoperad = crapope.cdoperad
                                             crapace.cdcooper = craptel.cdcooper 
                                             crapace.nmrotina = craptel.nmrotina
                                             crapace.idambace = 1.    
                                  END.
                           END.

                           /* cria web */
                           IF craptel.idambtel = 0 OR 
                              craptel.idambtel = 2 THEN
                           DO:
                               IF NOT CAN-FIND(
                                  FIRST b-crapace WHERE 
                                        b-crapace.cdcooper = craptel.cdcooper   AND
                                        b-crapace.nmdatela = craptel.nmdatela   AND
                                        b-crapace.nmrotina = craptel.nmrotina   AND
                                        b-crapace.cddopcao = "C"                AND
                                        b-crapace.cdoperad = crapope.cdoperad AND
                                        b-crapace.idambace = 2 NO-LOCK) THEN
                               DO:
                                  CREATE crapace.
                                  ASSIGN crapace.nmdatela = craptel.nmdatela
                                         crapace.cddopcao = "C"
                                         crapace.cdoperad = crapope.cdoperad
                                         crapace.cdcooper = craptel.cdcooper 
                                         crapace.nmrotina = craptel.nmrotina
                                         crapace.idambace = 2. 
                               END.
                           END.

                       END.  /*  Fim do FOR EACH  */

                  IF   tel_flgcarta   AND  
                      (glb_cdcooper < 3   OR    glb_cdcooper = 4)   THEN
                       DO:
                           CREATE crapcrm. 
 
                           RUN fontes/abreviar.p 
                                     (INPUT tel_nmoperad, 28, OUTPUT
                                      crapcrm.nmtitcrd).

                           { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                           /* Busca a proxima sequencia do campo crapldt.nrsequen */
                           RUN STORED-PROCEDURE pc_sequence_progress
                           aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPMAT"
                                                               ,INPUT "NRSEQCAR"
                                                               ,INPUT STRING(glb_cdcooper)
                                                               ,INPUT "N"
                                                               ,"").
                
                           CLOSE STORED-PROC pc_sequence_progress
                           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
                           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                
                           ASSIGN aux_nrseqcar = INTE(pc_sequence_progress.pr_sequence)
                                                 WHEN pc_sequence_progress.pr_sequence <> ?.

                           ASSIGN crapcrm.nrseqcar = aux_nrseqcar
                                  crapcrm.nmtitcrd = CAPS(crapcrm.nmtitcrd)
                                  crapcrm.cdsitcar = 1
                                  crapcrm.dtcancel = ?
                                  crapcrm.dtemscar = ?
                                  crapcrm.tpusucar = 1                                  
                  
                                  crapcrm.nrdconta = INT(crapope.cdoperad)

                                  crapcrm.dtvalcar = DATE(MONTH(glb_dtmvtolt),
                                                          28,
                                                          YEAR(glb_dtmvtolt) +
                                                          3) + 5

                                  crapcrm.dtvalcar = crapcrm.dtvalcar - 
                                                     DAY(crapcrm.dtvalcar)

                                  crapcrm.nrcartao = DECIMAL("9" + 
                                          STRING(crapcrm.nrseqcar,"999999") +
                                          STRING(crapcrm.nrdconta,"99999999") +
                                          STRING(crapcrm.tpusucar,"9"))
           
                                  crapcrm.nrviacar = 1
                                  crapcrm.tpcarcta = 9
                                  crapcrm.tptitcar = 9
                                  crapcrm.dssencar = "NAOTARIFA"
 
                                  crapcrm.dttransa = glb_dtmvtolt
                                  crapcrm.hrtransa = TIME
                                  crapcrm.cdoperad = glb_cdoperad
                                  crapcrm.cdcooper = glb_cdcooper.
                       END.

                    HIDE MESSAGE NO-PAUSE.
                    MESSAGE "Operador criado com sucesso!".
                    PAUSE.

               END.  /*  Fim da transacao  */

               FIND CURRENT crapope NO-LOCK NO-ERROR.
               RELEASE crapope.

               FIND CURRENT craptab NO-LOCK NO-ERROR.
               RELEASE craptab.
               
               HIDE MESSAGE NO-PAUSE.
               CLEAR FRAME f_operad NO-PAUSE.   
               
               LEAVE.
        
            END. /*  Fim do DO WHILE TRUE  */
        END.
   ELSE
   IF   glb_cddopcao = "M"   THEN
        DO:
            
            aux_cdoperad = INTEGER(tel_cdoperad) NO-ERROR.
            IF  ERROR-STATUS:ERROR THEN
                DO:
                    tel_cdoperad = "".
                    MESSAGE "Devido ao seu codigo, nao e possivel solicitar cartao.".
                    NEXT.

                END.

            IF  LENGTH(tel_cdoperad) > 8 THEN
                DO:
                    MESSAGE "Devido ao seu codigo, nao e possivel solicitar cartao.". 
                    NEXT.
                END.
 
            FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                               crapope.cdoperad = tel_cdoperad 
                               NO-LOCK NO-ERROR.
 
            IF   NOT AVAILABLE crapope   THEN
                 DO:
                     glb_cdcritic = 67.
                     RUN fontes/critic.p.
                     RUN limpa.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                 END.

            RUN fontes/carmag.p (INPUT tel_cdoperad, 
                                 INPUT 1, /* inpessoa */
                                 INPUT FALSE).

            RUN fontes/carmag.p (INPUT tel_cdoperad, 
                                 INPUT 1, /* inpessoa */
                                 INPUT TRUE).
        END.
   ELSE 
   IF   glb_cddopcao = "D"   THEN
        DO:
            ASSIGN aux_deoperad = ""
                   aux_nmdeoper = ""
                   aux_paraoper = ""
                   aux_nmparaop = "".
            
            DISPLAY aux_nmdeoper aux_nmparaop WITH FRAME f_duplica.
            UPDATE aux_deoperad aux_paraoper  WITH FRAME f_duplica.    
            
            /* leitura/verificacao do operario DE */
            FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                               crapope.cdoperad = aux_deoperad NO-LOCK NO-ERROR.
                 IF   NOT AVAILABLE crapope   THEN
                      DO:
                          glb_cdcritic = 67.
                          RUN fontes/critic.p.
                          RUN limpa.
                          MESSAGE glb_dscritic.
                          glb_cdcritic = 0.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          ASSIGN aux_nmdeoper = crapope.nmoperad
                                 aux_vlapvcap = crapope.vlapvcap. 
                          DISPLAY aux_nmdeoper WITH FRAME f_duplica.
                      END.            

            /* leitura/verificacao do operario PARA */     
            FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                               crapope.cdoperad = aux_paraoper NO-LOCK NO-ERROR.
                 IF   NOT AVAILABLE crapope   THEN
                      DO:
                          glb_cdcritic = 67.
                          RUN fontes/critic.p.
                          RUN limpa.
                          MESSAGE glb_dscritic.
                          glb_cdcritic = 0.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          aux_nmparaop = crapope.nmoperad.
                          DISPLAY aux_nmparaop WITH FRAME f_duplica.
                      END.  
            
            /* mensagem de confirmacao */
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                ASSIGN aux_confirma = "N"
                       glb_cdcritic = 78.
                RUN fontes/critic.p.
                glb_cdcritic = 0.
                BELL.
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
           
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S" THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     glb_cdcritic = 0.
                     BELL.
                     MESSAGE glb_dscritic.
                     PAUSE.
                     LEAVE. 
                 END. /* fim da mensagem de confirmacao */
            
            
            DO TRANSACTION ON ENDKEY UNDO, LEAVE
                          ON ERROR  UNDO, LEAVE:

                FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                   crapope.cdoperad = aux_paraoper EXCLUSIVE-LOCK.
                ASSIGN crapope.vlapvcap = aux_vlapvcap.
                
                VALIDATE crapope.
                RELEASE  crapope.
              
            END.

            FOR EACH crapace WHERE crapace.cdoperad = aux_deoperad AND
                                   crapace.cdcooper = glb_cdcooper NO-LOCK:
                FIND FIRST b-crapace WHERE 
                           b-crapace.cdcooper = crapace.cdcooper  AND
                           b-crapace.nmdatela = crapace.nmdatela  AND
                           b-crapace.nmrotina = crapace.nmrotina  AND 
                           b-crapace.cddopcao = crapace.cddopcao  AND
                           b-crapace.cdoperad = aux_paraoper      AND
                           b-crapace.idambace = crapace.idambace
                           NO-LOCK NO-ERROR.
                IF  NOT AVAILABLE b-crapace   THEN
                    DO:
                        CREATE b-crapace.
                        BUFFER-COPY crapace EXCEPT cdoperad TO b-crapace.
                        ASSIGN b-crapace.cdoperad = aux_paraoper.
                    END.
            END. /* END FOR EACH */

        END.
   ELSE
   IF   glb_cddopcao = "S"   THEN
       Opcao_S:
       DO  WHILE TRUE:

            FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                               crapope.cdoperad = tel_cdoperad 
                               NO-LOCK NO-ERROR NO-WAIT.
 
            IF   NOT AVAIL crapope THEN
                 DO:
                    glb_cdcritic = 67.
                    RUN fontes/critic.p.
                    RUN limpa.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    LEAVE.
                 END.

            /* Buscar descriçao do departamento */
            FIND FIRST crapdpo
                 WHERE crapdpo.cdcooper = glb_cdcooper 
                   AND crapdpo.cddepart = crapope.cddepart
                    NO-LOCK NO-ERROR.
            
            ASSIGN tel_nmoperad = crapope.nmoperad
                   tel_nvoperad = ENTRY(crapope.nvoperad,aux_nvoperad)
                   tel_flgperac = crapope.flgperac
                   tel_tpoperad = ENTRY(crapope.tpoperad,aux_tpoperad)
                   tel_dssitope = ENTRY(crapope.cdsitope,aux_dssitope)
                   tel_cddepart = crapope.cddepart
                   tel_dsdepart = IF avail crapdpo THEN 
                                     crapdpo.dsdepart 
                                  ELSE ""   
                   tel_cdagenci = crapope.cdagenci
                   tel_cdpactra = crapope.cdpactra
                   tel_flgdopgd = crapope.flgdopgd
                   tel_flgacres = crapope.flgacres
                   tel_vlpagchq = crapope.vlpagchq
                   tel_flgdonet = crapope.flgdonet
                   tel_insaqesp = crapope.insaqesp
                   tel_cdcomite = crapope.cdcomite
                   tel_vlalccre = crapope.vlapvcre
                   tel_vlapvcap = crapope.vlapvcap
                   tel_flgutcrm = crapope.flgutcrm.
                   
            RUN atualiza_dscomite.
            
            DISPLAY tel_nmoperad tel_nvoperad tel_flgperac 
                    tel_tpoperad tel_dssitope 
                    tel_cddepart tel_dsdepart 
                    tel_cdagenci tel_cdpactra
                    tel_flgdopgd tel_flgacres
                    tel_vlpagchq tel_flgdonet tel_insaqesp
                    tel_cdcomite WHEN crapcop.flgcmtlc
                    tel_dscomite WHEN crapcop.flgcmtlc
                    tel_vlalccre tel_vlapvcap tel_flgutcrm
                    WITH FRAME f_operad.
                   
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:    

                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.
       
                  RUN fontes/critic.p.
                  glb_cdcritic = 0.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  LEAVE.
        
            END.  /*  Fim do DO WHILE TRUE  */
           
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S" THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     glb_cdcritic = 0.
                     BELL.
                     MESSAGE glb_dscritic.
                     LEAVE Opcao_S.
                 END.

            DO TRANSACTION ON ENDKEY UNDO, LEAVE
                           ON ERROR  UNDO, LEAVE:
         
                FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                   crapope.cdoperad = tel_cdoperad 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.   

                IF  NOT AVAILABLE crapope   THEN
                    IF   LOCKED crapope   THEN
                         DO:
                             MESSAGE "Operador ja esta sendo alterado.".
                             PAUSE 3 NO-MESSAGE.
                             UNDO, LEAVE Opcao_S.
                         END.

                ASSIGN crapope.cddsenha = tel_cdoperad
                       crapope.dtaltsnh = 01/01/1900.

                FIND CURRENT crapope NO-LOCK NO-ERROR.

                RELEASE crapope.

            END.

            DISPLAY tel_cdoperad WITH FRAME f_senha.
            
            LEAVE.
        END.
   ELSE
   IF   glb_cddopcao = "V"   THEN
        DO:
           Opcao_V:
           DO WHILE TRUE:
       
              FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                 crapope.cdoperad = tel_cdoperad 
                                 NO-LOCK NO-ERROR NO-WAIT.
               
                 IF   NOT AVAILABLE crapope   THEN
                      DO:
                          glb_cdcritic = 67.
                          RUN fontes/critic.p.
                          RUN limpa.
                          MESSAGE glb_dscritic.
                          glb_cdcritic = 0.
                          LEAVE.
                      END.
                       
              /* Buscar descriçao do departamento */
              FIND FIRST crapdpo
                   WHERE crapdpo.cdcooper = glb_cdcooper 
                     AND crapdpo.cddepart = crapope.cddepart
                      NO-LOCK NO-ERROR.
              
              ASSIGN tel_nmoperad = crapope.nmoperad
                     tel_nvoperad = ENTRY(crapope.nvoperad,aux_nvoperad)
                     tel_flgperac = crapope.flgperac
                     tel_tpoperad = ENTRY(crapope.tpoperad,aux_tpoperad)
                     tel_dssitope = ENTRY(crapope.cdsitope,aux_dssitope)
                     tel_cddepart = crapope.cddepart
                     tel_dsdepart = IF avail crapdpo THEN 
                                       crapdpo.dsdepart 
                                    ELSE ""   
                     tel_cdagenci = crapope.cdagenci
                     tel_cdpactra = crapope.cdpactra
                     tel_flgdopgd = crapope.flgdopgd
                     tel_flgacres = crapope.flgacres
                     tel_vlpagchq = crapope.vlpagchq
                     tel_vllimted = crapope.vllimted
                     tel_flgdonet = crapope.flgdonet
                     tel_insaqesp = crapope.insaqesp
                     tel_cdcomite = crapope.cdcomite
                     tel_vlalccre = crapope.vlapvcre
                     tel_vlapvcap = crapope.vlapvcap
                     tel_flgutcrm = crapope.flgutcrm.
               
              RUN atualiza_dscomite.
              
              DISPLAY tel_nmoperad tel_nvoperad tel_flgperac tel_tpoperad 
                      tel_dssitope tel_cdagenci tel_cdpactra
                      tel_cddepart tel_dsdepart
                      tel_flgdopgd tel_flgacres
                      tel_vlpagchq tel_vllimted
                      tel_flgdonet tel_insaqesp
                      tel_cdcomite WHEN crapcop.flgcmtlc
                      tel_dscomite WHEN crapcop.flgcmtlc
                      tel_vlalccre tel_vlapvcap tel_flgutcrm
                      WITH FRAME f_operad.
             
              UPDATE tel_vlpagchq tel_vllimted WITH FRAME f_operad.

              RUN atualiza_vlpagchq.

              DO TRANSACTION ON ENDKEY UNDO, LEAVE 
                             ON ERROR  UNDO, LEAVE:
       
                  FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                     crapope.cdoperad = tel_cdoperad 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapope   THEN
                       IF   LOCKED crapope   THEN
                            DO:
                                MESSAGE "Operador ja esta sendo alterado.".
                                PAUSE 3 NO-MESSAGE.
                                UNDO, LEAVE Opcao_V.
                            END.

                  ASSIGN crapope.vlpagchq = tel_vlpagchq
                         crapope.vllimted = tel_vllimted.

                  FIND CURRENT crapope NO-LOCK NO-ERROR.

                  RELEASE crapope.

              END.

              LEAVE.

           END.
        END.
   ELSE    
   IF   glb_cddopcao = "N"   THEN /* Alterar Alcada de Credito */
        DO:                     
            FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK 
                 NO-ERROR.
       
            IF   NOT AVAILABLE crapcop   THEN
                 DO:
                     ASSIGN glb_cdcritic = 651.
                     RUN fontes/critic.p.
                     ASSIGN glb_cdcritic = 0.
         
                     BELL.
                     MESSAGE glb_dscritic.
         
                     NEXT.
                 END.

            ASSIGN tel_cdcomite = 0
                   tel_dscomite = ""
                   tel_vlalccre = 0.

            DISPLAY tel_cdcomite WHEN crapcop.flgcmtlc
                    tel_dscomite
                    tel_vlalccre WITH FRAME f_oper_cred.

            PAUSE 0.
            
            IF   crapcop.flgcmtlc THEN
                 DO:
                     FOR EACH crapope WHERE crapope.cdcooper = glb_cdcooper 
                                            NO-LOCK:
                         
                         CASE crapope.cdcomite:
                              WHEN 0 THEN tel_dscomite = "NAO PARTICIPA".
                              WHEN 1 THEN tel_dscomite = "COMITE LOCAL".
                              WHEN 2 THEN tel_dscomite = "COMITE SEDE".
                         END CASE.

                         CREATE cratope.
                         ASSIGN cratope.cdoperad = crapope.cdoperad
                                cratope.nmoperad = crapope.nmoperad
                                cratope.cdagenci = crapope.cdagenci 
                                cratope.dscomite = tel_dscomite.
                     END.                       
                     
                     DISPLAY b_oper_cred_cmtlocal 
                             WITH FRAME f_oper_cred_cmtlocal.
                     OPEN QUERY q_oper_cred_cmtlocal
                             FOR EACH cratope NO-LOCK.
                 END.           
            ELSE
                 DO:
                     DISPLAY b_oper_cred_alcada 
                             WITH FRAME f_oper_cred_alcada.
                     OPEN QUERY q_oper_cred_alcada
                             FOR EACH crapope WHERE 
                                      crapope.cdcooper = glb_cdcooper NO-LOCK
                                      BY crapope.nmoperad.
                 END.            

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                 IF   crapcop.flgcmtlc   THEN
                      UPDATE tel_cdcomite WITH FRAME f_oper_cred.
                 ELSE
                      UPDATE tel_vlalccre WITH FRAME f_oper_cred.

                 RUN atualiza_dscomite.
            
                 DISPLAY tel_dscomite WITH FRAME f_oper_cred.
                 
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    IF   crapcop.flgcmtlc   THEN
                         UPDATE b_oper_cred_cmtlocal 
                                WITH FRAME f_oper_cred_cmtlocal.
                    ELSE 
                         UPDATE b_oper_cred_alcada
                                WITH FRAME f_oper_cred_alcada.

                     LEAVE.

                 END. /** Fim do DO WHILE TRUE **/

                 IF   (crapcop.flgcmtlc                            AND
                       b_oper_cred_cmtlocal:NUM-SELECTED-ROWS = 0) OR
                      (NOT crapcop.flgcmtlc                        AND
                       b_oper_cred_alcada:NUM-SELECTED-ROWS = 0)   THEN
                       DO:
                           MESSAGE "Nenhum operador foi selecionado.".
                           PAUSE 2 NO-MESSAGE.
                           NEXT.                          
                       END.

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
                     ASSIGN aux_confirma = "N"
                            glb_cdcritic = 78.
                     RUN fontes/critic.p.
                     ASSIGN glb_cdcritic = 0.

                     BELL.
                     MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                    
                     LEAVE.
       
                 END. /* Fim do DO WHILE TRUE */
            
                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                      aux_confirma <> "S"                  THEN
                      DO:
                          ASSIGN glb_cdcritic = 79.
                          RUN fontes/critic.p.
                          ASSIGN glb_cdcritic = 0.

                          BELL.
                          MESSAGE glb_dscritic.

                          FOR EACH cratope EXCLUSIVE-LOCK:
                              DELETE cratope.
                          END.

                          LEAVE.
                      END.
       
                 IF   crapcop.flgcmtlc THEN
                      DO:
                          DO TRANSACTION
                             
                          aux_contador = 1 TO 
                                b_oper_cred_cmtlocal:NUM-SELECTED-ROWS:
                    
                                b_oper_cred_cmtlocal:FETCH-SELECTED-ROW(
                                                     aux_contador).
                      
                                FIND CURRENT cratope 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                FIND crapope WHERE 
                                     crapope.cdcooper = glb_cdcooper     AND
                                     crapope.cdoperad = cratope.cdoperad 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
                                IF   NOT AVAILABLE crapope   THEN
                                     IF   LOCKED crapope   THEN
                                          DO:
                                              PAUSE 2 NO-MESSAGE.
                                              RETRY.
                                          END.
                                     ELSE
                                          DO:
                                              ASSIGN glb_cdcritic = 67.
                                              RUN fontes/critic.p.
                                              ASSIGN glb_cdcritic = 0.
                                              BELL.
                                              MESSAGE glb_dscritic.
                                              LEAVE.
                                          END.
     
                                RUN atualiza_registro.
                      
                                FIND CURRENT crapope NO-LOCK NO-ERROR.

                                RELEASE crapope.
                          END.
                      
                          FOR EACH cratope EXCLUSIVE-LOCK:
                          
                              DELETE cratope.
                          END.
                      
                      END.
                 ELSE
                      DO:
                          DO TRANSACTION
                      
                          aux_contador = 1 TO
                                b_oper_cred_alcada:NUM-SELECTED-ROWS:
                    
                                b_oper_cred_alcada:FETCH-SELECTED-ROW(
                                                   aux_contador).
                      
                                FIND CURRENT crapope 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                IF   NOT AVAILABLE crapope   THEN
                                     IF   LOCKED crapope   THEN
                                          DO:
                                              PAUSE 2 NO-MESSAGE.
                                              RETRY.
                                          END.
                                     ELSE
                                          DO:
                                              ASSIGN glb_cdcritic = 67.
                                              RUN fontes/critic.p.
                                              ASSIGN glb_cdcritic = 0.
                                              BELL.
                                              MESSAGE glb_dscritic.
                                              LEAVE.
                                          END.
     
                                RUN atualiza_registro.
                      
                                FIND CURRENT crapope NO-LOCK NO-ERROR.

                                RELEASE crapope.
  
                          END.
                         
                      END.

                 LEAVE.
                
            END. /** Fim do DO WHILE TRUE **/
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 FOR EACH cratope EXCLUSIVE-LOCK:
                     DELETE cratope.
                 END.
        END.    
   ELSE 
     IF  glb_cddopcao = "X"   THEN
         DO:
             FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                crapope.cdoperad = tel_cdoperad NO-LOCK NO-ERROR.
 
             IF   NOT AVAILABLE crapope   THEN
                  DO:
                     glb_cdcritic = 67.
                     RUN fontes/critic.p.
                     RUN limpa.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     NEXT.
                  END.

             /* Buscar descriçao do departamento */
             FIND FIRST crapdpo
                  WHERE crapdpo.cdcooper = glb_cdcooper 
                    AND crapdpo.cddepart = crapope.cddepart
                     NO-LOCK NO-ERROR.

             ASSIGN tel_nmoperad = crapope.nmoperad
                    tel_nvoperad = ENTRY(crapope.nvoperad,aux_nvoperad)
                    tel_flgperac = crapope.flgperac
                    tel_tpoperad = ENTRY(crapope.tpoperad,aux_tpoperad)
                    tel_dssitope = ENTRY(crapope.cdsitope,aux_dssitope)
                    tel_cddepart = crapope.cddepart
                    tel_dsdepart = IF avail crapdpo THEN 
                                     crapdpo.dsdepart 
                                   ELSE ""
                    tel_cdagenci = crapope.cdagenci
                    tel_cdpactra = crapope.cdpactra
                    tel_flgdopgd = crapope.flgdopgd
                    tel_flgacres = crapope.flgacres
                    tel_vlpagchq = crapope.vlpagchq
                    tel_flgdonet = crapope.flgdonet
                    tel_insaqesp = crapope.insaqesp
                    tel_cdcomite = crapope.cdcomite
                    tel_vlalccre = crapope.vlapvcre
                    tel_vlapvcap = crapope.vlapvcap
                    tel_flgutcrm = crapope.flgutcrm.
                     
             RUN atualiza_dscomite.
             
             DISPLAY tel_nmoperad tel_nvoperad tel_flgperac tel_tpoperad 
                     tel_dssitope tel_cdagenci tel_cdpactra
                     tel_cddepart tel_dsdepart
                     tel_flgdopgd tel_flgacres
                     tel_vlpagchq tel_flgdonet tel_insaqesp
                     tel_cdcomite WHEN crapcop.flgcmtlc
                     tel_dscomite WHEN crapcop.flgcmtlc
                     tel_vlalccre tel_vlapvcap tel_flgutcrm
                     WITH FRAME f_operad.

             RUN fontes/confirma.p(INPUT "",
                                   OUTPUT aux_confirma).

             IF NOT aux_confirma = "S" THEN
                NEXT.

             RUN fontes/confirma.p(INPUT "Deseja replicar todas as permissoes ?(S/N)",
                                  OUTPUT aux_confirma).
             HIDE MESSAGE NO-PAUSE.
             
             HIDE MESSAGE NO-PAUSE.
             MESSAGE "Aguarde...".

             RUN copia_operador(INPUT aux_confirma).

             HIDE MESSAGE NO-PAUSE.
             MESSAGE "Operacao efetuada com sucesso.".

         END.
   ELSE
   IF   glb_cddopcao = "T"   THEN
        DO:
           Opcao_T:
           DO WHILE TRUE:
       
                 FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                    crapope.cdoperad = tel_cdoperad 
                                    NO-LOCK NO-ERROR NO-WAIT.
               
                 IF   NOT AVAILABLE crapope   THEN
                      DO:
                          glb_cdcritic = 67.
                          RUN fontes/critic.p.
                          RUN limpa.
                          MESSAGE glb_dscritic.
                          glb_cdcritic = 0.
                          LEAVE.
                      END.
                      
              /* Buscar descriçao do departamento */
              FIND FIRST crapdpo
                   WHERE crapdpo.cdcooper = glb_cdcooper 
                     AND crapdpo.cddepart = crapope.cddepart
                      NO-LOCK NO-ERROR.
              
              ASSIGN tel_nmoperad = crapope.nmoperad
                     tel_nvoperad = ENTRY(crapope.nvoperad,aux_nvoperad)
                     tel_flgperac = crapope.flgperac
                     tel_tpoperad = ENTRY(crapope.tpoperad,aux_tpoperad)
                     tel_dssitope = ENTRY(crapope.cdsitope,aux_dssitope)
                     tel_cddepart = crapope.cddepart
                     tel_dsdepart = IF avail crapdpo THEN 
                                      crapdpo.dsdepart 
                                    ELSE ""
                     tel_cdagenci = crapope.cdagenci
                     tel_cdpactra = crapope.cdpactra
                     tel_flgdopgd = crapope.flgdopgd
                     tel_flgacres = crapope.flgacres
                     tel_vlpagchq = crapope.vlpagchq
                     tel_flgdonet = crapope.flgdonet
                     tel_insaqesp = crapope.insaqesp
                     tel_cdcomite = crapope.cdcomite
                     tel_vlalccre = crapope.vlapvcre
                     tel_vlapvcap = crapope.vlapvcap
                     tel_flgutcrm = crapope.flgutcrm.
               
              RUN atualiza_dscomite.
              
              DISPLAY tel_nmoperad tel_nvoperad tel_flgperac tel_tpoperad 
                      tel_dssitope tel_cdagenci tel_cdpactra
                      tel_cddepart tel_dsdepart
                      tel_flgdopgd tel_flgacres
                      tel_vlpagchq tel_flgdonet tel_insaqesp
                      tel_cdcomite WHEN crapcop.flgcmtlc
                      tel_dscomite WHEN crapcop.flgcmtlc
                      tel_vlalccre tel_vlapvcap tel_flgutcrm
                      WITH FRAME f_operad.
             
              UPDATE tel_flgperac WITH FRAME f_operad.

              DO TRANSACTION ON ENDKEY UNDO, LEAVE 
                             ON ERROR  UNDO, LEAVE:
       
                 FIND crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                    crapope.cdoperad = tel_cdoperad 
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                 IF   NOT AVAILABLE crapope   THEN
                      IF   LOCKED crapope   THEN
                           DO:
                               MESSAGE "Operador ja esta sendo alterado.".
                               PAUSE 3 NO-MESSAGE.
                               UNDO, LEAVE Opcao_T.
                           END.

                 ASSIGN crapope.flgperac = tel_flgperac.

                 FIND CURRENT crapope NO-LOCK NO-ERROR.

                 RELEASE crapope.

              END.

              RUN gera_log ("Acessar contas restritas",
                            STRING(log_flgperac,"Sim/Nao"),
                            STRING(tel_flgperac,"Sim/Nao")).

              LEAVE.

           END.
        END.     

END.  /*  Fim do DO WHILE TRUE  */

PROCEDURE limpa:

    ASSIGN tel_nmoperad = ""
           tel_tpoperad = ""
           tel_flgperac = FALSE
           tel_nvoperad = ""
           tel_dssitope = ""
           tel_cddepart = 0
           tel_dsdepart = ""
           tel_flgcarta = FALSE
           tel_cdagenci = 0
           tel_cdpactra = 0
           tel_vlpagchq = 0
           tel_vlalccre = 0
           tel_flgdonet = TRUE
           tel_insaqesp = TRUE
           tel_cdcomite = 0.
    
    RUN atualiza_dscomite.
    
    DISPLAY tel_nmoperad tel_tpoperad tel_nvoperad tel_flgperac
            tel_dssitope tel_cddepart tel_dsdepart tel_flgcarta
            tel_vlpagchq tel_flgdonet tel_insaqesp
            tel_cdcomite WHEN crapcop.flgcmtlc
            tel_dscomite WHEN crapcop.flgcmtlc
            tel_vlalccre tel_cdpactra tel_cdagenci
            WITH FRAME f_operad.

    PAUSE 0 NO-MESSAGE.
    CLEAR FRAME f_operad.

END PROCEDURE.


PROCEDURE gera_log:

    DEF     INPUT PARAM aux_dsdcampo    AS CHAR                     NO-UNDO.
    DEF     INPUT PARAM aux_vlrantig    AS CHAR                     NO-UNDO.
    DEF     INPUT PARAM aux_vlralter    AS CHAR                     NO-UNDO.

    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")        + 
                      " "     + STRING(TIME,"HH:MM:SS")   + "' --> '"    +
                      "Operador "  + glb_cdoperad         + " - "        +
                      "alterou do operador " + tel_cdoperad      +
                      " o campo " + aux_dsdcampo + " de "                + 
                      aux_vlrantig  + " para "     + aux_vlralter + "."  + 
                      " >> log/operad.log").                                 

END.


PROCEDURE atualiza_registro:

    IF   crapcop.flgcmtlc   THEN
         DO:
             ASSIGN tel_cdoperad = crapope.cdoperad
                    log_cdcomite = crapope.cdcomite.
                             
             IF   log_cdcomite <> tel_cdcomite   THEN
                  DO:
                      CASE log_cdcomite:
                        WHEN 0 THEN log_dscomite = "- NAO PARTICIPA".
                        WHEN 1 THEN log_dscomite = "- COMITE LOCAL".
                        WHEN 2 THEN log_dscomite = "- COMITE SEDE".
                      END CASE.

                      RUN gera_log("Participa do Comite",STRING(log_dscomite),
                                                         STRING(tel_dscomite)).
                  END.                                       

             ASSIGN crapope.cdcomite = tel_cdcomite.
         END.
    ELSE
         DO:
             ASSIGN tel_cdoperad = crapope.cdoperad
                    log_vlalccre = crapope.vlapvcre.
                    /*log_vlpagchq = crapope.vlpagchq.  /*VTK*/  */

             IF   log_vlalccre <> tel_vlalccre   THEN
                  RUN gera_log("Alcada Credito",
                               STRING(log_vlalccre,"zzz,zzz,zz9.99"),
                               STRING(tel_vlalccre,"zzz,zzz,zz9.99")).
                      
             ASSIGN crapope.vlapvcre = tel_vlalccre.  
         END.
END.

PROCEDURE atualiza_dscomite:

  CASE tel_cdcomite:
       WHEN 0 THEN tel_dscomite = "- NAO PARTICIPA".
       WHEN 1 THEN tel_dscomite = "- COMITE LOCAL".
       WHEN 2 THEN tel_dscomite = "- COMITE SEDE".
  END CASE.
 
END.

PROCEDURE atualiza_vlpagchq:
    
    ASSIGN log_vlpagchq = crapope.vlpagchq.

    IF   log_vlpagchq <> tel_vlpagchq   THEN
         RUN gera_log("Valor Limite",
                      STRING(log_vlpagchq,"zzz,zzz,zz9.99"),
                      STRING(tel_vlpagchq,"zzz,zzz,zz9.99")).

END PROCEDURE.

/*******************************************************************************
Prodecure que replica o operador para demais cooperativas.
********************************************************************************/
PROCEDURE copia_operador:

    DEF INPUT PARAM par_confirma AS CHAR    NO-UNDO.
    
    FOR EACH b-crapcop WHERE b-crapcop.cdcooper <> 3 NO-LOCK:
        
        FIND b-crapope WHERE b-crapope.cdcooper = b-crapcop.cdcooper AND
                             b-crapope.cdoperad = crapope.cdoperad 
                             NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL b-crapope THEN
            DO:
               CREATE b-crapope.
               BUFFER-COPY crapope EXCEPT cdcooper TO b-crapope.
               ASSIGN b-crapope.cdcooper = b-crapcop.cdcooper.
        
               IF  par_confirma = "N" THEN
                   DO:
                      IF CAN-DO("1,3",STRING(b-crapope.tpoperad))   THEN 
                         FOR EACH craptel WHERE 
                                craptel.cdcooper = b-crapcop.cdcooper AND
                                craptel.flgtelbl = TRUE               AND
                                craptel.flgteldf = TRUE               NO-LOCK:
                           
                           /* Permissao Progrid */
                           IF  craptel.idsistem = 2  THEN 
                           DO:
                               IF NOT CAN-FIND(
                                  FIRST b-crapace WHERE 
                                  b-crapace.cdcooper = craptel.cdcooper AND
                                  b-crapace.nmdatela = craptel.nmdatela AND
                                  b-crapace.nmrotina = craptel.nmrotina AND
                                  b-crapace.cddopcao = "C"              AND
                                  b-crapace.cdoperad = crapope.cdoperad AND
                                  b-crapace.idambace = 3 NO-LOCK) THEN
                                  DO:
                                      CREATE crapace.
                                      ASSIGN crapace.nmdatela = craptel.nmdatela
                                             crapace.cddopcao = "C"
                                             crapace.cdoperad = crapope.cdoperad
                                             crapace.cdcooper = craptel.cdcooper 
                                             crapace.nmrotina = craptel.nmrotina
                                             crapace.idambace = 3.
                                  END.
                               NEXT.
                           END.
                           
                           /* Permissao Ayllos - 0 Todos, 1 Caracter, 2 Web */

                           /* cria caracter */
                           IF craptel.idambtel = 0 OR 
                              craptel.idambtel = 1 THEN
                           DO:
                               IF NOT CAN-FIND(
                                  FIRST b-crapace WHERE 
                                  b-crapace.cdcooper = craptel.cdcooper AND
                                  b-crapace.nmdatela = craptel.nmdatela AND
                                  b-crapace.nmrotina = craptel.nmrotina AND
                                  b-crapace.cddopcao = "C"              AND
                                  b-crapace.cdoperad = crapope.cdoperad AND
                                  b-crapace.idambace = 1 NO-LOCK) THEN
                                  DO:
                                      CREATE crapace.
                                      ASSIGN crapace.nmdatela = craptel.nmdatela
                                             crapace.cddopcao = "C"
                                             crapace.cdoperad = crapope.cdoperad
                                             crapace.cdcooper = craptel.cdcooper 
                                             crapace.nmrotina = craptel.nmrotina
                                             crapace.idambace = 1.    
                                  END.
                           END.

                           /* cria web */
                           IF craptel.idambtel = 0 OR 
                              craptel.idambtel = 2 THEN
                           DO:
                               IF NOT CAN-FIND(
                                  FIRST b-crapace WHERE 
                                        b-crapace.cdcooper = craptel.cdcooper   AND
                                        b-crapace.nmdatela = craptel.nmdatela   AND
                                        b-crapace.nmrotina = craptel.nmrotina   AND
                                        b-crapace.cddopcao = "C"                AND
                                        b-crapace.cdoperad = crapope.cdoperad AND
                                        b-crapace.idambace = 2 NO-LOCK) THEN
                               DO:
                                  CREATE crapace.
                                  ASSIGN crapace.nmdatela = craptel.nmdatela
                                         crapace.cddopcao = "C"
                                         crapace.cdoperad = crapope.cdoperad
                                         crapace.cdcooper = craptel.cdcooper 
                                         crapace.nmrotina = craptel.nmrotina
                                         crapace.idambace = 2. 
                               END.
                           END.

                         END.  /*  Fim do FOR EACH  */
                   END.
               ELSE
                   DO:
                      FOR EACH crapace WHERE 
                               crapace.cdcooper = crapope.cdcooper AND
                               crapace.cdoperad = crapope.cdoperad 
                               NO-LOCK:
                         
                         IF NOT CAN-FIND(
                            FIRST b-crapace WHERE
                                  b-crapace.cdcooper = b-crapcop.cdcooper AND
                                  b-crapace.nmdatela = crapace.nmdatela   AND
                                  b-crapace.nmrotina = crapace.nmrotina   AND
                                  b-crapace.cddopcao = crapace.cddopcao   AND
                                  b-crapace.cdoperad = crapace.cdoperad   AND
                                  b-crapace.idambace = crapace.idambace   NO-LOCK) THEN
                            DO:
                                CREATE b-crapace.
                                ASSIGN b-crapace.cdcooper = b-crapcop.cdcooper 
                                       b-crapace.nmdatela = crapace.nmdatela 
                                       b-crapace.nmrotina = crapace.nmrotina 
                                       b-crapace.cddopcao = crapace.cddopcao 
                                       b-crapace.cdoperad = crapace.cdoperad 
                                       b-crapace.idambace = crapace.idambace.
                            END.

                      END.
                   END.
               
            END.

    END. /* END FOR EACH */
  
END PROCEDURE.

/* .......................................................................... */









