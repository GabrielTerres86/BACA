/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package mergepdf;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import org.apache.pdfbox.io.MemoryUsageSetting;
import org.apache.pdfbox.multipdf.PDFMergerUtility;

/**
 *
 * @author tech.luana
 */
public class MergePDF {

    /**
     * @param args 
     * pasta de origem dos PDFs, 
     * nome dos PDFs à serem concatenados, em ordem de concatenação
     * caminho completo do arquivo final (com nome do arquivo)
     */
    public static void main(String[] args) throws Exception{
        if(null == args || args.length <= 0){
            throw new Exception("NOK: Parâmetros não informados");
        }else{
            String pasta = args[0];
            String docs = args[1];
            String caminhoFinal = args[2];
            validarParametrosInformados(pasta, docs, caminhoFinal);
            
            File pastaDocs = new File(pasta);
            File caminhoFinalDocs = new File(caminhoFinal);
            validarDiretoriosInformadosExistem(pastaDocs, caminhoFinalDocs);
            String[] nomeDocs = docs.split(";");
            mergeDocumentos(pastaDocs, nomeDocs, caminhoFinalDocs);
            System.out.println("OK: Merge efetuado com sucesso. Destino: "+caminhoFinal);
        }
    }
    
    public static void mergeDocumentos(File pasta, String[] nomesDoc, File caminhoDestino) throws Exception{
        FileOutputStream fileOutputStream = null;
        try{
            PDFMergerUtility ut = new PDFMergerUtility();
            for(int i = 0; i < nomesDoc.length; i++){
                if(null != nomesDoc[i] && !"".equals(nomesDoc[i])){
                    ut.addSource(new File(pasta, nomesDoc[i]));
                }
            }
            fileOutputStream = new FileOutputStream(caminhoDestino);
            ut.setDestinationStream(fileOutputStream);
            ut.mergeDocuments(MemoryUsageSetting.setupTempFileOnly());
        }
        catch(IOException e){
            throw new Exception("NOK: Não foi possível efetuar o merge dos arquivos solicitados. Causa: "+e.getMessage());
        }finally{
            if(null != fileOutputStream){
                try{
                    fileOutputStream.close();
                }
                catch(IOException e){
                    throw new Exception("NOK: Não foi possível finalizar o merge. Causa: "+e.getMessage());
                }
            }
        }
    }
    
    public static void validarParametrosInformados(String pasta, String docs, String caminhoFinal) throws Exception{
        if(null == pasta || "".equals(pasta.trim())){
            throw new Exception("NOK: Pasta dos documentos em branco ou não informada");
        }
        if(null == docs || "".equals(docs.trim())){
            throw new Exception("NOK: Documentos em branco ou não informados");
        }
        if(null == caminhoFinal || "".equals(caminhoFinal.trim())){
            throw new Exception("NOK: Caminho final dos documentos em branco ou não informado");
        }
    }
    
    public static void validarDiretoriosInformadosExistem(File pasta, File caminhoFinal) throws Exception{
        if(!pasta.exists()){
            throw new Exception("NOK: Pasta dos documentos informada não foi encontrada");
        }
        if(!(caminhoFinal.getParentFile()).exists()){
            throw new Exception("NOK: Caminho final dos documentos informado não foi encontrado");
        }
    }
}
