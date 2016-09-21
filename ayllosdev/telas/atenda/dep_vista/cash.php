<?php 

	//************************************************************************//
	//*** Fonte: cash.php                                             	   ***//
	//*** Autor: Guilherme                                                 ***//
	//*** Data : Mar�o/2009                 �tima Altera��o: 30/06/2011    ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao CASH da rotina dep�sitos a vista       ***//
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
	//***		  30/06/2011 - Alterado para layout padr�o (Rogerius - DB1)***//		
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se n�mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dataArr = explode('/',$glbvars["dtmvtolt"]);
	$dtrefere = isset($_POST["dtrefere"]) ? $_POST["dtrefere"] : "01/".$dataArr[1]."/".$dataArr[2];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Monta o xml de requisi��o
	$xmlGetExtrato  = "";
	$xmlGetExtrato .= "<Root>";
	$xmlGetExtrato .= "	<Cabecalho>";
	$xmlGetExtrato .= "		<Bo>b1wgen0027.p</Bo>";
	$xmlGetExtrato .= "		<Proc>extratos_emitidos_no_cash</Proc>";
	$xmlGetExtrato .= "	</Cabecalho>";
	$xmlGetExtrato .= "	<Dados>";
	$xmlGetExtrato .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetExtrato .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetExtrato .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetExtrato .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetExtrato .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetExtrato .= "		<idseqttl>1</idseqttl>";
	$xmlGetExtrato .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetExtrato .= "		<dtrefere>".$dtrefere."</dtrefere>";
	$xmlGetExtrato .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetExtrato .= "	</Dados>";
	$xmlGetExtrato .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetExtrato);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjExtrato = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjExtrato->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjExtrato->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$extrato  = $xmlObjExtrato->roottag->tags[0]->tags;
	
	// Procura ind�ce da op��o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}		

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

?>


<form action="" name="frmExtCash" id="frmExtCash" method="post" class="formulario">

	<label for="dtrefere">Per&iacute;odo:</label>
	<input type="text" name="dtrefere" id="dtrefere" value="<?php echo $dtrefere; ?>" autocomplete="no">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/pesquisar.gif" onClick="acessaOpcaoAba(7,6,6);return false;">
	
</form>

<br /> 

<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Emiss&atilde;o'); ?></th>
				<th><? echo utf8ToHtml('Dt. Ref');  ?></th>
				<th><? echo utf8ToHtml('Pac');  ?></th>
				<th><? echo utf8ToHtml('N&uacute;mero terminal financeiro');  ?></th>
				<th><? echo utf8ToHtml('Tarifou');  ?></th>
			</tr>
		</thead>
		<tbody>
			<? 
			foreach ( $extrato as $registro ) { 
			?>
				<tr>
					<td><span><?php echo dataParaTimestamp(getByTagName($registro->tags,'dtrefere')); ?></span>
							  <?php echo getByTagName($registro->tags,'dtrefere'); ?>
					</td>
					<td><span><?php echo dataParaTimestamp(getByTagName($registro->tags,'dtmesano')); ?></span>
							  <?php echo getByTagName($registro->tags,'dtmesano') ?>
					</td>
					<td><span><?php echo getByTagName($registro->tags,'cdagenci'); ?></span>
							  <?php echo getByTagName($registro->tags,'cdagenci'); ?>
					</td>
					<td><span><?php echo getByTagName($registro->tags,'nrnmterm'); ?></span>
							  <?php echo getByTagName($registro->tags,'nrnmterm'); ?>
					</td>
					<td><span><?php echo getByTagName($registro->tags,'inisenta'); ?></span>
							  <?php echo getByTagName($registro->tags,'inisenta') == 'yes' ? 'SIM' : 'N�O'; ?>
					</td>

				</tr>
		<? } ?>	
		</tbody>
	</table>
</div>	


<script type="text/javascript">

controlaLayout('frmExtCash');

// Seta m�scara aos campos dtrefere
$("#dtrefere","#frmExtCash").setMask("DATE","","","divRotina");

$("#dtrefere","#frmExtCash").focus();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte�do que est� �tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));	
</script>
