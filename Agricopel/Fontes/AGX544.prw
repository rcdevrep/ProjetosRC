#INCLUDE "protheus.ch"

User Function AGX544()

	Private cCadastro := "Carga X Notas"
	Private aRotina := {}
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cAlias := "ZZT"

	AADD(aRotina,{ "Pesquisa","AxPesqui" ,0,1})
	AADD(aRotina,{ "Visual" ,"U_Mod3All" ,0,2})
	AADD(aRotina,{ "Inclui" ,"U_Mod3All" ,0,3})
	AADD(aRotina,{ "Altera" ,"U_Mod3All" ,0,4})
	AADD(aRotina,{ "Exclui" ,"U_Mod3All" ,0,5})

	dbSelectArea(cAlias)
	dbSetOrder(1)
	mBrowse( 6,1,22,75,cAlias)

Return()

User Function Mod3All(cAlias,nReg,nOpcx)

	Local cTitulo   := "Cadastro Carga X Notas"
	Local cAliasE   := "ZZT"
	Local cAliasG   := "ZZU"
	Local cLinOk    := "AllwaysTrue()"
	Local cTudOk    := "AllwaysTrue()"
	Local cFieldOk  := "AllwaysTrue()"
     Local cAliasSX3 := "SX3"
     Local cX3CAMPO  := ""
     Local cX3USADO  := ""
     Local cX3NIVEL  := ""
	Local aCposE    := {}
	Local nUsado, nX := 0

	//Exemplo (continua豫o):
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Opcoes de acesso para a Modelo 3 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	Do Case
		Case nOpcx==3; nOpcE:=3 ; nOpcG:=3 // 3 - "INCLUIR"
		Case nOpcx==4; nOpcE:=3 ; nOpcG:=3 // 4 - "ALTERAR"
		Case nOpcx==2; nOpcE:=2 ; nOpcG:=2 // 2 - "VISUALIZAR"
		Case nOpcx==5; nOpcE:=2 ; nOpcG:=2 // 5 - "EXCLUIR"
	EndCase
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Cria variaveis M->????? da Enchoice �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	RegToMemory("ZZT",(nOpcx==3 .or. nOpcx==4 )) // Se for inclusao ou alteracao permite alterar o conteudo das variaveis de memoria
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Cria aHeader e aCols da GetDados �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	nUsado:=0
	dbSelectArea(cAliasSX3)
	dbSeek("ZZU")
	aHeader:={}
	While !Eof() .And. ((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))) == "ZZU")

          cX3CAMPO := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO"))))

		If Alltrim(cX3CAMPO)=="ZZU_CARGA"
			dbSkip()
			Loop
		Endif

          cX3USADO := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO"))))
          cX3NIVEL := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_NIVEL"))))

		If X3USO(cX3USADO).And.cNivel >= cX3NIVEL
			nUsado := nUsado+1

			AADD(aHeader,{;
                  TRIM((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TITULO"))))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO")))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_PICTURE")))),;
			   (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TAMANHO")))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_DECIMAL")))),;
                  "AllwaysTrue()",;
			   (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO")))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TIPO")))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))),;
                  (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CONTEXT")))) } )
		Endif
		dbSkip()
	End
	If nOpcx==3 // Incluir
		aCols:={Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For nX:=1 to nUsado
			aCols[1,nX]:=CriaVar(aHeader[nX,2])
		Next
	Else
		aCols:={}
		dbSelectArea("ZZU")
		dbSetOrder(1)
		dbSeek(xFilial()+M->ZZT_CARGA)
		While !eof().and.ZZU_CARGA==M->ZZT_CARGA
			AADD(aCols,Array(nUsado+1))
			For nX:=1 to nUsado
				aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
			dbSkip()
		End
	Endif

	//Exemplo (continua豫o):
	If Len(aCols)>0
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Executa a Modelo 3 �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		aCposE := {"ZZT_CARGA"}
		lRetMod3 := Modelo3(cTitulo, cAliasE, cAliasG, aCposE, cLinOk, cTudOk,nOpcE, nOpcG,cFieldOk)
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Executar processamento �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

		If lRetMod3
			/*Case nOpcx==3; nOpcE:=3 ; nOpcG:=3 // 3 - "INCLUIR"
			Case nOpcx==4; nOpcE:=3 ; nOpcG:=3 // 4 - "ALTERAR"
			Case nOpcx==2; nOpcE:=2 ; nOpcG:=2 // 2 - "VISUALIZAR"
			Case nOpcx==5; nOpcE:=2 ; nOpcG:=2 // 5 - "EXCLUIR"  */

			If nOpcx == 3  .or. nOpcx ==  4
				GravaDados(nOpcx)
			Elseif nOpcx == 5
				ExcluiDados()
			EndIf
		Else
			RollBackSX8()
		Endif
	Endif
Return

Static Function GravaDados(nOpcx)

	Local _nPosDel  := Len(aHeader) + 1
	Local _cCampo   := ""
	Local _nii      := 0
	Local _ni       := 0

	Begin Transaction
		//旼컴컴컴컴컴컴컴컴커
		//쿒ravo o Cabecalho �    Caso precise gravar dados na tabela de cabecalho Habilite
		//읕컴컴컴컴컴컴컴컴켸

		dbSelectArea("ZZT")
		RecLock("ZZT",.T.)
		ZZT_FILIAL := xFilial("ZZT")
		ZZT_CARGA  := M->ZZT_CARGA
		ZZT_DATA   := M->ZZT_DATA
		ZZT_BASE   := M->ZZT_BASE
		ZZT_PLACA  := M->ZZT_PLACA
		MsUnlock()

		/*          dbSelectArea("SX3") // Posiciono o SX3 pra gravar o cabecalho
		dbSeek("ZZT")

		If RecLock("ZZT", (_cOpcao = "I"))

		ZZT_FILIAL := xFilial("

		/*               While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO = "ZZT")
		_cCampo := SX3->X3_CAMPO
		If _cCampo = "RA_MAT"
		&_cCampo := xFilial("SRA")
		Else
		If X3USO(SX3->X3_USADO) .And. (cNivel>=SX3->X3_NIVEL)
		&_cCampo := M->&_cCampo
		Endif
		EndIf
		SX3->(dbSkip())
		End
		MsUnlock() */
		//旼컴컴컴컴컴컴컴컴�
		//쿒ravo os itens...�
		//읕컴컴컴컴컴컴컴컴�
		dbSelectArea("ZZU")
		dbSetOrder(1)
		//旼컴컴컴컴컴컴컴컴컴�
		//쿣arrendo o aCols...�
		//읕컴컴컴컴컴컴컴컴컴�
		For _ni := 1 to Len(aCols)
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//쿞e encontrou o item gravado no banco...�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			dbSelectArea("ZZU")
			dbSetOrder(2)
			If dbSeek(xFilial("ZZU") + M->ZZT_CARGA + aCols[_ni][1]+aCols[_ni][2])
				// Se a linha estiver deletada...
				If (aCols[_ni][_nPosDel])
					RecLock("ZZU",.F.)
					dbDelete()
					MsUnLock()
				Else
					//旼컴컴컴컴컴컴컴커
					//쿌ltera o Item...�
					//읕컴컴컴컴컴컴컴켸
					RecLock("ZZU",.F.)
					For _nii := 1 to Len(aHeader)
						_cCampo := ALLTRIM(aHeader[_nii,2])
						&_cCampo := aCols[_ni, _nii]
					Next
					MSUnlock()
				EndIf
			Else
				If !(aCols[_ni][_nPosDel])
					RecLock("ZZU",.T.)
					ZZU_FILIAL := xFilial("ZZU")
					ZZU_CARGA  := M->ZZT_CARGA
					ZZU_SEQ    := Str(Val(ZZU->ZZU_SEQ) + 1)
					For _nii := 1 to Len(aHeader)
						_cCampo := ALLTRIM(aHeader[_nii,2])
						&_cCampo := aCols[_ni, _nii]
					Next
					MSUnlock()

				EndIf
			EndIf
		Next

		/*BEGINDOC
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿚rganiza o sequencial no banco de dados em caso de �
		//쿮xclusao de linha da Grid.                         �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		ENDDOC*/

		/*               contseq:= 1
		dbSelectArea("ZZU")
		dbSetOrder(2)
		dbSeek(xFilial("ZZU") + M->RA_MAT)
		While (!Eof().And. (ZO_MAT = M->RA_MAT))
		If ZO_MAT = M->RA_MAT
		RecLock("SZO",.F.)
		Replace ZO_SEQ With strzero(contseq,2)
		MsUnLock()
		EndIf
		SZO->(dbskip())
		contseq := contseq + 1
		End                   */
		ConfirmSX8()
	End Transaction
Return

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튔uncao    쿐xcluiDados튍utor 쿑LAVIO SILVA        � Data � 13/05/2002 볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Funcao que excluira os dados da Modelo 3...                 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       � AP5 - CEPROMAT                                              볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function ExcluiDados()

	Begin Transaction
		dbSelectArea("ZZU")
		dbSeek(xFilial("ZZU") + M->ZZT_CARGA)
		While !EOF() .And.     ZZU_CARGA = M->ZZT_CARGA
			RecLock("ZZU",.F.)
			dbDelete()
			MSUnlock()
			dbSkip()
		End

		dbselectArea("ZZT")
		dbSeek(xFilial("ZZT") + M->ZZT_CARGA)
		RecLock("ZZT",.F.)
		dbDelete()
		MSUnlock()

	End Transaction
Return       