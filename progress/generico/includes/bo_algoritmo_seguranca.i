/* ............................................................................

   Programa: sistema/generico/includes/bo_algoritmo_seguranca.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Agosto/2011                   Ultima Atualizacao: 09/03/2012
   
   Dados referentes ao programa:

   Frequencia: Diario (internet)
   Objetivo  : Includes da bo de seguranca.

   Alteracoes: 03/10/2011 - Adicionado campos nmprepos, nrcpfpre e nrcpfope.
                            (Jorge). 
                            
               09/03/2012 - Adicionado os campos cdbcoctl e cdagectl.(Fabricio)
   
............................................................................ */

/* Temp-Table usada na procedure lista_protocolos */
DEF TEMP-TABLE cratpro                                                 NO-UNDO
    FIELD cdtippro LIKE crappro.cdtippro
    FIELD dtmvtolt LIKE crappro.dtmvtolt
    FIELD dttransa LIKE crappro.dttransa
    FIELD hrautent LIKE crappro.hrautent
    FIELD vldocmto LIKE crappro.vldocmto
    FIELD nrdocmto LIKE crappro.nrdocmto
    FIELD nrseqaut LIKE crappro.nrseqaut
    FIELD dsinform LIKE crappro.dsinform
    FIELD dsprotoc LIKE crappro.dsprotoc
    FIELD dscedent LIKE crappro.dscedent
    FIELD flgagend LIKE crappro.flgagend
    FIELD nmprepos LIKE crappro.nmprepos
    FIELD nrcpfpre LIKE crappro.nrcpfpre
    FIELD nmoperad LIKE crapopi.nmoperad
    FIELD nrcpfope LIKE crappro.nrcpfope
    FIELD cdbcoctl LIKE crapcop.cdbcoctl
    FIELD cdagectl LIKE crapcop.cdagectl
    FIELD cdagesic LIKE crapcop.cdagesic.

/* ......................................................................... */
