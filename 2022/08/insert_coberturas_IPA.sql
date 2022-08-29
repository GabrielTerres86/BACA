begin
    delete from seguro.tbseg_cobertura_vida;
	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,         cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(1,                         'MQC','Prote��o por morte',                  18,         65,     20000.00,    200000.00,        'R',        ' ',         1);

     insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,   cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(3,                   'IPA_VG_AP','Invalidez por acidente',          18,         65,     20000.00,    200000.00,         'R',        'Cobertura de at� {vlcobertura} em casos de invalidez total ou parcial por acidente.',         1);

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,                cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(355,                      'DIHA','Interna��o hospitalar por acidente',           18,         65,     6000.00,     6000.00,         'R',        'Cobertura de at� R$ 6.000,00 para interna��o hospitalar por acidente, com limites de at� 30 di�rias de R$ 200,00.',         1);			

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,          cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(257,                'SAF_I_7 NV','Assist�ncia Individual',          18,         65,      7000.00,      7000.00,        'S',        'Poder� ser acionada somente pelo titular em caso de aus�ncia por motivos naturais ou acidentais',         1);					

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,    cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(258,                 'SAF_FAM7K','Assist�ncia Familiar',           18,         65,      7000.00,      7000.00,        'S',        'Poder� ser acionada para o titular, c�njuge e filhos at� 21 anos em caso de aus�ncia por motivos naturais ou acidentais.',         1);					

    insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,          cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(256,                  'F+P_7000','Assist�ncia Familiar + Pais',          18,         65,      7000.00,      7000.00,        'S',        'Poder� ser acionada para o titular, seus pais, c�njuge e filhos at� 21 anos em caso de aus�ncia por motivos naturais ou acidentais.',         1);		

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,         cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(1,                         'MQC','Prote��o por morte',                  18,         65,     20000.00,    200000.00,        'R',        ' ',         2);								

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,   cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(3,                  'IPA_VG_AP','Invalidez por acidente',          18,         65,     20000.00,    200000.00,         'R',        'Cobertura de at� {vlcobertura} em casos de invalidez total ou parcial por acidente.',         2);										

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,                cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(420,                  'REA_DIH_A','Interna��o hospitalar por acidente',           18,         65,     6000.00,     6000.00,         'R',        'Cobertura de at� R$ 6.000,00 para interna��o hospitalar por acidente, com limites de at� 30 di�rias de R$ 200,00.',         2);			

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,          cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(9,                'SAF_I_7 NV','Assist�ncia Individual',          18,         65,      7000.00,      7000.00,        'S',        'Poder� ser acionada somente pelo titular em caso de aus�ncia por motivos naturais ou acidentais',         2);					

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,    cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(10,                 'SAF_FAM7K','Assist�ncia Familiar',           18,         65,      7000.00,      7000.00,        'S',        'Poder� ser acionada para o titular, c�njuge e filhos at� 21 anos em caso de aus�ncia por motivos naturais ou acidentais.',         2);					

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,          cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(412,                  'F+P_7000','Assist�ncia Familiar + Pais',          18,         65,      7000.00,      7000.00,        'S',        'Poder� ser acionada para o titular, seus pais, c�njuge e filhos at� 21 anos em caso de aus�ncia por motivos naturais ou acidentais.',         2);		
	Commit;
end;
/
