<?php
/*!
 * FONTE        : manpac.php
 * CRIACAO      : Jean Michel
 * DATA CRIACAO : 15/03/2016
 * OBJETIVO     : Mostrar tela MANPAC
 * --------------
 * ALTERACOES   :
 *
 * --------------
 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	require_once("../../includes/carrega_permissoes.php");
	
?>
	<script>
		var dtmvtolt = '<? echo $glbvars['dtmvtolt']?>';
	</script>

<html>
    <head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">	
		<meta http-equiv="Pragma" content="no-cache">
		<title><? echo $TituloSistema; ?></title>
		<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="../../scripts/scripts.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>" charset="utf-8"></script>
		<script type="text/javascript" src="../../scripts/dimensions.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="../../scripts/funcoes.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="../../scripts/mascara.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="../../scripts/menu.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="manpac.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
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
													<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('MANPAC - Manuten&ccedil;&atilde;o dos Servi&ccedil;os Cooperativos') ?></td>
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
																	<table width="570" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																		<tr>
																			<td>
																				<!-- INCLUDE DA TELA DE PESQUISA -->
																				<? require_once("../../includes/pesquisa/pesquisa.php"); ?>
																		
																				<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																				<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>
																		
																				<!-- INCLUDE COM AS ANOTACOES -->
																				<? include('anotacoes.php') ?>
																		
																				<div id="divRotina"></div>
																				<div id="divUsoGenerico"></div>
																				<div id="divListaAnotacoes"></div>
																		
																				<div id="divTela">
																					<? include('form_cabecalho.php'); ?>
																					<form id="frmDados" name="frmDados" class="formulario">
																						<div id="divDadosMANPAC">
																							<?php include('form_dados.php'); ?>
																						</div>
																						<div id="divConsulta"></div>
																						<div id="divMigracao"></div>
																						<div id="divBotoes" style="margin-bottom: 10px;">
																							<a href="#" class="botao" id="btVoltar" onClick="verificaAcao('V'); return false;">Voltar</a>
																							<a href="#" class="botao" id="btnConcluir" onClick="verificaAcao('C');">Prosseguir</a>
																						</div>
																					</form>
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
