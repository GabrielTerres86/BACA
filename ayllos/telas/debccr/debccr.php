<? 
/*!
 * FONTE        : debccr.php
 * CRIAÇÃO      : Tiago
 * DATA CRIAÇÃO : 23/07/2015
 * OBJETIVO     : Mostrar tela debccr
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

<? 
session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");	
require_once("../../includes/controla_secao.php");
		
// Verifica se tela foi chamada pelo método POST
isPostMethod();
	
// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");	
	
// Carrega permissões do operador
include("../../includes/carrega_permissoes.php");

?>

<html>
    <head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">	
		<meta http-equiv="Pragma" content="no-cache">
		<title><? echo $TituloSistema; ?></title>
		<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">		
		<link href="../../css/tooltip.css" rel="stylesheet" type="text/css">
    	<link rel="stylesheet" href="../../css/base/jquery.ui.all.css">
	
		<script type="text/javascript" src="../../scripts/scripts.js" charset="utf-8"></script>
		<script type="text/javascript" src="../../scripts/dimensions.js"></script>
		<script type="text/javascript" src="../../scripts/funcoes.js"></script>
		<script type="text/javascript" src="../../scripts/mascara.js"></script>
		<script type="text/javascript" src="../../scripts/menu.js"></script>
		<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
		
		<script type="text/javascript" src="../../scripts/ui/jquery.ui.core.js"></script>
		<script type="text/javascript" src="../../scripts/ui/jquery.ui.datepicker.js"></script>
		<script type="text/javascript" src="../../scripts/ui/i18n/jquery.ui.datepicker-pt-BR.js"></script>
		<script type="text/javascript" src="../../scripts/tooltip.js"></script>
		
		<script type="text/javascript" src="debccr.js"></script>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('DEBCCR - D&eacute;bito On-line de Faturas de Cart&atilde;o Cr&eacute;dito') ?></td>
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
															<table width="680" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
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
																			
																			<div id="divTabela">
																				<? include("form_debccr.php");  ?>
																			</div>
																			<br/>
																			<div id="divFaturaPendente"></div>
																			
																			<div id="divBotoes" style='margin-bottom :10px' style="display:none">																						
																				<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>
																				<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >Carregar</a>
																			</div> 
																		</div>
																		<form class="formulario" id="frmImpressao" name="frmImpressao" >
																			<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
																			<input name="nmarqpdf" id="nmarqpdf" type="hidden" value="" />																			
																		</form>
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