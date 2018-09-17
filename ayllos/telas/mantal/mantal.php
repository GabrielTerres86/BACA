<? 
/*!
 * FONTE        : mantal.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 21/06/2011
 * OBJETIVO     : Mostrar tela MANTAL
 * --------------
 * ALTERAÇÕES   : 04/11/2017 - Ajuste para tela ser chamada atraves da tela CONTAS > IMPEDIMENTOS
                               (Jonata - RKAM P364).

				  14/11/2017 - Ajsute para receber valores vindos da tela de impedimentos (Jonata - RKAM P364).
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
		<script type="text/javascript" src="../../scripts/menu.js?keyrand=<?php echo mt_rand(); ?>"></script>
		<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
		<script type="text/javascript" src="mantal.js?keyrand=<?php echo mt_rand(); ?>"></script>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('MANTAL - Manutenção dos Talonários') ?></td>
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
															<table width="575" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																<tr>
																	<td>
																		<!-- INCLUDE DA TELA DE PESQUISA -->
																		<? require_once("../../includes/pesquisa/pesquisa.php"); ?>
																		
																		<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																		<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>
																		
																		<div id="divRotina"></div>
																		<div id="divUsoGenerico"></div>
																		
																		<div id="divTela">
																			<? include('form_cabecalho.php'); ?>
																			<div id="divFiltro">
																			<? include('form_mantal.php'); ?>
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
<script type="text/javascript">
	var nrdconta           	   = '<? echo $_POST['nrdconta']; ?>';           // Conta que vai vir caso esteja sendo incluida uma nova conta
	var flgcadas           	   = '<? echo $_POST['flgcadas']; ?>';           // Verificar se esta sendo feito o cadastro da nova conta 
	var dtmvtolt		   	   = '<? echo $glbvars['dtmvtolt']; ?>';         // Data do sistema
	var executandoImpedimentos = '<? echo $_POST['executandoImpedimentos']; ?>'; // Se esta sendo rodada a rotina de Impedimentos
	var produtosCancM = new Array();	                 				 // Rotinas adicionais a serem chamadas via CONTAS/IMPEDIMENTOS
	var produtosCancMAtenda = new Array();	                 			 // Rotinas adicionais a serem chamadas via CONTAS/IMPEDIMENTOS
	var produtosCancMContas = new Array();	                 			 // Rotinas adicionais a serem chamadas via CONTAS/IMPEDIMENTOS
	var produtosCancMCheque = new Array();	                 			 // Rotinas adicionais a serem chamadas via CONTAS/IMPEDIMENTOS

	if (executandoImpedimentos){
		var produtos =  "<? echo $_POST['produtosCancM']; ?>";
		var produtosAtenda = "<? echo $_POST['produtosCancMAtenda']; ?>";
		var produtosContas = "<? echo $_POST['produtosCancMContas']; ?>";
		var produtosCheque = "<? echo $_POST['produtosCancMCheque']; ?>";
		var posicao = '<? echo $_POST['posicao']; ?>';
		produtosCancM = produtos.split("|");		
		produtosCancMAtenda = produtosAtenda.split("|");
		produtosCancMContas = produtosContas.split("|");
		produtosCancMCheque = produtosCheque.split("|");
		if (posicao == 1){
			posicao++;
		}
	}	
	
	
</script>