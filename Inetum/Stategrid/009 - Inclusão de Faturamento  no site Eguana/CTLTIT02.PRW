#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "FWPrintSetup.ch"
#Include "RPTDEF.CH" 
#INCLUDE "FILEIO.CH"
#INCLUDE "COLORS.CH"  
#Include "TOTVS.CH" 


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTLTIT02

Rotina para gerar XML da Nota Fiscal para enviar para o  Eguana via NFESEFAZ

@author    Jader Berto
@version   1
@since    06/08/2024
/*/
//------------------------------------------------------------------------------------------


User Function CTLTIT02()
Local cSerie    := PARAMIXB[1]    
Local cNota     := PARAMIXB[2]
Private aAnexo  := {}
Private cArqXML	:= ""
Private cPathXML:= "\cci_xml"



	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))


	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))

	If SA1->(DbSeek(xFilial("SA1") + SF2->(F2_CLIENTE+F2_LOJA)))

        If SE1->(DbSeek(xFilial("SE1") + SF2->F2_SERIE+SF2->F2_DOC))
	        U_zGerXML(cNota, cSerie, cPathXML)

            IF EXISTBLOCK("CTLTIT01")
                EXECBLOCK("CTLTIT01",.F.,.F.)
            ENDIF
        Else
            Help(" ",1,"NOMOVADT",,"Título financeiro não encontrado.")
        EndIf

    Else
        	Help(" ",1,"NOMOVADT",,"Cliente não identificado.")
            Return 
    EndIf



   	
Return


User Function zGerXML(cNota, cSerie, cPathXML)
    Local aArea     := GetArea()
    Local cIdent    := ""
    Local cArquivo  := ""
    Private PixelX
    Private PixelY
    Private nConsNeg
    Private nConsTex
    Private oRetNF
    Private nColAux
    Default cNota   := ""
    Default cSerie  := ""
       
    //Se existir nota
    If ! Empty(cNota)
        //Pega o IDENT da empresa
        cIdent := RetIdEnti()
           
      If !ExistDir(cPathXML)
            MakeDir(cPathXML)
        EndIf        
        cPathXML += '\'+ Alltrim(Replace(Replace(Replace(SA1->A1_CGC,'.',''),'-',''),'/',''))
        If !ExistDir(cPathXML)
            MakeDir(cPathXML)
        EndIf
        cPathXML += '\'+ Alltrim(SE1->E1_CLIENTE)+ Alltrim(SE1->E1_LOJA)
        If !ExistDir(cPathXML)
            MakeDir(cPathXML)
        EndIf
        cPathXML += '\'+ Year2Str(SE1->E1_EMISSAO)
        If !ExistDir(cPathXML)
            MakeDir(cPathXML)
        EndIf      
        cPathXML += '\'+ Month2Str(SE1->E1_EMISSAO)
        If !ExistDir(cPathXML)
            MakeDir(cPathXML)
        EndIf 
           
        //Gera o XML da Nota
        cArquivo := "nf_"+Alltrim(SE1->E1_FILIAL) + Alltrim(SE1->E1_PREFIXO) + Alltrim(SE1->E1_NUM) + Alltrim(SE1->E1_PARCELA) 
        zSpdXML(cNota, cSerie, cPathXML + '\' + cArquivo  + ".xml", .F.)
    EndIf
       
    RestArea(aArea)
Return

Static Function zSpdXML(cDocumento, cSerie, cArqXML, lMostra)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cIdEnt       := RetIdEnti()
    Local cTextoXML    := ""
    Local oFileXML
    Default cDocumento := ""
    Default cSerie     := ""
    Default cArqXML    := GetTempPath()+"arquivo_"+cSerie+cDocumento+".xml"
    Default lMostra    := .F.
        
    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
            
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"
            
        //Se tiver notas
        If oWebServ:RetornaNotas()
            
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
                
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                        
                //Senão, pega o xml normal (foi alterado abaixo conforme dica do Jorge Alberto)
                Else
                    cTextoXML := '<?xml version="1.0" encoding="UTF-8"?>'
                    cTextoXML += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT
                    cTextoXML += '</nfeProc>'
                EndIf
                    
                //Gera o arquivo
                oFileXML := FWFileWriter():New(cArqXML, .T.)
                oFileXML:SetEncodeUTF8(.T.)
                oFileXML:Create()
                oFileXML:Write(cTextoXML)
                oFileXML:Close()
                    
                //Se for para mostrar, será mostrado um aviso com o conteúdo
                If lMostra
                    Aviso("zSpdXML", cTextoXML, {"Ok"}, 3)
                EndIf
                    
            //Caso não encontre as notas, mostra mensagem
            Else
                ConOut("zSpdXML > Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...")
                    
                If lMostra
                    Aviso("zSpdXML", "Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
            
        //Senão, houve erros na classe
        Else
            ConOut("zSpdXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
                
            If lMostra
                Aviso("zSpdXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return
