<?php 

	//************************************************************************//
	//*** Fonte: limites_preposto.php 	    	                           ***//
	//*** Autor: Everton                                                   ***//
	//*** Data : Junho/2017                   Última Alteração: 19/06/2017 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar tela para atualização de limites prepostos   ***//
	//***                                                                  ***//	 
	//***                                                                  ***//	 
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}
	
	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	//exibeErro($nrcpfcgc);
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	

		$strnomacao = 'BUSCA_LIMITES_PREPOSTOS';
	
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "<Dados>";
		$xml .= "<cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "<nrcpf>".$nrcpfcgc."</nrcpf>";
		$xml .= "</Dados>";
		$xml .= "</Root>";
		
	    //print_r($xml);
		
		
		
		$xmlResult = mensageria($xml, "ATENDA" , $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	

		$xml_geral = simplexml_load_string($xmlResult);
		
		//print_r($xml_geral);
		
		$xmlObjeto = getObjectXML($xmlResult);
		

	
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}		
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<div id="divHabilitacaoInternet01">
	<form action="" method="post" name="frmAlterarLimites" id="frmAlterarLimites" onSubmit="return false;">
		<fieldset>
			<legend><? echo utf8ToHtml('Transações') ?></legend>
			
			<?php if ($limites[3]->cdata == "1") { ?>
				
				<input name="vllimtrf" type="hidden" id="vllimtrf" value="0,00">
				<input name="vllimpgo" type="hidden" id="vllimpgo" value="0,00">
				
				<label for="vllimweb"><? echo utf8ToHtml('Valor Limite Diário:') ?></label>
				<input name="vllimweb" type="text" class="campo" id="vllimweb" autocomplete="no" value="<?php echo number_format(str_replace(",",".",$limites[0]->cdata),2,",","."); ?>">
				<br />
				
			<?php } else { ?>
			
				<input name="vllimweb" type="hidden" id="vllimweb" value="0,00" />
				
				<label for="vllimtrf"><? echo utf8ToHtml('Vlr. Limite Diário Transf.:') ?></label>
				<input name="vllimtrf" type="text" class="campo" id="vllimtrf" autocomplete="no" value="<?php echo number_format(str_replace(",",".",$xml_geral->preposto->pr_vllimite_transf),2,",","."); ?>" />
				<br />	
				
				<label for="vllimpgo"><? echo utf8ToHtml('Vlr. Limite Diário Pagto.:') ?></label>
				<input name="vllimpgo" type="text" class="campo" id="vllimpgo" autocomplete="no" value="<?php echo number_format(str_replace(",",".",$xml_geral->preposto->pr_vllimite_pagto),2,",","."); ?>" />
				<br />
			<?php } ?>
			
				<label for="vllimted"><? echo utf8ToHtml('Valor Limite/Dia TED:') ?></label>
				<input name="vllimted" type="text" class="campo" id="vllimted" autocomplete="no" value="<?php echo number_format(str_replace(",",".",$xml_geral->preposto->pr_vllimite_ted),2,",","."); ?>" />
				<br/>
				<label for="vllimvrb"><? echo utf8ToHtml('Valor Limite VR Boleto:') ?></label>
				<input name="vllimvrb" type="text" class="campo" id="vllimvrb" autocomplete="no" value="<?php echo number_format(str_replace(",",".",$xml_geral->preposto->pr_vllimite_vrboleto),2,",","."); ?>" />
                <br/>
                <label for="vllimflp"><? echo utf8ToHtml('Valor Limite Folha Pgto:') ?></label>
                <input name="vllimflp" type="text" class="campo" id="vllimflp" autocomplete="no" value="<?php echo number_format(str_replace(",",".",$xml_geral->preposto->pr_vllimite_folha),2,",","."); ?>" />
		</fieldset>
	</form> 
	<div id="divBotoes">
		<input type="image" id = "btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="carregaHabilitacao();return false;" />
		<input type="image" id = "btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="validaDadosLimitesprep(<?php echo $limites[3]->cdata; ?>);return false;" />
	</div>
</div>


<div id="divHabilitacaoInternet02" style="display: none;"></div>

<script type="text/javascript">

controlaLayout('frmAlterarLimites');

<?php if ($limites[3]->cdata == "1") { ?>
$("#vllimweb","#frmAlterarLimites").setMask("DECIMAL","z.zzz.zz9,99","","");
<?php } else { ?>
$("#vllimtrf","#frmAlterarLimites").setMask("DECIMAL","z.zzz.zz9,99","","");
$("#vllimpgo","#frmAlterarLimites").setMask("DECIMAL","z.zzz.zz9,99","","");
<?php } ?>
$("#vllimted","#frmAlterarLimites").setMask("DECIMAL","z.zzz.zz9,99","","");
$("#vllimvrb","#frmAlterarLimites").setMask("DECIMAL","z.zzz.zz9,99","","");
$("#vllimflp","#frmAlterarLimites").setMask("DECIMAL","z.zzz.zz9,99","","");

// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("height","190px");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>