<? 
/*!
 * FONTE        : tab_consulta_opcao_s.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 28/04/2016
 * OBJETIVO     : Formulario que permite pesquisar situação dos convenios
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 
 *
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
    
   
    // Classe para leitura do xml de retorno
    require_once("../../class/xmlfile.php");	
    if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S")) <> "") {
        exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo();',true);
    }
 
    $telcdcop  = $_POST["telcdcop"];
    $nrconven  = $_POST["nrconven"];
    $nrdconta  = $_POST["nrdconta"];
    $cdagenci  = $_POST["cdagenci"];
    $dtinicio  = $_POST["dtinicio"];
    $dtafinal  = $_POST["dtafinal"];
    $insitceb  = $_POST["insitceb"];
    
    $insitceb_atu  = $_POST["insitceb_atu"];
    $cdcooper_atu  = $_POST["cdcooper_atu"];
    $nrdconta_atu  = $_POST["nrdconta_atu"];
    $nrconven_atu  = $_POST["nrconven_atu"];
    $nrcnvceb_atu  = $_POST["nrcnvceb_atu"];
    
    $nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
    $nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;

    // Verificar se deve atualizar tambem o conveniro(aprovacao/reprovacao)
    if ($insitceb_atu != 0 && $insitceb_atu != "" && $insitceb_atu != null ){
	    
		// Validar se usuario possui permissao para Aprovar/Reprovar
		if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
			exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo();',true);
		}

        // Montar o xml de Requisicao
        $xml  = "";
        $xml .= "<Root>";
        $xml .= " <Dados>";	
        $xml .= "   <telcdcop>".$cdcooper_atu."</telcdcop>";
        $xml .= "   <nrconven>".$nrconven_atu."</nrconven>";
        $xml .= "   <nrdconta>".$nrdconta_atu."</nrdconta>";
        $xml .= "   <nrcnvceb>".$nrcnvceb_atu."</nrcnvceb>";
        $xml .= "   <insitceb>".$insitceb_atu."</insitceb>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "COBRAN", "ALTERAR_SIT_CONV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);

        if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
            
            $msgError = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);            
            exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo();',true);
            die;                   
        }else{            
            exibirErro('inform','Convenio atualizado com sucesso.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo();',true);
        }             
    }    
    
        
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
    $xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
    $xml .= "   <nrregist>".$nrregist."</nrregist>";
    
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "COBRAN", "CONSULT_CONV_SIT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
        $msgError = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
        $msgError = str_replace('"','',$msgError);
        $msgError = preg_replace('/\s/',' ',$msgError);
        
        //Se for atualizacao e não encontrou nenhum registro apos a atualizacao
        if ( $insitceb_atu != 0 && $msgError == "Dados nao encontrados!"  ){
            null; // nao apresentar a critica  
        }else {         
            exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));hideMsgAguardo();',true);
        }
    }else{
        
        $registros = $xmlObject->roottag->tags[0]->tags;    
        $qtregist = $xmlObject->roottag->tags[1]->cdata;
    } 
    	
?>

 
<div class='divRegistros'>
    <table>

        <thead>
            <tr>
             <th>Cooperativa           </th>
             <th>PA                    </th>
             <th>Conta/DV              </th>
             <th>Raz&atilde;o Social   </th>
             <th>Conv&ecirc;nio        </th>
             <th>Dt An&aacute;lise     </th>
             <th>Operador              </th>
             <th>Status                </th>                
        </tr>

        </thead>
        <tbody>          
       <?php
        foreach ($registros as $r) {
            $mtdClick = "selecionaConvenio(  '".getByTagName($r->tags, 'cdcooper')."',".
                                            "'".getByTagName($r->tags, 'cdagenci')."',".
                                            "'".getByTagName($r->tags, 'nrdconta')."',".
                                            "'".getByTagName($r->tags, 'nrconven')."',".
                                            "'".getByTagName($r->tags, 'nrcnvceb')."',".
                                            "'".getByTagName($r->tags, 'dhanalis')."',".
                                            "'".getByTagName($r->tags, 'insitceb')."');";             
            ?>

            <tr onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
                <td><?= getByTagName($r->tags, 'nmrescop'); ?></td>
                <td><?= getByTagName($r->tags, 'cdagenci'); ?></td>
                <td><?= getByTagName($r->tags, 'nrdconta'); ?></td>	
                <td><?= getByTagName($r->tags, 'nmprimtl'); ?></td>	
                <td><?= getByTagName($r->tags, 'nrconven'); ?></td>	
                <td><?= getByTagName($r->tags, 'dhanalis'); ?></td>	
                <td><?= getByTagName($r->tags, 'nmoperad'); ?></td>	
                <td><?= getByTagName($r->tags, 'dssitceb'); ?></td>	
            </tr>
        
        <?php } ?>

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
        EfetuaPesquisaOpS(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
    });
    $('a.paginacaoProx').unbind('click').bind('click', function() {
        EfetuaPesquisaOpS(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
    });	
    
    $('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>
