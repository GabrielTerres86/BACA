<?php 

	//************************************************************************//
	//*** Fonte: dados_proposta.php                                        ***//
	//*** Autor: David                                                     ***//
	//*** Data : Maio/2009                    &Uacute;ltima Altera&ccedil;&atilde;o: 24/05/2013 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar dados da proposta de empr&eacute;stimo              ***//
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es:                                                      ***//
	/* 001: [24/05/2013] Lucas R.(CECRED): Incluir camada nas includes "../". *//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");		
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se par&acirc;metros necess&aacute;rios foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctremp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}		
	
	$nrdconta = $_POST["nrdconta"];
	$nrctremp = $_POST["nrctremp"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se n&uacute;mero do contrato &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrctremp)) {
		exibeErro("Contrato inv&aacute;lido.");
	}		
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetEpr  = "";
	$xmlGetEpr .= "<Root>";
	$xmlGetEpr .= "  <Cabecalho>";
	$xmlGetEpr .= "    <Bo>b1wgen0002.p</Bo>";
	$xmlGetEpr .= "    <Proc>obtem-dados-proposta-emprestimo</Proc>";
	$xmlGetEpr .= "  </Cabecalho>";
	$xmlGetEpr .= "  <Dados>";
	$xmlGetEpr .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetEpr .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetEpr .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetEpr .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetEpr .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetEpr .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";		
	$xmlGetEpr .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetEpr .= "    <idseqttl>1</idseqttl>";
	$xmlGetEpr .= "    <nrctremp>".$nrctremp."</nrctremp>";
	$xmlGetEpr .= "  </Dados>";
	$xmlGetEpr .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetEpr);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjEpr = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjEpr->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjEpr->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Dados da proposta
	$proposta       = $xmlObjEpr->roottag->tags[0]->tags[0]->tags;	
	$alienacao      = $xmlObjEpr->roottag->tags[1]->tags;
	$intervenientes = $xmlObjEpr->roottag->tags[2]->tags;
	$hipoteca       = $xmlObjEpr->roottag->tags[3]->tags; 
	$avais          = $xmlObjEpr->roottag->tags[4]->tags;	
	
	// Flag para indicar se avalista 1 e/ou 2 foram cadastrados
	$flgAval01 = count($avais) == 1 || count($avais) == 2 ? true : false;
	$flgAval02 = count($avais) == 2 ? true : false;
	
	// Totais (Bens hipotecados, Bens alienados, Intervenientes Anuentes)
	$qtBensAlienacao  = count($alienacao);
	$qtIntervenientes = count($intervenientes);
	$qtHipoteca       = count($hipoteca);	
		
	// Fun&ccedil;&atilde;o para retornar respectiva fun&ccedil;&atilde;o para bot&atilde;o continuar dos div's	
	function retornaFuncaoContinuar($idBotao) {
		global $proposta, $qtBensAlienacao, $qtIntervenientes, $qtHipoteca;
			
		if ($idBotao == 1 && $proposta[8]->cdata == "yes") {
			return "mostraDivsDadosProposta('divDadosBensProposta','230');";			
		} 
		
		if ($idBotao < 3 && ($proposta[9]->cdata == "yes" || $proposta[20]->cdata <> "1")) {
			return "mostraDivsDadosProposta('divDadosAvalistas','415');";
		} 
		
		if ($proposta[20]->cdata == "2") {											
			if ($idBotao < 4 && $qtBensAlienacao > 0) {				
				return "mostraDivsDadosProposta('divDadosAlienacao','260');";
			} elseif ($idBotao < 5 && $qtIntervenientes > 0) {				
				return "mostraDivsDadosProposta('divDadosIntervenientes','250');";
			}
		} 
		
		if ($idBotao < 4 && $proposta[20]->cdata == "3" && $qtHipoteca > 0) {								
			return "mostraDivsDadosProposta('divDadosHipoteca','210');";
		}							
		
		return "mostraDivDadosEpr();";	
	}	
	
	// Fun&ccedil;&atilde;o para retornar respectiva fun&ccedil;&atilde;o para bot&atilde;o voltar dos div's
	function retornaFuncaoVoltar($idBotao) {
		global $proposta, $qtBensAlienacao, $qtIntervenientes, $qtHipoteca;
		
		if ($idBotao == 1) {		
			if ($proposta[8]->cdata == "yes" || $proposta[9]->cdata == "yes" || $proposta[20]->cdata <> "1" || ($proposta[20]->cdata == "2" && ($qtBensAlienacao > 0 || $qtIntervenientes > 0)) || ($proposta[20]->cdata == "3" && $qtHipoteca > 0)) {
				return "mostraDivDadosEpr();";			
			} else {
				return "";	
			}
		}
		
		if ($idBotao == 2 || ($idBotao == 3 && $proposta[8]->cdata == "no")) {
			return "mostraDivsDadosProposta('divDadosProposta','307');";
		}
		
		if ($idBotao == 3) {
			return "mostraDivsDadosProposta('divDadosBensProposta','230');";
		}
		
		if ($idBotao == 4 || ($idBotao == 5 && $qtBensAlienacao == 0)) {
			return "mostraDivsDadosProposta('divDadosAvalistas','415');";			
		}
		
		if ($idBotao == 5) {
			return "mostraDivsDadosProposta('divDadosAlienacao','260');";				
		}				
	}	
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<div id="divDadosProposta">
	<table width="510" height="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td valign="middle">
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
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
									<td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;">PROPOSTA DE EMPR&Eacute;STIMO</td>
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
							<table width="100%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="125" height="24" align="right">N&iacute;vel de Risco:&nbsp;</td>
									<td class="txtNormal" width="105"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php echo $proposta[3]->cdata; ?>" readonly></td>
									<td class="txtNormalBold" width="105" align="right">Risco Calculado:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php echo $proposta[4]->cdata; ?>" readonly></td>
								</tr>
								<tr>
									<td class="txtNormalBold" height="24" align="right">Valor do Empr&eacute;stimo:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php echo number_format(str_replace(",",".",$proposta[0]->cdata),2,",","."); ?>" readonly></td>
									<td class="txtNormalBold" align="right">Linha de Cr&eacute;dito:&nbsp; </td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 170px;" value="<?php echo $proposta[5]->cdata." ".$proposta[21]->cdata; ?>" readonly></td>
								</tr>					
								<tr>
									<td class="txtNormalBold" height="24" align="right">Valor da Presta&ccedil;&atilde;o:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php echo number_format(str_replace(",",".",$proposta[1]->cdata),2,",","."); ?>" readonly></td>
									<td class="txtNormalBold" align="right">Finalidade:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 170px;" value="<?php echo $proposta[6]->cdata." ".$proposta[22]->cdata; ?>" readonly></td>
								</tr>	
								<tr>
									<td class="txtNormalBold" height="24" align="right">Qtde. de Parcelas:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php echo $proposta[2]->cdata; ?>" readonly></td>
									<td class="txtNormalBold" align="right">Garantia:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php echo $proposta[23]->cdata; ?>" readonly></td>
								</tr>
								<tr>
									<td class="txtNormalBold" height="24" align="right">Debitar Em:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php if ($proposta[10]->cdata == "yes") { echo "Folha"; } else { echo "Conta"; } ?>" readonly></td>									
									<td class="txtNormalBold" align="right">Qualif. Opera&ccedil;&atilde;o:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 170px;" value="<?php echo $proposta[24]->cdata.($proposta[24]->cdata > 0 ? " - ".$proposta[25]->cdata : ""); ?>" readonly></td>
								</tr>									
								<tr>
									<td class="txtNormalBold" height="24" align="right">&nbsp;</td>
									<td class="txtNormal">&nbsp;</td>									
									<td class="txtNormalBold" align="right">%CET:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php echo number_format(str_replace(",",".",$proposta[26]->cdata),2,",","."); ?>" readonly></td>
								</tr>
								<tr>
									<td class="txtNormalBold" height="24" align="right">Liberar Em:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php $proposta[7]->cdata; ?>" readonly></td>								
									<td class="txtNormalBold" align="right">Data do Pagto:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php echo $proposta[11]->cdata; ?>" readonly></td>
								</tr>
								<tr>
									<td class="txtNormalBold" height="24" align="right">Proposta:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php if ($proposta[8]->cdata == "yes") { echo "Imprime"; } else { echo "Nao Imprime"; } ?>" readonly></td>
									<td class="txtNormalBold" align="right">Nota Promiss&oacute;ria:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 100px;" value="<?php if ($proposta[9]->cdata == "yes") { echo "Imprime"; } else { echo "Nao Imprime"; } ?>" readonly></td>
								</tr>
								<tr>
									<td class="txtNormalBold" height="24" align="right">Liquida&ccedil;&otilde;es:&nbsp;</td>
									<td colspan="3" class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 380px;" value="<?php echo $proposta[12]->cdata; ?>" readonly></td>
								</tr>	
								<tr>
									<td class="txtNormalBold" height="78" align="right" valign="top">Observa&ccedil;&otilde;es:&nbsp;</td>
									<td colspan="3" class="txtNormal"><textarea class="campoTelaSemBorda" style="width: 380px;" rows="5" readonly><?php echo $proposta[18]->cdata; ?></textarea></td>
								</tr>
							</table>	
						</td>
					</tr>	
					<tr>
						<td height="10"></td>
					</tr>
					<tr>
						<td align="center">
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<?php 
									// Fun&ccedil;&atilde;o utilizada para bot&atilde;o continuar
									$fncVoltar = retornaFuncaoVoltar(1);
									
									if ($fncVoltar <> "") { 
									?>
									<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="<?php echo $fncVoltar; ?>return false;"></td>									
									<td width="10"></td>
									<?php
									}
									?>
									<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="<?php echo retornaFuncaoContinuar(1); ?>return false;"></td>								
								</tr>
							</table>
						</td>
					</tr>				
				</table>		
			</td>
		</tr>	
	</table>	
