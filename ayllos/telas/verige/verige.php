<? 
/*!
 * FONTE        : verige.php
 * CRIAÇÃO      : Carlos (CECRED)
 * DATA CRIAÇÃO : 11/11/2013
 * OBJETIVO     : Mostrar tela VERIGE					ÚLTIMA ALTERAÇÃO: 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

<? 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	require_once("../../includes/carrega_permissoes.php");

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0131.p</Bo>';
	$xml .= '		<Proc>Busca_Cooperativas</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nmrescop>'.$glbvars['nmrescop'].'</nmrescop>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 		= getDataXML($xml);
	$xmlObjeto 		= getObjectXML($xmlResult);

	// Recebe as cooperativas
	$nmcooper		= $xmlObjeto->roottag->tags[0]->attributes['NMCOOPER'];
	//$nmcoper2		= $xmlObjeto->roottag->tags[0]->attributes['NMCOPER2'];
	$nmcoper2 = $nmcooper;
	
	// Faz o tratamento para criar o select
	$nmcooperArray	= explode(',', $nmcooper);
	$nmcoope2Array	= explode(',', $nmcoper2);

	$qtcooper		= count($nmcooperArray);
	$qtcoper2		= count($nmcoope2Array);
	
	$slcooper		= '';
	$slcoper2		= ''; 

	//
	for ( $j = 0; $j < $qtcooper; $j +=2 ) {
		$slcooper = $slcooper . '<option value="'.$nmcooperArray[$j+1].'">'.$nmcooperArray[$j].'</option>';
	}

	//
	for ( $i = 0; $i < $qtcoper2; $i +=2 ) {
		$slcoper2 = $slcoper2 . '<option value="'.$nmcoope2Array[$i+1].'">'.$nmcoope2Array[$i].'</option>';
	}

	
?>

<script>
var dtmvtolt = '<?php echo $glbvars['dtmvtolt'] ?>';
var slcooper = '<?php echo $slcooper ?>';
var slcoper2 = '<?php echo $slcoper2 ?>';
var cdcoplog = '<?php echo $glbvars['cdcooper'] ?>';


</script>

<html>
    <head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<meta http-equiv="Pragma" content="no-cache">
		<title><? echo $TituloSistema; ?></title>
		<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="../../scripts/scripts.js" charset="utf-8"></script>
		<script type="text/javascript" src="../../scripts/dimensions.js"></script>
		<script type="text/javascript" src="../../scripts/funcoes.js"></script>
		<script type="text/javascript" src="../../scripts/mascara.js"></script>
		<script type="text/javascript" src="../../scripts/menu.js"></script>
		<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
		<script type="text/javascript" src="verige.js?v=<?php echo time()?>"></script>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('VERIGE - Consulta Grupo Econômico') ?></td>
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
															<table width="765" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																<tr>
																	<td>

																		<!-- INCLUDE DA TELA DE PESQUISA -->
																		<? require_once("../../includes/pesquisa/pesquisa.php"); ?>

																		<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																		<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>

																		<!-- INCLUDE COM AS MENSAGEM -->
																		<? include('msg_alerta.php')?>

																		<div id="divRotina"></div>
																		<div id="divUsoGenerico"></div>

																		<div id="divTela">																		
																			<div style="width:570px;text-align: center;margin:0 auto">
																				<? include('form_cabecalho.php'); ?>	

																				<div id="divEndivGrupo"></div>

																				<div id="divMsgAjuda">

																					<div id="divBotoes" style="margin-top:-10px; height:25px">
																						<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar<a/>
																					</div>

																				</div>
																			</div>
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