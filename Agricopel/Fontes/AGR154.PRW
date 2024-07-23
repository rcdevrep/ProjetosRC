#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 06/11/01

User Function AGR154()        // incluido pelo assistente de conversao do AP5 IDE em 06/11/01

   // #METADATASQL
   Local cAliasSX3 := "SX3"
   Local cX3USADO  := ""
   Local cX3NIVEL  := ""
   Local cX3CAMPO  := ""
   Local cX3TIPO   := ""

   Local nIt := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPrvt("NOPCX,NUSADO,AHEADER,ACOLS,_NPOSFOR,_NPOSGRU")
	SetPrvt("_NPOSCOMP,_NPOSLARG,_NPOSQTDE,_NPOSFP,_NPOSENT,_NPOSDEL")
	SetPrvt("CTIPOENT,DDATA,NLINGETD,CTITULO,AC,AR")
	SetPrvt("ACGD,CLINHAOK,CTUDOOK,LRETMOD2,NIT,xTotCheque,cTotCheque,cMens")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcao de acesso para o Modelo 2                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// 3,4 Permitem alterar getdados e incluir linhas
	// 6 So permite alterar getdados e nao incluir linhas
	// Qualquer outro numero so visualiza
	nOpcx := 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montando aHeader                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SEF->(DbSetOrder(1))               // filial+Banco+Agencia+Conta+Num
	dbSelectArea(cAliasSX3)
	dbSetOrder(1)
	dbSeek("SEF")
	nUsado  := 0
	aHeader := {}
	While !Eof() .And. ((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))) == "SEF")

      cX3USADO := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO"))))
      cX3NIVEL := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_NIVEL"))))

		IF X3USO(cX3USADO) .And. cNivel >= cX3NIVEL

         cX3CAMPO := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO"))))

			If Upper(AllTrim(cX3CAMPO)) == "EF_VALORBX"
				dbSkip()
				Loop
			Endif

			If Upper(AllTrim(cX3CAMPO)) <> "EF_PREFIXO" .AND.;
			Upper(AllTrim(cX3CAMPO)) <> "EF_TIPO"    .AND.;
			Upper(AllTrim(cX3CAMPO)) <> "EF_BANCO"   .AND.;
			Upper(AllTrim(cX3CAMPO)) <> "EF_AGENCIA" .AND.;
			Upper(AllTrim(cX3CAMPO)) <> "EF_CONTA"   .AND.;
			Upper(AllTrim(cX3CAMPO)) <> "EF_NUM"     .AND.;
			Upper(AllTrim(cX3CAMPO)) <> "EF_VENCTO"  .AND.;
			Upper(AllTrim(cX3CAMPO)) <> "EF_VALOR"   .AND.;
			Upper(AllTrim(cX3CAMPO)) <> "EF_CMC7"

				DbSkip()
				Loop
			Endif

			nUsado := nUsado + 1

			AADD(aHeader,{;
               TRIM((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TITULO"))))),;
               (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO")))),;
               (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_PICTURE")))),;
			   (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TAMANHO")))),;
               (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_DECIMAL")))),;
               "",;
			   (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO")))),;
               (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TIPO")))),;
               (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))),;
               (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_PICTURE")))) } )
		Endif

		dbSkip()
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montando aCols                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols  := Array(1,nUsado+1)
	dbSelectArea(cAliasSX3)
	dbSeek("SEF")
	nUsado := 0
	While !Eof() .And. ((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_ARQUIVO")))) == "SEF")

      cX3CAMPO := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_CAMPO"))))

		If Upper(AllTrim(cX3CAMPO)) == "EF_VALORBX"
			dbSkip()
			Loop
		Endif

		If Upper(AllTrim(cX3CAMPO)) <> "EF_PREFIXO" .AND.;
		Upper(AllTrim(cX3CAMPO)) <> "EF_TIPO"    .AND.;
		Upper(AllTrim(cX3CAMPO)) <> "EF_BANCO"   .AND.;
		Upper(AllTrim(cX3CAMPO)) <> "EF_AGENCIA" .AND.;
		Upper(AllTrim(cX3CAMPO)) <> "EF_CONTA"   .AND.;
		Upper(AllTrim(cX3CAMPO)) <> "EF_NUM"     .AND.;
		Upper(AllTrim(cX3CAMPO)) <> "EF_VENCTO"  .AND.;
		Upper(AllTrim(cX3CAMPO)) <> "EF_VALOR"   .AND.;
		Upper(AllTrim(cX3CAMPO)) <> "EF_CMC7"
			dbSkip()
			Loop
		Endif

      cX3USADO := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_USADO"))))
      cX3NIVEL := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_NIVEL"))))

		IF X3USO(cX3USADO) .AND. cNivel >= cX3NIVEL
			nUsado := nUsado + 1
			IF nOpcx == 3

            cX3TIPO := (cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TIPO"))))

				IF cX3TIPO == "C"
					aCOLS[1][nUsado] := SPACE((cAliasSX3)->(FieldGet((cAliasSX3)->(FieldPos("X3_TAMANHO")))))
				Elseif cX3TIPO == "N"
					aCOLS[1][nUsado] := 0
				Elseif cX3TIPO == "D"
					aCOLS[1][nUsado] := CTOD('  /  /  ')
				Elseif cX3TIPO == "M"
					aCOLS[1][nUsado] := ""
				Else
					aCOLS[1][nUsado] := .F.
				Endif
			Endif
		Endif

		dbSkip()
	End

	aCOLS[1][nUsado+1] := .F.

	_nPosPref := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_PREFIXO" })
	_nPosTipo := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_TIPO"    })
	_nPosBanc := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_BANCO"   })
	_nPosAgen := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_AGENCIA" })
	_nPosCont := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_CONTA"   })
	_nPosNum  := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_NUM"     })
	_nPosVenc := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_VENCTO"  })
	_nPosValo := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_VALOR"   })
	_nPosCMC7 := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="EF_CMC7"    })

	_nPosDel  := Len(aHeader) + 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis do Cabecalho do Modelo 2                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dData    := ddatabase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis do Rodape do Modelo 2                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLinGetD := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo := "Cheques Extras"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aC := {}
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.
	#IFDEF WINDOWS
	//        AADD(aC,{"cTipoent"        ,{15,10} ,"Tipo" ,"@!",,,})
	AADD(aC,{"dData"        ,{15,200} ,"Data",    ,,,})
	#ELSE
	//        AADD(aC,{"cTipoent"     ,{6,5} ,"Tipo"       ,"@!"                   ,,,})
	AADD(aC,{"dData"     ,{6,40} ,"Data"      ,   ,,,})
	#ENDIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com descricao dos campos do Rodape do Modelo 2         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aR := {}
	// aR[n,1] = Nome da Variavel Ex.:"cCliente"
	// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aR[n,3] = Titulo do Campo
	// aR[n,4] = Picture
	// aR[n,5] = Validacao
	// aR[n,6] = F3
	// aR[n,7] = Se campo e' editavel .t. se nao .f.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com coordenadas da GetDados no modelo2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF WINDOWS
	aCGD := {42,5,123,315}
	#ELSE
	aCGD := {08,04,20,73}
	#ENDIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacoes na GetDados da Modelo 2                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//cLinhaOk := "ExecBlock('Md2LinOk',.f.,.f.)"
	//cTudoOk  := "ExecBlock('Md2TudOk',.f.,.f.)"
	cLinhaOk := "AllwaysTrue()"
	cTudoOk  := "AllwaysTrue()"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada da Modelo2                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// lRetMod2 = .t. se confirmou
	// lRetMod2 = .f. se cancelou

	ExecBlock('AGR155',.f.,.f.)

	lRetMod2   := .t.

	xTotCheque := 0
	cTotCheque := ""

	// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
	// objeto Getdados Corrente

	While lRetMod2

		lRetMod2 := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)

		If lRetMod2

			SEF->(DbSetOrder(1))               // filial+BANCO+AGENCIA+CONTA+NUM
			For nIt := 1 To Len(aCols)

				If !aCols[nIt,_nPosDel]

					DbSelectArea("SEF")
					DbSetOrder(1)
					DbSeek(xFilial("SEF")+aCols[nIt,_nPosBanc]+aCols[nIt,_nPosAgen]+aCols[nIt,_nPosCont]+aCols[nIt,_nPosNum])
					While !Eof()
						If SEF->EF_VENCTO == aCols[nIt,_nPosVenc]
							MsgStop('Cheque Ja Cadastrado...'+aCols[nIt,_nPosNum])
							lRetMod2 := .f.
						Endif
						Dbskip()
					End

					xTotCheque := xTotCheque + aCols[nIt,_nPosValo]

				Endif

			Next nIt

			If !lRetMod2
				lRetMod2 := .t.
				loop
			Endif

			IF !MsgYesNo("Confirma Atualizacao deste lote ? "+Str(xTotcheque), "Confirmação")
				xTotCheque := 0
				lRetMod2   := .t.
				loop
			Endif

		Endif

		If lRetMod2

			SEF->(DbSetOrder(1))               // filial+BANCO+AGENCIA+CONTA+NUM
			For nIt := 1 To Len(aCols)

				If !aCols[nIt,_nPosDel]

					RecLock("SEF",.T.)
					SEF->EF_FILIAL  := xFilial()
					SEF->EF_PREFIXO := aCols[nIt,_nPosPref]
					SEF->EF_TIPO    := aCols[nIt,_nPosTipo]
					SEF->EF_BANCO   := aCols[nIt,_nPosBanc]
					SEF->EF_AGENCIA := aCols[nIt,_nPosAgen]
					SEF->EF_CONTA   := aCols[nIt,_nPosCont]
					SEF->EF_NUM     := aCols[nIt,_nPosNum]
					SEF->EF_VENCTO  := aCols[nIt,_nPosVenc]
					SEF->EF_VALOR   := aCols[nIt,_nPosValo]
					SEF->EF_CMC7    := aCols[nIt,_nPosCmc7]
					SEF->EF_DATA    := dDataBase
					SEF->EF_HIST    := 'CHEQUE EXTRA'
					SEF->EF_ORIGEM  := 'AGR154'
					MsUnLock("SEF")

				Endif
			Next nIt

			Return

		EndIF

		If !lRetMod2

			#IFDEF WINDOWS
			MsgStop("Voce abortou a operacao!")
			#ELSE
			Alert("Voce abortou a operacao!")
			#ENDIF

			Return

		Endif

	End

Return