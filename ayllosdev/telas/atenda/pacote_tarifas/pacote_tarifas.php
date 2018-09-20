<?php 
	/************************************************************************
         Fonte: pacote_tarifas.php
         Autor: Lucas Lombardi
         Data : Marco/2016                  Última alteração: 00/00/0000

         Objetivo  : Mostrar rotina de Pacote Tarifas da tela ATENDA

         Alterações:
             					
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
	if (!isset($_POST['nmdatela'])) exibirErro('error','Parâmetros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina);');
	
    $labelRot = $_POST['labelRot'];	
	
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	
	
	setVarSession("opcoesTela",$opcoesTela);
		
	// Carregas as opções da Rotina de Pacote de tarifas
	$flgAcesso     = (in_array('@',$glbvars["opcoesTela"]));	
	$msgErro 	   = 'Acesso n&atilde;o permitido para esta op&ccedil;&atilde;o.';
				
	if ($flgAcesso == '') exibirErro('error',$msgErro,'Alerta - Aimaro','bloqueiaFundo(divRotina);');
	
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table id="tabelaPai" cellpadding="0" cellspacing="0" border="0" width="645">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo $nmrotina; ?></td>
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
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px 2px 8px;">
									<form name="frmImprimir" id="frmImprimir" style="display:none">
										<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">										
										<input name="nmarquiv" id="nmarquiv" type="hidden" value="" />
									</form>
									<input type="hidden" name="dtmvtolt" id="dtmvtolt" value="<?php echo $glbvars["dtmvtolt"]; ?>">
									<div id="divConteudoOpcao" style="height: 245px;"></div>
								</td>
								<div id="divRotina"></div>
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
