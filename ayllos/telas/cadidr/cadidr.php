<?php

	/*******************************************************************
	Fonte: tab096.php                                                		
	Autor: Lucas Reinert                                             		
	Data : Fevereiro/2016                 Última Alteração: --/--/----   		
	                                                                 		
	Objetivo  : Mostrar tela CADIDR
	                                                                    
	Alterações: 															
	*******************************************************************/
	
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
										<table width="100%"  border= "0" cellpadding="3" cellspacing="0">
											<tr>
												<td style="border: 1px solid #F4F3F0;">
													<table width="100%"  border= "0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
														<tr>
															<td align="center">
																<table width="600" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																	<tr>
																		<td>																			
																			<fieldset>
																				<legend>Indicadores</legend>
																				<div id="divTela">																																												
																					<div id="divTabela">
																						<div id="divConsulta">
																							
																						</div>
																						<?php /*include('obtem_consulta.php');*/ ?>
																					</div>
																					
																					<?php include('form_cadidr.php'); ?>
																					
																					<div id="divBotoes"  style="margin-top:5px; margin-bottom :10px; text-align: center;" >
																						<span></span>
																						<a href="#" class="botao" id="btAlterar" onClick="verificaAcesso('A');" style="text-align: right;">Alterar</a>
																						<a href="#" class="botao" id="btIncluir" onClick="verificaAcesso('I');" style="text-align: right;">Incluir</a>
																						<a href="#" class="botao" id="btExcluir" onClick="selecionaIndicador('E');" style="text-align: right;">Excluir</a>
																						<a href="#" class="botao" id="btVoltar"  onClick="trocaVisao('');" style="display: none; text-align: right;">Voltar</a>
																						<a href="#" class="botao" id="btProsseguir" style="display: none; text-align: right;">Prosseguir</a>
																					</div>																				
																					
																				</div>
																			</fieldset>
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
