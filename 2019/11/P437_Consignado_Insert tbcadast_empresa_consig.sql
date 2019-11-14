-- Script de carga da tabela tbcadast_empresa_consig e tbcadast_emp_consig_param
-- onde irá considerar as empresas das cooperativas Acredicoop , Acentra , Credifoz  e 
-- indicador de empresa consignado = 2
-- Para as empresas que conter a palavras "PUBLICO", "PREFEITURA","CAMARA" OU "MUNICIPAL"
-- Será considerado o tipo do consignado como "Publico", caso contrário "Privado"
-- P437 - Consignado - Josiane Stiehler - AMcom 21/03/2019
DECLARE
CURSOR cr_crapemp IS
select a.cdcooper,
       a.cdempres,
       a.dsdemail,
       DECODE(instr(UPPER(a.nmextemp),'PUBLICO'),0, 
              DECODE(instr(UPPER(a.nmextemp),'PREFEITURA'),0,
              DECODE(instr(UPPER(a.nmextemp),'CAMARA'),0,
              DECODE(instr(UPPER(a.nmextemp),'MUNICIPAL'),0,1,2),2),2),2) tpmodconvenio,
       a.dtfchfol
from crapemp a
where a.indescsg = 2 -- empresa consignado
and a.cdcooper in (1,6,7,8,9,10,11,12,14,16)  -- cooperativas 
and a.dtfchfol > 8; ---Corrigir a regra para quem tem a data de fechamaento < 9

vr_mes_novo_de        number;
vr_mes_novo_ate       number;
vr_mes_novo_arq       number;
vr_mes_novo_venc      number;     
vr_idemprconsig       tbcadast_empresa_consig.IDEMPRCONSIG%type;
vr_idemprconsigparam  tbcadast_emp_consig_param.idemprconsigparam%type;