</div>
<?php 
// Se imprime proposta do empr&eacute;stimo, mostra Bens da Proposta
if ($proposta[8]->cdata == "yes") { 
?>
<div id="divDadosBensProposta">
	<table width="510" height="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td valign="middle">
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
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
									<td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;">PROPOSTA DE EMPR&Eacute;STIMO</td>
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
							<table width="100%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="115" height="24" align="right">Nome da Chefia:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 374px;" value="<?php echo $proposta[14]->cdata; ?>" readonly></td>
								</tr>
								<tr>
									<td class="txtNormalBold" height="24" align="right">Rela&ccedil;&atilde;o de Bens:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 374px;" value="<?php echo $proposta[19]->tags[0]->cdata; ?>" readonly></td>
								</tr>					
								<tr>
									<td class="txtNormalBold" height="24" align="right">&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 374px;" value="<?php echo $proposta[19]->tags[1]->cdata; ?>" readonly></td>
								</tr>	
								<tr>
									<td class="txtNormalBold" height="24" align="right">&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 374px;" value="<?php echo $proposta[19]->tags[2]->cdata; ?>" readonly></td>
								</tr>	
								<tr>
									<td class="txtNormalBold" height="24" align="right">&nbsp; </td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 374px;" value="<?php echo $proposta[19]->tags[3]->cdata; ?>" readonly></td>
								</tr>
								<tr>
									<td class="txtNormalBold" height="24" align="right">Rendas:&nbsp;</td>
									<td class="txtNormal">
										<table width="100%" cellpadding="0" cellspacing="0" border="0">
											<tr>
												<td width="45" class="txtNormalBold">Sal&aacute;rio:&nbsp;</td>
												<td width="145" class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 130px;" value="<?php echo number_format(str_replace(",",".",$proposta[15]->cdata),2,",","."); ?>" readonly></td>
												<td width="54" class="txtNormalBold">Conjug&ecirc;:&nbsp;</td>
												<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 130px;" value="<?php echo number_format(str_replace(",",".",$proposta[16]->cdata),2,",","."); ?>" readonly></td>
											</tr>
										</table>
									</td> 
								</tr>
								<tr>
									<td class="txtNormalBold" height="24" align="right">&nbsp;</td>
									<td class="txtNormal">
										<table width="100%" cellpadding="0" cellspacing="0" border="0">
											<tr>
												<td width="45" class="txtNormalBold">Outras:&nbsp;</td>
												<td width="145" class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 130px;" value="<?php echo number_format(str_replace(",",".",$proposta[17]->cdata),2,",","."); ?>" readonly></td>
												<td width="54" class="txtNormalBold">&nbsp;</td>
												<td class="txtNormal">&nbsp;</td>
											</tr>
										</table>
									</td> 
								</tr>								
							</table>	
						</td>
					</tr>	
					<tr>
						<td height="10"></td>
					</tr>
					<tr>
						<td align="center">
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>									
									<td align="center"><input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="<?php echo retornaFuncaoVoltar(2); ?>return false;"></td>									
									<td width="10"></td>
									<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="<?php echo retornaFuncaoContinuar(2); ?>return false;"></td>								
								</tr>
							</table>
						</td>
					</tr>				
				</table>		
			</td>
		</tr>	
	</table>	
</div>
<script type="text/javascript">	
$("#divDadosBensProposta").css("display","none");
</script>
<?php 
}

