/* .............................................................................

   Programa: Fontes/pesqcs.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jose Eduardo/Elton
   Data    : Julho/2006                        Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Estatistica de protocolos de custodia. 

   Alteracoes: 

............................................................................. */

{ includes/var_online.i }

DEF VAR aux_ptcustod AS INT FORMAT "zzz,zz9"                        NO-UNDO.
DEF VAR aux_chcustod AS INT FORMAT "z,zzz,zz9"                      NO-UNDO.
DEF VAR aux_nmprimtl LIKE crapass.nmprimtl                          NO-UNDO.

DEF VAR aux_contador AS INT                                         NO-UNDO.

DEF VAR tel_nrdconta LIKE crapass.nrdconta                          NO-UNDO.

DEF VAR tel_dtinicio AS DATE FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR tel_dttermin AS DATE FORMAT "99/99/9999"                    NO-UNDO.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM  "Titular da Conta" AT ROW 1 COLUMN 1
      "Protocolos"       AT ROW 1 COLUMN 27 
      "Cheques"          AT ROW 1 COLUMN 41         
      aux_nmprimtl       AT ROW 3 COLUMN 1
      aux_ptcustod       AT ROW 3 COLUMN 30 
      aux_chcustod       AT ROW 3 COLUMN 39
      WITH NO-LABEL NO-BOX
      ROW 11 COLUMN 10 SIZE 60 BY 8 OVERLAY WITH FRAME f_consulta.
            
FORM "Conta:" 
     tel_nrdconta NO-LABEL         HELP "Informe numero de conta para consulta"
     SKIP(1)
     "Periodo - Data Inicio:"
     tel_dtinicio                  HELP "Informe data inicial para consulta"  
     NO-LABEL SPACE(4)
     "Data Fim:"
     tel_dttermin                  HELP "Informe data final para consulta"
     NO-LABEL  WITH FRAME f_quadro ROW 6 COLUMN 3 NO-BOX OVERLAY.


RUN fontes/inicia.p.
          
VIEW FRAME f_moldura.
PAUSE (0).

VIEW FRAME f_quadro.
VIEW FRAME f_consulta. 

ASSIGN tel_dttermin = glb_dtmvtolt.
       tel_dtinicio = tel_dttermin - DAY(tel_dttermin).


DO WHILE TRUE ON ENDKEY UNDO, LEAVE :

   DO  WHILE TRUE ON ENDKEY UNDO, LEAVE : 
       UPDATE tel_nrdconta tel_dtinicio tel_dttermin WITH FRAME f_quadro. 
              
       LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:            
            RUN  fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "PESQCS"   THEN
                 LEAVE.
            ELSE
                 NEXT.
        END.
   
                         
   HIDE   aux_ptcustod  aux_chcustod  aux_nmprimtl.

   MESSAGE "PROCESSANDO...".
 
   
   
   FIND crapass WHERE  crapass.nrdconta = tel_nrdconta AND
                       crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
   IF  AVAIL crapass THEN 
       ASSIGN aux_nmprimtl = crapass.nmprimtl.
   ELSE
       ASSIGN aux_nmprimtl = "Nao cadastrado".
   
   FOR EACH craplot WHERE craplot.cdcooper  = glb_cdcooper AND
                          craplot.dtmvtolt >= tel_dtinicio AND 
                          craplot.dtmvtolt <= tel_dttermin AND
                          craplot.tplotmov  = 19           NO-LOCK:

       aux_contador = 0.
    
       FOR EACH crapcst WHERE crapcst.cdcooper = craplot.cdcooper  AND
                              crapcst.dtmvtolt = craplot.dtmvtolt  AND
                              crapcst.cdagenci = craplot.cdagenci  AND
                              crapcst.cdbccxlt = craplot.cdbccxlt  AND
                              crapcst.nrdolote = craplot.nrdolote  AND
                             (crapcst.nrdconta = tel_nrdconta)     AND
                              crapcst.inchqcop = 0                 NO-LOCK:
     
           ASSIGN  aux_chcustod = aux_chcustod + 1
                                  aux_contador = 1.

       END.

       IF   aux_contador > 0  THEN 
            aux_ptcustod = aux_ptcustod + 1.

   END.
   

   HIDE MESSAGE NO-PAUSE.
  
   DISPLAY  aux_ptcustod  aux_chcustod aux_nmprimtl FORMAT "x(25)" 
            WITH FRAME f_consulta.   
   

   ASSIGN  aux_ptcustod = 0
           aux_chcustod = 0
           aux_nmprimtl = "".
END.

/*............................................................................*/