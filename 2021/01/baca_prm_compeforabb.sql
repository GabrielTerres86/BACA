INSERT 
  INTO crapprm(NMSISTEM,
               CDCOOPER,
               CDACESSO,
               DSTEXPRM,
               DSVLRPRM) 
        VALUES('CRED'
              ,3
              ,'LST_EMAIL_COMPEFORABB'
              ,'Email dos responsaveis pelo processo de COMPEFORABB.'
              ,'plantonistas@ailos.coop.br;charles@ailos.coop.br;compe@ailos.coop.br;david.kistner@ailos.coop.br;' || 
               'csti03@ailos.coop.br;guilherme.eberhardt@ailos.coop.br;julio.machado@ailos.coop.br');
               
COMMIT;               
