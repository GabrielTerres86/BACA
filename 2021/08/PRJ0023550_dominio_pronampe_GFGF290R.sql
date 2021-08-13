BEGIN

  DELETE FROM cecred.tbepr_dominio_campo WHERE nmdominio = 'PRONAMPE_REJEICAOREG';    -- 15.2 C�DIGOS DE REJEI��O DOS REGISTROS DA REMESSA OU PR�-VALIDA��O
  DELETE FROM cecred.tbepr_dominio_campo WHERE nmdominio = 'PRONAMPE_PENDENCIAOP';    -- 15.11 TIPO DE PEND�NCIA DA OPERA��O
  DELETE FROM cecred.tbepr_dominio_campo WHERE nmdominio = 'PRONAMPE_SITUACAOOP';     -- 15.13 SITUA��O DA OPERA��O
  DELETE FROM cecred.tbepr_dominio_campo WHERE nmdominio = 'PRONAMPE_ENCERRAMENTOOP'; -- 15.12 MOTIVO DE ENCERRAMENTO DA OPERA��O PELO ADMINISTRADOR
  DELETE FROM cecred.tbepr_dominio_campo WHERE nmdominio = 'PRONAMPE_IMPUGNACAOOP';   -- 15.14 MOTIVO DE IMPUGNA��O DA OPERA��O
  
