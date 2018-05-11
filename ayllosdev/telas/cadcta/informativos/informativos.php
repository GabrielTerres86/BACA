<?
/*!
 * FONTE        : informativos.php
 * CRIAÇÃO      : Rodolpho Telmo (DB!)
 * DATA CRIAÇÃO : 19/04/2010 
 * OBJETIVO     : Mostra rotina de INFORMATIVOS da tela de CONTAS
 */	 
?>

<?	
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');		
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST['nmdatela']) || !isset($_POST['nmrotina'])) exibirErro('error','Parâmetros incorretos.','Alerta - Ayllos','');
	    
    $nmdatela = isset($_POST["nmdatela"]) ? $_POST["nmdatela"] : $glbvars["nmdatela"];
	$nmrotina = isset($_POST["nmrotina"]) ? $_POST["nmrotina"] : $glbvars["nmrotina"];	
    
	// Carrega permissões do operador
	/*include('../../../includes/carrega_permissoes.php');*/
	
	setVarSession("opcoesTela",$opcoesTela);
	
	// Carregas as opções da Rotina de Bens
	/*
    
    $flgAcesso   = (in_array('@', $glbvars['opcoesTela']));	
	$flgIncluir  = (in_array('I', $glbvars['opcoesTela']));	
	$flgExcluir  = (in_array('E', $glbvars['opcoesTela']));
    if ($flgAcesso == '') exibirErro('error','Seu usuário não possui permissão de acesso a tela de Informativos.','Alerta - Ayllos','');
    */
	
    $opeaction   = ((isset($_POST['opeaction'])) ? $_POST['opeaction'] : '');
	
	
    
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="500">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">INFORMATIVOS</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina(divRotina,'','obtemCabecalho();');return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="acessaOpcaoAba(4,0,'@')" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao"></div>
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
	// Declara os flags para as opções da Rotina de Bens	
	var flgIncluir  = "<? echo $flgIncluir; ?>";
	var flgExcluir  = "<? echo $flgExcluir; ?>";
	var opeaction   = "<? echo $opeaction; ?>";
	exibeRotina(divRotina);

    controlaOperacao(opeaction);
	
</script>


