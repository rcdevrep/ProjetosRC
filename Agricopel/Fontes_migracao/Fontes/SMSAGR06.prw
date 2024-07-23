#Include "rwmake.ch"
#Include "protheus.ch"
#Include "Topconn.ch"


//Tela de pedidos
User Function SMSAGR06(xPedidos)

	Local cQry 		:= ""
	Private nCol 	:= 0
	Private nCol1 	:= 20
	Private nCol2 	:= 400-150
	Private nCol3 	:= 1100-80
	Private nCol4 	:= 1300-80
	Private nCol5 	:= 1500-80
	Private nCol6 	:= 1800-80
	Private nCol7 	:= 2100-80
	Private nQuebra := 3000
	Private cMark   := ""//GetMark(,"TRB","C5_OK")
	Private aBrw 	:= {}
	Private lMarcados := .F.
	Private oMB06
	Private aRotina := {}
	Private cPerg := "SMSAGR04"
	Private aCampos := {}

	If !(Pergunte(cPerg))
	    Return
	Endif

	If mv_par09 <> 2
		aRotina   := { { "Recarregar" ,"U_SMS06REC" , 0, 4},;
					   { "Imprimir"   ,"U_SMS06IMP" , 0, 4}}
	Else
		aRotina   := { { "Recarregar" ,"U_SMS06REC" , 0, 4},;
					   { "Liberar Impressão" ,"U_SMS06LIB" , 0, 4},;
					   { "Imprimir"   ,"U_SMS06IMP" , 0, 4}}

		MSGINFO("Você entrou utilizando a Rotina de Liberar Impressão, dessa forma será carregado na Grid de dados os pedidos já faturados","Informacao")

	Endif

	//Gera Query de dados
	GeraQry()

    //Gera arquivo de Trabalho
	GeraTRB()

	//Grava arquivo de trabalho
	GravaTRB()

	//Cria MarkBrow
	cMark   := GetMark(,"TRB","C5_OK")

	dbSelectArea("SX3")
	dbSetOrder(2)

	aBRW := {}

	For nI := 1 To Len(aCampos)
		If dbSeek(aCampos[nI][1])
			IF Alltrim(X3_TITULO) == 'Nome'
				AADD(aBRW,{X3_CAMPO,"",IIF(nI==1,"",PADR(X3_TITULO,40)),Trim(X3_PICTURE)})
			Else
		   		AADD(aBRW,{X3_CAMPO,"",IIF(nI==1,"",Trim(X3_TITULO)),Trim(X3_PICTURE)})
			Endif
		EndIf
	Next

   	oMB06 := MarkBrow("TRB","C5_OK","",aBRW,.F.,cMark,'U_SMS06MT()')

	//CriaMark()

Return


Static  Function GeraTRB()

	aCampos := {}

	Aadd(aCampos,{ "C5_OK"		, "C", 02, 0 } )
	Aadd(aCampos,{ "C9_PEDIDO"	, "C", 06, 0 } )
	Aadd(aCampos,{ "C9_CLIENTE"	, "C", 06, 2 } )
	Aadd(aCampos,{ "C9_LOJA"	, "C", 02, 2 } )
	Aadd(aCampos,{ "A1_NOME"	, "C", 40, 0 } )
	Aadd(aCampos,{ "A1_MUN"		, "C", 60, 0 } )
	Aadd(aCampos,{ "C5_EMISSAO"	, "D", 08, 0 } )
	Aadd(aCampos,{ "C5_TRANSP"	, "C", 06, 0 } )
	Aadd(aCampos,{ "A4_NOME"	, "C", 40, 0 } )
	Aadd(aCampos,{ "C9_DATALIB"	, "D", 08, 0 } )
	Aadd(aCampos,{ "C5_XIMPRE"	, "C", 01, 0 } )
	Aadd(aCampos,{ "C5_FILIAL"	, "C", 02, 0 } )
	//Aadd(aCampos,{ "C5_LOJAENT"	, "C", 02, 0 } )
	//Aadd(aCampos,{ "C5_NF"		, "C", 01, 0 } )

	cNomArq := CriaTrab(aCampos)

	If (Select("TRB") <> 0)
	   DbSelectArea("TRB")
	   DbCloseArea()
	End

	DbUseArea(.T., , cNomArq, "TRB", Nil, .F.)

	cIndex := Criatrab(nil,.F.)

	IndRegua("TRB", cIndex, "C9_PEDIDO",,, "Selecionando Registros...")

Return


