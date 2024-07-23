#INCLUDE "Protheus.ch"

/*/{Protheus.doc} XLS2ARR
Função chamada para realizar a conversão de XLS para um array
@author CesarTH - SLA
@since 09/01/2018
@version 1.0
@param cArqE, characters, nome do arquivo XLS a ser carregado.
@param cOrigemE, characters, local onde está o arquivo XLS.
@param nLinTitE, numeric, quantas linhas de cabeçalho que não serão integradas possui o arquivo.
@param lTela, logical, tela para seleção do arquivo.
@type function
/*/    

User Function XLS2ARR(cArqE,cOrigemE,nLinTitE,lTela)

	Local aRMInfo		:= GetRmtInfo()
	Private cBarra		:= IIf(("LINUX","MAC") $ Upper(aRMInfo[2]),"/","\") // Verifica o uso da barra conforme o SO.
	Private cArq       	:= IIf(ValType(cArqE)=="C",cArqE,"")
	Private cArqMacro  	:= "xls2dbf.xla"
	Private cTemp      	:= GetTempPath() // Coleta o caminho do temp do client.
	Private cSystem    	:= Upper(GetSrvProfString("STARTPATH","")) + IIf(("LINUX","MAC") $ Upper(aRMInfo[2]),"/","\")//Pega o caminho do sistema
	Private cOrigem    	:= If(ValType(cOrigemE)=="C",cOrigemE,"")
	Private nLinTit    	:= If(ValType(nLinTitE)=="N",nLinTitE,0)
	Private aArquivos  	:= {}
	Private aRet       	:= {}
	Default lTela		:= .T.

	cArq       += Space(20-(Len(cArq)))
	cOrigem    += Space(99-(Len(cOrigem)))

	If lTela .Or. Empty(AllTrim(cArq)) .Or. Empty(AllTrim(cOrigem))	
		cPath := cGetFile("Excel(*.xls) |*.xls |" , OEMToANSI("Importação Planilha"), 1, "", .T., GETF_LOCALHARD,.F., .F.)
		cArq := SubStr(cPath,RAt(cBarra,cPath) + 1,(RAt(".",cPath)-RAt(cBarra,cPath)-1))
		cOrigem := Substr(cPath,1,RAt(cBarra,cPath))
	EndIf

	If !Empty(cOrigem + cArq)
		aAdd(aArquivos, cArq)
		IntegraArq()
	Else
		MsgStop(OEMToANSI("Arquivo Inválido!"))
		Return {}
	EndIf

Return aRet

/*/{Protheus.doc} IntegraArq
Faz a chamada das rotinas referentes a integração.
@author CesarTH - SLA
@since 09/01/2018
@version 1.0
@type function
/*/
Static Function IntegraArq()

	Local lConv      := .F.
	//Converte arquivos xls para csv copiando para a pasta temp
	MsAguarde( {|| ConOut("Começou conversão do arquivo "+cArq+ " - "+Time()),;
		lConv := convArqs(aArquivos) }, "Convertendo arquivos", "Convertendo arquivos" )
	
//	lConv := convArqs(aArquivos)
	
	If lConv
   //Carrega do xls no array
		ConOut("Terminou conversão do arquivo "+cArq+ " - "+Time())
		ConOut("Começou carregamento do arquivo "+cArq+ " - "+Time())
		Processa( {|| aRet:= CargaArray(AllTrim(cArq)) } ,"Aguarde, carregando planilha...")
		ConOut("Terminou carregamento do arquivo "+cArq+ " - "+Time())
		
//		aRet:= CargaArray(AllTrim(cArq))
		   
	EndIf

Return

/*/{Protheus.doc} convArqs
Converte os arquivos .xls para .csv
@author CesarTH - SLA
@since 09/01/2018
@version 1.0
@param aArqs, array, arquivos.
@type function
/*/
Static Function convArqs(aArqs)

	Local oExcelApp
	Local cNomeXLS  := ""
	Local cFile     := ""
	Local cExtensao := ""
	Local i         := 1
	Local j         := 1
	Local aExtensao := {}

	cOrigem := AllTrim(cOrigem)

	// Verifica se o caminho termina com "\" ou "/", dependendo do SO.
	If !Right(cOrigem,1) $ (cBarra)
		cOrigem := AllTrim(cOrigem) + cBarra
	EndIf


	// Loop em todos arquivos que serão convertidos.
	For i := 1 To Len(aArqs)

		If !"." $ AllTrim(aArqs[i])
      		// Passa por aqui para verificar se a extensão do arquivo é .xls ou .xlsx
			aExtensao := Directory(cOrigem+AllTrim(aArqs[i])+".*")
			For j := 1 To Len(aExtensao)
				If "XLS" $ Upper(aExtensao[j][1])
					cExtensao := SubStr(aExtensao[j][1],Rat(".",aExtensao[j][1]),Len(aExtensao[j][1]) + 1 - Rat(".",aExtensao[j][1]))
					Exit
				EndIf
			Next j
		EndIf
   		// Recebe o nome do arquivo corrente.
		cNomeXLS := AllTrim(aArqs[i])
		cFile    := cOrigem+cNomeXLS+cExtensao
   
		If !File(cFile)
			MsgInfo(OEMToANSI("O arquivo " + cFile + "não foi encontrado!") ,"Arquivo")
			Return .F.
		EndIf
     
//		Verifica se existe o arquivo na pasta temporaria e apaga.
		If File(cTemp+cNomeXLS+cExtensao)
			fErase(cTemp+cNomeXLS+cExtensao)
		EndIf
   
//		Copia o arquivo XLS para o Temporario para ser executado.
		If !__CopyFile(cFile, cTemp + cNomeXLS + cExtensao)
			MsgStop("Problemas na copia do arquivo " + cFile + " para " + cTemp + cNomeXLS + cExtensao, "FALHA")
			Return .F.
		EndIf
   
//		Apaga macro da pasta temporária se existir.
		If !File(cTemp + cArqMacro)
//			Copia o arquivo XLA para o Temporario para ser executado.
			If !__CopyFile(cSystem + cArqMacro, cTemp + cArqMacro)
				MsgStop("Problemas na copia do arquivo " + cSystem + cArqMacro + "para" + cTemp + cArqMacro, "FALHA")
				Return .F.
			EndIf		
		EndIf

//		Exclui o arquivo antigo (se existir)
		If File(cTemp+cNomeXLS+".csv")
			fErase(cTemp+cNomeXLS+".csv")
		EndIf
   
//		Inicializa o objeto para executar a macro.
		oExcelApp := MsExcel():New()
//		Define qual o caminho da macro a ser executada,
		oExcelApp:WorkBooks:Open(cTemp+cArqMacro)
//		Executa a macro passando como parametro da macro o caminho e o nome do excel corrente.
		oExcelApp:Run(cArqMacro + '!XLS2DBF',cTemp,cNomeXLS)
//		Fecha a macro sem salvar.
		oExcelApp:WorkBooks:Close('savechanges:=False')
//		Sai do arquivo e destrói o objeto.
		oExcelApp:Quit()
		oExcelApp:Destroy()

//		Exclui o Arquivo excel da temp.
		fErase(cTemp + cNomeXLS + cExtensao)
//		Exclui a Macro no diretorio temporario.
		fErase(cTemp + cArqMacro) 
   
	Next i

Return .T.

/*/{Protheus.doc} CargaArray
carrega dados do csv no array pra retorno
@author CesarTH - SLA
@since 09/01/2018
@version 1.0
@param cArq, characters, nome do arquivo que será usado.
@type function
/*/
Static Function CargaArray(cArq)

	Local cLinha  := ""
	Local nLin    := 1
	Local nTotLin := 0
	Local aDados  := {}
	Local cFile   := cTemp + cArq + ".csv"
	Local nHandle := 0


// Abre o arquivo csv gerado na temp
	nHandle := Ft_Fuse(cFile)
	If nHandle == -1
		Return aDados
	EndIf
	Ft_FGoTop()
	nLinTot := FT_FLastRec()-1
	ProcRegua(nLinTot)
// Pula as linhas de cabeçalho
	While nLinTit > 0 .AND. !Ft_FEof()
		Ft_FSkip()
		nLinTit--
	EndDo

// Percorre todas linhas do arquivo csv.
	Do While !Ft_FEof()
// 		Exibe a linha a ser lida.
		IncProc("Carregando Linha "+AllTrim(Str(nLin))+" de "+AllTrim(Str(nLinTot)))
		nLin++
// 		Lê linha.
		cLinha := Ft_FReadLn()
//		Verifica se a linha está em branco, se estiver pula.
		If Empty(AllTrim(StrTran(cLinha,';','')))
			Ft_FSkip()
			Loop
		EndIf
// 		Transforma as aspas duplas em aspas simples.
		cLinha := StrTran(cLinha,'"',"'")
		cLinha := '{"'+cLinha+'"}'
// 		Adiciona o cLinha no array trocando o delimitador ; por , para ser reconhecido como elementos de um array. 
		cLinha := StrTran(cLinha,';','","')
		aAdd(aDados, &cLinha)
   
// 		Passa para a próxima linha.
		FT_FSkip()
   
	EndDo

// Libera o arquivo CSV.
	FT_FUse()
// Exclui o arquivo CSV.
	If File(cFile)
		FErase(cFile)
	EndIf

Return aDados