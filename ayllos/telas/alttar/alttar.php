<?php
/*!
 * FONTE        : alttar.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 25/08/2015
 * OBJETIVO     : Rotina para buscar sequencial da tabela ALTTAR
 * --------------
 * ALTERAÇÕES   : 30/10/2017 - Alterado a largura da tela para 800 para comportar os novos campos 
 *							   vlpertar, vlmaxtar, vlmintar e tpcobtar. PRJ M150 (Mateus Z - Mouts)
 *
 *                28/06/2018 - Recarregar o js sempre que abrir a tela
 *                             INC0017641 - Heitor (Mouts)
 * -------------- 
 */

	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');
	
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();
	
	// Carrega permissões do operador
	include("../../includes/carrega_permissoes.php");		
	
?>

<html> 
  <head> 
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <meta http-equiv="Pragma" content="no-cache">
   <title><?php echo $TituloSistema; ?></title>
   
   <link href="../../css/tooltip.css" rel="stylesheet" type="text/css">
   <link rel="stylesheet" href="../../css/base/jquery.ui.all.css">
   <link href="../../css/estilo2.css" rel="stylesheet" type="text/css">		
   
   <script type="text/javascript" src="../../scripts/scripts.js"></script>
   <script type="text/javascript" src="../../scripts/dimensions.js"></script>
   <script type="text/javascript" src="../../scripts/funcoes.js"></script>
   <script type="text/javascript" src="../../scripts/mascara.js"></script>
   <script type="text/javascript" src="../../scripts/menu.js"></script>	
   <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
   
   <script type="text/javascript" src="../../scripts/ui/jquery.ui.core.js"></script>
	<script type="text/javascript" src="../../scripts/ui/jquery.ui.datepicker.js"></script>
	<script type="text/javascript" src="../../scripts/ui/i18n/jquery.ui.datepicker-pt-BR.js"></script>
	<script type="text/javascript" src="../../scripts/tooltip.js"></script>
   
   <script type="text/javascript" src="alttar.js?keyrand=<?php echo mt_rand(); ?>"></script>
  </head>

  <body>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
		   <td><?php  include("../../includes/topo.php"); ?></td>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">ALTTAR - Alterar Tarifas </td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
										 	<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>						  
									      </tr>
									   </table>
     							    </td>								
								</tr>				
								<tr>
									<td id="tdConteudoTela" class="tdConteudoTela" align="center"> 
										<table width="100%"  border= "0" cellpadding="3" cellspacing="0">
											<tr>
												<td style="border: 1px solid #F4F3F0;">
													<table width="100%"  border= "0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
														<tr>
															<td align="center">
																<table width="800" border="0" cellpadding="0" cellspacing="0" style="backgroung-color: #F4F3F0;">
																	<tr>
																		<td>
																			<!-- INCLUDE DA TELA DE PESQUISA -->
																			<? require_once("../../includes/pesquisa/pesquisa.php"); ?>

																		    <div id="divRotina"></div>
																			<div id="divUsoGenerico"></div>
																			
																			<div id="divTela">
																				
																				<? include('form_cabecalho.php'); ?>	
																																								
																				<div id="divDetalhamento"> </div>
																				<div id="divParametro"> </div>
																				
																				
																																								
																				<div id="divBotoes" style="margin-top:5px; margin-bottom :10px;display:none">
																					<a href="#" class="botao" id="btVoltar"  onclick="btnVoltar(); return false;">Voltar</a>
																					<a href="#" class="botao" id="btSalvar"  onClick="btnContinuar(); return false;">Salvar</a>
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
