begin
    delete from seguro.tbseg_cobertura_vida;
	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,         cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(1,                         'MQC','Proteção por morte',                  18,         65,     20000.00,    200000.00,        'R',        ' ',         1);

     insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,   cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(3,                   'IPA_VG_AP','Invalidez por acidente',          18,         65,     20000.00,    200000.00,         'R',        'Cobertura de até {vlcobertura} em casos de invalidez total ou parcial por acidente.',         1);

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,                cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(355,                      'DIHA','Internação hospitalar por acidente',           18,         65,     6000.00,     6000.00,         'R',        'Cobertura de até R$ 6.000,00 para internação hospitalar por acidente, com limites de até 30 diárias de R$ 200,00.',         1);			

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,          cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(257,                'SAF_I_7 NV','Assistência Individual',          18,         65,      7000.00,      7000.00,        'S',        'Poderá ser acionada somente pelo titular em caso de ausência por motivos naturais ou acidentais',         1);					

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,    cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(258,                 'SAF_FAM7K','Assistência Familiar',           18,         65,      7000.00,      7000.00,        'S',        'Poderá ser acionada para o titular, cônjuge e filhos até 21 anos em caso de ausência por motivos naturais ou acidentais.',         1);					

    insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,          cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(256,                  'F+P_7000','Assistência Familiar + Pais',          18,         65,      7000.00,      7000.00,        'S',        'Poderá ser acionada para o titular, seus pais, cônjuge e filhos até 21 anos em caso de ausência por motivos naturais ou acidentais.',         1);		

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,         cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(1,                         'MQC','Proteção por morte',                  18,         65,     20000.00,    200000.00,        'R',        ' ',         2);								

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,   cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(3,                  'IPA_VG_AP','Invalidez por acidente',          18,         65,     20000.00,    200000.00,         'R',        'Cobertura de até {vlcobertura} em casos de invalidez total ou parcial por acidente.',         2);										

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,                cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(420,                  'REA_DIH_A','Internação hospitalar por acidente',           18,         65,     6000.00,     6000.00,         'R',        'Cobertura de até R$ 6.000,00 para internação hospitalar por acidente, com limites de até 30 diárias de R$ 200,00.',         2);			

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,          cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(9,                'SAF_I_7 NV','Assistência Individual',          18,         65,      7000.00,      7000.00,        'S',        'Poderá ser acionada somente pelo titular em caso de ausência por motivos naturais ou acidentais',         2);					

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,    cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(10,                 'SAF_FAM7K','Assistência Familiar',           18,         65,      7000.00,      7000.00,        'S',        'Poderá ser acionada para o titular, cônjuge e filhos até 21 anos em caso de ausência por motivos naturais ou acidentais.',         2);					

	insert into seguro.tbseg_cobertura_vida(cdcobertura,dsdescricao_abreviada,dsdescricao_completa,          cdidade_min,cdidade_max,vlcapital_min,vlcapital_max,tpcobertura,dsobervacao,tpambiente) values 
											(412,                  'F+P_7000','Assistência Familiar + Pais',          18,         65,      7000.00,      7000.00,        'S',        'Poderá ser acionada para o titular, seus pais, cônjuge e filhos até 21 anos em caso de ausência por motivos naturais ou acidentais.',         2);		
	Commit;
end;
/
