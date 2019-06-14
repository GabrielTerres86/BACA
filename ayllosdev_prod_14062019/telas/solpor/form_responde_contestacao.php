<?php
	/*!
	* FONTE        : form_responde_contestacao.php
	* CRIAÇÃO      : Andrey Formigari
	* DATA CRIAÇÃO : Janeiro/2019
	* OBJETIVO     : Mostrar rotina de responder contestação.
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	$idstatus   = ( ( !empty($_POST['idstatus']) )   ? $_POST['idstatus']   : 2 );
	$dsrowid   =  ( ( !empty($_POST['rowid']) )   	 ? $_POST['rowid']   	: '' );
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "	<cdmotivo>".$idstatus."</cdmotivo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ATENDA", "BUSCA_MOTIVOS_RESPONDE_CONTESTACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','estadoInicial()', false);
	}

	$registros = $xmlObject->roottag->tags;

	$xml = new XmlMensageria();
	$xml->add('dsrowid',$dsrowid);

	$xmlResult = "";

    $xmlResult = mensageria($xml, "SOLPOR", "DETALHE_PORTABILIDADE_RETORNO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	$solicitacao = $xmlObj->roottag->tags[0]->tags[0]->tags;
	$nusolicitacao = getByTagName($solicitacao,"nusolicitacao");
	
	/*
	*** Busca dados da contestação
	*/
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrnuportabilidade>".$nusolicitacao."</nrnuportabilidade>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "BUSCA_DADOS_CONTESTACAO_RECEBE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','acessaOpcaoAba(2,0,"0")', false);
	}
	
	$contestacao = $xmlObject->roottag->tags[0];
	$dsmotivo = getByTagName($contestacao->tags,'dsmotivo');
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="555">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">RESPONDER CONTESTA&Ccedil;&Atilde;O</td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
                                    <form action="" method="post" name="frmResponderContestacao" id="frmResponderContestacao" class="formulario">
	
										<div id="divDados" class="clsCampos">
										
											<fieldset style="padding: 5px">
												<legend>Motivo</legend>
												
												<label class="clsCampos" style="width: 145px;">Motivo:</label>
												<textarea style="width: 320px;height: 60px;margin-right: 37px;" id="dsmotivo" class="campoTelaSemBorda" readonly disabled><?=$dsmotivo;?></textarea>
												
												<label class="clsCampos" style="width: 145px;">Aprova&ccedil;&atilde;o portabilidade:</label>
												<div style="float:left;">
													<input onclick="responderContestacao('<?php echo $dsrowid; ?>', 2);return fasle;" <?php echo (($idstatus == 2) ? 'checked' : ''); ?> class="radio" id="id_situacao_aprovada" type="radio" name="idsituacao" value="2" /> 
													<label onclick="responderContestacao('<?php echo $dsrowid; ?>', 2);return fasle;" for="id_situacao_aprovada" style="margin:1px 15px 0 3px;">Manter Aprova&ccedil;&atilde;o</label>
												</div>
												<div style="float:left;">
													<input onclick="responderContestacao('<?php echo $dsrowid; ?>', 3);return fasle;" <?php echo (($idstatus == 3) ? 'checked' : ''); ?> class="radio" id="id_situacao_reprovada" type="radio" name="idsituacao" value="3" /> 
													<label onclick="responderContestacao('<?php echo $dsrowid; ?>', 3);return false;" for="id_situacao_reprovada" style="margin:1px 0 0 3px;">Reprovada</label>
												</div>
												
												<br style="clear:both"/>
												
												<label for="cdmotivo" class="clsCampos" style="width:145px">Resposta:</label>
												<select id="cdmotivo" name="cdmotivo" class="campo" style="width:320px">
													<option value=""></option>
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
										<a class="botao" id="btConfirmar" href="#" onclick="confirmaRespondeContestacao(false, '<?php echo $dsrowid; ?>')">Confirmar</a>
										<a class="botao" id="btVoltar" href="#" onclick="fechaRotina($('#divUsoGenerico')); return false;">Voltar</a>
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