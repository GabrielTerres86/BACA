<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 05/05/2016
 * OBJETIVO     : Rotina para buscar os riscos
 */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');
    isPostMethod();		

    // Guardo os parâmetos do POST em variáveis	
    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
    $innivris = (isset($_POST['innivris'])) ? $_POST['innivris'] : 2; // Default: A

    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdnivel_risco>".$innivris."</cdnivel_risco>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_CADRIS", "BUSCA_RISCO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObject->roottag->tags[0]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial()');
    }

    $registros = $xmlObject->roottag->tags[0]->tags;
?>
<div class="divRegistros">
    <table>
        <thead>
            <tr>
                <?php
                    // Se for exclusao exibe checkbox
                    if ($cddopcao == 'E') {
                        ?><th><input type="checkbox" id="select_all"/></th><?php
                    }
                ?>
                <th>Conta</th>
                <th>Nome</th>
            </tr>
        </thead>
        <tbody>
        <?php
            foreach ($registros as $reg) {
                $nrdconta = getByTagName($reg->tags,'NRDCONTA');
                $nmprimtl = getByTagName($reg->tags,'NMPRIMTL');
                $dsjustif = getByTagName($reg->tags,'DSJUSTIFICATIVA');
                ?>
                <tr>
                    <?php
                        // Se for exclusao exibe checkbox
                        if ($cddopcao == 'E') {
                            ?><td><input type="checkbox" class="clsCheckbox" value="<?php echo $nrdconta; ?>" /></td><?php
                        // Se for consulta
                        } else if ($cddopcao == 'C') {
                            ?><input type="hidden" id="hdn_dsjustif" value="<?php echo $dsjustif; ?>" /><?php
                        }
                    ?>
                    <td><?php echo $nrdconta; ?></td>
                    <td><?php echo $nmprimtl; ?></td>
                </tr>
                <?php
            }
        ?>
        </tbody>
    </table>
</div>