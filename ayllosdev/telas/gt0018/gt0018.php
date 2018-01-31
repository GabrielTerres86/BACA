<? 
/*!
 * FONTE        : gt0018.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 12/12/2017
 * OBJETIVO     : Mostrar tela GT0018
 * --------------
 * ALTERAÇÕES   : 
 *
 *				  
 * --------------
 */
?>

<? 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	require_once("../../includes/carrega_permissoes.php");
	
?>

<script>
	var dtmvtolt = '<? echo $glbvars['dtmvtolt']?>';    
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">
    <head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">	
		<meta http-equiv="Pragma" content="no-cache">
		<meta http-equiv="X-UA-Compatible" content="IE=100" >
        <title><? echo $TituloSistema; ?></title>
	        
		<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
		<link href="../../css/tooltip.css" rel="stylesheet" type="text/css">        
    	<link rel="stylesheet" href="../../css/base/jquery.ui.all.css">
        
		<script type="text/javascript" src="../../scripts/scripts.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>" charset="utf-8"></script>
		<script type="text/javascript" src="../../scripts/dimensions.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="../../scripts/funcoes.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="../../scripts/mascara.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="../../scripts/menu.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
        
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.core.js"></script>
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.datepicker.js"></script>
        <script type="text/javascript" src="../../scripts/ui/i18n/jquery.ui.datepicker-pt-BR.js"></script>
		<script type="text/javascript" src="../../scripts/tooltip.js"></script>
                
        <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
		<script type="text/javascript" src="gt0018.js?sidlogin=<?php echo $glbvars["sidlogin"]; ?>"></script>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('GT0018– Manter Convenios') ?></td>
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
															<table width="700" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																<tr>
																	<td>
																		<!-- INCLUDE DA TELA DE PESQUISA -->
																		<? require_once("../../includes/pesquisa/pesquisa.php"); ?>
																		
																		<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																		<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>
																		
																		<!-- INCLUDE COM AS ANOTACOES -->
																		<? include('anotacoes.php') ?>
																		
																		<div id="divRotina"></div>
																		<div id="divUsoGenerico"></div>
																		<div id="divListaAnotacoes"></div>
																		
																		<div id="divTela">
																			<? include('form_cabecalho.php'); ?>                                                                                
                                                                            <? include('form_campos.php'); ?>                                                                            
                         
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