Static  Function GravaTRB()

	While QRYPED->(!EOF())

	      Dbselectarea('TRB')
	      Reclock('TRB',.T.)

	      	TRB->C5_OK      := "  "//QRYPED->
   			TRB->C9_PEDIDO  := QRYPED->C9_PEDIDO
			TRB->C9_CLIENTE := QRYPED->C9_CLIENTE
   			TRB->C9_LOJA    := QRYPED->C9_LOJA
			TRB->A1_NOME  	:= QRYPED->A1_NOME//POSICIONE('SA1',1,xFilial('SA1')+QRYPED->C9_CLIENTE+QRYPED->C9_LOJA,"A1_NOME")//QRYPED->C5_NREDUZ
   		    TRB->C5_EMISSAO := QRYPED->C5_EMISSAO
			TRB->C5_TRANSP  := QRYPED->C5_TRANSP
			TRB->A4_NOME    := POSICIONE('SA4',1,xFilial('SA4')+QRYPED->C5_TRANSP,"A4_NOME")//QRYPED->A4_NOME
			TRB->C9_DATALIB := QRYPED->C9_DATALIB
			TRB->C5_XIMPRE  := QRYPED->C5_XIMPRE
   		    TRB->C5_FILIAL  := QRYPED->C5_FILIAL
   		    TRB->A1_MUN     := POSICIONE('CC2',1,xfilial('CC2')+QRYPED->A1_EST+QRYPED->A1_COD_MUN,'CC2_MUN')

	      TRB->(MSUNLOCK())


		QRYPED->(dbskip())
	Enddo

Return

Static  Function ExcluiTRB()


//If DBSelectAREA('TRB')

		TRB->(DBGOTOP())

   		While TRB->(!EOF())

	   	   Dbselectarea('TRB')

	   	   Reclock('TRB',.F.)

	      	TRB->(DbDelete())

	      TRB->(MSUNLOCK())
	     TRB->(DBSKIP())
	Enddo
//Endif

Return

User Function SMS06MT()

	Local cGravar := "  "

	lMarcados := !lMarcados

	If lMarcados
	   cGravar := cMark
    Endif

	TRB->(DBGOTOP())
    While TRB->(!Eof())
        RecLock('TRB',.F.)
	    	TRB->C5_OK := cGravar
        TRB->(MsUnlock())
    	TRB->(Dbskip())
    Enddo
	TRB->(DBGOTOP())
Return

Static function GeraQry()

	Local cQuery   := ""
	Local _cFilAnt := MV_PAR07


	cQuery := " SELECT A1_COD_MUN,A1_EST,A1_NOME,C9_FILIAL,C9_PEDIDO,C5_OBS,C5_VEND1,C5_VEND2,C5_TRANSP,C5_VEND3,C5_FILIAL,C9_CLIENTE,C9_LOJA,C5_NOMECLI,C5_EMISSAO,C5_TRANSP,C9_DATALIB,C5_XIMPRE FROM "+RetSqlName('SC9')+" SC9 (nolock) "
	cQuery += " INNER JOIN "+RetSqlName('SC5')+" SC5 (nolock) ON (C5_NUM = C9_PEDIDO AND SC5.D_E_L_E_T_ = '' AND SC5.C5_FILIAL = SC9.C9_FILIAL ) "
	//cQuery += " INNER JOIN "+RetSqlName('SB1')+" SB1 ON (B1_COD = C9_PRODUTO AND SB1.D_E_L_E_T_ = '' AND SB1.B1_FILIAL = SC9.C9_FILIAL ) "
	cQuery += " INNER JOIN "+RetSqlName('SA1')+" SA1 (nolock) ON (C9_CLIENTE = A1_COD AND A1_LOJA =  C9_LOJA AND SA1.D_E_L_E_T_ = '' AND A1_FILIAL = '"+xfilial('SA1')+"') "
	cQuery += " INNER JOIN "+RetSqlName('SC6')+" SC6 (nolock) ON (C9_PEDIDO = C6_NUM AND C6_ITEM = C9_ITEM AND C9_FILIAL = C6_FILIAL AND SC6.D_E_L_E_T_ = '') "//LEANDRO 24.02.2016
	cQuery += " INNER JOIN "+RetSqlName('SF4')+" SF4 (nolock) ON (F4_CODIGO = C6_TES AND F4_FILIAL = C6_FILIAL AND SF4.D_E_L_E_T_ = '') "//LEANDRO 24.02.2016

	cQuery += " Where "

	//Tratamento para reimpressao
	If mv_par09 <> 2
   		cQuery += " (C9_BLEST = '' And C9_BLCRED  = '') AND "//And C9_FILIAL ='" + xFilial("SC9") + "' "
	Endif
	cQuery += "  C9_PEDIDO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += " And C9_DATALIB  >= '" +DTOS(mv_par03) + "' AND C9_DATALIB <= '" +DTOS(mv_par04)+ "' "
	cQuery += " And C6_ENTREG  >= '" +DTOS(mv_par10) + "' AND C6_ENTREG <= '" +DTOS(mv_par11)+ "' "
	cQuery += " AND C9_LOCAL = '" +mv_par05+ "' "//AND C9_LOCAL <= '" + mv_par06 + "' "
	cQuery += " AND SC9.D_E_L_E_T_ = ''"
	//cQuery += "AND C9_PEDIDO IN ("+cPedidos+")"//'"+mv_par05+"' AND '"+mv_par06+"' "

	If Alltrim(MV_PAR06) <> ""
		cQuery += " AND C5_TRANSP = '" +mv_par06+ "' "//AND C5_TRANSP <= '" + mv_par08 + "' "
	Endif

	cQuery += " AND C9_FILIAL = '" + _cFilAnt + "'"// AND C9_FILIAL <='" + mv_par10 + "' "

	If mv_par08 == 1 .or. mv_par09 == 2//sim
		cQuery += " AND C5_XIMPRE = 'S' "
	Elseif mv_par08 == 2 //nao
		cQuery += " AND C5_XIMPRE <> 'S' "
	Endif

	//Leandro Spiller - 24/02/2016
	cQuery += " AND F4_ESTOQUE <> 'N' "

	//cQuery += " OR C9_PEDIDO = '402787' " //LEANDRO RETIRAR, TESTE

	cQuery += " GROUP BY A1_COD_MUN,A1_EST,A1_NOME,C9_FILIAL,C9_PEDIDO,C5_OBS,C5_VEND1,C5_VEND2,C5_TRANSP,C5_VEND3,C5_FILIAL,C9_CLIENTE,C9_LOJA,C5_NOMECLI,C5_EMISSAO,C5_TRANSP,C9_DATALIB,C5_XIMPRE"
 	cQuery += " ORDER BY C9_PEDIDO"

	If (Select("QRYPED") <> 0)
		dbSelectArea("QRYPED")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRYPED"
	TCSETFIELD("QRYPED","C9_DATALIB" 		  ,"D",08,0)
	TCSETFIELD("QRYPED","C5_EMISSAO" 		  ,"D",08,0)

	dbSelectArea("QRYPED")
	QRYPED->(dbGoTop())


