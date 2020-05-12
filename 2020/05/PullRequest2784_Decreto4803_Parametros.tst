PL/SQL Developer Test script 3.0
266
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
  values (aux_cdpartar, 14, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 13, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 11, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 10, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 9, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 8, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 7, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 6, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 5, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 4, '0');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 3, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 2, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 12, '1');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 16, '1');

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

  -- VIACREDI - 1
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 1, '5504;9675;9677;9676;9660;9633;9632;9664;9654;9653;9679;9650;9651;9652;9655;9656;9657;43001;30000;14401;34401;14701;24401;44401;24701;42701;40000');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 15, '');

  -- EVOLUA - 14
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 14, '');

  -- CIVIA - 13
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 13, '184;998;999;67;171;150;57;240;241;242;281;341;342;343;344;345');

  -- CREDIFOZ - 11
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 11, '51;204;205;206;207;208;209;210;211;212;213;214;215;382;383');

  -- CREDICOMIN - 10
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 10, '193;194;192;195;175;122;153;123;124;250;252;251;198;199;197;201;174;159;162;220;164;163;60;250;251;252');

  -- TRANSPOCRED - 9
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 9, '451;452;453;454;455;457;458;150;151;154;155;156;157;158;159;263;264');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 8, '');

  -- CREDCREA - 7
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 7, '220;221;130;131;3678;3710;3687;195;96;197;198');

  -- UNILOS - 6
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 6, '44;43;45;46;47;48;49;50;51;72;85;87');

  -- ACENTRA - 5
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 5, '46;89;90;91;92;93;652;712;713;714;733;734');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 4, '');

  -- AILOS - 3
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 3, '');

  -- ACREDICOOP - 2
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 2, '840;841;978;979;985;1043;1044;350;351;352;1500');

  -- CREVISC - 12
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 12, '25;26;245;246;1500;129;130;137;145;169;206;215;219;220;242;243;244');

  -- VIACREDI AV - 16
  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 16, '');

  aux_cdpartar :=  aux_cdpartar + 1;
  -- Email Padrão para Previa --
  insert into crappat (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
  values (aux_cdpartar, 'E-mail padrão para envio da finalização da prévia XML 3040 da opção P e Q', 2, 12);

  insert into crapbat (CDBATTAR, NMIDENTI, CDPROGRA, TPCADAST, CDCADAST)
  values ('PREVEMAIL3040', 'INFORMAR EMAIL PARA PRÉVIA 3040 TELA RISCO OPERACOES P E Q QUANDO EMAIL OPERADOR NÃO CADASTRADO', ' ', 2, aux_cdpartar);

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 17, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 1, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 15, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 14, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 13, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 11, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 10, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 9, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 8, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 7, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 6, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 5, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 4, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 3, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 2, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 12, 'creditosuporte@cecred.coop.br');

  insert into crappco (CDPARTAR, CDCOOPER, DSCONTEU)
  values (aux_cdpartar, 16, 'creditosuporte@cecred.coop.br');

  -- Domínio da risco
  insert into tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('INORIGEM_RATING', '8', 'DECRETO 4803');

  -- Atualização das finalidades para Coronavírus
  UPDATE crapprm SET dsvlrprm = '62,63,82' WHERE cdacesso = 'FINALI_CORONA';

  COMMIT;

END;
0
0
