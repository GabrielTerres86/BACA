CREATE OR REPLACE VIEW CECRED.VWSGO_COOPERADOS AS
SELECT ass.cdcooper cooperativa,
       ass.nrdconta numero_conta,
       ass.cdagenci codigo_pa,
       age.nmresage nome_pa,
       ass.inpessoa tipo_pessoa,
       ttl.dtnasttl data_nascimento,
       ttl.nmextttl nome_reclamante,
       ttl.nrcpfcgc cpf_cnpj_titular,
       ttl.idseqttl sequencial,
       '' razao_social,
       '' profissao,
       decode(enc.tpendass,10,'RESIDENCIAL','COMERCIAL') tipo_endereco,
       enc.dsendere endereco,
       enc.nrendere numero_endereco,
       enc.nmbairro bairro,
       enc.nmcidade cidade,
       enc.nrcepend cep,
       enc.cdufende uf,
       enc.complend complemento
  FROM crapcop cop,
       crapass ass,
       crapage age,
       crapttl ttl,
       crapenc enc
 WHERE cop.flgativo = 1
   AND ass.cdcooper = cop.cdcooper
   AND ass.inpessoa = 1
   AND age.cdcooper = cop.cdcooper
   AND age.cdagenci = ass.cdagenci
   AND ttl.cdcooper = ass.cdcooper
   AND ttl.nrdconta = ass.nrdconta
   AND enc.cdcooper(+) = ttl.cdcooper
   AND enc.nrdconta(+) = ttl.nrdconta
   AND enc.idseqttl(+) = ttl.idseqttl
   AND enc.tpendass(+) IN (9,10)
   AND ass.dtelimin IS NULL
   AND ttl.nrcpfcgc IS NOT NULL
UNION
SELECT ass.cdcooper,
       ass.nrdconta,
       ass.cdagenci,
       age.nmresage,
       ass.inpessoa,
       NULL,
       ass2.nmprimtl,
       ass2.nrcpfcgc,
       1,
       ass.nmprimtl,
       ass2.dsproftl,
       decode(enc.tpendass,10,'RESIDENCIAL','COMERCIAL'),
       enc.dsendere,
       enc.nrendere,
       enc.nmbairro,
       enc.nmcidade,
       enc.nrcepend,
       enc.cdufende,
       enc.complend
  FROM crapcop cop,
       crapass ass,
       crapage age,
       crapavt avt,
       crapass ass2,
       crapenc enc
 WHERE cop.flgativo = 1
   AND ass.cdcooper = cop.cdcooper
   AND ass.inpessoa = 2
   AND age.cdcooper = cop.cdcooper
   AND age.cdagenci = ass.cdagenci
   AND avt.cdcooper = ass.cdcooper
   AND avt.tpctrato = 6
   AND avt.nrdconta = ass.nrdconta
   AND ass2.cdcooper(+) = avt.cdcooper
   AND ass2.nrdconta(+) = avt.nrdctato
   AND enc.cdcooper(+) = ass.cdcooper
   AND enc.nrdconta(+) = ass.nrdconta
   AND enc.idseqttl(+) = 1
   AND enc.tpendass(+) = 9
   AND ass.dtelimin IS NULL
   AND ass2.nrcpfcgc IS NOT NULL;
