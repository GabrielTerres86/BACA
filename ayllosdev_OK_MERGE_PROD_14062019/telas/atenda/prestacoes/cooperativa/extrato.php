<?php 

	//************************************************************************//
	//*** Fonte: extrato.php                                               ***//
	//*** Autor: David                                                     ***//
	//*** Data : Maio/2009                    Última Alteração: 24/05/2013 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao Extrato da rotina Prestações da tela   ***//
	//***             ATENDA                                               ***//
	//***                                                                  ***//	 
	//*** Alterações: 													   ***//
    //***     24/05/2013 - Incluir camada nas includes "../". (Lucas R)	   ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");		
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctremp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctremp = $_POST["nrctremp"];
	$dtiniper = isset($_POST["dtiniper"]) && validaData($_POST["dtiniper"]) ? $_POST["dtiniper"] : "01/01/".substr($glbvars["dtmvtolt"],6);
	$dtfimper = isset($_POST["dtfimper"]) && validaData($_POST["dtfimper"]) ? $_POST["dtfimper"] : $glbvars["dtmvtolt"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctremp)) {
		exibeErro("Contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisição
	$xmlGetExtrato  = "";
	$xmlGetExtrato .= "<Root>";
	$xmlGetExtrato .= "	<Cabecalho>";
	$xmlGetExtrato .= "		<Bo>b1wgen0002.p</Bo>";
	$xmlGetExtrato .= "		<Proc>obtem-extrato-emprestimo</Proc>";
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
	$xmlGetExtrato .= "		<nrctremp>".$nrctremp."</nrctremp>";
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
<table width="510" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td valign="middle">
			<table width="510" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td align="center">
						<table width="430" border="0" cellpadding="0" cellspacing="2">
							<tr>
								<td width="50">
									<table width="100%" border="0" cellpadding="0" cellspacing="0">
										<tr>
											<td height="1" style="background-color:#999999;"></td>
										</tr>
									</table>
								</td>								
								<td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;">EXTRATO</td>
								<td width="50">
									<table width="100%" border="0" cellpadding="0" cellspacing="0">
										<tr>
											<td height="1" style="background-color:#999999;"></td>
										</tr>
									</table>								
								</td>
							</tr>
						</table>						
					</td>
				</tr>
				<tr>
					<td>
						<form action="" name="frmExtEpr" id="frmExtEpr" method="post">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td width="57" height="27" class="txtNormalBold" align="center">Per&iacute;odo:</td>
								<td width="67"><input type="text" name="dtiniper" id="dtiniper" style="width: 65px;" class="campo" value="<?php echo $dtiniper; ?>"></td>
								<td width="17" class="txtNormalBold" align="center">&agrave;</td>
								<td width="67"><input type="text" name="dtfimper" id="dtfimper" style="width: 65px;" class="campo" value="<?php echo $dtfimper; ?>"></td>
								<td width="95" align="center"><input type="image" src="<?php echo $UrlImagens; ?>botoes/pesquisar.gif" onClick="extratoEmprestimo();return false;"></td>
							</tr>
						</table>
						</form>
					</td>	
				</tr>
				<tr>
					<td>	
						<table width="495" border="0" cellpadding="1" cellspacing="2">
							<tr style="background-color: #F4D0C9;">
								<td width="70" class="txtNormalBold">Data</td>
								<td width="185" class="txtNormalBold">Hist&oacute;rico</td>
								<td width="75" class="txtNormalBold" align="right">Documento</td>
								<td width="30" class="txtNormalBold" align="center">D/C</td>
								<td class="txtNormalBold" align="right">Valor</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<div id="divResultado" style="overflow-y: scroll; overflow-x: hidden; height: 130px; width: 100%;">
							<table width="100%" border="0" cellpadding="1" cellspacing="2">
								<?php 
								$style = "";
								
								for ($i = 0; $i < $qtLancto; $i++) { 
									if ($style == "") {
										$style = " style=\"background-color: #FFFFFF;\"";
									} else {
										$style = "";
									}	
								?>
								<tr<?php echo $style; ?>>
									<td width="70" class="txtNormal"><?php echo $extrato[$i]->tags[1]->cdata; ?></td>
									<td width="185" class="txtNormal"><?php echo $extrato[$i]->tags[5]->cdata; ?></td>
									<td width="75" align="right" class="txtNormal"><?php echo formataNumericos("zz.zzz.zzz",$extrato[$i]->tags[6]->cdata,"."); ?></td>
									<td width="30" align="center" class="txtNormal"><?php echo $extrato[$i]->tags[7]->cdata; ?></td>
									<td class="txtNormal" align="right"><?php echo number_format(str_replace(",",".",$extrato[$i]->tags[8]->cdata),2,",","."); ?></td>
								</tr>	
								<?php
								} // Fim do for
								?>
							</table>
						</div>
					</td>
				</tr>
				<tr>
					<td height="5"></td>
				</tr>
				<tr>
					<td align="center"><input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="mostraDivDadosEpr();return false;"></td>
				</tr>
			</table>	
		</td>
	</tr>
</table>
<script type="text/javascript">
mostraDiv("divConteudoOpcaoRotina","231");

// Seta máscara aos campos dtiniper e dtfimper
$("#dtiniper,#dtfimper","#frmExtEpr").setMask("DATE","","","divRotina");
	
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>