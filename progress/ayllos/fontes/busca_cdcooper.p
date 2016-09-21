/* conexao com o banco unificado */
CONNECT /usr/coop/bdados/prd/progress/ayllos/banco NO-ERROR.

/* conexao com o banco progrid */
CONNECT /usr/coop/bdados/prd/progress/progrid/progrid NO-ERROR.

/* conexao com o banco jddda */
IF TRIM(OS-GETENV("PKGNAME")) = "pkgprod" THEN
   CONNECT /usr/coop/bdados/prd/progress/jddda/jddda
           -db JDDDAPROD -ld bdjddda -dt MSS
           -H 0303prodts01 -S 4448 -lkwtmo 180 NO-ERROR.

ELSE
IF TRIM(OS-GETENV("PKGNAME")) = "pkghomol" THEN
   CONNECT /usr/coop/bdados/prd/progress/jddda/jddda
           -db JDDDAHOMOL -ld bdjddda -dt MSS
           -H 0303prodts01 -S 4447 -lkwtmo 180 NO-ERROR.
ELSE
IF TRIM(OS-GETENV("PKGNAME")) = "pkgdesen" THEN
   CONNECT /usr/coop/bdados/prd/progress/jddda/jddda
           -db JDDDADESEN -ld bdjddda -dt MSS
           -H 0303prodts01 -S 4446 -lkwtmo 180 NO-ERROR.

RUN /usr/coop/sistema/ayllos/fontes/busca_cdcooper2.p.

/* desconecta os bancos */
DISCONNECT banco   NO-ERROR.
DISCONNECT progrid NO-ERROR.
DISCONNECT jddda   NO-ERROR.

QUIT.

