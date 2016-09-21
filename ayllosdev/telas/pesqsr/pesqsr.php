<?
/*!
 * FONTE        : pesqsr.php
 * CRIAÇÃO      : Gabriel CApoia (DB1)				Última alteração: 30/06/2016
 * DATA CRIAÇÃO : 16/07/2013
 * OBJETIVO     : Mostrar tela PESQSR
 * --------------
 
Alterações: 02/06/2016 #412556
					   - Não estava mostrando os dados do cheque;
					   - Inclusão dos campos Coop, cód de pesquisa, sequência e vlr cpmf;
					   - Inclusão de máscaras de moeda, inteiro, conta e outras;
					   - nrctabb vazio;
					   - Correção do botão Voltar, que estava deixando as opções quase invisíveis (fade);
					   - Ajuste dos campos, pois estavam com alinhamentos e tamanhos desproporcionais aos seus conteúdos;
					   - Correção da sequência dos focos dos campos ao pressionar enter;
					   - Correção da ordenação das validações;
					   - Campos não estavam sendo limpos quando era trocada a opção da tela;
					   - Comentados os códigos que envolviam a geração de relatório, pois esta opção não existe na tela 
						 atual do ambiente caracter;
					   - Ajustes de css que estavam sendo feitos em js sem necessidade e em alguns casos com redundância.
					   (Carlos) 

		    24/062016 - Ajustes referente a homologação da tela para liberação 
                       (Adriano - SD 412556).

			24/062016 - Ajustes referente a homologação da área de negócio 
                        (Adriano - SD 412556).

*/

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	require_once("../../includes/carrega_permissoes.php");

	$nometela = str_replace(".php", "", basename($_SERVER['PHP_SELF']));

?>

<html>
    <head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<meta http-equiv="Pragma" content="no-cache">
		<title><? echo $TituloSistema; ?></title>
		<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="../../scripts/scripts.js" charset="utf-8"></script>
		<script type="text/javascript" src="../../scripts/dimensions.js"></script>
		<script type="text/javascript" src="../../scripts/funcoes.js?keyrand=<?php echo mt_rand(); ?>"></script>
		<script type="text/javascript" src="../../scripts/mascara.js"></script>
		<script type="text/javascript" src="../../scripts/menu.js"></script>
		<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
		<script type="text/javascript" src="<? echo $nometela ?>.js?keyrand=<?php echo mt_rand(); ?>"></script>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml(strtoupper($nometela).' - PESQUISA SUA REMESSA') ?></td>
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
																		<div id="divTela">
																			<? include('form_cabecalho.php'); ?>

																			<? include('form_filtro.php'); ?>
																			
																			<div id="divTabela"></div>                                                                            
																			<div id="divBotoesConsulta" style='text-align:center; margin-bottom: 10px; margin-top: 10px;'>
                                                                                <a href="#" class="botao" id="btVoltar" onclick="btnVoltar('1'); return false;">Voltar</a>
                                                                                <a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">Prosseguir</a>

																			</div>
																			<div id="divBotoes" style='text-align:center; margin-bottom: 10px; margin-top: 10px;'>
                                                                                <a href="#" class="botao" id="btVoltar" onclick="btnVoltar('2'); return false;">Voltar</a>                                                                                
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