#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} GrossUp.PRW

@since 01/10/2022
@version P12 12.1.23
@description Rotina de Gross Up 
@description 
@obs Programador Jorge Paiva
@modify :

cPDLiqGross È um verba de base para ser lanÁado no movimento do funcio·rio com o valor de lÌquido 
que dever· ser (LQD)

cPDPrvGross È a verba de provento que vai complementar a remuneraÁ„o do funcion·rio. (116)

GrossUp( "LQD" , "116" )


/*/
User Function GrossUp( cPDLiqGross, cPDPrvGross )

Local nValLiq       := 0

Private n198        := Abs( fBuscapd( "198" ) )
Private n433        := Abs( fBuscapd( "433" ) )
Private n117Dias    := Abs( fBuscapd( "117", "H" ) )
Private nRetIRRF    := GetMV( "MV_VLRETIR" )

Default cPDLiqGross := ""
Default cPDPrvGross := ""

nValLiq := Abs( fBuscaPD( cPDLiqGross ) )

If SRA->RA_CATFUNC $ 'A-P'

	nValLiq := Abs( fBuscapd("LQD") )
EndIf

If nValLiq > 0 .And. !Empty( cPDPrvGross )

	CalcGrossUp( cPDLiqGross, cPDPrvGross, nValLiq )
EndIf

Return NIL

/*/f/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
<Descricao> : DiferenÁa de Sal·rio Bruto
<Autor> : Marcelo CorrÍa Coutinho
<Data> : 01/10/2021
<Parametros> : Nil
<Retorno> : Nil
<Processo> : State Grid
<Tipo> : 
<Obs> : 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/

Static Function CalcGrossUp( cPDLiq, cPDProv, nValLiq )

Local nIn      := 0
Local nIr      := 0
Local nK       := 0
Local nP       := 0
Local nX       := 0
Local nLiqCalc := 0
Local nDifLan  := nValLiq
Local nTotDif  := 0
Local nVal188  := 0
Local nVal116  := 0
Local nOutrasB := 0

Local aArea    := GetArea()

Local nQtdDep  := 0
Local nDedDep  := 0

Local nBsCalc  := 0
Local nIRCalc  := 0

Local nBaseIR  := 0
Local nBaseIN  := 0
Local nBsINFer := 0
Local nBsINAux := 0

Local nINSS    := ABS( fBuscaPD( aCodFol[0064][01] ) ) + ABS( fBuscaPD( aCodFol[0065][01] ) ) 

Local aIRRF    := {}
Local aINSS    := {}

Local nINOutEm := Abs( fBuscaPD( "866" ) )

Local nAPD


//----------------------------------------------------
//
//  Total de Dependentes
//
//---------------------------------------------------------------------------------------------

dbSelectArea( "SRB" )
SRB->( dbSetOrder( 1 ) )

If SRB->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) ) )

	While SRB->( RB_FILIAL + RB_MAT ) == SRA->( RA_FILIAL + RA_MAT )

		If SRB->RB_TIPIR # "4"

			nQtdDep += 1
		EndIf

		SRB->( dbSkip() )
	End
EndIf

If Val( SRA->RA_DEPIR ) > 0

	nQtdDep := Val( SRA->RA_DEPIR )
EndIf

//----------------------------------------------------
//
//  Base IRRF - Valor de AuxÌlio
//  Base INSS - Valor de AuxÌlio
//
//---------------------------------------------------------------------------------------------h



