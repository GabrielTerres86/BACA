/*.............................................................................

   Programa: fontes/segauto.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Novembro/2008                       Ultima Atualizacao : 31/03/2010

   Dados referente ao programa:
        
   Frequencia: Diario (on-line).
   Objetivo  : Rotina/Tela. Permitir a consulta dos seguros AUTO (Tela ATENDA).
   
   
   Alteracoes: 31/03/2010 - Adaptcao para o browaer do seguro ser dinamico
                            (Gabriel).

..............................................................................*/

DEF INPUT PARAM par_nrctrseg AS INTE                                NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_seguro.i }

DEF TEMP-TABLE w-seguros                                            NO-UNDO
    FIELD nmdsegur LIKE crawseg.nmdsegur FORMAT "x(40)"
    FIELD dsmarvei LIKE crawseg.dsmarvei
    FIELD dstipvei LIKE crawseg.dstipvei
    FIELD nranovei LIKE crawseg.nranovei
    FIELD nrmodvei LIKE crawseg.nrmodvei
    FIELD nrdplaca LIKE crawseg.nrdplaca
    FIELD dtinivig LIKE crawseg.dtinivig
    FIELD dtfimvig LIKE crawseg.dtfimvig
    FIELD qtparcel LIKE crawseg.qtparcel FORMAT "zz9"
    FIELD vlpreseg LIKE crawseg.vlpreseg FORMAT "zzz,zzz,zz9.99"
    FIELD vlpremio LIKE crawseg.vlpremio FORMAT "zzz,zzz,zz9.99"
    FIELD dtdebito AS   INT              FORMAT " 99".

DEF VAR b1wgen0033 AS HANDLE                                        NO-UNDO.

FORM SKIP(1) 
     w-seguros.nmdsegur AT 07 LABEL "Segurado"              SKIP(2)
     w-seguros.dsmarvei AT 10 LABEL "Marca"     
     w-seguros.dstipvei AT 46 LABEL "Tipo"      
     w-seguros.nranovei AT 12 LABEL "Ano"  
     w-seguros.nrmodvei AT 29 LABEL "Modelo"   
     w-seguros.nrdplaca AT 45 LABEL "Placa"                 SKIP(2)
     w-seguros.dtinivig AT 06 LABEL "Vigencia do seguro:    Inicio"  
     w-seguros.dtfimvig AT 26 LABEL "    Final"             SKIP(2)
     w-seguros.qtparcel AT 05 LABEL "Quantidade parcelas" 
     w-seguros.vlpreseg AT 34 LABEL "Valor da parcela"    
     w-seguros.dtdebito AT 11 LABEL "Dia do debito"       
     w-seguros.vlpremio AT 35 LABEL "Total do premio"       SKIP(2) 
     WITH ROW 4 SIDE-LABELS OVERLAY CENTERED WIDTH 78 FRAME f_auto.
                 
RUN sistema/generico/procedures/b1wgen0033.p PERSISTENT SET b1wgen0033.
    
IF   VALID-HANDLE(b1wgen0033)   THEN
     DO:
         RUN seguro_auto IN b1wgen0033(INPUT glb_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT glb_cdoperad,
                                       INPUT glb_dtmvtolt,
                                       INPUT tel_nrdconta,
                                       INPUT par_nrctrseg,
                                       INPUT 1,
                                       INPUT 1,
                                       INPUT "ATENDA",
                                       INPUT FALSE,
                                       OUTPUT TABLE w-seguros). 
         DELETE PROCEDURE b1wgen0033.
     END.

FIND FIRST w-seguros NO-LOCK NO-ERROR.
    
IF   NOT AVAILABLE w-seguros   THEN   
     RETURN.

DISPLAY w-seguros WITH FRAME f_auto.
     
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   PAUSE MESSAGE "Tecle algo para retornar...".
   LEAVE.
END.
 
HIDE FRAME f_auto.

/*............................................................................*/
