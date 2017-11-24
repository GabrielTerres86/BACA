CREATE OR REPLACE VIEW CECRED.VW_USUARIOS_INTERNET AS
SELECT /*+ INDEX(snh CRAPSNH##CRAPSNH1) INDEX(ass CRAPASS##CRAPASS1) INDEX(ttl CRAPTTL##CRAPTTL1) */
       snh.cdcooper
      ,snh.nrdconta
      ,snh.idseqttl

      ,ass.inpessoa
      ,ass.idastcjt

      --Dados da conta
      ,ttl.nrcpfcgc
      ,ttl.nmextttl
      ,regexp_substr(ttl.nmextttl,'\w+') nmresttl -- Apenas o primeiro nome

      -- Dados do procurador (apenas PJ com Ass Cjt)
      ,NULL nrcpfpro
      ,NULL nmextpro
      ,NULL nmrespro

  FROM crapsnh snh
      ,crapass ass
      ,crapttl ttl
 WHERE ass.cdcooper = snh.cdcooper
   AND ass.nrdconta = snh.nrdconta
   AND ass.inpessoa = 1 -- Pessoa Física
   AND snh.cdcooper = ttl.cdcooper
   AND snh.nrdconta = ttl.nrdconta
   AND snh.idseqttl = ttl.idseqttl
   AND snh.cdsitsnh = 1 -- Ativa
   AND snh.tpdsenha = 1 -- Internet

UNION

-- PESSOA JURÍDICA SEM ASS CONJUNTA
SELECT /*+ INDEX(snh CRAPSNH##CRAPSNH1) INDEX(ass CRAPASS##CRAPASS1) INDEX(jur CRAPJUR##CRAPJUR1) */
       snh.cdcooper
      ,snh.nrdconta
      ,snh.idseqttl

      ,ass.inpessoa
      ,ass.idastcjt

      --Dados da conta
      ,ass.nrcpfcgc
      ,jur.nmextttl
      ,jur.nmfansia nmresttl

      -- Dados do procurador
      ,NULL nrcpfpro
      ,NULL nmextpro
      ,NULL nmrespro

  FROM crapsnh snh
      ,crapass ass
      ,crapjur jur

 WHERE ass.cdcooper = snh.cdcooper
   AND ass.nrdconta = snh.nrdconta
   AND ass.inpessoa IN (2,3) -- Pessoa Jurídica
   AND ass.idastcjt = 0 -- Sem Assinatura conjunta
   AND jur.cdcooper = snh.cdcooper
   AND jur.nrdconta = snh.nrdconta
   AND snh.cdsitsnh = 1 -- Ativa
   AND snh.tpdsenha = 1 -- Internet

UNION

-- PESSOA JURÍDICA COM ASS CONJUNTA
SELECT /*+ INDEX(snh CRAPSNH##CRAPSNH1) INDEX(ass CRAPASS##CRAPASS1) INDEX(jur CRAPJUR##CRAPJUR1) */
       snh.cdcooper
      ,snh.nrdconta
      ,snh.idseqttl

      ,ass.inpessoa
      ,ass.idastcjt

      -- Dados da conta
      ,ass.nrcpfcgc
      ,jur.nmextttl
      ,jur.nmfansia nmresttl

      -- Dados do Procurador
      ,avt.nrcpfcgc nrcpfpro
      ,NVL(avtttl.nmextttl, avt.nmdavali) nmextpro
      ,regexp_substr(NVL(avtttl.nmextttl, avt.nmdavali),'\w+') nmrespro -- Apenas o primeiro nome

  FROM crapsnh snh
      ,crapass ass
      ,crapjur jur
      ,crappod pod
      ,crapavt avt
      ,crapttl avtttl

 WHERE ass.cdcooper = snh.cdcooper
   AND ass.nrdconta = snh.nrdconta
   AND ass.inpessoa IN (2,3) -- Pessoa Jurídica
   AND ass.idastcjt = 1 -- Assinatura conjunta
   AND jur.cdcooper = snh.cdcooper
   AND jur.nrdconta = snh.nrdconta
   --AND snh.cdsitsnh = 1 -- Ativa
   AND snh.tpdsenha = 1 -- Internet

   -- Poderes do cartão de assinatura
   AND pod.cdcooper = snh.cdcooper
   AND pod.nrdconta = snh.nrdconta
   AND pod.nrcpfpro = snh.nrcpfcgc
   AND pod.cddpoder = 10 -- Operação de autoatendimento
   AND pod.flgconju = 1 -- Assina em conjunto

   -- Procuradores
   AND avt.cdcooper = snh.cdcooper
   AND avt.tpctrato = 6 -- procuradores
   AND avt.nrdconta = snh.nrdconta
   AND avt.nrctremp = 0 -- Fixo 0 pq ass conjunta não tem contrato de empréstimo
   AND avt.nrcpfcgc = snh.nrcpfcgc

   AND avt.cdcooper = avtttl.cdcooper(+)
   AND avt.nrdctato = avtttl.nrdconta(+)
   AND avt.nrcpfcgc = avtttl.nrcpfcgc(+)
;
