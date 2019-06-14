<?php 

	/************************************************************************
	 Fonte: produtos.php                                              
	 Autor: Gabriel - Rkam                                                    
	 Data : Setembro/2015                   Última alteraçÃo: 
	                                                                  
	 Objetivo  : Mostrar rotina de Produtos da tela ATENDA            
	                                                                  	 
	 Alterações: 
	
	************************************************************************/
	
	// Carregas as opções da Rotina 
	$flgAcesso	  = (in_array('@', $glbvars['opcoesTela']));
	
	$flgcadas = $_POST['flgcadas'];
    $labelRot = $_POST['labelRot'];
	
	if ($flgAcesso == '') exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a tela de Produtos.','Alerta - Aimaro','');
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">PRODUTOS</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="executandoProdutos = false;encerraRotina(true);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<?php 
											$idPrincipal = 0;	
											
											//Mostra opções da rotina Atendimento no layer conforme permissão do operador
											for ($i = 0; $i < count($opcoesTela); $i++) {
												if ($opcoesTela[$i] <> "@") {
													continue;
												}
												
												switch ($opcoesTela[$i]) {							
													case "@": 
													      $nameOpcao = "Principal";
														  $idPrincipal = $i; 
													break;													
												}												
											?>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq<?php echo $i; ?>"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen<?php echo $i; ?>"><a href="#" id="linkAba<?php echo $i; ?>" onClick="acessaOpcaoAba(<?php echo count($opcoesTela); ?>,<?php echo $i; ?>,'<?php echo $opcoesTela[$i]; ?>',1);return false;" class="txtNormalBold"><?php echo $nameOpcao; ?></a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir<?php echo $i; ?>"></td>
											<td width="1"></td>
											<?php
											} // Fim do for
											?>	
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao" style="height: 350px;">&nbsp;</div>
								</td>
							</tr>
						</table>			    
					</td> 
				</tr>
			</table>
		</td>
	</tr>
</table>			
<script type="text/javascript">

	var flgcadas = '<? echo $flgcadas; ?>';
	
	// Mostra div da rotina
	mostraRotina();

	// Centralizar tela
	$('#divRotina').css({'width':'1000px','height':'600px','position':'absolute', 'left':'50%','margin-left':'-500px','top':'50%','margin-top':'-300px'});
	
	// Esconde mensagem de aguardo
	hideMsgAguardo();	
		
	<?php 	
		
	if (in_array("@",$opcoesTela)) { // Se operador possuir permissão	
		echo "acessaOpcaoAba(".count($opcoesTela).",".$idPrincipal.",'".$opcoesTela[$idPrincipal]."','".$_POST["opeProdutos"]."');";
	} else {
		echo "acessaOpcaoAba(".count($opcoesTela).",0,'".$opcoesTela[0]."','".$_POST["opeProdutos"]."');";
	}
	?>
	
</script>