// Se imprime promiss&oacute;rias ou for linha de cr&eacute;dito para hipot&eacute;ca (2) ou aliena&ccedil;&atilde;o (3), mostra Avalistas
if ($proposta[9]->cdata == "yes" || $proposta[20]->cdata <> "1") { 
?>
<div id="divDadosAvalistas">
	<table width="510" height="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td valign="middle">
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
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
									<td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;">DADOS DOS AVALISTAS/FIADORES</td>
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
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="117" height="23" align="right">Qtde. Promiss&oacute;rias:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 30px;" value="<?php echo $proposta[13]->cdata; ?>" readonly></td>
								</tr>
							</table>							
						</td>
					</tr>
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="43" height="23" align="right">Conta:&nbsp;</td>
									<td class="txtNormal" width="65"><input type="text" class="campoTelaSemBorda" style="width: 60px;" value="<?php if ($flgAval01) { echo formataNumericos("zzzz.zzz-z",$avais[0]->tags[0]->cdata,".-"); } else { echo "0"; } ?>" readonly></td>
									<td class="txtNormalBold" width="44" align="right">Nome:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 351px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[1]->cdata; } ?>" readonly></td>
								</tr>
							</table>							
						</td>
					</tr>
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="63" height="23" align="right">CPF/CNPJ:&nbsp;</td>
									<td class="txtNormal" width="115"><input type="text" class="campoTelaSemBorda" style="width: 110px;" value="<?php if ($flgAval01 && $avais[0]->tags[2]->cdata > 0) { echo formataNumericos("99999999999999",$avais[0]->tags[2]->cdata,".-"); } else { echo "00000000000000"; } ?>" readonly></td>
									<td class="txtNormalBold" width="70" align="right">Documento:&nbsp;</td>
									<td class="txtNormal" width="26"><input type="text" class="campoTelaSemBorda" style="width: 22px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[3]->cdata; } ?>" readonly></td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 120px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[4]->cdata; } ?>" readonly></td>								
								</tr>
							</table>							
						</td>
					</tr>
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">							
								<tr>
									<td width="153" height="23" align="right" class="txtNormalBold">Conjug&ecirc;:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 350px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[5]->cdata; } ?>" readonly></td>
								</tr>		
							</table>							
						</td>
					</tr>
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">							
								<tr>
									<td class="txtNormalBold" width="63" height="23" align="right">CPF/CNPJ:&nbsp;</td>
									<td class="txtNormal" width="115"><input type="text" class="campoTelaSemBorda" style="width: 110px;" value="<?php if ($flgAval01 && $avais[0]->tags[6]->cdata > 0) { echo formataNumericos("99999999999999",$avais[0]->tags[6]->cdata,".-"); } else { echo "00000000000000"; } ?>" readonly></td>
									<td class="txtNormalBold" width="70" align="right">Documento:&nbsp;</td>
									<td class="txtNormal" width="26"><input type="text" class="campoTelaSemBorda" style="width: 22px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[7]->cdata; } ?>" readonly></td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 120px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[8]->cdata; } ?>" readonly></td>
								</tr>												
							</table>							
						</td>
					</tr>			
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="35" height="23" align="right">End.:&nbsp;</td>
									<td class="txtNormal" width="364"><input type="text" class="campoTelaSemBorda" style="width: 359px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[9]->cdata; } ?>" readonly></td>
									<td class="txtNormalBold" width="32" align="right">CEP:&nbsp;</td>		
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 72px;" value="<?php if ($flgAval01) { echo formataNumericos("zzzzz-zzz",$avais[0]->tags[15]->cdata,"-"); } else { echo "0"; } ?>" readonly></td>						
								</tr>
							</table>							
						</td>
					</tr>					
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="45" height="23" align="right">Bairro:&nbsp;</td>
									<td class="txtNormal" width="175"><input type="text" class="campoTelaSemBorda" style="width: 170px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[10]->cdata; } ?>" readonly></td>
									<td class="txtNormalBold" width="49" height="20" align="right">Cidade:&nbsp;</td>
									<td class="txtNormal" width="185"><input type="text" class="campoTelaSemBorda" style="width: 180px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[13]->cdata; } ?>" readonly></td>
									<td class="txtNormalBold" width="24" align="right">UF:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 25px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[14]->cdata; } ?>" readonly></td>								
								</tr>
							</table>							
						</td>
					</tr>
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td width="45" height="23" align="right" class="txtNormalBold">E-Mail:&nbsp;</td>
									<td class="txtNormal" width="300"><input type="text" class="campoTelaSemBorda" style="width: 295px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[12]->cdata; } ?>" readonly></td>
									<td class="txtNormalBold" width="38" align="right">Fone:&nbsp;</td>								
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 120px;" value="<?php if ($flgAval01) { echo $avais[0]->tags[11]->cdata; } ?>" readonly></td>
								</tr>
							</table>							
						</td>
					</tr>		
					<tr>
						<td height="4"></td>
					</tr>								
					<tr>
						<td height="1" style="background-color: #333333;"></td>
					</tr>								
					<tr>
						<td height="4"></td>
					</tr>																
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="43" height="23" align="right">Conta:&nbsp;</td>
									<td class="txtNormal" width="65"><input type="text" class="campoTelaSemBorda" style="width: 60px;" value="<?php if ($flgAval02) { echo formataNumericos("zzzz.zzz-z",$avais[1]->tags[0]->cdata,".-"); } else { echo "0"; } ?>" readonly></td>
									<td class="txtNormalBold" width="44" align="right">Nome:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 351px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[1]->cdata; } ?>" readonly></td>
								</tr>
							</table>							
						</td>
					</tr>
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="63" height="23" align="right">CPF/CNPJ:&nbsp;</td>
									<td class="txtNormal" width="115"><input type="text" class="campoTelaSemBorda" style="width: 110px;" value="<?php if ($flgAval02 && $avais[1]->tags[2]->cdata > 0) { echo formataNumericos("99999999999999",$avais[1]->tags[2]->cdata,".-"); } else { echo "00000000000000"; } ?>" readonly></td>
									<td class="txtNormalBold" width="70" align="right">Documento:&nbsp;</td>
									<td class="txtNormal" width="26"><input type="text" class="campoTelaSemBorda" style="width: 22px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[3]->cdata; } ?>" readonly></td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 120px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[4]->cdata; } ?>" readonly></td>
								</tr>
							</table>							
						</td>
					</tr>
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">							
								<tr>
									<td width="153" height="23" align="right" class="txtNormalBold">Conjug&ecirc;:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 350px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[5]->cdata; } ?>" readonly></td>
								</tr>		
							</table>							
						</td>
					</tr>
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">							
								<tr>
									<td class="txtNormalBold" width="63" height="23" align="right">CPF/CNPJ:&nbsp;</td>
									<td class="txtNormal" width="115"><input type="text" class="campoTelaSemBorda" style="width: 110px;" value="<?php if ($flgAval02 && $avais[1]->tags[6]->cdata > 0) { echo formataNumericos("99999999999999",$avais[1]->tags[6]->cdata,".-"); } else { echo "00000000000000"; } ?>" readonly></td>
									<td class="txtNormalBold" width="70" align="right">Documento:&nbsp;</td>
									<td class="txtNormal" width="26"><input type="text" class="campoTelaSemBorda" style="width: 22px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[7]->cdata; } ?>" readonly></td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 120px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[8]->cdata; } ?>" readonly></td>
								</tr>												
							</table>							
						</td>
					</tr>			
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="35" height="23" align="right">End.:&nbsp;</td>
									<td class="txtNormal" width="364"><input type="text" class="campoTelaSemBorda" style="width: 359px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[9]->cdata; } ?>" readonly></td>
									<td class="txtNormalBold" width="32" align="right">CEP:&nbsp;</td>		
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 72px;" value="<?php if ($flgAval02) { echo formataNumericos("zzzzz-zzz",$avais[1]->tags[15]->cdata,"-"); } else { echo "0"; } ?>" readonly></td>						
								</tr>
							</table>							
						</td>
					</tr>					
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="45" height="23" align="right">Bairro:&nbsp;</td>
									<td class="txtNormal" width="175"><input type="text" class="campoTelaSemBorda" style="width: 170px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[10]->cdata; } ?>" readonly></td>
									<td class="txtNormalBold" width="49" height="20" align="right">Cidade:&nbsp;</td>
									<td class="txtNormal" width="185"><input type="text" class="campoTelaSemBorda" style="width: 180px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[13]->cdata; } ?>" readonly></td>
									<td class="txtNormalBold" width="24" align="right">UF:&nbsp;</td>
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 25px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[14]->cdata; } ?>" readonly></td>								
								</tr>
							</table>							
						</td>
					</tr>
					<tr>
						<td>
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td width="45" height="23" align="right" class="txtNormalBold">E-Mail:&nbsp;</td>
									<td class="txtNormal" width="300"><input type="text" class="campoTelaSemBorda" style="width: 295px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[12]->cdata; } ?>" readonly></td>
									<td class="txtNormalBold" width="38" align="right">Fone:&nbsp;</td>								
									<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 120px;" value="<?php if ($flgAval02) { echo $avais[1]->tags[11]->cdata; } ?>" readonly></td>
								</tr>
							</table>							
						</td>
					</tr>		
					<tr>
						<td height="10"></td>
					</tr>
					<tr>
						<td align="center">
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>									
									<td align="center"><input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="<?php echo retornaFuncaoVoltar(3); ?>return false;"></td>									
									<td width="10"></td>
									<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="<?php echo retornaFuncaoContinuar(3); ?>return false;"></td>															
								</tr>
							</table>
						</td>
					</tr>															
				</table>	
			</td>
		</tr>			
	</table>
