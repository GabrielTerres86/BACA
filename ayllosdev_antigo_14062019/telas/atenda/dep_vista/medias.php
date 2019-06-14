<?php 

	 /************************************************************************
	   Fonte: medias.php
	   Autor: Guilherme
	   Data : Fevereiro/2008                 Última Alteração: 21/07/2016

	   Objetivo  : Mostrar opcao Médias da rotina de Dep. Vista
                   da tela ATENDA

	   Alterações: 02/09/2010 - Ajuste na apresentação dos campos (David).
				   24/06/2011 - Alterado para layout padrão (Gabriel - DB1).
				   14/10/2015 - Adicionado novos campos média do mês atual e dias úteis decorridos. SD 320300 (Kelvin).
				   21/07/2016 - Correcao no uso da função number_format. SD 479874 (Carlos R).
	 ************************************************************************/
	
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
	$xmlGetMedias  = "";
	$xmlGetMedias .= "<Root>";
	$xmlGetMedias .= "	<Cabecalho>";
	$xmlGetMedias .= "		<Bo>b1wgen0001.p</Bo>";
	$xmlGetMedias .= "		<Proc>carrega_medias</Proc>";
	$xmlGetMedias .= "	</Cabecalho>";
	$xmlGetMedias .= "	<Dados>";
	$xmlGetMedias .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetMedias .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetMedias .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetMedias .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetMedias .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetMedias .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetMedias .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetMedias .= "		<idseqttl>1</idseqttl>";
	$xmlGetMedias .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetMedias .= "	</Dados>";
	$xmlGetMedias .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetMedias);
	
	// Cria objeto para classe de tratamento de XML
	$xmlGetMedias = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlGetMedias->roottag->tags[0]->name) && strtoupper($xmlGetMedias->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlGetMedias->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$medias = $xmlGetMedias->roottag->tags;
	
	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<form action="" method="post" name="frmMedias" id="frmMedias" class="formulario" >

	<label for="period0"><?php echo $medias[0]->tags[0]->tags[0]->cdata; ?></label>
	<input name="period0" id="period0" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[0]->tags[0]->tags[1]->cdata)),2,",",".");  ?>" />
	
	<label for="vlsmnmes"><?php echo 'M&eacute;dia Negativa do M&ecirc;s:'; ?></label>
	<input name="vlsmnmes" id="vlsmnmes" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[1]->tags[0]->tags[0]->cdata)),2,",","."); ?>" />
	<br />
	
	<label for="period1"><?php echo $medias[0]->tags[1]->tags[0]->cdata; ?></label>
	<input name="period1" id="period1" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[0]->tags[1]->tags[1]->cdata)),2,",",".");  ?>" />
	<br />
	
	<label for="period2"><?php echo $medias[0]->tags[2]->tags[0]->cdata; ?></label>
	<input name="period2" id="period2" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[0]->tags[2]->tags[1]->cdata)),2,",",".");  ?>" />
	
	<label for="vlsmnesp"><? echo utf8ToHtml('Média Neg. Esp. do Mês:') ?></label>
	<input name="vlsmnesp" id="vlsmnesp" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[1]->tags[0]->tags[1]->cdata)),2,",","."); ?>" />
	<br />
	
	<label for="period3"><?php echo $medias[0]->tags[3]->tags[0]->cdata; ?></label>
	<input name="period3" id="period3" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[0]->tags[3]->tags[1]->cdata)),2,",",".");  ?>" />
	<br />
	
	<label for="period4"><?php echo $medias[0]->tags[4]->tags[0]->cdata; ?></label>
	<input name="period4" id="period4" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[0]->tags[4]->tags[1]->cdata)),2,",",".");  ?>" />
	
	<label for="vlsaqmax"><?php echo 'M&eacute;d. Saq. s\ Bloqueio:'; ?></label>
	<input name="vlsaqmax" id="vlsaqmax" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[1]->tags[0]->tags[2]->cdata)),2,",","."); ?>" />
	<br />
	
	<label for="period5"><?php echo $medias[0]->tags[5]->tags[0]->cdata; ?></label>
	<input name="period5" id="period5" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[0]->tags[5]->tags[1]->cdata)),2,",",".");  ?>" />
	<br />
	
	<label for="period6"><?php echo $medias[0]->tags[6]->tags[0]->cdata; ?></label>
	<input name="period6" id="period6" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[0]->tags[6]->tags[1]->cdata)),2,",",".");  ?>" />
	
	<label for="qtdiaute"><?php echo 'Dias &Uacute;teis no M&ecirc;s:'; ?></label>
	<input name="qtdiaute" id="qtdiaute" type="text" value="<?php echo $medias[1]->tags[0]->tags[3]->cdata; ?>" />
	<br />
	
	<label for="vltsddis"><?php echo 'M&ecirc;s Atual:'; ?></label>
	<input name="vltsddis" id="vltsddis" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[1]->tags[0]->tags[7]->cdata)),2,",","."); ?>" />
	<label for="qtdiauti"><?php echo 'Dias &Uacute;teis Decorridos:'; ?></label>
	<input name="qtdiauti" id="qtdiauti" type="text" value="<?php echo $medias[1]->tags[0]->tags[6]->cdata; ?>" />
	
	<br />
	<label for="vlsmdtri"><?php echo 'Trimestre:'; ?></label>
	<input name="vlsmdtri" id="vlsmdtri" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[1]->tags[0]->tags[4]->cdata)),2,",","."); ?>" />
	<br />
	
	<label for="vlsmdsem"><?php echo 'Semestre:'; ?></label>
	<input name="vlsmdsem" id="vlsmdsem" type="text" value="<?php echo number_format(floatval(str_replace(",",".",$medias[1]->tags[0]->tags[5]->cdata)),2,",","."); ?>" />
	<br />

</form>

<script type="text/javascript">

controlaLayout('frmMedias');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