/* 
  15.2 C�DIGOS DE REJEI��O DOS REGISTROS DA REMESSA OU PR�-VALIDA��O
*/

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '0', 'Dados v�lidos');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '1', 'Dado inv�lido no campo TIPO DO REGISTRO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '2', 'Dado inv�lido no campo IDENTIFICADOR DA OPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '3', 'Dado inv�lido no campo N�MERO DA AG�NCIA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '4', 'A data de formaliza��o n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '5', 'Dado inv�lido no campo CPF-CNPJ DO MUTU�RIO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '6', 'Dado inv�lido no campo FINALIDADE DO CR�DITO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '7', 'Dado inv�lido no campo MODALIDADE DO CR�DITO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '8', 'Dado inv�lido no campo DATA DA FORMALIZA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '9', 'Dado inv�lido no campo DATA PREVISTA DA PRIMEIRA LIBERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '10', 'Dado inv�lido no campo VALOR PREVISTO DA PRIMEIRA LIBERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '11', 'Dado inv�lido no campo TIPO DE PESSOA DO MUTU�RIO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '12', 'Dado inv�lido no campo DATA DE VENCIMENTO DA OPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '13', 'Dado inv�lido no campo VALOR DA OPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '14', 'Dado inv�lido no campo PERCENTUAL DE GARANTIA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '15', 'Dado inv�lido no campo NOVO IDENTIFICADOR DA OPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '16', 'Faturamento superior ao m�ximo permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '17', 'Dado inv�lido no campo SALDO DEVEDOR');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '18', 'A data do cancelamento n�o pode ser anterior a outro evento j� informado');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '19', 'O saldo de capital n�o pode ser maior que o valor da opera��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '21', 'Dado inv�lido no campo VALOR FINANCIADO ADICIONAL');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '22', 'Dado inv�lido no campo DATA DO SALDO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '23', 'Dado inv�lido no campo SALDO DE CAPITAL EM NORMALIDADE');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '24', 'Dado inv�lido no campo SALDO DE CAPITAL EM ATRASO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '25', 'Dado inv�lido no campo N�VEL DE RISCO DA OPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '26', 'Dado inv�lido no campo DATA DA LIQUIDA��O DA OPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '27', 'Dado inv�lido no campo DATA DE IN�CIO DA INADIMPL�NCIA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '28', 'Dado inv�lido no campo DATA DA SOLICITA��O DE HONRA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '29', 'Dado inv�lido no campo DATA DA RECUPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '30', 'Dado inv�lido no campo VALOR RECUPERADO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '31', 'As datas informadas est�o fora de uma ordem l�gica entre si');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '32', 'Informou data futura em campo que exige data passada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '33', 'Informou data passada em campo que exige data futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '34', 'Opera��o j� cadastrada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '35', 'Evento informado ap�s o prazo limite');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '36', 'Procedimento n�o permitido para mutu�rio com opera��o honrada pelo Fundo Garantidor');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '37', 'Excedeu o valor m�ximo que pode ser garantido ao mutu�rio');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '38', 'Excedeu o valor m�ximo que pode ser garantido ao Agente Financeiro');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '39', 'Excedeu o valor m�ximo que pode ser garantido pelo Fundo');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '40', 'Dados informados resultam em CCG igual a zero');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '41', 'Opera��o n�o cadastrada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '42', 'Nenhuma altera��o em rela��o aos dados j� cadastrados');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '44', 'O Agente Financeiro excedeu seu �ndice m�ximo de valores honrados');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '45', 'J� foi informado saldo com data mais recente que esta');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '46', 'Informou saldo em normalidade para opera��o vencida');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '48', 'A data de in�cio da inadimpl�ncia n�o pode ser anterior � data de formaliza��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '50', 'N�o foi localizada a recupera��o de valor honrado com os dados informados');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '51', 'Procedimento n�o permitido para opera��o na situa��o NORMALIDADE');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '52', 'Procedimento n�o permitido para opera��o na situa��o ATRASADA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '53', 'Procedimento n�o permitido para opera��o na situa��o CANCELADA PELO AGENTE COM DEVOL CCG');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '54', 'Procedimento n�o permitido para opera��o na situa��o ENCERRADA PELO ADMINISTRADOR');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '55', 'Procedimento n�o permitido para opera��o na situa��o HONRADA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '56', 'Procedimento n�o permitido para opera��o na situa��o LIQUIDADA AP�S A HONRA DA GARANTIA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '57', 'Procedimento n�o permitido para opera��o na situa��o LIQUIDADA SEM HONRA DA GARANTIA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '58', 'Dado inv�lido no campo SALDO BASE PARA C�LCULO DO VALOR HONRADO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '59', 'A data de in�cio da inadimpl�ncia n�o confere com as informa��es de saldo anteriores');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '60', 'Per�odo de inadimpl�ncia menor que o m�nimo exigido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '61', 'Per�odo de inadimpl�ncia maior que o m�ximo permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '62', 'Dado inv�lido no campo C�DIGO IBGE DO MUNIC�PIO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '64', 'Dado inv�lido no campo TIPO DE P�BLICO ALVO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '65', 'Dado inv�lido no campo FATURAMENTO BRUTO ANUAL');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '66', 'Dado inv�lido no campo DATA DA LIBERA��O OU ACP');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '67', 'Dado inv�lido no campo VALOR DA LIBERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '68', 'Dado inv�lido no campo VALOR DA CCG');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '69', 'Dado inv�lido no campo SALDO DE ENCARGOS EM NORMALIDADE');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '70', 'Dado inv�lido no campo SALDO DE ENCARGOS EM ATRASO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '72', 'A data do saldo n�o pode ser anterior � primeira libera��o de cr�dito');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '88', 'Dado inv�lido no campo DATA DO CANCELAMENTO DA OPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '92', 'Valor garantido maior que o m�ximo permitido para a finalidade INVESTIMENTO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '93', 'Valor Garantido maior que o m�ximo permitido para a finalidade CAPITAL DE GIRO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '94', 'Percentual de garantia menor que o m�nimo exigido para a finalidade INVESTIMENTO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '95', 'Percentual de garantia menor que o m�nimo exigido para a finalidade CAPITAL DE GIRO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '96', 'Percentual de garantia maior que o m�ximo permitido para a finalidade INVESTIMENTO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '97', 'Percentual de garantia maior que o m�ximo permitido para a finalidade CAPITAL DE GIRO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '100', 'Dado inv�lido no campo DATA DA ALTERA��O DA OPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '103', 'O valor liberado somado com as libera��es anteriores n�o pode superar o valor da opera��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '104', 'A CCG informada n�o confere com a CCG calculada pelo Administrador');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '107', 'Dado inv�lido no campo DATA DA RECUPERA��O A CANCELAR');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '108', 'Procedimento n�o permitido para opera��o na situa��o IMPUGNADA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '109', 'A data de liquida��o n�o pode ser menor que a data do �ltimo saldo informado');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '110', 'C�digo de p�blico alvo n�o permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '113', 'Dado inv�lido no campo DATA DA REATIVA��O DA OPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '114', 'Dado inv�lido no campo DATA DA DEVOLU��O DO VALOR HONRADO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '116', 'A data da devolu��o n�o pode ser anterior � data da honra da garantia');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '117', 'Procedimento n�o permitido para opera��o na situa��o FORMALIZADA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '119', 'Procedimento n�o permitido para opera��o na situa��o CANCELADA PELO AGENTE SEM DEVOL CCG');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '120', 'O valor liberado n�o pode ser maior que o valor da opera��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '121', 'Agente Financeiro n�o habilitado a operar com este Fundo Garantidor na data do evento');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '122', 'A data da libera��o de cr�dito ou ACP n�o pode ser maior que a data de vencim. da opera��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '123', 'A data da formaliza��o n�o pode ser menor que a data de vencimento da opera��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '124', 'O valor da opera��o n�o pode ser menor que o seu saldo devedor');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '125', 'Dado inv�lido no campo DATA DO CANCELAMENTO DA RECUPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '126', 'Dado inv�lido no campo VALOR DA RECUPERA��O A CANCELAR');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '127', 'A data da altera��o n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '128', 'Procedimento n�o permitido para opera��o com pend�ncia');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '129', 'CPF/CNPJ inv�lido junto � Receita Federal do Brasil');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '130', 'N�o deve ser cobrada CCG nesta libera��o de cr�dito/ACP');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '131', 'Dado inv�lido no campo TIPO DE CRONOGRAMA DE AMORTIZA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '132', 'Dado inv�lido no campo CONDI��O ESPECIAL DA OPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '133', 'Dado inv�lido no campo DATA PREVISTA DE VENCIMENTO DA OPERA��O');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '134', 'A data de vencimento n�o pode ser alterada em opera��o com cronograma do tipo independente');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '135', 'N�o permitido cronograma INDEPENDENTE para a modalidade/finalidade de cr�dito da opera��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '136', 'A data da libera��o de cr�dito ou ACP n�o pode ser anterior � data de formaliz. da oper.');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '137', 'A data da libera��o do cr�dito ou ACP n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '138', 'A data da reativa��o n�o pode ser anterior � data de liquida��o da opera��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '139', 'A data da reativa��o n�o pode ser posterior � data de vencimento da opera��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '140', 'Dado inv�lido no campo DATA DO DESPACHO EXTERNO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '142', 'Modalidade de cr�dito incompat�vel com a condi��o especial');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '143', 'Procedimento n�o permitido para opera��o na situa��o PARCELADA AP�S A HONRA DA GARANTIA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '144', 'Dado inv�lido no campo DATA DO PARCELAMENTO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '145', 'Dado inv�lido no campo VALOR DO SALDO PARCELADO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '146', 'Dado inv�lido no campo DATA DE VENCIMENTO DO PARCELAMENTO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '147', 'A data do parcelamento n�o pode ser anterior � data da honra da garantia');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '148', 'A data do parcelamento n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '149', 'O saldo parcelado difere do saldo honrado a recuperar na data do parcelamento');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '150', 'A data de vencimento do parcelamento n�o pode ser anterior � data do parcelamento');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '151', 'Prazo de parcelamento maior que o m�ximo permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '152', 'Dado inv�lido no campo FONTE DE RECURSOS');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '153', 'Dado inv�lido no campo PROGRAMA DE CR�DITO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '154', 'Prazo da opera��o maior que o m�ximo permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '155', 'O c�digo de p�blico alvo � incompat�vel com a condi��o especial');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '156', 'Data em dia n�o �til');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '157', 'O saldo n�o pode ser zero na en�sima libera��o em opera��o da modalidade CR�DITO FIXO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '158', 'A data do saldo deve ser o �ltimo dia do m�s');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '159', 'A data do saldo n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '160', 'A data da solicita��o de honra n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '161', 'A data do cancelamento n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '162', 'A data da liquida��o n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '163', 'A data da reativa��o n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '164', 'Tipo de condi��o especial n�o permitido nessa data de formaliza��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '165', 'Tipo de condi��o especial n�o permitido nessa data de despacho externo');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '166', 'Saldo base incompat�vel com saldos anteriores da opera��o, conforme metodologia de c�lculo');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '167', 'A data da altera��o n�o pode ser anterior � data da formaliza��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '168', 'O saldo devedor somado com o valor liberado n�o pode ser maior que o valor da opera��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '169', 'A data desta libera��o de cr�dito/ACP n�o pode ser anterior � ultima informada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '170', 'A data da libera��o de cr�dito/ACP n�o pode ser anterior � data do despacho externo');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '171', 'A data do cancelamento n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '172', 'Procedimento n�o permitido para mutu�rio com opera��o LIQUIDADA P�S-HONRA COM ABATIMENTO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '173', 'Procedimento n�o permitido para mutu�rio com opera��o CEDIDA P�S-HONRA COM DES�GIO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '174', 'Dado inv�lido no campo VALOR DO ABATIMENTO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '175', 'Dado inv�lido no campo TIPO DE ABATIMENTO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '176', 'Procedimento n�o permitido para opera��o na situa��o LIQUIDADA P�S-HONRA COM ABATIMENTO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '177', 'Procedimento n�o permitido para opera��o na situa��o CEDIDA P�S-HONRA COM DES�GIO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '178', 'J� existe opera��o formalizada com o identificador da opera��o substituta');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '179', 'A data da recupera��o deve ser dia �til');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '180', 'A data da recupera��o n�o pode ser anterior � data de solicita��o da honra');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '181', 'A data da recupera��o n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '183', 'O valor do abatimento � compat�vel com o tipo de abatimento');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '184', 'N�o cumpriu o prazo m�nimo desde a solicita��o de honra para conceder abatimento');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '185', 'N�o cumpriu o prazo m�nimo desde a solicita��o de honra para fazer cess�o com des�gio');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '187', 'A recupera��o a cancelar n�o foi a �ltima informada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '188', 'O saldo base informado resulta em valor honrado igual a zero');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '189', 'O c�digo de p�blico alvo � incompat�vel com o tipo de pessoa');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '190', 'Dados informados na remessa divergem dos informados na pr�-valida��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '192', 'Esta opera��o j� foi pr�-validada com reserva');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '193', 'Procedimento n�o permitido para mutu�rio com opera��o PARCELADA POS-HONRA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '194', 'A opera��o original n�o foi liquidada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '195', 'A data do cancelamento n�o pode ser anterior � data da recupera��o a cancelar');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '196', 'Procedimento n�o permitido para opera��o que foi liquidada para novacao de divida');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '197', 'C�digo do tipo de formaliza��o inv�lido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '199', 'N�o foi localizada a opera��o liquidada para a nova��o da divida');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '200', 'O valor recuperado junto com o abatimento est� abaixo do m�nimo exigido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '202', 'A data do abatimento n�o pode ser anterior a uma recupera��o ou abatimento j� informado');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '203', 'A data do abatimento n�o pode ser futura');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '204', 'A data do abatimento n�o pode ser anterior � data da honra da garantia');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '205', 'O prazo entre o in�cio da inadimpl�ncia e a data do abatimento � menor que o permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '206', 'Prazo entre os abatimentos e menor que o permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '207', 'J� foi processado evento anterior que utilizou este n�mero de reserva');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '208', 'A reserva expirou por decurso de prazo');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '209', 'A reserva foi cancelada pelo Agente Financeiro');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '210', 'N�mero de reserva n�o localizado');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '211', 'Dado invalido no campo NUMERO DA RESERVA');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '212', 'abatimento acima do percentual m�ximo permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '213', 'O valor do abatimento n�o corresponde ao saldo honrado a recuperar');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '214', 'O valor do abatimento n�o pode ser maior nem igual ao saldo honrado');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '215', 'Dado invalido no campo DATA DO ABATIMENTO');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '216', 'O prazo entre a honra da garantia e o abatimento � menor que o permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '217', 'Este tipo de evento n�o estava habilitado na data informada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '218', 'J� foi processado evento de abatimento ap�s a recupera��o a cancelar');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '219', 'N�o � permitido aumentar o valor da opera��o de nova��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '220', '� proibida mais de uma libera��o de cr�dito em opera��o do tipo "nova��o de d�vida"');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '221', 'Prazo da opera��o menor que o m�nimo permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '222', 'Opera��o formalizada fora do per�odo permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '223', 'O valor da opera��o n�o pode ser alterado');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '224', 'A altera��o da data de vencimento deve ser feita pelo evento 10');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '225', 'O valor liberado n�o pode ser zero');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '226', 'Empresa com mais de 1 ano de funda��o deve informar faturamento maior que zero');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '227', 'Excedeu o valor m�ximo que pode ser financiado com base no faturamento do mutu�rio');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '228', 'Excedeu o valor m�ximo que pode ser financiado pelo Agente com a garantia desse Fundo');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '229', 'Tipo de evento n�o habilitado para este Fundo Garantidor');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '230', 'Excedeu o valor m�ximo que pode ser financiado a empresa com menos de 1 ano');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '231', 'Excedeu o valor m�ximo que pode ser financiado a cada mutu�rio');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '232', 'Excedeu o valor m�ximo que pode ser honrado pelo Fundo');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '233', 'Faturamento bruto anual inv�lido junto � RFB');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '234', 'Opera��o n�o cadastrada no SCR do BACEN');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '235', 'O faturamento informado anteriormente ainda est� pendente de valida��o pela RFB');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '236', 'O faturamento informado anteriormente foi validado pela RFB');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '237', 'Opera��o pendente de valida��o no SCR do BACEN');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '240', 'Tipo de Programa de Cr�dito n�o permitido para esta opera��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '241', 'Altera��o de vencimento n�o permitida para esta opera��o');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '242', 'O prazo adicional, em rela��o � opera��o original, � maior que o permitido');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '243', 'Solicita��o de honra n�o permitida para o per�odo em que a opera��o foi formalizada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '244', 'O c�digo de p�blico alvo � incompat�vel com o faturamento');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '245', 'N�o permitido para opera��o formalizada em ano anterior');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_REJEICAOREG', '999', 'Registro rejeitado por outro motivo (consulte o Administrador do Fundo)');

