BEGIN
  
insert into tbcadast_pessoa_juridica (IDPESSOA, CDCNAE, NMFANTASIA, NRINSCRICAO_ESTADUAL, CDNATUREZA_JURIDICA, DTCONSTITUICAO, DTINICIO_ATIVIDADE, QTFILIAL, QTFUNCIONARIO, VLCAPITAL, DTREGISTRO, NRREGISTRO, DTINSCRICAO_MUNICIPAL, NRNIRE, INREFIS, DSSITE, NRINSCRICAO_MUNICIPAL, CDSETOR_ECONOMICO, VLFATURAMENTO_ANUAL, CDRAMO_ATIVIDADE, NRLICENCA_AMBIENTAL, DTVALIDADE_LICENCA_AMB, PEUNICO_CLIENTE, TPREGIME_TRIBUTACAO, DSORGAO_REGISTRO, TPPREFERENCIACONTATO, TPPREFERATENDIMENTO, INIMPORT_EXPORT, NRFAT_PUBLICO, TPCOMPRENDA, DSFINACTA)
values (246951, null, 'HIGH SECURITY', 0, 2305, null, to_date('03-09-2007', 'dd-mm-yyyy'), null, null, null, null, null, null, null, null, null, null, 2, null, 64, null, null, null, null, null, null, null, null, null, null, null);

    UPDATE CRAPEPA
    SET NMFANSIA = 'HIGH SECURITY'
    , NATJURID = 2305
    , CDSETECO = 2
    , CDRMATIV = 64
    where cdcooper = 6
    and nrdconta = 501840;
	
	UPDATE CRAPTTL
	SET NMSOCIAL = 'DJENIFER ESTEFANI DE GODOI'
	WHERE CDCOOPER = 1
	AND NRDCONTA = 11688912;	

    commit;
END;