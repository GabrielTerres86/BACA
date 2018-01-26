<?
/*!
 * FONTE        : procuradores.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 15/09/2010 
 * OBJETIVO     : Mostra rotina de Representantes/Procuradores (Pessoa Física)
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 * ALTERACOES   : 22/07/2013 - inclusão da opção de poderes (Jean Michel).
 *
 */	
?>
 
<?

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');		
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	

    
	// Verifica permissões de acessa a tela
	//if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'@')) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','');
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST['nmdatela']) || !isset($_POST['nmrotina'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','');
	$nmdatela = isset($_POST["nmdatela"]) ? $_POST["nmdatela"] : $glbvars["nmdatela"];
	$nmrotina = isset($_POST["nmrotina"]) ? $_POST["nmrotina"] : $glbvars["nmrotina"];	
    // Armazenar nome da tela e rotina na sessão
    setVarSession("nmdatela",$nmdatela);
    setVarSession("nmrotina",$nmrotina);

	// Carrega permissões do operador
    //para esta tela nao é necesario validar permissao
	//include('../../../includes/carrega_permissoes.php');	
	
	setVarSession("opcoesTela",$opcoesTela);
    
	
	// Carregas as opções da Rotina de Procuradores/representantes
	$flgAcesso	  = (in_array('@', $glbvars['opcoesTela']));
	$flgConsultar = (in_array('C', $glbvars['opcoesTela']));
	$flgAlterar   = (in_array('A', $glbvars['opcoesTela']));
	$flgIncluir   = (in_array('I', $glbvars['opcoesTela']));
	$flgExcluir   = (in_array('E', $glbvars['opcoesTela']));
	$flgPoderes   = (in_array('P', $glbvars['opcoesTela']));

	
	$opeaction   = ((isset($_POST['opeaction'])) ? $_POST['opeaction'] : '');
		
		
	//if ($flgAcesso == '') exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a tela de Representantes/Procuradores.','Alerta - Ayllos','');
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">PROCURADORES</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina(divRotina,'','encerraRotina(true);');return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao"><? include ('principal.php'); ?></div>
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
	
	// Declara os flags para as opções da Rotina de Procuradores
	var flgAlterar   = "<? echo $flgAlterar;   ?>";	
	var flgIncluir   = "<? echo $flgIncluir;   ?>";	
	var flgExcluir   = "<? echo $flgExcluir;   ?>";	
	var flgConsultar = "<? echo $flgConsultar; ?>";	
	var flgPoderes 	 = "<? echo $flgPoderes;   ?>";
	var opeaction 	 = "<? echo $opeaction;   ?>";
	
	 //alert(flgAlterar+' | '+flgIncluir+' | '+flgExcluir+' | '+flgConsultar+' | '+flgPoderes);
	
	// Função que exibe a Rotina
	exibeRotina(divRotina);
	

    controlaOperacaoProcuradores(opeaction);

	
</script>