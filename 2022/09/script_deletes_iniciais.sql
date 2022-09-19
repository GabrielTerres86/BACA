DECLARE

  vr_nrseqrdr cecred.craprdr.nrseqrdr%type;

BEGIN

  DELETE FROM cecred.crapaca aca
   WHERE aca.nmdeacao IN ('PROCESSA_ARQ_CERC', 'LISTA_AGENDAS_ATIVAS_ARQUIVO')
     AND aca.nrseqrdr = (SELECT rdr.nrseqrdr
                           FROM cecred.craprdr rdr
                          WHERE rdr.nmprogra = 'TELA_IMPREC');

  DELETE FROM cecred.craptel tel
   WHERE tel.nmdatela = 'IMPREC';

  DELETE FROM cecred.crapprg prg
   WHERE prg.nmsistem = 'CRED'
     AND prg.cdprogra = 'IMPREC';

  DELETE FROM cecred.craprdr rdr
   WHERE rdr.nmprogra = 'TELA_IMPREC';

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
