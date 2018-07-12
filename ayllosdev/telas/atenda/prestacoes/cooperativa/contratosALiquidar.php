<?php

    /*
    * FONTE        : contratosALiquidar.php
    * CRIAÇÃO      : Diego Simas (AMcom)
    * DATA CRIAÇÃO : 09/07/2018
    * OBJETIVO     : Mostra a tela com lista de contratos a liquidar.
    */	
	
	session_start();

	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');

    $cdcooper = $_POST['cdcooper'] == '' ? 0 : $_POST['cdcooper'];
	$nrdconta = $_POST['nrdconta'] == '' ? 0 : $_POST['nrdconta'];
	$nrctremp = $_POST['nrctremp'] == '' ? 0 : $_POST['nrctremp'];
	
	// Monta o xml de requisição
	
    $xml  = "";
    $xml .= "<Root>";
    $xml .= "  <Dados>";
    $xml .= "    <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";		
    $xml .= "    <nrctremp>".$nrctremp."</nrctremp>";		
    $xml .= "  </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_ATENDA_PRESTACOES", "CONSULTAR_CONTRATOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
    $xmlObjeto = getObjectXML($xmlResult);	
    
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial()', false);
    }

    $contratos = $xmlObjeto->roottag->tags[0]->tags[0]->tags;	    
  
?>

    <script type="text/javascript">
        var dsctrliqCL = '';        
    </script>

    <table id="tdImp"cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="400">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Contratos Liquidados</td>
									<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),divRotina);"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
									<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
								</tr>
							</table>     
						</td> 
					</tr>    
					<tr>
						<td class="tdConteudoTela" align="center">	
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px 2px 8px;">
										<div id="divConteudoOpcao">
                                            <div id="tabPrestacao">
                                                <div class="divRegistros">	
                                                    <table class="tituloRegistros">
                                                        <thead>
                                                            <tr>
                                                                <th title="Contratos Liquidados Selecionados"><?php echo 'S'; ?></th>
                                                                <th title="Linha de Cr&eacute;dito"><?php echo 'Lin'; ?></th>
                                                                <th title="Finalidade"><?php echo 'Fin'; ?></th>
                                                                <th title="N&uacute;mero de Contrato"><?php echo 'Contrato'; ?></th>
                                                                <th title="Produto"><?php echo 'Produto'; ?></th>
                                                                <th title="Data"><?php echo 'Data'; ?></th>
                                                                <th title="Valor Emprestado"><?php echo 'Emprestado'; ?></th>
                                                                <th title="Parcelas"><?php echo 'Parc'; ?></th>
                                                                <th title="Valor"><?php echo 'Valor'; ?></th>
                                                                <th title="Saldo"><?php echo 'Saldo'; ?></th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <?php foreach( $contratos as $contrato ) {
                                                            if(getByTagName($contrato->tags,'tpcontvi') == "*"){
                                                                echo("<script type='text/javascript'>");
                                                                echo("dsctrliqCL += ".getByTagName($contrato->tags,'nrctremp')."+','".";");
                                                                echo("</script>");    
                                                            }
                                                            switch (getByTagName($contrato->tags,'tpemprst')) {
                                                                case 0:
                                                                    $tipo = "Price TR";
                                                                    break;
                                                                case 1:
                                                                    $tipo = "Price Pre-fixado";
                                                                    break;
                                                                case 2:
                                                                    $tipo = "Pos-fixado";
                                                                    break;
                                                            } ?>
                                                            <?php

                                                            if(getByTagName($contrato->tags,'tpcontvi') != "*"){
                                                                echo "<tr ondblclick='selecionarContrato(this);'>";
                                                            }else{
                                                                echo "<tr>";
                                                            }
                                                            ?>                                                            
                                                                <!-- Hiddens -->
                                                                <input type="hidden" id="nrctrempCL" name="nrctrempCL" value="<?php echo getByTagName($contrato->tags,'nrctremp'); ?>" />                                                        
                                                                <input type="hidden" id="selecionado" name="selecionado" value="<?php echo getByTagName($contrato->tags,'tpcontvi'); ?>" />                                                        
                                                                <td><a id='selecao'><?php echo getByTagName($contrato->tags,'tpcontvi'); ?></a></td>
                                                                <td><?php echo getByTagName($contrato->tags,'cdlcremp') ?></td>
                                                                <td><?php echo getByTagName($contrato->tags,'cdfinemp') ?></td>
                                                                <td><?php echo formataNumericos("z.zzz.zzz.zzz",getByTagName($contrato->tags,'nrctremp'),"."); ?></td>
                                                                <td><?php echo stringTabela($tipo,40,'maiuscula'); ?></td> 
                                                                <td><?php echo getByTagName($contrato->tags,'dtmvtolt') ?></td>
                                                                <td><?php echo number_format(str_replace(",",".",getByTagName($contrato->tags,'vlemprst')),2,",",".");?></td>
                                                                <td><?php echo getByTagName($contrato->tags,'qtpreemp') ?></td>
                                                                <td><?php echo number_format(floatval(str_replace(",",".",getByTagName($contrato->tags,'vlpreemp'))),2,",",".");  ?></td>
                                                                <td><?php echo number_format(floatval(str_replace(",",".",getByTagName($contrato->tags,'vlsdeved'))),2,",",".");  ?></td>
                                                            </tr>				
                                                            <? } ?>                                                            
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>                                            
                                            <div id="divBotoes">
                                                <a href="#" class="botao" id="btVoltar" onClick="mostraDivControles('CONTROLES');">Voltar</a>
                                                <a href="#" class="botao" id="btPagar" onClick="gravaContratosLiquidados();">Gravar</a>
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

    <script type="text/javascript">
        
        formataContratosLiq();
        
        function selecionarContrato(_this){
            
            //Trata (Seleção) NÚMEROS DE CONTRATOS LIQUIDADOS
            var contratoSel = $(_this).find('#nrctrempCL').val();
            var arrayContratos = dsctrliqCL.split(",");                     
            var selecionado = $(_this).find('#selecao').text();

            if(selecionado == ""){                
                $(_this).find('#selecao').text("*");                
                if (arrayContratos.indexOf(contratoSel) === -1) {
                    dsctrliqCL += contratoSel + ',';
                }
            }else{
                $(_this).find('#selecao').text(""); 
                if (arrayContratos.indexOf(contratoSel) != -1) {
                    var dsctrliqCLaux = dsctrliqCL.replace(contratoSel+',','');
                    dsctrliqCL = dsctrliqCLaux;
                }
            }
        }
        
    </script>
