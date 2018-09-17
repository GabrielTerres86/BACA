<?php 
/*!
 * FONTE        : logdda.php
 * CRIAÇÃO      : David (Cecred)
 * DATA CRIAÇÃO : Março/2011
 * OBJETIVO     : Mostrar Tela LOGDDA
 * --------------
 * ALTERAÇÕES   :
 * 001: [02/03/2011] David (CECRED) : Desenvolver a tela LOGDDA
 * 002: [30/11/2012] Daniel(CECRED) : Alterado layout da tela, alterado estilo css (Daniel).
 * -------------- 
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
	<script type="text/javascript" src="logdda.js"></script>	
	<style type="text/css">
		#divLogdda {height:320px;};
		#frmCabLogdda {padding:3px 0px 2px 0px;margin-bottom:4px;border-top:1px solid #777;border-bottom:1px solid #777;}
		#divDetalheErroDDA {height:150px;width:100%;overflow:hidden;}
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?php echo utf8ToHtml('LOGDDA - Visualizar log de erros no serviço DDA'); ?></td>
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
																		<div id="divLogdda">
																			<form id="frmCabLogdda" name="frmCabLogdda" class="formulario cabecalho" style="display:none">		
																				<label for="cddopcao"><?php echo utf8ToHtml('Opção:') ?></label>
																				<select id="cddopcao" name="cddopcao" alt="Informe a opcao desejada (C).">
																					<option value="C">C - Consultar log de erros no servico DDA</option> 																					
																				</select>																				
																				<label for="dtmvtlog"><?php echo utf8ToHtml('Data da Transação:'); ?></label>
																				<input type="text" id="dtmvtlog" name="dtmvtlog" value="<?php echo $glbvars['dtmvtolt']; ?>" alt="Informe a data da transação do erro." style="text-align:right"/>																				
																				<a href="#" class="botao" id="bntOK" onclick="consultaLog();return false;">OK</a>
																				<br style="clear:both" />	
																			</form>
																			<fieldset id='tabConteudo'>
																				<legend>Registros</legend>																					
																				<div class="divRegistros"></div>
																				<div id="divBotoes">
																					<a href="#" class="botao" id="btVoltar">Voltar</a> 
																					<a href="#" class="botao" id="btConsultar" onClick="mostraDetalhamento();">Consultar</a>																				
																				</div>
																			</fieldset>
																			<fieldset id='tabDetalheErroDDA'>
																				<legend>Detalhamento</legend>																					
																				<div class="divDetalheErroDDA">
																					<form name="frmDadosDetalheErroDDA" id="frmDadosDetalheErroDDA" class="formulario">	
																						<label for="dttransa"><?php echo utf8ToHtml('Data da Transação:'); ?></label>
																						<input name="dttransa" id="dttransa" type="text" value="" />
																						<br />																						
																						<label for="hrtransa"><?php echo utf8ToHtml('Hora da Transação:'); ?></label>
																						<input name="hrtransa" id="hrtransa" type="text" value="" />
																						<br />
																						<label for="nrdconta">Conta/dv:</label>
																						<input name="nrdconta" id="nrdconta" type="text" value="" />
																						<br />
																						<label for="nmprimtl">Nome:</label>
																						<input name="nmprimtl" id="nmprimtl" type="text" value="" />
																						<br />
																						<label for="dscpfcgc">CPF/CNPJ:</label>
																						<input name="dscpfcgc" id="dscpfcgc" type="text" value="" />
																						<br />
																						<label for="nmmetodo"><?php echo utf8ToHtml('Método:'); ?></label>
																						<input name="nmmetodo" id="nmmetodo" type="text" value="" />
																						<br />
																						<label for="cdderror"><?php echo utf8ToHtml('Código do Erro:'); ?></label>
																						<input name="cdderror" id="cdderror" type="text" value="" />
																						<br />
																						<label for="dsderror"><?php echo utf8ToHtml('Descrição do Erro:'); ?></label>																						
																						<textarea name="dsderror" id="dsderror"></textarea>
																						<br />																						
																					</form>
																				</div>
																				<div id="divBotoesDetalhe">
																					<a href="#" class="botao" id="btVoltar" onClick="controlaLayout('C',false);">Voltar</a>																				
																				</div>
																			</fieldset>	
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