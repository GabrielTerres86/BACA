<?php
/*!
 * FONTE        : ldesco.php                        Última alteração: 11/10/2017
 * CRIAÇÃO      : Otto - RKAM
 * DATA CRIAÇÃO : 17/11/2016
 * OBJETIVO     : Mostrar tela LDESCO
 * --------------
 * ALTERAÇÕES   :  11/10/2017 - Inclusao dos campos Modelo e % Mínimo Garantia. (Lombardi - PRJ404)
 * --------------
 */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    require_once("../../includes/carrega_permissoes.php");


    $cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
    $cdcodigo = (isset($_POST["cdcodigo"])) ? $_POST["cdcodigo"] : '';
    $tdesconto = (isset($_POST["tdesconto"])) ? $_POST["tdesconto"] : '';
    
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {     
    
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }
    
    validaDados();

    // Monta o xml de requisição        
    $xml        = "";
    $xml       .= "<Root>";
    $xml       .= " <Dados>";
    $xml       .= "     <cddopcao>".$cddopcao."</cddopcao>";    
    $xml       .= "     <cddlinha>".$cdcodigo."</cddlinha>";    
    $xml       .= "     <tpdescto>".$tdesconto."</tpdescto>";       
    $xml       .= " </Dados>";
    $xml       .= "</Root>";
    
    // Executa script para envio do XML 
    $xmlResult = mensageria($xml, "TELA_LDESCO", "LDESCO_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjMotivos = getObjectXML($xmlResult);
    
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObjMotivos->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObjMotivos->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btnVoltar\',\'#divBotoesFiltroLdesco\').click();',false);     
                    
    } 
        
    $linhas   = $xmlObjMotivos->roottag->tags[0]->tags[0];


    function validaDados(){
        
        //Codigo
        if ( $GLOBALS["cdcodigo"] == 0){ 
            exibirErro('error','Código inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLdesco\').focus();',false);
        }
    
    }

?> 




<script type="text/javascript">
    
    $('#descricao','#frmLdesco').val('<?echo getByTagName($linhas->tags,'DSDLINHA'); ?>');
    $('#taxamora','#frmLdesco').val('<?echo getByTagName($linhas->tags,'TXJURMOR'); ?>');
    $('#taxamensal','#frmLdesco').val('<?echo getByTagName($linhas->tags,'TXMENSAL'); ?>');
    $('#tpctrato','#frmLdesco').val('<?echo getByTagName($linhas->tags,'TPCTRATO'); ?>');
    $('#taxadiaria','#frmLdesco').val('<?echo getByTagName($linhas->tags,'TXDIARIA'); ?>');
    $('#qtvias','#frmLdesco').val('<?echo getByTagName($linhas->tags,'NRDEVIAS'); ?>');
    $('#tarifa','#frmLdesco').val('<?echo getByTagName($linhas->tags,'FLGTARIF')?>');
    $('#permingr','#frmLdesco').val('<?echo getByTagName($linhas->tags,'PERMINGR')?>');
    $('#situacao','#frmLdesco').val('<?echo getByTagName($linhas->tags,'DSSITLCR'); ?>');

    formataLinhaDesconto();
    
	if('<?echo $cddopcao;?>' == 'L' || '<?echo $cddopcao;?>' == 'B'){
		
		$('#frmLdesco').show();
	    trocaBotao('showConfirmacao(\'Deseja prosseguir com a opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'bloqlibLinhaDesconto();\',\'\',\'sim.gif\',\'nao.gif\')','btnVoltar(2)');
		
	}else{
		removeProsseguir('btnVoltar(2); return false;');

		if($('#descricao','#frmLdesco').val()) {
			$('#frmLdesco').show();
		}
		$('#btVoltar', '#divBotoesFiltroLdesco').focus();
	}
	
</script>