prompt RDM0030655

set feedback off
set define off

insert into tbcadast_pessoa (IDPESSOA, NRCPFCGC, NMPESSOA, NMPESSOA_RECEITA, TPPESSOA, DTCONSULTA_SPC, DTCONSULTA_RFB, CDSITUACAO_RFB, TPCONSULTA_RFB, DTATUALIZA_TELEFONE, DTCONSULTA_SCR, TPCADASTRO, CDOPERAD_ALTERA, IDCORRIGIDO, DTALTERACAO, DTREVISAO_CADASTRAL)
values (12045475, 8988746000167, 'DUCA ADMINISTRADORA DE BENS LTDA',  'DUCA ADMINISTRADORA DE BENS LTDA', 2, null, null, null, null, null, null, 3, '1', null, to_date('23-04-2019 17:21:17', 'dd-mm-yyyy hh24:mi:ss'), null);

insert into TBCADAST_PESSOA_JURIDICA (IDPESSOA, CDCNAE, NMFANTASIA, NRINSCRICAO_ESTADUAL, CDNATUREZA_JURIDICA, DTCONSTITUICAO, DTINICIO_ATIVIDADE, QTFILIAL, QTFUNCIONARIO, VLCAPITAL, DTREGISTRO, NRREGISTRO, DTINSCRICAO_MUNICIPAL, NRNIRE, INREFIS, DSSITE, NRINSCRICAO_MUNICIPAL, CDSETOR_ECONOMICO, VLFATURAMENTO_ANUAL, CDRAMO_ATIVIDADE, NRLICENCA_AMBIENTAL, DTVALIDADE_LICENCA_AMB, PEUNICO_CLIENTE, TPREGIME_TRIBUTACAO, DSORGAO_REGISTRO)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), null, 'DUCA ADMINISTRADORA DE BENS LTDA', 0, 2135, null, to_date('14-07-1979', 'dd-mm-yyyy'), 0, 0, null, null, null, null, null, null, ' ', null, 2, null, 48, null, null, null, null, null);



insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('24-04-2019 08:51:06', 'dd-mm-yyyy hh24:mi:ss'), 2, 12, '1-Prospect', '3-Intermediario', '1', '3');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1, null, '12045475', '1', '12045475');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 2, null, '8988746000167', '1', '8988746000167');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 3, null, 'RAZAO SOCIAL EMPRESA', '1', 'RAZAO SOCIAL EMPRESA');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 5, null, '2', '1', '2');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 12, null, '1-Prospect', '1', '1');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 13, null, '1', '1', '1');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:16', 'dd-mm-yyyy hh24:mi:ss'), 1, 58, null, '12045475', '1', '12045475');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:16', 'dd-mm-yyyy hh24:mi:ss'), 1, 60, null, 'NOME FANTASIA EMPRESA', '1', 'NOME FANTASIA EMPRESA');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:16', 'dd-mm-yyyy hh24:mi:ss'), 1, 62, null, '2135-Empresario (Individual) ', '1', '2135');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:16', 'dd-mm-yyyy hh24:mi:ss'), 1, 64, null, '14/07/1979', '1', '14/07/1979');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:16', 'dd-mm-yyyy hh24:mi:ss'), 1, 76, null, '2-COMERCIO', '1', '2');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:16', 'dd-mm-yyyy hh24:mi:ss'), 1, 78, null, '48-PECAS E ACESS. PARA VEICULOS', '1', '48');

insert into tbcadast_pessoa_historico (IDPESSOA, NRSEQUENCIA, DHALTERACAO, TPOPERACAO, IDCAMPO, DSVALOR_ANTERIOR, DSVALOR_NOVO, CDOPERAD_ALTERA, DSVALOR_NOVO_ORIGINAL)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 0, to_date('23-04-2019 17:21:17', 'dd-mm-yyyy hh24:mi:ss'), 2, 3, 'RAZAO SOCIAL EMPRESA', 'EMPRESA TESTE', '1', 'EMPRESA TESTE');



insert into tbcadast_pessoa_endereco (IDPESSOA, NRSEQ_ENDERECO, TPENDERECO, NMLOGRADOURO, NRLOGRADOURO, DSCOMPLEMENTO, NMBAIRRO, IDCIDADE, NRCEP, TPIMOVEL, VLDECLARADO, DTALTERACAO, DTINICIO_RESIDENCIA, TPORIGEM_CADASTRO, CDOPERAD_ALTERA)
values ((select idpessoa from TBCADAST_PESSOA where nrcpfcgc = 8988746000167), 1, 9, 'RUA ALAMEDA RIO BRANCO', 14, 'SALA 304', 'CENTRO', 14461, 89010300, null, null, null, null, null, '1');

commit;

prompt Done.
