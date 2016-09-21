<? 
/*!
 * FONTE        : admcrd.php
 * CRIAÇÃO      : Cristian Filipe Fernandes (Gati Tecnologia).
 * DATA CRIAÇÃO : 12/09/2013
 * OBJETIVO     : Mostrar tela ADMCRD
 * --------------
 * ALTERAÇÕES   : 26/02/2014 - Revisão e Correção (Lucas).
 *                22/07/2014 - Layout padrao (Jonata-Rkam).
 * --------------
 */
?>

<? 
	session_start();

	// Includes para controle da session, vari?veis globais de controle, e biblioteca de fun??es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
		
	// Verifica se tela foi chamada pelo m?todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	// Carrega permiss?es do operador
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
		<script type="text/javascript" src="cbrfra.js"></script>
	</head>
	<body>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><? include('../../includes/topo.php'); ?></td>
	</tr>
	<tr>
		<td id="tdConteudo" valign="top">
			<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
				<tr> 
					<td width="175" valign="top">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td id="tdMenu"><? include("../../includes/menu.php"); ?></td>
							</tr>  
						</table>
					</td>
					<td id="tdTela" valign="top">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td>
									<table width="100%"  border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
											<td class="txtBrancoBold" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('CBRFRA - Controle de C&oacute;digos com Fraude') ?></td>
											<td class="txtBrancoBold" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
											<td class="txtBrancoBold" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<? echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
											<td width="8"><img src="<? echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
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
															<table width="545" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																<tr>
																	<td>
																		<div id="divTela">
																			<? include('form_cabecalho.php') ?>
																			<div>
																			<form id="divFormPrincipal" name="divFormPrincipal" class="formulario cabecalho" onSubmit="return false;">
																				<input type="hidden" name="hdncodbarexc" id="hdncodbarexc" value=""/>
																				<label for="nrdcodigo" style="margin-left:22px;" >Código:</label>
																				<input type="text" class="campo somenteNumeros" id="nrdcodigo" name="nrdcodigo" maxlength="44" value="" alt="Informe o nro. do código." />
																				<br style="clear:both" />																	
																				<label class="clsincluir" for="nmdata" style="margin-left:34px;"  >Data:</label>
																				<input class="campo data clsdata clsincluir" name="nmdata" id="nmdata" type="text" onchange="validaDataInput(this)" value="<? echo date("d/m/Y"); ?>" />
																				<label class="clsconsulta" for="nmdatainicial">Data Inicial:</label>
																				<input class="campo data clsdata clsconsulta" name="nmdatainicial" id="nmdatainicial" type="text" onchange="validaDataInput(this)" value="" />
																				<label class="clsconsulta clspadding" for="nmdatafinal">Data Final:</label>
																				<input class="campo data clsdata clsconsulta" name="nmdatafinal" id="nmdatafinal" type="text" onchange="validaDataInput(this)" value="" />
																				<a href="#" class="botao clsconsulta clsbotao" id="btnBuscar" onclick="realizaOperacao('C', '1' , '30')">Buscar</a>
																				
																				<br style="clear:both" />
																			</form>
																			</div>
																			<div id="divTabela" style="margin-top: 10px;">
																				
																			</div>																															
																			<div id="divBotoes" style="margin-bottom:10px;">
																				<a href="#" class="botao" id="btVoltar" onClick="estadoInicial();">Voltar</a>
																				<a href="#" class="botao clsincluir clsbotao"  id="btnGravar" onclick="confirma('I')">Gravar</a>
																			</div>																			
																		</div>																		
																		
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