Return


//Recarrega dados em tela
User Function SMS06REC()

   If mv_par09 <> 2
		aRotina   := { { "Recarregar" ,"U_SMS06REC" , 0, 4},;
					   { "Imprimir"   ,"U_SMS06IMP" , 0, 4}}
	Else
		aRotina   := { { "Recarregar" ,"U_SMS06REC" , 0, 4},;
					   { "Liberar Impressão" ,"U_SMS06LIB" , 0, 4},;
					   { "Imprimir"   ,"U_SMS06IMP" , 0, 4}}
	Endif


   //Gera Query de dados
	GeraQry()

	//Grava arquivo de trabalho
	GeraTRB()

	GravaTRB()

	//oMB06 := MarkBrow("TRB","C5_OK","",aBRW,.F.,cMark,'U_SMS06MT()')
  	MarkBRefresh()

Return


//Imprime dados
User Function SMS06IMP()

    Local aSms06Ped := {}

	Dbselectarea('TRB')
	TRB->(DbGoTop())

	While TRB->(!Eof())

	     If cMark == TRB->C5_OK
	      	AADD(aSms06Ped,{TRB->C5_FILIAL,TRB->C9_PEDIDO })
	      Endif

		TRB->(dbskip())
	Enddo


	If len(aSms06Ped) > 0

	   //Grava pedidos Como Impressos
	   GravaIMP(aSms06Ped)

	   //Recarrega Dados
	   U_SMS06REC()

	   //Imprime dados
	   U_SMSAGR05(aSms06Ped)

	Else
		Alert('Selecione ao menos um pedido')
	Endif

Return


Static function GravaIMP(xPedG)


    //Grava TRB
    TRB->(dbgotop())
    While TRB->(!Eof())

        If TRB->C5_OK == cMark

          RecLock('TRB',.F.)
          	TRB->C5_XIMPRE := 'S'
          TRB->(Msunlock())

        Endif
    	TRB->(dbskip())
    Enddo
	TRB->(dbgotop())


    //Grava SC5
    For i := 1 to len(xPedG)
		Dbselectarea('SC5')
		SC5->(Dbgotop())
   		if DbSeek(xPedG[i][1]+xPedG[i][2])
   		 	RecLock('SC5',.F.)
   		 		C5_XIMPRE := 'S'
   		 	Msunlock()
	    Endif
	Next i

Return


User Function SMS06LIB()

    Local aSms06Lib := {}

   	Dbselectarea('TRB')
	TRB->(DbGoTop())

	While TRB->(!Eof())

	     If cMark == TRB->C5_OK
	      	AADD(aSms06Lib,{TRB->C5_FILIAL,TRB->C9_PEDIDO })
	      Endif

		TRB->(dbskip())
	Enddo


	If len(aSms06Lib) > 0

	   //Grava pedidos Como NÃO Impressos
	   GravaIMP2(aSms06Lib)

	   //Recarrega Dados
	   U_SMS06REC()
     Endif

Return

//Grava impressão como não impresso
Static function GravaIMP2(xPedG)

    //Grava TRB
    TRB->(dbgotop())
    While TRB->(!Eof())

        If TRB->C5_OK == cMark

          RecLock('TRB',.F.)
          	TRB->C5_XIMPRE := ' '
          TRB->(Msunlock())

        Endif
    	TRB->(dbskip())
    Enddo
	TRB->(dbgotop())


    //Grava SC5
    For i := 1 to len(xPedG)
		Dbselectarea('SC5')
		SC5->(Dbgotop())
   		if DbSeek(xPedG[i][1]+xPedG[i][2])
   		 	RecLock('SC5',.F.)
   		 		C5_XIMPRE := ' '
   		 	Msunlock()
	    Endif
	Next i

Return
