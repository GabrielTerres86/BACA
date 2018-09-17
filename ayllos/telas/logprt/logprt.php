<?php 
/*!
 * FONTE        : logprt.php
 * CRIAÇ&AtildeO      : Lombardi (Cecred)
 * DATA CRIAÇ&AtildeO : Junho/2015
 * OBJETIVO     : Mostrar Tela LOGPRT 
 */ 
?>

<?php	

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

	setVarSession("opcoesTela",$opcoesTela);
	
	$flgConsultar = in_array('C', $glbvars['opcoesTela']);
		
?>

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<meta http-equiv="Pragma" content="no-cache">
	<title><?php echo $TituloSistema; ?></title>
	<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="../../scripts/scripts.js" charset="utf-8"></script>
	<script type="text/javascript" src="../../scripts/dimensions.js"></script>
	<script type="text/javascript" src="../../scripts/funcoes.js"></script>
	<script type="text/javascript" src="../../scripts/mascara.js"></script>
	<script type="text/javascript" src="../../scripts/menu.js"></script>
	<script type="text/javascript" src="logprt.js"></script>	
	<style type="text/css">
		#divLogprt {height:320px;};
		#frmCabLogprt {padding:3px 0px 2px 0px;margin-bottom:4px;border-top:1px solid #777;border-bottom:1px solid #777;}
		#divDetalheErroPRT {height:150px;width:100%;overflow:hidden;}
		#divBotoesDetalhe {border-top:1px solid #777;padding-top:10px;display:block;clear:both;}
	</style>	
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?php echo utf8ToHtml('LOGPRT - Cr&iacute;ticas de portabilidade de cr&eacute;dito'); ?></td>
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
															<table width="630" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																<tr>
																	<td>
																		<div id="divTela">
																		<div id="divLogPRT">
																			<form name="frmImprimir" id="frmImprimir" style="display:none">
																				<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
																				<input name="nmarquiv" id="nmarquiv" type="hidden" value="" />
																			</form>
																			<form id="frmCabLogprt" onSubmit="return false;" name="frmCabLogprt" class="formulario cabecalho" style="display:none">
																				
																				<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>"/>
																				
																				<label for="cdopcao"><?php echo utf8ToHtml('Op&ccedil&atildeo:') ?></label>
																				<select id="cdopcao" name="cdopcao" alt="Informe a opcao desejada (C).">
																					<option value="C" selected>Criticas na liquidação de contrato por portabilidade</option>
																					<option value="D">Criticas na efetivação de contrato por portabilidade</option>
																				</select>
                                        <br style="clear:both" />
																				<label for="dtlogini"><?php echo utf8ToHtml('Data inicial:'); ?></label>
                                        <input type="text" id="dtlogini" name="dtlogini" value="<?php echo $glbvars['dtmvtolt']; ?>" alt="Informe a data da transação do erro." style="text-align:right"/>
                                        
																				<label for="dtlogfin"><?php echo utf8ToHtml('Data final:'); ?></label>
																				<input type="text" id="dtlogfin" name="dtlogfin" value="<?php echo $glbvars['dtmvtolt']; ?>" alt="Informe a data da transação do erro." style="text-align:right"/>
                                        
																				<a href="#" class="botao" id="bntOK" onClick="geraRelatorio();">OK</a>
																				<br style="clear:both" />
																			</form>
																		</div>
																		</div>
																		<script type="text/javascript">
																			formataCabecalho();
																			controlaLayout('');	
																			flgConsultar = '<?php echo $flgConsultar; ?>';
																		</script>
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