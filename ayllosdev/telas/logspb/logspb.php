<?php 
/*
	Fonte: logspb.php
	Autor: Bruno Luiz Katzjarowski
	Data: 01/11/2018
	Ultima alteração:

	Objetivo: Mostrar tela LOGSPB

	Alterações:
*/
	include("includes/requires.php"); 

	setVarSession("opcoesTela",$opcoesTela);
?>
<script>
	var cdcooper = '<? echo $glbvars['cdcooper']?>';
	var nmcooper = '<? echo strtoupper($glbvars['nmcooper'])?>';
</script>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta http-equiv="Pragma" content="no-cache">
<title><?php echo $TituloSistema; ?></title>
<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
<link href="css/logspb.css?keyrand=<?php echo mt_rand(); ?>" rel="stylesheet" type="text/css">
<script type="text/javascript" src="../../scripts/scripts.js"></script>
<script type="text/javascript" src="../../scripts/dimensions.js"></script>
<script type="text/javascript" src="../../scripts/funcoes.js"></script>
<script type="text/javascript" src="../../scripts/mascara.js"></script>
<script type="text/javascript" src="../../scripts/jquery.mask.min.js"></script>
<script type="text/javascript" src="../../scripts/menu.js"></script>

<!--<script type="text/javascript" src="logspb.js?keyrand=<?php //echo mt_rand(); ?>"></script>-->
<script type="text/javascript" src="js/logspb.js?keyrand=<?php echo mt_rand(); ?>"></script>
<script type="text/javascript" src="js/carrega_tabelas.js?keyrand=<?php echo mt_rand(); ?>"></script>
<script type="text/javascript" src="js/carrega_detalhes_mensagem.js?keyrand=<?php echo mt_rand(); ?>"></script>

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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">LOGSPB - Visualizar log das transa&ccedil;&otilde;es SPB</td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
											<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td id="tdConteudoTela" class="tdConteudoTela" align="center">
									<div id="divTelaInteira">
										<div id='divPrincipalLogSpb' >
											<?php
												//Include do form de cabeçalho para iniciar as pesquisas
												include('includes/telas/cabecalho.php');
											?>
										</div>	<!-- FIM divPrincipalLogSpb -->
										<div id='frmCamposTelaLogSPB'>
											<div class='divTabelaLogSpb'>
												<?php
													//include da tabela de retorno da consulta
													include('includes/telas/tabela_consulta.php');
												?>
											</div>
											<div class='divBotoesDetalhes'>
												<?php
													//include da tabela de retorno da consulta
													include('includes/telas/botoes_detalhes.php');
												?>
											</div>

											<!-- ROTINA -->
											<div id="divRotina">
												<?php
													//include da tela de modal
													include('includes/telas/modal.php');
												?>
											</div>
										</div>
									</div>
								</td>
							</tr>
						</table> <!-- FIM table tela principal -->
					</td> <!-- Fim tdTela -->
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>

