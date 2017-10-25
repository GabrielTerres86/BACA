<? 
/*!
 * FONTE        : cadmat.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 22/09/2017
 * OBJETIVO     : Mostrar tela CADMAT
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

	// Armazena variáveis vindas do CRM
	$crm_inacesso = isset($glbvars['CRM_INACESSO']) ? $glbvars['CRM_INACESSO'] : 0;
	$crm_nrdconta = isset($glbvars['CRM_NRDCONTA']) ? $glbvars['CRM_NRDCONTA'] : 0;
	$crm_nrcpfcgc = isset($glbvars['CRM_NRCPFCGC']) ? $glbvars['CRM_NRCPFCGC'] : 0;
	$crm_cdoperad = isset($glbvars['CRM_CDOPERAD']) ? $glbvars['CRM_CDOPERAD'] : '';
	$crm_cdagenci = isset($glbvars['CRM_CDAGENCI']) ? $glbvars['CRM_CDAGENCI'] : 0;
	
?>

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
		<script type="text/javascript" src="cadmat.js?keyrand=<?php echo mt_rand(); ?>"></script>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('CADMAT -  Matrícula de Sócio') ?></td>
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
																	<td>
																		
																		<!-- INCLUDE DA TELA DE PESQUISA -->
																		<? require_once("../../includes/pesquisa/pesquisa.php"); ?>
																		
																		<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																		<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>
																		
																		<div id="divRotina"></div>
																		<div id="divUsoGenerico"></div>
																		
																		<div id="divTela">
																			<? include('form_cabecalho.php'); ?>
																			<? include('form_cadmat.php'); ?>
																			<div id="divBotoes" style="margin-top:5px; margin-bottom :10px;display:none">
																				<a href="#" class="botao" id="btVoltar" 	onclick="btnVoltar(); return false;">Voltar</a>
																				<a href="#" class="botao" id="btDemiss"     onclick="verificarDesligamento();">Desligamento</a>
																				<a href="#" class="botao" id="btTermDemiss" onclick="alert('Em desenvolvimento');">Termo Desligamento</a>
																				<a href="#" class="botao" id="btGerarTed"   onclick="gerarTedCapital();">Gerar TED Capital</a>
																				<a href="#" class="botao" id="btSaqParcial" onclick="alert('Em desenvolvimento');">Saque Parcial</a>
																				<a href="#" class="botao" id="btProsseguir">Prosseguir</a>
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
<script>
// Alimenta variáveis do CRM para o js
var crm_inacesso = <?php echo $crm_inacesso; ?>;
var crm_nrdconta = '<?php echo formataContaDVsimples($crm_nrdconta); ?>';
var crm_nrcpfcgc = normalizaNumero('<?php echo $crm_nrcpfcgc; ?>');
var crm_cdoperad = '<?php echo $crm_cdoperad; ?>';
var crm_cdagenci = <?php echo $crm_cdagenci; ?>;
</script>