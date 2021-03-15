-- Scripts DML Projetos:  - Inclusão do Desconto cheque na esteira de crédito

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
      AND lim.tpctrlim = 2
      AND cop.flgativo = 1);
  
-- Excluir craplim
DELETE craplim p
   WHERE  p.tpctrlim = 2
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
 WHERE w.tpctrlim = 2 -- Limite de desconto cheque
   AND w.insitlim IN (2,3) -- Ativo E Cancelado 
;   

COMMIT; 

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
,5 --tpproduto Limite Desc. Cheque
,dtcadastro
,inobservacao
,idativo
  from tbcadast_motivo_anulacao t
 WHERE tpproduto =3;
 
COMMIT; 


-- carga tab019
DECLARE
  -- Variáveis
  vr_qtcooper NUMBER;
  vr_dscritic VARCHAR2(10000);

  CURSOR cr_crapcop IS
    SELECT  
           --
           cdcooper,
           Initcap(nmrescop) nmrescop
      FROM crapcop cop
     WHERE cop.flgativo = 1
     ORDER BY cop.cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

begin
  FOR rw_crapcop  in cr_crapcop  LOOP
      -- Grava linha para as cooperativas
      BEGIN
        update craptab b
        set b.dstextab =  substr(b.dstextab,1,220)||' '||'000000100,00'||' '||'000000100,00'||' '||'0005'||' '||'0005'
        WHERE cdacesso IN ('LIMDESCONTPF','LIMDESCONTPJ') 
        AND   cdcooper = rw_crapcop.cdcooper;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro update crapaca  - ' || SQLERRM;
          DBMS_OUTPUT.PUT_LINE (vr_dscritic);
          EXIT;
      END;
  END LOOP;

END;
/

commit;
 