BEGIN
  FOR rg_crapemp in cr_crapemp
  LOOP
   -- dbms_output.put_line (' empresa :'||rg_crapemp.cdempres);
    BEGIN
      DELETE tbcadast_emp_consig_param
       WHERE idemprconsig IN (select idemprconsig
                                from tbcadast_empresa_consig
                               where cdcooper = rg_crapemp.cdcooper
                                 and cdempres = rg_crapemp.cdempres);
                                   
      DELETE tbcadast_empresa_consig a
       WHERE a.cdcooper  = rg_crapemp.cdcooper
         AND a.cdempres  =  rg_crapemp.cdempres;
       
      INSERT INTO tbcadast_empresa_consig
              (--IDEMPRCONSIG         --Sequencial da tabela.                                                                                                  
               CDCOOPER             --Codigo que identifica a Cooperativa.                                                                                   
              ,CDEMPRES             --Codigo da empresa.                                                                                                     
              ,INDCONSIGNADO        --Indicador de convenio de desconto consignado em folha de pagamento esta habilitado. 0 - Desabilitado / 1 - Habilitado. 
              ,DTATIVCONSIGNADO     --Data de habilitacao do convenio de desconto consignado.                                                                
              ,TPMODCONVENIO        --Tipo de Modalidade de Convenio (1 - Privado, 2 . Publico e 3 - INSS).                                                  
              ,NRDIALIMITEREPASSE   --Dia limite para Repasse. (de 1 a 31).                                                                                  
              ,INDAUTREPASSECC      --Autorizar Debito Repasse em C/C. (0 - Não Autorizado / 1 - Autorizado)                                                 
              ,INDINTERROMPER       --Indicador de Interrupcao de Cobranca. (0 - Não Interromper / 1 - Interromper)                                          
              ,DSDEMAILCONSIG       --E-mail de contato consignado da empresa.                                                                               
              ,INDALERTAEMAILEMP    --Indicador se deve receber alerta no e-mail da empresa (0 - Nao Receber / 1 - Receber)                                  
              ,INDALERTAEMAILCONSIG --Indicador se deve receber alerta no e-mail de contanto consignado da empresa (0 - Nao Receber / 1 - Receber)           
              ,DTINTERROMPER)       --Data de Interrupcao de Cobranca.   
        VALUES
              (--seq_tbc_emp_cons_idemprconsig.nextval --IDEMPRCONSIG                                                                              
               rg_crapemp.cdcooper                   --CDCOOPER
              ,rg_crapemp.cdempres                   --CDEMPRES
              ,1 -- habilitado                       --INDCONSIGNADO
              ,trunc(sysdate)                        --DTATIVCONSIGNADO
              ,rg_crapemp.tpmodconvenio              --TPMODCONVENIO       
              ,10                                    --NRDIALIMITEREPASSE  
              ,decode(rg_crapemp.tpmodconvenio,1,1,0) --INDAUTREPASSECC     1- autorizado - 1-privado, 0 -não autorizado 2-publico
              ,0                       --INDINTERROMPER      
              ,null                    --DSDEMAILCONSIG    
              ,1                       --INDALERTAEMAILEMP   
              ,0                       --INDALERTAEMAILCONSIG
              ,null)                   --DTINTERROMPER)      
            returning IDEMPRCONSIG into vr_idemprconsig;
    EXCEPTION
     WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro tbcadast_empresa_consig - empresa :'||rg_crapemp.cdempres||' - '||seq_tbc_emp_cons_idemprconsig.nextval||sqlerrm );
      raise_application_error (-20343,'erro :'||vr_idemprconsig||' - '||sqlerrm);
    END;
    ----preenche os parametros----    
    vr_mes_novo_de   := to_char(sysdate,'MM');
    vr_mes_novo_ate  := to_char(sysdate,'MM') +1;
    vr_mes_novo_arq  := to_char(sysdate,'MM') +1;
    vr_mes_novo_venc := to_char(sysdate,'MM') +1;

    FOR CONTADOR IN 1..12 
    LOOP
      --Mês de inclusão da proposta De (DD/MM)
      IF vr_mes_novo_de < 12 THEN
        vr_mes_novo_de := vr_mes_novo_de + 1;
      ELSIF vr_mes_novo_de = 12 THEN  
        vr_mes_novo_de := 1;
      ELSE
        vr_mes_novo_de := vr_mes_novo_de + 1;
      END IF;
      
      --Mês de inclusao da proposta Ate(DD/MM).
      IF vr_mes_novo_ate < 12 THEN
        vr_mes_novo_ate := vr_mes_novo_ate + 1;
      ELSIF vr_mes_novo_ate = 12 THEN  
        vr_mes_novo_ate := 1;
      ELSE
        vr_mes_novo_ate := vr_mes_novo_ate + 1;
      END IF;
      
      --Mês do envio do arquivo (DD/MM).
      IF vr_mes_novo_arq < 12 THEN
        vr_mes_novo_arq := vr_mes_novo_arq + 1;
      ELSIF vr_mes_novo_arq = 12 THEN  
        vr_mes_novo_arq := 1;
      ELSE
        vr_mes_novo_arq := vr_mes_novo_arq + 1;
      END IF;
      
      --Data do vencimento (DD/MM).
      IF vr_mes_novo_venc < 12 THEN
        vr_mes_novo_venc := vr_mes_novo_venc + 1;
      ELSIF vr_mes_novo_venc = 12 THEN  
        vr_mes_novo_venc := 1;
      ELSE
        vr_mes_novo_venc := vr_mes_novo_venc + 1;
      END IF;
 
     ------------------------------------------------
      BEGIN
        INSERT INTO  tbcadast_emp_consig_param
                (--IDEMPRCONSIGPARAM  --Sequencial da tabela                    
                 IDEMPRCONSIG       --Sequencial da tabela                    
                ,DTINCLPROPOSTADE   --Data de inclusão da proposta De (DD/MM)  
                ,DTINCLPROPOSTAATE  --Data de inclusao da proposta Ate(DD/MM) 
                ,DTENVIOARQUIVO     --Data do envio do arquivo (DD/MM)        
                ,DTVENCIMENTO       --Data do vencimento (DD/MM) 
                )
          VALUES(--vr_idemprconsig                    --IDEMPRCONSIGPARAM 
                 vr_idemprconsig   --IDEMPRCONSIG      
                ,trunc(to_date(rg_crapemp.dtfchfol - 7||'/'||
                 vr_mes_novo_de||'/1900','dd/mm/yyyy'))  --DTINCLPROPOSTADE  
                ,trunc(to_date(rg_crapemp.dtfchfol -8||'/'||
                 vr_mes_novo_ate||'/1900','dd/mm/yyyy')) --DTINCLPROPOSTAATE 
                ,trunc(to_date(rg_crapemp.dtfchfol -7||'/'||
                 vr_mes_novo_arq||'/1900','dd/mm/yyyy')) --DTENVIOARQUIVO    
                ,trunc(to_date(rg_crapemp.dtfchfol||'/'||
                 vr_mes_novo_venc||'/1900','dd/mm/yyyy')) --DTVENCIMENTO)      
                 )
            return idemprconsigparam into vr_idemprconsigparam;
      EXCEPTION
       WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro tbcadast_emp_consig_param - empresa :'||rg_crapemp.cdempres
                              ||' - '||vr_idemprconsigparam||sqlerrm );
        raise_application_error (-20344,'erro :'||' - '||vr_idemprconsig||
                                 ' - '||vr_idemprconsigparam||' - '||sqlerrm);                              
      END;
    END LOOP;
  END LOOP;
  COMMIT;    
END;
/
