begin
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'CONTAB_CONTA_CONTABIL', 'Lista de contas contabeis para a geração da base de receitas', '7116,7118,7252,7262,7254,7132,7258,7122,7135,7141,7276,7272,7274,7275,7278,7245,7235,7236,7237,7239,7248,7240,7251,7337,7345,7338,7052,7340,7341,7053,7342,7238,7241,7265,7246,7247,7242,7244,7453,7124,7123,7138,7136,7281,7257,7113,7339,7473,7347,7186,7487,7489,7492,7234,7111,7102,7498,7557,7008,7047,7004,7043,7587,7195,7615,7617,7619,7621,7623,7625,7627,7129,7572,7573,7574,7575,7067,7068,7069,7593,7596,7563,7566,7231,7282,7283,7285,7287,7286,7222,7590,7560,7267,7260,7223,7189,7161,7162,7149,7224,7288,7158,7160,7159,7163,7164,7165,7166,7167,7168,7169,7171,7172,7174,7291,7263,7192,7261,7125,7133,7134,7516,7196');

    INSERT INTO EXPURGO.TBHST_CONTROLE (idcontrole,nmowner,nmtabela,nmcampo_refere,nrdias_refere,tpintervalo,nmanalista,dtinicio,tpoperacao)
    VALUES (17,'CONTABILIDADE','tbcontab_dados_arquivo','dtmvtolt',60,2,'Jaison',TRUNC(SYSDATE),2);

    commit;
exception
  when others then
    rollback;
end;