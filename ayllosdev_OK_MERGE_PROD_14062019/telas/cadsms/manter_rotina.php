<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/10/2016
 * OBJETIVO     : Rotina para controlar as operações da tela CADSMS
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();


// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$cdcoptel = (isset($_POST['cdcoptel'])) ? $_POST['cdcoptel'] : 0;
$flofesms = (isset($_POST['flofesms'])) ? $_POST['flofesms'] : 0;
$flgenvia_sms = (isset($_POST['flgenvia_sms'])) ? $_POST['flgenvia_sms'] : 0;
$dtiniofe = (isset($_POST['dtiniofe'])) ? $_POST['dtiniofe'] : '';
$dtfimofe = (isset($_POST['dtfimofe'])) ? $_POST['dtfimofe'] : '';
$dsmensag = (isset($_POST['dsmensag'])) ? $_POST['dsmensag'] : '';
$fllindig = (isset($_POST['fllindig'])) ? $_POST['fllindig'] : 0;
$nrdialau = (isset($_POST['nrdialau'])) ? $_POST['nrdialau'] : 0;
$json_mensagens	 = (isset($_POST['json_mensagens']))  ? $_POST['json_mensagens'] : '' ;
$json_lotesReenv = (isset($_POST['json_lotesReenv'])) ? $_POST['json_lotesReenv'] : '' ;


if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	exibeErroNew($msgError);
}

if ( $cddopcao == 'O' or $cddopcao == 'M' or 
     $cddopcao == 'P' or $cddopcao == 'Z') {
         
	$xml = new XmlMensageria();
    $xml->add('cdcoptel',$cdcoptel);
    $xml->add('cddopcao',$cddopcao);

    $xmlResult = mensageria($xml, "CADSMS", "CONSULTAR_CADSMS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErroNew($msgErro);
        exit();
    }
    
    if ($cddopcao == 'O') { 
        $registros = $xmlObj->roottag->tags[0]->tags;
        foreach ($registros as $r) {
            echo '$("#dtiniofe", "#frmOpcaoO").val("' . getByTagName($r->tags, 'dtiniofe') . '");';
            echo '$("#dtfimofe", "#frmOpcaoO").val("' . getByTagName($r->tags, 'dtfimofe') . '");';         
            echo "$('#dsmensag', '#frmOpcaoO').val('".preg_replace('/\r\n|\r|\n/','\n',getByTagName($r->tags,'dsmensag'))."');";        
            
            if (getByTagName($r->tags, 'flofesms') == "1" ) {
                echo 'document.getElementById("flofesms").checked = true;';
            }else{
                echo 'document.getElementById("flofesms").checked = false;';  
            }
            
        }
    }else if ($cddopcao == 'M') { 
      
        $registros = $xmlObj->roottag->tags[0]->tags;
        foreach ($registros as $r) {

            $fllindig	     = getByTagName($r->tags,'flglinha_digitavel') == 1 ? "'checked'" : "null";
            echo "$('#fllindig',   '#frmOpcaoM').attr('checked',$fllindig);";
            
            $htmlmensagens = '';
            $ultimofieldset = '';
            
            // Gera os campos das mensagens
            foreach( $r->tags[1]->tags as $msg ) {
                $cdtipo_mensagem = $msg->attributes['CDTIPO_MENSAGEM'];
                $dscampo = $msg->tags[0]->cdata;
                $dsmensagem = $msg->tags[1]->cdata;
                //Remover quebra de linha, para nao dar erro no javascript
                $dsmensagem = preg_replace('/\r\n|\r|\n/','\n',$dsmensagem);
                
                $dsobservacao = $msg->tags[2]->cdata;
                $fieldset = $msg->tags[3]->cdata;
                $qtmaxcar     = $msg->tags[4]->cdata;
                
                //Verifica se o fieldset alterou (Tag DsAreaTela)
                if ($fieldset != $ultimofieldset) {
                    if ($ultimofieldset != '') //Fecha o fieldset anterior
                        $htmlmensagens .= "</fieldset>";
                    
                    $htmlmensagens .= "<br/><fieldset><legend>".htmlentities($fieldset)."</legend><br/>";
                    $ultimofieldset = $fieldset;
                }
                else {
                    $htmlmensagens .= "<br/>";
                }
                
                //Imprime o campo
                $htmlmensagens .= "<fieldset style=\"margin-left:20px; margin-top:10px;width: 95%\"><legend>".htmlentities($dscampo)."</legend>";
                $htmlmensagens .= "<textarea id=\"mensagem$cdtipo_mensagem\" name=\"mensagem$cdtipo_mensagem\" cdtipo_mensagem=\"$cdtipo_mensagem\" maxlength=\"$qtmaxcar\">".htmlentities($dsmensagem)."</textarea>";
                $htmlmensagens .= "<br/>";
                if ($dsobservacao) // Imprime a observação apenas se tiver
                    $htmlmensagens .= "<span style=\"margin-left:10px\" >Obs.:".$dsobservacao."</span>";
                $htmlmensagens .= "</fieldset>";
            }
            
            $htmlmensagens .= "</fieldset><br/>";
        }
        echo "$('#divMensagens').html('$htmlmensagens');";
        
        return false;
        
    }else if ($cddopcao == 'P') { 
      
        $registros = $xmlObj->roottag->tags[0]->tags;
        foreach ($registros as $r) {

            $nrdialau	     = getByTagName($r->tags,'nrdiaslautom');
            echo "$('#nrdialau',   '#frmOpcaoP').val($nrdialau);";
            
            $htmlmensagens = '';
            $ultimofieldset = '';
            
            // Gera os campos das mensagens
            foreach( $r->tags[1]->tags as $msg ) {
                $cdtipo_mensagem = $msg->attributes['CDTIPO_MENSAGEM'];
                $dscampo         = $msg->tags[0]->cdata;
                $dsmensagem      = $msg->tags[1]->cdata;
                //Remover quebra de linha, para nao dar erro no javascript
                $dsmensagem      = preg_replace('/\r\n|\r|\n/','\n',$dsmensagem);
                $dsobservacao    = $msg->tags[2]->cdata;
                $fieldset        = $msg->tags[3]->cdata;
                
                //Verifica se o fieldset alterou (Tag DsAreaTela)
                if ($fieldset != $ultimofieldset) {
                    if ($ultimofieldset != '') //Fecha o fieldset anterior
                        $htmlmensagens .= "</fieldset>";
                    
                    $htmlmensagens .= "<br/><fieldset><legend>".htmlentities($fieldset)."</legend><br/>";
                    $ultimofieldset = $fieldset;
                }
                else {
                    $htmlmensagens .= "<br/>";
                }
                
                //Imprime o campo
                $htmlmensagens .= "<fieldset style=\"margin-left:20px; margin-top:10px;width: 95%\"><legend>".htmlentities($dscampo)."</legend>";
                $htmlmensagens .= "<textarea id=\"mensagem$cdtipo_mensagem\" name=\"mensagem$cdtipo_mensagem\" cdtipo_mensagem=\"$cdtipo_mensagem\">".htmlentities($dsmensagem)."</textarea>";
                $htmlmensagens .= "<br/>";
                if ($dsobservacao) // Imprime a observação apenas se tiver
                    $htmlmensagens .= "<span style=\"margin-left:10px\" >Obs.:".htmlentities($dsobservacao)."</span>";
                $htmlmensagens .= "</fieldset>";
            }
            
            $htmlmensagens .= "</fieldset><br/>";
        }
        echo "$('#divMensagensP').html('$htmlmensagens');";
        
        return false;
        
    }else if ($cddopcao == 'Z') { 
        $htmlmensagens = '';       
        echo "$('#divLotes').html('<div class=\"divRegistros\"></div>'); ";
      
        $htmlmensagens .='<table><thead>';
        $htmlmensagens .='<tr>';
        $htmlmensagens .='   <th>Reenviar</th>';
        $htmlmensagens .='   <th>Cooperativa</th>';
        $htmlmensagens .='   <th>Data e hora</th>';
        $htmlmensagens .='</tr> </thead><tbody>';
        $i = 1;
        
        $registros = $xmlObj->roottag->tags[0]->tags;
        foreach ($registros as $r) {
            // Listar Lotes
            foreach( $r->tags[0]->tags as $lote ) {
                
                $idlote_sms     = $lote->tags[0]->cdata;
                $dhretorno      = $lote->tags[1]->cdata;
                $dsagrupador    = $lote->tags[2]->cdata;
                $i++;
                
                $htmlmensagens .= "<tr>"; // id='loteSMS_$i' 
                $htmlmensagens .= "  <td align=\"center\"> <input type=\"checkbox\" id=\"flreenvi_$idlote_sms\" value=\"$idlote_sms\" style=\"margin-left:30px;\" >";                
                $htmlmensagens .= "  </td>";                
                $htmlmensagens .= "  <td> $dsagrupador </td>";
                $htmlmensagens .= "  <td> $dhretorno </td>";
                $htmlmensagens .= '</tr>';
            
            }    
        }
        $htmlmensagens .= '</tbody></table>';         
        echo "$('div.divRegistros', '#divLotes').html('$htmlmensagens');";    
        return false;
    }
    
}

