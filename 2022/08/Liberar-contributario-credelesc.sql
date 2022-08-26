BEGIN

/* Mudar tipo de custeio padrão da cooperativa para CONTRIBUTÁRIO */

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = 0
   WHERE p.cdcooper = 8
     AND p.cdacesso = 'TPCUSTEI_PADRAO';

/* Mudar tipo de custeio das linhas de crédito para CONTRIBUTÁRIO */

  UPDATE cecred.craplcr SET tpcuspr = 0 WHERE cdcooper = 8 and flgsegpr = 1;

/* Definir o dia em que foi feita a mudança para CONTRIBUTÁRIO
   (as propostas que já existiam antes dessa data, e que ainda não estavam efetivadas, permanecerão com tipo de custeior NÃO CONTRIBUTÁRIO...
    Se a data da cooperativa for retroativa, esse parâmetro também precisa ter data retroativa. Por exemplo, se a data na crapdat for 01/07/2022, esse parâmetro precisa ter valor 01/07/2022 ou inferior) */

  INSERT INTO cecred.crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 8, 'DIA_ATIVA_CONTRB_SEGPRE', 'Dia da ativação das linhas de credito contributario', '20/07/2022');

  COMMIT;
END;
/
