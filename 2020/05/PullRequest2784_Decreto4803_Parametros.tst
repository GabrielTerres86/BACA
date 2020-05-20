PL/SQL Developer Test script 3.0
316
DECLARE
  CURSOR cr_crapbat(pr_cdbattar IN crapbat.cdbattar%TYPE) IS
    SELECT cdcadast
      FROM crapbat
     WHERE cdbattar = pr_cdbattar;
  rw_crapbat cr_crapbat%ROWTYPE;

  aux_cdpartar_add  crappat.cdpartar%TYPE;
  aux_cdpartar_del  crappat.cdpartar%TYPE;

BEGIN

  OPEN cr_crapbat('DEC4803SIT');
  FETCH cr_crapbat INTO rw_crapbat;
  CLOSE cr_crapbat;
  IF rw_crapbat.cdcadast IS NOT NULL THEN
    aux_cdpartar_del := rw_crapbat.cdcadast;
    DELETE FROM crapbat WHERE cdcadast = aux_cdpartar_del;
    DELETE FROM crappat WHERE cdpartar = aux_cdpartar_del;
    DELETE FROM crappco WHERE cdpartar = aux_cdpartar_del;
  END IF;

  OPEN cr_crapbat('DEC4803DAT');
  FETCH cr_crapbat INTO rw_crapbat;
  CLOSE cr_crapbat;
  IF rw_crapbat.cdcadast IS NOT NULL THEN
    aux_cdpartar_del := rw_crapbat.cdcadast;
    DELETE FROM crapbat WHERE cdcadast = aux_cdpartar_del;
    DELETE FROM crappat WHERE cdpartar = aux_cdpartar_del;
    DELETE FROM crappco WHERE cdpartar = aux_cdpartar_del;
  END IF;

  OPEN cr_crapbat('DEC4803LIN');
  FETCH cr_crapbat INTO rw_crapbat;
  CLOSE cr_crapbat;
  IF rw_crapbat.cdcadast IS NOT NULL THEN
    aux_cdpartar_del := rw_crapbat.cdcadast;
    DELETE FROM crapbat WHERE cdcadast = aux_cdpartar_del;
    DELETE FROM crappat WHERE cdpartar = aux_cdpartar_del;
    DELETE FROM crappco WHERE cdpartar = aux_cdpartar_del;
  END IF;

  OPEN cr_crapbat('PREVEMAIL3040');
  FETCH cr_crapbat INTO rw_crapbat;
  CLOSE cr_crapbat;
  IF rw_crapbat.cdcadast IS NOT NULL THEN
    aux_cdpartar_del := rw_crapbat.cdcadast;
    DELETE FROM crapbat WHERE cdcadast = aux_cdpartar_del;
    DELETE FROM crappat WHERE cdpartar = aux_cdpartar_del;
    DELETE FROM crappco WHERE cdpartar = aux_cdpartar_del;
  END IF;

  DELETE FROM tbgen_dominio_campo WHERE nmdominio = 'INORIGEM_RATING' AND cddominio = 8;

  COMMIT;

  SELECT MAX(cdpartar) INTO aux_cdpartar_add FROM crappat;
  aux_cdpartar_add :=  aux_cdpartar_add + 1;
  -- ----- Ativação ----- --
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar_add, 'Decreto 4803 - Ativo (1) ou Desativado (0)', 1, 12);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('DEC4803SIT', 'INFORMA ATIVO DECRETO 4803 PARA CONGELAR RISCO EMPRESTIMOS', ' ', 2, aux_cdpartar_add);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 17, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 1, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 15, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 14, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 13, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 11, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 10, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 9, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 8, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 7, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 6, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 5, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 4, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 3, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 2, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 12, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 16, '0');

  aux_cdpartar_add :=  aux_cdpartar_add + 1;
  -- ----- Ativação ----- --
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar_add, 'Decreto 4803 - Dados início;fim;risco;qtd em atraso', 2, 12);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('DEC4803DAT', 'INFORMA DATA OCR, OPERACAO INICIAL, FINAL, DIAS EM ATRASO', ' ', 2, aux_cdpartar_add);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 16, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 15, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 14, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 13, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 11, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 10, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 9, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 8, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 7, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 6, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 5, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 4, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 3, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 2, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 1, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 17, '29/02/2020;01/03/2020;30/09/2020;15');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 12, '29/02/2020;01/03/2020;30/09/2020;15');

  aux_cdpartar_add :=  aux_cdpartar_add + 1;
  -- ----- Linhas ----- --
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar_add, 'Decreto 4803 - Linhas de crédito para empréstimo', 2, 12);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('DEC4803LIN', 'INFORMA LINHA PARA DECRETO 4803 CONGELAR RISCO EMPRESTIMOS', ' ', 2, aux_cdpartar_add);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 17, '');

  -- VIACREDI - 1
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 1, '5504;9675;9677;9676;9660;9633;9632;9664;9654;9653;9679;9650;9651;9652;9655;9656;9657;43001;30000;14401;34401;14701;24401;44401;24701;42701;40000');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 15, '');

  -- EVOLUA - 14
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 14, '');

  -- CIVIA - 13
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 13, '76;184;998;999;67;171;150;57;240;241;242;281;341;342;343;344;345');

  -- CREDIFOZ - 11
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 11, '51;204;205;206;207;208;209;210;211;212;213;214;215;382;383');

  -- CREDICOMIN - 10
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 10, '193;194;192;195;175;122;153;123;124;250;252;251;198;199;197;201;174;159;162;220;164;163;60;250;251;252');

  -- TRANSPOCRED - 9
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 9, '451;452;453;454;455;457;458;150;151;154;155;156;157;158;159;263;264');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 8, '');

  -- CREDCREA - 7
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 7, '220;221;130;131;3678;3710;3687;195;96;197;198');

  -- UNILOS - 6
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 6, '44;43;45;46;47;48;49;50;51;72;85;87');

  -- ACENTRA - 5
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 5, '46;89;90;91;92;93;652;712;713;714;733;734');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 4, '');

  -- AILOS - 3
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 3, '');

  -- ACREDICOOP - 2
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 2, '840;841;978;979;985;1043;1044;350;351;352;1500');

  -- CREVISC - 12
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 12, '25;26;245;246;1500;129;130;137;145;169;206;215;219;220;242;243;244');

  -- VIACREDI AV - 16
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 16, '');

  aux_cdpartar_add :=  aux_cdpartar_add + 1;
  -- Email Padrão para Previa --
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar_add, 'E-mail padrão para envio da finalização da prévia XML 3040 da opção P e Q', 2, 12);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('PREVEMAIL3040', 'INFORMAR EMAIL PARA PRÉVIA 3040 TELA RISCO OPERACOES P E Q QUANDO EMAIL OPERADOR NÃO CADASTRADO', ' ', 2, aux_cdpartar_add);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 17, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 1, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 15, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 14, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 13, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 11, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 10, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 9, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 8, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 7, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 6, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 5, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 4, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 3, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 2, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 12, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar_add, 16, 'creditosuporte@cecred.coop.br');

  -- Domínio da risco
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('INORIGEM_RATING', '8', 'DECRETO 4803');

  -- Atualização das finalidades para Coronavírus
  UPDATE crapprm SET dsvlrprm = '62,63,82' WHERE cdacesso = 'FINALI_CORONA';

  COMMIT;

END;
0
0
