/* ..........................................................................

   Programa: Fontes/gg0001.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Marco/2004.                       Ultima atualizacao: 10/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Conter funcoes que poderao ser utilizadas por qualquer 
               programa que acessar o banco de dados "central.db".
               
   Restricoes: Fazer a chamada das rotinas somente quando o banco estiver 
               conectado.

   ROTINAS :
             
     PROCEDURE p_criatabdolar { Cadastra a tabela do dolar conforme 
               administradora e data passada como parametro} - (Julio).

     PROCEDURE p_enderecocecred { pesquisa na crapcop o endereco da CECRED
               o retorno e feito atraves dos parametros passados } - (Julio).

     FUNCTION  f_valordolar { pesquisa o valor do dolar apartir do codigo
               da administradora e data das faturas } - (Julio)
                
     FUNCTION  f_datadolar { pesquisa se tem tabela de dolar  com o valor
               zerado, se existir, retorna a data da tabela } - (Julio)
               
     FUNCTION  f_alteradolar { Grava o valor do dolar na tabela conforme 
               parametros, esta funcao retorna um valor inteiro que corresponde
               a critica (crapcri), caso ocorra algum erro. 
               EX: - Se a gravacao ocorrer sem erros, retorna "0"; 
                   - Se o registro estiver sendo utilizado em outro terminal
                     retorna "341";
                   - E se nao existir registro para a data e administradora 
                     especificada entao retorna "55".} - (Julio)               

   Alteracoes: 22/06/2012 - Substituido gncoper por crapcop (Tiago).           
               
               10/12/2013 - Inclusao de VALIDATE gndolar (Carlos)

............................................................................ */

FUNCTION f_valordolar RETURN LOGICAL(INPUT  par_cdadmcrd AS INTEGER,
                                     INPUT  par_dtdolfat AS DATE,
                                     OUTPUT par_vldolfat AS DECIMAL):
                                      
  FIND gndolar WHERE gndolar.cdadmcrd = par_cdadmcrd AND
                     gndolar.dtdolfat = par_dtdolfat 
                     NO-LOCK NO-ERROR.
                                     
  IF   AVAILABLE gndolar   THEN
       DO:
           ASSIGN par_vldolfat = gndolar.vldolfat.
           RETURN TRUE.
       END.
  ELSE 
       DO:
           ASSIGN par_vldolfat = 0.0.
           RETURN FALSE.          
       END.
END.

FUNCTION f_datadolar RETURN DATE(INPUT par_cdadmcrd AS INTEGER):
                                      
  FIND FIRST gndolar WHERE gndolar.cdadmcrd = par_cdadmcrd AND
                           gndolar.vldolfat = 0
                           NO-LOCK NO-ERROR.
                                     
  IF   AVAILABLE gndolar   THEN
       RETURN gndolar.dtdolfat.
  ELSE 
       RETURN ?.

END.

FUNCTION f_alteradolar RETURN INTEGER(INPUT par_cdadmcrd AS INTEGER, 
                                      INPUT par_dtdolfat AS DATE,
                                      INPUT par_vldolfat AS DECIMAL):

  FIND gndolar WHERE gndolar.cdadmcrd = par_cdadmcrd AND
                     gndolar.dtdolfat = par_dtdolfat 
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

  IF   NOT AVAILABLE gndolar   THEN
       DO:
           IF   LOCKED gndolar   THEN
                RETURN 341.
           ELSE
                RETURN 55.
       END.
  ELSE
       DO:
           ASSIGN gndolar.vldolfat = par_vldolfat.
           RETURN 0.
       END.
           
END.

PROCEDURE p_criatabdolar:

   DEF INPUT PARAMETER par_cdadmcrd  AS INTEGER                 NO-UNDO.
   DEF INPUT PARAMETER par_dtdoltab  AS DATE                    NO-UNDO.  
   
   CREATE gndolar.
   ASSIGN gndolar.cdadmcrd = par_cdadmcrd
          gndolar.dtdolfat = par_dtdoltab.
   VALIDATE gndolar.
END.

PROCEDURE p_enderecocecred:

   DEF OUTPUT PARAMETER par_nrcepend  AS  INTEGER                 NO-UNDO.
   DEF OUTPUT PARAMETER par_dsendcop  AS  CHARACTER               NO-UNDO.
   DEF OUTPUT PARAMETER par_cdufdcop  AS  CHARACTER               NO-UNDO.
   DEF OUTPUT PARAMETER par_nmcidade  AS  CHARACTER               NO-UNDO.
  
   FIND crapcop WHERE crapcop.cdcooper = 3 NO-LOCK NO-ERROR.
         
   IF   AVAILABLE crapcop   THEN
        DO:
            ASSIGN par_nmcidade = crapcop.nmcidade          
                   par_dsendcop = crapcop.dsendcop + "   , " + 
                                  TRIM(STRING(crapcop.nrendcop, "zz,zz9"))
                   par_nrcepend = crapcop.nrcepend
                   par_cdufdcop = crapcop.cdufdcop.
        END.
   ELSE
        DO:
            ASSIGN par_nmcidade = ""
                   par_dsendcop = ""
                   par_nrcepend = 0
                   par_cdufdcop = "".

        END.
END.

/* ......................................................................... */
