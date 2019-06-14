<?php

	/*************************************************************************
	 Fonte: improp.php                                                
	 Autor: Gabriel                                                   
	 Data : Outubro/2010                 Última Alteração: 	23/07/2013	   
	                                                                  
	 Objetivo  : Mostrar tela IMPROP.                                
	                                                                   
	 Alterações: 27/02/2013 - Migrar para o layout padrao (Gabriel)
		
			     23/07/2013 - Paginar a tela de 10 em 10 registros (Gabriel)
				 
				 05/09/2013 - Alteração da sigla PAC para PA (Carlos)
	                                                                  
	*************************************************************************/
	
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
   <title><?php echo $TituloSistema; ?></title>
   <link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
   <link href="improp.css" rel="stylesheet" type="text/css">
   <script type="text/javascript" src="../../scripts/scripts.js"></script>
   <script type="text/javascript" src="../../scripts/dimensions.js"></script>
   <script type="text/javascript" src="../../scripts/funcoes.js"></script>
   <script type="text/javascript" src="../../scripts/mascara.js"></script>
   <script type="text/javascript" src="../../scripts/menu.js"></script>	
   <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
   <script type="text/javascript" src="improp.js"></script>
	
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">IMPROP - Consulta/Impress&atilde;o de propostas </td>
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
											   <td  style="border: 1px solid #F4F3F0;">
											      <table width ="100%"  border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;" >
														<tr>
															<td align="center">																									 
															<table width="560" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;" >
															     <tr> 
															  	      <td>		
															              <!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
     								           	 	      		          <? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?> 	
																						
															              <form action="<?php echo $UrlSite; ?>telas/improp/impressao_contratos.php" name="frmImprop" class="formulario" id="frmImprop" method="post">
																	      <input type="hidden" name="nomedarq" id="nomedarq" value="">
																				
																			<table width = "100%">	
																				<tr>
																				  <td>
																					<label for="cddopcao" > Op&ccedil;&atilde;o:</label>   
										
																					<select name="cddopcao" id="cddopcao" class="campo" >
																					
																						<option value="I" selected> I - Imprimir propostas </option>
																						<option value="C"> C - Consultar propostas </option>
																						<option value="E"> E - Excluir propostas </option>
																				
																					</select>
																				  </td>
																				</tr>
																				<tr>
																					<td>
																						<label for="nrdconta"> Conta:</label>
																						<input name="nrdconta" type="text" id="nrdconta"/>
																					  
																						<a href="#" id="pesquisaAssoc" name="esquisaAssoc" onClick="mostraPesquisaAssociado('nrdconta','frmImprop','');return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" ></a>
																					
																						<label for="cdagenci"> PA:</label>
																						<input name="cdagenci" type="text" class="campo" id="cdagenci" >
																						
																						<label for="dtiniper"> Data:  </label>
																						<input name="dtiniper" type="text" class="campo" id="dtiniper" />
																																						  
																						<label for="dtfimper"> a </label>
																						<input name="dtfimper" type="text" class="campo" id="dtfimper" />
																					</td>			
																				</tr>
																				<tr>
																				<td>
																				<label for="tprelato0" > Tipo: </label>
																					
																				<input name="tprelato01" id="tprelato01" type="checkbox" class="checkbox" value="1"> 
																			    <label for="tprelato01"> Empr&eacute;stimo </label> 
																				
																				<input name="tprelato02" id="tprelato02" type="checkbox" class="checkbox" value="2">
																				<label for="tprelato02"> Lim. Cr&eacute;dito </label>

																				<input name="tprelato03" id="tprelato03" type="checkbox" class="checkbox" value="3">
																				<label for="tprelato03"> Descto. Cheque </label>	
																				
																				<input name="tprelato04" id="tprelato04" type="checkbox" class="checkbox" value="4">
																				<label for="tprelato04"> Descto. T&iacute;tulo </label>
																				
																				<input name="tprelato05" id="tprelato05" type="checkbox" class="checkbox" value="5">
																				<label for="tprelato05"> Todas </label>
																				</td>
																				</tr>
																			</table>			
																		  </form>
																		  
																		  <div id= "divTela">
																		  
																				<!-- Este Div sera mostrado no mostra_contratos.php -->
																		        <div id="divContratos">	
             																				
																				</div>		
																																	
																			<div id="divBotoes" style="margin-bottom: 15px;">
																			  
																			  <a href="#" class="botao" id="btVoltar"     onClick="voltar(); 					return false;">Voltar</a>	
																			  <a href="#" class="botao" id="btProsseguir" onClick="ValidaDadosContratos(); 	    return false;">Prosseguir</a>	
																			  <a href="#" class="botao" id="btImprimir"   onClick="confirmaImprimirContratos(); return false;">Imprimir</a>	
																			  <a href="#" class="botao" id="btExcluir"    onClick="confirmaExcluirContratos(); 	return false;">Excluir</a>	
																			  
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

<script type='text/javascript'>

// Desabilitar checkBox (todas as propostas)
$("#flgtodas","#frmImprop").prop("disabled",true);
	
</script>