dbSelectArea( "SRV" )
SRV->( dbSetOrder( 1 ) )
n1:=n2:=0
For nP := 1 To Len( aPD )

	If aPD[nP][05] > 0 .And.;
	   SRV->( dbSeek( xFilial( "SRV" ) + aPD[nP][01] ) ) .And.;
	   Iif( cRoteiro == "RES", aPD[nP][01] # "116", .T. )

		If SRV->RV_INSS == "S"

			If SRV->RV_TIPOCOD == "1"

				nBaseIN += aPD[nP][05]
				nVal116 += aPD[nP][05]

			ElseIf SRV->RV_TIPOCOD == "2"

				nBaseIN -= aPD[nP][05]
				nVal116 -= aPD[nP][05]
			EndIf
		EndIf

		If SRV->RV_IR   == "S"

			If SRV->RV_TIPOCOD == "1"

				nBaseIR += aPD[nP][05]

			ElseIf SRV->RV_TIPOCOD == "2"

				nBaseIR -= aPD[nP][05]
			EndIf
		EndIf

		If SRV->RV_INSS <> "S" .And. SRV->RV_IR <> "S" .And. cRoteiro == "RES"

			If SRV->RV_TIPOCOD == "1"

				nOutrasB += aPD[nP][05]

			ElseIf SRV->RV_TIPOCOD == "2"

				nOutrasB -= aPD[nP][05]
			EndIf
		EndIf
	EndIf
Next nPd

//----------------------------------------------------
//
//  TABELA DE IRRF
//
//---------------------------------------------------------------------------------------------

nPisoIRRF := 0

For nIr := 1 To Len( aTabIR )

	If nIr == 5

		nDedDep := aTabIR[nIr][01]
	Else

		aAdd( aIRRF, Array( 4 ) )

		aIRRF[ Len( aIRRF ) ][ 01 ] := nPisoIRRF       //-- Piso
		aIRRF[ Len( aIRRF ) ][ 02 ] := aTabIR[nIr][01] //-- Teto
		aIRRF[ Len( aIRRF ) ][ 03 ] := aTabIR[nIr][02] //-- Percentual
		aIRRF[ Len( aIRRF ) ][ 04 ] := aTabIR[nIr][03] //-- DeduÁ„o

		nPisoIRRF := aTabIR[nIr][01] //+ 0.01
	EndIf
Next nIr

//----------------------------------------------------
//
//  TABELA DE INSS
//
//---------------------------------------------------------------------------------------------

nPisoINSS := 0

For nIn := 1 To Len( atINSS )

	aAdd( aINSS, Array( 3 ) )

	aINSS[ Len( aINSS ) ][ 01 ] := nPisoINSS       //-- Piso
	aINSS[ Len( aINSS ) ][ 02 ] := atINSS[nIn][01] //-- Teto
	aINSS[ Len( aINSS ) ][ 03 ] := atINSS[nIn][02] //-- Percentual

	nPisoINSS := atINSS[nIn][01] //+ 0.01
Next nIn

//----------------------------------------------------
//
//  C·lculo de IRRF - DiferenÁa Sal·rio Bruto
//
//---------------------------------------------------------------------------------------------

//--- SEM AUXÕLIO MORADIA

If n433 == 0

	nBsINFer := nBaseIN

	While nDifLan >= 0.005 .And. nLiqCalc < nValLiq

		If nLiqCalc == 0

			nBsINDf  := nBaseIN
		EndIf

		If SRA->RA_CATFUNC $ 'A-P'

			nINSS := aINSS[ Len( aINSS ) ][ 02 ] * 0.11
		Else

			If nBsINDf >= aINSS[ Len( aINSS ) ][ 02 ]

				nINSS := 0

				For nX := 1 To Len( aINSS )

					If nX == 1

   						nINSS += aINSS[ nX ][ 02 ] * aINSS[ nX ][ 03 ]
					Else

   						nINSS += ( aINSS[ nX ][ 02 ] - aINSS[ nX - 1 ][ 02 ] ) * aINSS[ nX ][ 03 ]
					EndIf
				Next nX
			Else

				For nX := 1 To Len( aINSS )

					If nBsINDf >= aINSS[ nX ][ 01 ] .And. ;
			   		   nBsINDf <= aINSS[ nX ][ 02 ]

	   					nINSS := nBsINDf * aINSS[ nX ][ 03 ]
					EndIf
				Next nX
			EndIf
		EndIf

		If n117Dias > 0

			nINSS := ( nINSS / ( nBsCalc + nBsINFer ) ) * nBsCalc
		EndIf

		If nINOutEm > 0

			nINSS := 0
		EndIf

		If nLiqCalc == 0

			nBsCalc  := nBaseIR - Abs( fBuscapd( "707" ) ) //aqui
		EndIf

		If nBsCalc >= aIRRF[ Len( aIRRF ) ][ 01 ]

			nIRCalc := ( ( nBsCalc - nINSS - ( nQtdDep * nDedDep ) ) * aIRRF[ Len( aIRRF ) ][ 03 ] / 100 ) - aIRRF[ Len( aIRRF ) ][ 04 ]
		Else

			For nK := 1 To Len( aIRRF )

				If nBsCalc >= aIRRF[ nK ][ 01 ] .And. ;
		   		   nBsCalc <= aIRRF[ nK ][ 02 ]

	   				nIRCalc := ( ( nBsCalc - nINSS - ( nQtdDep * nDedDep ) ) * aIRRF[ nK ][ 03 ] / 100 ) - aIRRF[ nK ][ 04 ]
				EndIf
			Next nK
		EndIf

		If n117Dias > 0

			nLiqCalc := nBsCalc
			nLiqCalc -= nIRCalc
			nLiqCalc -= nINSS

			If nLiqCalc > 0

				nDifLan := nValLiq - ( nBsCalc - nIRCalc )
			EndIf

			nTotDif  := nBsCalc
			nBsINDf  += nDifLan
			nBsCalc  += nDifLan

			If nDifLan <= 0.005

				nTotDif  := nBsCalc
				lCalcDif := .F.
			EndIf
		Else

			nIRCalc  := Iif( nIRCalc > 0, nIRCalc, 0 )
			nINSS    := Iif( nINSS   > 0, nINSS,   0 )

			nLiqCalc := nBsCalc // + nOutrasB
			nLiqCalc -= Iif( nIRCalc > 0, nIRCalc, 0 )
			nLiqCalc -= Iif( nINSS   > 0, nINSS,   0 )

			If nLiqCalc > 0

				nDifLan := nValLiq - nLiqCalc //9999.9975525
			EndIf

			If nDifLan == 0 .And. nBsCalc == nValLiq .And. nIRCalc == 0 .And. nINSS == 0

				nTotDif := nValLiq
				Exit
			EndIf

			If nDifLan >= 0.003 .And. nLiqCalc < nValLiq

		//		nTotDif := nBsCalc - Iif( SRA->RA_CATFUNC $ 'A-P', fBuscapd("188"), Iif( cRoteiro == "RES", nOutrasB, salario ) )

				nTotDif := nBsCalc - Iif( SRA->RA_CATFUNC $ 'A-P', fBuscapd("188"), salario )
				nBsINDf += nDifLan
				nBsCalc += nDifLan

				If nLiqCalc == 0

					nDifLan := nValLiq
				EndIf

				If nBaseIN == 0

					nBaseIN := nValLiq
				EndIf

				If nBaseIR == 0

					nBaseIR := nValLiq
				EndIf
			EndIf
		EndIf
	End

	//-------------------------------------
	// Verifica RetenÁ„o MÌnima de IR
	//-------------------------------------------------------

	If nIRCalc > 0 .And. nIRCalc < nRetIRRF

		nTotDif := nValLiq
	EndIf
	//--------------------------------------
	//
	//-------------------------------------------------------
Else

	//--- COM AUXÕLIO MORADIA

	nBsINFer := nBaseIN - n198
	nBsINAux := n198

	lCalcDif := .T.

	While lCalcDif

		If nLiqCalc == 0

			nBsINDf  := nBaseIN
		EndIf

		If SRA->RA_CATFUNC $ 'A-P'

			nINSS := Round( aINSS[ Len( aINSS ) ][ 02 ] * 0.11, 2 )
		Else

			If nBsINDf >= aINSS[ Len( aINSS ) ][ 02 ]

				nINSS := 0

				For nX := 1 To Len( aINSS )

					If nX == 1

   						nINSS += Round( aINSS[ nX ][ 02 ] * aINSS[ nX ][ 03 ], 2 )
					Else

   						nINSS += Round( ( aINSS[ nX ][ 02 ] - aINSS[ nX - 1 ][ 02 ] ) * aINSS[ nX ][ 03 ], 2 )
					EndIf
				Next nX
			Else

				For nX := 1 To Len( aINSS )

					If nBsINDf >= aINSS[ nX ][ 01 ] .And. ;
			   		   nBsINDf <= aINSS[ nX ][ 02 ]

	   					nINSS := nBsINDf * aINSS[ nX ][ 03 ]
					EndIf
				Next nX
			EndIf
		EndIf

		If n117Dias > 0

			nINSS := ( nINSS / ( nBsCalc + nBsINFer ) ) * nBsCalc
		EndIf

		If nINOutEm > 0

			nINSS := 0
		EndIf

		If nLiqCalc == 0

			nBsCalc := nBaseIR - Abs( fBuscapd( "707" ) ) //aqui
		EndIf

		If nBsCalc >= aIRRF[ Len( aIRRF ) ][ 01 ]

			nIRCalc := ( ( nBsCalc - nINSS - ( nQtdDep * nDedDep ) ) * aIRRF[ Len( aIRRF ) ][ 03 ] / 100 ) - aIRRF[ Len( aIRRF ) ][ 04 ]
		Else

			For nK := 1 To Len( aIRRF )

				If nBsCalc >= aIRRF[ nK ][ 01 ] .And. ;
		   		   nBsCalc <= aIRRF[ nK ][ 02 ]

	   				nIRCalc := ( ( nBsCalc - nINSS - ( nQtdDep * nDedDep ) ) * aIRRF[ nK ][ 03 ] / 100 ) - aIRRF[ nK ][ 04 ]
				EndIf
			Next nK
		EndIf

		If n117Dias > 0

			nLiqCalc := nBsCalc
			nLiqCalc -= nIRCalc
			nLiqCalc -= nINSS

			If nLiqCalc > 0

				nDifLan := nValLiq - ( nBsCalc - nIRCalc - n433 )
			EndIf

			nTotDif  := nBsCalc
			nBsINDf  += nDifLan
			nBsCalc  += nDifLan

			If nDifLan <= 0.005

				nTotDif  := nBsCalc - n198 - 0.005
				lCalcDif := .F.
			EndIf
		Else

			nLiqCalc := nBsCalc
			nLiqCalc -= nIRCalc
			nLiqCalc -= nINSS

			If nLiqCalc > 0

				nDifLan := nValLiq - ( nBsCalc - nIRCalc - nINSS - n433 )
			EndIf

			nTotDif  := nBsCalc - Iif( SRA->RA_CATFUNC $ 'A-P', fBuscapd("188"), salario )
			nBsINDf  += nDifLan
			nBsCalc  += nDifLan

			If nDifLan <= 0.005 //Round( nBsCalc - nTotDif, 3 ) == Round( ( Iif( SRA->RA_CATFUNC $ 'A-P', fBuscapd("188"), salario ) / 30 * ( 30 - n117Dias ) ), 3 ) .And. nBsCalc # nBaseIR

				nTotDif  := nBsCalc - nBaseIR + 0.002
				lCalcDif := .F.
			EndIf
		EndIf
	End
EndIf

If nTotDif > 0
	//Roteiro FOL
	If SRA->RA_CATFUNC $ 'M-H'
		

			fDelPD(cPDProv)


			If round(ABS(nVal116 + noround(nTotDif,2) - nBsCalc + 0.01),2) > 0
				nTotDif += 0.01
			EndIf

			fGeraVerba( cPDProv, nTotDif,,,,,,,,, .T. )

			
			fGeraVerba( "861", nBsCalc -  nTotDif,,,,,,,,, .T. )


	EndIf

	//Roteiro AUT
	If SRA->RA_CATFUNC $ 'A-P'

		If fLocaliapd("188") > 0

			nVal188 := fBuscapd("188")
			

			If round(ABS(nVal188 + noround(nTotDif,2) - nBsCalc + 0.01),2) > 0 //round(nLiqCalc,2) > 74700.00 .AND. round(nLiqCalc,2) <= 82300.00
				nTotDif += 0.01
			
			EndIf
			

			//0.00308657
			APD[fLocaliapd("188"),5] := nVal188 + noround(nTotDif,2)



			fDelPD( "861" )
			fGeraVerba( "861", nVal188 + noround(nTotDif,2),,,,,,,,, .T. )
			
		Else

			nTotDif += Abs( fBuscapd("188") )

			fDelPD( "188" )
			fDelPD( "861" )

			fGeraVerba( "861", noround(nTotDif,2),,,,,,,,, .T. )
			fGeraVerba( "188", noround(nTotDif,2),,,,,,,,, .T. )
		EndIf
	EndIf
	
EndIf

RestArea( aArea )

Return .T.