</div>
<script type="text/javascript">	
$("#divDadosAvalistas").css("display","none");
</script>
<?php 
}

// Se for linha de cr&eacute;dito para aliena&ccedil;&atilde;o, mostra dados para Aliena&ccedil;&atilde;o
if ($proposta[20]->cdata == "2" && $qtBensAlienacao > 0) { 
?>
<div id="divDadosAlienacao">
	<table width="510" height="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td valign="middle">
				<form action="" name="frmAlienacao" id="frmAlienacao" method="post">
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
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
									<td height="18" class="txtNormalBold" align="center" style="background-color:#E3E2DD;">DADOS PARA ALIENA&Ccedil;&Atilde;O FIDUCI&Aacute;RIA</td>
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
							<table width="100%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="125" height="24" align="right">Bens:&nbsp;</td>
									<td class="txtNormal">
										<select class="campoTelaSemBorda" id="aux_idbemali" name="aux_idbemali">
											<?php for ($i = 0; $i < $qtBensAlienacao; $i++) { ?>
											<option value="<?php echo $i; ?>"><?php echo $alienacao[$i]->tags[0]->cdata; ?></option>
											<?php } ?>
										</select>										
									</td>
								</tr>						
							</table>
						</td>
					</tr>								
					<tr> 
						<td id="tdDivBensAlienacao"> 
							<?php for ($i = 0; $i < $qtBensAlienacao; $i++) { ?>
							<div id="divBemAlienacao<?php echo $i; ?>">
								<table width="100%" border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td>
											<table width="100%" border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td class="txtNormalBold" width="125" height="24" align="right">Categoria:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 300px;" value="<?php echo $alienacao[$i]->tags[1]->cdata; ?>" readonly></td>
												</tr>
												<tr>
													<td class="txtNormalBold" height="24" align="right">Descri&ccedil;&atilde;o:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 300px;" value="<?php echo $alienacao[$i]->tags[2]->cdata; ?>" readonly></td>
												</tr>					
												<tr>
													<td class="txtNormalBold" height="24" align="right">Cor/Classe:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 300px;" value="<?php echo $alienacao[$i]->tags[3]->cdata; ?>" readonly></td>
												</tr>	
											</table>
										</td>
									</tr>
									<tr>
										<td>
											<table width="100%" border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td width="125" height="24" align="right" class="txtNormalBold">Chassi/N&ordm; de S&eacute;rie:&nbsp;</td>
													<td width="210" class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 200px;" value="<?php echo $alienacao[$i]->tags[4]->cdata; ?>" readonly></td>
													<td width="133" align="right" class="txtNormalBold">Tipo do Chassi:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 25px;" value="<?php echo $alienacao[$i]->tags[9]->cdata; ?>" readonly></td>
												</tr>
											</table>
										</td> 
									</tr>								
									<tr>
										<td>
											<table width="100%" cellpadding="0" cellspacing="2" border="0">
												<tr>
													<td width="125" height="24" align="right" class="txtNormalBold">UF/Placa:&nbsp;</td>
													<td width="28" class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 25px;" value="<?php echo $alienacao[$i]->tags[10]->cdata; ?>" readonly></td>
													<td width="10" align="center" class="txtNormal">/</td>
													<td width="80" class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 70px;" value="<?php echo $alienacao[$i]->tags[7]->cdata; ?>" readonly></td>
													<td width="213" align="right" class="txtNormalBold">UF Licenciamento:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 25px;" value="SC" readonly></td>
												</tr>
											</table>
										</td> 
									</tr>								
									<tr>
										<td>
											<table width="100%" cellpadding="0" cellspacing="2" border="0">
												<tr>
													<td width="125" height="24" align="right" class="txtNormalBold">Renavam:&nbsp;</td>
													<td width="80" class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 70px;" value="<?php echo $alienacao[$i]->tags[8]->cdata; ?>" readonly></td>
													<td width="101" align="right" class="txtNormalBold">Ano Fabrica&ccedil;&atilde;o:&nbsp;</td>
													<td width="52" class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 42px;" value="<?php echo $alienacao[$i]->tags[5]->cdata; ?>" readonly></td>
													<td width="81" align="right" class="txtNormalBold">Ano Modelo:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 42px;" value="<?php echo $alienacao[$i]->tags[6]->cdata; ?>" readonly></td>
												</tr>
											</table>
										</td> 
									</tr>							
									<tr>
										<td>
											<table width="100%" border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td class="txtNormalBold" width="125" height="24" align="right">CPF/CNPJ Propr.:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 200px;" value="<?php echo $alienacao[$i]->tags[12]->cdata; ?>" readonly></td>
												</tr>											
											</table>	
										</td>
									</tr>											
								</table>
							</div>
							<?php } ?>
						</td> 
					</tr> 			
					<tr>
						<td height="10"></td>
					</tr>
					<tr>
						<td align="center">
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>									
									<td align="center"><input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="<?php echo retornaFuncaoVoltar(4); ?>return false;"></td>
									<td width="10"></td>
									<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="<?php echo retornaFuncaoContinuar(4); ?>return false;"></td>								
								</tr>
							</table>
						</td>
					</tr>																										
				</table>	
				</form>
			</td>
		</tr>			
	</table>	
</div>
<script type="text/javascript">	
$("#aux_idbemali","#frmAlienacao").unbind("change");
$("#aux_idbemali","#frmAlienacao").bind("change",function () {	
	$("#tdDivBensAlienacao > div").each(function(i) {
		$(this).css("display","none");
	});
	
	$("#divBemAlienacao" + $(this).val()).css("display","block");
});

$("#aux_idbemali","#frmAlienacao").trigger("change");

$("#divDadosAlienacao").css("display","none");
</script>
<?php 
} 

