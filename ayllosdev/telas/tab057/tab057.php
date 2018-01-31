<? 
/*!
 * FONTE        : tab057.php
 * DATA CRIAÇÃO : 19/01/2018
 * OBJETIVO     : Mostrar tela TAB057
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
	
?>

<script>
var dtmvtglb = '<?php echo ( isset($glbvars['dtmvtolt']) ) ? $glbvars['dtmvtolt'] : ''; ?>';
</script>

<html>
	<head> 
	   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	   <meta http-equiv="Pragma" content="no-cache">
	   <title><?php echo $TituloSistema; ?></title>
	   <link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
	   <script type="text/javascript" src="../../scripts/scripts.js"></script>
	   <script type="text/javascript" src="../../scripts/dimensions.js"></script>
	   <script type="text/javascript" src="../../scripts/funcoes.js"></script>
	   <script type="text/javascript" src="../../scripts/mascara.js"></script>
	   <script type="text/javascript" src="../../scripts/menu.js"></script>	
	   <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
	   <script type="text/javascript" src="tab057.js?keyrand=<?php echo mt_rand(); ?>"></script>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('TAB057 - SEQUENCIAL DOS ARQUIVOS DE CONVÊNIO') ?></td>
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
															<table width="610" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																<tr>
																	<td>
																		<!-- INCLUDE DA TELA DE PESQUISA -->
																		<? require_once("../../includes/pesquisa/pesquisa.php"); ?>
																		
																		<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																		<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>
																		
																		<div id="divRotina"></div>
																		<div id="divUsoGenerico"></div>
																		
																		<div id="divTela">
																		    <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
																		
																		    <!-- Formulario para o cabecalho -->
																			<? include('form_cabecalho.php'); ?>

																		    <!-- Formulario para os filtros da tela -->
																			<? include('form_filtros.php'); ?>
																			
																			<!-- Formulario para editar os dados Sicredi -->
																			<? include('form_sicredi.php'); ?>
                                      
																			<!-- Formulario para editar os dados Bancoob -->
																			<? //include('form_bancoob.php'); ?>
																			
																			<div id="divConsulta"></div>
																			
																			<div id="divBotoes" style="margin-top:5px; margin-bottom :10px;display:none">
																				<a href="#" class="botao" id="btVoltar">Voltar</a>
																				<a href="#" class="botao" id="btSalvar">Prosseguir</a>
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