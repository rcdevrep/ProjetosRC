#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} XAG0125
Emissão de Etiquetas de Volumes / Cliente
@author Leandro Spiller
@since 01/03/2024
@return Nil, Função não tem retorno
@example U_XAG0125()
/*/
User Function XAG0125(xDoc,xSerie)//u_XAG0125('000003267','2')

    Default xDoc   := ""
	Default xSerie := ""

	Local _aImpress := GetImpWindows(.F.)
	Local _I        := 0 
	Local lImpArgox := .F.

	Private oDlgEtiq
	Private oBtCanc
	Private oBtProc

	Private oGetNF
	Private cGetNF := SPACE(TamSX3("F2_DOC")[1])

	Private oGetSerie
	Private cGetSerie := SPACE(TamSX3("F2_SERIE")[1])

	Private oGetVol
	Private cGetVol := SPACE(3)

	Private oSayCli
	Private oSaySerie
	Private oSayEmiss
	Private oSayNF
	Private oSayVol

    Private _cNomeCli := ""
	Private _cEmissao := ""

	//Valida se tem impressora Argox instalada
	For _I := 1 to len(_aImpress)
		If 'ARGOX' $ UPPER(_aImpress[_I])
			lImpArgox := .T. //alert(_aImpress[_I])
		Endif 
	NExt _I 

	if !lImpArgox
		MSGINFO( "Não foi encontrada impressora Argox para geração da Etiqueta")
		Return
	Endif 

	//Se tiver Doc preenchido sugere 
	If alltrim(xDoc) <> "" 
		cGetNF    := xDoc
		cGetSerie := xSerie
        
        //Só posiciona se não tiver vazio 
        If alltrim(cGetNF) <> "" .and. alltrim(cGetSerie) <> ""
           
            Dbselectarea('SF2') 
            //Posiciona caso não esteja
            If SF2->F2_DOC <> cGetNF .OR. alltrim(SF2->F2_SERIE)  <> cGetSerie
                SF2->(Dbsetorder(1))
                DbSeek(xFilial('SF2') + cGetNF +cGetSerie )
            Endif 


            If alltrim(SF2->F2_TIPO) == 'D' //Devolução posiciona Fornecedor
                Dbselectarea('SA2')
                If SA2->A2_COD  <> SF2->F2_CLIENTE .AND. SA2->A2_LOJA <> SF2->F2_LOJA 
                    SA2->(Dbsetorder(1))
                    DbSeek(xFilial('SA2') + SF2->F2_CLIENTE +SF2->F2_LOJA )
                Endif 
                
                If SA2->A2_COD == SF2->F2_CLIENTE .AND. SA2->A2_LOJA == SF2->F2_LOJA
                     _cNomeCli := "Cliente: " + SF2->F2_CLIENTE + "-" + SF2->F2_LOJA + " - " + SA2->A2_NREDUZ
                Else
                    _cNomeCli := ""
                Endif 
               
            Else
                Dbselectarea('SA1')
                If SA1->A1_COD  <> SF2->F2_CLIENTE .OR. SA1->A1_LOJA <> SF2->F2_LOJA 
                    SA1->(Dbsetorder(1))
                    DbSeek(xFilial('SA1') + SF2->F2_CLIENTE +SF2->F2_LOJA )
                Endif 

                If SA1->A1_COD == SF2->F2_CLIENTE .AND. SA1->A1_LOJA == SF2->F2_LOJA 
                    _cNomeCli := "Cliente: " + SF2->F2_CLIENTE + "-" + SF2->F2_LOJA + " - " + SA1->A1_NREDUZ
                Else 
                    _cNomeCli := "" 
                Endif 
             
            Endif 
        Endif 

        _cEmissao := "Emissão: " + DtoC(SF2->F2_EMISSAO)

	Endif 

	DEFINE MSDIALOG oDlgEtiq TITLE "Etiqueta de Volumes/Cliente - Impressora USB001" FROM 000, 000  TO 220, 400 COLORS 0, 16777215 PIXEL

	@ 067, 009 MSGET oGetVol VAR cGetVol SIZE 018, 010 OF oDlgEtiq COLORS 0, 16777215 PIXEL
	@ 059, 009 SAY oSayVol PROMPT "Volumes" SIZE 018, 007 OF oDlgEtiq COLORS 0, 16777215 PIXEL
	@ 010, 009 SAY oSayNF PROMPT "Nota Fiscal" SIZE 031, 007 OF oDlgEtiq COLORS 0, 16777215 PIXEL
	@ 019, 009 MSGET oGetNF VAR cGetNF SIZE 044, 010 OF oDlgEtiq COLORS 0, 16777215 PIXEL
	@ 010, 061 SAY oSaySerie PROMPT "Série" SIZE 018, 007 OF oDlgEtiq COLORS 0, 16777215 PIXEL
	@ 019, 061 MSGET oGetSerie VAR cGetSerie SIZE 018, 010 OF oDlgEtiq VALID CarregNF() COLORS 0, 16777215 PIXEL
	@ 035, 009 SAY oSayCli PROMPT _cNomeCli SIZE 150, 007 OF oDlgEtiq COLORS 0, 16777215 PIXEL
	@ 047, 009 SAY oSayEmiss PROMPT _cEmissao SIZE 150, 007 OF oDlgEtiq COLORS 0, 16777215 PIXEL


	DEFINE SBUTTON oBtProc FROM 083, 009 TYPE 01 OF oDlgEtiq ENABLE ACTION OkProc()
	DEFINE SBUTTON oBtCanc FROM 083, 061 TYPE 02 OF oDlgEtiq ENABLE ACTION OkCanc()

	ACTIVATE MSDIALOG oDlgEtiq CENTERED

Return

Static Function CarregNF()

	//Local _cNomeCli := ""
	//Local _cEmissao := ""
  
    //Só posiciona se não tiver vazio 
    //Só posiciona se não tiver vazio 
    If alltrim(cGetNF) <> "" .and. alltrim(cGetSerie) <> ""
        
        Dbselectarea('SF2') 
        //Posiciona caso não esteja
        If SF2->F2_DOC <> cGetNF .OR. alltrim(SF2->F2_SERIE)  <> cGetSerie
            SF2->(Dbsetorder(1))
            DbSeek(xFilial('SF2') + cGetNF +cGetSerie )
        Endif 


        If alltrim(SF2->F2_TIPO) == 'D' //Devolução posiciona Fornecedor
            Dbselectarea('SA2')
            If SA2->A2_COD  <> SF2->F2_CLIENTE .AND. SA2->A2_LOJA <> SF2->F2_LOJA 
                SA2->(Dbsetorder(1))
                DbSeek(xFilial('SA2') + SF2->F2_CLIENTE +SF2->F2_LOJA )
            Endif 
            
            If SA2->A2_COD == SF2->F2_CLIENTE .AND. SA2->A2_LOJA == SF2->F2_LOJA 
                    _cNomeCli := "Cliente: " + SF2->F2_CLIENTE + "-" + SF2->F2_LOJA + " - " + SA2->A2_NREDUZ
            Else
                _cNomeCli := ""
            Endif 
            
        Else
            Dbselectarea('SA1')
            If SA1->A1_COD  <> SF2->F2_CLIENTE .OR. SA1->A1_LOJA <> SF2->F2_LOJA 
                SA1->(Dbsetorder(1))
                DbSeek(xFilial('SA1') + SF2->F2_CLIENTE +SF2->F2_LOJA )
            Endif 

            If SA1->A1_COD == SF2->F2_CLIENTE .AND. SA1->A1_LOJA == SF2->F2_LOJA
                _cNomeCli := "Cliente: " + SF2->F2_CLIENTE + "-" + SF2->F2_LOJA + " - " + SA1->A1_NREDUZ
            Else 
                _cNomeCli := "" 
            Endif 
            
        Endif 
    Endif 

	_cEmissao := "Emissão: " + DtoC(SF2->F2_EMISSAO)

	oSayCli:SetText(_cNomeCli)
	oSayEmiss:SetText(_cEmissao)

	If (Empty(_cNomeCli))
		Alert("NF não encontrada!")
	EndIf

	//(_cAliasNF)->(DbCloseArea())

Return(.T.)

Static Function OkCanc()
	Close(oDlgEtiq)
Return

Static Function OkProc()

	If Empty(cGetNF) .Or. Empty(cGetVol)
		Aviso("Atenção","Campo Nota Fiscal ou Volume estão em branco!", {"&OK"})
	Else
		
		Processa({|| Imprimir() })

		//Atualiza quantidade de Volumes
		Dbselectarea('SF2')
		If alltrim(SF2->F2_DOC) <> alltrim(cGetNF)  .or. alltrim(cGetSerie)  <> alltrim(SF2->F2_SERIE) 
			DbsetOrder(1)
			Dbseek(xfilial('SF2') + cGetNF + cGetSerie)
		Endif 
		
		If VAL(cGetVol) > 0 
			RecLock('SF2',.F.)
				SF2->F2_VOLUME1 := VAL(cGetVol)
			SF2->(Msunlock())
		Endif 
			
		Aviso("Impressão OK","Etiquetas Emitidas Com Sucesso!", {"&OK"})
	EndIf

	cGetNF    := SPACE(TamSX3("F2_DOC")[1])
	cGetSerie := SPACE(TamSX3("F2_SERIE")[1])
	cGetVol   := SPACE(03)

	oGetNF:SetFocus()

Return()

Static Function Imprimir()

	Local cNF        := AllTrim(StrZero(Val(cGetNF),6))
	Local cVolumeTot := AllTrim(StrZero(Val(cGetVol),3))
	Local cVolume    := ""
	Local cNomeCli   := ""
	Local cDestino   := ""
	Local nTotalEtiq := Val(cGetVol)
	Local nEtiqueta  := 0

	//_cAliasNF := GetNF()
	cNomeCli  := IIF( SF2->F2_TIPO == 'D'    ,  AllTrim(SA2->A2_NREDUZ) , AllTrim(SA1->A1_NREDUZ)  )
	
    If  SF2->F2_TIPO == 'D'
        cDestino  := Substr(AllTrim(SA2->A2_MUN),1,22) + "-" + AllTrim(SA2->A2_EST)
    Else
        cDestino  := Substr(AllTrim(SA1->A1_MUN),1,22) + "-" + AllTrim(SA1->A1_EST)
    Endif 

	MSCBPRINTER("OS 214","LPT1",,,.F.)
	MSCBCHKSTATUS(.F.)

	For nEtiqueta := 1 to nTotalEtiq
		MSCBBEGIN(1,4)

		cVolume := AllTrim(StrZero(nEtiqueta,3))

		MSCBSAY(005,026,GetEmpresa(),"N","2","002,003")
		MSCBSAY(005,018,"CLIENTE:" + cNomeCli,"N","2","002,003") // cabem 25 caracteres no nome de cliente
		MSCBSAY(005,010,"DEST.:" + cDestino,"N","2","002,003") // cabem 27 caracteres no destino
		MSCBSAY(005,002,"N.F.:" + cNF + " - VOL.:" + cVolume + "/" + cVolumeTot,"N","2","002,003")

		MSCBEND()
		MSCBWrite("<STX>f320<CR>")

		Sleep(1000)
	End

	MSCBCLOSEPRINTER()
Return()

Static Function GetEmpresa()

	Local cRet := ""

	cRet := AllTrim(Upper(SM0->M0_NOME))
	cRet += "-"
	cRet += AllTrim(Upper(SM0->M0_CIDENT))

    If (SM0->M0_CODIGO == "16")
		cRet += "-O8OO-643-8880"
	EndIf

Return(cRet)
