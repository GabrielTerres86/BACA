/* .............................................................................

   Programa: Fontes/ver_cadastro.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Julho/2003.                        Ultima atualizacao: 25/05/2009
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Verificar se eh necessario fazer recadastramento do associado.

    
   Alteracoes: 05/08/2003 - Tratamento para Operador 1 (Julio).
               07/07/2004 - Alterado para pegar pela data de admissao
                            (crapass.dtadmiss)(Mirtes)
               
               25/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               25/05/2009 - Alteracao CDOPERAD (Kbase).

			   08/12/2016 - P341-Automatização BACENJUD - Realizar a validação 
			                do departamento pelo código do mesmo (Renato Darosci)
..............................................................................*/

DEF INPUT  PARAMETER par_nrdconta AS INTEGER                         NO-UNDO.
DEF INPUT  PARAMETER par_dtmvtolt AS DATE                            NO-UNDO.
DEF OUTPUT PARAMETER par_cdcritic AS INTEGER                         NO-UNDO.

{ includes/var_online.i }

DEF BUFFER  crabass FOR crapass.

par_cdcritic = 0.

IF   glb_cddepart = 20 THEN  /* TI */ 
     RETURN.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = glb_cdcooper   AND
                   craptab.cdacesso = "ATUALIZCAD"   AND
                   craptab.tpregist = 0              NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN
     DO:
        FIND LAST crapalt WHERE crapalt.cdcooper = glb_cdcooper  AND 
                                crapalt.nrdconta = par_nrdconta  AND
                                crapalt.tpaltera = 1           
                                NO-LOCK NO-ERROR.
                  
        IF    AVAILABLE crapalt   THEN
             IF   (par_dtmvtolt - crapalt.dtaltera) > INT(craptab.dstextab) THEN
                   par_cdcritic = 763. 
             ELSE
                  .
        ELSE 
            DO:  
                FIND crabass WHERE crabass.cdcooper = glb_cdcooper  AND 
                                   crabass.nrdconta = par_nrdconta 
                                   NO-LOCK NO-ERROR.
                IF  AVAIL crabass AND
                    ((par_dtmvtolt - crabass.dtadmiss)
                                   > INT(craptab.dstextab))  THEN
                    ASSIGN par_cdcritic = 763.
                 
                /*==================  Desativado em 07/07/2004 =========
                IF   glb_cdcooper = 4   AND
                     glb_dtmvtolt <= 08/31/2003 THEN
                     .
                ELSE     
                     par_cdcritic = 763.
                =======================================================*/
            END.
     END.      
/* .......................................................................... */

