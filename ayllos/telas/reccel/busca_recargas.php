<?php
	/*!
	 * FONTE        : busca_recargas.php
	 * CRIAÇÃO      : Lucas Reinert
	 * DATA CRIAÇÃO : 07/03/2017
	 * OBJETIVO     : Rotina para buscar as recargas de celular
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$nrdconta = !isset($_POST["nrdconta"]) ? 0  : $_POST["nrdconta"];
	$dtinirec = !isset($_POST["dtinirec"]) ? "" : $_POST["dtinirec"];
	$dtfimrec = !isset($_POST["dtfimrec"]) ? "" : $_POST["dtfimrec"];
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 50;

	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"C")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Verifica se os parâmetros necessários foram informados	
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','$(\'#nrdconta\', \'#frmOpcaoC\').focus();',false);
	if ($nrdconta == 0) exibirErro('error','Informe o n&uacute;mero da conta.','Alerta - Ayllos','$(\'#nrdconta\', \'#frmOpcaoC\').focus();',false);
	if ($dtinirec == "" || $dtfimrec == "") exibirErro('error','Informe as datas inicial e final do período.','Alerta - Ayllos','$(\'#dtinirec\', \'#frmOpcaoC\').focus();',false);
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <dtinirec>".$dtinirec."</dtinirec>";
	$xml .= "   <dtfimrec>".$dtfimrec."</dtfimrec>";
	$xml .= "	<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "	<nrregist>".$nrregist."</nrregist>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_RECCEL", "BUSCA_RECARGAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}
	
	$qtregist = $xmlObj->roottag->tags[1]->cdata;
		
?>
<div class="divRegistros">	
	<table class="tituloRegistros" id="tbRecargas">
		<thead>
			<tr>
				<th>Transa&ccedil;&atilde;o</th>
				<th>Hora</th>
				<th>Valor</th>
				<th>DDD/Telefone</th>
				<th>Operadora</th>
				<th>NSU Operadora</th>
			</tr>
		</thead>
		<tbody>
			<input type="hidden" id="nriniseq" value="<? echo $nriniseq ?>"/>
			<input type="hidden" id="nrregist" value="<? echo $nrregist ?>"/>
            <input type="hidden" id="qtregist" value="<? echo $qtregist ?>"/>
            <?
			if(strtoupper($xmlObj->roottag->tags[0]->tags[0]->name == 'INF')){	
				foreach($xmlObj->roottag->tags[0]->tags as $infoRecarga){
					$aux_dtrecarga = $infoRecarga->tags[0]->cdata; // Transação
					$aux_hrtransa = $infoRecarga->tags[1]->cdata; // Hora
					$aux_vlrecarga = $infoRecarga->tags[2]->cdata; // Valor
					$aux_nrtelefo = $infoRecarga->tags[3]->cdata; // Telefone
					$aux_nmoperadora = $infoRecarga->tags[4]->cdata; // Operadora
					$aux_nsuoperadora = $infoRecarga->tags[5]->cdata; // NSU Operadora
                    $aux_idoperacao = $infoRecarga->tags[6]->cdata; // Operadora
					?>
					<tr>
                        <input type="hidden" id="idoperacao" value="<? echo $aux_idoperacao ?>"/>
						<td id="dtrecarga" ><span><? echo $aux_dtrecarga ?></span><? echo $aux_dtrecarga ?></td>
						<td id="hrtransa" ><span><? echo $aux_hrtransa ?></span><? echo $aux_hrtransa ?></td>
						<td id="vlrecarga" ><span><? echo $aux_vlrecarga ?></span><? echo $aux_vlrecarga ?></td>
						<td id="nrtelefo" ><span><? echo $aux_nrtelefo ?></span><? echo $aux_nrtelefo ?></td>
						<td id="nmoperadora" ><span><? echo $aux_nmoperadora ?></span><? echo $aux_nmoperadora ?></td>
						<td id="nsuoperadora" ><span><? echo $aux_nsuoperadora ?></span><? echo $aux_nsuoperadora ?></td>
					</tr>
					<?
				}		
			}?>                
		</tbody>
	</table>
</div>						
<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?
					//
					if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
					
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
						?> <a class='paginacaoAnt'><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				<?
					if (isset($nriniseq)) { 
						?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
					}
				?>
			</td>
			<td>
				<?
					// Se a paginação não está na &uacute;ltima página, exibe botão proximo
					if ($qtregist > ($nriniseq + $nrregist - 1)) {
						?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
					} else {
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>
</div>


<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        buscaRecargas(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        buscaRecargas(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>
