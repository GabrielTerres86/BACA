DECLARE

  vr_aux_param VARCHAR(1000);

  CURSOR cr_cooperativas IS
    SELECT a.cdcooper
          ,CASE
             WHEN a.cdcooper = 1 THEN
              '850012'
             WHEN a.cdcooper = 16 THEN
              '1017128'
             ELSE
              '0'
           END conta
          ,'3968' historico
      FROM crapcop a
     WHERE a.flgativo = 1;
     
BEGIN

  INSERT INTO crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1 FROM crappat)
    ,'HISTORICOS_CRED_SFH'
    ,2
    ,0);

  INSERT INTO crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1 FROM crappat)
    ,'HISTORICOS_CRED_SFI'
    ,2
    ,0);
        
  INSERT INTO crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar = 'HISTORICOS_CRED_SFH')
    ,3
    ,'VLPARCELA,3697/VLMORA,3696/VLMULTA,3695/VLTAXA_ADM_PF,3805/VLTAXA_ADM_PJ,3806/VLSEGURO_MPI,3808/VLSEGURO_DFI,3807/VLPARCELA_ESTORNO_FGTS,3746/VLSALDO_DEVEDOR_FGTS,3748/');

  INSERT INTO crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar = 'HISTORICOS_CRED_SFI')
    ,3
    ,'VLPARCELA,3700/VLMORA,3699/VLMULTA,3698/VLTAXA_ADM_PF,3805/VLTAXA_ADM_PJ,3806/VLSEGURO_MPI,3808/VLSEGURO_DFI,3807/VLPARCELA_ESTORNO_FGTS,3746/VLSALDO_DEVEDOR_FGTS,3748/');    
    
    
    
    
 INSERT INTO crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1
       FROM crappat)
    ,'HISTORICOS_CRED_BOLETO_IQ'
    ,2
    ,0);

  FOR rw_cooperativas IN cr_cooperativas LOOP
    vr_aux_param := TRIM(vr_aux_param || rw_cooperativas.cdcooper || ',' || rw_cooperativas.conta || ',' ||
                         rw_cooperativas.historico || '/');
  END LOOP;

  INSERT INTO crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar
       FROM CREDITO.crappat a
      WHERE a.nmpartar = 'HISTORICOS_CRED_BOLETO_IQ')
    ,3
    ,vr_aux_param);   
    
 
 
 insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0000', 'N�o h� ocorr�ncia.', '0');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0001', 'Opera��o n�o processada pelo Ag. OP. - solicitar novamente', '1');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0002', 'Arquivo sem Header do Agente Financeiro.', '2');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0003', 'Arquivo sem o totalizador do Agente Financeiro (Trailler).', '3');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0004', 'Registro Header em duplicidade.', '4');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0005', 'Registro Trailler em duplicidade.', '5');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0006', 'Arquivo com sequencial de registro fora de ordem, ou inv�lido.', '6');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0007', 'Data da gera��o do arquivo (data do movimento), inv�lido.', '7');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0008', 'Tipo da linha incoerente com o tipo de inform��o.', '8');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0009', 'Registro com menos de 1200 caracteres.', '9');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0010', 'Registro com mais de 1200 caracteres.', '10');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0011', 'CGC/CNPJ do Agente Financeiro inv�lido.', '11');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0012', 'CGC/CNPJ da Entidade Organizadora inv�lido.', '12');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0013', 'CGC/CNPJ da Construtora Respons�vel inv�lido.', '13');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0014', 'CRF do Agente Financeiro vencido.', '14');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0015', 'CRF da Entidade Organizadora vencido.', '15');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0016', 'CRF da Construtora Respons�vel vencido.', '16');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0017', 'Projeto (Contrato CER) inv�lido ou inexistente.', '17');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0018', 'Opera��o inv�lida ou n�o est� vinculada ao Projeto.', '18');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0019', 'Opera��o/CER inexistente.', '19');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0020', 'Contrato Mutu�rio x AF n�o est� vinculado � opera��o informada.', '20');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0021', 'Mutu�rio localizado pelo contrato.', '21');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0022', 'Mutu�rio localizado pelo CPF.', '22');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0023', 'Data da assinatura inv�lida.', '23');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0024', 'Ano da data de assinatura divergente do ano or�ament�rio.', '24');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0025', 'C�digo Munic�pio n�o existe ou diverge da UF.', '25');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0026', 'Plano de Reajuste n�o informado ou inv�lido.', '26');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0027', 'Sistema de Amortiza��o n�o informado ou inv�lido.', '27');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0028', 'Taxa de Juros inv�lida de acordo com a renda, classifica��o e modalidade informados.', '28');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0029', 'Prazo de retorno acima do limite 360 meses.', '29');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0030', 'Valor de garantia acima do limite do munic�pio de acordo com o programa.', '30');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0031', 'Somat�rio do valor de empr�stimo e valor de desconto est� maior que o valor de garantia.', '31');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0032', 'Somat�rio do valor de empr�stimo e valor de desconto est� maior que o valor de avalia��o.', '32');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0033', 'Valor do financiamento incompat�vel com programa.', '33');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0034', 'Valor de avalia��o acima do limite do munic�pio de acordo com o programa.', '34');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0035', 'Classifica��o do financiamento errada.', '35');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0036', 'Data in�cio do retorno inv�lida.', '36');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0037', 'Prazo de car�ncia inv�lido.', '37');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0038', 'Renda Familiar Bruta inv�lida - igual a zero.', '38');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0039', 'Renda Familiar Bruta acima do limite do munic�pio de acordo com o programa.', '39');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0040', 'Renda Familiar Bruta acima do limite para enquadramento no programa.', '40');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0041', 'Renda Familiar Bruta acima do limite com TA - Taxa de Administra��o.', '41');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0042', 'Renda Familiar Bruta acima do limite com  DJ - Diferencial de Juros.', '42');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0043', 'Renda Familiar Bruta menor que presta��o (aviso).', '43');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0044', 'Opera��o com desconto sem TA/DJ (aviso).', '44');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0045', 'Opera��o sem desconto com TA/DJ (aviso).', '45');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0046', 'Desconto Agente Financeiro maior que o calculado pelo Agente Operador.', '46');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0047', 'Diverg�ncia no c�lculo de TA.', '47');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0048', 'Diverg�ncia no c�lculo de DJ.', '48');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0049', 'Modalidade incompat�vel com o Projeto.', '49');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0050', 'Grupo operacional incompat�vel com o programa.', '50');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0051', 'Valor do terreno inv�lido.', '51');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0052', 'Coobrigado informado sem CPF.', '52');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0053', 'Coobrigado informado sem renda.', '53');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0054', 'Sem dota��o or�ament�ria PRINCIPAL para a UF.', '54');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0055', 'Programa informado n�o localizado.', '55');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0056', 'Descri��o projeto ultrapassou o limite de caracteres.', '56');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0057', 'Nome completo projeto ultrapassou o limite de caracteres.', '57');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0058', 'Nome destaque ultrapassou o limite de caracteres.', '58');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0059', 'Endere�o ultrapassou o limite de caracteres.', '59');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0060', 'Bairro ultrapassou o limite de caracteres.', '60');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0061', 'Cidade ultrapassou o limite de caracteres.', '61');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0062', 'UF inv�lida.', '62');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0063', 'CEP ultrapassou o limite de caracteres.', '63');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0064', 'Empreendimento sem o n�mero de unidades habitacionais informado.', '64');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0065', 'GPS Lat. Grau n�o informado.', '65');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0066', 'GPS Lat. Minuto n�o informado.', '66');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0067', 'GPS Lat. Segundo n�o informado.', '67');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0068', 'GPS Long. Grau n�o informado.', '68');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0069', 'GPS Long. Minuto n�o informado.', '69');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0070', 'GPS Long. Segundo n�o informado.', '70');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0071', 'GPS Hemisf�rio n�o informado.', '71');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0072', 'GPS Local Ponto M�dio n�o informado.', '72');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0073', 'GPS Datum n�o informado.', '73');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0074', 'Data in�cio obra n�o informada ou inv�lida.', '74');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0075', 'Data final obra n�o informada ou inv�lida.', '75');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0076', 'Data t�rmino car�ncia n�o informada ou inv�lida.', '76');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0077', 'Prazo de retorno n�o informado ou inv�lido.', '77');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0078', 'In�cio do retorno n�o informado ou inv�lido.', '78');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0079', 'Taxa de juros n�o informada.', '79');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0080', 'Data assinatura do Laudo n�o informada ou inv�lida.', '80');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0081', 'QCI � Valor de Terreno inv�lido.', '81');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0082', 'QCI � Valor da Obra inv�lido.', '82');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0083', 'QCI � Valor de Equipamentos Comunit�rios inv�lido.', '83');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0084', 'QCI - Valor de Infra-estrutura inv�lido.', '84');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0085', 'QCI - Valor de outros custos inv�lido.', '85');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0086', 'Informa��o sobre Pessoa f�sica/jur�dica F/J inv�lida.', '86');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0087', 'Mutu�rio n�o localizado ou n�o contratado.', '87');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0088', 'Valor da parcela', '88');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0089', 'Valor do terreno', '89');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0090', 'Valor da antecipa��o', '90');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0091', 'Valor Glosado', '91');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0092', 'Saldo credor or�amento do VE insuficiente', '92');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0093', 'Saldo credor or�amento do desconto insuficiente', '93');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0094', 'Saldo credor or�amento da taxa de administra��o insuficiente', '94');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0095', 'Saldo credor or�amento do diferencial de juros insuficiente', '95');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0096', 'Valor total solicitado', '96');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0097', 'Data do RAE inv�lida', '97');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0098', '% de obra acumulado inv�lido', '98');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0099', 'Situa��o da obra inv�lida', '99');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0100', 'Mutu�rio localizado pelo CPF j� benefici�rio de descontos/subs�dios.', '100');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0101', 'Sem or�amento de desconto para contrata��o de im�vel usado.', '101');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0102', 'Saldo credor da opera��o (Contrato CER) do VE insuficiente', '102');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0103', 'Saldo credor do opera��o (Contrato CER) do desconto insuficiente', '103');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0104', 'Saldo credor do opera��o (Contrato CER) da taxa de administra��o insuficiente', '104');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0105', 'Saldo credor do opera��o (Contrato CER) do diferencial de juros insuficiente', '105');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0106', 'Mutu�rio n�o enquadrado para empreendimento de opera��o especial.', '106');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0107', 'Saldo credor or�amento dos descontos insuficiente', '107');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0108', 'REGRA DE TRANSI��O AT� 31/12/2018', '108');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0109', 'Sem dota��o or�ament�ria DESCONTOS para a UF.', '109');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0110', 'N�mero da opera��o alterada/atualizada', '110');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0111', 'Ultrapassado o prazo para desligamento (24 meses ap�s encerramento da obra).', '111');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0112', 'Modalidade n�o atende ao PCVA (Programa Casa Verde e Amarela)', '112');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0113', 'Contrato apresenta todas as rubricas zeradas', '113');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0114', 'Valor total do movimento abaixo do m�nimo estabelecido (R$ 10,00)', '114');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0115', 'Data de avalia��o inv�lida', '115');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0116', 'Linha de financiamento inv�lida', '116');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0117', 'Enquadramento inv�lido', '117');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0118', 'Taxa de juros do passivo incompat�vel com renda/programa', '118');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'CRITICA_CEF_FUNDING_0119', 'Contrato individual inconsistente', '119');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 1, 'CONTA_FUNDING_CONTRATO', 'Registro do movimento de inclus�o de contrato de Funding na Central', '671');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 16, 'CONTA_FUNDING_CONTRATO', 'Registro do movimento de inclus�o de contrato de Funding na Central', '680');



  UPDATE craptel t
     SET t.cdopptel = t.cdopptel || ',M'
        ,t.lsopptel = t.lsopptel || ',IMP. MAN REC'
   WHERE t.cdcooper = 3
     AND UPPER(t.nmdatela) = 'CTGIMB';

  INSERT INTO crapace
    (nmdatela
    ,cddopcao
    ,cdoperad
    ,nmrotina
    ,cdcooper
    ,nrmodulo
    ,idevento
    ,idambace)
    SELECT 'CTGIMB'
          ,'M'
          ,ope.cdoperad
          ,' '
          ,ope.cdcooper
          ,1
          ,0
          ,2
      FROM crapace ace
          ,crapope ope
     WHERE ope.cdcooper = ace.cdcooper
       AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
       AND UPPER(ace.nmdatela) = 'CTGIMB'
       AND UPPER(ace.cddopcao) = 'I'
       AND ope.cdsitope = 1
       AND ace.cdcooper = 3;

  INSERT INTO crapace
    (nmdatela
    ,cddopcao
    ,cdoperad
    ,nmrotina
    ,cdcooper
    ,nrmodulo
    ,idevento
    ,idambace)
  VALUES
    ('CTGIMB'
    ,'M'
    ,'f0033379'
    ,' '
    ,3
    ,1
    ,0
    ,2);

  INSERT INTO crapace
    (nmdatela
    ,cddopcao
    ,cdoperad
    ,nmrotina
    ,cdcooper
    ,nrmodulo
    ,idevento
    ,idambace)
  VALUES
    ('CTGIMB'
    ,'M'
    ,'f0033884'
    ,' '
    ,3
    ,1
    ,0
    ,2);
    
    INSERT INTO crapace
    (nmdatela
    ,cddopcao
    ,cdoperad
    ,nmrotina
    ,cdcooper
    ,nrmodulo
    ,idevento
    ,idambace)
  VALUES
    ('CTGIMB'
    ,'@'
    ,'f0033379'
    ,' '
    ,3
    ,1
    ,0
    ,2);

  INSERT INTO crapace
    (nmdatela
    ,cddopcao
    ,cdoperad
    ,nmrotina
    ,cdcooper
    ,nrmodulo
    ,idevento
    ,idambace)
  VALUES
    ('CTGIMB'
    ,'@'
    ,'f0033884'
    ,' '
    ,3
    ,1
    ,0
    ,2);

  INSERT INTO craprdr
    (NMPROGRA
    ,DTSOLICI)
  VALUES
    ('EMPR0025'
    ,SYSDATE);

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('PROCESSA_ARQ_FUND'
    ,'EMPR0025'
    ,'pc_processar_arq_funding_cef'
    ,'pr_tpexecuc,pr_dsdiretor,pr_dsarquivo,pr_linha_dados'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'EMPR0025'
        AND ROWNUM = 1));   
    
    
    
    
    
    
    
    
    INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('PROCESSA_ARQ_DAMP_FGTS'
    ,'EMPR0025'
    ,'pc_processar_arq_damp_fgts'
    ,'pr_tpexecuc,pr_dsdiretor,pr_dsarquivo,pr_linha_dados'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'EMPR0025'
        AND ROWNUM = 1));
    
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
    ROLLBACK;
END;





