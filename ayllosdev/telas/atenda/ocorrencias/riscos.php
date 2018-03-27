<?php 
	/************************************************************************
	      Fonte: riscos.php
	      Autor: Reginaldo Silva (AMcom)
	      Data : Janeiro/2018               Última Alteração:  

	      Objetivo  : Mostrar aba "Riscos" da rotina de OCORRÊNCIAS
                      da tela ATENDA

	      Alterações:		

		  09/02/2018 - Inclusão das colunas Risco Melhora e Risco Final

	************************************************************************/	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');		
	require_once('../../../includes/controla_secao.php');
    // Classe para leitura do xml de retorno
	require_once('../../../class/xmlfile.php');

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
    $msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], '@');

	if (!empty($msgError)) {
		exibeErro($msgError);		
	}	
	
	// Verifica se o número do CPF/CNPJ foi informado
	if (empty($_POST['nrcpfcnpj'])) {
		exibeErro('Par&acirc;metros incorretos.');
	}	

	$nrdconta = $_POST['nrdconta'];
	$nrcpfcnpj = $_POST['nrcpfcnpj'];
	$numDigitos = strlen($nrcpfcnpj) > 11 ? 14 : 11;
	$nrcpfcnpj = str_pad($nrcpfcnpj, 14, '0', STR_PAD_LEFT);

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro('CPF/CNPJ inv&aacute;lido.');
	}
	
	// Monta o xml de requisição
	$xml = "<Root>";
    $xml .= " <Dados>";
	$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "   <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResultRiscos = mensageria($xml, "TELA_ATENDA_OCORRENCIAS", "BUSCA_DADOS_RISCO", 
		$glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
		$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    
	// Cria objeto para classe de tratamento de XML
	$xmlObjRiscos = getObjectXML($xmlResultRiscos);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRiscos->roottag->tags[0]->name) == 'ERRO') {
		exibeErro($xmlObjRiscos->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$listaRiscos = $xmlObjRiscos->roottag->tags[0]->tags[0]->tags;
	$dadosCentral = $xmlObjRiscos->roottag->tags[0]->tags[1]->tags;
	$riscoCentral = getByTagName($dadosCentral, 'risco_ult_central'); 
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo "<script type='text/javascript'>";
		echo "hideMsgAguardo();";
		echo "showError('error','".$msgErro."','Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');";
		echo "</script>";

		exit();
	}

	function aplicaMascara($str)
	{
		$numDigitos = strlen($str) > 11 ? 14 : 11;		
		$str = str_pad($str, $numDigitos, '0', STR_PAD_LEFT);
		
		if (strlen($str) == 11) {
			$str = substr($str, 0, 3) . '.' . substr($str, 3, 3) . '.' .
				substr($str, 6, 3) . '-'. substr($str, 9, 2);
		}
		else {
			$str = substr($str, 0, 2) . '.' . substr($str, 2, 3) . '.' .
				substr($str, 5, 3) . '/'. substr($str, 8, 4) . '-' . 
				substr($str, 12, 2);
		}

		return $str;
	}	

	function extraiRaizCpfCnpj($cpfCnpj)
	{
		$cpfCnpj = str_pad($cpfCnpj, 14, '0', STR_PAD_LEFT);

		if (strlen($cpfCnpj) == 11)  {
			return $cpfCnpj;
		}

		return substr($cpfCnpj, 0, 8);
	}
?>
<div id='divTabRiscos'>
	<div class='divRegistros'>	
		<table>
			<thead>
				<tr>
					<th><span title="CPF/CNPJ">CPF/CNPJ</span></th>
					<th><span title="Número da conta">Conta</span></th>
					<th><span title="Número do contrato">Contr.</span></th>
					<th><span title="Tipo de contrato">Tipo</span></th>
					<th><span title="Risco Inclusão">R. Incl.</span></th>
					<th><span title="Rating">Rat.</span></th>
					<th><span title="Risco Atraso">R. Atr.</span></th>
					<th><span title="Risco Agravado">R. Agr.</span></th>
					<th><span title="Risco Melhora">R. Melh.</span></th>
					<th><span title="Risco da Operação">R. Oper.</span></th>
					<th><span title="Risco do CPF">R. CPF</span></th>
					<th><span title="Risco do Grupo Econômico">R. GE</span></th>					
					<th><span title="Risco Final">R. Final</span></th>
				</tr>
			</thead>
			<tbody>				
				<? 
				foreach ($listaRiscos as $risco) {
				?>
					<tr>
						<td><? echo aplicaMascara(getByTagName($risco->tags, 'cpf_cnpj')); ?></td>
						<td><? echo formataContaDV(getByTagName($risco->tags, 'numero_conta')); ?></td>
						<td><? echo number_format(getByTagName($risco->tags, 'contrato'), 0, '', '.'); ?></td>
						<td><? echo getByTagName($risco->tags, 'tipo_registro'); ?></td>
						<td><? echo getByTagName($risco->tags, 'risco_inclusao'); ?></td>
						<td><? echo getByTagName($risco->tags, 'rating'); ?></td>
						<td><? echo getByTagName($risco->tags, 'risco_atraso'); ?></td>
						<td><? echo getByTagName($risco->tags, 'risco_agravado'); ?></td>
						<td><? echo getByTagName($risco->tags, 'risco_melhora'); ?></td>
						<td><? echo getByTagName($risco->tags, 'risco_operacao'); ?></td>						
						<td><? echo getByTagName($risco->tags, 'risco_cpf'); ?></td>
						<td><? echo getByTagName($risco->tags, 'risco_grupo'); ?></td>
						<td><? echo getByTagName($risco->tags, 'risco_final'); ?></td>
					</tr>					
				<?
					}
				?>
			</tbody>
		</table>
	</div>
	<div id="infoCentral" style="padding-top: 7px;">
		<div id="infoUltimaCentral" style="float: left; width: 50%; text-align: left;">
			<label for="riscoCooperado" style="width: 170px; margin-right: 15px; margin-left: 30px; font-weight: bold; display: block; float: left;">Risco Cooperado:</label>
			<input type="text" name="riscoCooperado" id="riscoCooperado" value="<? echo getByTagName($dadosCentral, 'risco_cooperado'); ?>" readonly tabindex="-1" style="width: 90px; text-align: center; outline: 1px solid grey; display: block; float: left; position: relative;">
			<br>
			<div style="margin-top: 10px;">
				<label for="riscoUltimaCentral" style="width: 170px; margin-right: 15px; margin-left: 30px; font-weight: bold; display: block; float: left;">Risco Último Fechamento:</label>
				<input type="text" name="riscoUltimaCentral" id="riscoUltimaCentral" value="<? echo getByTagName($dadosCentral, 'risco_ult_central');/*!empty($riscoCentral) ? $riscoCentral : 'A';*/ ?>" readonly tabindex="-1" style="width: 40px; text-align: center; outline: 1px solid grey; display: block; float: left; position: relative;">
			</div>
		</div>
		<div id="infoRiscoFinal" style="float: right; width: 50%; text-align: left;">
		    <label for="dataRisco" style="width: 130px; margin-right: 15px; margin-left: 30px; font-weight: bold; display: block; float: left;">Data do risco:</label>
			<input type="text" name="dataUltimaCentral" id="dataUltimaCentral" value="<? echo getByTagName($dadosCentral, 'data_risco'); ?>" readonly tabindex="-1" style="width: 80px; text-align: center; outline: 1px solid grey; display: block; float: left; margin-left: 10px; position: relative;">
			<br>
			<div style="margin-top: 10px;">
				<label for="dataRisco" style="width: 130px; margin-right: 15px; margin-left: 30px; font-weight: bold; display: block; float: left;">Qtd. Dias no risco:</label>
				<input type="text" name="diasRisco" id="diasRisco" value="<? echo getByTagName($dadosCentral, 'qtd_dias_risco'); ?>" readonly tabindex="-1" style="width: 80px; text-align: center; outline: 1px solid grey; display: block; float: left; margin-left: 10px; position: relative;">
			</div>
		</div>
	</div>
</div>

<script type='text/javascript'>
	// Formata layout
	formataRiscos();
	// Esconde mensagem de aguardo
	hideMsgAguardo();
	// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
	blockBackground(parseInt($('#divRotina').css('z-index')));
</script>
