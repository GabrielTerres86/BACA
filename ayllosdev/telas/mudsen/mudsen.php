<?
/******************************************************************************
ATENCAO! CONVERSAO PROGRESS - ORACLE
ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!

PARA QUALQUER ALTERACAO QUE ENVOLVA PARAMETROS DE COMUNICACAO NESSE FONTE,
A PARTIR DE 10/MAI/2013, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES PESSOAS:
- GUILHERME STRUBE (CECRED)
- MARCOS MARTINI (SUPERO)
- GUILHERME BOETTCHER (SUPERO)
*******************************************************************************/




/***********************************************************************
	Fonte: mudsen.php
	Autor: Gabriel
	Data : Julho/2011						Ultima Alteracao: 29/06/2016
	
	Objetivo: Mostrar a tela MUDSEN.
	
	Alteracoes: 20/11/2012 - Efetuado altera��o layout da tela e alterado css
				para novo padrao, alterado bot�es do tipo tag <input> por
				tag <a>, removido chamada para funcao formata
				mensagem (Daniel).

				29/06/2016 - Retirar validacao de permissao de acesso (Lucas Ranghetti #460374)
***********************************************************************/

session_start();

// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");	
require_once("../../includes/controla_secao.php");
		
// Verifica se tela foi chamada pelo m�todo POST
isPostMethod();
	
// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");	
	
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
		<script type="text/javascript" src="mudsen.js"></script>
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
													<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('MUDSEN - Mudan&ccedil;a de Senha') ?></td>
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
																	<table width="460" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																		<tr>
																			<td>																		
																				<form method="post" id="frmMudsen" name="frmMudsen" class="formulario">																			
																					<table width="100%" border="0" cellspacing="0" cellpadding="0">																													
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
																							<tr> 
																								<table  border="0" cellspacing="0" cellpadding="0">					
																									<tr height="40px">	
																									    <td width="250px"> <label style="width:250px"> C&oacute;digo de Operador: </label> </td>
																										<td> <input id="cdoperad" name="cdoperad" type="text"class="campo" maxlength="10" style="width:80px;" alt="Informe o c&oacute;digo do Operador." > </td>																																																		
																									</tr>
																									<tr height="40px" >
																										<td width="250px"> <label style="width:250px"> Senha atual: </label> </td>
																										<td> <input id="cdsenha1" name="cdsenha1" type="password" class="campo" maxlength="10" style="width:80px;" alt="Informe a senha atual do operador." > 
																									</tr>
																									
																									<tr height="40px">
																										<td width="250px"> <label style="width:250px"> Digite nova senha: </label>  </td>
																										<td> <input id="cdsenha2" name="cdsenha2" type="password" class="campo" maxlength="10" style="width:80px;" alt="Informe a nova senha do operador." > </td> 
																									</tr>
																									
																									<tr height="40px">
																										<td width="250px"> <label style="width:250px"> Confirme nova senha:  </label> </td>
																										<td> <input id="cdsenha3" name="cdsenha3" type="password" class="campo" maxlength="10" style="width:80px;" alt="Confirme a nova senha do operador." >  </td>
																									</tr>
							
																								</table>
																							</tr>																				
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
																							<td colspan="2" height="6"/>
																						</tr>
																						<tr> 
																							<td height="20px">
																								<div id="divTela">
																									<div id="divMsgAjuda" style='margin-top:5px; margin-bottom:10px; padding-left: 200px;'>	
																									 <span> </span>
																									 <a href="#" class="botao" id="btContinuar"  onClick="altera_senha();return false;" align = "center">Continuar</a> 
																									</div>
																								<div id="divTela">
																							</td>
																						</tr>	
																						<tr height="10px"> 
																						<td height="10px">
																						</td>
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
