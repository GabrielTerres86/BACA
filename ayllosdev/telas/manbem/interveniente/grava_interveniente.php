<?
/*!
 * FONTE        : valida_interveniente.php
 * CRIAÇÃO      : Maykon D. Granemann (Envolti)
 * DATA CRIAÇÃO : 16/08/2018
 * OBJETIVO     : Rotina para validar os dados para cadastro de interveniente.
 * --------------
 * ALTERAÇÕES   :
 * --------------
 *   
 */
?>
<?
    include('../includes/requires.php');

    $nomeTela = "TELA_MANBEM";
    $nomeFuncaoBanco ="CRIA_INTERVENIENTE";
    $parametrosRequisicao = array(
                                    'nrdconta', 'nrctremp', 'tpctrato', 'nrcpfcgc', 'nmdavali', 'nrcpfcjg', 
                                    'nmconjug', 'tpdoccjg', 'nrdoccjg', 'tpdocava', 'nrdocava', 'dsendre1',
                                    'dsendre2', 'nrfonres', 'dsdemail', 'nmcidade', 'cdufresd', 'nrcepend',
                                    'cdnacion', 'nrendere', 'complend', 'nrcxapst'
                                );
    $tagPrincipal = "Dados";

    try{
        $tagEncontrada = executa();
        if($tagEncontrada)
        {
            $msgSuccess  = "Interveniente Cadastrado com sucesso!";
            echo respostaJson(1,$msgSuccess, 0);                
        }
    }
    catch(Exception $ex)
    {
        echo respostaJson(2,$ex->getMessage(), -1);
    }       
?>