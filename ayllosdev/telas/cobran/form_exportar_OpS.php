<? 
/*!
 * FONTE        : form_exportar_OpS.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 28/04/2016
 * OBJETIVO     : Formulario que permite exportar consulta de situação dos convenios
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 
 *
 */
?>

<?

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	isPostMethod();	
    
    // Classe para leitura do xml de retorno
    require_once("../../class/xmlfile.php");	
    if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S")) <> "") {
        exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo();',false);
    }
 
    $telcdcop  = $_POST["telcdcop"];
    $nrconven  = $_POST["nrconven"];
    $nrdconta  = $_POST["nrdconta"];
    $cdagenci  = $_POST["cdagenci"];
    $dtinicio  = $_POST["dtinicio"];
    $dtafinal  = $_POST["dtafinal"];
    $insitceb  = $_POST["insitceb"];
    $cddopcao  = $_POST["cddopcao"];
    $nmarqint  = $_POST["nmarqint"];
    
    //Exportar consulta
    if ($cddopcao == 'ES') {
        $nmarqint = "/micros/".$glbvars["nmcooper"]."/cobranca/".$nmarqint.".txt";
       
        // Montar o xml de Requisicao
        $xml  = "";
        $xml .= "<Root>";
        $xml .= " <Dados>";	
        $xml .= "   <telcdcop>".$telcdcop."</telcdcop>";
        $xml .= "   <nrconven>".$nrconven."</nrconven>";
        $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
        $xml .= "   <telcdage>".$cdagenci."</telcdage>";
        $xml .= "   <dtinicio>".$dtinicio."</dtinicio>";
        $xml .= "   <dtafinal>".$dtafinal."</dtafinal>";
        $xml .= "   <insitceb>".$insitceb."</insitceb>";
        $xml .= "   <nmarqdst>".$nmarqint."</nmarqdst>";
        $xml .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
        
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "COBRAN", "EXPORT_CONV_SIT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);

        if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
            $msgError = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
            exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo();',false);
            
        }else{
            $msgError = 'Arquivo gerado com sucesso!';
            exibirErro('inform',$msgError,'Alerta - Aimaro','fechaRotina($(\'#divRotina\'));hideMsgAguardo();',false);
            die();
        } 
    }
	
?>

<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">&nbsp;</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudo">

										<form id="frmExportarOpS" name="frmExportarOpS" class="formulario" onsubmit="return false;">

											<fieldset>
												<legend>Exportar Consulta</legend>
												<label for="nmarqint">Destino:</label>
                                                <label for="nmarqint1">/micros/<? echo $glbvars["nmcooper"]; ?>/cobranca/</label>
												<input name="nmarqint" id="nmarqint" type="text" />
                                                <label for="nmarqint2">.txt</label>
												
											</fieldset>	

										</form>

										<div id="divBotoes" style="margin-bottom:10px">
											<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Cancelar</a>
											<a href="#" class="botao" id="btContinuar" >Continuar</a>
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