// Se for linha de cr&eacute;dito para aliena&ccedil;&atilde;o, mostra dados dos Intervenientes Anuentes
if ($proposta[20]->cdata == "2" && $qtIntervenientes > 0) { 
?>
<div id="divDadosIntervenientes">
	<table width="510" height="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td valign="middle">
				<form action="" name="frmIntervenientes" id="frmIntervenientes" method="post">
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
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
									<td height="18" class="txtNormalBold" align="center" style="background-color:#E3E2DD;">DADOS DO INTERVENIENTE ANUENTE</td>
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
							<table width="100%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="140" height="24" align="right">Interveniente Anuente:&nbsp;</td>
									<td class="txtNormal">
										<select class="campoTelaSemBorda" id="aux_idinterv" name="aux_idinterv">
											<?php for ($i = 0; $i < $qtIntervenientes; $i++) { ?>
											<option value="<?php echo $i; ?>"><?php echo $i + 1; ?></option>
											<?php } ?>
										</select>										
									</td>
								</tr>						
							</table>
						</td>
					</tr>								
					<tr> 
						<td id="tdDivIntervenientes"> 
							<?php for ($i = 0; $i < $qtIntervenientes; $i++) { ?>
							<div id="divInterveniente<?php echo $i; ?>">
								<table width="100%" border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td>
											<table width="100%" border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td class="txtNormalBold" width="45" height="24" align="right">Conta:&nbsp;</td>
													<td width="100" class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 95px;" value="<?php echo formataNumericos("zzzz.zzz-z",$intervenientes[$i]->tags[0]->cdata,".-"); ?>" readonly></td>
												  <td width="75" align="right" class="txtNormalBold">Nome:&nbsp;</td>
												  <td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 283px;" value="<?php echo $intervenientes[$i]->tags[1]->cdata; ?>" readonly></td>
												</tr>
												<tr>
													<td class="txtNormalBold" height="24" align="right">CPF:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 95px;" value="<?php echo formataNumericos("99999999999999",$intervenientes[$i]->tags[2]->cdata,".-"); ?>" readonly></td>
												  <td align="right" class="txtNormalBold">Documento:&nbsp;</td>
												  <td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 22px;" value="<?php echo $intervenientes[$i]->tags[3]->cdata; ?>" readonly>&nbsp;&nbsp;<input type="text" class="campoTelaSemBorda" style="width: 95px;" value="<?php echo $intervenientes[$i]->tags[4]->cdata; ?>" readonly></td>
												</tr>					
												<tr>
													<td class="txtNormalBold" height="24" align="right">Nasc.:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 95px;" value="<?php echo $intervenientes[$i]->tags[5]->cdata; ?>" readonly></td>
												  <td align="right" class="txtNormalBold">Conjug&ecirc;:&nbsp;</td>
												  <td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 283px;" value="<?php echo $intervenientes[$i]->tags[6]->cdata; ?>" readonly></td>
												</tr>	
												<tr>
													<td class="txtNormalBold" height="24" align="right">CPF:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 95px;" value="<?php echo formataNumericos("99999999999999",$intervenientes[$i]->tags[7]->cdata,".-"); ?>" readonly></td>
												  <td align="right" class="txtNormalBold">Documento:&nbsp;</td>
												  <td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 22px;" value="<?php echo $intervenientes[$i]->tags[8]->cdata; ?>" readonly>&nbsp;&nbsp;<input type="text" class="campoTelaSemBorda" style="width: 95px;" value="<?php echo $intervenientes[$i]->tags[9]->cdata; ?>" readonly></td>
												</tr>													
											</table>
										</td>
									</tr>
									<tr>
										<td>
											<table border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td class="txtNormalBold" width="45" height="23" align="right">End.:&nbsp;</td>
													<td class="txtNormal" width="364"><input type="text" class="campoTelaSemBorda" style="width: 359px;" value="<?php echo $intervenientes[$i]->tags[10]->tags[0]->cdata; ?>" readonly></td>
													<td class="txtNormalBold" width="32" align="right">CEP:&nbsp;</td>		
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 62px;" value="<?php echo formataNumericos("zzzzz-zzz",$intervenientes[$i]->tags[15]->cdata,"-"); ?>" readonly></td>						
												</tr>
											</table>							
										</td>
									</tr>					
									<tr>
										<td>
											<table border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td class="txtNormalBold" width="45" height="23" align="right">Bairro:&nbsp;</td>
													<td class="txtNormal" width="175"><input type="text" class="campoTelaSemBorda" style="width: 170px;" value="<?php echo $intervenientes[$i]->tags[10]->tags[1]->cdata; ?>" readonly></td>
													<td class="txtNormalBold" width="49" height="20" align="right">Cidade:&nbsp;</td>
													<td class="txtNormal" width="185"><input type="text" class="campoTelaSemBorda" style="width: 180px;" value="<?php echo $intervenientes[$i]->tags[13]->cdata; ?>" readonly></td>
													<td class="txtNormalBold" width="24" align="right">UF:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 25px;" value="<?php echo $intervenientes[$i]->tags[14]->cdata; ?>" readonly></td>								
												</tr>
											</table>							
										</td>
									</tr>
									<tr>
										<td>
											<table border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td width="45" height="23" align="right" class="txtNormalBold">E-Mail:&nbsp;</td>
													<td class="txtNormal" width="300"><input type="text" class="campoTelaSemBorda" style="width: 295px;" value="<?php echo $intervenientes[$i]->tags[12]->cdata; ?>" readonly></td>
													<td class="txtNormalBold" width="38" align="right">Fone:&nbsp;</td>								
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 120px;" value="<?php echo $intervenientes[$i]->tags[11]->cdata; ?>" readonly></td>
												</tr>
											</table>							
										</td>
									</tr>											
								</table>
							</div>
							<?php } ?>
						</td> 
					</tr> 			
					<tr>
						<td height="10"></td>
					</tr>
					<tr>
						<td align="center">
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="<?php echo retornaFuncaoVoltar(5); ?>return false;"></td>
									<td width="10"></td>
									<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="<?php echo retornaFuncaoContinuar(5); ?>return false;"></td>								
								</tr>							
							</table>									
						</td>
					</tr>																										
				</table>	
				</form>
			</td>
		</tr>			
	</table>	
</div>
<script type="text/javascript">	
$("#aux_idinterv","#frmIntervenientes").unbind("change");
$("#aux_idinterv","#frmIntervenientes").bind("change",function () {	
	$("#tdDivIntervenientes > div").each(function(i) {
		$(this).css("display","none");
	});
	
	$("#divInterveniente" + $(this).val()).css("display","block");
});

$("#aux_idinterv","#frmIntervenientes").trigger("change");

$("#divDadosIntervenientes").css("display","none");
</script>
<?php 
} 

