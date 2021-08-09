BEGIN
INSERT INTO tbinss_notif_benef_sicredi (cdcooper, 
                                        nrdconta, 
                                        dhrequisicaoapi, 
                                        dsdispositivo, 
                                        cdagetfn,
                                        dsnotificacao,
                                        cdmensagemid,
                                        cdtransactionid,
                                        nrrecben,
                                        dhaceitenotif,
                                        inaceitenotif)
                                 SELECT ass.cdcooper,
                                        ass.nrdconta,
                                        SYSDATE,
                                        'cooperativa = '||ass.cdcooper||' - PA: '||ass.cdagenci||' - Terminal: '||TRUNC(dbms_random.value(10, 300)),
                                        TRUNC(dbms_random.value(10, 300)),
                                        '    EM NO MAXIMO 60 DIAS LIGUE 135 E    '||'   AGENDE UM ATENDIMENTO NO INSS PARA   '||'  REGULARIZAR O SEU CADASTRO E EVITAR   '||'      A SUSPENSAO DO SEU BENEFICIO      ',
                                        TRUNC(dbms_random.value(10, 300)),
                                        dbms_crypto.Hash(to_char(dcb.id_dcb), 2),
                                        dbi.nrrecben,
                                        CASE WHEN MOD(dbi.nrrecben, 2) <> 0 THEN SYSDATE ELSE NULL END,
                                        CASE WHEN MOD(dbi.nrrecben, 2) <> 0 THEN 1 ELSE TRUNC(dbms_random.value(-1, 0)) END
                                   FROM crapdbi dbi
                                  INNER JOIN crapass ass
                                     ON ass.nrcpfcgc = dbi.nrcpfcgc
                                  INNER JOIN tbinss_dcb dcb
                                     ON dcb.nrdconta = ass.nrdconta
                                    AND dcb.cdcooper = ass.cdcooper
                                    AND dcb.nrrecben = dbi.nrrecben
                                  WHERE ROWNUM <= 10000;
COMMIT;
END;