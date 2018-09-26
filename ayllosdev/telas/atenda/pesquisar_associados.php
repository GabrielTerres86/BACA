<?php 
	//*********************************************************************************************//
	//*** Fonte: pesquisar_associados.php                                                       ***//
	//*** Autor: David                                                                          ***//
	//*** Data : Fevereiro/2008               &Uacute;ltima Altera&ccedil;&atilde;o: 13/08/2009 ***//
	//***                                                                                       ***//
	//*** Objetivo  : Efetuar pesquisa de associados na tela ATENDA                             ***//
	//***                                                                                       ***//	 
	//*** Altera&ccedil;&otilde;es: 13/08/2009 - Tratamento para paginacao (Guilherme).         ***//
	//***                           12/08/2013 - Alteração da sigla PAC para PA (Carlos).       ***//
	//*********************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Verifica Permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os par&acirc;metros necess&aacute;rios foram informados
	if (!isset($_POST["cdpesqui"]) || 
		!isset($_POST["nmdbusca"]) || 
		!isset($_POST["tpdapesq"]) || 
		!isset($_POST["cdagpesq"]) || 
		!isset($_POST["nrdctitg"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$cdpesqui = $_POST["cdpesqui"];
	$nmdbusca = $_POST["nmdbusca"];
	$tpdapesq = $_POST["tpdapesq"];
	$cdagpesq = $_POST["cdagpesq"];
	$nrdctitg = $_POST["nrdctitg"];	
	
	// Dados para pagina&ccedil;&atilde;o dos cooperados
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 1;
	$nrregist = 500;			

	// Verifica se tipo de pesquisa &eacute; v&aacute;lido
	if (!validaInteiro($cdpesqui) || ($cdpesqui <> "1" && $cdpesqui <> "2")) {
		exibeErro("Tipo de pesquisa inv&aacute;lido.");
	}	
	
	// Valida tipo de titular
	if ($cdpesqui == "1" && (!validaInteiro($tpdapesq) || $tpdapesq < 0 || $tpdapesq > 4)) {
		exibeErro("Tipo de Titular inv&aacute;lido.");
	}
	
	// Verifica se c&oacute;digo do PAC &eacute; um inteiro v&aacute;lido
	if ($cdpesqui == "1" && !validaInteiro($cdagpesq)) {
		exibeErro("C&oacute;digo de PA inv&aacute;lido.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0001.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>zoom-associados</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPesquisa .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPesquisa .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetPesquisa .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetPesquisa .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetPesquisa .= "		<cdpesqui>".$cdpesqui."</cdpesqui>";
	$xmlSetPesquisa .= "		<nmdbusca>".$nmdbusca."</nmdbusca>";
	$xmlSetPesquisa .= "		<tpdapesq>".$tpdapesq."</tpdapesq>";
	$xmlSetPesquisa .= "		<cdagpesq>".$cdagpesq."</cdagpesq>";
	$xmlSetPesquisa .= "		<nrdctitg>".$nrdctitg."</nrdctitg>";
	$xmlSetPesquisa .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xmlSetPesquisa .= "		<nrregist>".$nrregist."</nrregist>";
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";			
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPesquisa = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	$pesquisa = $xmlObjPesquisa->roottag->tags[0]->tags;

	// Quantidade total de cooperados na pesquisa
	$qtcopera = $xmlObjPesquisa->roottag->tags[0]->attributes["QTCOPERA"]; 
	
	if (count($pesquisa) == 0) {
		exibeErro("N&atilde;o h&aacute; associados com os dados informados.");
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divConsultaAssociado\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}		
	
?>
<div id="divListaAssociadosLista" style="overflow-y: scroll; overflow-x: hidden; height: 110px; width: 100%;">
	<table width="445" border="0" cellpadding="1" cellspacing="2">																																		
		<?php 	
		$style = "";
		
		for ($i = 0; $i < count($pesquisa); $i++) { 
			if ($style == "") {
				$style = "style=\"background-color: #FFFFFF;\"";
			} else {
				$style = "";
			}	
		?>
		<tr <?php echo $style; ?>>
			<td width="65" class="txtNormal" align="right"><a href="#" class="txtNormal" onClick="dadosContaConsulta('<?php echo $pesquisa[$i]->tags[1]->cdata; ?>');return false;"><?php echo formataContaDV($pesquisa[$i]->tags[1]->cdata); ?></a></td>
			<td width="300" class="txtNormal"><a href="#" class="txtNormal" onClick="dadosContaConsulta('<?php echo $pesquisa[$i]->tags[1]->cdata; ?>');return false;"><?php echo $pesquisa[$i]->tags[3]->cdata; ?></a></td>
			<td class="txtNormal" align="right"><?php if ($pesquisa[$i]->tags[4]->cdata <> "") { ?><a href="#" class="txtNormal" onClick="dadosContaConsulta('<?php echo $pesquisa[$i]->tags[1]->cdata; ?>');return false;"><?php echo formataNumericos("z.zzz.zzz-z",$pesquisa[$i]->tags[4]->cdata,".-"); ?></a><?php } else { echo "&nbsp;"; } ?></td>
		</tr>
		<?php
		} // Fim do for
		?>
	</table>
</div>	
<div id="divListaAssociadosRodape">
	<table width="445" border="0" cellpadding="1" cellspacing="2">	
		<tr>
			<td colspan="12" height="1" bgcolor="#EFF2E5"></td>
		</tr>						
		<tr>
			<td height="30" colspan="12">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<?php if ($nriniseq > 1) { ?>
						<td width="25" align="center"><a href="#" class="txtNormal" onClick="consultaAssociado(<?php echo $nriniseq - $nrregist; ?>);return false;"><img src="<?php echo $UrlImagens; ?>icones/ico_previous.gif" width="16" height="15" border="0"></a></td>
						<td width="50"><a href="#" class="txtNormal" onClick="consultaAssociado(<?php echo $nriniseq - $nrregist; ?>);return false;"><strong>Anterior</strong></a></td>
						<?php } else { ?>
						<td width="25" align="center">&nbsp;</td>
						<td width="50">&nbsp;</td>
						<?php } ?>
						<td align="center">
							<table cellpadding="0" cellspacing="0" border="0" width="250">
								<tr>
									<td class="txtNormal" style="border-bottom: 1px solid #CBDCC5;" align="center">Exibindo <strong><?php echo $nriniseq; ?></strong> at&eacute; <strong><?php if (($nriniseq + $nrregist) > $qtcopera) { echo $qtcopera; } else { echo ($nriniseq + $nrregist - 1); } ?></strong> de <strong><?php echo $qtcopera; ?></strong></td>
								</tr>
							</table>
						<?php if ($qtcopera > ($nriniseq + $nrregist - 1)) { ?>
						<td width="50" align="right"><a href="#" class="txtNormal" onClick="consultaAssociado(<?php echo $nriniseq + $nrregist; ?>);return false;"><strong>Pr&oacute;ximo</strong></a></td>
						<td width="25" align="center"><a href="#" class="txtNormal" onClick="consultaAssociado(<?php echo $nriniseq + $nrregist; ?>);return false;"><img src="<?php echo $UrlImagens; ?>icones/ico_next.gif" width="16" height="15" border="0"></a></td>
						<?php } else { ?>
						<td width="50" align="right">&nbsp;</td>
						<td width="0" align="center">&nbsp;</td>
						<?php } ?>
					</tr>
				</table>
			</td>
		</tr>
</div>			
<script type="text/javascript">
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divConsultaAssociado").css("z-index")));
</script>