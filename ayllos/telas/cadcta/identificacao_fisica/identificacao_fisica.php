<?
/*!
 * FONTE        : identificacao_fisica.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : Janeiro/2010 
 * OBJETIVO     : Mostra rotina de Identificação Física Conjuge da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [25/03/2010] Rodolpho Telmo  (DB1): Adequação da tela ao novo padrão
 * 002: [18/01/2011] David (CECRED)       : Utilizar classe "fecharRotina" no botão para fechamento da rotina
 * 003: [21/05/2012] Adriano (CECRED)     : Ajustes referente ao projeto GP - Sócios Menores
 * 004: [01/09/2015] Gabriel (RKAM)       : Reformulacao Cadastral.
 */	
?>

<?
	session_start();	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");	
	isPostMethod();
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','');

	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);

	$qtOpcoesTela = count($opcoesTela);

	// Carregas as opções da Rotina de Bens
	$flgAcesso   = (in_array("@", $glbvars["opcoesTela"]));
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));
	$flgIncluir  = (in_array("I", $glbvars["opcoesTela"]));

	$opeaction = ((isset($_POST['opeaction'])) ? $_POST['opeaction'] : '');
	

	if ($flgAcesso == "") exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a tela de Identifica&ccedil;&atilde;o F&iacute;sica.','Alerta - Ayllos','');
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="430">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="tdTitRotina" class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">IDENTIFICAÇÃO FÍSICA</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharRotina" onClick="fechaRotina(divRotina,'','obtemCabecalho();');return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="acessaOpcaoAba(3,0,'@')" class="txtNormalBold">IDENTIFICAÇÃO</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao" style="height: 340px; width: 500px;">&nbsp;</div>
									<div id="divOpcoesDaOpcao1">&nbsp;</div>
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
	var flgAlterar   = "<? echo $flgAlterar;   ?>";
	var flgIncluir   = "<? echo $flgIncluir;   ?>";
	var qtOpcoesTela = "<? echo $qtOpcoesTela; ?>";
		
	exibeRotina(divRotina);

	<? echo "acessaOpcaoAba(".$qtOpcoesTela.",0,'".$opcoesTela[0]."');"; ?>
    
    if (opeaction == 'CI'){
        operacao = '<?=$opeaction?>';
    }

	var opeaction = '<?=$opeaction?>';
    
	if (opeaction == 'CI'){   
        // Aguardar terminar de montar a tela        
        setTimeout(function(){ controlaOperacao('CI'); }, 800);	
	}
    
</script>