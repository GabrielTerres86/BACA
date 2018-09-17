<? 
/*!
 * FONTE        : conaut.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM).
 * DATA CRIAÇÃO : 16/07/2014
 * OBJETIVO     : Mostrar tela CONAUT
 * --------------
 * ALTERAÇÕES   : 30/11/2016 - P341-Automatização BACENJUD - Alterado para validar o departamento  
 *                             pelo código ao invés da descrição (Renato Darosci - Supero)
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
	
	// Se o codigo do departamento não for PRODUTOS ou TI
	if ($glbvars["cddepart"] != 14  && $glbvars["cddepart"] != 20 ) {
		redirecionaErro($glbvars["redirect"],$UrlSite."principal.php","_self",'036 - Operacao nao autorizada.');
	}
	
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
		<!--script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script-->
		<script type="text/javascript" src="conaut.js"></script>
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
											<td class="txtBrancoBold" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('CONAUT - Consultas Automatizadas') ?></td>
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
																			<? include('form_opcao_b.php'); ?>	
																			<? include('form_opcao_m.php'); ?>	
																			<? include('form_opcao_p.php'); ?>	
																			<? include('form_opcao_t.php'); ?>	
																			<? include('form_opcao_r.php'); ?>	
																			<? include('form_opcao_c.php'); ?>		
																		    <div id="divTabela" style="margin-top: 10px;">
																				
																			</div>	
																			<div id="divBotoes" style="margin-bottom:10px;">
																				<a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="estadoInicial();">Voltar</a>
																				<a href="#" class="botao" id="btSalvar" name="btVoltar" onClick="realizaOperacao();">Salvar </a>
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