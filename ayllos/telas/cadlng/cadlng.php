<?php

	/*************************************************************************
	 Fonte: CADLNG.php                                                
	 Autor: Adriano                                                   
	 Data : Outubro/2011              Última Alteração: 		       
	                                                                  
	 Objetivo  : Mostrar tela CADLNG.                                 
	                                                                  
	 Alterações: 30/11/2016 - P341-Automatização BACENJUD - Alterado para passar como parametro o  
                              código do departamento ao invés da descrição (Renato Darosci - Supero)										   			   
	                                                                  
	************************************************************************/
	
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
	
    // VAlidação $glbvars["dsdepart"] != "CONTROLADORIA", foi retirada por não existir cadastro CONTROLADORIA
	if ($glbvars["cddepart"] != 20){ 
		
		if ($glbvars["redirect"] == "html") {
				redirecionaErro($glbvars["redirect"],$UrlSite."principal.php","_self",$msgError);
			} elseif ($glbvars["redirect"] == "script_ajax") {
				echo 'hideMsgAguardo();';
				echo 'showError("error","'.addslashes($msgError).'","Alerta - Permiss&otilde;es","");';
			} elseif ($glbvars["redirect"] == "html_ajax") {
				echo '<script type="text/javascript">hideMsgAguardo();showError("error","'.addslashes($msgError).'","Alerta - Permiss&otilde;es","");</script>';
			}
		
		exit();

	}
?>

<html> 
  <head> 
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <meta http-equiv="Pragma" content="no-cache">
   <title><?php echo $TituloSistema; ?></title>
   <link href="../../css/estilo.css" rel="stylesheet" type="text/css">
   <script type="text/javascript" src="../../scripts/scripts.js"></script>
   <script type="text/javascript" src="../../scripts/dimensions.js"></script>
   <script type="text/javascript" src="../../scripts/funcoes.js"></script>
   <script type="text/javascript" src="../../scripts/mascara.js"></script>
   <script type="text/javascript" src="../../scripts/menu.js"></script>	
   <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
   <script type="text/javascript" src="cadlng.js"></script>	
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">CADLNG - Cadastro Lista Negra </td>
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
																<table width="545" border="0" cellpadding="0" cellspacing="0" style="backgroung-color: #F4F3F0;">
																	<tr>
																		<td>
																			<div id="divTela">
																				
																				<!-- INCLUDE DA TELA DE PESQUISA -->
																				<? require_once("../../includes/pesquisa/pesquisa.php"); ?>
																				
																				<? include('form_cabecalho.php'); ?>
																													
																				<div id="divIncluir">									
																					<? include('form_incluir_cadlng.php');	?>
																				</div>
																				
																				<div id="divConsulta">
																					<? include('form_consulta_cadlng.php');	?> 
																				</div>
																				
																				<div id="divDetalhes">
																					<? include('form_detalhes.php'); ?>
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
