-- Scripts DML Projetos: PRJ0013792 - Inclusão do cheque especial na esteira de crédito
-- Tipo: Telas

-- criar motivos anulação
insert into tbcadast_motivo_anulacao
( cdcooper
,cdmotivo
,dsmotivo
,tpproduto
,dtcadastro
,inobservacao
,idativo
)
SELECT cdcooper
,cdmotivo
,dsmotivo
,4 --tpproduto Limite Crédito
,dtcadastro
,inobservacao
,idativo
  from tbcadast_motivo_anulacao t
 WHERE tpproduto =3;
 

-- Replica tabela craplim para craulim - tempo exec H3: 3:27
INSERT INTO crawlim
  (nrdconta,
   insitlim,
   dtpropos,
   dtinivig,
   inbaslim,
   vllimite,
   nrctrlim,
   cdmotcan,
   dtfimvig,
   qtdiavig,
   cdoperad,
   dsencfin##1,
   dsencfin##2,
   dsencfin##3,
   flgimpnp,
   nrctaav1,
   nrctaav2,
   dsendav1##1,
   dsendav1##2,
   dsendav2##1,
   dsendav2##2,
   nmdaval1,
   nmdaval2,
   dscpfav1,
   dscpfav2,
   nmcjgav1,
   nmcjgav2,
   dscfcav1,
   dscfcav2,
   tpctrlim,
   qtrenova,
   cddlinha,
   dtcancel,
   cdopecan,
   cdcooper,
   qtrenctr,
   cdopelib,
   nrgarope,
   nrinfcad,
   nrliquid,
   nrpatlvr,
   idquapro,
   nrperger,
   vltotsfn,
   flgdigit,
   dtrenova,
   tprenova,
   dsnrenov,
   nrconbir,
   dtconbir,
   inconcje,
   cdopeori,
   cdageori,
   dtinsori,
   cdopeexc,
   cdageexc,
   dtinsexc,
   dtrefatu,
   insitblq,
   idcobope,
   idcobefe)
  (SELECT lim.nrdconta,
          insitlim,
          dtpropos,
          dtinivig,
          inbaslim,
          vllimite,
          nrctrlim,
          cdmotcan,
          dtfimvig,
          qtdiavig,
          cdoperad,
          dsencfin##1,
          dsencfin##2,
          dsencfin##3,
          flgimpnp,
          nrctaav1,
          nrctaav2,
          dsendav1##1,
          dsendav1##2,
          dsendav2##1,
          dsendav2##2,
          nmdaval1,
          nmdaval2,
          dscpfav1,
          dscpfav2,
          nmcjgav1,
          nmcjgav2,
          dscfcav1,
          dscfcav2,
          tpctrlim,
          qtrenova,
          cddlinha,
          dtcancel,
          cdopecan,
          lim.cdcooper,
          qtrenctr,
          cdopelib,
          nrgarope,
          nrinfcad,
          nrliquid,
          nrpatlvr,
          idquapro,
          nrperger,
          vltotsfn,
          flgdigit,
          dtrenova,
          tprenova,
          dsnrenov,
          nrconbir,
          dtconbir,
          inconcje,
          cdopeori,
          cdageori,
          dtinsori,
          cdopeexc,
          cdageexc,
          dtinsexc,
          dtrefatu,
          insitblq,
          idcobope,
		  idcobefe
     FROM craplim lim,
          crapcop cop
    WHERE lim.cdcooper = cop.cdcooper
      AND lim.tpctrlim = 1
      AND cop.flgativo = 1);
  
-- Excluir craplim
DELETE craplim p
   WHERE  p.tpctrlim = 1
   AND    p.insitlim = 1
   --     garantir que só vai apagar os contrato já convertidos em proposta
   AND    EXISTS( SELECT 1
                  FROM   crawlim w
                  WHERE  w.cdcooper = p.cdcooper
                  AND    w.tpctrlim = p.tpctrlim
                  AND    w.nrdconta = p.nrdconta
                  AND    w.nrctrlim = p.nrctrlim)
;

-- Atualizar nos contratos ativos/cancelados 
--e que são anteriores ao projeto, situação esteira e decisão.
UPDATE crawlim w
   SET w.insitest = 3 -- Analise Finalizada
      ,w.insitapr = 2 -- Aprovada Manual
 WHERE w.tpctrlim = 1 -- Limite de Credito
   AND w.insitlim IN (2,3) -- Ativo E Cancelado 
;   

COMMIT; 
