<?php 
	/************************************************************************
	      Fonte: riscos.php
	      Autor: Reginaldo Silva (AMcom)
	      Data : Janeiro/2018               �ltima Altera��o:  

	      Objetivo  : Mostrar aba "Riscos" da rotina de OCORR�NCIAS
                      da tela ATENDA

	      Altera��es:		

		  09/02/2018 - Inclus�o das colunas Risco Melhora e Risco Final

	************************************************************************/	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');		
	require_once('../../../includes/controla_secao.php');
    // Classe para leitura do xml de retorno
	require_once('../../../class/xmlfile.php');

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
    $msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], '@');

	if (!empty($msgError)) {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n�mero do CPF/CNPJ foi informado
	if (empty($_POST['nrcpfcnpj'])) {
		exibeErro('Par&acirc;metros incorretos.');
	}	

	$nrdconta = $_POST['nrdconta'];
	$nrcpfcnpj = $_POST['nrcpfcnpj'];
	$numDigitos = strlen($nrcpfcnpj) > 11 ? 14 : 11;
	$nrcpfcnpj = str_pad($nrcpfcnpj, 14, '0', STR_PAD_LEFT);

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro('CPF/CNPJ inv&aacute;lido.');
	}
	
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjRiscos->roottag->tags[0]->name) == 'ERRO') {
		exibeErro($xmlObjRiscos->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$listaRiscos = $xmlObjRiscos->roottag->tags[0]->tags[0]->tags;
	$dadosCentral = $xmlObjRiscos->roottag->tags[0]->tags[1]->tags;
	$riscoCentral = getByTagName($dadosCentral, 'risco_ult_central'); 
		
	// Fun��o para exibir erros na tela atrav�s de javascript
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
					<th><span title="N�mero da conta">Conta</span></th>
					<th><span title="N�mero do contrato">Contr.</span></th>
					<th><span title="Tipo de contrato">Tipo</span></th>
					<th><span title="Risco Inclus�o">R. Incl.</span></th>
					<th><span title="Rating">Rat.</span></th>
					<th><span title="Risco Atraso">R. Atr.</span></th>
					<th><span title="Risco Agravado">R. Agr.</span></th>
					<th><span title="Risco Melhora">R. Melh.</span></th>
					<th><span title="Risco da Opera��o">R. Oper.</span></th>
					<th><span title="Risco do CPF">R. CPF</span></th>
					<th><span title="Risco do Grupo Econ�mico">R. GE</span></th>					
					<th><span title="Risco Final">R. Final</span></th>
				</tr>
			</thead>
			<tbody>				
				<? 
				$riscosOperacao = array(); // riscos das opera??es para c?lculo do risco CPF
				$dadosRisco     = array(); // dados dos riscos para exibi??o na tabela
				foreach ($listaRiscos as $risco) {
					$cpfCnpj = getByTagName($risco->tags, 'cpf_cnpj');
					$cpfCnpjRaiz = extraiRaizCpfCnpj($cpfCnpj); // para o caso de CNPJ de matriz/filial

					if (!isset($riscosOperacao[$cpfCnpjRaiz])) {
						$riscosOperacao[$cpfCnpjRaiz] = array();
						$dadosRisco[$cpfCnpjRaiz] = array();
					}

					$riscoOperacao = getByTagName($risco->tags, 'risco_operacao');

					// evita arrasto de opera��es que n�o atendem ao crit�rio da materialidade
					if (getByTagName($risco->tags, 'arrasta_operacao') == 'S') {
						array_push($riscosOperacao[$cpfCnpjRaiz], $riscoOperacao);
					}

					array_push($dadosRisco[$cpfCnpjRaiz], 
						array(
							'cpf_cnpj' => $cpfCnpj,
							'numero_conta' => getByTagName($risco->tags, 'numero_conta'),
							'contrato' => getByTagName($risco->tags, 'contrato'),
							'risco_inclusao' => getByTagName($risco->tags, 'risco_inclusao'),
							'rating' => getByTagName($risco->tags, 'rating'),
							'risco_atraso' => getByTagName($risco->tags, 'risco_atraso'),
							'risco_agravado' => getByTagName($risco->tags, 'risco_agravado'),
							'risco_melhora' => getByTagName($risco->tags, 'risco_melhora'),
							'risco_operacao' => $riscoOperacao,
							'risco_grupo' => getByTagName($risco->tags, 'risco_grupo'),
							'risco_final' => getByTagName($risco->tags, 'risco_final'),
							'tipo_registro' => getByTagName($risco->tags, 'tipo_registro')
						));
				}

				foreach ($riscosOperacao as $cpfCnpj => $niveisRisco) {
					// Calcula o risco CPF como o maior risco das opera��es do mesmo CPF
					$riscoCpfCnpj = max($niveisRisco);

					foreach ($dadosRisco[$cpfCnpj] as $risco) {
						$riscoGrupo = $risco['risco_grupo'];
				?>
					<tr>
						<td><? echo aplicaMascara($risco['cpf_cnpj']); ?></td>
						<td><? echo formataContaDV($risco['numero_conta']); ?></td>
						<td><? echo number_format($risco['contrato'], 0, '', '.'); ?></td>
						<td><? echo $risco['tipo_registro']; ?></td>
						<td><? echo $risco['risco_inclusao']; ?></td>
						<td><? echo $risco['rating']; ?></td>
						<td><? echo $risco['risco_atraso']; ?></td>
						<td><? echo $risco['risco_agravado']; ?></td>
						<td><? echo $risco['risco_melhora']; ?></td>
						<td><? echo $risco['risco_operacao']; ?></td>						
						<td><? echo $riscoCpfCnpj; ?></td>
						<td><? echo $riscoGrupo ?></td>
						<td><? echo !empty($risco['risco_final']) ? $risco['risco_final'] : max($riscoCpfCnpj, $riscoGrupo); ?></td>
					</tr>
				<?
					}
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
				<label for="riscoUltimaCentral" style="width: 170px; margin-right: 15px; margin-left: 30px; font-weight: bold; display: block; float: left;">Risco �ltimo Fechamento:</label>
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
