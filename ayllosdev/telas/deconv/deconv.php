<?php

/************************************************************************
	Fonte: deconv.php
	Autor: Gabriel
	Data : Junho/2011						 Ultima Alteracao: 20/11/2012
	
	Objetivo: Mostrar a tela DECONV.
	
	Alteracoes: 20/11/2012 - Alterado css para novo padrao, alterado 
				width form, alterado botões do tipo campo <input> por
				campo <a>, mudanças layout da tela. Removido chamada para
				funcao formataMsgAjuda('') (Daniel)

************************************************************************/

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
	<script type="text/javascript" src="../../scripts/scripts.js" charset="utf-8"></script>
	<script type="text/javascript" src="../../scripts/dimensions.js"></script>
	<script type="text/javascript" src="../../scripts/funcoes.js"></script>
	<script type="text/javascript" src="../../scripts/mascara.js"></script>
	<script type="text/javascript" src="../../scripts/menu.js"></script>
	<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
	<script type="text/javascript" src="deconv.js"></script>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('DECONV - Autoriza&ccedil;&atilde;o Convenios') ?></td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
											<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td id="tdConteudoTela" class="tdConteudoTela" align="center" style="display:none">	
									<table width="100%"  border= "0" cellpadding="3" cellspacing="0">
											<tr>
												<td> 
													<table width="100%"  border= "0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
														<tr>
															<td align="center">
																<table width="520" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																	<tr>
																		<td>
																		    <!-- INCLUDE DA TELA DE PESQUISA -->
																		    <? require_once("../../includes/pesquisa/pesquisa.php"); ?>
	
 																		    <!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
     								           	 	      		       		<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?> 
																		
																			<form action="<?php echo $UrlSite; ?>telas/deconv/impressao_declaracao.php" method="post" id="frmDeconv" name="frmDeconv" class="formulario">
																			
																			<input type="hidden" id="conta" name="conta" value="">  
																			<input type="hidden" id="idseqttl" name="idseqttl" value="" >
																			<input type="hidden" id="convenio" name="convenio" value="">
																			
																			<table width="520" border="0" cellspacing="0" cellpadding="0">
																																						
																				<tr>
																					<tr>
																						<td colspan="2" height="6"/>
																					</tr>
																					<tr>
																						<td colspan="2" height="1" style="background-color: #666666;"></td>
																					</tr>
																					<tr>
																						<td colspan="1" height="1"/>
																					</tr>					
																					<td>
																						<table width="100%" border="0" cellspacing="0" cellpadding="0" >					
																							<tr>	
																								<td colspan="2">
																								  <label> Op&ccedil;&atilde;o: </label>	
																								  <select id="opcao" name="opcao"class="campo" alt="Informe a op&ccedil;&atilde;o desejada (R)." style="width: 440px;" >
																									  <option value="R" > R - Imprimir declaracao/autorizacao para convenios.</option>
																								  </select>
																								  <a href="#" class="botao" id="btnOK" name="btnOK" onClick="libera_campo();return false;">OK</a> 
																								</td>
																						
																							</tr>
																							<tr>	
																								<td>
																									<label> Cod.Convenio: </label>
																									<input id="cdconven" name="cdconven" type="text"class="campo" maxlength="4" size="4" style="width: 70px; text-align: right;" alt="Informe o n&uacute;mero do convenio ou pressione F7 para listar." >
																									<a style="padding: 3px 0 0 3px;" href="#" id="pesquisaConven" onClick="mostraPesquisaConven();return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" ></a>
																								</td>
															
																								<td>
																									<label> &nbsp; Conta/dv:</label>
																									<input id="nrdconta" name="nrdconta" type="text" class="campo" style="width: 80px; text-align: right;" alt="Informe o n&uacute;mero da conta do cooperado ou F7 para listar." maxlength="10">
																									<a style="padding: 3px 0 0 3px;" href="#" id="pesquisaAssoc" onClick="mostraPesquisaAssoc();return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" ></a>
																								</td>
																							</tr>
																													
																						</table>
																					</td>																				
																					<tr>
																						<td colspan="2" height="6"/>
																					</tr>
																					<tr>
																						<td colspan="2" height="1" style="background-color: #666666;"></td>
																					</tr>
																					<tr>
																					    <td colspan="2" height="6"/>
																					</tr>																					
																				</tr>
																				<tr>	
																					
																			
																					<table height="100%" border="0" cellpadding="0" cellspacing="1" class="tituloRegistros">														 						 																				
																						<tr style="background-color: #F4D0C9; text-align:center">
																							<td width="83" class="txtNormalBold"> Titular       </td>
																							<td width="80" class="txtNormalBold"> Conta/dv  </td>
																							<td width="364" class="txtNormalBold"> Nome  </td>																																										
																				    	</tr>										      																										
																					</table>
																				
																					<table width="100%" border="0" cellspacing="0" cellpadding="0">										
																						<tr >	
																							<div id="divTitulares"style="overflow-y: scroll; height:100px;" >
																							</div>																						
																						</tr>
																					</table>
																					<tr>
																						<td colspan="2" height="6"/>
																					</tr>
																					<tr>
																						<td colspan="2" height="1" style="background-color: #666666;"></td>
																					</tr>
																					 <tr> 
																					    <td height="20px">
																						<div id="divTela">
																							 <div id="divBotoes"  style='display:none; align:center; margin-top:15px; margin-bottom :15px;'>	
																								<a href="#" class="botao" id="btVoltar" onClick="btVoltar(); return false;">Voltar</a> 
																								<a href="#" class="botao" id="btImprimir" onClick="geraDeclaracao(); return false;">Imprimir</a>
																								<a href="#" class="botao" id="btContinuar" onClick="valida_traz_titulares(); return false;" alt ="Selecione o titular e clique em Imprimir ou em Voltar para retornar.">Continuar</a>
																							 </div>
																						 </div>
																						</td>
																						<tr height="10px"> 
																						<td height="10px">
																						</td>
																						</tr>
																					</tr>																 
																				</tr>								
																			</table>
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