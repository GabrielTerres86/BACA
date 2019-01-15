<? 
/*!
 * FONTE        : parecc.php
 * CRIAÇÃO      : Luís Fernando Moraes
 * DATA CRIAÇÃO : 11/01/2018
 * OBJETIVO     : Mostrar tela parecc
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
	   <script type="text/javascript" src="../../scripts/jquery.mask.min.js"></script>
	   <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
	   <script type="text/javascript" src="parecc.js?keyrand=<?php echo mt_rand(); ?>"></script>
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
													<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo 'PARECC - Par&acirc;metro de Envio de Cart&atilde;o para o Endere&ccedil;o do Cooperado' ?></td>
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
																	<table width="510" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																		<tr>
																			<td>
																				<div id="divRotina"></div>
																				<div id="divUsoGenerico"></div>
																				
																				<div id="divTela">
																					<input type="hidden" name="hdnCooper" id="hdnCooper" value="<?php echo ( isset($glbvars["cdcooper"]) ) ? $glbvars["cdcooper"] : 0; ?>" />
																					<!-- Formulario para o cabecalho -->
																					<? include('form_cabecalho.php'); ?>

																					<!-- Formulario para editar os valores dos horarios -->
																					<? include('form_cadastro.php'); ?>
																					
																					<div id="divBotoes" style="display:none">
																						<a href="#" class="botao" id="btVoltar">Voltar</a>
																						<a href="#" class="botao" id="btSalvar">Continuar</a>
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