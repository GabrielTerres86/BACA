<?php
/*!
 * FONTE        : ldesco.php                        Última alteração: 
 * CRIAÇÃO      : Otto - RKAM
 * DATA CRIAÇÃO : 17/11/2016
 * OBJETIVO     : Mostrar tela LDESCO
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

    require_once("../../includes/carrega_permissoes.php");


    $cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
    $cdcodigo = (isset($_POST["cdcodigo"])) ? $_POST["cdcodigo"] : '';
    
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
    $xml       .= " </Dados>";
    $xml       .= "</Root>";
    
    // Executa script para envio do XML 
    $xmlResult = mensageria($xml, "TELA_LROTAT", "CONSULTALROTAT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjMotivos = getObjectXML($xmlResult);
    
    

    // Se ocorrer um erro, mostra crítica
    if($cddopcao == "A") {
        if (strtoupper($xmlObjMotivos->roottag->tags[0]->name) == "ERRO") {
        
            $msgErro = $xmlObjMotivos->roottag->tags[0]->tags[0]->tags[4]->cdata;
            exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLdesco\').click();',false);     
                        
        } 
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

    $('input,select','#frmLrotat').habilitaCampo();

    $('#descricao','#frmLrotat').val('<?echo getByTagName($linhas->tags,'dsdlinha'); ?>');
    $('#situacao','#frmLrotat').val('<?echo (getByTagName($linhas->tags,'dssitlcr')) ? getByTagName($linhas->tags,'dssitlcr') : 'LIBERADA'; ?>').desabilitaCampo();
    $('#tlimite','#frmLrotat').val('<?echo getByTagName($linhas->tags,'tpdlinha'); ?>');

    $('#QtxCapOp','#frmLrotat').val('<?echo getByTagName($linhas->tags,'qtvezcap'); ?>').addClass('porcento_7').attr('maxlength','3');
    $('#QtxCapCe','#frmLrotat').val('<?echo getByTagName($linhas->tags,'qtvcapce'); ?>').addClass('porcento_7').attr('maxlength','3');
    $('#qtdiavig','#frmLrotat').val('<?echo getByTagName($linhas->tags,'qtdiavig'); ?>').addClass('porcento_7').attr('maxlength','3');


    $('#DVcontOp','#frmLrotat').val('<?echo getByTagName($linhas->tags,'vllimmax'); ?>').addClass('porcento_7');
    $('#DVcontCe','#frmLrotat').val('<?echo getByTagName($linhas->tags,'vllmaxce'); ?>').addClass('porcento_7');

    $('#Tfixa','#frmLrotat').val('<?echo getByTagName($linhas->tags,'txjurfix'); ?>').addClass('porcento_7').attr('maxlength','3');
    $('#Tvar','#frmLrotat').val('<?echo getByTagName($linhas->tags,'txjurvar'); ?>').addClass('porcento_7').attr('maxlength','3');
    $('#Tmensal','#frmLrotat').val('<?echo getByTagName($linhas->tags,'txmensal'); ?>').addClass('porcento_7').attr('maxlength','3');

    $('#dsencfin1','#frmLrotat').val('<?echo getByTagName($linhas->tags,'dsencfin1'); ?>').attr('maxlength','25');
    $('#dsencfin2','#frmLrotat').val('<?echo getByTagName($linhas->tags,'dsencfin2'); ?>').attr('maxlength','25');
    $('#dsencfin3','#frmLrotat').val('<?echo getByTagName($linhas->tags,'dsencfin3'); ?>').attr('maxlength','25');

    trocaBotao('alteraLinhaDescontoDo()','btnVoltar(2)');
    $('#frmLrotat').css('display','block');
    
</script>
