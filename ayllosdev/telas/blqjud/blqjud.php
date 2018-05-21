<? 
/*!
 * FONTE        : BLQJUD.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 23/04/2013
 * OBJETIVO     : Mostrar tela BLQJUD
 * --------------
 * ALTERAÇÕES   : 29/09/2017 - Melhoria 460 - (Andrey Formigari - Mouts)
				
				  14/03/2018 - Adicionado parametro que faltava na chamada da procedure
				     		   consulta-bloqueio-jud. (Kelvin)
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
	
    $nometela = str_replace(".php", "", basename($_SERVER['PHP_SELF']));
?>

<script>
	var dtmvtolt = '<? echo $glbvars['dtmvtolt']?>';
	var cdcooper = '<? echo $glbvars['cdcooper']?>';
</script>

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
		<script type="text/javascript" src="<? echo $nometela ; ?>.js?keyrand=<?php echo mt_rand(); ?>"></script>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('BLQJUD - Bloqueio Judicial de Cooperados do Sistema Financeiro') ?></td>
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
															<table width="560" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																<tr>
																	<td>
																		<!-- INCLUDE DA TELA DE PESQUISA -->
																		<? require_once("../../includes/pesquisa/pesquisa.php"); ?>
																		
																		<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																		<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>
																		
																		<div id="divRotina"> </div>
																		<div id="divUsoGenerico"></div>
																		
																		<div id="divTela">
																			<? include('form_cabecalho.php'); ?>
																			<? include('form_impressao.php'); ?>
                                                                            <? include('form_operacao.php'); ?>
																			<? include('form_consulta.php'); ?>	
																			<div id="div_tabblqjud"></div>
                                                                            <? include('form_acaojud.php'); ?>																			
																			<? include('form_desbloqueio.php'); ?>
																			<? include('form_pesquisa_ass.php'); ?>
																																																												
																			<div id="divBotoes" style='text-align:center; margin-bottom: 10px; display:none;' >
																				<input type="hidden" id="cdsitbot" name="cdsitbot" value="0">
                                                                                <a href="#" class="botao" id="btVoltar"       name="btnVoltar"      onClick="btnVoltar();return false;"            style="float:none;">Voltar</a>
                                                                                <a href="#" class="botao" id="btnContinuar"   name="btnContinuar"   onClick="btnContinuar(); return false;"        style="float:none;">Continuar</a>
                                                                                <a href="#" class="botao" id="btnSalvar"      name="btnSalvar"      onClick="showConfirmaInc(); return false;"     style="float:none;">Salvar</a>
                                                                                <a href="#" class="botao" id="btnPesquisar"   name="btnPesquisar"   onClick="validaConsulta(); return false;"      style="float:none;">Pesquisar</a>
                                                                                <a href="#" class="botao" id="btnImprimir"    name="btnImprimir"    onClick="geraImpressao(); return false;"       style="float:none;">Imprimir</a>
																				<a href="#" class="botao" id="btnAlterar"     name="btnAlterar"     onClick="showConfirma(); return false;"        style="float:none;">Alterar</a>
																				<a href="#" class="botao" id="btnDesbloqueio" name="btnDesbloqueio" onClick="confirmaDesbloqueio(); return false;" style="float:none;">Desbloquear</a>
																				
																		    </div>
																		</div>
                                                                       
																		<form id="frmImpressao" name="frmImpressao" >
																			<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
																			
																			<input name="nroficon" id="nroficon" type="hidden" value="" />
																			<input name="nrctacon" id="nrctacon" type="hidden" value="" />
																			<input name="operacao" id="operacao" type="hidden" value="" />
																			<input name="cddopcao" id="cddopcao" type="hidden" value="" />
																																						
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