/*
  15.11 TIPO DE PEND�NCIA DA OPERA��O
*/

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_PENDENCIAOP', '1', 'Saldo devedor n�o informado pelo Agente');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_PENDENCIAOP', '2', 'Opera��o de cr�dito fixo com saldo devedor zero');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_PENDENCIAOP', '3', 'Opera��o vencida e com saldo em normalidade');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_PENDENCIAOP', '4', 'Faturamento bruto anual inv�lido junto � RFB');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_PENDENCIAOP', '5', 'Opera��o n�o cadastrada no SCR do BACEN');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_PENDENCIAOP', '6', 'Ap�s alterar FBA, a opera��o excedeu o valor m�ximo financi�vel mutu�rio');


/*
  15.12 MOTIVO DE ENCERRAMENTO DA OPERA��O PELO ADMINISTRADOR
*/

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_ENCERRAMENTOOP', '1', 'Saldo devedor n�o informado pelo Agente');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_ENCERRAMENTOOP', '2', 'Opera��o de cr�dito fixo com saldo devedor zero');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_ENCERRAMENTOOP', '3', 'Opera��o vencida e com saldo em normalidade');


/*
  15.13 SITUA��O DA OPERA��O
*/


  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '1', 'Formalizada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)  
    VALUES ('PRONAMPE_SITUACAOOP', '2', 'Normalidade');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '3', 'Atrasada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '4', 'Honrada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '5', 'Liquidada p�s-honra sem abatimento');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '6', 'Liquidada sem honra');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '7', 'Cancelada pelo Agente com devolu��o de CCG');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '8', 'Cancelada pelo Agente sem devolu��o de CCG');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '9', 'Encerrada pelo Administrador');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '10', 'Impugnada');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '11', 'Parcelada p�s-honra');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '12', 'Liquidada p�s-honra com abatimento');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_SITUACAOOP', '13', 'Cedida p�s-honra com des�gio');


/*
  15.14 MOTIVO DE IMPUGNA��O DA OPERA��O
*/

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_IMPUGNACAOOP', '1', 'Opera��o contratada em desacordo com as normas');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_IMPUGNACAOOP', '2', 'Honra de garantia solicitada em desacordo com as normas');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_IMPUGNACAOOP', '3', 'Opera��o impugnada por outro motivo (consulte o Administrador do Fundo)');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_IMPUGNACAOOP', '4', 'Faturamento bruto anual inv�lido junto � RFB');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_IMPUGNACAOOP', '5', 'Opera��o n�o cadastrada no SCR do BACEN');

  INSERT INTO cecred.tbepr_dominio_campo (nmdominio, cddominio, dscodigo)
    VALUES ('PRONAMPE_IMPUGNACAOOP', '6', 'Ap�s alterar FBA, a opera��o excedeu o valor m�ximo financi�vel mutu�rio');

  COMMIT;
END;
