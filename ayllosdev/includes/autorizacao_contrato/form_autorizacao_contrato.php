<?php
/***************************************************************************************
 * FONTE        : form_autorizacao_contrato.php				Última alteração: --/--/----
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 13/12/2018
 * OBJETIVO     : Solicita senha de autorização
 
   Alterações   :  04/06/2019 - Ajuste para exibir alerta de acordo com retorno 
                                dsmensagem do oracle - PRJ 470 (Mateus Z / Mouts)
 
 **************************************************************************************/
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
  
	$nrdconta    = (isset($_POST["nrdconta"]))    ? $_POST["nrdconta"]    : "";
	$tpcontrato  = (isset($_POST["tpcontrato"]))  ? $_POST["tpcontrato"]  : "";
    $vlcontrato  = (isset($_POST["vlcontrato"]))  ? $_POST["vlcontrato"]  : "";
    $obrigatoria = (isset($_POST["obrigatoria"])) ? $_POST["obrigatoria"] : "";

    //bruno - prj 470 - alt 1
	$nrcontrato  = (isset($_POST["nrcontrato"]))  ? $_POST["nrcontrato"]  : "";

    //Ajustar valor do contrato caso tenha ","
    $vlcontrato = str_replace(".","",$vlcontrato);
    $vlcontrato = str_replace(',','.',$vlcontrato);
    
    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= "  <Dados>";
    $xml .= "    <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "    <tpcontrato>" . $tpcontrato . "</tpcontrato>";
    $xml .= "    <vlcontrato>" . $vlcontrato . "</vlcontrato>";
    $xml .= "    <nrcontrato>" . $nrcontrato . "</nrcontrato>"; //prj 470 - bruno - alt 1
    $xml .= "  </Dados>";
    $xml .= "</Root>";
    
    $xmlResult = mensageria($xml, "TELA_AUTCTD", "VER_CARTAO_MAG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = simplexml_load_string($xmlResult);

    if($xmlObject->Erro->Registro != null){  
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if($msgErro == null || $msgErro == ''){
            $msgErro = $xmlObject->Erro->Registro->dscritic;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
    }

    $contas    = $xmlObject->inf->contas;
    $qtcartoes = $xmlObject->inf->qtcartoes;
    $inpessoa  = $xmlObject->inf->inpessoa;
    $flgsenha  = $qtcartoes > 0 ? 1 : 0;
    // Pj470 - SM2 -- Mateus Zimmermann -- Mouts
    $dsmensagem = $xmlObject->inf->dsmensagem;

?>	
<? if($dsmensagem){ ?>
    <!-- Pj470 - SM2 -- Mateus Zimmermann -- Mouts -->
    <script>
        fechaRotina($('#divUsoGenerico'));
        showError("inform",'<? echo utf8ToHtml($dsmensagem) ?>',"Alerta - Aimaro","exibeRotina($('#divUsoGenerico'))");
    </script>
    <!-- Fim Pj470 - SM2 -->
<? } ?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?php echo utf8ToHtml('Opções Documento') ?></td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><!--<a href="#" id="btFecharAutorizacaoContrato"><img src="<?php //echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a>--></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 8px;">							
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 5px;">
                                    <form name="frmAutorizacaoContrato" id="frmAutorizacaoContrato" class="formulario" method="post" onsubmit="return false;">
                                        <input type="hidden" name="inpessoa" value="<?php echo $inpessoa; ?>">
                                        <div id="divTipoAutorizacaoContrato">
                                            <?php if($flgsenha == 1){ ?>
                                                <input name="tipautor" id="senha" type="radio" class="radio" value="1" <?php if ($flgsenha == 1) { echo "checked"; } ?> />
                                                <label for="senha" class="radio">Solicitar senha do cooperado</label>
                                                <br style="clear:both" />
                                            <?php } ?>
                                            <input name="tipautor" id="impressao" type="radio" class="radio" value="2" <?php if ($flgsenha == 0) { echo "checked"; } ?> />
                                            <label for="impressao" class="radio">Imprimir Documento</label>
                                        </div>
                                        <br style="clear:both" />
                                        <fieldset id="fsSenhasAutorizacaoContrato">
                                            <?php foreach ($contas as $conta) { ?>
                                                <div class="senhas" data-nrcontausuario='<?php echo $conta->nrdconta; ?>'>
                                                    <label class="rotulo" data-campo-nome='sim'><?php echo $conta->nrcpfcgc ?> - <?php echo $conta->nmprimtl  ?></label><br>
                                                    <label class='rotulo'>Senha :</label>
                                                    <input type="password" class="campo dssencar inteiro" />
                                                    <label class="lblErro"></label>
                                                    <br />
                                                </div>
                                            <?php } ?>
                                        </fieldset>
                                    </form>
                                    <br style="clear:both" />
                                    <div id="divBotoesAutorizacaoContrato">
                                        <a href="#" class="botao" id="btVoltarAutorizacaoContrato">Voltar</a>
                                        <a href="#" class="botao" id="btProsseguirAutorizacaoContrato">Prosseguir</a> 
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
