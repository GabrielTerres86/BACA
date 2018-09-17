<?php 
	/*********************************************************************
	 Fonte: trfcop.php                                                 
	 Autor: Gabriel                                                     
	 Data : Setembro/2011                Última Alteração: 27/12/2012 
	                                                                  
	 Objetivo  : Mostrar tela TRFCOP.                                 
	                                                                  
	 Alterações: 18/12/2012 - Alteracao layout tela, alterado css, alterado 
	                          botoes tag tipo input para tag a (Daniel).

				 27/12/2012 - Deixar mais espaco entre os botoes (Gabriel)				
	**********************************************************************/
	
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

	setVarSession("opcoesTela",$opcoesTela);
		
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
<script type="text/javascript" src="trfcop.js"></script>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">TRFCOP - Transfer&ecirc;ncia intercooperativa </td>
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
															<table width="660" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																<tr>
																	<td>															
																		<table width="100%" border="0" cellspacing="0" cellpadding="0">																			
																			<tr>
																				<td>
																					<? include("form_cabecalho.php"); ?>																
																				</td>
																			</tr>																				
																			<tr>
																				<td>
																					<table width="100%" cellpadding="0" cellspacing="0" border="0">
																						<tr>
																							<td align="center">
																							<div id="divTela">
																								<div id="divOpcao_P" name="divOpcao_P" style="width: 100%; height:100x; display: none; ">	
																									<br/>	
																									<? include ('mostra_parametros.php'); ?>																			
																								</div>
																								
																								<div id="divOpcao_L" name="divOpcao_L" style="width: 100%; height:330px; display: none;"> 
																								</div>	
																								
																								<div id="divDetalhes_L" name="divDetalhes_L" style="width: 100%; display: none;"> 
																									 <? include ('form_detalhe_log.php'); ?>
																								</div>
																																						
																								<div id="divBotoes" style='display:none; margin-top:20px; margin-bottom :10px' >	
																								<!--  <span></span> -->
																								  <a href="#" class="botao" id="btVoltar"  onClick="voltar(); return false;" >Voltar</a>														  
																								  <a href="#" class="botao" id="btProsseguir" onClick="confirma(); return false;" >Prosseguir</a>
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
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>