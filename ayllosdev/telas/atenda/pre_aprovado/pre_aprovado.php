<?php
/*!
 * FONTE        : pre_aprovado.php
 * CRIAÇÃO      : Petter Rafael - Envolti
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Mostrar rotina de Pre Aprovado da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	

    // Se parâmetros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) 
	   exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','');

	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");	

	setVarSession("opcoesTela",$opcoesTela);
	$qtOpcoesTela = count($opcoesTela);

    // Carregas as opções da Rotina de Ativo/Passivo
	$flgAcesso   = (in_array("@", $glbvars["opcoesTela"]));
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));

	if ($flgAcesso == ""){
		exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a tela de Filia&ccedil;&atilde;o.','Alerta - Ayllos','');
    }
 ?>
 <table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
		<td align="center">	
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11">
                                    <img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21">
                                </td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">
                                    Pré-Aprovado
                                </td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">
                                    <a href="#" onClick="encerraRotina(true);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a>
                                </td>
								<td width="8">
                                    <img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21">
                                </td>
							</tr>
						</table>     
					</td> 
				</tr> 
                <tr>
					<td class="tdConteudoTela" align="center">	
                        <table width="100%"  border="0" cellspacing="0" cellpadding="0">
							<tr>
                                <td>
									<table border="background-color: #F4F3F0;" cellspacing="0" cellpadding="0" >
                                        <tr>
                                            <td>
                                                <img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0">
                                            </td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0">
                                                <a href="#" id="linkAba0" onClick="acessaOpcaoAba(2,0,0)" class="txtNormalBold">Pr&eacute;-Aprovado</a>
                                            </td>
											<td>
                                                <img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0">
                                            </td>
											<td width="1"></td>
											<td>
                                                <img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq1">
                                            </td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen1">
                                                <a href="#" id="linkAba1" onClick="acessaOpcaoAba(2,1,1)" class="txtNormalBold">Restri&ccedil;&otilde;es no Sistema</a>
                                            </td>
											<td>
                                                <img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir1">
                                            </td>
											<td width="1"></td>
                                            <td>
                                                <img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq2">
                                            </td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen2">
                                                <a href="#" id="linkAba2" onClick="acessaOpcaoAba(2,2,2)" class="txtNormalBold">Carga Manual e Bloqueio Manual</a>
                                            </td>
											<td>
                                                <img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir2">
                                            </td>
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
	var flgAlterar   = "<? echo $flgAlterar;  ?>";
	var qtOpcoesTela = "<? echo $qtOpcoesTela; ?>";
    
	exibeRotina(divRotina);	
	acessaOpcaoAba("<? echo $qtOpcoesTela ?>",0,0);
</script>