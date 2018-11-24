<?php

	/*******************************************************************
	Fonte: tab096.php                                                		
	Autor: Lucas Reinert                                             		
	Data : Fevereiro/2016                 �ltima Altera��o: --/--/----   		
	                                                                 		
	Objetivo  : Mostrar tela CADIDR
	                                                                    
	Altera��es: 															
	*******************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');
	
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();
	
	// Carrega permiss�es do operador
	include("../../includes/carrega_permissoes.php");	
			
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
   <script type="text/javascript" src="cadidr.js"></script>
	
	
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">CADIDR - Cadastro Indicadores de Reciprocidade </td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
										 	<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>						  
									      </tr>
									   </table>
     							    </td>								
								</tr>				
								<tr>
									<td id="tdConteudoTela" class="tdConteudoTela" align="center"> 
										<table width="550"  border= "0" cellpadding="3" cellspacing="0">
											<tr>													
												<td>								
													<table border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
														<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="trocaVisao('');acessaOpcaoAba(0);return false;">Indicadores</a></td>
														<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
														<td width="1"></td>

														<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq1"></td>
														<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen1"><a href="#" id="linkAba1" class="txtNormalBold" onClick="trocaVisao('');acessaOpcaoAba(1);return false;">Vincula&ccedil;&otilde;es</a></td>
														<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir1"></td>
														<td width="1"></td>
													</tr>
													</table>																		
												</td>
											</tr>
											<tr>
												<td style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
													<div id="divAba0" class="clsAbas">
														<table width="100%"  border= "0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
															<tr>
																<td align="center">
																	<table width="600" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																		<tr>
																			<td>																			
																				<div id="divTela">																																												
																					<div id="divTabela">
																						<div id="divConsulta"></div>
																						<?php /*include('obtem_consulta.php');*/ ?>
																					</div>
																					
																					<?php include('form_cadidr.php'); ?>
																					
																					<div id="divBotoes"  style="margin-top:5px; margin-bottom :10px; text-align: center;" >
																						<span></span>
																						<a href="#" class="botao" id="btAlterar" onClick="verificaAcesso('A');" style="text-align: right;">Alterar</a>
																						<a href="#" class="botao" id="btIncluir" onClick="verificaAcesso('I');" style="text-align: right;">Incluir</a>
																						<a href="#" class="botao" id="btExcluir" onClick="selecionaLinha('E');" style="text-align: right;">Excluir</a>
																						<a href="#" class="botao" id="btVoltar"  onClick="trocaVisao('');" style="display: none; text-align: right;">Voltar</a>
																						<a href="#" class="botao" id="btProsseguir" style="display: none; text-align: right;">Prosseguir</a>
																					</div>																				
																					
																				</div>
																			</td>
																		</tr>
																	</table>
																	
																</td>		
															</tr>
														</table>
													</div> <!-- Fim aba "Indicadores" -->

													<div id="divAba1" class="clsAbas">
														<table width="100%"  border= "0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
															<tr>
																<td align="center">
																	<table width="600" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																		<tr>
																			<td>																			
																				<div id="divTela">																																												
																					<div id="divTabela">
																						<div id="divConsulta"></div>
																					</div>
																					
																					<?php include('form_vinculacoes.php'); ?>
																					
																					<div id="divBotoes"  style="margin-top:5px; margin-bottom :10px; text-align: center;" >
																						<span></span>
																						<a href="#" class="botao" id="btAlterar" onClick="verificaAcesso('A');" style="text-align: right;">Alterar</a>
																						<a href="#" class="botao" id="btIncluir" onClick="verificaAcesso('I');" style="text-align: right;">Incluir</a>
																						<a href="#" class="botao" id="btExcluir" onClick="selecionaLinha('E');" style="text-align: right;">Excluir</a>
																						<a href="#" class="botao" id="btVoltar"  onClick="trocaVisao('');" style="display: none; text-align: right;">Voltar</a>
																						<a href="#" class="botao" id="btProsseguir" style="display: none; text-align: right;">Prosseguir</a>
																					</div>																				
																					
																				</div>
																			</td>
																		</tr>
																	</table>
																	
																</td>		
															</tr>
														</table>
													</div> <!-- Fim aba "Vinculacoes" -->
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
