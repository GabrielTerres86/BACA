<?php 
	/*********************************************************************
	 Fonte: gravam.php                                                 
	 Autor: Andrei - RKAM                                                     
	 Data : Maio/2016                Última Alteração: 14/07/2016
	                                                                  
	 Objetivo  : Mostrar tela GRAVAM.                                 
	                                                                  
	 Alterações: 14/07/2016 - Ajuste para corrigir o nome da tela (Andrei - RKAM).
	 
	**********************************************************************/
	
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
		<script type="text/javascript" src="gravam.js?keyrand=<?php echo mt_rand(); ?>"></script>

		<script type="text/javascript"">
			
			var cdcooper = "<? echo $glbvars['cdcooper']; ?>";

		</script>

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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">GRAVAM - Gravames</td>
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
															<table id="tblTela" width="650" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																<tr>
																	<td>
																		<!-- INCLUDE DA TELA DE PESQUISA -->
																		<? require_once("../../includes/pesquisa/pesquisa.php"); ?>
																		
																		<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																		<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>

																		<div id="divTela">

																			<!-- Cabeçalho da Página -->
																			<? include("form_cabecalho.php"); ?>

																			<div id="divFiltro"></div>

																			<form id="frmCons" name="frmCons" class="formulario" onSubmit="return false;" style="display:block">
																					<div id="divDados" style="margin-top: 20px;"></div>    
																			</form>
																			
																			<div id="divTabela"></div>
																			<div id="divRotina"></div>
																			<div id="divUsoGenerico"></div>
																			<div id="divBotoes" style="display:none;padding-bottom: 15px;">
																			
																				<a href="#" class="botao" id="btVoltar">Voltar</a>																																							
																				<a href="#" class="botao" id="btProsseguir" >Prosseguir</a>
																				<!--
																				<a href="#" class="botao" id="btConsultar" >Consultar</a>																																						
																				<a href="#" class="botao" id="btAlterar" >Alterar</a>																																								
																				<a href="#" class="botao" id="btBaixar" >Baixar</a>
																				-->
																				<a href="#" class="botao" id="btRetArq" >Retornar arquivo</a>
																				<a href="#" class="botao" id="btGerArq" >Gerar arquivo</a>																																						
																				<a href="#" class="botao" id="btInclManuGravame" >Inclusão manual do gravame</a>
																				<a href="#" class="botao" id="btConcluir" >Concluir</a>
																				<a href="#" class="botao" id="btConsultar" >Consultar</a>																				
																				<a href="#" class="botao" id="btImprimir" >Imprimir</a>
																				
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
								</
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