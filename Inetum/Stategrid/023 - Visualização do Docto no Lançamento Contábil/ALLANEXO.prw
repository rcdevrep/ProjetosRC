#INCLUDE "TOTVS.CH"
#include "protheus.ch"
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "FWMVCDef.ch"
#INCLUDE "Jpeg.CH"
#INCLUDE "topconn.ch" 

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Data      |     Autor       |       Descrição
 2024/07/01   | Jader Berto     | Utilizado ponto de entrada que usuario filtra a tabela CT2 na mBrowse
                                   para incluir opção de menu na rotina CTBA101
								   Com objetivo de buscar anexo(s) relacionado à origem do lançamento contábil
 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

User Function ALLANEXO()
Local   aFileNF   := {}
Local   nFile     := 0
Local   aFold     := {}
Local   nFold     := 1
Local   _cDoc     := ""
Local   _cPrefix  := ""
Local   _cTipo    := ""
Local   _cTipDoc  := ""
Local   _cCliente := ""
Local   _cLoja    := ""
Local   _aTipArq  := {"nf","fin","finm","finr","spg"}
Local   nTip
Private aCabec    := {}
Private aFiles    := {}
Private cCadastro := "Visualização de Documentos"


    If CT2->CT2_LP $ GetMV("MV_XLPANX1")
        _cDoc := 	_cDoc := SUBSTR(CT2->CT2_KEY,8,9)
    ElseIf CT2->CT2_LP $ GetMV("MV_XLPANX2")
        _cDoc := SUBSTR(CT2->CT2_KEY,5,9)
    ElseIf CT2->CT2_LP $ GetMV("MV_XLPANX3")
        _cDoc := SUBSTR(CT2->CT2_KEY,10,9)
	Else
		_cDoc := SUBSTR(CT2->CT2_KEY,5,9)
    EndIf

	_cTipDoc := SUBSTR(CT2->CT2_KEY, 5, 2) 
	_cPrefix := SUBSTR(CT2->CT2_KEY, 7, 3)
	_cTipo   := SUBSTR(CT2->CT2_KEY, 21, 2)                   
	_cCliente:= SUBSTR(CT2->CT2_KEY, 32, 6)   
	_cLoja   := SUBSTR(CT2->CT2_KEY, 38, 2) 



	//--LINHA 1 - TITULO DO TCBROWSE/PLANILA EXCEL
	//--LINHA 2 - LARGURA DA COLUNA DO TCBROWSE
	//--LINHA 3 - 1=CARACTER			2=NUMERO	3=VALOR MONET.		4=DATA

    
    aCabec := {{"Diretorio","Documento" , "Data", "Hora"},;	//CABECALHO
                {255       ,255         , 10    , 10},;	//TAMANHO
                {1	       ,1           ,4      , 1}}							


    For nTip := 1 to Len(_aTipArq)

        //Busca arquivos NF
        aFileNF := Directory("\totvs_anexos\"+cEmpAnt+"\"+CT2->CT2_FILORIG+"\"+_aTipArq[nTip]+"\*.*", "D")
        nFile := 1
		For nFile := 1 to Len(aFileNF)
            If (STRZERO(val(_cDoc),6)+' ' $ aFileNF[nFile][1]) //.OR. aFileNF[nFile][1] $ _cDoc
                aFold := Directory("\totvs_anexos\"+cEmpAnt+"\"+CT2->CT2_FILORIG+"\"+_aTipArq[nTip]+"\"+aFileNF[nFile][1]+"\*.*")
                nFold := 1
				For nFold := 1 to Len(aFold)
                    AADD(aFiles, {"\totvs_anexos\"+cEmpAnt+"\"+CT2->CT2_FILORIG+"\"+_aTipArq[nTip]+"\"+aFileNF[nFile][1]+"\",Alltrim(aFold[nFold][1]), aFold[nFold][3], aFold[nFold][4]})
                Next nFold
                aFold := {}
                
            Endif
        Next nFile
		nFile := 1
    
    Next nTip



    /*
    aFiles := Directory("\totvs_anexos\"+cEmpAnt+"\"+cFilAnt+"\FIN\")
    aFiles := Directory("\totvs_anexos\"+cEmpAnt+"\"+cFilAnt+"\NF\")
    */
    If Len(aFiles) > 0
		LjMsgRun("Gerando interface visual...",,{|| fREL(cCadastro, aCabec, aFiles)})
	Else
		 Help(NIL, NIL, "Registros não encontrados", NIL, "Não foram encontrados registros na base de dados.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique os dados para serem exibidos."})
	EndIf

return 


Static function fREL( cTit , aCabec , aValores )
	Local i, j
	Local xTipo
	Local xTam
	Local xDec
	Private oBrowse
	Private aRotina		:= MenuDef()
	Private aCampos		:= {}
	Private aSeek 		:= {}
	Private aDados 		:= aValores
	Private aFieFilter 	:= {}

	
	cCadastro 	:= cTit
	
	For i:= 1 to Len(aCabec[1])
		xTipo := VALTYPE(aDados[1][i])
		If xTipo == "C"
			xTam := aCabec[2][i]
			xDec := 0
		ElseIf xTipo == "N"
			xTam := 14
			xDec := 2
		ElseIf xTipo == "D"
			xTam := 8
			xDec := 0
		ElseIf xTipo == "L"
			xTam := 3
			xDec := 0
		EndIf
		AAdd(aCampos,{"CAMPO"+cValtoChar(i)  	, xTipo , xTam , xDec})
	Next
	

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf

	oTempTable := FWTemporaryTable():New("TRB")
	oTempTable:SetFields( aCampos )
	oTempTable:Create()


	For i:= 1 to len(aDados)
		If RecLock("TRB",.t.)
			For j:= 1 to Len(aCabec[1])
				&("TRB->CAMPO"+cValtoChar(j))    := aDados[i,j]
			Next j
			j:= 1
			MsUnLock()
		Endif
	Next i
	dbSelectArea("TRB")
	TRB->(DbGoTop())
 
	
	//Campos que irão compor a tela de filtro

	For j:= 1 to Len(aCabec[1])
		xTipo := VALTYPE(aDados[1][j])
		If xTipo == "C"
			xTam := len(aDados[1][j])
			xDec := 0
		ElseIf xTipo == "N"
			xTam := 14
			xDec := 2
		ElseIf xTipo == "D"
			xTam := 8
			xDec := 0
		ElseIf xTipo == "L"
			xTam := 3
			xDec := 0
		EndIf
		Aadd(aFieFilter,{"CAMPO"+cValtoChar(j)	, aCabec[1][j]   , xTipo, xTam, xDec,"@!"})
	Next j
	
	oBrowse:= FWMarkBrowse():New()
	oBrowse:SetAlias( "TRB" )
	oBrowse:SetDescription( cCadastro )
	//oBrowse:SetSeek(.T.,aSeek)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetLocate()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padrão >>> "TR_ST == 'A'"
	oBrowse:SetFieldFilter(aFieFilter)
	oBrowse:DisableDetails()

	
	//Detalhes das colunas que serão exibidas
	For j:= 1 to Len(aCabec[1])
		If !(aCabec[1][j] $ "TR_OK|REC")
			xTipo := VALTYPE(aDados[1][j])
			If xTipo == "C"
				xTam := len(aDados[1][j])
				xDec := 0
			ElseIf xTipo == "N"
				xTam := 14
				xDec := 2
			ElseIf xTipo == "D"
				xTam := 8
				xDec := 0
			ElseIf xTipo == "L"
				xTam := 3
				xDec := 0
			EndIf
			oBrowse:SetColumns(MontaColunas("CAMPO"+cValtoChar(j)	,aCabec[1][j]		,01,"@!",0,xTam,xDec))
		EndIf
	Next j

	oBrowse:Activate()
	/*
	If !Empty(cArqTrb)
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())
		cArqTrb := ""
		TRB->(DbCloseArea())
		delTabTmp('TRB')
    	dbClearAll()
	Endif
	*/
    	
return(Nil)

Static Function MCFG6Invert(cMarca,lMarcar)
    Local cAliasX := "TRB"
    Local aAreaSD1 := (cAliasX)->( GetArea() )
    dbSelectArea(cAliasX)
    (cAliasX)->( dbGoTop() )
    While !(cAliasX)->( Eof() )
        RecLock( (cAliasX), .F. )
        (cAliasX)->CAMPO1 := IIf( lMarcar, cMarca, " " )
        MsUnlock()
        (cAliasX)->( dbSkip() )
    EndDo
    RestArea( aAreaSD1 )
Return .T.
 
Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0
	
	
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}
 
Static Function MenuDef()
	Local aArea		:= GetArea()
	Local aRotina1 := {}
    
	AADD(aRotina1, {"ABRIR", 'U_RELOPEN()',0,6,0,Nil})

		
	RestArea(aArea)
Return( aRotina1 )





*------------------------*     
User Function RELOPEN()
*------------------------*
Local cTemp	  := GetTempPath()

	__CopyFile(Alltrim(TRB->CAMPO1)+Alltrim(TRB->CAMPO2), cTemp+Alltrim(TRB->CAMPO2))
    shellExecute("Open", cTemp+Alltrim(TRB->CAMPO2)," /k dir" , "C:\", 1 )

Return     
