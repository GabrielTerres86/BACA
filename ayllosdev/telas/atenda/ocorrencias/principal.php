<?php 

	 /****************************************************************************************
	    Fonte: principal.php
	    Autor: Guilherme
	    Data : Fevereiro/2008                 Última Alteração: 31/10/2012

	    Objetivo  : Mostrar opcao Principal da rotina de OCORRENCIAS
                    da tela ATENDA

	    Alterações: 26/02/2010 - Alterar descrição (dd) por (ocor) (David).
					
					19/08/2010 - Incluido os campos "Data de Risco" e "Dias no Risco" (Elton).
					
					06/04/2011 - Incluido campo "Risco Cooperado" (Adriano).

					13/07/2011 - Alterado para layout padrão (Rogerius - DB1). 	
					
					31/10/2012 - Incluido o campo "Risco Grupo Economico" (Adriano).
		
	 *****************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlGetOcorrencia  = "";
	$xmlGetOcorrencia .= "<Root>";
	$xmlGetOcorrencia .= "	<Cabecalho>";
	$xmlGetOcorrencia .= "		<Bo>b1wgen0027.p</Bo>";
	$xmlGetOcorrencia .= "		<Proc>lista_ocorren</Proc>";
	$xmlGetOcorrencia .= "	</Cabecalho>";
	$xmlGetOcorrencia .= "	<Dados>";
	$xmlGetOcorrencia .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetOcorrencia .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetOcorrencia .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetOcorrencia .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetOcorrencia .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetOcorrencia .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetOcorrencia .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlGetOcorrencia .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlGetOcorrencia .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetOcorrencia .= "		<idseqttl>1</idseqttl>";
	$xmlGetOcorrencia .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetOcorrencia .= "	</Dados>";
	$xmlGetOcorrencia .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetOcorrencia);
	
	// Cria objeto para classe de tratamento de XML
	$xmlGetOcorrencia = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlGetOcorrencia->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlGetOcorrencia->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$ocorrencia = $xmlGetOcorrencia->roottag->tags[0]->tags[0]->tags;
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<form action="" method="post" name="frmOcorrencias" id="frmOcorrencias" class="formulario" style="margin-top: 20px;">

	<label for="campo00">Contra Ordens:</label>
	<input id="campo00" type="text" value="<?php echo $ocorrencia[0]->cdata; ?>" />
	
	<label for="campo01">Devolu&ccedil;&otilde;es:</label>
	<input id="campo01" type="text" value="<?php echo $ocorrencia[1]->cdata; ?>" />
	
	<br />
	
	<label for="campo02">Consulta SPC:</label>
	<input id="campo02" type="text" value="<?php echo $ocorrencia[2]->cdata; ?>" />

	<label for="campo03">No SPC p/ Coop:</label>
	<input id="campo03" type="text" value="<?php echo $ocorrencia[3]->cdata; ?>" />
	
	<br />
	
	<label for="campo04">Cr&eacute;dito L&iacute;quido:</label>
	<input id="campo04" type="text" value="<?php echo $ocorrencia[4]->cdata; ?>" />
	
	<label for="campo05">(dd)</label>
	<input id="campo05" type="text" value="<?php echo $ocorrencia[5]->cdata; ?>" />
	
	<label for="campo06">Estouros:</label>
	<input id="campo06" type="text" value="<?php echo $ocorrencia[6]->cdata ?>" />
	<label for="ocor">(ocor)</label>
	
	<br />
	
	<label for="campo07">Est&aacute; no SPC:</label>
	<input id="campo07" type="text" value="<?php if ($ocorrencia[7]->cdata == "yes") { echo "SIM"; } else { echo "NAO"; } ?>" />
	
	<label for="campo08">Est&aacute; no CCF:</label>
	<input id="campo08" type="text" value="<?php if ($ocorrencia[8]->cdata == "yes") { echo "SIM"; } else { echo "NAO"; }  ?>" />
	
	<br />
	
	<label for="campo09">Empr. em atraso:</label>
	<input id="campo09"type="text" value="<?php if ($ocorrencia[9]->cdata == "yes") { echo "SIM"; } else { echo "NAO"; } ?>" />
	
	<label for="campo17">Risco Cooperado:</label>
	<input id="campo17" type="text" value="<?php echo $ocorrencia[17]->cdata." - ".$ocorrencia[18]->cdata;  ?>" />
	
	<br />
	<br />
	<br />
	
	<label for="campo12">Empr&eacute;stimos:</label>
	<input id="campo12" type="text" value="<?php if ($ocorrencia[12]->cdata == "yes") { echo "SIM"; } else { echo "NAO"; } ?>" />
	
	<br />
	
	<label for="campo13">Conta Corrente:</label>
	<input id="campo13" type="text" align="left" value="<?php if ($ocorrencia[13]->cdata == "yes") { echo "SIM"; } else { echo "NAO"; } ?>" />
	<br />
	<br />
	
</form>

<script type="text/javascript">

// Formata o layout
formataPrincipal();


// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>