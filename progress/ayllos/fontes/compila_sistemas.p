/* conexao com o banco unificado */
CONNECT /usr/coop/bdados/prd/progress/ayllos/ayllos
        -db ayllosp -ld ayllosp -dt ORACLE NO-ERROR.

/* conexao com o banco progrid */
CONNECT /usr/coop/bdados/prd/progress/progrid/progrid
        -db progridp -ld progridp -dt ORACLE NO-ERROR.


RUN /usr/coop/sistema/ayllos/fontes/compila_sistemas2.p.

/* desconecta os bancos */
DISCONNECT ayllos  NO-ERROR.
DISCONNECT progrid NO-ERROR.

QUIT.