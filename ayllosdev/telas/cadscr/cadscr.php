<?
/*!
 * FONTE        : cadscr.php					Último ajuste: 08/12/2015
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 09/10/2015
 * OBJETIVO     : Mostrar tela CADSCR
 * --------------
 * ALTERAÇÕES   : 08/12/2015 - Ajustes de homologação referente a conversão efetuada pela DB1
							  (Adriano).
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
													<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('CADSCR - Informações para o 3026') ?></td>
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
																	<table width="610" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																		<tr>
																			<td>
																				<div id="divRotina"></div>
																																						
																				<div id="divTela">
																				
																					<? include('form_cabecalho.php'); ?>
																					<? include('form_consulta.php'); ?>					
																					<? include('form_senha.php'); ?>
																					
																					<div id="divTabela">
																																																											
																					</div>
																					
																					<div id="divBotoes" style='text-align:center; margin-bottom: 10px; display:none;'>
																					
																						<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
																						<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">Prosseguir</a>
																						<a href="#" class="botao" id="btConcluir" onclick="showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','btnContinuar();','$(\'#dtsolici\',\'#frmConsulta\').focus();','sim.gif','nao.gif');">Concluir</a>
																						<a href="#" class="botao" id="btSalvarSenha" onclick="btnContinuarSenha(); return false;">Prosseguir</a>							
																						<a href="#" class="botao" id="btAlterar"   name="btAlterar" onClick="btnAlterar();return false;"  style="float:none;">Alterar</a>
																						<a href="#" class="botao" id="btAlterarHist" name="btAlterarHist" onClick="btnAlterarHist();return false;" style="float:none;">Alterar</a>
																						<a href="#" class="botao" id="btIncluir" name="btIncluir" onClick="btnIncluir();return false;"  style="float:none;">Incluir</a>
																						<a href="#" class="botao" id="btIncluirHist" name="btIncluirHist" onClick="btnIncluirHist();return false;"  style="float:none;">Incluir</a>																				
																						<a href="#" class="botao" id="btExcluir"   name="btExcluir" onClick="btnExcluir();return false;"  style="float:none;">Excluir</a>
																						<a href="#" class="botao" id="btExcluirHist" name="btExcluirHist" onClick="btnExcluirHist();return false;"  style="float:none;">Excluir</a>		
																						
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
<script>
	nometela = "<? echo $nometela ?>"
</script>