<?php 
	/************************************************************************
         Fonte: consorcio.php
         Autor: Lucas R.
         Data : Julho/2013                  &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000

         Objetivo  : Mostrar rotina de CONSORCIO da tela ATENDA

         Altera&ccedil;&otilde;es:
 		 25/07/2016 - Adicionado classe (SetWindow) - necessaria para navegação com teclado - (Evandro - RKAM)             					
	  ************************************************************************/
?>
<?	
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');		
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST['nmdatela'])) exibirErro('error','Parâmetros incorretos.','Alerta - Aimaro','');
	
   $labelRot = $_POST['labelRot'];	

	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	
	
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table cellpadding="0" cellspacing="0" border="0" width="645">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo $nmrotina; ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>        
						</table>
					</td>        
				</tr>        
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%"  border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
           									<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba(1,0,0);return false;">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
                                        </tr>
									</table>
								</td>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao" style="height: 245px;"></div>
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
	
	exibeRotina(divRotina);
	hideMsgAguardo();
	bloqueiaFundo(divRotina);	
	acessaOpcaoAba(1,0,0);

</script>
