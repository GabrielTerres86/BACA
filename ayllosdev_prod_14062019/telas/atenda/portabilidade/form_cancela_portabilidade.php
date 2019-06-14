<?php
	/*!
	* FONTE        : form_cancela_portabilidade.php
	* CRIAÇÃO      : Andre Clemer
	* DATA CRIAÇÃO : Outubro/2018
	* OBJETIVO     : Mostrar rotina de cancelamento de portabilidade.
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);
	}  

	$xml  = "<Root>";
	$xml .= " <Dados/>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ATENDA", "BUSCA_MOTIVOS_CANCELAMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','estadoInicial()', false);
	}

	$registros = $xmlObject->roottag->tags;
?>
<table cellpadding="0" cellspacing="0" border="0" width="555">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">PORTABILIDADE DE SAL&Aacute;RIO</td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'));exibeRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>     
                    </td> 
                </tr>    
                <tr>
                    <td class="tdConteudoTela" align="center">	
                        <table width="100%"  border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td style="border: 1px solid #F4F3F0;">
                                    <table border="background-color: #F4F3F0;" cellspacing="0" cellpadding="0" >
                                        <tr>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="8" height="21" id="imgAbaEsq0"></td>
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0" class="txtNormalBold">Principal</td>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="8" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <form action="" method="post" name="frmCancelaPortabilidade" id="frmCancelaPortabilidade" class="formulario">
	
										<div id="divDados" class="clsCampos">
										
											<fieldset style="padding: 5px">
												<legend>Motivo</legend>
												<label for="cdmotivo" class="clsCampos" style="width:110px">Motivo:</label>
												<select id="cdmotivo" name="cdmotivo" class="campo" style="width:320px">
												<?php
													foreach ($registros as $registro) {
														$cddominio = getByTagName($registro->tags,'cddominio');
														$dscodigo  = getByTagName($registro->tags,'dscodigo');

														echo '<option value="'.$cddominio.'">'.$dscodigo.'</option>';
													}
												?>
												</select>
											</fieldset>
										
										</div>
									</form>

									<div id="divBotoes" style="padding: 5px">	
										<a class="botao" id="btConfirmar" href="#" onclick="confirmaCancelamento(false)">Confirmar</a>
										<a class="botao" id="btVoltar" href="#" onclick="fechaRotina($('#divUsoGenerico'));exibeRotina($('#divRotina')); return false;">Voltar</a>
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
<script type="text/javascript">
    controlaLayout('C');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divUsoGenerico").css("z-index")));
</script>