// Se for linha de cr&eacute;dito para hipot&eacute;ca, mostra dados para Hipot&eacute;ca
if ($proposta[20]->cdata == "3" && $qtHipoteca > 0) { 
?>
<div id="divDadosHipoteca">
	<table width="510" height="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td valign="middle">
				<form action="" name="frmHipoteca" id="frmHipoteca" method="post">
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
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
									<td height="18" class="txtNormalBold" align="center" style="background-color:#E3E2DD;">DADOS PARA HIPOT&Eacute;CA</td>
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
							<table width="100%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td class="txtNormalBold" width="110" height="24" align="right">Im&oacute;veis:&nbsp;</td>
									<td class="txtNormal">
										<select class="campoTelaSemBorda" id="aux_idhipote" name="aux_idhipote">
											<?php for ($i = 0; $i < $qtHipoteca; $i++) { ?>
											<option value="<?php echo $i; ?>"><?php echo $hipoteca[$i]->tags[0]->cdata; ?></option>
											<?php } ?>
										</select>										
									</td>
								</tr>						
							</table>
						</td>
					</tr>								
					<tr> 
						<td id="tdDivHipoteca"> 
							<?php for ($i = 0; $i < $qtHipoteca; $i++) { ?>
							<div id="divHipoteca<?php echo $i; ?>">
								<table width="100%" border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td>
											<table width="100%" border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td class="txtNormalBold" width="110" height="24" align="right">Categoria:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 360px;" value="<?php echo $hipoteca[$i]->tags[1]->cdata; ?>" readonly></td>
												</tr>
												<tr>
													<td class="txtNormalBold" height="24" align="right">Descri&ccedil;&atilde;o:&nbsp;</td>
													<td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 360px;" value="<?php echo $hipoteca[$i]->tags[2]->tags[0]->cdata; ?>" readonly></td>
												</tr>
												<tr>
												  <td class="txtNormalBold" height="24" align="right">&nbsp;</td>
												  <td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 360px;" value="<?php echo $hipoteca[$i]->tags[2]->tags[1]->cdata; ?>" readonly></td>
												  </tr>
												<tr>
												  <td class="txtNormalBold" height="24" align="right">Endere&ccedil;o:&nbsp;</td>
												  <td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 360px;" value="<?php echo $hipoteca[$i]->tags[3]->tags[0]->cdata; ?>" readonly></td>
												  </tr>
												<tr>
												  <td class="txtNormalBold" height="24" align="right">&nbsp;</td>
												  <td class="txtNormal"><input type="text" class="campoTelaSemBorda" style="width: 360px;" value="<?php echo $hipoteca[$i]->tags[3]->tags[1]->cdata; ?>" readonly></td>
												  </tr>					
											</table>
										</td>
									</tr>
								</table>
							</div>
							<?php } ?>
						</td> 
					</tr>			
					<tr>
						<td height="10"></td>
					</tr>
					<tr>
						<td align="center">
							<table border="0" cellpadding="0" cellspacing="0">
								<tr>									
									<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="<?php echo retornaFuncaoVoltar(4); ?>return false;"></td>
									<td width="10"></td>
									<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="<?php echo retornaFuncaoContinuar(4); ?>return false;"></td>								
								</tr>							
							</table>								
						</td>
					</tr>																										
				</table>	
				</form>
			</td>
		</tr>			
	</table>	
</div>
<script type="text/javascript">	
$("#aux_idhipote","#frmHipoteca").unbind("change");
$("#aux_idhipote","#frmHipoteca").bind("change",function () {	
	$("#tdDivHipoteca > div").each(function(i) {
		$(this).css("display","none");
	});
	
	$("#divHipoteca" + $(this).val()).css("display","block");
});

$("#aux_idhipote","#frmHipoteca").trigger("change");

$("#divDadosHipoteca").css("display","none");
</script>
<?php 
} 
?>
<script type="text/javascript">	
mostraDivProposta();

antDiv2 = "divDadosProposta";

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>