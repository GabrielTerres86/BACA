/* PRJ438 - Cadastrar motivo de anulação para reprovação de transação pendente */
DECLARE
  --
  vdsmtv          tbcadast_motivo_anulacao.dsmotivo%TYPE;
  vr_new_cdmotivo tbcadast_motivo_anulacao.cdmotivo%TYPE;

  FUNCTION new_cdmotivo RETURN tbcadast_motivo_anulacao.cdmotivo%TYPE IS
    vr_next_cdmotivo tbcadast_motivo_anulacao.cdmotivo%TYPE;
  BEGIN
    SELECT MAX(cdmotivo) + 1
      INTO vr_next_cdmotivo
      FROM tbcadast_motivo_anulacao;
  
    RETURN vr_next_cdmotivo;
  
  END new_cdmotivo;

BEGIN
  --
  --
  vr_new_cdmotivo := new_cdmotivo;
  vdsmtv          := 'Transação pendente não aprovada pelo sócio';
  --
  FOR vr IN (SELECT cop.cdcooper
               FROM crapcop cop
              WHERE cop.flgativo = 1
              ORDER BY 1) LOOP
    INSERT INTO TBCADAST_MOTIVO_ANULACAO
      (cdcooper,
       cdmotivo,
       dsmotivo,
       tpproduto,
       dtcadastro,
       inobservacao,
       idativo)
    VALUES
      (vr.cdcooper, vr_new_cdmotivo, vdsmtv, 1, SYSDATE, 0, 1);
  
  END LOOP;

  COMMIT;

END;


