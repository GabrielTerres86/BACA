<?php
/* 
 * FONTE        : parrat.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 24/01/2019
 * OBJETIVO     : Alterar e Consultar - Parâmetros do Rating
 * ALTERAÇÕES   : 25/02/2019 - Adicionado o campo "Habilitar contingência"
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
 *                04/03/2019 - Adicionado o campo "Habilitar sugestão" para as cooperativas
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
*/

session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();

// Carrega permissões do operador
include("../../includes/carrega_permissoes.php");

$xml = "<Root>";
$xml .= " <Dados>";
//Apenas carregar todas se for coop 3 - cecred
if ($glbvars["cdcooper"] == 3){
	$xml .= "   <cdcooper>0</cdcooper>";
}else{
	$xml .= '   <cdcooper>'.$glbvars["cdcooper"].'</cdcooper>';
}
$xml .= "   <flgativo>1</flgativo>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

$registros = $xmlObj->roottag->tags[0]->tags;
$htmlOpcoesCooperativas = '{';
foreach ($registros as $r) {
	if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
		// $htmlOpcoesCooperativas .= '<option value="' . getByTagName($r->tags, 'cdcooper') . '">' . getByTagName($r->tags, 'nmrescop') . '</option>';
		$htmlOpcoesCooperativas .= '"'.getByTagName($r->tags, 'cdcooper').'" : "'.getByTagName($r->tags, 'nmrescop').'",';
	}
}
$htmlOpcoesCooperativas .= '}';

?>

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta http-equiv="Pragma" content="no-cache">
	<title><?php echo $TituloSistema; ?></title>
	<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="../../scripts/scripts.js" charset="utf-8"></script>
	<script type="text/javascript" src="../../scripts/dimensions.js"></script>
	<script type="text/javascript" src="../../scripts/funcoes.js"></script>
	<script type="text/javascript" src="../../scripts/mascara.js"></script>
	<script type="text/javascript" src="../../scripts/menu.js"></script>
	<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>

	<script type="text/javascript">
		var opcoesCooperativas = <?=$htmlOpcoesCooperativas?>;
	</script>
	<script type="text/javascript" src="parrat.js?keyrand=<?php echo mt_rand(); ?>"></script>
</head>
<body>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td><?php include("../../includes/topo.php"); ?></td>
		</tr>
		<tr>
			<td id="tdConteudo" valign="top">
				<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
					<tr> 
						<td width="175" valign="top">
							<table width="100%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td id="tdMenu"><?php include("../../includes/menu.php"); ?></td>
								</tr>  
							</table>
						</td>
						<td id="tdTela" valign="top">
							<table width="100%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td>
										<table width="100%"  border="0" cellspacing="0" cellpadding="0">
											<tr>
												<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
												<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8_decode('PARRAT - Parâmetros do Rating') ?></td>
												<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
												<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
												<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
											</tr>
										</table>
									</td>
								</tr>
								<tr>
									<td id="tdConteudoTela" class="tdConteudoTela" align="center">
										<table width="100%" border="0" cellpadding="3" cellspacing="0">
											<tr>
												<td style="border: 1px solid #F4F3F0;">
													<table width="100%" border="0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
														<tr>
															<td align="center">
																<table width="670" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																	<tr>
																		<td style="background-color: #F4F3F0; padding: 2px;">
																			<!-- INCLUDE DA TELA DE PESQUISA -->
																			<?php require_once("../../includes/pesquisa/pesquisa.php"); ?>

																			<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																			<?php require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>

																			<div id="divRotina"></div>
																			<div id="divUsoGenerico"></div>

																			<div id="divTela">

																				<div id="divCabecalho"></div>
																				<div id="divConteudoOpcao"></div>

																			</div>

																		</td>
																	</tr>
																</table>
															</td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</html>
