DECLARE
  vr_codigo INTEGER := 5750;

BEGIN

DELETE FROM TAA.TBTAA_SEP_ARQ_OCORRENCIA WHERE IDARQUIVO >= vr_codigo;
DELETE FROM TAA.TBTAA_SEP_ARQ_TRANSACAO WHERE IDARQUIVO >= vr_codigo;
DELETE FROM TAA.TBTAA_SEP_ARQ_CONTESTACAO WHERE IDARQUIVO >= vr_codigo;
DELETE FROM TAA.TBTAA_SEP_ARQ_CUSTODIA WHERE IDARQUIVO >= vr_codigo;
DELETE FROM TAA.TBTAA_SEP_ARQ_TRAILER_SERV WHERE IDARQUIVO >= vr_codigo;
DELETE FROM TAA.TBTAA_SEP_ARQ_HEADER_SERV WHERE IDARQUIVO >= vr_codigo;
DELETE FROM TAA.TBTAA_SEP_ARQ_TRAILER WHERE IDARQUIVO >= vr_codigo;
DELETE FROM TAA.TBTAA_SEP_ARQ_HEADER WHERE IDARQUIVO >= vr_codigo;
DELETE FROM TAA.TBTAA_SEP_ARQ WHERE IDARQUIVO >= vr_codigo;

 COMMIT;
END;