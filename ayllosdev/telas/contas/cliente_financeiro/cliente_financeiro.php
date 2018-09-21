<?
/*!
 * FONTE        : cliente_financeiro.php
 * CRIAÇÃO      : Gabriel Santos (DB1)
 * DATA CRIAÇÃO : Março/2010 
 * OBJETIVO     : Mostra rotina de Cliente Financeiro da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001 [29/03/2010] Rodolpho Telmo (DB1)  : Controle de Abas
 * 002 [05/08/2015] Gabriel (RKAM)        : Reformulacao cadastral. 
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
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','');

	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];

	// A rotina somente possui uma opção de tela, mas trataremos como 2 Abas, uma para "Dados Sistema Financeiro" 
	// e outra para "Emissão Ficha Cadastral", por isso da valor fixo abaixo
	$qtOpcoesTela = 2;
	
	// Carrega opção visão e verifica se usuario tem acesso.
	$flgAcesso = (in_array("@",$glbvars["opcoesTela"]));
	
	$inpessoa  = $_POST['inpessoa'];
	$flgcadas  = $_POST['flgcadas'];
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'@',false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Aimaro',$metodo,($inpessoa == 2));
	}	
	
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>	
						<table width="100%" border="0" cellspacing="0" cellpadding="0" id="tituloRotina">
							<tr>
								<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif">CLIENTE FINANCEIRO</td>
								<td width="12" id="tdTitTela" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina(divRotina);return false;"><img src="<? echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<? echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
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
											<td><img src="<? echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaCliEsq1"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCliCen1"><a href="#" id="linkAbaCli1" onClick="controlaOperacao('TD');"  class="txtNormalBold">Dados Sistema Financeiro</a></td>
											<td><img src="<? echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaCliDir1"></td>
											<td width="1"></td>
											
											<td><img src="<? echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaCliEsq2"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCliCen2"><a href="#" id="linkAbaCli2" onClick="controlaOperacao('TE');"  class="txtNormalBold">Emiss&atilde;o Ficha Cadastral</a></td>
											<td><img src="<? echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaCliDir2"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoCliente"></div>
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
	var qtOpcoesTela = "<? echo $qtOpcoesTela; ?>";		
	var flgcadas     = "<? echo $flgcadas;     ?>";
	
	if (inpessoa == 2) {
		exibeRotina(divRotina);      // Exibir a rotina quando PJ
	} else {
		$("#tituloRotina").remove(); // Remover titulo para PF
	}
	
	controlaOperacao('TD');	
</script>