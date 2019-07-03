<?php 

	//************************************************************************//
	//*** Fonte: aplicacoes_programadas.php                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Março/2010                   Última Alteração: 27/07/2018 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar extrato da aplicação programada              ***//	
	//***                                                                  ***//	 
	//*** Alterações:  13/07/2011 - Alterado para layout padrão            ***//
	//*** 							(Gabriel - DB1)                        ***//
	//***                                                                  ***//
	//***              27/07/2018 - Derivação para Aplicação Programada    ***//
	//***                           (Proj. 411.2 - CIS Corporate)          ***// 
	//***                                                                  ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])|| !isset($_POST["cdprodut"])) {		
		exibeErro("Par&acirc;metros incorretos.");		
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	$cdprodut = $_POST["cdprodut"];
	$dtiniper = isset($_POST["dtiniper"]) && validaData($_POST["dtiniper"]) ? $_POST["dtiniper"] : "01/01/".substr($glbvars["dtmvtolt"],6);
	$dtfimper = isset($_POST["dtfimper"]) && validaData($_POST["dtfimper"]) ? $_POST["dtfimper"] : $glbvars["dtmvtolt"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o contrato da poupança é um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}

	if ($cdprodut  <1){
		// RPP
		// Monta o xml de requisição
		$xmlGetExtrato  = "";
		$xmlGetExtrato .= "<Root>";
		$xmlGetExtrato .= "  <Cabecalho>";
		$xmlGetExtrato .= "    <Bo>b1wgen0006.p</Bo>";
		$xmlGetExtrato .= "    <Proc>consulta-extrato-poupanca</Proc>";
		$xmlGetExtrato .= "  </Cabecalho>";
		$xmlGetExtrato .= "  <Dados>";
		$xmlGetExtrato .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlGetExtrato .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlGetExtrato .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlGetExtrato .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlGetExtrato .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlGetExtrato .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xmlGetExtrato .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$xmlGetExtrato .= "    <idseqttl>1</idseqttl>";
		$xmlGetExtrato .= "    <nrctrrpp>".$nrctrrpp."</nrctrrpp>";
		$xmlGetExtrato .= "    <dtiniper>".$dtiniper."</dtiniper>";
		$xmlGetExtrato .= "    <dtfimper>".$dtfimper."</dtfimper>";
		$xmlGetExtrato .= "  </Dados>";
		$xmlGetExtrato .= "</Root>";
			
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlGetExtrato);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjExtrato = getObjectXML($xmlResult);

	} else {
		// Captacao
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";	
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <idseqttl>1</idseqttl>";
		$xml .= "   <nrctrrpp>".$nrctrrpp."</nrctrrpp>";
		$xml .= "   <dtmvtolt_ini>".$dtiniper."</dtmvtolt_ini>";
		$xml .= "   <dtmvtolt_fim>".$dtfimper."</dtmvtolt_fim>";
		$xml .= "   <idlstdhs>1</idlstdhs>";
		$xml .= "   <idgerlog>0</idgerlog>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		$xmlResult = mensageria($xml, "APLI0008", "EXTRATO_APL_PROG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjExtrato = getObjectXML($xmlResult);
	}
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjExtrato->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjExtrato->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$extrato  = $xmlObjExtrato->roottag->tags[0]->tags;
	$qtLancto = count($extrato);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<form action="" name="frmExtrato" id="frmExtrato" method="post">
	<fieldset>
		<legend><? echo utf8ToHtml('Aplicações Programadas:') ?></legend>
		
		<label for="dtiniper"><? echo utf8ToHtml('Período:') ?></label>
		<input type="text" name="dtiniper" id="dtiniper" value="<?php echo $dtiniper; ?>" />
		
		<label for="dtfimper"><? echo utf8ToHtml('à:') ?></label>
		<input type="text" name="dtfimper" id="dtfimper" value="<?php echo $dtfimper; ?>" />
		
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/pesquisar.gif" onClick="extratoAplicacaoProgramada();return false;" />
		<br style="clear:both;">
		
		<div id="divExtrato">
		
			<div class="divRegistros">
				<table>
					<thead>
						<tr>
							<th>Data</th>
							<th>Hist&oacute;rico</th>
							<th>Docmto</th>
							<th>D/C</th>
							<th>Valor</th>
							<th>Saldo</th>
						</tr>			
					</thead>
					<tbody>
						<?  for ($i = 0; $i < $qtLancto; $i++) {
						       if ($cdprodut  <1){
								   $vllanmto       = number_format(str_replace(",",".",$extrato[$i]->tags[4]->cdata),2,",",".");
								   $vllanmto_total = number_format(str_replace(",",".",$extrato[$i]->tags[5]->cdata),2,",",".");
							   }else{
								   $vllanmto       = $extrato[$i]->tags[4]->cdata;
								   $vllanmto_total = $extrato[$i]->tags[5]->cdata;
							   }
						?>
							<tr>
								<td><?php if ($i > 0) { echo $extrato[$i]->tags[0]->cdata; } else { echo "&nbsp;"; } ?></td>
								
								<td><?php echo $extrato[$i]->tags[1]->cdata; ?></td>
								
								<td><span><? if ($i > 0) { echo $extrato[$i]->tags[2]->cdata; } else { echo "&nbsp;"; } ?></span>
									<?php if ($i > 0) { echo number_format($extrato[$i]->tags[2]->cdata,0,",","."); } else { echo "&nbsp;"; } ?></td>
								
								<td><?php if ($i > 0) { echo $extrato[$i]->tags[3]->cdata; } else { echo "&nbsp;"; } ?></td>
								
								<td><span><?php if ($i > 0) { echo $extrato[$i]->tags[4]->cdata; } else { echo "&nbsp;"; } ?></span>
									<?php if ($i > 0) { echo $vllanmto; } else { echo "&nbsp;"; } ?></td>
								
								<td><span><? echo $extrato[$i]->tags[5]->cdata; ?></span>
									<?php echo $vllanmto_total; ?></td>
							</tr>	
						<?} // Fim do for ?>			
					</tbody>
				</table>
			</div>
		
		</div>
		
	</fieldset>
</form>
<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDivConsulta();return false;" />
</div>

<script type="text/javascript">
// Seta m&aacute;scara aos campos dtiniper e dtfimper
$("#dtiniper,#dtfimper","#frmExtrato").setMask("DATE","","","divRotina");

$("#divDadosPoupanca").css("display","none");
$("#divExtratoPoupanca").css("display","block");

controlaLayout('frmExtrato');
	
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
