<?php
/*!
 * FONTE        : pardbt.php 
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIAÇÃO : Março/2018
 * OBJETIVO     : Mostrar tela PARDBT (Parametrização do Debitador Único).
 * --------------
 * ALTERAÇÕES   : 
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
   <link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
   <script type="text/javascript" src="../../scripts/scripts.js"></script>
   <script type="text/javascript" src="../../scripts/dimensions.js"></script>
   <script type="text/javascript" src="../../scripts/funcoes.js"></script>
   <script type="text/javascript" src="../../scripts/mascara.js"></script>
   <script type="text/javascript" src="../../scripts/menu.js"></script>	
   <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
   <script type="text/javascript" src="pardbt.js"></script>	
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">PARDBT - Parametrização do Debitador Único</td>
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
																<table width="1028" border="0" cellpadding="0" cellspacing="0" style="backgroung-color: #F4F3F0;">
																	<tr>
																		<td>
																			<!-- INCLUDE DA TELA DE PESQUISA -->
																			<?php require_once("../../includes/pesquisa/pesquisa.php"); ?>																    
																			
																			<div id="divTela">
																				
																				<?php include('form_cabecalho.php'); ?>
																				
																				<table id="divAbas" cellpadding="0" cellspacing="0" border="0" width="100%" style="margin: 25px 0px; display: block;">
																					<tr>
																						<td align="center">		
																							<table cellpadding="0" cellspacing="0" border="0" width="1028">       
																								<tr>
																									<td class="tdConteudoTela" align="center" style="background-color: transparent;">
																										<table width="100%"  border="0" cellspacing="0" cellpadding="0">
																											<tr>
																												<td>
																													<table border="0" cellspacing="0" cellpadding="0">
																														<tr>
																															<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
																															<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba(0);return false;">Prioridades</a></td>
																															<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
																															<td width="1"></td>

																															<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq1"></td>
																															<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen1"><a href="#" id="linkAba1" class="txtNormalBold" onClick="acessaOpcaoAba(1);return false;">Horários</a></td>
																															<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir1"></td>
																															<td width="1"></td>

																															<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq2"></td>
																															<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen2"><a href="#" id="linkAba2" class="txtNormalBold" onClick="acessaOpcaoAba(2);return false;">Execução Emergencial</a></td>
																															<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir2"></td>
																															<td width="1"></td>

																															<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq3"></td>
																															<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen3"><a href="#" id="linkAba3" class="txtNormalBold" onClick="acessaOpcaoAba(3);return false;">Histórico</a></td>
																															<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir3"></td>
																															<td width="1"></td>
																														</tr>
																													</table>
																												</td>
																											</tr>
																											<tr>
																												<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
																													<div id="divConteudoOpcao" style="height: 400px; padding-top: 15px;">
																														&nbsp;
																													</div>
																													<div id="divBotoes" style="margin-top:5px; margin-bottom :10px;display:none">
																														<a href="#" class="botao" id="btVoltar"  onclick="btnVoltar(); return false;">Voltar</a>
																														<a href="#" class="botao" id="btSalvar"  onClick="btnContinuar(); return false;">Salvar</a>
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
																				
																				
																				
																			</div>

																			<div id="divRotina"></div>
																			<div id="divUsoGenerico"></div>
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
