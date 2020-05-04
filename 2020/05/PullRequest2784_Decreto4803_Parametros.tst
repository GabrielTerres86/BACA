PL/SQL Developer Test script 3.0
194
DECLARE

  aux_cdpartar  crappat.cdpartar%TYPE;

BEGIN

  SELECT MAX(cdpartar) INTO aux_cdpartar FROM crappat;
  aux_cdpartar :=  aux_cdpartar + 1;
  -- ----- Ativação ----- --
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar, 'Decreto 4803 - Ativo (1) ou Desativado (0)', 1, 12);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('DEC4803SIT', 'INFORMA ATIVO DECRETO 4803 PARA CONGELAR RISCO EMPRESTIMOS', ' ', 2, aux_cdpartar);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 17, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 1, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 15, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 14, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 13, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 11, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 10, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 9, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 8, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 7, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 6, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 5, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 4, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 3, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 2, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 12, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 16, '0');

  aux_cdpartar :=  aux_cdpartar + 1;
  -- ----- Ativação ----- --
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar, 'Decreto 4803 - Dados início;fim;risco;qtd em atraso', 2, 12);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('DEC4803DAT', 'INFORMA DATA OCR, OPERACAO INICIAL, FINAL, DIAS EM ATRASO', ' ', 2, aux_cdpartar);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 16, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 15, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 14, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 13, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 11, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 10, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 9, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 8, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 7, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 6, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 5, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 4, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 3, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 2, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 1, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 17, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 12, '29/02/2020;01/03/2020;30/09/2020;15');

  aux_cdpartar :=  aux_cdpartar + 1;
  -- ----- Linhas ----- --
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar, 'Decreto 4803 - Linhas de crédito para empréstimo', 2, 12);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('DEC4803LIN', 'INFORMA LINHA PARA DECRETO 4803 CONGELAR RISCO EMPRESTIMOS', ' ', 2, aux_cdpartar);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 17, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 1, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 15, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 14, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 13, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 11, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 10, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 9, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 8, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 7, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 6, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 5, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 4, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 3, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 2, '');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 12, '158;1;58');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 16, '');

  -- Domínio da risco
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('INORIGEM_RATING', '8', 'DECRETO 4803');

  -- Atualização das finalidades para Coronavírus
  UPDATE crapprm SET dsvlrprm = '62,63,82' WHERE cdacesso = 'FINALI_CORONA';

  COMMIT;

END;
0
0