// Opcao de Gravação
if ( $cddopcao == 'GO' or  // Gravar opcao O
     $cddopcao == 'GM' or  // Gravar opcao M
     $cddopcao == 'GP' or  // Gravar opcao M
     $cddopcao == 'RZ'){   // Reenviar Zendia
          
   
    $xml = new XmlMensageria();
    $xml->add('cdcoptel'       ,$cdcoptel);
    $xml->add('cddopcao'       ,$cddopcao);
    
    if ( $cddopcao == 'GO') {    
        $xml->add('flgenvia_sms'  ,$flgenvia_sms);
        $xml->add('flgoferta_sms' ,$flofesms);
        $xml->add('dtini_oferta'  ,$dtiniofe);
        $xml->add('dtfim_oferta'  ,$dtfimofe);                
        $xml->add('json_mensagens',utf8_decode($json_mensagens));
        $nmdeacao = "ATUALIZAR_SMS_PARAM";
        
    }else if ( $cddopcao == 'GM') {    
        $xml->add('flglinha_digitavel'  ,$fllindig);
        $xml->add('json_mensagens'      ,utf8_decode($json_mensagens));
        $nmdeacao = "ATUALIZAR_OPCAO_M";
        
    }else if ( $cddopcao == 'GP') {            
        $xml->add('nrdiaslautom'  ,$nrdialau);
        $xml->add('json_mensagens'      ,utf8_decode($json_mensagens));
        $nmdeacao = "ATUALIZAR_OPCAO_P";
    }else if ( $cddopcao == 'RZ') {                    
        $xml->add('json_lotesReenv'      ,utf8_decode($json_lotesReenv));
        $nmdeacao = "REENVIAR_LOTE_SMS_COBRAN";
    }

    $xmlResult = mensageria($xml, "CADSMS", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErroNew($msgErro);
        exit();
    }
    
	$dsmensage = $xmlObj->roottag->tags[0]->tags[0]->cdata;
    echo 'showError("inform","'.$dsmensage.'","Notifica&ccedil;&atilde;o - Ayllos","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
    
}   

function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
}