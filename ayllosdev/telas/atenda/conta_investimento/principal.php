<?php 

	//************************************************************************//
	//*** Fonte: principal.php                                             ***//
	//*** Autor: David                                                     ***//
	//*** Data : Setembro/2007                Última Alteração: 30/06/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opção Principal da rotina de Conta           ***//
	//***             Investimento da tela ATENDA                          ***//
	//***                                                                  ***//	 
	//*** Alterações: 09/10/2008 - Mostrar se aplicação referente ao       ***//
	//***                          resgate estava bloqueada (David).       ***//
	//***                                                                  ***//	 
	//***             30/06/2011 - Alterado para layout     			   ***//
	//***						    padrão (Rogerius - DB1).			   ***//
	//************************************************************************//
	
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
	
	// Verifica se número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtiniper = isset($_POST["dtiniper"]) && validaData($_POST["dtiniper"]) ? $_POST["dtiniper"] : $glbvars["dtmvtolt"];
	$dtfimper = isset($_POST["dtfimper"]) && validaData($_POST["dtfimper"]) ? $_POST["dtfimper"] : $glbvars["dtmvtolt"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlGetExtrato  = "";
	$xmlGetExtrato .= "<Root>";
	$xmlGetExtrato .= "	<Cabecalho>";
	$xmlGetExtrato .= "		<Bo>b1wgen0020.p</Bo>";
	$xmlGetExtrato .= "		<Proc>extrato_investimento</Proc>";
	$xmlGetExtrato .= "	</Cabecalho>";
	$xmlGetExtrato .= "	<Dados>";
	$xmlGetExtrato .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetExtrato .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetExtrato .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetExtrato .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetExtrato .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetExtrato .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlGetExtrato .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetExtrato .= "		<idseqttl>1</idseqttl>";
	$xmlGetExtrato .= "		<dtiniper>".$dtiniper."</dtiniper>";
	$xmlGetExtrato .= "		<dtfimper>".$dtfimper."</dtfimper>";
	$xmlGetExtrato .= "	</Dados>";
	$xmlGetExtrato .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetExtrato);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjExtrato = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjExtrato->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjExtrato->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$vlsldant = $xmlObjExtrato->roottag->tags[0]->attributes["VLSLDANT"];
	$extrato  = $xmlObjExtrato->roottag->tags[0]->tags;
	
	// Procura indíce da opçã "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}		

	// Função para exibir erros na tela atravé de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>


<form action="" name="frmContaInv" id="frmContaInv" method="post" class="formulario">
	
	<label for="dtiniper">Per&iacute;odo:</label>
	<input type="text" name="dtiniper" id="dtiniper" value="<?php echo $dtiniper; ?>">
	
	<label for="dtfimper">&agrave;</label>
	<input type="text" name="dtfimper" id="dtfimper" value="<?php echo $dtfimper; ?>">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/pesquisar.gif" onClick="acessaOpcaoAba(<?php echo count($glbvars["opcoesTela"]); ?>,<?php echo $idPrincipal; ?>,'@');return false;">
	
</form>

<br />

<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Data'); ?></th>
				<th><? echo utf8ToHtml('Hist&oacute;rico');  ?></th>
				<th><? echo utf8ToHtml('S');  ?></th>
				<th><? echo utf8ToHtml('Docmto');  ?></th>
				<th><? echo utf8ToHtml('D/C');  ?></th>
				<th><? echo utf8ToHtml('Valor');  ?></th>
				<th><? echo utf8ToHtml('Saldo');  ?></th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td>&nbsp;</td>
				<td><?php if (count($extrato) > 0) { echo "SALDO ANTERIOR"; } else { echo "&nbsp;"; } ?></td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>						
				<td>&nbsp;</td>
				<td><?php if (count($extrato) > 0) { echo number_format(str_replace(",",".",$vlsldant),2,",","."); } else { echo "&nbsp;"; } ?></td>
			</tr>
		
			<? 
			for ($i = 0; $i < count($extrato); $i++) { 
			?>
				<tr>
					<td><span><?php echo dataParaTimestamp($extrato[$i]->tags[0]->cdata); ?></span>
							  <?php echo $extrato[$i]->tags[0]->cdata; ?>
					</td>
					<td><span><?php echo $extrato[$i]->tags[1]->cdata; ?></span>
							  <?php echo $extrato[$i]->tags[1]->cdata; ?>
					</td>
					<td><span><?php echo $extrato[$i]->tags[6]->cdata; ?></span>
							  <?php echo $extrato[$i]->tags[6]->cdata; ?>
					</td>
					<td><span><?php echo $extrato[$i]->tags[2]->cdata; ?></span>
							  <?php echo $extrato[$i]->tags[2]->cdata; ?>
					</td>
					<td><span><?php echo getByTagName($registro->tags,'dssitlli'); ?></span>
							  <?php echo $extrato[$i]->tags[3]->cdata; ?>
					</td>
					<td><span><?php echo str_replace(",",".",$extrato[$i]->tags[4]->cdata); ?></span>
							  <?php echo number_format(str_replace(",",".",$extrato[$i]->tags[4]->cdata),2,",","."); ?>
					</td>

					<td><span><?php echo str_replace(",",".",$extrato[$i]->tags[5]->cdata); ?></span>
							  <?php echo number_format(str_replace(",",".",$extrato[$i]->tags[5]->cdata),2,",","."); ?>
					</td>

				</tr>
		<? } ?>	
		</tbody>
	</table>
</div>	

<script type="text/javascript">

// Formata layout
controlaLayout('principal');

// Seta máscara aos campos dtiniper e dtfimper
$("#dtiniper,#dtfimper","#frmContaInv").setMask("DATE","","","divRotina");

layoutOpcao();
controlaFoco();
</script>