 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela CONTAS->IMPRESSOES
    Projeto     : Inovações
    Autor       : Cassia de Oliveira (GFT)
    Data        : Janeiro/2019
    Objetivo    : Realiza o cadastro do relatorio e da mensageria da procedure Ficha-Proposta
  ---------------------------------------------------------------------------------------------------------------------*/

BEGIN
INSERT INTO 
    craprel(
      CDRELATO,
      NRVIADEF,
      NRVIAMAX,
      NMRELATO,
      NRMODULO,
      NMDESTIN,
      NMFORMUL,
      INDAUDIT,
      CDCOOPER,
      PERIODIC,
      TPRELATO,
      INIMPREL,
      INGERPDF,
      DSDEMAIL,
      CDFILREL,
      NRSEQPRI)  
SELECT
    773,
    1,
    1,
    'FICHA-PROPOSTA',
    5,
    ' ',
    ' ',
    0,
    cdcooper,
    'D',
    1,
    1,
    1,
    ' ',
    null,
    null
FROM 
    crapcop;

INSERT INTO 
    crapaca(
      nmdeacao,
      nmpackag,
      nmproced,
      lstparam,
      nrseqrdr) 
VALUES ('IMPRESSAO_FICHA_PROPOSTA',
        'CADA0002',
        'pc_impressao_ficha_prop',
        'pr_nrdconta',
        246);
COMMIT;
END;
